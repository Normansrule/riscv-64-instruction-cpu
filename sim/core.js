// =============================================================================
// sim/core.js — cycle-accurate model of the 6-stage RV64IM pipeline in rtl/.
//
//     IF ──► ID ──► RR ──► EX ──► MEM ──► WB
//   fetch  decode  reg    execute memory  write
//                  read   +branch access  back
//
// This file mirrors rtl/rv64_core.v one-to-one. `make test` runs every program
// through both and diffs the per-cycle pipeline traces, so if you change the
// hazard or forwarding rules here you must change them in the Verilog too.
//
// Pipeline registers (latches between stages), as named in the RTL:
//   if_id   IF  → ID    { valid, pc, word }
//   id_rr   ID  → RR    { valid, pc, word, decoded instruction }
//   rr_ex   RR  → EX    { ... , operand values read from the register file }
//   ex_mem  EX  → MEM   { ... , ALU result / address, store data }
//   mem_wb  MEM → WB    { ... , final value to write to rd }
//
// Hazard rules:
//   * Data hazards are solved by FORWARDING into EX from ex_mem and mem_wb,
//     plus a write-first bypass inside the register file for WB → RR.
//   * LOAD-USE: a load's data only exists after MEM, so if the instruction in
//     RR needs the register being loaded by the instruction in EX, RR/ID/IF
//     stall for one cycle and a bubble is inserted into EX.
//   * CONTROL: a gshare branch predictor + branch target buffer (BTB) guess
//     the next PC in IF. Branches/jumps resolve in EX; a MISPREDICTION
//     flushes the 3 younger instructions in IF, ID and RR (3-cycle penalty).
//     With the predictor disabled (bp=false) every branch is predicted
//     not-taken, i.e. every taken branch/jump costs 3 cycles.
//   * ECALL/EBREAK/illegal reaching EX flush the younger instructions and
//     stop fetch; the core halts when that instruction reaches WB.
// =============================================================================
import { decode, usesRegs, disasm } from './isa.js';

export const STAGES = ['IF', 'ID', 'RR', 'EX', 'MEM', 'WB'];
export const MMIO_PUTCHAR = 0x10000000n;
const M64 = (1n << 64n) - 1n;
const u64 = x => BigInt.asUintN(64, x);
const s64 = x => BigInt.asIntN(64, x);
const s32 = x => BigInt.asIntN(32, x);
const u32 = x => BigInt.asUintN(32, x);
const sx32 = x => u64(s32(x));          // take low 32 bits, sign-extend to 64
const MIN64 = 1n << 63n;

const LOADS = { lb: [1, true], lh: [2, true], lw: [4, true], ld: [8, false], lbu: [1, false], lhu: [2, false], lwu: [4, false] };
const STORES = { sb: 1, sh: 2, sw: 4, sd: 8 };
const BRANCHES = new Set(['beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu']);
export const isHalt = d => d.name === 'ecall' || d.name === 'ebreak' || d.name === 'illegal';

