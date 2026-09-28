#!/usr/bin/env node
// =============================================================================
// tools/animations.mjs: animated SVGs for the README and the site (make animations)
//
//   docs/img/animations/pipeline.svg   a real trace from model/core.js, cycle by cycle:
//                                      forwarding, a load stall, a FETCH2 redirect, a flush
//   docs/img/animations/wallace.svg    a multiply step: partial products compressed 3 -> 2
//                                      level by level (the numbers are real and checked)
//   docs/img/animations/cache.svg      five accesses to a 2-way cache: miss, hit, conflict,
//                                      least-recently-used eviction
//   docs/img/animations/predictor.svg  a 2-bit counter against gshare on a loop branch
//
// Plain SVG + CSS keyframes (no JavaScript), so the files animate as <img> in a GitHub
// README. Every frame is a <g> that is visible for exactly one time slot of the loop.
// =============================================================================
import fs from 'node:fs';
import path from 'node:path';
import { assemble } from '../model/asm.js';
import { Core, CONFIGS, STAGES } from '../model/core.js';

const FONT = "font-family=\"'IBM Plex Sans','Segoe UI',Helvetica,Arial,sans-serif\"";
const MONO = "font-family=\"'IBM Plex Mono',Consolas,monospace\"";
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const C = {
  ink: '#17251D', sub: '#4A5A50', faint: '#8A968E', paper: '#FBFCF8', line: '#D5DBD0',
  F1: '#2E86C1', F2: '#17A2B8', D: '#6A5ACD', E: '#E08E0B', M: '#27AE60', W: '#C0392B',
  hit: '#1E8449', miss: '#C0392B', flush: '#C2185B', pred: '#00796B', tag: '#C9982E', idx: '#17A2B8', off: '#6A5ACD',
};
const STAGE_COL = { FETCH1: C.F1, FETCH2: C.F2, DECODE: C.D, EXECUTE: C.E, MEMORY: C.M, WRITEBACK: C.W };
const PALETTE = ['#2E86C1', '#8E44AD', '#16A085', '#D35400', '#2C3E50', '#C0392B', '#7D6608', '#1ABC9C', '#6A5ACD', '#B03A2E', '#117A65', '#AF601A'];

// An animated SVG made of frames: frame(i, svg) is visible during slot i of the loop.
function animation(W, H, frames, secondsPerFrame, slide = 0) {
  const dur = frames * secondsPerFrame, f = 100 / frames, e = f * 0.999;
  const css = `
  .fr{opacity:0;animation:show ${dur}s linear infinite}
  .sl{opacity:0;animation:slide ${dur}s ease-out infinite}
  .pb{animation:grow ${dur}s linear infinite;transform-box:fill-box;transform-origin:0 0}
  @keyframes show{0%{opacity:1}${e.toFixed(3)}%{opacity:1}${f.toFixed(3)}%{opacity:0}100%{opacity:0}}
  @keyframes slide{0%{opacity:0.2;transform:translateX(-${slide}px)}${(f * 0.3).toFixed(3)}%{opacity:1;transform:translateX(0)}${e.toFixed(3)}%{opacity:1;transform:translateX(0)}${f.toFixed(3)}%{opacity:0}100%{opacity:0}}
  @keyframes grow{0%{transform:scaleX(0)}100%{transform:scaleX(1)}}
  @media (prefers-reduced-motion: reduce){.fr,.sl,.pb{animation-duration:${dur * 3}s}}`;
  const out = [];
  const add = s => out.push(s);
  add(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}"><style>${css}</style>`);
  add(`<rect width="100%" height="100%" rx="12" fill="${C.paper}" stroke="${C.line}"/>`);
  const text = (x, y, s, { size = 12, weight = 400, fill = C.ink, anchor = 'start', mono = false } = {}) =>
    `<text x="${x}" y="${y}" ${mono ? MONO : FONT} font-size="${size}" font-weight="${weight}" fill="${fill}" text-anchor="${anchor}">${esc(s)}</text>`;
  const rect = (x, y, w, h, { fill = '#FFF', stroke = C.line, sw = 1.2, rx = 6, op = 1 } = {}) =>
    `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${rx}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}"${op < 1 ? ` fill-opacity="${op}"` : ''}/>`;
  const frame = (i, body, cls = 'fr') => add(`<g class="${cls}" style="animation-delay:${(i * secondsPerFrame).toFixed(3)}s">${body}</g>`);
  const progress = (x, y, w) => { add(rect(x, y, w, 5, { fill: '#E8ECE5', stroke: 'none', rx: 2.5 })); add(`<rect class="pb" x="${x}" y="${y}" width="${w}" height="5" rx="2.5" fill="${C.pred}"/>`); };
  return { add, text, rect, frame, progress, done: () => { add('</svg>'); return out.join('\n'); } };
}

