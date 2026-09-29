// =============================================================================
// site/console.js: the FPGA computer, emulated in the browser
//
// The same boot firmware (fpga/firmware/bios.s) runs on the same cycle-exact model the regression checks
// against the RTL, with the device registers of fpga/rtl/Sixfold_System.sv answered in JavaScript:
// PUTCHAR and the UART go to the terminal on the page, LEDS lights the LEDs, BUTTONS reads the buttons
// under them, BOOT restarts the core. Uploading a program sends the same byte stream tools/fpga_load.py
// sends to a real board. The emulation runs at 1 MHz (1,000,000 cycles per second of real time), which is
// what the CLOCK register reports, so programs that wait on the clock behave as on the board, only slower.
// =============================================================================
import { assemble } from '../model/asm.js';
import { Core, CONFIGS, MMIO_BASE } from '../model/core.js';
import { PROGRAMS, FIRMWARE } from '../web/programs.js';

const $ = id => document.getElementById(id);
const CLOCK_HZ = 1_000_000;
const FIRMWARE_ENTRY = 0x0000;

class EmulatedSystem {
  constructor(onChar, onLeds) {
    this.onChar = onChar; this.onLeds = onLeds;
    this.firmware = assemble(FIRMWARE);
    this.memory = new Uint8Array(65536);
    this.memory.set(this.firmware.bytes.slice(0, 0x1000), 0);
    this.rx = []; this.leds = 0; this.buttons = 0; this.timer = 0;
    this.lastTohost = 0n; this.lastCycles = 0; this.bootReason = 0; this.bootAddress = 0x2000;
    this.pendingBoot = false; this.idlePolls = 0;
    const self = this;
    this.devices = {
      load(address) {
        const offset = Number(address - MMIO_BASE);
        if (offset !== 0x18) self.idlePolls = 0;
        switch (offset) {
          case 0x08: return self.leds;
          case 0x10: return self.buttons;
          case 0x18: { // bit 0 byte waiting, bit 1 queue full (never here), bit 2 idle, 15:8 the byte
            if (!self.rx.length) self.idlePolls++;
            return (self.rx.length ? 1 : 0) | 4 | ((self.rx[0] || 0) << 8);
          }
          case 0x28: return CLOCK_HZ;
          case 0x30: return self.lastTohost;
          case 0x38: return self.lastCycles;
          case 0x40: return self.bootReason;
          case 0x48: return self.timer;
          case 0x50: return self.bootAddress;
          default: return 0;
        }
      },
      store(address, data, mask) {
        const offset = Number(address - MMIO_BASE);
        self.idlePolls = 0;
        if (offset === 0x00 && mask) self.onChar(Number(data & 0xffn));
        else if (offset === 0x08 && (mask & 1)) { self.leds = Number(data & 0xffn); self.onLeds(self.leds); }
        else if (offset === 0x18) self.rx.shift();
        else if (offset === 0x20) self.pendingBoot = true;
        else if (offset === 0x50) self.bootAddress = Number(data & 0xffffffffn);
      },
    };
    this.powerOn();
  }
  boot(vector, reason) {
    if (this.core) this.memory = this.core.mem.slice();
    this.bootReason = reason;
    this.running = vector !== FIRMWARE_ENTRY;
    this.core = new Core(this.memory, { ...CONFIGS.performance, devices: this.devices, resetPc: vector });
    this.pendingBoot = false; this.idlePolls = 0;
  }
  powerOn() { this.leds = 0; this.onLeds(0); this.rx = []; this.boot(FIRMWARE_ENTRY, 0); }
  // Wait for input instead of burning cycles: the firmware has polled an empty receive queue many times
  get waiting() { return this.idlePolls > 200 && !this.rx.length && !this.running; }
  run(cycles) {
    for (let i = 0; i < cycles; i++) {
      this.core.step(); this.timer++;
      if (this.pendingBoot) this.boot(this.bootAddress, 2);
      else if (this.core.halted) {
        this.lastTohost = this.core.csr.tohost; this.lastCycles = this.core.stats.cycles;
        this.boot(FIRMWARE_ENTRY, 1);
      }
      if (this.waiting) return;
    }
  }
  send(bytes) { this.rx.push(...bytes); this.idlePolls = 0; }
}

