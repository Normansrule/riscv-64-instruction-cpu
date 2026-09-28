#!/usr/bin/env node
// =============================================================================
// tools/diagrams.mjs: the detailed figures in the README and docs
//
//   docs/img/diagrams/branch_prediction.svg  the whole front end: BTB, BHT, gshare, chooser, RAS
//   docs/img/diagrams/cache.svg              one 2-way set-associative cache lookup, refill and prefetch
//   docs/img/diagrams/memory_hierarchy.svg   Sixfold's memory next to a typical desktop core
//   docs/img/diagrams/clock_roadmap.svg      measured clock periods against 2.5 GHz and 5 GHz
//
// Every number in these figures comes from the RTL parameters (src/*.sv) or from
// docs/PERFORMANCE.md; the figures are redrawn by `make diagrams`.
// =============================================================================
import fs from 'node:fs';
import path from 'node:path';

const FONT = "font-family=\"'IBM Plex Sans','Segoe UI',Helvetica,Arial,sans-serif\"";
const MONO = "font-family=\"'IBM Plex Mono',Consolas,monospace\"";
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

export const C = {
  ink: '#17251D', sub: '#4A5A50', faint: '#8A968E', paper: '#FBFCF8', edge: '#2B3A31', box: '#FFFFFF', line: '#D5DBD0',
  F1: '#2E86C1', F2: '#17A2B8', D: '#6A5ACD', E: '#E08E0B', M: '#27AE60', W: '#C0392B',
  tag: '#C9982E', idx: '#17A2B8', off: '#6A5ACD', pred: '#00796B', flush: '#C2185B', data: '#2B3A31', hit: '#1E8449', miss: '#C0392B',
  ctr: ['#C0392B', '#E59866', '#82C99A', '#1E8449'],
};