// =============================================================================
// 1. The pipeline, from a real model trace
// =============================================================================
export function pipelineAnimation() {
  const src = `
    li   t0, 3
    la   s0, data
loop:
    ld   t1, 0(s0)
    add  t2, t2, t1
    addi s0, s0, 8
    addi t0, t0, -1
    bnez t0, loop
    sh3add t3, t0, s0
    cpop t4, t2
    halt
data:
    .dword 5, 7, 9`;
  const img = assemble(src);
  const core = new Core(img, { ...CONFIGS.performance, caches: false });
  const labels = Object.fromEntries(Object.entries(img.symbols).filter(([k]) => k !== '.').map(([k, v]) => [v, k]));
  const pretty = t => t.replace(/^addi (\w+), zero, (-?\d+)$/, 'li   $1, $2')
    .replace(/^bne (\w+), zero, 0x([0-9a-f]+)$/, (m, r, h) => `bnez ${r}, ${labels[parseInt(h, 16)] || '0x' + h}`)
    .replace(/^auipc s0, 0x0$/, 'la   s0, data (1/2)').replace(/^addi s0, s0, 44$/, 'la   s0, data (2/2)');
  const evs = core.run().slice(0, 28);
  const T = evs.length, W = 1240, H = 470, x0 = 30, sw = 196, sy = 112, sh = 92;
  const a = animation(W, H, T, 1.1, 60);
  const { add, text, rect, frame, progress } = a;
  add(text(24, 34, 'The pipeline, cycle by cycle (a real trace from the cycle-exact model)', { size: 19, weight: 700 }));
  add(text(24, 56, 'A loop that sums three numbers: forwarding, a load stall, a predicted-taken branch, a flush when the loop exits. Caches off for clarity.', { size: 12.5, fill: C.sub }));
  STAGES.forEach((s, i) => {
    const x = x0 + i * (sw + 4);
    add(rect(x, 76, sw, 28, { fill: STAGE_COL[s], stroke: STAGE_COL[s], rx: 6 }));
    add(text(x + 10, 95, s, { size: 13, weight: 700, fill: '#FFF' }));
    add(rect(x, sy, sw, sh, { fill: STAGE_COL[s], stroke: STAGE_COL[s], op: 0.06, rx: 8 }));
  });
  let retired = 0;
  const colorOf = id => PALETTE[id % PALETTE.length];
  const place = {}; // id -> stage index in the previous cycle
  const story = ev => {
    if (ev.flush) return ['FLUSH: the branch guessed "taken" but the loop is over. BranchControl squashes the 3 younger', 'instructions (red) and FETCH1 restarts at the right address: 3 bubbles.', C.flush];
    if (ev.stall) return ['LOAD_STALL: add needs t1, but the load only has it in MEMORY next cycle. DECODE and the', 'front end hold; a bubble goes into EXECUTE. Then the value is forwarded from MEMORY.', '#B8860B'];
    if (ev.redirect) return ['FETCH2 redirect: predecode sees a branch the predictor calls taken, so FETCH1 jumps back to', 'the top of the loop. The instruction fetched behind it is squashed: 1 bubble.', C.F2];
    if (ev.fwd.a === 'EXECUTE' || ev.fwd.b === 'EXECUTE') return ['Forwarding: DECODE needs a value that EXECUTE is computing right now. It is taken straight', 'from the ALU output at the end of this cycle, so nothing waits.', C.E];
    if (ev.fwd.a === 'MEMORY' || ev.fwd.b === 'MEMORY') return ['Forwarding from MEMORY: the loaded value reaches DECODE one stage later than an ALU result.', '', C.M];
    return ['Six instructions in flight, one finishing per cycle when nothing is in the way.', '', C.sub];
  };
  evs.forEach((ev, c) => {
    let body = '';
    const now = {};
    STAGES.forEach((s, i) => {
      const x = x0 + i * (sw + 4);
      const st = ev.stages[s];
      if (!st) { body += text(x + sw / 2, sy + 52, 'bubble', { size: 12, fill: C.faint, anchor: 'middle' }); return; }
      const ins = core.instrs[st.id], squashed = ev.squashed.includes(st.id);
      now[st.id] = i;
      const moved = place[st.id] === i - 1, held = place[st.id] === i;
      let box = rect(x + 8, sy + 12, sw - 16, sh - 24, { fill: squashed ? '#FDECEA' : '#FFF', stroke: squashed ? C.flush : colorOf(st.id), sw: 2.2, rx: 8 });
      box += `<rect x="${x + 8}" y="${sy + 12}" width="6" height="${sh - 24}" rx="3" fill="${squashed ? C.flush : colorOf(st.id)}"/>`;
      box += text(x + 22, sy + 38, pretty(ins.text).slice(0, 22), { size: 12.5, mono: true, weight: 600, fill: squashed ? C.flush : C.ink });
      let note = `pc 0x${ins.pc.toString(16)}`;
      if (squashed) note = 'squashed';
      else if (held && s === 'DECODE') note = 'held (waiting for t1)';
      else if (s === 'DECODE' && (ev.fwd.a || ev.fwd.b)) note = `operand from ${ev.fwd.a || ev.fwd.b}`;
      else if (s === 'WRITEBACK') note = 'retires';
      box += text(x + 22, sy + 58, note, { size: 11, fill: squashed ? C.flush : C.sub });
      if (s === 'WRITEBACK' && !squashed) retired++;
      body += moved ? `<g class="sl" style="animation-delay:${(c * 1.1).toFixed(3)}s">${box}</g>` : `<g>${box}</g>`;
    });
    Object.keys(place).forEach(k => delete place[k]); Object.assign(place, now);
    const [l1, l2, col] = story(ev);
    body += rect(x0, 230, W - 60, 70, { fill: col, stroke: col, op: 0.08, rx: 10 });
    body += text(x0 + 16, 258, l1, { size: 13.5, weight: 600, fill: C.ink });
    if (l2) body += text(x0 + 16, 280, l2, { size: 13.5, fill: C.sub });
    body += text(W - 40, 40, `cycle ${ev.cycle} of ${T}`, { size: 15, weight: 700, anchor: 'end', mono: true });
    body += text(W - 40, 60, `${retired} retired`, { size: 12, anchor: 'end', fill: C.sub, mono: true });
    // timeline cursor
    body += rect(x0 + c * ((W - 60) / T), 344, (W - 60) / T - 2, 30, { fill: 'none', stroke: C.ink, sw: 2.4, rx: 4 });
    frame(c, body);
  });
  // timeline
  add(text(x0, 334, 'every cycle of the trace', { size: 11.5, fill: C.sub, weight: 600 }));
  evs.forEach((ev, c) => {
    const x = x0 + c * ((W - 60) / T), w = (W - 60) / T - 2;
    const col = ev.flush ? C.flush : ev.stall ? '#E0B03A' : ev.redirect ? C.F2 : (ev.stages.WRITEBACK ? C.M : '#D9DED6');
    add(rect(x, 344, w, 30, { fill: col, stroke: 'none', rx: 4, op: 0.85 }));
    add(text(x + w / 2, 364, String(ev.cycle), { size: 10, anchor: 'middle', fill: '#FFF', weight: 700, mono: true }));
  });
  const key = [[C.M, 'an instruction retired'], ['#D9DED6', 'no instruction retired (pipeline filling, bubble)'], ['#E0B03A', 'load stall'], [C.F2, 'FETCH2 redirect'], [C.flush, 'flush']];
  let kx = x0;
  key.forEach(([col, s]) => { add(rect(kx, 390, 14, 14, { fill: col, stroke: 'none', rx: 3 })); add(text(kx + 20, 402, s, { size: 11.5, fill: C.sub })); kx += 34 + s.length * 6.2; });
  add(text(x0, 440, 'Drawn by tools/animations.mjs from model/core.js, the same model `make test` checks against the RTL on every cycle.', { size: 11, fill: C.faint }));
  progress(x0, 452, W - 60);
  return a.done();
}

