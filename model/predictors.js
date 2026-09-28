// =============================================================================
// model/predictors.js: the branch predictor arena.
//
// Trace-driven models of five direction predictors, from the simplest to the
// kind inside today's Intel, AMD and ARM cores. They are fed the real stream of
// (branch address, taken?) pairs that a program produces on Sixfold, and each
// one guesses before it is told the answer. This is how architects compare
// predictors before building one in hardware.
//
//   bht         Branch History Table: one 2-bit counter per branch (Smith 1981)
//   gshare      counter chosen by PC xor global history (McFarling 1993)  [in Sixfold's RTL]
//   tournament  BHT + gshare + a per-branch chooser (Alpha 21264)         [in Sixfold's RTL]
//   perceptron  a tiny neural network per branch (Jimenez & Lin 2001; AMD Zen used a hashed perceptron)
//   tage        TAgged GEometric history lengths (Seznec 2006; AMD Zen 2+, Intel, ARM use TAGE variants)
//
// Only gshare and the tournament are built in the RTL; the others are model-only here.
// Trace-driven means each predictor is updated right after its own guess, which is
// slightly optimistic compared with a real pipeline (see docs/MODERN_CPUS.md).
// =============================================================================

const sat = (v, lo, hi) => Math.max(lo, Math.min(hi, v));

export class BHT {
  static label = 'BHT (per-branch 2-bit)';
  constructor(bits = 7) { this.mask = (1 << bits) - 1; this.t = new Uint8Array(1 << bits).fill(2); }
  predict(pc) { return this.t[(pc >>> 2) & this.mask] >= 2; }
  update(pc, taken) { const i = (pc >>> 2) & this.mask; this.t[i] = sat(this.t[i] + (taken ? 1 : -1), 0, 3); }
}

export class GShare {
  static label = 'gshare (global history)';
  constructor(bits = 6) { this.bits = bits; this.mask = (1 << bits) - 1; this.t = new Uint8Array(1 << bits).fill(2); this.h = 0; }
  idx(pc) { return ((pc >>> 2) ^ this.h) & this.mask; }
  predict(pc) { return this.t[this.idx(pc)] >= 2; }
  update(pc, taken) { const i = this.idx(pc); this.t[i] = sat(this.t[i] + (taken ? 1 : -1), 0, 3); this.h = ((this.h << 1) | (taken ? 1 : 0)) & this.mask; }
}

export class Tournament {
  static label = 'tournament (BHT + gshare + chooser)';
  constructor() { this.b = new BHT(7); this.g = new GShare(6); this.c = new Uint8Array(128).fill(1); }
  predict(pc) { return this.c[(pc >>> 2) & 127] >= 2 ? this.g.predict(pc) : this.b.predict(pc); }
  update(pc, taken) {
    const bp = this.b.predict(pc), gp = this.g.predict(pc), i = (pc >>> 2) & 127;
    if (gp === taken && bp !== taken) this.c[i] = sat(this.c[i] + 1, 0, 3); else if (bp === taken && gp !== taken) this.c[i] = sat(this.c[i] - 1, 0, 3);
    this.b.update(pc, taken); this.g.update(pc, taken);
  }
}

// A perceptron per branch: y = w0 + sum(w_i * x_i), x_i = +1 if the i-th most recent branch was taken, else -1.
// Predict taken if y >= 0. Train when wrong, or when |y| is below a confidence threshold.
export class Perceptron {
  static label = 'perceptron (neural, 16-bit history)';
  constructor(entries = 64, history = 16) {
    this.n = entries; this.H = history; this.theta = Math.floor(1.93 * history + 14);
    this.w = Array.from({ length: entries }, () => new Int16Array(history + 1)); this.x = new Int8Array(history).fill(-1);
  }
  out(pc) { const w = this.w[(pc >>> 2) % this.n]; let y = w[0]; for (let i = 0; i < this.H; i++) y += w[i + 1] * this.x[i]; return y; }
  predict(pc) { return this.out(pc) >= 0; }
  update(pc, taken) {
    const y = this.out(pc), t = taken ? 1 : -1, w = this.w[(pc >>> 2) % this.n];
    if ((y >= 0) !== taken || Math.abs(y) <= this.theta) {
      w[0] = sat(w[0] + t, -128, 127);
      for (let i = 0; i < this.H; i++) w[i + 1] = sat(w[i + 1] + t * this.x[i], -128, 127);
    }
    this.x.copyWithin(1, 0); this.x[0] = t;
  }
}

