// =============================================================================
// web/regions.js: "who is running?" for programs that share the CPU
//
// A program can name the parts of its code in a header line:
//   # REGIONS: task0=task0 task1=task1 task2=task2 kernel=kernel_start asleep=task_done
// Each entry is name=label (or name=address); a region runs from its label up to the next region's label (in address
// order). Every cycle is charged to the region of the last instruction that reached WRITEBACK, so
// bubbles count for the code that caused them. Used by the lab (web/app.js) and the front page.
// =============================================================================
import { assemble } from '../model/asm.js';
import { Core } from '../model/core.js';

export function parseRegions(source, symbols) {
  const m = source.match(/^#\s*REGIONS:\s*(.+)$/m);
  if (!m) return null;
  const names = [], starts = [];
  for (const part of m[1].trim().split(/\s+/)) {
    const [name, label] = part.split('=');
    const start = label in symbols ? Number(symbols[label]) : /^(0x[0-9a-f]+|\d+)$/i.test(label || '') ? Number(label) : NaN;
    if (!name || Number.isNaN(start)) continue;
    starts.push({ start, index: names.length });
    names.push(name);
  }
  if (!names.length) return null;
  starts.sort((a, b) => a.start - b.start);
  return {
    names,
    of(pc) { let k = -1; for (const s of starts) { if (pc >= s.start) k = s.index; else break; } return k; },
  };
}

// Tracks the current region while a core runs: call step(ev) after every core.step().
export class RegionTracker {
  constructor(regions) { this.regions = regions; this.current = -1; this.cycles = new Array(regions.names.length).fill(0); }
  step(ev) {
    const w = ev.stages.WRITEBACK;
    if (w) { const k = this.regions.of(w.pc); if (k >= 0) this.current = k; }
    if (this.current >= 0) this.cycles[this.current]++;
    return this.current;
  }
}

// Runs a whole program and returns its timeline: one region index per cycle (255 = none yet).
// Async and chunked, so a long program does not freeze the page.
export async function profile(source, coreOptions = {}, maxCycles = 2_000_000) {
  const img = assemble(source);
  const regions = parseRegions(source, img.symbols);
  if (!regions) return null;
  const core = new Core(img, coreOptions), tracker = new RegionTracker(regions);
  let timeline = new Uint8Array(1 << 16), traps = [];
  while (!core.halted && core.cycle < maxCycles) {
    for (let k = 0; k < 20000 && !core.halted; k++) {
      const ev = core.step(), r = tracker.step(ev);
      if (ev.cycle > timeline.length) { const t = new Uint8Array(timeline.length * 2); t.set(timeline); timeline = t; }
      timeline[ev.cycle - 1] = r < 0 ? 255 : r;
      if (ev.interrupt) traps.push(ev.cycle);
    }
    await new Promise(r => setTimeout(r, 0));
  }
  return { regions, timeline: timeline.slice(0, core.cycle), cycles: core.cycle, perRegion: tracker.cycles, traps, stats: core.stats, regs: core.regs };
}

// Draws a timeline as one row per region (a Gantt chart) into a canvas.
export function drawTimeline(canvas, prof, colors, { rowHeight = 16, gap = 4, labelWidth = 0, upTo = Infinity } = {}) {
  const dpr = Math.min(2, window.devicePixelRatio || 1);
  const W = canvas.clientWidth, n = prof.regions.names.length, H = n * (rowHeight + gap);
  if (canvas.width !== Math.round(W * dpr) || canvas.height !== Math.round(H * dpr)) { canvas.width = Math.round(W * dpr); canvas.height = Math.round(H * dpr); canvas.style.height = H + 'px'; }
  const g = canvas.getContext('2d');
  g.setTransform(dpr, 0, 0, dpr, 0, 0); g.clearRect(0, 0, W, H);
  const plotW = W - labelWidth, last = Math.min(upTo, prof.cycles);
  g.globalAlpha = 0.12; g.fillStyle = colors.track || '#888';
  for (let r = 0; r < n; r++) g.fillRect(labelWidth, r * (rowHeight + gap), plotW, rowHeight);
  g.globalAlpha = 1;
  // one pixel column at a time: the region that ran most in that column's cycles
  const perPx = prof.cycles / plotW;
  for (let x = 0; x < plotW; x++) {
    const a = Math.floor(x * perPx), b = Math.min(last, Math.floor((x + 1) * perPx));
    if (a >= last) break;
    const count = new Array(n).fill(0);
    for (let c = a; c < Math.max(b, a + 1); c++) { const r = prof.timeline[c]; if (r !== 255) count[r]++; }
    for (let r = 0; r < n; r++) if (count[r]) { g.fillStyle = colors[prof.regions.names[r]] || colors.default || '#888'; g.fillRect(labelWidth + x, r * (rowHeight + gap), 1.05, rowHeight); }
  }
  if (labelWidth) {
    g.fillStyle = colors.text || '#ccc'; g.font = `500 ${Math.min(12, rowHeight - 3)}px 'IBM Plex Mono', monospace`; g.textBaseline = 'middle';
    prof.regions.names.forEach((name, r) => g.fillText(name, 0, r * (rowHeight + gap) + rowHeight / 2 + 1));
  }
  if (upTo < prof.cycles) { const x = labelWidth + upTo / prof.cycles * plotW; g.fillStyle = colors.cursor || '#fff'; g.fillRect(x - 1, 0, 2, H); }
  return { plotLeft: labelWidth, plotWidth: plotW };
}