// A tiny SVG builder shared by all figures.
function canvas(W, H, title, subtitle) {
  const out = [];
  const add = s => out.push(s);
  const kinds = ['data', 'pred', 'flush', 'F1', 'F2', 'E', 'M', 'tag', 'idx', 'off', 'hit', 'miss', 'sub'];
  add(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}">`);
  add(`<defs>${kinds.map(k => `<marker id="m-${k}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="${C[k]}"/></marker>`).join('')}</defs>`);
  add(`<rect width="100%" height="100%" rx="12" fill="${C.paper}" stroke="${C.line}"/>`);
  const text = (x, y, s, { size = 12, weight = 400, fill = C.ink, anchor = 'start', mono = false, italic = false } = {}) =>
    add(`<text x="${x}" y="${y}" ${mono ? MONO : FONT} font-size="${size}" font-weight="${weight}" fill="${fill}" text-anchor="${anchor}"${italic ? ' font-style="italic"' : ''}>${esc(s)}</text>`);
  const rect = (x, y, w, h, { fill = C.box, stroke = C.edge, sw = 1.5, rx = 6, dash = null, op = 1 } = {}) =>
    add(`<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${rx}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}"${dash ? ` stroke-dasharray="${dash}"` : ''}${op < 1 ? ` fill-opacity="${op}"` : ''}/>`);
  const box = (x, y, w, h, title, lines = [], { fill = C.box, stroke = C.edge, tsize = 13, tfill = C.ink, lsize = 10.5, file = null } = {}) => {
    rect(x, y, w, h, { fill, stroke });
    text(x + w / 2, y + 19, title, { size: tsize, weight: 700, anchor: 'middle', fill: tfill });
    let yy = y + 19;
    if (file) { yy += 13; text(x + w / 2, yy, file, { size: 9, anchor: 'middle', mono: true, fill: C.faint }); }
    lines.forEach((s, i) => text(x + w / 2, yy + 15 + i * 13.5, s, { size: lsize, anchor: 'middle', fill: C.sub }));
  };
  const wire = (pts, kind = 'data', { width = 2, dash = null, arrow = true } = {}) => {
    const d = pts.map((p, i) => `${i ? 'L' : 'M'}${p[0]},${p[1]}`).join(' ');
    add(`<path d="${d}" fill="none" stroke="${C[kind]}" stroke-width="${width}"${dash ? ` stroke-dasharray="${dash}"` : ''} stroke-linejoin="round"${arrow ? ` marker-end="url(#m-${kind})"` : ''}/>`);
  };
  const dot = (x, y, kind = 'data') => add(`<circle cx="${x}" cy="${y}" r="3.2" fill="${C[kind]}"/>`);
  const mux = (x, y, w, h, label, inputs = [], { stroke = C.edge } = {}) => {
    add(`<polygon points="${x},${y} ${x + w},${y + h * 0.18} ${x + w},${y + h * 0.82} ${x},${y + h}" fill="#F3F5F0" stroke="${stroke}" stroke-width="1.6"/>`);
    if (label) text(x + w / 2, y - 7, label, { size: 10, fill: C.sub, anchor: 'middle', weight: 600 });
    inputs.forEach(([yy, s]) => text(x + 4, yy + 3.5, s, { size: 8.5, fill: C.sub, mono: true }));
  };
  const circle = (x, y, r, label, stroke = C.edge) => {
    add(`<circle cx="${x}" cy="${y}" r="${r}" fill="#FFF" stroke="${stroke}" stroke-width="1.8"/>`);
    text(x, y + 4.5, label, { size: 12, weight: 700, anchor: 'middle', fill: stroke });
  };
  const pill = (x, y, s, color, { size = 10, w = null } = {}) => {
    const ww = w ?? s.length * size * 0.6 + 14;
    add(`<rect x="${x}" y="${y}" width="${ww}" height="${size + 8}" rx="${(size + 8) / 2}" fill="${color}" fill-opacity="0.13" stroke="${color}"/>`);
    text(x + ww / 2, y + size + 2, s, { size, fill: color, anchor: 'middle', weight: 700 });
    return ww;
  };
  const counters = (x, y, w, rowH, states, { cols = 1 } = {}) => {
    const per = Math.ceil(states.length / cols), cw = w / cols;
    states.forEach((s, i) => {
      const c = Math.floor(i / per), r = i % per;
      add(`<rect x="${x + c * cw}" y="${y + r * rowH}" width="${cw - 1}" height="${rowH - 0.8}" fill="${C.ctr[s]}"/>`);
    });
  };
  text(24, 34, title, { size: 20, weight: 700 });
  if (subtitle) text(24, 56, subtitle, { size: 12.5, fill: C.sub });
  return { add, text, rect, box, wire, dot, mux, circle, pill, counters, done: () => { add('</svg>'); return out.join('\n'); } };
}

// Deterministic "random" counter states so the figures do not change between runs.
function states(n, seed) {
  let s = seed;
  return Array.from({ length: n }, () => { s = (s * 1103515245 + 12345) & 0x7fffffff; const v = s % 10; return v < 1 ? 0 : v < 3 ? 1 : v < 6 ? 2 : 3; });
}

// =============================================================================
// Branch prediction front end
// =============================================================================
export function branchPrediction() {
  const W = 1600, H = 1080;
  const g = canvas(W, H, 'The Sixfold front end: choosing the next PC every cycle, before any instruction is decoded',
    'Performance build (src/Riscv64.sv). FETCH1 guesses with the Branch Target Buffer and a tournament of two direction predictors; FETCH2 corrects cheap cases; EXECUTE checks and trains.');
  const { add, text, rect, box, wire, dot, mux, circle, pill, counters } = g;

  const bands = [['FETCH1', 20, 1010, C.F1, 'look up 4 tables in parallel with the instruction cache'], ['FETCH2', 1030, 1300, C.F2, 'predecode, RAS, redirect'], ['EXECUTE', 1320, 1580, C.E, 'resolve, train, repair']];
  for (const [n, x0, x1, col, s] of bands) {
    rect(x0, 72, x1 - x0, 32, { fill: col, stroke: col });
    text(x0 + 12, 93, n, { size: 14, weight: 700, fill: '#FFF' });
    text(x1 - 10, 93, s, { size: 11, fill: '#FFF', anchor: 'end' });
    rect(x0, 108, x1 - x0, 690, { fill: col, stroke: 'none', op: 0.05, rx: 4 });
  }

  // FETCH1_PC and its bus
  box(40, 420, 110, 84, 'FETCH1_PC', ['64-bit register', 'loads next PC', 'every cycle'], { tsize: 12.5 });
  const busX = 190;
  wire([[150, 462], [busX, 462]], 'data', { arrow: false }); dot(busX, 462);
  const bx = 240, by = 132, tx = 240, tyy = 380;
  wire([[busX, 121], [busX, tyy + 300]], 'data', { arrow: false });

  // ---- BTB
  rect(bx, by, 440, 236, { fill: '#EAF2FB', stroke: C.F1, sw: 1.8, rx: 8 });
  text(bx + 12, by + 22, 'Branch Target Buffer (BTB)', { size: 14, weight: 700, fill: C.F1 });
  text(bx + 12, by + 37, 'src/Branch_Target_Buffer.sv', { size: 9, mono: true, fill: C.faint });
  text(bx + 12, by + 53, '16 entries, direct mapped: "the instruction at this PC jumped to that PC"', { size: 10.5, fill: C.sub });
  const cols = [['V', 22], ['JAL', 34], ['tag = PC[31:6]', 132], ['target (32 bits)', 150]];
  const ty = by + 64;
  let cx = bx + 20;
  cols.forEach(([h, w]) => { text(cx + w / 2, ty + 10, h, { size: 9.5, fill: C.sub, anchor: 'middle', weight: 600 }); cx += w; });
  const rows = [[1, 0, '0x00000080', '0x00002040'], [1, 1, '0x00000080', '0x00002310'], [0, 0, '-', '-'], [1, 0, '0x00000081', '0x000020c8'], [1, 0, '0x00000080', '0x00002108'], [0, 0, '-', '-']];
  rows.forEach((r, i) => {
    let xx = bx + 20; const yy = ty + 16 + i * 17, hl = i === 3;
    cols.forEach(([, w], j) => {
      add(`<rect x="${xx}" y="${yy}" width="${w - 1}" height="16" fill="${hl ? '#FFF3C4' : '#FFF'}" stroke="${C.line}"/>`);
      text(xx + w / 2, yy + 12, String(r[j]), { size: 9.5, mono: true, anchor: 'middle', fill: r[0] ? C.ink : C.faint });
      xx += w;
    });
  });
  const rowY = ty + 16 + 3 * 17 + 8; // centre of the selected row
  text(bx + 283, ty + 16 + 6 * 17 + 14, '... 16 rows ...', { size: 9.5, fill: C.faint, anchor: 'middle', italic: true });
  wire([[busX, rowY], [bx + 18, rowY]], 'idx'); text(busX + 5, rowY - 5, 'PC[5:2]', { size: 9, mono: true, fill: C.idx });
  const cmpY = by + 212;
  circle(bx + 142, cmpY, 15, '=?', C.F1);
  wire([[bx + 142, ty + 16 + 6 * 17], [bx + 142, cmpY - 15]], 'tag', { width: 1.6 });
  text(bx + 148, ty + 16 + 6 * 17 + 14, 'stored tag', { size: 9, fill: C.tag });
  wire([[busX, cmpY], [bx + 127, cmpY]], 'tag', { width: 1.6 }); text(busX + 5, cmpY - 5, 'PC[31:6]', { size: 9, mono: true, fill: C.tag });
  wire([[bx + 157, cmpY], [704, cmpY], [704, 494], [736, 494]], 'F1');
  text(bx + 166, cmpY - 6, 'BTB_HIT (valid and tag match)', { size: 9.5, mono: true, fill: C.F1, weight: 700 });
  wire([[bx + 358, rowY], [870, rowY], [870, 196], [900, 196]], 'F1');
  text(bx + 450, rowY - 6, 'BTB_PREDICTED_TARGET', { size: 9.5, mono: true, fill: C.F1, weight: 700 });
  wire([[bx + 76 - 17, ty + 16 + 6 * 17], [bx + 59, 306], [720, 306], [720, 520], [736, 520]], 'F1', { width: 1.4, dash: '4 3' });
  text(bx + 450, 301, 'HIT_IS_JAL', { size: 9.5, mono: true, fill: C.F1 });

  // ---- Tournament
  rect(tx, tyy, 450, 400, { fill: '#E6F4F1', stroke: C.pred, sw: 1.8, rx: 8 });
  text(tx + 12, tyy + 22, 'Tournament direction predictor', { size: 14, weight: 700, fill: C.pred });
  text(tx + 12, tyy + 37, 'src/Tournament_Chooser.sv, src/GShare_Branch_Predictor.sv', { size: 9, mono: true, fill: C.faint });
  text(tx + 12, tyy + 53, 'two predictors answer "taken?"; a third table picks which one to trust', { size: 10.5, fill: C.sub });
  // BHT
  text(tx + 20, tyy + 80, 'Branch History Table (BHT)', { size: 12, weight: 700 });
  text(tx + 20, tyy + 95, '128 x 2-bit counters, index PC[8:2]', { size: 10, fill: C.sub });
  text(tx + 20, tyy + 108, 'learns each branch on its own', { size: 10, fill: C.sub });
  counters(tx + 220, tyy + 66, 100, 3.4, states(128, 7), { cols: 8 });
  text(tx + 270, tyy + 132, '128 counters', { size: 9, fill: C.faint, anchor: 'middle' });
  wire([[busX, tyy + 76], [tx + 216, tyy + 76]], 'idx', { width: 1.6 }); text(busX + 5, tyy + 71, 'PC[8:2]', { size: 9, mono: true, fill: C.idx });
  const mx = tx + 400, my = tyy + 126;
  wire([[tx + 322, tyy + 93], [tx + 384, tyy + 93], [tx + 384, my + 20], [mx, my + 20]], 'pred', { width: 1.8 });
  text(tx + 328, tyy + 88, 'BHT says', { size: 9.5, fill: C.pred });
  // gshare
  wire([[busX, tyy + 160], [tx + 190, tyy + 160], [tx + 190, tyy + 203]], 'idx', { width: 1.6 }); text(busX + 5, tyy + 155, 'PC[7:2]', { size: 9, mono: true, fill: C.idx });
  text(tx + 20, tyy + 180, 'gshare', { size: 12, weight: 700 });
  text(tx + 20, tyy + 195, '64 x 2-bit, index PC[7:2] XOR history', { size: 10, fill: C.sub });
  rect(tx + 20, tyy + 204, 132, 26, { fill: '#FFF', stroke: C.pred });
  text(tx + 86, tyy + 222, 'GLOBAL_HISTORY', { size: 10.5, mono: true, anchor: 'middle', weight: 700, fill: C.pred });
  [1, 0, 1, 1, 0, 1].forEach((b, i) => { rect(tx + 20 + i * 22, tyy + 234, 21, 20, { fill: b ? '#1E8449' : '#C0392B', stroke: '#FFF', sw: 1, rx: 2 }); text(tx + 30.5 + i * 22, tyy + 248, b ? 'T' : 'N', { size: 10, fill: '#FFF', anchor: 'middle', weight: 700 }); });
  text(tx + 20, tyy + 270, 'the last 6 branch directions: FETCH2 shifts in', { size: 9.5, fill: C.sub });
  text(tx + 20, tyy + 282, 'each guess, EXECUTE repairs it after a flush', { size: 9.5, fill: C.sub });
  add(`<circle cx="${tx + 190}" cy="${tyy + 217}" r="14" fill="#FFF" stroke="${C.pred}" stroke-width="2"/><path d="M${tx + 180},${tyy + 207} L${tx + 200},${tyy + 227} M${tx + 200},${tyy + 207} L${tx + 180},${tyy + 227}" stroke="${C.pred}" stroke-width="2"/>`);
  wire([[tx + 152, tyy + 217], [tx + 174, tyy + 217]], 'pred', { width: 1.6 });
  counters(tx + 220, tyy + 190, 100, 3.4, states(64, 11), { cols: 4 });
  text(tx + 270, tyy + 256, '64 counters', { size: 9, fill: C.faint, anchor: 'middle' });
  wire([[tx + 204, tyy + 217], [tx + 216, tyy + 217]], 'pred', { width: 1.6 });
  wire([[tx + 322, tyy + 217], [tx + 384, tyy + 217], [tx + 384, my + 56], [mx, my + 56]], 'pred', { width: 1.8 });
  text(tx + 328, tyy + 212, 'gshare says', { size: 9.5, fill: C.pred });
  // chooser
  wire([[busX, tyy + 300], [tx + 335, tyy + 300], [tx + 335, tyy + 306]], 'idx', { width: 1.4 }); text(busX + 5, tyy + 295, 'PC[8:2]', { size: 9, mono: true, fill: C.idx });
  text(tx + 20, tyy + 322, 'Chooser: 128 x 2-bit', { size: 12, weight: 700 });
  text(tx + 20, tyy + 337, 'counter >= 2: trust gshare, else the BHT;', { size: 10, fill: C.sub });
  text(tx + 20, tyy + 351, 'moves toward whichever one was right', { size: 10, fill: C.sub });
  text(tx + 20, tyy + 365, 'when the two disagree', { size: 10, fill: C.sub });
  counters(tx + 300, tyy + 310, 70, 2.2, states(128, 3), { cols: 8 });
  text(tx + 335, tyy + 360, '128 counters', { size: 9, fill: C.faint, anchor: 'middle' });
  wire([[tx + 370, tyy + 327], [tx + 415, tyy + 327], [tx + 415, my + 76]], 'pred', { width: 1.6, dash: '4 3' });
  text(tx + 420, tyy + 290, 'select', { size: 9.5, fill: C.pred });
  mux(mx, my, 30, 80, '', [[my + 20, 'B'], [my + 56, 'G']], { stroke: C.pred });
  wire([[mx + 30, my + 40], [736, my + 40]], 'pred', { width: 2 });
  text(696, my + 34, 'TAKEN', { size: 9, mono: true, fill: C.pred, weight: 700 });

  // AND gate
  add(`<path d="M736,480 L760,480 A26,40 0 0 1 760,560 L736,560 Z" fill="#FFF" stroke="${C.F1}" stroke-width="1.8"/>`);
  text(758, 525, '&', { size: 15, weight: 700, anchor: 'middle', fill: C.F1 });
  text(792, 474, 'HIT && (JAL || TAKEN)', { size: 9, mono: true, fill: C.F1 });
  wire([[786, 520], [912, 520], [912, 412]], 'F1');
  text(792, 514, 'FETCH1_BTB_REDIRECT', { size: 9, mono: true, fill: C.F1, weight: 700 });

  // PC + 4 and the next-PC mux
  circle(830, 121, 14, '+4');
  wire([[busX, 121], [816, 121]], 'data', { width: 1.6 });
  wire([[844, 121], [880, 121], [880, 150], [900, 150]], 'data', { width: 1.6 });
  wire([[860, 300], [900, 300]], 'data', { width: 1.6 }); text(856, 304, 'FETCH1_PC', { size: 9, mono: true, fill: C.sub, anchor: 'end' });
  mux(900, 124, 40, 300, '', [[150, 'PC+4'], [196, 'BTB'], [300, 'hold'], [330, 'F2'], [398, 'EX']]);
  text(920, 440, 'next PC', { size: 10, fill: C.sub, anchor: 'middle', weight: 700 });
  text(790, 330, 'priority', { size: 9.5, fill: C.sub, weight: 700 });
  ['1 EXECUTE flush', '2 FETCH2 redirect', '3 I-cache miss: hold', '4 BTB redirect', '5 PC + 4'].forEach((s, i) => text(790, 344 + i * 12.5, s, { size: 9.5, fill: C.sub }));
  pill(790, 412, 'I-cache miss', C.miss, { size: 9.5 });
  wire([[876, 421], [928, 421], [928, 392]], 'miss', { width: 1.4, dash: '4 3' });
  wire([[940, 274], [990, 274], [990, 113], [30, 113], [30, 462], [40, 462]], 'data', { width: 2.2 });

  // FETCH2
  box(1046, 128, 238, 92, 'Predecode', ['opcode: branch? JAL? JALR?', 'call: rd = ra or t0', 'return: jalr x0, 0(ra or t0)'], { tsize: 12.5 });
  box(1046, 236, 238, 60, 'Target adder', ['FETCH2_PC + B or J immediate'], { tsize: 12.5 });
  rect(1046, 312, 238, 214, { fill: '#EAF6F8', stroke: C.F2, sw: 1.8, rx: 8 });
  text(1058, 332, 'Return Address Stack (RAS)', { size: 12.5, weight: 700, fill: C.F2 });
  text(1058, 347, '8 x 64-bit, src/Return_Address_Stack.sv', { size: 9, fill: C.faint, mono: true });
  ['0x2014', '0x2330', '0x2468', '', '', '', '', ''].forEach((v, i) => { const yy = 480 - i * 16; rect(1070, yy, 110, 15, { fill: v ? '#FFF' : '#F4F6F2', stroke: C.line, rx: 1, sw: 1 }); text(1125, yy + 11.5, v || '-', { size: 9.5, mono: true, anchor: 'middle', fill: v ? C.ink : C.faint }); });
  wire([[1210, 456], [1184, 456]], 'F2', { width: 1.6 }); text(1214, 460, 'top', { size: 9.5, fill: C.F2 });
  text(1190, 386, 'call: push PC+4', { size: 9.5, fill: C.sub }); text(1190, 400, 'ret: pop', { size: 9.5, fill: C.sub });
  text(1058, 514, 'pointer checkpointed per call/ret', { size: 9.5, fill: C.sub });
  box(1046, 542, 238, 104, 'Redirect decision', ['JAL, or branch predicted taken,', 'or return (target = RAS top),', 'and FETCH1 did not already jump:', 'squash FETCH1, 1 bubble'], { tsize: 12.5, stroke: C.F2 });
  wire([[1165, 220], [1165, 236]], 'data', { width: 1.5 }); wire([[1165, 296], [1165, 312]], 'data', { width: 1.5 }); wire([[1165, 526], [1165, 542]], 'data', { width: 1.5 });
  wire([[1165, 646], [1165, 668], [1010, 668], [1010, 330], [940, 330]], 'F2', { width: 2.2 });
  text(1020, 684, 'FETCH2_PREDICTED_NEXT_PC', { size: 9.5, mono: true, fill: C.F2, weight: 700 });

  // EXECUTE
  box(1336, 128, 228, 80, 'BranchComparator', ['== != < >= (signed, unsigned)', 'on forwarded rs1, rs2'], { tsize: 12.5 });
  box(1336, 224, 228, 116, 'BranchControl', ['actual direction and target', 'vs the prediction that', 'travelled down the pipe', 'wrong: FLUSH (3 bubbles)'], { tsize: 12.5, stroke: C.flush, fill: '#FCE4EC' });
  wire([[1450, 208], [1450, 224]], 'data', { width: 1.5 });
  box(1336, 356, 228, 176, 'Train (every branch)', ['BHT counter at the PC', 'gshare counter at the index', 'saved when it was predicted', 'chooser: toward the one', 'that was right', 'BTB: insert taken branch / JAL'], { tsize: 12.5, stroke: C.pred, fill: '#E6F4F1' });
  box(1336, 548, 228, 120, 'Repair (only after a flush)', ['GLOBAL_HISTORY <= checkpoint', '+ the real direction', 'RAS pointer <= checkpoint', 'refetch from the right PC'], { tsize: 12.5, stroke: C.flush });
  wire([[1450, 340], [1450, 356]], 'pred', { width: 1.5 }); wire([[1450, 532], [1450, 548]], 'flush', { width: 1.5 });
  wire([[1450, 668], [1450, 740], [960, 740], [960, 398], [940, 398]], 'flush', { width: 2.4 });
  text(1200, 756, 'EXECUTE_REDIRECT_PC + FLUSH_FETCH1_FETCH2_DECODE', { size: 9.5, mono: true, fill: C.flush, weight: 700, anchor: 'middle' });
  wire([[1336, 470], [1316, 470], [1316, 790], [tx + 235, 790], [tx + 235, tyy + 402]], 'pred', { width: 1.4, dash: '5 4' });
  text(740, 812, 'training writes: one per resolved branch, at the table indexes saved when it was predicted', { size: 10, fill: C.pred });

  // bottom panels
  const py = 836;
  rect(20, py, 560, 226, { fill: '#FFF', stroke: C.line, rx: 8 });
  text(36, py + 24, 'Every table entry is a 2-bit saturating counter', { size: 13, weight: 700 });
  const sn = ['00 strong\nnot taken', '01 weak\nnot taken', '10 weak\ntaken', '11 strong\ntaken'];
  [60, 180, 300, 420].forEach((x, i) => {
    add(`<circle cx="${x + 40}" cy="${py + 92}" r="36" fill="${C.ctr[i]}" fill-opacity="0.18" stroke="${C.ctr[i]}" stroke-width="2"/>`);
    sn[i].split('\n').forEach((s, j) => text(x + 40, py + 88 + j * 14, s, { size: j ? 10 : 11, weight: j ? 400 : 700, anchor: 'middle' }));
    if (i < 3) {
      add(`<path d="M${x + 72},${py + 76} Q${x + 100},${py + 58} ${x + 128},${py + 76}" fill="none" stroke="${C.hit}" stroke-width="1.8" marker-end="url(#m-hit)"/>`);
      text(x + 100, py + 60, 'taken', { size: 9.5, fill: C.hit, anchor: 'middle' });
      add(`<path d="M${x + 128},${py + 108} Q${x + 100},${py + 126} ${x + 72},${py + 108}" fill="none" stroke="${C.miss}" stroke-width="1.8" marker-end="url(#m-miss)"/>`);
      text(x + 100, py + 136, 'not taken', { size: 9.5, fill: C.miss, anchor: 'middle' });
    }
  });
  text(36, py + 166, 'Predict taken when the counter is 2 or 3. One odd outcome only moves it one step, so a loop', { size: 10.5, fill: C.sub });
  text(36, py + 181, 'branch that falls through once at the end is not unlearned. Reset value: 10 (weakly taken).', { size: 10.5, fill: C.sub });
  text(36, py + 206, 'Cost: 128 + 64 + 128 counters = 640 bits of direction state, plus a 16-entry BTB.', { size: 10.5, fill: C.sub, weight: 600 });

  rect(600, py, 470, 226, { fill: '#FFF', stroke: C.line, rx: 8 });
  text(616, py + 24, 'What each case costs (bubbles = lost cycles)', { size: 13, weight: 700 });
  [['not a branch, or not taken and predicted so', '0', C.hit], ['taken branch / JAL already in the BTB', '0', C.hit], ['taken branch / JAL not in the BTB yet (FETCH2)', '1', C.F2],
    ['return predicted by the RAS (FETCH2)', '1', C.F2], ['direction or target wrong (EXECUTE flush)', '3', C.flush], ['instruction cache miss (refill)', '+11', C.miss]].forEach(([s, n, col], i) => {
    const yy = py + 52 + i * 27;
    text(616, yy + 4, s, { size: 11 });
    pill(1010, yy - 10, n, col, { size: 11, w: 44 });
  });

  rect(1090, py, 490, 226, { fill: '#FFF', stroke: C.line, rx: 8 });
  text(1106, py + 24, 'Accuracy on 17_predictor_challenge (make arena)', { size: 13, weight: 700 });
  [['BHT alone', 68.2, C.ctr[1]], ['gshare alone', 81.9, C.F2], ['tournament (in RTL)', 83.4, C.pred], ['perceptron (model)', 90.3, C.D], ['TAGE (model)', 96.2, C.M]].forEach(([n, v, col], i) => {
    const yy = py + 44 + i * 32;
    text(1106, yy + 14, n, { size: 11 });
    rect(1250, yy, 260, 20, { fill: '#F1F3EE', stroke: 'none', rx: 3 });
    rect(1250, yy, 260 * (v - 50) / 50, 20, { fill: col, stroke: 'none', rx: 3 });
    text(1518, yy + 15, v.toFixed(1) + '%', { size: 11, weight: 700, fill: col });
  });
  text(1106, py + 212, 'axis starts at 50% (a coin flip). TAGE is the basis of current Intel, AMD and Arm predictors.', { size: 9.5, fill: C.faint });
  return g.done();
}

// =============================================================================
// Cache lookup
// =============================================================================
export function cache() {
  const W = 1600, H = 1010;
  const g = canvas(W, H, 'Inside a Sixfold cache: 4 KiB, 2-way set-associative, 32-byte lines, least-recently-used replacement',
    'src/Instruction_Cache.sv and src/Data_Cache.sv have the same shape: 64 sets x 2 ways x 32 bytes. Example: a load from address 0x0000_2072.');
  const { add, text, rect, box, wire, dot, mux, circle, pill } = g;

  // Address bar
  const ax = 330, ay = 86, bw = 24;
  text(ax - 20, ay + 30, 'address', { size: 13, weight: 700, anchor: 'end' });
  text(ax - 20, ay + 46, '0x0000_2072', { size: 11, mono: true, anchor: 'end', fill: C.sub });
  const bits = (0x2072).toString(2).padStart(32, '0').split('').map(Number);
  const fields = [[31, 11, C.tag, 'tag  [31:11]  21 bits', 'which of the lines that share this set?', '= 4'], [10, 5, C.idx, 'set  [10:5]  6 bits', 'which of the 64 sets', '= 3'], [4, 0, C.off, 'offset  [4:0]  5 bits', 'which byte in the 32-byte line', '= 18 (doubleword 2)']];
  for (let b = 31; b >= 0; b--) {
    const x = ax + (31 - b) * bw;
    const f = fields.find(([hi, lo]) => b <= hi && b >= lo);
    rect(x, ay + 14, bw - 2, 30, { fill: f[2], stroke: '#FFF', sw: 1, rx: 3, op: 0.2 + 0.7 * bits[31 - b] });
    text(x + bw / 2 - 1, ay + 35, String(bits[31 - b]), { size: 13, mono: true, anchor: 'middle', weight: 700, fill: bits[31 - b] ? '#FFF' : f[2] });
    if (b % 4 === 3 || b === 0) text(x + bw / 2 - 1, ay + 10, String(b), { size: 8.5, mono: true, anchor: 'middle', fill: C.faint });
  }
  fields.forEach(([hi, lo, col, name, what, val]) => {
    const x0 = ax + (31 - hi) * bw, x1 = ax + (31 - lo) * bw + bw - 2;
    add(`<path d="M${x0},${ay + 50} L${x0},${ay + 56} L${x1},${ay + 56} L${x1},${ay + 50}" fill="none" stroke="${col}" stroke-width="2"/>`);
    text((x0 + x1) / 2, ay + 72, `${name.split(' ')[0]} ${val.replace(' (doubleword 2)', '')}`, { size: 12, anchor: 'middle', fill: col, weight: 700 });
  });
  fields.forEach(([hi, lo, col, name, what, val], i) => {
    text(ax + 32 * bw + 20, ay + 8 + i * 30, `${name.replace(/  /g, ' ')}`, { size: 11.5, fill: col, weight: 700 });
    text(ax + 32 * bw + 20, ay + 22 + i * 30, what, { size: 10, fill: C.sub });
  });
  text(ax - 20, ay + 62, 'bits 63..32 must be 0', { size: 10, fill: C.faint, anchor: 'end' });

  // Two ways
  const wy = 230, rowH = 21;
  const setRows = [0, 1, 2, 3, 4, 5, -1, 63];
  const ways = [
    { x: 180, name: 'way 0', tags: [2, 0, 1, 4, 1, 0, 0, 3], valid: [1, 1, 1, 1, 1, 0, 0, 1] },
    { x: 760, name: 'way 1', tags: [0, 5, 0, 1, 3, 0, 0, 0], valid: [0, 1, 0, 1, 1, 0, 0, 0] },
  ];
  const wcol = [['V', 26], ['tag (21 bits)', 110], ['data: 4 doublewords = 32 bytes', 380]];
  for (const [wi, w] of ways.entries()) {
    rect(w.x - 10, wy - 34, 540, 262, { fill: '#FFF', stroke: C.line, rx: 8 });
    text(w.x, wy - 14, w.name, { size: 13, weight: 700 });
    text(w.x + 520, wy - 14, `WAY${wi}_VALID, WAY${wi}_TAG, WAY${wi}_DATA`, { size: 9.5, mono: true, fill: C.faint, anchor: 'end' });
    let xx = w.x;
    wcol.forEach(([h, ww]) => { text(xx + ww / 2, wy, h, { size: 9.5, fill: C.sub, anchor: 'middle', weight: 600 }); xx += ww; });
    setRows.forEach((s, r) => {
      const yy = wy + 8 + r * rowH;
      if (s < 0) { text(w.x + 258, yy + 14, '... sets 6 to 62 ...', { size: 9.5, fill: C.faint, anchor: 'middle', italic: true }); return; }
      const hl = s === 3;
      let x = w.x;
      const v = w.valid[r];
      add(`<rect x="${x}" y="${yy}" width="25" height="${rowH - 2}" fill="${hl ? '#FFF3C4' : '#FFF'}" stroke="${hl ? C.idx : C.line}" stroke-width="${hl ? 1.8 : 1}"/>`);
      text(x + 13, yy + 14, String(v), { size: 10, mono: true, anchor: 'middle', fill: v ? C.ink : C.faint }); x += 26;
      add(`<rect x="${x}" y="${yy}" width="109" height="${rowH - 2}" fill="${hl ? '#FFF3C4' : '#FFF'}" stroke="${hl ? C.idx : C.line}" stroke-width="${hl ? 1.8 : 1}"/>`);
      text(x + 55, yy + 14, v ? String(w.tags[r]) : '-', { size: 10, mono: true, anchor: 'middle', fill: v ? C.tag : C.faint }); x += 110;
      for (let d = 0; d < 4; d++) {
        const pick = hl && wi === 0 && d === 2;
        add(`<rect x="${x + d * 95}" y="${yy}" width="94" height="${rowH - 2}" fill="${pick ? '#E6E1FF' : hl ? '#FFF3C4' : v ? '#F7F8F4' : '#FFF'}" stroke="${pick ? C.off : hl ? C.idx : C.line}" stroke-width="${pick || hl ? 1.8 : 1}"/>`);
        text(x + d * 95 + 47, yy + 14, v ? (pick ? 'bytes 16..23' : `dw ${d}`) : '', { size: 9, mono: true, anchor: 'middle', fill: pick ? C.off : C.faint });
      }
      text(w.x - 16, yy + 14, String(s), { size: 9.5, mono: true, anchor: 'end', fill: hl ? C.idx : C.faint, weight: hl ? 700 : 400 });
    });
  }
  text(160, wy + 8 + 3 * rowH + 14 - 88, 'set', { size: 9.5, fill: C.faint, anchor: 'end' });
  // LRU column
  const lx = 1330;
  rect(lx - 10, wy - 34, 90, 262, { fill: '#FFF', stroke: C.line, rx: 8 });
  text(lx + 35, wy - 14, 'LRU', { size: 13, weight: 700, anchor: 'middle' });
  text(lx + 35, wy, '1 bit / set', { size: 9.5, fill: C.sub, anchor: 'middle' });
  const lru = [1, 0, 1, 1, 0, 0, 0, 1];
  setRows.forEach((s, r) => {
    const yy = wy + 8 + r * rowH;
    if (s < 0) return;
    add(`<rect x="${lx + 10}" y="${yy}" width="50" height="${rowH - 2}" fill="${s === 3 ? '#FFF3C4' : '#FFF'}" stroke="${s === 3 ? C.idx : C.line}"/>`);
    text(lx + 35, yy + 14, String(lru[r]), { size: 10, mono: true, anchor: 'middle' });
  });
  text(lx + 35, wy + 196, 'which way to', { size: 9, fill: C.sub, anchor: 'middle' });
  text(lx + 35, wy + 208, 'evict next', { size: 9, fill: C.sub, anchor: 'middle' });

  // set index arrow
  const sy = 182, sx0 = ax + 23 * bw;
  wire([[sx0, ay + 78], [sx0, sy]], 'idx', { arrow: false });
  wire([[sx0, sy], [150, sy], [150, wy + 8 + 3 * rowH + 9], [176, wy + 8 + 3 * rowH + 9]], 'idx');
  wire([[700, sy], [700, wy + 8 + 3 * rowH + 9], [756, wy + 8 + 3 * rowH + 9]], 'idx');
  wire([[sx0, sy], [1300, sy], [1300, wy + 8 + 3 * rowH + 9], [1336, wy + 8 + 3 * rowH + 9]], 'idx', { width: 1.5 });
  text(158, sy - 5, 'set 3 selects one row in every array, in the same cycle', { size: 10, fill: C.idx, weight: 600 });

  // comparators
  const cy = 540;
  circle(310, cy, 20, '=?', C.tag);
  circle(890, cy, 20, '=?', C.tag);
  wire([[ways[0].x + 26 + 55, wy + 8 + 8 * rowH + 2], [ways[0].x + 81, cy - 30], [296, cy - 30], [300, cy - 18]], 'tag', { width: 1.6 });
  wire([[ways[1].x + 26 + 55, wy + 8 + 8 * rowH + 2], [ways[1].x + 81, cy - 30], [876, cy - 30], [880, cy - 18]], 'tag', { width: 1.6 });
  wire([[225, cy], [290, cy]], 'tag', { width: 1.6 }); text(220, cy + 4, 'address tag 4', { size: 10, fill: C.tag, weight: 700, anchor: 'end' });
  wire([[805, cy], [870, cy]], 'tag', { width: 1.6 }); text(800, cy + 4, 'address tag 4', { size: 10, fill: C.tag, weight: 700, anchor: 'end' });
  text(310, cy - 42, 'stored tag 4', { size: 9.5, fill: C.tag }); text(890, cy - 42, 'stored tag 1', { size: 9.5, fill: C.tag });
  // AND with valid -> hit way
  box(250, 590, 120, 54, 'HIT_WAY0', ['V && tag 4 == 4'], { tsize: 11.5, stroke: C.hit, tfill: C.hit });
  box(830, 590, 120, 54, 'HIT_WAY1', ['V && tag 1 == 4'], { tsize: 11.5, stroke: C.miss, tfill: C.miss });
  wire([[310, cy + 20], [310, 590]], 'hit'); wire([[890, cy + 20], [890, 590]], 'miss');
  pill(380, 600, 'yes', C.hit); pill(960, 600, 'no', C.miss);
  // OR -> HIT
  box(520, 680, 150, 54, 'HIT = W0 or W1', ['0: stall and refill'], { tsize: 11.5, stroke: C.hit });
  wire([[310, 644], [310, 707], [520, 707]], 'hit'); wire([[890, 644], [890, 707], [670, 707]], 'miss');
  // data mux
  mux(1090, 520, 36, 110, 'way', [[544, 'W0'], [604, 'W1']]);
  wire([[ways[0].x + 136 + 2 * 95 + 47, wy + 8 + 8 * rowH + 2], [ways[0].x + 136 + 2 * 95 + 47, 470], [1060, 470], [1060, 544], [1090, 544]], 'off', { width: 1.8 });
  wire([[ways[1].x + 136 + 2 * 95 + 47, wy + 8 + 8 * rowH + 2], [ways[1].x + 136 + 2 * 95 + 47, 604], [1090, 604]], 'data', { width: 1.4, dash: '4 3' });
  wire([[950, 617], [1108, 617], [1108, 616]], 'hit', { width: 1.4 });
  wire([[1126, 575], [1180, 575]], 'off', { width: 2.2 });
  box(1180, 530, 190, 92, 'READ_DATA', ['doubleword 2 of the line', '(offset[4:3]); LoadControl', 'picks bytes with [2:0]'], { tsize: 12, stroke: C.off });
  text(1180, 648, 'I-cache: the 32-bit word at offset[4:2]', { size: 10, fill: C.sub });
  text(1180, 690, 'all of this happens in one cycle:', { size: 11, fill: C.hit, weight: 700 }); text(1180, 706, 'a hit costs 0 extra cycles', { size: 11, fill: C.hit, weight: 700 });

  // ---- miss handling panel
  const my = 770;
  rect(20, my, 760, 226, { fill: '#FFF', stroke: C.line, rx: 8 });
  text(36, my + 24, 'On a miss: refill (MISS_LATENCY = 10, so a miss costs 11 cycles)', { size: 13, weight: 700 });
  for (let c = 0; c < 12; c++) {
    const x = 40 + c * 58, col = c === 0 ? C.miss : c === 11 ? C.hit : '#D9DED6';
    rect(x, my + 42, 54, 30, { fill: col, stroke: '#FFF', rx: 4, op: c === 0 || c === 11 ? 0.9 : 1 });
    text(x + 27, my + 62, c === 0 ? 'miss' : c === 11 ? 'hit' : String(c), { size: 10.5, anchor: 'middle', weight: 700, fill: c === 0 || c === 11 ? '#FFF' : C.sub });
  }
  text(40, my + 92, 'cycle', { size: 9.5, fill: C.faint });
  text(335, my + 92, 'core stalls: FETCH1 holds its PC (I-cache) or the load waits in EXECUTE (D-cache)', { size: 10, fill: C.sub, anchor: 'middle' });
  text(620, my + 92, 'INSTALL when 1 cycle is left', { size: 10, fill: C.hit, anchor: 'middle' });
  const notes = [
    ['victim way', 'an empty way first, otherwise the one LRU points at (chosen before this cycle\'s LRU update)'],
    ['next-line prefetch', 'after a demand miss on line X, line X + 1 is fetched in the background if it is not present'],
    ['stores', 'D-cache is write-through, no-allocate: main memory always has the data, a cached copy is updated too'],
    ['MMIO', 'addresses 0x1000_0000 and up (putchar) bypass the cache entirely'],
  ];
  notes.forEach(([k, v], i) => { text(36, my + 124 + i * 24, k, { size: 11, weight: 700 }); text(170, my + 124 + i * 24, v, { size: 11, fill: C.sub }); });

  rect(800, my, 780, 226, { fill: '#FFF', stroke: C.line, rx: 8 });
  text(816, my + 24, 'Why two ways? (programs/16_cache_conflicts.s)', { size: 13, weight: 700 });
  const why = [
    'Two arrays exactly 2 KiB apart share every set index. In a direct-mapped cache they evict',
    'each other on every access ("thrashing"). With 2 ways both lines live in the same set.',
    '',
    'Size cost of this cache, per line: 1 valid + 21 tag + 256 data bits; plus 1 LRU bit per set:',
    '128 lines x 278 bits + 64 = 35,648 bits of storage for 32,768 bits of data (8.8% overhead).',
    '',
    'Real CPUs: 32 to 64 KiB L1 caches with 8 to 12 ways and 64-byte lines, a 4 or 5 cycle load-to-use',
    'latency (pipelined), and stride and stream prefetchers instead of just "next line".',
  ];
  why.forEach((s, i) => text(816, my + 50 + i * 20, s, { size: 11, fill: i >= 3 && i <= 4 ? C.ink : C.sub }));
  return g.done();
}

// =============================================================================
// Memory hierarchy
// =============================================================================
export function hierarchy() {
  const W = 1600, H = 560;
  const g = canvas(W, H, 'Memory hierarchy: Sixfold next to a typical desktop core',
    'Each level is bigger and slower than the one above it. Widths are drawn on a log scale of size; cycle counts at the right.');
  const { text, rect, pill, add } = g;
  const col = [C.D, C.F1, C.F2, C.M, C.E, C.W];
  const draw = (x0, title, levels, note) => {
    text(x0, 100, title, { size: 15, weight: 700 });
    const cx = x0 + 330;
    levels.forEach(([name, size, bytes, cyc, detail], i) => {
      const y = 124 + i * 78;
      const w = Math.max(280, 60 * Math.log2(bytes / 64));
      const c = col[i % col.length];
      rect(cx - Math.min(w, 620) / 2, y, Math.min(w, 620), 58, { fill: c, stroke: c, op: 0.16, rx: 8 });
      add(`<rect x="${cx - Math.min(w, 620) / 2}" y="${y}" width="${Math.min(w, 620)}" height="58" rx="8" fill="none" stroke="${c}" stroke-width="1.8"/>`);
      text(cx, y + 24, `${name}  ${size}`, { size: 13, weight: 700, anchor: 'middle', fill: C.ink });
      text(cx, y + 42, detail, { size: 10.5, anchor: 'middle', fill: C.sub });
      pill(x0 + 670, y + 18, cyc, c, { size: 11, w: 96 });
    });
    text(x0, 124 + levels.length * 78 + 20, note, { size: 11, fill: C.sub });
  };
  draw(30, 'Sixfold (this repository)', [
    ['registers', '31 x 64-bit', 248, '0 cycles', 'x1..x31, forwarding into DECODE'],
    ['L1 I-cache + L1 D-cache', '4 KiB each', 4096, '0 extra', '2-way, 32 B lines, LRU, next-line prefetch'],
    ['main memory', '64 KiB', 65536, '+11 cycles', 'Scratchpad_Memory behind a 10-cycle refill port'],
  ], 'Every miss is counted: the I and D terms of the CPI stack (docs/MATH.md).');
  add(`<line x1="800" y1="84" x2="800" y2="${H - 30}" stroke="${C.line}" stroke-width="1.5" stroke-dasharray="6 5"/>`);
  draw(830, 'A typical desktop core (order of magnitude)', [
    ['registers', '~200-300 physical', 2048, '0 cycles', 'renamed, out of order'],
    ['L1 I + D', '32-64 KiB each', 49152, '4-5 cycles', '8-12 ways, 64 B lines, pipelined'],
    ['L2', '1-3 MiB per core', 2 * 1048576, '12-18 cycles', 'private, inclusive or not'],
    ['L3', '16-96 MiB shared', 32 * 1048576, '40-70 cycles', 'shared by all cores, sliced'],
    ['DRAM', '16-64 GiB', 16 * 1073741824, '~250-400 cycles', 'about 80-100 ns at 4-5 GHz'],
  ], 'Latencies vary by generation; these are typical published figures for recent Intel and AMD cores.');
  return g.done();
}

// =============================================================================
// Clock roadmap
// =============================================================================
export function clockRoadmap(data) {
  const W = 1600, H = 110 + data.rows.length * 46 + 20 + 60 + data.steps.length * 26 + 30;
  const g = canvas(W, H, 'Clock frequency: where Sixfold is, and what it takes to reach 2.5 GHz and 5 GHz',
    'Longest register-to-register path, logic only (tools/timing.sh, typical corner). Shorter bar = faster clock. Log scale.');
  const { text, rect, add, pill } = g;
  const x0 = 470, x1 = 1440;
  const lo = Math.log10(100), hi = Math.log10(400000);
  const X = ps => x0 + (x1 - x0) * (Math.log10(ps) - lo) / (hi - lo);
  [100, 200, 400, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000].forEach(ps => {
    add(`<line x1="${X(ps)}" y1="92" x2="${X(ps)}" y2="${92 + data.rows.length * 46 + 8}" stroke="${C.line}" stroke-width="1"/>`);
    text(X(ps), 86, ps >= 1000 ? `${ps / 1000} ns` : `${ps} ps`, { size: 10, fill: C.faint, anchor: 'middle' });
  });
  data.rows.forEach(([label, ps, kind, note], i) => {
    const y = 100 + i * 46;
    const col = kind === 'target' ? C.flush : kind === 'best' ? C.M : kind === 'base' ? C.faint : C.F1;
    text(x0 - 14, y + 20, label, { size: 12, anchor: 'end', weight: kind === 'best' ? 700 : 400 });
    if (kind === 'target') {
      add(`<line x1="${X(ps)}" y1="${y}" x2="${X(ps)}" y2="${y + 30}" stroke="${col}" stroke-width="3"/>`);
      rect(x0, y + 4, X(ps) - x0, 22, { fill: col, stroke: col, op: 0.08, rx: 3, dash: '5 4' });
    } else rect(x0, y + 4, X(ps) - x0, 22, { fill: col, stroke: col, op: 0.85, rx: 3 });
    const f = 1e6 / ps;
    const fs = f >= 1000 ? `${(f / 1000).toFixed(2)} GHz` : `${f.toFixed(f < 10 ? 1 : 0)} MHz`;
    text(X(ps) + 8, y + 20, `${ps >= 1000 ? (ps / 1000).toFixed(ps >= 10000 ? 0 : 2) + ' ns' : ps + ' ps'}  =  ${fs}`, { size: 11.5, weight: 700, fill: col });
    if (note) text(x0 - 14, y + 35, note, { size: 9.5, anchor: 'end', fill: C.faint });
  });
  // steps panel
  const py = 110 + data.rows.length * 46 + 20;
  rect(20, py, W - 40, H - py - 20, { fill: '#FFF', stroke: C.line, rx: 8 });
  text(36, py + 26, 'Closing the gap: the clock is set by the slowest pipeline stage, so every step cuts the logic between two registers', { size: 13, weight: 700 });
  data.steps.forEach(([what, how, status], i) => {
    const y = py + 52 + i * 26;
    const col = status === 'done' ? C.M : status === 'measured' ? C.F1 : C.faint;
    pill(36, y - 13, status, col, { size: 10, w: 84 });
    text(134, y, what, { size: 11.5, weight: 700 });
    text(560, y, how, { size: 11, fill: C.sub });
  });
  return g.done();
}

export const CLOCK_DATA = JSON.parse(fs.readFileSync(new URL('../docs/clock_roadmap.json', import.meta.url), 'utf8'));

const isMain = process.argv[1] && path.resolve(process.argv[1]) === path.resolve(new URL(import.meta.url).pathname);
if (isMain) {
  fs.mkdirSync('docs/img/diagrams', { recursive: true });
  const figs = { branch_prediction: branchPrediction(), cache: cache(), memory_hierarchy: hierarchy(), clock_roadmap: clockRoadmap(CLOCK_DATA) };
  for (const [n, svg] of Object.entries(figs)) { fs.writeFileSync(`docs/img/diagrams/${n}.svg`, svg); console.log(`wrote docs/img/diagrams/${n}.svg`); }
}