// Pure ALU/branch semantics. a, b are unsigned 64-bit BigInts.
export function execute(d, a, b, pc) {
  const imm = BigInt(d.imm);
  const immU = u64(imm);
  const P = BigInt(pc);
  const sh6 = x => x & 63n, sh5 = x => x & 31n;
  switch (d.name) {
    case 'lui': return u64(s32(imm << 12n));
    case 'auipc': return u64(P + s32(imm << 12n));
    case 'jal': case 'jalr': return u64(P + 4n);
    case 'addi': return u64(a + immU);
    case 'slti': return s64(a) < imm ? 1n : 0n;
    case 'sltiu': return a < immU ? 1n : 0n;
    case 'xori': return a ^ immU;
    case 'ori': return a | immU;
    case 'andi': return a & immU;
    case 'slli': return u64(a << sh6(imm));
    case 'srli': return a >> sh6(imm);
    case 'srai': return u64(s64(a) >> sh6(imm));
    case 'add': return u64(a + b);
    case 'sub': return u64(a - b);
    case 'sll': return u64(a << sh6(b));
    case 'slt': return s64(a) < s64(b) ? 1n : 0n;
    case 'sltu': return a < b ? 1n : 0n;
    case 'xor': return a ^ b;
    case 'srl': return a >> sh6(b);
    case 'sra': return u64(s64(a) >> sh6(b));
    case 'or': return a | b;
    case 'and': return a & b;
    case 'addiw': return sx32(a + immU);
    case 'slliw': return sx32(a << sh5(imm));
    case 'srliw': return sx32(u32(a) >> sh5(imm));
    case 'sraiw': return sx32(s32(a) >> sh5(imm));
    case 'addw': return sx32(a + b);
    case 'subw': return sx32(a - b);
    case 'sllw': return sx32(a << sh5(b));
    case 'srlw': return sx32(u32(a) >> sh5(b));
    case 'sraw': return sx32(s32(a) >> sh5(b));
    case 'mul': return u64(a * b);
    case 'mulh': return u64((s64(a) * s64(b)) >> 64n);
    case 'mulhsu': return u64((s64(a) * b) >> 64n);
    case 'mulhu': return u64((a * b) >> 64n);
    case 'div': return b === 0n ? M64 : (a === MIN64 && b === M64) ? a : u64(s64(a) / s64(b));
    case 'divu': return b === 0n ? M64 : a / b;
    case 'rem': return b === 0n ? a : (a === MIN64 && b === M64) ? 0n : u64(s64(a) % s64(b));
    case 'remu': return b === 0n ? a : a % b;
    case 'mulw': return sx32(a * b);
    case 'divw': { const x = s32(a), y = s32(b); if (y === 0n) return M64; if (x === -(1n << 31n) && y === -1n) return sx32(x); return sx32(x / y); }
    case 'divuw': { const x = u32(a), y = u32(b); if (y === 0n) return M64; return sx32(x / y); }
    case 'remw': { const x = s32(a), y = s32(b); if (y === 0n) return sx32(x); if (x === -(1n << 31n) && y === -1n) return 0n; return sx32(x % y); }
    case 'remuw': { const x = u32(a), y = u32(b); if (y === 0n) return sx32(x); return sx32(x % y); }
  }
  if (d.name in LOADS || d.name in STORES) return u64(a + immU);   // effective address
  return 0n; // branches, fence, ecall, ebreak
}

export function branchTaken(name, a, b) {
  switch (name) {
    case 'beq': return a === b;
    case 'bne': return a !== b;
    case 'blt': return s64(a) < s64(b);
    case 'bge': return s64(a) >= s64(b);
    case 'bltu': return a < b;
    case 'bgeu': return a >= b;
  }
  return false;
}

const BUBBLE = Object.freeze({ valid: false });

// -----------------------------------------------------------------------------
// gshare predictor (McFarling 1993) + direct-mapped branch target buffer.
// Mirrors rtl/branch_predictor.v exactly.
//
//   index  = PC[GHR_BITS+1:2] XOR GHR          (which 2-bit counter to use)
//   PHT    = 2^GHR_BITS two-bit saturating counters, reset to 01 (weakly NT)
//   GHR    = global history: last GHR_BITS conditional-branch outcomes
//   BTB    = 2^BTB_BITS entries {valid, tag = PC[31:7], target, is_jump}
//   predict taken  <=>  BTB hit AND (is_jump OR counter >= 2)
// Tables are updated when the branch resolves in EX (non-speculative).
// -----------------------------------------------------------------------------
export const GHR_BITS = 8, BTB_BITS = 5;
export class Gshare {
  // history=false turns gshare into a plain bimodal predictor (model-only,
  // used by `rv.mjs bp` to show what the global history buys you).
  constructor(enabled = true, history = true) {
    this.enabled = enabled;
    this.history = history;
    this.pht = new Uint8Array(1 << GHR_BITS).fill(1);
    this.ghr = 0;
    this.btb = Array.from({ length: 1 << BTB_BITS }, () => ({ valid: false, tag: 0, target: 0, jump: false }));
  }
  index(pc) { return (((pc >>> 2) & ((1 << GHR_BITS) - 1)) ^ this.ghr) & ((1 << GHR_BITS) - 1); }
  btbSlot(pc) { return (pc >>> 2) & ((1 << BTB_BITS) - 1); }
  predict(pc) {
    const idx = this.index(pc), e = this.btb[this.btbSlot(pc)];
    const hit = e.valid && e.tag === (pc >>> 7);
    const counter = this.pht[idx];
    const taken = this.enabled && hit && (e.jump || counter >= 2);
    return { taken, target: taken ? e.target : 0, idx, hit, counter };
  }
  // returns a description of the update (for the visualizer)
  update(pc, idx, isBranch, isJump, taken, target) {
    const u = {};
    if (isBranch) {
      const c = this.pht[idx];
      this.pht[idx] = taken ? Math.min(3, c + 1) : Math.max(0, c - 1);
      u.counter = [c, this.pht[idx]];
      if (this.history) this.ghr = ((this.ghr << 1) | (taken ? 1 : 0)) & ((1 << GHR_BITS) - 1);
    }
    if ((isBranch && taken) || isJump) {
      this.btb[this.btbSlot(pc)] = { valid: true, tag: pc >>> 7, target, jump: isJump };
      u.btbWrite = true;
    }
    return u;
  }
}

