// =============================================================================
// tools/blockdiagram.mjs — draws docs/img/cpu_block_diagram.svg
//
// The full datapath of rtl/rv64_core.v: every latch, mux, unit and feedback
// path, colour-coded by what kind of signal it carries.
// =============================================================================
const FONT = "font-family=\"'IBM Plex Sans','Segoe UI',Helvetica,Arial,sans-serif\"";
const MONO = "font-family=\"'IBM Plex Mono',Consolas,monospace\"";
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

export const COL = {
  ink: '#17251D', sub: '#4A5A50', paper: '#FBFCF8', box: '#FFFFFF', edge: '#2B3A31',
  data: '#2B3A31', ctrl: '#6A4FC8', pred: '#138A8A', redirect: '#C2185B', fwdMem: '#E07B00',
  wb: '#C62828', hold: '#B8860B',
  IF: '#3C8DBC', ID: '#6A5ACD', RR: '#9B59B6', EX: '#E08E0B', MEM: '#27AE60', WB: '#C0392B',
};

export function blockDiagramSVG() {
  const W = 1640, H = 900;
  const out = [];
  const add = s => out.push(s);
  const markers = Object.entries({ data: COL.data, ctrl: COL.ctrl, pred: COL.pred, redirect: COL.redirect, fwdMem: COL.fwdMem, wb: COL.wb, hold: COL.hold })
    .map(([k, c]) => `<marker id="a-${k}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="${c}"/></marker>`).join('');
  const text = (x, y, s, { size = 12, weight = 400, fill = COL.ink, anchor = 'start', mono = false, italic = false } = {}) =>
    add(`<text x="${x}" y="${y}" ${mono ? MONO : FONT} font-size="${size}" font-weight="${weight}" fill="${fill}" text-anchor="${anchor}"${italic ? ' font-style="italic"' : ''}>${esc(s)}</text>`);
  const lines = (x, y, arr, o = {}) => arr.forEach((s, i) => text(x, y + i * ((o.size || 12) + 3), s, o));
  const box = (x, y, w, h, title, sub = [], { fill = COL.box, stroke = COL.edge, tsize = 13 } = {}) => {
    add(`<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="6" fill="${fill}" stroke="${stroke}" stroke-width="1.6"/>`);
    text(x + w / 2, y + 18, title, { size: tsize, weight: 600, anchor: 'middle' });
    sub.forEach((s, i) => text(x + w / 2, y + 34 + i * 14, s, { size: 10.5, fill: COL.sub, anchor: 'middle' }));
  };
  const wire = (pts, kind = 'data', { width = 2, dash = null, arrow = true } = {}) => {
    const d = pts.map((p, i) => `${i ? 'L' : 'M'}${p[0]},${p[1]}`).join(' ');
    add(`<path d="${d}" fill="none" stroke="${COL[kind]}" stroke-width="${width}"${dash ? ` stroke-dasharray="${dash}"` : ''} stroke-linejoin="round"${arrow ? ` marker-end="url(#a-${kind})"` : ''}/>`);
  };
  const dot = (x, y, kind = 'data') => add(`<circle cx="${x}" cy="${y}" r="3.2" fill="${COL[kind]}"/>`);
  const mux = (x, y, w, h, label, inputs = []) => {
    add(`<polygon points="${x},${y} ${x + w},${y + h * 0.18} ${x + w},${y + h * 0.82} ${x},${y + h}" fill="#F3F5F0" stroke="${COL.edge}" stroke-width="1.6"/>`);
    if (label) text(x + w / 2, y - 6, label, { size: 10, fill: COL.sub, anchor: 'middle' });
    inputs.forEach(([yy, s]) => text(x + 3, yy + 3.5, s, { size: 8.5, fill: COL.sub, mono: true }));
  };
  const lbl = (x, y, s, kind = 'data', anchor = 'start') => text(x, y, s, { size: 10, fill: COL[kind] === COL.data ? COL.sub : COL[kind], anchor, mono: true });

  add(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}">`);
  add(`<defs>${markers}</defs>`);
  add(`<rect width="100%" height="100%" rx="12" fill="${COL.paper}" stroke="#D5DBD0"/>`);
  text(20, 28, 'RV64IM 6-stage pipeline: datapath, gshare branch prediction, forwarding and hazard control', { size: 17, weight: 600 });

  // ---------------------------------------------------------------- stages
  const stages = [
    ['IF', 20, 300, 'instruction fetch + predict'], ['ID', 330, 520, 'decode'], ['RR', 550, 740, 'register read'],
    ['EX', 770, 1110, 'execute + resolve branches'], ['MEM', 1140, 1370, 'memory access'], ['WB', 1400, 1620, 'write back'],
  ];
  for (const [n, x0, x1, sub] of stages) {
    add(`<rect x="${x0}" y="44" width="${x1 - x0}" height="34" rx="6" fill="${COL[n]}"/>`);
    text(x0 + 10, 66, n, { size: 15, weight: 700, fill: '#FFF' });
    text(x0 + 52, 66, sub, { size: 11.5, fill: '#FFF' });
    add(`<rect x="${x0}" y="84" width="${x1 - x0}" height="560" rx="4" fill="${COL[n]}" fill-opacity="0.045"/>`);
  }
  const latches = [[305, 'IF/ID'], [525, 'ID/RR'], [745, 'RR/EX'], [1115, 'EX/MEM'], [1375, 'MEM/WB']];
  for (const [x, n] of latches) {
    add(`<rect x="${x}" y="100" width="16" height="540" rx="3" fill="#DDE3D8" stroke="${COL.edge}" stroke-width="1.4"/>`);
    add(`<text transform="translate(${x + 11.5},${632}) rotate(-90)" ${FONT} font-size="11" font-weight="700" fill="${COL.ink}">${n} pipeline register</text>`);
  }
  const L = { 1: [305, 321], 2: [525, 541], 3: [745, 761], 4: [1115, 1131], 5: [1375, 1391] };

  // ---------------------------------------------------------------- IF
  box(30, 100, 130, 88, 'Branch predictor', ['gshare: 256 x 2-bit PHT', 'index = PC[9:2] xor GHR', 'BTB: 32 entries'], { stroke: COL.pred });
  mux(40, 205, 22, 100, '', [[222, '+4'], [252, 'bp'], [285, 'fix']]);
  text(51, 322, 'next PC', { size: 10, fill: COL.sub, anchor: 'middle' });
  box(85, 226, 60, 50, 'PC', [], { tsize: 14 });
  add(`<circle cx="200" cy="212" r="15" fill="#F3F5F0" stroke="${COL.edge}" stroke-width="1.6"/>`); text(200, 216, '+4', { size: 11, weight: 700, anchor: 'middle' });
  box(165, 300, 125, 110, 'Instruction', ['memory', '64 KiB, 32-bit read', 'mem[PC]']);
  wire([[62, 255], [85, 255]]);                                         // mux -> PC
  wire([[145, 250], [L[1][0], 250]]);                                   // PC -> latch
  dot(160, 250); wire([[160, 250], [160, 212], [185, 212]]);            // PC -> +4
  wire([[215, 212], [228, 212], [228, 196], [26, 196], [26, 222], [40, 222]]);   // +4 -> mux
  dot(175, 250); wire([[175, 250], [175, 300]]);                        // PC -> imem
  dot(115, 250); wire([[115, 226], [115, 188]], 'pred');               // PC -> predictor (drawn from PC up)
  wire([[160, 150], [236, 150], [236, 180], [L[1][0], 180]], 'pred');  // prediction -> latch
  lbl(238, 174, 'pred', 'pred');
  wire([[95, 188], [95, 200], [34, 200], [34, 252], [40, 252]], 'pred'); // predicted target -> mux
  wire([[290, 350], [L[1][0], 350]]);                                   // instr -> latch
  lbl(292, 366, 'instr', 'data', 'end');
  lbl(250, 244, 'pc');

  // ---------------------------------------------------------------- ID
  wire([[L[1][1], 350], [345, 350]], 'data', { arrow: false });
  add(`<line x1="345" y1="118" x2="345" y2="528" stroke="${COL.data}" stroke-width="3"/>`);
  box(365, 104, 140, 64, 'Decoder', ['opcode, funct3, funct7', '-> control signals'], { stroke: COL.ctrl });
  wire([[345, 136], [365, 136]]);
  wire([[505, 130], [L[2][0], 130]], 'ctrl', { width: 3 }); lbl(509, 148, 'ctrl', 'ctrl');
  wire([[345, 300], [L[2][0], 300]]); lbl(352, 294, 'rs1 = instr[19:15]');
  wire([[345, 380], [L[2][0], 380]]); lbl(352, 374, 'rs2 = instr[24:20]');
  box(380, 426, 110, 50, 'Imm gen', ['I S B U J / shamt']);
  wire([[345, 451], [380, 451]]); wire([[490, 451], [L[2][0], 451]]); lbl(494, 445, 'imm');
  wire([[345, 520], [L[2][0], 520]]); lbl(352, 514, 'rd = instr[11:7]');
  wire([[L[1][1], 250], [L[2][0], 250]]); lbl(352, 244, 'pc');
  wire([[L[1][1], 180], [L[2][0], 180]], 'pred'); lbl(352, 174, 'pred taken / target / index', 'pred');

  // ---------------------------------------------------------------- RR
  box(582, 272, 130, 150, 'Register file', ['32 x 64-bit', '2 read, 1 write', 'x0 = 0', 'write-first bypass']);
  wire([[L[2][1], 300], [582, 300]]); wire([[L[2][1], 380], [582, 380]]);
  wire([[712, 300], [L[3][0], 300]]); lbl(716, 294, 'rs1 val');
  wire([[712, 380], [L[3][0], 380]]); lbl(716, 374, 'rs2 val');
  for (const [y, k] of [[130, 'ctrl'], [180, 'pred'], [250, 'data'], [451, 'data'], [520, 'data']]) wire([[L[2][1], y], [L[3][0], y]], k, { width: k === 'ctrl' ? 3 : 2 });

  // ---------------------------------------------------------------- EX
  mux(785, 282, 20, 72, 'fwd A', [[300, 'r'], [322, 'm'], [340, 'w']]);
  mux(785, 364, 20, 72, 'fwd B', [[380, 'r'], [402, 'm'], [420, 'w']]);
  wire([[L[3][1], 300], [785, 300]]); wire([[L[3][1], 380], [785, 380]]);
  mux(835, 236, 20, 128, 'A sel', [[252, 'pc'], [276, '0'], [336, 'a']]);
  mux(835, 376, 20, 100, 'B sel', [[396, 'b'], [456, 'i']]);
  wire([[805, 318], [818, 318], [818, 336], [835, 336]]);
  wire([[805, 400], [818, 400], [818, 396], [835, 396]]);
  wire([[L[3][1], 250], [835, 250]]);
  wire([[L[3][1], 451], [822, 451], [822, 456], [835, 456]]);
  add(`<text x="826" y="279" ${MONO} font-size="10" fill="${COL.sub}" text-anchor="end">0</text>`); wire([[828, 276], [835, 276]], 'data', { width: 1.5 });
  // ALU shape
  add(`<polygon points="900,262 975,300 975,420 900,458 900,380 916,360 900,340" fill="#FFF7E8" stroke="${COL.EX}" stroke-width="2"/>`);
  text(944, 356, 'ALU', { size: 15, weight: 700, anchor: 'middle' });
  text(944, 372, '+ - << >> & | ^', { size: 9, fill: COL.sub, anchor: 'middle', mono: true });
  text(944, 385, 'slt  mul  div', { size: 9, fill: COL.sub, anchor: 'middle', mono: true });
  wire([[855, 300], [900, 300]]); wire([[855, 426], [900, 426]]);
  wire([[940, 130], [940, 278]], 'ctrl', { width: 1.6, dash: '5 3' }); lbl(944, 200, 'alu_op', 'ctrl');
  // branch unit
  box(990, 150, 115, 100, 'Branch unit', ['taken? (beq ... bgeu)', 'target = pc+imm', 'or (rs1+imm)&~1', 'vs. prediction'], { stroke: COL.redirect });
  dot(812, 318); wire([[812, 318], [812, 228], [990, 228]], 'data', { width: 1.5 });
  dot(812, 400); wire([[812, 400], [812, 410], [826, 410], [826, 238], [990, 238]], 'data', { width: 1.5 });
  wire([[L[3][1], 180], [990, 180]], 'pred');
  dot(870, 250); wire([[870, 250], [870, 210], [990, 210]], 'data', { width: 1.5 });
  // wb-select: ALU vs PC+4
  box(990, 386, 56, 26, 'PC+4', [], { tsize: 11 });
  dot(980, 250); wire([[980, 250], [980, 399], [990, 399]], 'data', { width: 1.5 });
  mux(1066, 330, 18, 90, 'link?', [[350, 'y'], [399, 'p']]);
  wire([[975, 350], [1066, 350]]); wire([[1046, 399], [1066, 399]]);
  wire([[1084, 375], [L[4][0], 375]]); lbl(1052, 324, '');
  dot(1030, 350); wire([[1030, 350], [1030, 310], [L[4][0], 310]]); lbl(1036, 304, 'addr');
  lbl(1088, 369, 'value');
  dot(826, 470); wire([[826, 410], [826, 490], [L[4][0], 490]], 'data', { width: 2 }); lbl(1040, 484, 'store data');
  for (const [y, k] of [[130, 'ctrl'], [520, 'data']]) wire([[L[3][1], y], [L[4][0], y]], k, { width: k === 'ctrl' ? 3 : 2 });
  // redirect + predictor update (top)
  wire([[1047, 150], [1047, 90], [22, 90], [22, 285], [40, 285]], 'redirect', { width: 2.4 });
  text(560, 86, 'mispredict: PC <- correct target (fix_pc), flush IF, ID, RR (3 cycles lost)', { size: 11, fill: COL.redirect, weight: 600 });
  wire([[1070, 150], [1070, 97], [150, 97], [150, 100]], 'pred', { width: 1.6, dash: '6 3' });
  text(560, 108, 'update PHT counter, GHR, BTB when the branch resolves', { size: 10.5, fill: COL.pred });

  // ---------------------------------------------------------------- MEM
  box(1172, 386, 128, 120, 'Data memory', ['64 KiB, byte-addressed', 'little-endian', 'lb/lh/lw/ld, sb..sd']);
  wire([[L[4][1], 310], [1156, 310], [1156, 410], [1172, 410]]); lbl(1160, 404, 'addr');
  wire([[L[4][1], 490], [1172, 490]]); lbl(1140, 484, 'wdata');
  box(1172, 530, 128, 40, '0x1000_0000', ['store here = putchar'], { tsize: 11 });
  add(`<line x1="1236" y1="506" x2="1236" y2="530" stroke="${COL.edge}" stroke-dasharray="3 3"/>`);
  box(1306, 420, 32, 40, '', [], {}); text(1322, 436, 'ext', { size: 9.5, anchor: 'middle', weight: 600 }); text(1322, 449, 's/z', { size: 9, anchor: 'middle', fill: COL.sub });
  wire([[1300, 440], [1306, 440]]);
  mux(1346, 340, 18, 120, 'load?', [[375, 'v'], [440, 'l']]);
  wire([[L[4][1], 375], [1346, 375]]); wire([[1338, 440], [1346, 440]]);
  wire([[1364, 400], [L[5][0], 400]]);
  for (const [y, k] of [[130, 'ctrl'], [520, 'data']]) wire([[L[4][1], y], [L[5][0], y]], k, { width: k === 'ctrl' ? 3 : 2 });

  // ---------------------------------------------------------------- WB
  box(1430, 360, 175, 80, 'Write back', ['regfile[rd] <- value', '(if reg_write and rd != x0)', 'ecall/ebreak here: HALT']);
  wire([[L[5][1], 400], [1430, 400]]);
  wire([[L[5][1], 130], [1470, 130], [1470, 360]], 'ctrl', { width: 1.6, dash: '5 3' }); lbl(1476, 200, 'reg_write', 'ctrl');
  // write-back value & rd back to the register file
  dot(1408, 400, 'wb'); wire([[1408, 400], [1408, 608], [640, 608], [640, 422]], 'wb', { width: 2.6 });
  dot(1400, 520, 'wb'); wire([[L[5][1], 520], [1400, 520], [1400, 622], [690, 622], [690, 422]], 'wb', { width: 1.8 });
  text(830, 603, 'write-back value = MEM/WB forwarding (2 ahead)', { size: 10.5, fill: COL.wb, weight: 600 });
  text(830, 636, 'rd (write address)', { size: 10.5, fill: COL.wb });

  // ---------------------------------------------------------------- forwarding
  dot(1136, 375, 'fwdMem'); wire([[1136, 375], [1136, 580], [772, 580], [772, 402], [785, 402]], 'fwdMem', { width: 2.2 });
  dot(772, 580, 'fwdMem'); wire([[772, 402], [772, 322], [785, 322]], 'fwdMem', { width: 2.2 });
  text(830, 575, 'EX/MEM forwarding (value of the instruction 1 ahead)', { size: 10.5, fill: COL.fwdMem, weight: 600 });
  dot(778, 608, 'wb'); wire([[778, 608], [778, 420], [785, 420]], 'wb', { width: 2 });
  dot(778, 420, 'wb'); wire([[778, 420], [778, 340], [785, 340]], 'wb', { width: 2 });

  // ---------------------------------------------------------------- control units
  box(560, 690, 200, 86, 'Hazard unit', ['load-use: RR needs rd of a load in EX', '-> stall IF/ID/RR, bubble into EX', 'mispredict or halt in EX -> flush'], { stroke: COL.hold });
  box(790, 690, 210, 86, 'Forward unit', ['rs1/rs2 of EX == rd in MEM?  -> m', 'else == rd in WB?  -> w', 'else register file value  -> r'], { stroke: COL.fwdMem });
  wire([[560, 740], [115, 740], [115, 276]], 'hold', { width: 1.8, dash: '6 4' });
  wire([[313, 740], [313, 640]], 'hold', { width: 1.8, dash: '6 4' });
  wire([[533, 740], [533, 640]], 'hold', { width: 1.8, dash: '6 4' });
  wire([[700, 690], [700, 660], [753, 660], [753, 640]], 'hold', { width: 1.8, dash: '6 4' });
  text(130, 758, 'stall: hold PC, IF/ID, ID/RR  |  flush: clear IF/ID, ID/RR, RR/EX  |  bubble: clear RR/EX', { size: 10.5, fill: COL.hold, weight: 600 });
  wire([[860, 690], [860, 660], [795, 660], [795, 354]], 'fwdMem', { width: 1.5, dash: '4 3' });
  wire([[880, 690], [880, 650], [800, 650], [800, 434]], 'fwdMem', { width: 1.5, dash: '4 3' });
  lbl(864, 676, 'sel A / sel B', 'fwdMem');
  wire([[1123, 640], [1123, 733], [1000, 733]], 'fwdMem', { width: 1.5, dash: '4 3' }); lbl(1128, 700, 'rd (MEM)', 'fwdMem');
  wire([[1383, 640], [1383, 753], [1000, 753]], 'fwdMem', { width: 1.5, dash: '4 3' }); lbl(1330, 700, 'rd (WB)', 'fwdMem');
  wire([[1210, 90], [1210, 90]], 'redirect', { arrow: false });

  // ---------------------------------------------------------------- legend
  const lx = 1060, ly = 790;
  add(`<rect x="${lx - 10}" y="${ly - 22}" width="570" height="100" rx="8" fill="#FFF" stroke="#D5DBD0"/>`);
  const items = [['data', 'data path (64-bit values)'], ['ctrl', 'decoder control signals'], ['pred', 'branch prediction'], ['redirect', 'mispredict redirect'], ['fwdMem', 'EX/MEM forwarding'], ['wb', 'write-back / MEM/WB forwarding'], ['hold', 'stall / flush control']];
  items.forEach(([k, s], i) => {
    const x = lx + (i % 2) * 280, y = ly + Math.floor(i / 2) * 20;
    add(`<line x1="${x}" y1="${y - 4}" x2="${x + 36}" y2="${y - 4}" stroke="${COL[k]}" stroke-width="3"${k === 'hold' ? ' stroke-dasharray="6 4"' : ''}/>`);
    text(x + 44, y, s, { size: 11 });
  });
  text(20, 812, 'Each pipeline register captures its inputs on the rising clock edge.', { size: 11.5, fill: COL.sub });
  text(20, 830, 'Everything between two pipeline registers is combinational logic that must settle within one clock period.', { size: 11.5, fill: COL.sub });
  text(20, 848, 'Muxes: r = register-file value, m = from EX/MEM, w = from MEM/WB, a/b = forwarded operand, i = immediate, y = ALU, p = PC+4, v = value, l = loaded data.', { size: 11.5, fill: COL.sub });
  text(20, 874, 'Source of truth: rtl/rv64_core.v. Regenerate with: node tools/gendocs.mjs', { size: 11, fill: COL.sub, italic: true });
  add('</svg>');
  return out.join('\n') + '\n';
}
