// =============================================================================
// model/core.js: cycle-exact software twin of src/Riscv64.sv
//
//   FETCH1 ─► FETCH2 ─► DECODE ─► EXECUTE ─► MEMORY ─► WRITEBACK
//   gshare    predecode  regfile   ALU, MDU   Load      regfile
//   lookup    redirect   control   branch     Control   write
//             JAL/taken  forward   CSR, store
//
// Every rule below has the same name as the signal in the RTL, so you can read
// the two files side by side. `make test` runs each program through BOTH and
// diffs the per-cycle trace, so a change here must also be made in src/.
//
//   LOAD_STALL                     DECODE_VALID && EXECUTE is a load && its rd != 0 && rd matches
//                                  the rs1 OR rs2 FIELD of the Decode instruction (fields, not uses)
//   FLUSH_FETCH1_FETCH2_DECODE     EXECUTE_VALID && (branch guessed wrong || JALR)
//   FETCH2_BRANCH_OFF_OR_CONTINUE  FETCH2_VALID && (JAL || branch predicted taken)
//   Forwarding into DECODE         x0 > EXECUTE (not a load) > MEMORY > WRITEBACK > register file
//   HALT_NOW                       the instruction that wrote a nonzero TOHOST is in WRITEBACK
// =============================================================================
import { decode, disasm, usesRegs } from './isa.js';

export const STAGES = ['FETCH1', 'FETCH2', 'DECODE', 'EXECUTE', 'MEMORY', 'WRITEBACK'];
export const SHORT = { FETCH1: 'F1', FETCH2: 'F2', DECODE: 'D', EXECUTE: 'E', MEMORY: 'M', WRITEBACK: 'W' };
export const RESET_PC = 0x2000;
export const MMIO_PUTCHAR = 0x10000000n;
export const CSR = { TOHOST: 0x51E, STATUS: 0x50A, HARTID: 0x50B, CYCLE: 0xC00, INSTRET: 0xC02, MHARTID: 0xF14 };
export const DEFAULT_HISTORY_BITS = 4; // GSHARE_HISTORY_BITS in src/Riscv64.sv

const u64 = x => BigInt.asUintN(64, x);
const s64 = x => BigInt.asIntN(64, x);
const u32 = x => BigInt.asUintN(32, x);
const s32 = x => BigInt.asIntN(32, x);
const sx32 = x => u64(s32(x)); // low 32 bits sign-extended to 64
const bits = (w, hi, lo) => (w >>> lo) & ((1 << (hi - lo + 1)) - 1);
const sextN = (v, n) => BigInt.asIntN(n, BigInt(v));

// ---------------------------------------------------------------- ControlUnit + ALUdec
// Mirrors src/Control_Unit.sv and src/ALUdec.sv exactly (by opcode/funct bits, not by name).
export const OPC = { LUI: 0x37, AUIPC: 0x17, JAL: 0x6f, JALR: 0x67, BRANCH: 0x63, STORE: 0x23, LOAD: 0x03,
  OP: 0x33, OP_IMM: 0x13, OP_32: 0x3b, OP_IMM_32: 0x1b, SYSTEM: 0x73 };
export const WB = { ALU: 0, MEMORY: 1, PC_ADD_4: 2, CSR: 3 };
export const WB_NAMES = ['ALU', 'MEMORY', 'PC_ADD_4', 'CSR'];
const ARITH = ['ADD', 'SLL', 'SLT', 'SLTU', 'XOR', 'SRL_SRA', 'OR', 'AND'];
const MULDIV = ['MUL', 'MULH', 'MULHSU', 'MULHU', 'DIV', 'DIVU', 'REM', 'REMU'];