// =============================================================================
// 2. The Wallace tree: one multiply step, level by level
// =============================================================================
export function wallaceAnimation() {
  const A = 0xB73n, Bm = 0xB5n, ACC_S = 0x1A5n, ACC_C = 0x0F4n; // 12-bit multiplicand, 8 multiplier bits, a carry-save accumulator
  const AW = 12, BW = 8;
  const rows0 = [];
  for (let j = 0; j < BW; j++) rows0.push({ v: ((Bm >> BigInt(j)) & 1n) ? A << BigInt(j) : 0n, label: `A x b${j} (b${j} = ${(Bm >> BigInt(j)) & 1n})`, lo: j, hi: j + AW - 1 });
  rows0.push({ v: ACC_S, label: 'accumulator: sum', lo: 0, hi: 9 });
  rows0.push({ v: ACC_C, label: 'accumulator: carry', lo: 0, hi: 9 });
  const levels = [rows0];
  while (levels.at(-1).length > 2) {
    const prev = levels.at(-1), next = [];
    for (let i = 0; i + 2 < prev.length; i += 3) {
      const [x, y, z] = prev.slice(i, i + 3);
      const lo = Math.min(x.lo, y.lo, z.lo), hi = Math.max(x.hi, y.hi, z.hi);
      next.push({ v: x.v ^ y.v ^ z.v, label: 'sum bits', lo, hi, from: i });
      next.push({ v: ((x.v & y.v) | (x.v & z.v) | (y.v & z.v)) << 1n, label: 'carry bits (one column left)', lo: lo + 1, hi: hi + 1, from: i });
    }
    for (let i = prev.length - (prev.length % 3); i < prev.length; i++) next.push({ ...prev[i], label: prev[i].label + ' (passes through)', from: null });
    levels.push(next);
  }
  const final = levels.at(-1)[0].v + levels.at(-1)[1].v;
  const expect = A * Bm + ACC_S + ACC_C;
  if (final !== expect) throw new Error('wallace animation arithmetic');
  const COLS = AW + BW + levels.length, W = 1240, H = 560, cell = 22, right = 1000, top = 120;
  const frames = levels.length + 1;
  const a = animation(W, H, frames, 2.6, 0);
  const { add, text, rect, frame, progress } = a;
  add(text(24, 34, 'Inside one multiply step: a Wallace tree never waits for a carry', { size: 19, weight: 700 }));
  add(text(24, 56, `A = ${A} (12 bits) x the next 8 multiplier bits (${Bm}) + the carry-save accumulator. Each level turns every 3 rows into 2 with full adders.`, { size: 12.5, fill: C.sub }));
  for (let c = 0; c < COLS; c++) add(text(right - c * cell, top - 14, String(c), { size: 9, anchor: 'middle', fill: C.faint, mono: true }));
  const tripleCol = ['#2E86C1', '#D35400', '#8E44AD', '#16A085'];
  levels.forEach((rows, L) => {
    let body = '';
    body += text(24, 94, L === 0 ? 'level 0: the partial products (multiplicand shifted by j, kept only where multiplier bit j is 1), plus the two accumulator rows' : `level ${L}: ${levels[L - 1].length} rows -> ${rows.length} rows (${Math.floor(levels[L - 1].length / 3)} row${Math.floor(levels[L - 1].length / 3) > 1 ? "s" : ""} of full adders in parallel)`, { size: 14, weight: 600 });
    rows.forEach((r, i) => {
      const y = top + i * 32, grp = L < levels.length - 1 && i < rows.length - (rows.length % 3) ? Math.floor(i / 3) : -1;
      if (grp >= 0 && rows.length > 2) body += rect(right - r.hi * cell - 14, y - 12, (r.hi - r.lo) * cell + 28, 26, { fill: tripleCol[grp % 4], stroke: 'none', op: 0.1, rx: 13 });
      for (let c = r.lo; c <= r.hi; c++) {
        const bit = (r.v >> BigInt(c)) & 1n;
        body += `<circle cx="${right - c * cell}" cy="${y}" r="7.5" fill="${bit ? (grp >= 0 && rows.length > 2 ? tripleCol[grp % 4] : C.ink) : '#FFF'}" stroke="${grp >= 0 && rows.length > 2 ? tripleCol[grp % 4] : C.ink}" stroke-width="1.6"/>`;
      }
      body += text(right + 24, y + 4, r.label, { size: 11.5, fill: C.sub });
    });
    if (rows.length > 2) body += text(24, H - 70, 'Same-coloured rows go through one row of full adders together: sum = x ^ y ^ z stays in its column, carry = majority(x, y, z) moves one column left.', { size: 12.5, fill: C.sub });
    else body += text(24, H - 70, 'Two rows left: in Sixfold they stay two (the carry-save accumulator) until the SIGN cycle, where one prefix adder sums them.', { size: 12.5, fill: C.sub });
    body += text(W - 40, 40, `level ${L} / ${levels.length - 1}`, { size: 15, weight: 700, anchor: 'end', mono: true });
    frame(L, body);
  });
  let body = text(24, 94, 'After the last step: one carry-propagate adder (Kogge-Stone) turns the two rows into the product', { size: 14, weight: 600 });
  const bitsRow = (v, y, label, col) => { let s = ''; for (let c = 0; c < COLS; c++) { const b = (v >> BigInt(c)) & 1n; s += `<circle cx="${right - c * cell}" cy="${y}" r="7.5" fill="${b ? col : '#FFF'}" stroke="${col}" stroke-width="1.6"/>`; } return s + text(right + 24, y + 4, label, { size: 11.5, fill: C.sub }); };
  body += bitsRow(levels.at(-1)[0].v, top, 'sum row', C.ink) + bitsRow(levels.at(-1)[1].v, top + 32, 'carry row', C.ink);
  body += `<line x1="${right - (COLS - 1) * cell - 12}" y1="${top + 52}" x2="${right + 12}" y2="${top + 52}" stroke="${C.ink}" stroke-width="2"/>`;
  body += bitsRow(final, top + 76, `= ${final}`, C.hit);
  body += text(24, top + 150, `${A} x ${Bm} + ${ACC_S} + ${ACC_C} = ${expect}  (checked when this picture was drawn)`, { size: 15, weight: 700, fill: C.hit, mono: true });
  body += text(24, top + 180, `${levels.length - 1} levels of one full adder each: no carry ever travels more than one column before the final add.`, { size: 13, fill: C.sub });
  body += text(24, top + 200, 'The real step (src/Carry_Save_Multiplier.sv) does 64 x 16 bits: 18 rows -> 2 in 6 levels, every clock cycle.', { size: 13, fill: C.sub });
  body += text(W - 40, 40, 'final add', { size: 15, weight: 700, anchor: 'end', mono: true });
  frame(levels.length, body);
  progress(24, H - 30, W - 48);
  return a.done();
}