// TAGE: a base BHT plus tagged tables looked up with geometrically longer global histories (4, 8, 16, 32).
// The longest matching table provides the prediction; on a wrong guess a new entry is allocated in a longer table.
export class TAGE {
  static label = 'TAGE (4 tagged tables, history 4-32)';
  constructor() {
    this.base = new BHT(8); this.L = [4, 8, 16, 32]; this.size = 128;
    this.tables = this.L.map(() => ({ tag: new Uint16Array(this.size), ctr: new Int8Array(this.size), u: new Uint8Array(this.size), valid: new Uint8Array(this.size) }));
    this.h = [];  // global history, newest first
  }
  fold(len, bits) { let v = 0, acc = 0; for (let i = 0; i < len; i++) { acc = (acc << 1) | (this.h[i] || 0); if ((i + 1) % bits === 0) { v ^= acc; acc = 0; } } return (v ^ acc) & ((1 << bits) - 1); }
  lookup(pc) {
    const p = pc >>> 2, hits = [];
    this.L.forEach((len, k) => {
      const i = (p ^ this.fold(len, 7) ^ (p >>> 7)) & (this.size - 1);
      const tag = (p ^ (this.fold(len, 8) * 3)) & 255;
      const T = this.tables[k];
      if (T.valid[i] && T.tag[i] === tag) hits.push({ k, i, tag });
    });
    return hits;
  }
  predict(pc) { const hits = this.lookup(pc); if (!hits.length) return this.base.predict(pc); const h = hits[hits.length - 1]; return this.tables[h.k].ctr[h.i] >= 0; }
  update(pc, taken) {
    const p = pc >>> 2, hits = this.lookup(pc), provider = hits[hits.length - 1];
    const alt = hits.length > 1 ? this.tables[hits[hits.length - 2].k].ctr[hits[hits.length - 2].i] >= 0 : this.base.predict(pc);
    const pred = provider ? this.tables[provider.k].ctr[provider.i] >= 0 : this.base.predict(pc);
    if (provider) {
      const T = this.tables[provider.k];
      T.ctr[provider.i] = sat(T.ctr[provider.i] + (taken ? 1 : -1), -4, 3);
      if (pred !== alt) T.u[provider.i] = sat(T.u[provider.i] + (pred === taken ? 1 : -1), 0, 3);
    } else this.base.update(pc, taken);
    if (pred !== taken) { // allocate in a longer table
      const start = provider ? provider.k + 1 : 0; let done = false;
      for (let k = start; k < this.L.length && !done; k++) {
        const i = (p ^ this.fold(this.L[k], 7) ^ (p >>> 7)) & (this.size - 1), T = this.tables[k];
        if (!T.valid[i] || T.u[i] === 0) { T.valid[i] = 1; T.tag[i] = (p ^ (this.fold(this.L[k], 8) * 3)) & 255; T.ctr[i] = taken ? 0 : -1; T.u[i] = 0; done = true; }
      }
      if (!done) for (let k = start; k < this.L.length; k++) { const i = (p ^ this.fold(this.L[k], 7) ^ (p >>> 7)) & (this.size - 1); this.tables[k].u[i] = sat(this.tables[k].u[i] - 1, 0, 3); }
    }
    this.h.unshift(taken ? 1 : 0); if (this.h.length > 64) this.h.pop();
  }
}

export const PREDICTORS = { bht: BHT, gshare: GShare, tournament: Tournament, perceptron: Perceptron, tage: TAGE };

// Replay a branch trace through every predictor. onStep(i, correct) lets the site animate the race.
export function runArena(trace, onStep) {
  const preds = Object.entries(PREDICTORS).map(([k, C]) => ({ key: k, label: C.label, p: new C(), right: 0 }));
  trace.forEach(([pc, taken], i) => {
    for (const r of preds) { if (r.p.predict(pc) === taken) r.right++; r.p.update(pc, taken); }
    if (onStep) onStep(i, preds);
  });
  return preds.map(r => ({ key: r.key, label: r.label, accuracy: trace.length ? r.right / trace.length : 1, correct: r.right, branches: trace.length }));
}

// The branch stream of a program: every conditional branch resolved in EXECUTE, in order.
export function branchTrace(core, maxCycles = 3e6) {
  const trace = [];
  while (!core.halted && core.cycle < maxCycles) {
    const ev = core.step();
    if (ev.resolve && ev.resolve.kind === 'branch') trace.push([ev.stages.EXECUTE.pc, ev.resolve.actual]);
  }
  return trace;
}