export function control(word) {
  const op = word & 0x7f, f3 = bits(word, 14, 12), f7 = bits(word, 31, 25), b30 = bits(word, 30, 30), rs1f = bits(word, 19, 15);
  const c = { regWrite: 0, memRead: 0, memWrite: 0, csrWrite: 0, csrImm: 0, aIsPC: 0, bIsImm: 0, isWord: 0, isMulDiv: 0,
    isBranch: 0, isJal: 0, isJalr: 0, immType: 'I', wbSel: WB.ALU, aluOp: 'XXX' };
  const md = f7 === 0b0000001;
  const arith = () => { const n = ARITH[f3]; return n === 'SRL_SRA' ? (b30 ? 'SRA' : 'SRL') : n; };
  switch (op) {
    case OPC.LUI: Object.assign(c, { regWrite: 1, bIsImm: 1, immType: 'U', aluOp: 'COPY_B' }); break;
    case OPC.AUIPC: Object.assign(c, { regWrite: 1, aIsPC: 1, bIsImm: 1, immType: 'U', aluOp: 'ADD' }); break;
    case OPC.JAL: Object.assign(c, { isJal: 1, regWrite: 1, aIsPC: 1, bIsImm: 1, immType: 'J', wbSel: WB.PC_ADD_4, aluOp: 'ADD' }); break;
    case OPC.JALR: Object.assign(c, { isJalr: 1, regWrite: 1, bIsImm: 1, immType: 'I', wbSel: WB.PC_ADD_4, aluOp: 'JALR' }); break;
    case OPC.BRANCH: Object.assign(c, { isBranch: 1, aIsPC: 1, bIsImm: 1, immType: 'B', aluOp: 'ADD' }); break;
    case OPC.STORE: Object.assign(c, { memWrite: 1, bIsImm: 1, immType: 'S', aluOp: 'ADD' }); break;
    case OPC.LOAD: Object.assign(c, { regWrite: 1, memRead: 1, bIsImm: 1, immType: 'I', wbSel: WB.MEMORY, aluOp: 'ADD' }); break;
    case OPC.OP: case OPC.OP_32:
      Object.assign(c, { regWrite: 1, isMulDiv: md ? 1 : 0, isWord: op === OPC.OP_32 ? 1 : 0 });
      c.aluOp = md ? MULDIV[f3] : (f3 === 0 ? (b30 ? 'SUB' : 'ADD') : arith());
      break;
    case OPC.OP_IMM: case OPC.OP_IMM_32:
      Object.assign(c, { regWrite: 1, bIsImm: 1, immType: 'I', isWord: op === OPC.OP_IMM_32 ? 1 : 0 });
      c.aluOp = f3 === 0 ? 'ADD' : arith();
      break;
    case OPC.SYSTEM:
      c.regWrite = f3 !== 0 ? 1 : 0; c.wbSel = WB.CSR;
      if (f3 === 0b001 || f3 === 0b101) c.csrWrite = 1; else if (f3 !== 0) c.csrWrite = rs1f !== 0 ? 1 : 0;
      if (f3 === 0b101 || f3 === 0b110 || f3 === 0b111) { c.csrImm = 1; c.immType = 'Z'; }
      c.aluOp = (f3 === 0b001 || f3 === 0b101) ? 'COPY_B' : 'XXX';
      break;
    default: break; // FENCE and unknown opcodes: no operation
  }
  return c;
}

// ---------------------------------------------------------------- ImmediateGenerator
export function immediate(word, type) {
  switch (type) {
    case 'I': return u64(sextN(bits(word, 31, 20), 12));
    case 'S': return u64(sextN((bits(word, 31, 25) << 5) | bits(word, 11, 7), 12));
    case 'B': return u64(sextN((bits(word, 31, 31) << 12) | (bits(word, 7, 7) << 11) | (bits(word, 30, 25) << 5) | (bits(word, 11, 8) << 1), 13));
    case 'U': return u64(sextN((word & 0xfffff000) >>> 0, 32));
    case 'J': return u64(sextN((bits(word, 31, 31) << 20) | (bits(word, 19, 12) << 12) | (bits(word, 20, 20) << 11) | (bits(word, 30, 21) << 1), 21));
    case 'Z': return BigInt(bits(word, 19, 15));
    default: return 0n;
  }
}