export class Core {
  constructor(bytes, { bp = true, history = true } = {}) {
    this.bp = new Gshare(bp, history);
    this.mem = new Uint8Array(0x10000);
    this.mem.set(bytes.subarray(0, 0x10000));
    this.regs = new Array(32).fill(0n);
    this.pc = 0;
    this.stop = false;           // fetch stopped (halt instruction in flight)
    this.if_id = BUBBLE; this.id_rr = BUBBLE; this.rr_ex = BUBBLE; this.ex_mem = BUBBLE; this.mem_wb = BUBBLE;
    this.cycle = 0;
    this.halted = false;
    this.output = '';
    this.nextId = 0;
    this.instrs = [];            // every fetched instruction: {id, pc, text, fetchCycle, squashed}
    this.stats = { cycles: 0, retired: 0, loadUseStalls: 0, branchFlushes: 0, squashed: 0, forwards: 0, branches: 0, jumps: 0, mispredicts: 0, predictedTaken: 0 };
    this.illegal = false;
  }

  readMem(addr, size) {
    let v = 0n;
    for (let k = size - 1; k >= 0; k--) v = (v << 8n) | BigInt(this.mem[Number((addr + BigInt(k)) & 0xffffn)]);
    return v;
  }
  fetch(pc) {
    const m = this.mem, a = pc & 0xffff;
    return (m[a] | (m[(a + 1) & 0xffff] << 8) | (m[(a + 2) & 0xffff] << 16) | (m[(a + 3) & 0xffff] << 24)) >>> 0;
  }