function uploadStream(source) {
  const img = assemble(source);
  const [lo, hi] = img.used;
  const bytes = [...img.bytes.slice(lo, hi)];
  const word = v => [v & 255, (v >>> 8) & 255, (v >>> 16) & 255, (v >>> 24) & 255];
  const checksum = bytes.reduce((a, b) => (a + b) >>> 0, 0);
  return ['l'.charCodeAt(0), ...word(lo), ...word(hi - lo), ...bytes, ...word(checksum), 'r'.charCodeAt(0)];
}

function setup() {
  const term = $('fc-term');
  if (!term) return;
  let text = '';
  const render = () => { term.textContent = text; term.scrollTop = term.scrollHeight; };
  let dirty = false;
  const onChar = c => { if (c === 13) return; text += String.fromCharCode(c); if (text.length > 20000) text = text.slice(-16000); dirty = true; };
  const ledEls = [];
  const leds = $('fc-leds');
  for (let i = 7; i >= 0; i--) { const s = document.createElement('span'); s.className = 'fc-led'; s.title = `LED ${i}`; leds.appendChild(s); ledEls[i] = s; }
  const onLeds = v => ledEls.forEach((el, i) => el.classList.toggle('on', !!((v >> i) & 1)));
  const system = new EmulatedSystem(onChar, onLeds);

  const buttons = $('fc-buttons');
  ['FIRE1', 'FIRE2', 'UP', 'DOWN', 'LEFT', 'RIGHT'].forEach((name, i) => {
    const b = document.createElement('button'); b.type = 'button'; b.textContent = name; b.className = 'fc-btn';
    const press = on => { system.buttons = on ? system.buttons | (1 << i) : system.buttons & ~(1 << i); b.classList.toggle('down', on); };
    b.addEventListener('pointerdown', () => press(true));
    ['pointerup', 'pointerleave', 'pointercancel'].forEach(e => b.addEventListener(e, () => press(false)));
    buttons.appendChild(b);
  });

  const select = $('fc-program');
  for (const name of Object.keys(PROGRAMS)) { const o = document.createElement('option'); o.value = name; o.textContent = name; select.appendChild(o); }
  select.value = '20_leds_and_buttons';
  $('fc-upload').addEventListener('click', () => { system.send(uploadStream(PROGRAMS[select.value])); term.focus(); });
  $('fc-reset').addEventListener('click', () => { text += '\n'; system.powerOn(); term.focus(); });
  term.addEventListener('keydown', e => {
    if (e.ctrlKey || e.metaKey || e.altKey) return;
    if (e.key === 'Enter') { system.send([13]); e.preventDefault(); }
    else if (e.key.length === 1) { system.send([e.key.charCodeAt(0) & 0xff]); e.preventDefault(); }
  });
  for (const [id, key] of [['fc-help', 'h'], ['fc-info', 'i'], ['fc-run', 'r'], ['fc-memtest', 'm']])
    $(id).addEventListener('click', () => { system.send([key.charCodeAt(0)]); term.focus(); });

  const status = $('fc-status');
  let visible = false, last = performance.now();
  new IntersectionObserver(entries => { visible = entries.some(e => e.isIntersecting); }, { threshold: 0.05 }).observe(term);
  const frame = now => {
    const dt = Math.min(100, now - last); last = now;
    if (visible) {
      system.run(Math.round(CLOCK_HZ * dt / 1000));
      status.textContent = system.waiting ? 'firmware waiting for input'
        : system.running ? `program running at 0x2000, cycle ${system.core.cycle.toLocaleString('en-US')}` : 'firmware running';
    }
    if (dirty) { render(); dirty = false; }
    requestAnimationFrame(frame);
  };
  requestAnimationFrame(frame);
}

setup();