// ---------------------------------------------------------------- ALU (src/ALU.sv)
export function alu(a, b, op, isWord) {
  const sub = op === 'SUB' || op === 'SLT' || op === 'SLTU';
  const sum = a + (sub ? u64(~b) : b) + (sub ? 1n : 0n); // 65-bit shared adder
  if (isWord) {
    const sh = BigInt(Number(b & 31n)), lo = u32(a);
    if (op === 'SLL') return sx32(lo << sh);
    if (op === 'SRL') return sx32(lo >> sh);
    if (op === 'SRA') return sx32(u32(s32(lo) >> sh));
    return sx32(sum); // ADDW / ADDIW / SUBW use the low half of the shared adder
  }
  const sh = BigInt(Number(b & 63n));
  switch (op) {
    case 'ADD': case 'SUB': case 'JALR': return u64(sum);
    case 'AND': return a & b;
    case 'OR': return a | b;
    case 'XOR': return a ^ b;
    case 'SLT': return ((a >> 63n) !== (b >> 63n)) ? (a >> 63n) : ((u64(sum) >> 63n) & 1n);
    case 'SLTU': return ((sum >> 64n) & 1n) ? 0n : 1n;
    case 'SLL': return u64(a << sh);
    case 'SRL': return a >> sh;
    case 'SRA': return u64(s64(a) >> sh);
    case 'COPY_B': return b;
    case 'CSR': return a & u64(~b);
    default: return 0n;
  }
}

// ---------------------------------------------------------------- MultiplyDivideUnit
export function multiplyDivide(a, b, op, isWord) {
  if (isWord) {
    const A = u32(a), B = u32(b), sA = s32(A), sB = s32(B);
    let r;
    switch (op) {
      case 'MUL': r = u32(A * B); break;
      case 'DIV': r = B === 0n ? 0xffffffffn : (A === 0x80000000n && B === 0xffffffffn) ? A : u32(sA / sB); break;
      case 'DIVU': r = B === 0n ? 0xffffffffn : A / B; break;
      case 'REM': r = B === 0n ? A : (A === 0x80000000n && B === 0xffffffffn) ? 0n : u32(sA % sB); break;
      case 'REMU': r = B === 0n ? A : A % B; break;
      default: r = 0n;
    }
    return sx32(r);
  }
  const sA = s64(a), sB = s64(b);
  switch (op) {
    case 'MUL': return u64(a * b);
    case 'MULH': return u64((sA * sB) >> 64n);
    case 'MULHSU': return u64((sA * b) >> 64n);
    case 'MULHU': return u64((a * b) >> 64n);
    case 'DIV': return b === 0n ? u64(-1n) : (a === 1n << 63n && b === u64(-1n)) ? a : u64(sA / sB);
    case 'DIVU': return b === 0n ? u64(-1n) : a / b;
    case 'REM': return b === 0n ? a : (a === 1n << 63n && b === u64(-1n)) ? 0n : u64(sA % sB);
    case 'REMU': return b === 0n ? a : a % b;
    default: return 0n;
  }
}

// ---------------------------------------------------------------- BranchComparator
export function branchComparator(f3, a, b) {
  switch (f3) {
    case 0: return a === b;
    case 1: return a !== b;
    case 4: return s64(a) < s64(b);
    case 5: return !(s64(a) < s64(b));
    case 6: return a < b;
    case 7: return !(a < b);
    default: return false;
  }
}

// ---------------------------------------------------------------- Load / Store Control
export function loadControl(f3, addr, dword) {
  const off = BigInt(Number(addr & 7n));
  const byte = (dword >> (8n * off)) & 0xffn;
  const half = (dword >> (16n * (off >> 1n))) & 0xffffn;
  const word = (dword >> (32n * (off >> 2n))) & 0xffffffffn;
  switch (f3) {
    case 0: return u64(BigInt.asIntN(8, byte));
    case 1: return u64(BigInt.asIntN(16, half));
    case 2: return u64(BigInt.asIntN(32, word));
    case 3: return dword;
    case 4: return byte;
    case 5: return half;
    case 6: return word;
    default: return 0n;
  }
}
export function storeControl(f3, addr, value) {
  const off = Number(addr & 7n);
  switch (f3) {
    case 0: return { mask: 1 << off, data: (value & 0xffn) << BigInt(8 * off) };
    case 1: { const h = off >> 1; return { mask: 0b11 << (2 * h), data: (value & 0xffffn) << BigInt(16 * h) }; }
    case 2: { const w = off >> 2; return { mask: w ? 0xf0 : 0x0f, data: (value & 0xffffffffn) << BigInt(32 * w) }; }
    case 3: return { mask: 0xff, data: value };
    default: return { mask: 0, data: 0n };
  }
}