// =============================================================================
// 3. A 2-way set-associative cache: five accesses
// =============================================================================
export function cacheAnimation() {
  // 4 sets x 2 ways x 32-byte lines (a small version of Sixfold's 64 sets): address = tag | set (2 bits) | offset (5 bits)
  const accesses = [0x2040, 0x2058, 0x2840, 0x3040, 0x2840];
  const sets = 4, ways = [Array(sets).fill(null), Array(sets).fill(null)], lru = Array(sets).fill(0), time = [Array(sets).fill(0), Array(sets).fill(0)];
  const W = 1240, H = 520;
  const steps = [];
  accesses.forEach((addr, n) => {
    const set = (addr >> 5) & 3, tag = addr >> 7, off = addr & 31;
    const hitWay = ways.findIndex(w => w[set] === tag);
    const before = ways.map(w => w.slice()), lruBefore = lru.slice();
    let victim = -1, why = '';
    if (hitWay < 0) {
      victim = ways[0][set] === null ? 0 : ways[1][set] === null ? 1 : lru[set];
      why = ways[0][set] === null || ways[1][set] === null ? 'an empty way' : `way ${victim}, the least recently used`;
      ways[victim][set] = tag;
      lru[set] = 1 - victim;
    } else lru[set] = 1 - hitWay;
    steps.push({ n, addr, set, tag, off, hitWay, victim, why, before, after: ways.map(w => w.slice()), lruBefore, lruAfter: lru.slice() });
  });
  const a = animation(W, H, steps.length * 2, 2.2, 0);
  const { add, text, rect, frame, progress } = a;
  add(text(24, 34, 'A 2-way set-associative cache at work: miss, hit, conflict, eviction', { size: 19, weight: 700 }));
  add(text(24, 56, 'A small version of Sixfold\'s caches (4 sets instead of 64). Address = tag | set (2 bits) | offset (5 bits): each line holds 32 bytes.', { size: 12.5, fill: C.sub }));
  const drawCache = (state, lruS, s, hl, hlWay, col) => {
    let b = '';
    const cx = 560, cy = 170;
    [0, 1].forEach(w => b += text(cx + 60 + w * 250, cy - 12, `way ${w}`, { size: 13, weight: 700, anchor: 'middle' }));
    b += text(cx + 560, cy - 12, 'LRU', { size: 13, weight: 700, anchor: 'middle' });
    for (let set = 0; set < sets; set++) {
      const y = cy + set * 52;
      b += text(cx - 14, y + 30, `set ${set}`, { size: 12, anchor: 'end', fill: set === s ? C.idx : C.faint, weight: set === s ? 700 : 400 });
      [0, 1].forEach(w => {
        const t = state[w][set], on = set === s && hl && w === hlWay;
        b += rect(cx + w * 250 - 60, y, 240, 44, { fill: on ? col : set === s ? '#FFF8DC' : '#FFF', stroke: on ? col : set === s ? C.idx : C.line, sw: on ? 2.6 : 1.3, op: on ? 0.18 : 1 });
        b += text(cx + w * 250 + 60, y + 28, t === null ? 'empty' : `tag 0x${t.toString(16)}  (0x${(t << 7 | set << 5).toString(16)}..)`, { size: 12, anchor: 'middle', mono: true, fill: t === null ? C.faint : C.ink });
      });
      b += rect(cx + 530, y, 60, 44, { fill: set === s ? '#FFF8DC' : '#FFF', stroke: set === s ? C.idx : C.line });
      b += text(cx + 560, y + 28, String(lruS[set]), { size: 13, anchor: 'middle', mono: true });
    }
    return b;
  };
  const addrBits = (st) => {
    const bits = st.addr.toString(2).padStart(14, '0').split('');
    let b = text(40, 110, `access ${st.n + 1}: load from 0x${st.addr.toString(16)}`, { size: 16, weight: 700, mono: true });
    bits.forEach((bit, i) => {
      const pos = 13 - i, col = pos >= 7 ? C.tag : pos >= 5 ? C.idx : C.off;
      b += rect(40 + i * 30, 124, 26, 32, { fill: col, stroke: 'none', op: bit === '1' ? 0.9 : 0.2, rx: 4 });
      b += text(40 + i * 30 + 13, 146, bit, { size: 14, weight: 700, anchor: 'middle', mono: true, fill: bit === '1' ? '#FFF' : col });
    });
    b += text(40, 180, `tag 0x${st.tag.toString(16)}`, { size: 13, weight: 700, fill: C.tag, mono: true });
    b += text(150, 180, `set ${st.set}`, { size: 13, weight: 700, fill: C.idx, mono: true });
    b += text(240, 180, `offset ${st.off}`, { size: 13, weight: 700, fill: C.off, mono: true });
    return b;
  };
  steps.forEach((st, k) => {
    // frame 1: look up
    let b = addrBits(st);
    b += text(40, 230, `1. The set bits pick set ${st.set} in BOTH ways (highlighted).`, { size: 13.5 });
    b += text(40, 256, `2. Two comparators check both stored tags against 0x${st.tag.toString(16)} at the same time.`, { size: 13.5 });
    b += drawCache(st.before, st.lruBefore, st.set, false, -1, C.hit);
    b += text(W - 40, 40, `access ${st.n + 1} / ${steps.length}: look up`, { size: 14, weight: 700, anchor: 'end', mono: true });
    frame(2 * k, b);
    // frame 2: result
    b = addrBits(st);
    const hit = st.hitWay >= 0;
    b += rect(40, 208, 460, 150, { fill: hit ? C.hit : C.miss, stroke: hit ? C.hit : C.miss, op: 0.08, rx: 10 });
    b += text(60, 240, hit ? `HIT in way ${st.hitWay}` : 'MISS', { size: 22, weight: 800, fill: hit ? C.hit : C.miss });
    const lines = hit
      ? [`The data comes back this same cycle: 0 extra cycles.`, `LRU for set ${st.set} now points at way ${st.lruAfter[st.set]}`, '(the way NOT just used is next to go).']
      : [`The pipeline waits 11 cycles while the refill engine`, `fetches the 32-byte line. It goes into ${st.why}.`, `LRU now points at way ${st.lruAfter[st.set]}. Next-line prefetch starts.`];
    lines.forEach((l, i) => b += text(60, 272 + i * 22, l, { size: 13.5, fill: C.sub }));
    b += drawCache(st.after, st.lruAfter, st.set, true, hit ? st.hitWay : st.victim, hit ? C.hit : C.miss);
    b += text(W - 40, 40, `access ${st.n + 1} / ${steps.length}: ${hit ? 'hit' : 'miss'}`, { size: 14, weight: 700, anchor: 'end', mono: true });
    frame(2 * k + 1, b);
  });
  add(text(40, 420, 'Why two ways? 0x2040 and 0x2840 share set 2. A direct-mapped cache would throw one out every time; here both fit,', { size: 12.5, fill: C.sub }));
  add(text(40, 440, 'until a third line of set 2 (0x3040) arrives and replaces the one used longest ago.', { size: 12.5, fill: C.sub }));
  add(text(40, 470, 'Same behaviour as src/Data_Cache.sv and src/Instruction_Cache.sv (64 sets there); drawn by tools/animations.mjs.', { size: 11, fill: C.faint }));
  progress(24, H - 24, W - 48);
  return a.done();
}