  // Advance one clock cycle. Returns an event record describing the cycle.
  step() {
    if (this.halted) return null;
    this.cycle++;
    const ev = { cycle: this.cycle, stages: {}, notes: [] };
    const tag = s => (s.valid ? { id: s.id, pc: s.pc, text: s.text } : null);
    ev.stages = { IF: this.stop ? null : { id: this.nextId, pc: this.pc, text: '' }, ID: tag(this.if_id), RR: tag(this.id_rr), EX: tag(this.rr_ex), MEM: tag(this.ex_mem), WB: tag(this.mem_wb) };

    // ---------------- WB : write the register file ---------------------------
    const wb = this.mem_wb;
    let rfWrite = null;
    if (wb.valid) {
      this.stats.retired++;
      if (wb.regWrite && wb.rd !== 0) { this.regs[wb.rd] = wb.wbVal; rfWrite = { rd: wb.rd, value: wb.wbVal }; }
      if (isHalt(wb.d)) { this.halted = true; this.illegal = wb.d.name === 'illegal'; }
    }
    ev.rfWrite = rfWrite;

    // ---------------- MEM : data memory access -------------------------------
    const mm = this.ex_mem;
    let nextMemWb = BUBBLE, memWrite = null;
    if (mm.valid) {
      let wbVal = mm.wbVal;
      if (mm.d.name in LOADS) {
        const [size, signed] = LOADS[mm.d.name];
        const isIO = mm.addr === MMIO_PUTCHAR;
        let v = isIO ? 0n : this.readMem(mm.addr, size);
        if (signed) v = u64(BigInt.asIntN(size * 8, v));
        wbVal = v;
        ev.memAccess = { kind: 'load', addr: mm.addr, size, value: v };
      } else if (mm.d.name in STORES) {
        const size = STORES[mm.d.name];
        memWrite = { addr: mm.addr, size, value: mm.storeData & ((1n << BigInt(size * 8)) - 1n) };
        ev.memAccess = { kind: 'store', ...memWrite };
      }
      nextMemWb = { ...mm, wbVal };
    }

    // ---------------- EX : forwarding, ALU, branch resolution ----------------
    const ex = this.rr_ex;
    let nextExMem = BUBBLE, redirect = null, haltEx = false, bpUpdate = null;
    ev.fwd = { a: null, b: null };
    if (ex.valid) {
      const fwd = (reg, readVal, which) => {
        if (reg === 0) return readVal;
        if (mm.valid && mm.regWrite && mm.rd === reg) { ev.fwd[which] = 'MEM'; return mm.wbVal; }
        if (wb.valid && wb.regWrite && wb.rd === reg) { ev.fwd[which] = 'WB'; return wb.wbVal; }
        return readVal;
      };
      const a = ex.use.rs1 ? fwd(ex.d.rs1, ex.a, 'a') : ex.a;
      const b = ex.use.rs2 ? fwd(ex.d.rs2, ex.b, 'b') : ex.b;
      if (ev.fwd.a) this.stats.forwards++;
      if (ev.fwd.b) this.stats.forwards++;
      const result = execute(ex.d, a, b, ex.pc);
      const n = ex.d.name;
      // ---- resolve control flow and compare with what IF predicted ----
      const isBranch = BRANCHES.has(n), isJump = n === 'jal' || n === 'jalr';
      let target = 0;
      if (n === 'jal' || isBranch) target = (ex.pc + ex.d.imm) >>> 0;
      else if (n === 'jalr') target = Number(u64(a + u64(BigInt(ex.d.imm))) & ~1n & 0xffffffffn);
      const actualTaken = isJump || (isBranch && branchTaken(n, a, b));
      const mispredict = actualTaken !== ex.pred.taken || (actualTaken && target !== ex.pred.target);
      if (mispredict) redirect = actualTaken ? target : (ex.pc + 4) >>> 0;
      if (isBranch) this.stats.branches++;
      if (isJump) this.stats.jumps++;
      if (mispredict) this.stats.mispredicts++;
      bpUpdate = { pc: ex.pc, idx: ex.pred.idx, isBranch, isJump, taken: actualTaken, target };
      ev.resolve = (isBranch || isJump || ex.pred.taken) ? { predicted: ex.pred.taken, actual: actualTaken, mispredict, target } : null;
      haltEx = isHalt(ex.d);
      ev.alu = { a, b, result, taken: actualTaken && isBranch };
      nextExMem = { ...ex, wbVal: result, addr: result, storeData: b };
    }

    // ---------------- RR : register read (write-first bypass from WB) --------
    const rr = this.id_rr;
    let nextRrEx = BUBBLE;
    if (rr.valid) {
      nextRrEx = { ...rr, a: this.regs[rr.d.rs1], b: this.regs[rr.d.rs2] };
      if (rfWrite && rr.use.rs1 && rfWrite.rd === rr.d.rs1) ev.notes.push(`RF bypass WB→RR (${'x' + rr.d.rs1})`);
    }

    // ---------------- ID : decode ---------------------------------------------
    const id = this.if_id;
    let nextIdRr = BUBBLE;
    if (id.valid) {
      const d = decode(id.word);
      const use = usesRegs(d);
      nextIdRr = { ...id, d, use, rd: use.rd ? d.rd : 0, regWrite: use.rd && d.rd !== 0 };
    }

    // ---------------- IF : fetch ------------------------------------------------
    let nextIfId = BUBBLE, pred = null;
    if (!this.stop) {
      const word = this.fetch(this.pc);
      const d = decode(word);
      const inst = { id: this.nextId, pc: this.pc, text: disasm(d, this.pc), word, fetchCycle: this.cycle, squashed: false };
      ev.stages.IF.text = inst.text;
      pred = this.bp.predict(this.pc);        // read tables BEFORE this cycle's update
      ev.predict = pred;
      nextIfId = { valid: true, id: inst.id, pc: this.pc, word, text: inst.text, pred };
      this.pendingFetch = inst;
    }

    // ---------------- hazard unit -------------------------------------------------
    const loadUse = ex.valid && (ex.d.name in LOADS) && ex.rd !== 0 && rr.valid &&
      ((rr.use.rs1 && rr.d.rs1 === ex.rd) || (rr.use.rs2 && rr.d.rs2 === ex.rd));

    // commit memory write (MEM stage) at the clock edge
    if (memWrite) {
      if (memWrite.addr === MMIO_PUTCHAR) this.output += String.fromCharCode(Number(memWrite.value & 0xffn));
      else for (let k = 0; k < memWrite.size; k++)
        this.mem[Number((memWrite.addr + BigInt(k)) & 0xffffn)] = Number((memWrite.value >> BigInt(8 * k)) & 0xffn);
    }

    // predictor tables update at the clock edge (instruction in EX resolved)
    if (bpUpdate) ev.bpUpdate = { ...bpUpdate, ...this.bp.update(bpUpdate.pc, bpUpdate.idx, bpUpdate.isBranch, bpUpdate.isJump, bpUpdate.taken, bpUpdate.target) };

    ev.stall = false; ev.flush = [];
    if (this.halted) { ev.halt = true; this.stats.cycles = this.cycle; return ev; }

    const squash = (latch) => { if (latch.valid) { this.instrs[latch.id].squashed = true; this.stats.squashed++; ev.flush.push(latch.id); } };
    if (redirect !== null || haltEx) {
      // flush the three younger instructions (in IF, ID, RR)
      squash(rr); squash(id);
      if (!this.stop) { this.instrs[this.pendingFetch.id] = this.pendingFetch; this.nextId++; squash({ valid: true, id: this.pendingFetch.id }); }
      this.if_id = BUBBLE; this.id_rr = BUBBLE; this.rr_ex = BUBBLE;
      if (redirect !== null) { this.pc = redirect; this.stats.branchFlushes++; ev.redirect = redirect; }
      if (haltEx) { this.stop = true; ev.haltEx = true; }
    } else if (loadUse) {
      // hold IF, ID, RR; insert a bubble into EX
      ev.stall = true; this.stats.loadUseStalls++;
      this.rr_ex = BUBBLE;
    } else {
      if (!this.stop) {
        this.instrs[this.pendingFetch.id] = this.pendingFetch; this.nextId++;
        if (pred.taken) this.stats.predictedTaken++;
        this.pc = pred.taken ? pred.target : (this.pc + 4) >>> 0;
      }
      this.if_id = nextIfId; this.id_rr = nextIdRr; this.rr_ex = nextRrEx;
    }
    this.ex_mem = nextExMem; this.mem_wb = nextMemWb;
    this.stats.cycles = this.cycle;
    return ev;
  }

  // Run to completion. Returns array of events (or just counts if !keepEvents).
  run(maxCycles = 200000, keepEvents = true) {
    const events = [];
    while (!this.halted && this.cycle < maxCycles) { const e = this.step(); if (keepEvents) events.push(e); }
    if (!this.halted) throw new Error(`did not halt within ${maxCycles} cycles (missing ecall?)`);
    return events;
  }

  // Same line format the RTL testbench prints — used by `make test` to diff.
  static traceLine(ev) {
    const f = s => (ev.stages[s] ? ev.stages[s].pc.toString(16).padStart(8, '0') : '--------');
    return `C${ev.cycle} ` + STAGES.map(s => `${s}:${f(s)}`).join(' ') + (ev.stall ? ' STALL' : '') + (ev.redirect !== undefined || ev.haltEx ? ' FLUSH' : '');
  }
}