// ---------------------------------------------------------------- GSharePredictor
export class GShare {
  constructor(historyBits = DEFAULT_HISTORY_BITS, enabled = true) {
    this.historyBits = historyBits; this.enabled = enabled;
    this.mask = (1 << historyBits) - 1;
    this.pht = new Uint8Array(1 << historyBits).fill(2); // reset: every counter weakly taken (2'b10)
    this.ghr = 0;
  }
  index(pc) { return ((pc >>> 2) & this.mask) ^ this.ghr; } // FETCH_PC[HISTORY_BITS+1:2] ^ GLOBAL_HISTORY_REGISTER
  predict(pc) { const idx = this.index(pc), counter = this.pht[idx]; return { idx, counter, taken: this.enabled && counter >= 2, ghr: this.ghr, pcBits: (pc >>> 2) & this.mask }; }
  train(idx, taken) { const c = this.pht[idx]; this.pht[idx] = taken ? Math.min(3, c + 1) : Math.max(0, c - 1); return { idx, before: c, after: this.pht[idx] }; }
}

const BUBBLE = cause => ({ valid: false, cause });

// ---------------------------------------------------------------- the core
export class Core {
  // opts.bp: false = always predict not taken; opts.historyBits: GSHARE_HISTORY_BITS
  constructor(image, { bp = true, historyBits = DEFAULT_HISTORY_BITS } = {}) {
    this.mem = new Uint8Array(65536);
    this.mem.set((image.bytes || image).slice(0, 65536)); // absolute addresses: code starts at RESET_PC
    this.regs = new Array(32).fill(0n);
    this.bp = new GShare(historyBits, bp);
    this.csr = { tohost: 0n, status: 0n, cycle: 0n, instret: 0n };
    this.F1PC = RESET_PC;
    this.f2 = BUBBLE('fill'); this.d = BUBBLE('fill'); this.e = BUBBLE('fill'); this.m = BUBBLE('fill'); this.w = BUBBLE('fill');
    this.cycle = 0; this.halted = false; this.output = '';
    this.instrs = []; this.nextId = 0;
    this.stats = { cycles: 0, retired: 0, loadStalls: 0, falseLoadStalls: 0, flushes: 0, mispredicts: 0, jalrFlushes: 0,
      redirects: 0, branches: 0, predictedTaken: 0, forwards: 0,
      bubbles: { fill: 0, loaduse: 0, flush: 0, redirect: 0 } };
  }

  fetch(pc) { const m = this.mem, a = pc & 0xffff; return (m[a] | (m[(a + 1) & 0xffff] << 8) | (m[(a + 2) & 0xffff] << 16) | (m[(a + 3) & 0xffff] << 24)) >>> 0; }
  readDouble(addr) {
    if (addr === MMIO_PUTCHAR) return 0n;
    const base = Number(addr & 0xfff8n); let v = 0n;
    for (let k = 7; k >= 0; k--) v = (v << 8n) | BigInt(this.mem[(base + k) & 0xffff]);
    return v;
  }
  csrRead(addr) {
    switch (addr) {
      case CSR.TOHOST: return this.csr.tohost;
      case CSR.STATUS: return this.csr.status;
      case CSR.CYCLE: return this.csr.cycle;
      case CSR.INSTRET: return this.csr.instret;
      default: return 0n; // HARTID, MHARTID and unknown CSRs read 0
    }
  }
  instr(id, pc, word) {
    if (!this.instrs[id]) { const d = decode(word); this.instrs[id] = { id, pc, word, text: word === 0 ? '(empty memory, not code)' : disasm(d, pc), fetchCycle: this.cycle, squashed: false }; }
    return this.instrs[id];
  }