// =============================================================================
// 4. A 2-bit counter against gshare on a loop branch
// =============================================================================
export function predictorAnimation() {
  // A loop branch that is taken 3 times, then not taken once, over and over (T T T N ...)
  const outcomes = [];
  for (let i = 0; i < 5; i++) outcomes.push(1, 1, 1, 0);
  let ctr = 2, bimRight = 0;
  const HB = 3; let ghr = 0; const pht = new Uint8Array(1 << HB).fill(2); let gRight = 0;
  const steps = outcomes.map((t, i) => {
    const pb = ctr >= 2 ? 1 : 0, idx = ghr, pg = pht[idx] >= 2 ? 1 : 0;
    const s = { i, t, ctrBefore: ctr, pb, ghr, idx, phtBefore: Array.from(pht), pg };
    if (pb === t) bimRight++; if (pg === t) gRight++;
    ctr = t ? Math.min(3, ctr + 1) : Math.max(0, ctr - 1);
    pht[idx] = t ? Math.min(3, pht[idx] + 1) : Math.max(0, pht[idx] - 1);
    ghr = ((ghr << 1) | t) & ((1 << HB) - 1);
    return { ...s, ctrAfter: ctr, bimRight, gRight, phtAfter: Array.from(pht) };
  });
  const W = 1240, H = 520;
  const a = animation(W, H, steps.length, 1.3, 0);
  const { add, text, rect, frame, progress } = a;
  add(text(24, 34, 'Why history helps: one 2-bit counter against gshare on a loop branch (taken, taken, taken, not taken, ...)', { size: 19, weight: 700 }));
  add(text(24, 56, 'The same outcome stream goes into both. The single counter always misses the loop exit; gshare learns that "after T T T comes N".', { size: 12.5, fill: C.sub }));
  const STATES = ['strong N', 'weak N', 'weak T', 'strong T'], SC = ['#C0392B', '#E59866', '#82C99A', '#1E8449'];
  steps.forEach((s, k) => {
    let b = '';
    // outcome stream
    outcomes.forEach((t, i) => {
      const x = 40 + i * 58, on = i === k;
      b += rect(x, 80, 50, 34, { fill: i < k ? (t ? C.hit : C.miss) : '#FFF', stroke: on ? C.ink : C.line, sw: on ? 2.6 : 1.2, op: i < k ? 0.25 : 1, rx: 6 });
      b += text(x + 25, 102, i <= k ? (t ? 'T' : 'N') : '?', { size: 14, weight: 700, anchor: 'middle', fill: i <= k ? (t ? C.hit : C.miss) : C.faint });
    });
    // one counter
    b += rect(40, 140, 560, 300, { fill: '#FFF', stroke: C.line, rx: 10 });
    b += text(60, 166, 'One 2-bit counter (a Branch History Table entry)', { size: 14, weight: 700 });
    STATES.forEach((n, i) => {
      const cx = 110 + i * 130, on = i === s.ctrBefore;
      b += `<circle cx="${cx}" cy="240" r="${on ? 44 : 38}" fill="${SC[i]}" fill-opacity="${on ? 0.9 : 0.15}" stroke="${SC[i]}" stroke-width="${on ? 3 : 1.5}"/>`;
      b += text(cx, 244, n, { size: 12, weight: 700, anchor: 'middle', fill: on ? '#FFF' : C.ink });
    });
    b += text(60, 322, `predicts: ${s.pb ? 'TAKEN' : 'NOT TAKEN'}`, { size: 16, weight: 700, fill: s.pb === s.t ? C.hit : C.miss });
    b += text(60, 348, s.pb === s.t ? 'right' : `wrong: the branch was ${s.t ? 'taken' : 'not taken'} (a 3-cycle flush on Sixfold)`, { size: 13, fill: s.pb === s.t ? C.hit : C.miss });
    b += text(60, 410, `right so far: ${s.bimRight} of ${k + 1}`, { size: 15, weight: 700, mono: true });
    // gshare
    b += rect(630, 140, 570, 300, { fill: '#FFF', stroke: C.line, rx: 10 });
    b += text(650, 166, 'gshare: 3 bits of history pick one of 8 counters', { size: 14, weight: 700 });
    b += text(650, 196, 'history (last 3 outcomes):', { size: 12.5, fill: C.sub });
    for (let j = 2; j >= 0; j--) { const bit = (s.ghr >> j) & 1; b += rect(830 + (2 - j) * 34, 180, 30, 26, { fill: bit ? C.hit : C.miss, stroke: 'none', rx: 4, op: 0.85 }); b += text(845 + (2 - j) * 34, 198, bit ? 'T' : 'N', { size: 13, weight: 700, anchor: 'middle', fill: '#FFF' }); }
    for (let e = 0; e < 8; e++) {
      const x = 650 + e * 66, on = e === s.idx;
      b += rect(x, 224, 60, 60, { fill: SC[s.phtBefore[e]], stroke: on ? C.ink : 'none', sw: 3, op: on ? 0.9 : 0.3, rx: 6 });
      b += text(x + 30, 248, e.toString(2).padStart(3, '0'), { size: 11, anchor: 'middle', mono: true, fill: on ? '#FFF' : C.ink });
      b += text(x + 30, 270, String(s.phtBefore[e]), { size: 14, weight: 700, anchor: 'middle', mono: true, fill: on ? '#FFF' : C.ink });
    }
    b += text(650, 322, `predicts: ${s.pg ? 'TAKEN' : 'NOT TAKEN'}`, { size: 16, weight: 700, fill: s.pg === s.t ? C.hit : C.miss });
    b += text(650, 348, s.pg === s.t ? 'right' : `wrong (still learning this history pattern)`, { size: 13, fill: s.pg === s.t ? C.hit : C.miss });
    b += text(650, 410, `right so far: ${s.gRight} of ${k + 1}`, { size: 15, weight: 700, mono: true });
    b += text(W - 40, 40, `branch ${k + 1} / ${steps.length}`, { size: 14, weight: 700, anchor: 'end', mono: true });
    frame(k, b);
  });
  add(text(40, 470, 'Sixfold runs both side by side and a chooser picks per branch (the tournament predictor); the arena on the site races five predictor designs.', { size: 12, fill: C.sub }));
  progress(24, H - 24, W - 48);
  return a.done();
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === path.resolve(new URL(import.meta.url).pathname);
if (isMain) {
  fs.mkdirSync('docs/img/animations', { recursive: true });
  const all = { pipeline: pipelineAnimation(), wallace: wallaceAnimation(), cache: cacheAnimation(), predictor: predictorAnimation() };
  for (const [n, svg] of Object.entries(all)) { fs.writeFileSync(`docs/img/animations/${n}.svg`, svg); console.log(`wrote docs/img/animations/${n}.svg (${(svg.length / 1024).toFixed(0)} KiB)`); }
}