  // Advance one clock cycle. Returns an event record describing the cycle.
  step() {
    if (this.halted) return null;
    this.cycle++;
    const ev = { cycle: this.cycle, stages: {}, fwd: {}, squashed: [] };
    const { f2, d, e, m, w } = this;

    // ================= WRITEBACK =================
    const HALT_NOW = w.valid && w.writesTohost && this.csr.tohost !== 0n;
    if (w.valid) ev.stages.WRITEBACK = { id: w.id, pc: w.pc };
    const rfWrite = (w.valid && w.regWrite && w.rd !== 0) ? { rd: w.rd, value: w.data } : null;
    if (rfWrite) ev.rfWrite = rfWrite;

    // ================= MEMORY =================
    let fwdM = 0n;
    if (m.valid) {
      const loadData = loadControl(m.funct3, m.result, m.dcData);
      fwdM = [m.result, loadData, m.pc4, m.csrData][m.wbSel];
      ev.stages.MEMORY = { id: m.id, pc: m.pc };
      if (m.memRead) ev.memAccess = { kind: 'load', addr: m.result, value: loadData, dword: m.dcData, funct3: m.funct3 };
    }

    // ================= EXECUTE =================
    let FLUSH = false, adjust = 0, fwdE = 0n, exNext = null, storeOp = null, csrWrite = null, bpTrain = null, restoreGhr = null;
    if (e.valid) {
      const A = e.aIsPC ? BigInt(e.pc) : e.rs1v, B = e.bIsImm ? e.imm : e.rs2v;
      const aluOut = alu(A, B, e.aluOp, e.isWord);
      const result = e.isMulDiv ? multiplyDivide(e.rs1v, e.rs2v, e.aluOp, e.isWord) : aluOut;
      const pc4 = u64(BigInt(e.pc) + 4n);
      const jalrTarget = aluOut & ~1n;
      const taken = branchComparator(e.funct3, e.rs1v, e.rs2v);
      // BranchControl
      adjust = Number(pc4 & 0xffffffffn);
      if (e.isBranch) {
        adjust = taken ? e.target : adjust; FLUSH = taken !== e.pred;
        bpTrain = { idx: e.idx, taken };
        ev.resolve = { kind: 'branch', predicted: e.pred, actual: taken, mispredict: FLUSH, target: e.target };
      } else if (e.isJal) {
        adjust = e.target; ev.resolve = { kind: 'jal', predicted: true, actual: true, mispredict: false, target: e.target };
      } else if (e.isJalr) {
        adjust = Number(jalrTarget & 0xffffffffn); FLUSH = true;
        ev.resolve = { kind: 'jalr', predicted: false, actual: true, mispredict: true, target: adjust };
      }
      if (FLUSH) restoreGhr = e.isBranch ? ((e.ckpt << 1) | (taken ? 1 : 0)) & this.bp.mask : e.ckpt;
      const csrData = this.csrRead(e.csrAddr);
      fwdE = [result, 0n, pc4, csrData][e.wbSel];
      if (e.csrWrite) {
        const src = e.csrImm ? BigInt(bits(e.word, 19, 15)) : e.rs1v, f3 = e.funct3;
        const nv = (f3 === 2 || f3 === 6) ? (csrData | src) : (f3 === 3 || f3 === 7) ? (csrData & u64(~src)) : src;
        csrWrite = { addr: e.csrAddr, value: nv };
        ev.csrWrite = csrWrite;
      }
      if (e.memWrite) { const s = storeControl(e.funct3, result, e.rs2v); storeOp = { addr: result, ...s }; ev.memAccess = { kind: 'store', addr: result, value: e.rs2v, mask: s.mask, funct3: e.funct3 }; }
      exNext = { valid: true, id: e.id, pc: e.pc, rd: e.rd, regWrite: e.regWrite, memRead: e.memRead, funct3: e.funct3, result, pc4, csrData,
        wbSel: e.wbSel, dcData: this.readDouble(result), writesTohost: !!(e.csrWrite && e.csrAddr === CSR.TOHOST) };
      ev.stages.EXECUTE = { id: e.id, pc: e.pc };
      ev.alu = { a: A, b: B, result, op: e.aluOp, unit: e.isMulDiv ? 'MDU' : 'ALU', word: !!e.isWord };
    }

    // ================= DECODE =================
    const dw = d.valid ? d.word : 0;
    const rs1f = bits(dw, 19, 15), rs2f = bits(dw, 24, 20), rdf = bits(dw, 11, 7);
    const forward = (r) => {
      if (r === 0) return [0n, null];
      if (e.valid && e.regWrite && !e.memRead && e.rd !== 0 && e.rd === r) return [fwdE, 'EXECUTE'];
      if (m.valid && m.regWrite && m.rd !== 0 && m.rd === r) return [fwdM, 'MEMORY'];
      if (w.valid && w.regWrite && w.rd !== 0 && w.rd === r) return [w.data, 'WRITEBACK'];
      return [this.regs[r], null];
    };
    const LOAD_STALL = d.valid && e.valid && !!e.memRead && e.rd !== 0 && (e.rd === rs1f || e.rd === rs2f);
    let deNext = null;
    if (d.valid) {
      ev.stages.DECODE = { id: d.id, pc: d.pc };
      const c = control(d.word);
      const [v1, s1] = forward(rs1f), [v2, s2] = forward(rs2f);
      const use = usesRegs(decode(d.word));
      ev.fwd = { a: use.rs1 ? s1 : null, b: use.rs2 ? s2 : null, rs1: rs1f, rs2: rs2f };
      deNext = { valid: true, id: d.id, pc: d.pc, word: d.word, ...c, rs1v: v1, rs2v: v2, imm: immediate(d.word, c.immType), rd: rdf,
        funct3: bits(d.word, 14, 12), csrAddr: bits(d.word, 31, 20), pred: d.pred, idx: d.idx, ckpt: d.ckpt, target: d.target };
      if (LOAD_STALL) ev.loadStallReal = (use.rs1 && e.rd === rs1f) || (use.rs2 && e.rd === rs2f);
    }

    // ================= FETCH2 =================
    let REDIRECT = false, f2Target = 0, f2IsBranch = false;
    if (f2.valid) {
      const op = f2.word & 0x7f, isJal = op === OPC.JAL;
      f2IsBranch = op === OPC.BRANCH;
      const imm = isJal ? immediate(f2.word, 'J') : immediate(f2.word, 'B');
      f2Target = Number(u64(BigInt(f2.pc) + imm) & 0xffffffffn);
      REDIRECT = isJal || (f2IsBranch && f2.pred);
      ev.stages.FETCH2 = { id: f2.id, pc: f2.pc };
      if (f2IsBranch || isJal) ev.predecode = { kind: isJal ? 'jal' : 'branch', predicted: REDIRECT, target: f2Target, idx: f2.idx, counter: f2.counter };
    }

    // ================= FETCH1 =================
    const word = this.fetch(this.F1PC);
    const pred = this.bp.predict(this.F1PC);
    const f1Id = this.nextId;
    this.instr(f1Id, this.F1PC, word);
    ev.stages.FETCH1 = { id: f1Id, pc: this.F1PC };
    ev.predict = pred;

    const ADVANCE = !FLUSH && !LOAD_STALL;
    ev.stall = LOAD_STALL && !FLUSH;
    ev.flush = FLUSH;
    ev.redirect = REDIRECT && ADVANCE;
    ev.ghr = this.bp.ghr;

    // ================= the clock edge =================
    if (HALT_NOW) { // only the Writeback instruction finishes; everything else freezes
      if (rfWrite) this.regs[rfWrite.rd] = rfWrite.value;
      this.stats.retired++; this.stats.cycles = this.cycle;
      this.halted = true; ev.halt = true;
      return ev;
    }
    if (rfWrite) this.regs[rfWrite.rd] = rfWrite.value;
    if (w.valid) this.stats.retired++; else this.stats.bubbles[w.cause]++;
    if (storeOp && storeOp.mask) {
      if (storeOp.addr === MMIO_PUTCHAR) { this.output += String.fromCharCode(Number(storeOp.data & 0xffn)); ev.putchar = true; }
      else { const base = Number(storeOp.addr & 0xfff8n); for (let k = 0; k < 8; k++) if (storeOp.mask & (1 << k)) this.mem[(base + k) & 0xffff] = Number((storeOp.data >> BigInt(8 * k)) & 0xffn); }
    }
    if (csrWrite) { if (csrWrite.addr === CSR.TOHOST) this.csr.tohost = csrWrite.value; else if (csrWrite.addr === CSR.STATUS) this.csr.status = csrWrite.value; }
    this.csr.cycle++; if (w.valid) this.csr.instret++;
    if (bpTrain) { ev.bpUpdate = { ...this.bp.train(bpTrain.idx, bpTrain.taken), taken: bpTrain.taken }; this.stats.branches++; }
    if (FLUSH) { this.bp.ghr = restoreGhr; ev.ghrRestore = restoreGhr; }
    else if (ADVANCE && f2.valid && f2IsBranch) { this.bp.ghr = ((this.bp.ghr << 1) | (f2.pred ? 1 : 0)) & this.bp.mask; ev.ghrShift = f2.pred ? 1 : 0; }

    // statistics
    if (ev.stall) { this.stats.loadStalls++; if (!ev.loadStallReal) this.stats.falseLoadStalls++; }
    if (FLUSH) { this.stats.flushes++; if (e.isJalr) this.stats.jalrFlushes++; else this.stats.mispredicts++; }
    if (ev.redirect) this.stats.redirects++;

    // pipeline registers
    this.w = m.valid ? { valid: true, id: m.id, pc: m.pc, rd: m.rd, regWrite: m.regWrite, data: fwdM, writesTohost: m.writesTohost } : BUBBLE(m.cause);
    this.m = exNext || BUBBLE(e.cause);
    const squash = (id) => { const i = this.instrs[id]; if (i && !i.squashed) { i.squashed = true; ev.squashed.push(id); } };
    if (FLUSH) {
      this.e = BUBBLE('flush');
      if (d.valid) squash(d.id);
      if (f2.valid) squash(f2.id);
      squash(f1Id); this.nextId++;
      this.d = BUBBLE('flush'); this.f2 = BUBBLE('flush');
      this.F1PC = adjust >>> 0;
    } else if (LOAD_STALL) {
      this.e = BUBBLE('loaduse');
    } else {
      if (deNext) { this.e = deNext; if (ev.fwd.a) this.stats.forwards++; if (ev.fwd.b) this.stats.forwards++; }
      else this.e = BUBBLE(d.cause);
      this.d = f2.valid ? { valid: true, id: f2.id, pc: f2.pc, word: f2.word, pred: f2.pred, idx: f2.idx, ckpt: ev.ghr, target: f2Target } : BUBBLE(f2.cause);
      if (REDIRECT) { squash(f1Id); this.f2 = BUBBLE('redirect'); }
      else this.f2 = { valid: true, id: f1Id, pc: this.F1PC, word, pred: pred.taken, idx: pred.idx, counter: pred.counter };
      this.nextId++;
      this.F1PC = (REDIRECT ? f2Target : this.F1PC + 4) >>> 0;
    }
    this.stats.cycles = this.cycle;
    return ev;
  }

  // Run to completion. Returns the array of events (or [] when keepEvents is false).
  run(maxCycles = 2000000, keepEvents = true) {
    const events = [];
    while (!this.halted && this.cycle < maxCycles) { const ev = this.step(); if (keepEvents) events.push(ev); }
    if (!this.halted) throw new Error(`no TOHOST write within ${maxCycles} cycles (does the program end with "halt"?)`);
    return events;
  }

  // Same line format the RTL testbench prints: `make test` diffs the two.
  static traceLine(ev) {
    const f = s => (ev.stages[s] ? (ev.stages[s].pc >>> 0).toString(16).padStart(8, '0') : '--------');
    return `C${ev.cycle} ` + STAGES.map(s => `${SHORT[s]}:${f(s)}`).join(' ') + (ev.stall ? ' STALL' : '') + (ev.flush ? ' FLUSH' : '') + (ev.redirect ? ' REDIRECT' : '');
  }
}
