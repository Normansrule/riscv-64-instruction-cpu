#!/usr/bin/env node
// =============================================================================
// tools/gendocs.mjs — regenerate every generated doc and picture in the repo.
//
//   binary/README.md                 index of all instructions with bit patterns
//   binary/opcode_map.md             the RISC-V major-opcode map
//   binary/<RV64I|RV64M>/<name>.md   one page per instruction
//   binary/programs/*.lst, *.hex     every example program, assembled
//   docs/img/formats/*.svg           R/I/S/B/U/J bit-field diagrams
//   docs/img/instructions/*.svg      one bit-field picture per instruction
//   docs/img/pipeline/*.svg          pipeline charts of every experiment
//   docs/img/cpu_block_diagram.svg   the full datapath
//
//   node tools/gendocs.mjs
// =============================================================================
import fs from 'node:fs';
import path from 'node:path';
import { INSTRUCTIONS, FORMATS, OPCODES, encode, decode } from '../sim/isa.js';
import { assemble, toHex, toListing } from '../sim/asm.js';
import { Core, STAGES } from '../sim/core.js';
import { blockDiagramSVG } from './blockdiagram.mjs';

const W = (p, s) => { fs.mkdirSync(path.dirname(p), { recursive: true }); fs.writeFileSync(p, s); };
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const b = (v, n) => v.toString(2).padStart(n, '0');

// ---------------------------------------------------------------------------
// colours shared by every picture (see also web/style tokens)
// ---------------------------------------------------------------------------
export const FIELD_COLOR = {
  opcode: '#2F6FDB', rd: '#1F9D6B', rs1: '#D97A1E', rs2: '#C23B8F', funct3: '#7457D1',
  funct7: '#5B6472', funct6: '#5B6472', funct12: '#5B6472', imm: '#B8911B', shamt: '#B8911B',
  fm: '#5B6472', pred: '#5B6472', succ: '#5B6472',
};
const fieldKind = name => {
  const k = name.split('[')[0];
  return FIELD_COLOR[k] ? k : 'imm';
};
export const STAGE_COLOR = { IF: '#3C8DBC', ID: '#6A5ACD', RR: '#9B59B6', EX: '#E08E0B', MEM: '#27AE60', WB: '#C0392B' };
const FONT = "font-family=\"'IBM Plex Sans','Segoe UI',Helvetica,Arial,sans-serif\"";
const MONO = "font-family=\"'IBM Plex Mono','SFMono-Regular',Consolas,monospace\"";

// ---------------------------------------------------------------------------
// bit-field SVG
// ---------------------------------------------------------------------------
function bitfieldSVG(title, fields, subtitle = '') {
  const cw = 24, x0 = 20, y0 = subtitle ? 64 : 48, h = 40;
  const width = x0 * 2 + cw * 32, height = y0 + h + 58;
  let s = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}">`;
  s += `<rect width="100%" height="100%" rx="10" fill="#FBFCF8" stroke="#D5DBD0"/>`;
  s += `<text x="${x0}" y="26" ${FONT} font-size="17" font-weight="600" fill="#17251D">${esc(title)}</text>`;
  if (subtitle) s += `<text x="${x0}" y="46" ${FONT} font-size="12.5" fill="#4A5A50">${esc(subtitle)}</text>`;
  for (const f of fields) {
    const x = x0 + (31 - f.hi) * cw, w = (f.hi - f.lo + 1) * cw;
    const col = FIELD_COLOR[fieldKind(f.name)];
    s += `<rect x="${x}" y="${y0}" width="${w}" height="${h}" fill="${col}" fill-opacity="0.14" stroke="${col}" stroke-width="1.5"/>`;
    const bits = f.bits ?? '';
    for (let i = 0; i < bits.length; i++) {
      const fixed = bits[i] === '0' || bits[i] === '1';
      s += `<text x="${x + i * cw + cw / 2}" y="${y0 + 26}" text-anchor="middle" ${MONO} font-size="14" font-weight="${fixed ? 700 : 400}" fill="${fixed ? '#17251D' : col}">${esc(bits[i])}</text>`;
    }
    s += `<text x="${x + 3}" y="${y0 - 5}" ${MONO} font-size="10" fill="#6B7A70">${f.hi}</text>`;
    if (f.hi !== f.lo) s += `<text x="${x + w - 3}" y="${y0 - 5}" text-anchor="end" ${MONO} font-size="10" fill="#6B7A70">${f.lo}</text>`;
    s += `<text x="${x + w / 2}" y="${y0 + h + 18}" text-anchor="middle" ${FONT} font-size="12" font-weight="600" fill="${col}">${esc(f.name)}</text>`;
    s += `<text x="${x + w / 2}" y="${y0 + h + 34}" text-anchor="middle" ${FONT} font-size="10.5" fill="#6B7A70">${w / cw} bit${w / cw > 1 ? 's' : ''}</text>`;
  }
  return s + '</svg>\n';
}

function templateBits(def) {
  // bit string with fixed bits as 0/1 and variable bits as letters
  const out = new Array(32).fill('?');
  const put = (hi, lo, val) => { for (let i = hi; i >= lo; i--) out[31 - i] = val === null ? null : ((val >> (i - lo)) & 1).toString(); };
  const sym = (hi, lo, ch) => { for (let i = hi; i >= lo; i--) out[31 - i] = ch; };
  put(6, 0, def.opcode);
  if (def.funct3 !== null) put(14, 12, def.funct3); else if (def.fmt !== 'U' && def.fmt !== 'J') sym(14, 12, 'f');
  switch (def.fmt) {
    case 'R': put(31, 25, def.funct7); sym(24, 20, 't'); sym(19, 15, 's'); sym(11, 7, 'd'); break;
    case 'I': sym(31, 20, 'i'); sym(19, 15, 's'); sym(11, 7, 'd'); break;
    case 'I-sh64': put(31, 26, def.funct7); sym(25, 20, 'h'); sym(19, 15, 's'); sym(11, 7, 'd'); break;
    case 'I-sh32': put(31, 25, def.funct7); sym(24, 20, 'h'); sym(19, 15, 's'); sym(11, 7, 'd'); break;
    case 'S': sym(31, 25, 'i'); sym(24, 20, 't'); sym(19, 15, 's'); sym(11, 7, 'i'); break;
    case 'B': sym(31, 25, 'i'); sym(24, 20, 't'); sym(19, 15, 's'); sym(11, 7, 'i'); break;
    case 'U': case 'J': sym(31, 12, 'i'); sym(11, 7, 'd'); break;
    case 'SYS': put(31, 20, def.name === 'ebreak' ? 1 : 0); put(19, 15, 0); put(11, 7, 0); break;
    case 'FENCE': sym(31, 28, 'm'); sym(27, 24, 'p'); sym(23, 20, 'u'); put(19, 15, 0); put(11, 7, 0); break;
  }
  return out.join('');
}

function fieldsWithBits(fmt, bitstr) {
  return FORMATS[fmt].map(([name, hi, lo]) => ({ name, hi, lo, bits: bitstr.slice(31 - hi, 32 - lo) }));
}

// ---------------------------------------------------------------------------
// control signals the decoder produces (mirrors rtl/decoder.v)
// ---------------------------------------------------------------------------
const ALU_OF = {
  add: 'ADD', addi: 'ADD', addw: 'ADD', addiw: 'ADD', sub: 'SUB', subw: 'SUB', sll: 'SLL', slli: 'SLL', sllw: 'SLL', slliw: 'SLL',
  slt: 'SLT', slti: 'SLT', sltu: 'SLTU', sltiu: 'SLTU', xor: 'XOR', xori: 'XOR', srl: 'SRL', srli: 'SRL', srlw: 'SRL', srliw: 'SRL',
  sra: 'SRA', srai: 'SRA', sraw: 'SRA', sraiw: 'SRA', or: 'OR', ori: 'OR', and: 'AND', andi: 'AND',
  mul: 'MUL', mulw: 'MUL', mulh: 'MULH', mulhsu: 'MULHSU', mulhu: 'MULHU', div: 'DIV', divw: 'DIV', divu: 'DIVU', divuw: 'DIVU',
  rem: 'REM', remw: 'REM', remu: 'REMU', remuw: 'REMU',
};
export function control(def) {
  const n = def.name, s = def.syntax;
  const c = {
    use_rs1: ['rrr', 'rri', 'load', 'store', 'branch', 'jalr'].includes(s) ? 1 : 0,
    use_rs2: ['rrr', 'store', 'branch'].includes(s) ? 1 : 0,
    reg_write: ['rrr', 'rri', 'load', 'ui', 'jal', 'jalr'].includes(s) ? '1 (if rd≠x0)' : 0,
    alu_op: ALU_OF[n] || 'ADD',
    a_sel: n === 'lui' ? 'ZERO' : n === 'auipc' ? 'PC' : 'RS1',
    b_imm: ['rri', 'load', 'store', 'ui', 'jalr'].includes(s) ? 1 : 0,
    is_word: /w$/.test(n) && def.opcode !== OPCODES.LOAD && def.opcode !== OPCODES.STORE && n !== 'lw' ? 1 : 0,
    is_load: s === 'load' ? 1 : 0, is_store: s === 'store' ? 1 : 0,
    is_branch: s === 'branch' ? 1 : 0, is_jal: n === 'jal' ? 1 : 0, is_jalr: n === 'jalr' ? 1 : 0,
    wb_pc4: n === 'jal' || n === 'jalr' ? 1 : 0, is_halt: n === 'ecall' || n === 'ebreak' ? 1 : 0,
  };
  if (['rrr'].includes(s) === false && ['branch', 'jal', 'none'].includes(s)) c.alu_op = '— (unused)';
  if (n === 'lwu') c.is_word = 0;
  return c;
}

function stageStory(def) {
  const n = def.name, s = def.syntax, c = control(def);
  const st = {};
  st.IF = 'Fetch the 32-bit word at `PC` from instruction memory; predict not-taken: `PC ← PC + 4`.';
  st.ID = `Decoder recognises \`${n}\` from opcode \`${b(def.opcode, 7)}\`${def.funct3 !== null ? `, funct3 \`${b(def.funct3, 3)}\`` : ''}${def.funct7 !== null ? `, funct${def.fmt === 'I-sh64' ? 6 : 7} \`${b(def.funct7, def.fmt === 'I-sh64' ? 6 : 7)}\`` : ''}; the immediate generator builds the ${def.fmt}-type immediate.`;
  st.RR = c.use_rs1 && c.use_rs2 ? 'Read `rs1` and `rs2` from the register file (write-first bypass if WB is writing the same register).'
    : c.use_rs1 ? 'Read `rs1` from the register file.' : 'Nothing to read: this instruction has no register sources.';
  const fwd = c.use_rs1 || c.use_rs2 ? ' Operands may be replaced by forwarded values from EX/MEM or MEM/WB.' : '';
  if (s === 'branch') st.EX = `Branch unit compares \`rs1\` and \`rs2\` (${def.sem.replace(/ pc \+= sext\(imm\)/, '').replace('if ', '')}); target = \`PC + imm\`. If taken, redirect PC and flush IF/ID/RR (3-cycle penalty).${fwd}`;
  else if (n === 'jal') st.EX = 'Target `PC + imm`: always redirect and flush IF/ID/RR. The link value `PC + 4` is sent down the pipe.';
  else if (n === 'jalr') st.EX = `Target \`(rs1 + imm) & ~1\`: always redirect and flush. Link value \`PC + 4\`.${fwd}`;
  else if (s === 'load' || s === 'store') st.EX = `ALU computes the effective address \`rs1 + imm\`.${fwd}`;
  else if (n === 'lui') st.EX = 'ALU computes `0 + imm` (A input selects ZERO).';
  else if (n === 'auipc') st.EX = 'ALU computes `PC + imm` (A input selects PC).';
  else if (s === 'none') st.EX = n === 'fence' ? 'Nothing (FENCE is a no-op on an in-order core with one memory).' : 'Halt instruction detected in EX: flush the younger instructions and stop fetching.';
  else st.EX = `ALU performs **${c.alu_op}**${c.is_word ? ' on 32 bits, result sign-extended to 64' : ''}: \`${def.sem}\`.${fwd}`;
  if (s === 'load') st.MEM = `Read memory at the address; ${/u$/.test(n) ? 'zero' : 'sign'}-extend the ${{ lb: 8, lbu: 8, lh: 16, lhu: 16, lw: 32, lwu: 32, ld: 64 }[n]}-bit value to 64 bits.`;
  else if (s === 'store') st.MEM = `Write the low ${{ sb: 8, sh: 16, sw: 32, sd: 64 }[n]} bits of \`rs2\` to memory (address \`0x1000_0000\` prints a character instead).`;
  else st.MEM = 'No memory access: the result passes through to MEM/WB.';
  st.WB = c.reg_write ? `Write \`rd\` ← ${s === 'load' ? 'loaded value' : c.wb_pc4 ? '`PC + 4`' : 'ALU result'}.` : (c.is_halt ? 'Reaching WB halts the core; the simulation ends.' : 'Nothing is written.');
  return st;
}

// examples with concrete registers
const EXAMPLES = {
  rrr: n => `${n} a0, a1, a2`, rri: n => (/^s(l|r)[la]iw?$/.test(n) ? `${n} a0, a1, ${n.endsWith('w') ? 5 : 40}` : `${n} a0, a1, -5`),
  load: n => `${n} a0, 16(sp)`, store: n => `${n} a0, 16(sp)`, branch: n => `${n} a0, a1, -8`, ui: n => `${n} a0, 0x12345`,
  jal: () => 'jal ra, 2048', jalr: () => 'jalr ra, 8(t0)', none: n => n,
};

function exampleWord(def) {
  const src = EXAMPLES[def.syntax](def.name);
  const d0 = decode(0);
  // encode through the assembler so the example matches real syntax (branch/jal offsets relative to pc 0)
  const txt = def.syntax === 'branch' ? `${def.name} a0, a1, target\n.org 0x100\ntarget:` : def.syntax === 'jal' ? 'jal ra, target\n.org 0x800\ntarget:' : src;
  const img = assemble(txt);
  const w = img.listing.find(l => l.word !== undefined).word;
  void d0;
  return { src: def.syntax === 'branch' ? `${def.name} a0, a1, +256` : def.syntax === 'jal' ? 'jal ra, +2048' : src, word: w };
}

// ---------------------------------------------------------------------------
// pipeline chart SVG from the model
// ---------------------------------------------------------------------------
function pipelineSVG(title, img, maxCycles = 30, maxRows = 22, { from = 1, bp = true } = {}) {
  const core = new Core(img.bytes, { bp });
  const events = core.run();
  const first = from, last = Math.min(events.length, from + maxCycles - 1);
  const rows = new Map();
  for (const ev of events.slice(first - 1, last)) for (const s of STAGES) {
    const st = ev.stages[s]; if (!st) continue;
    if (!rows.has(st.id)) rows.set(st.id, { pc: st.pc, text: st.text, cells: {} });
    const r = rows.get(st.id); if (!r.text && st.text) r.text = st.text;
    r.cells[ev.cycle] = { s, stall: ev.stall && ['IF', 'ID', 'RR'].includes(s), fwd: s === 'EX' ? [ev.fwd.a, ev.fwd.b].filter(Boolean) : [] };
  }
  const ids = [...rows.keys()].sort((a, b) => a - b).slice(0, maxRows);
  const cw = 30, rh = 24, lx = 250, top = 70;
  const width = lx + cw * (last - first + 1) + 24, height = top + rh * (ids.length + 1) + 64;
  let s = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}">`;
  s += `<defs><pattern id="hatch" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(45)"><line x1="0" y1="0" x2="0" y2="6" stroke="#17251D" stroke-opacity="0.35" stroke-width="2"/></pattern></defs>`;
  s += `<rect width="100%" height="100%" rx="10" fill="#FBFCF8" stroke="#D5DBD0"/>`;
  s += `<text x="16" y="28" ${FONT} font-size="17" font-weight="600" fill="#17251D">${esc(title)}</text>`;
  const st = core.stats;
  s += `<text x="16" y="48" ${FONT} font-size="12" fill="#4A5A50">${st.cycles} cycles total, ${st.retired} retired, CPI ${(st.cycles / st.retired).toFixed(2)}, ${st.loadUseStalls} load-use stall(s), ${st.branchFlushes} redirect(s), ${st.forwards} forwarded operand(s)${first > 1 ? ` — cycles ${first} to ${last} shown` : events.length > last ? ` — first ${last} cycles shown` : ''}${bp ? '' : ' — predictor OFF'}</text>`;
  for (let c = first; c <= last; c++) s += `<text x="${lx + (c - first + 0.5) * cw}" y="${top - 6}" text-anchor="middle" ${MONO} font-size="10.5" fill="#6B7A70">${c}</text>`;
  ids.forEach((id, i) => {
    const r = rows.get(id), y = top + i * rh;
    const squashed = core.instrs[id]?.squashed;
    if (i % 2 === 0) s += `<rect x="8" y="${y}" width="${width - 16}" height="${rh}" fill="#EEF2EA" fill-opacity="0.6"/>`;
    s += `<text x="16" y="${y + 16}" ${MONO} font-size="11" fill="${squashed ? '#9AA59D' : '#6B7A70'}">${r.pc.toString(16).padStart(4, '0')}</text>`;
    s += `<text x="56" y="${y + 16}" ${MONO} font-size="11.5" fill="${squashed ? '#9AA59D' : '#17251D'}"${squashed ? ' text-decoration="line-through"' : ''}>${esc((r.text || '').slice(0, 27))}</text>`;
    for (const [cyc, cell] of Object.entries(r.cells)) {
      const x = lx + (cyc - first) * cw + 2;
      const col = squashed ? '#B4BDB6' : STAGE_COLOR[cell.s];
      s += `<rect x="${x}" y="${y + 3}" width="${cw - 4}" height="${rh - 6}" rx="3" fill="${col}"${squashed ? ' fill-opacity="0.45"' : ''}/>`;
      if (cell.stall) s += `<rect x="${x}" y="${y + 3}" width="${cw - 4}" height="${rh - 6}" rx="3" fill="url(#hatch)"/>`;
      s += `<text x="${x + (cw - 4) / 2}" y="${y + 16}" text-anchor="middle" ${FONT} font-size="9.5" font-weight="700" fill="#FFFFFF">${cell.s}</text>`;
      if (cell.fwd.length) s += `<circle cx="${x + cw - 6}" cy="${y + 5}" r="4" fill="#FFFFFF" stroke="${STAGE_COLOR.EX}" stroke-width="2"/>`;
    }
  });
  const hy = top + ids.length * rh + 8;
  s += `<text x="16" y="${hy + 14}" ${FONT} font-size="11.5" font-weight="600" fill="#4A5A50">hazard unit</text>`;
  for (const ev of events.slice(first - 1, last)) {
    const x = lx + (ev.cycle - first) * cw + 2;
    if (ev.stall) s += `<rect x="${x}" y="${hy}" width="${cw - 4}" height="18" rx="3" fill="#F2C94C"/><text x="${x + (cw - 4) / 2}" y="${hy + 13}" text-anchor="middle" ${FONT} font-size="9.5" font-weight="700" fill="#17251D">stall</text>`;
    if (ev.redirect !== undefined || ev.haltEx) s += `<rect x="${x}" y="${hy}" width="${cw - 4}" height="18" rx="3" fill="#8E44AD"/><text x="${x + (cw - 4) / 2}" y="${hy + 13}" text-anchor="middle" ${FONT} font-size="9.5" font-weight="700" fill="#FFF">flush</text>`;
  }
  // legend
  let lxp = 16; const ly = height - 22;
  for (const k of STAGES) { s += `<rect x="${lxp}" y="${ly - 11}" width="26" height="15" rx="3" fill="${STAGE_COLOR[k]}"/><text x="${lxp + 13}" y="${ly}" text-anchor="middle" ${FONT} font-size="9.5" font-weight="700" fill="#FFF">${k}</text>`; lxp += 32; }
  s += `<rect x="${lxp + 8}" y="${ly - 11}" width="26" height="15" rx="3" fill="#9B59B6"/><rect x="${lxp + 8}" y="${ly - 11}" width="26" height="15" rx="3" fill="url(#hatch)"/><text x="${lxp + 40}" y="${ly}" ${FONT} font-size="11" fill="#4A5A50">stalled</text>`;
  s += `<circle cx="${lxp + 106}" cy="${ly - 4}" r="4" fill="#FFF" stroke="${STAGE_COLOR.EX}" stroke-width="2"/><text x="${lxp + 116}" y="${ly}" ${FONT} font-size="11" fill="#4A5A50">operand forwarded into EX</text>`;
  s += `<rect x="${lxp + 280}" y="${ly - 11}" width="26" height="15" rx="3" fill="#B4BDB6" fill-opacity="0.45"/><text x="${lxp + 312}" y="${ly}" ${FONT} font-size="11" fill="#4A5A50">flushed (wrong path)</text>`;
  return s + '</svg>\n';
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
function main() {
  // 1. format pictures
  const FORMAT_TITLES = {
    R: 'R-type: register-register (add, sub, mul, ...)', I: 'I-type: immediate, loads, jalr',
    'I-sh64': 'I-type shift (RV64): slli, srli, srai with a 6-bit shift amount',
    'I-sh32': 'I-type shift (word): slliw, srliw, sraiw with a 5-bit shift amount',
    S: 'S-type: stores', B: 'B-type: conditional branches', U: 'U-type: lui, auipc', J: 'J-type: jal',
    SYS: 'SYSTEM: ecall, ebreak', FENCE: 'FENCE',
  };
  for (const [fmt, fl] of Object.entries(FORMATS))
    W(`docs/img/formats/${fmt}.svg`, bitfieldSVG(FORMAT_TITLES[fmt], fl.map(([name, hi, lo]) => ({ name, hi, lo, bits: '' }))));

  // 2. per-instruction pages + pictures
  const index = [];
  for (const def of INSTRUCTIONS) {
    const tb = templateBits(def);
    W(`docs/img/instructions/${def.name}.svg`, bitfieldSVG(`${def.name} — ${def.desc}`, fieldsWithBits(def.fmt, tb), def.sem));
    const ex = exampleWord(def);
    const exBits = b(ex.word, 32);
    W(`docs/img/instructions/${def.name}_example.svg`, bitfieldSVG(`${ex.src}   =   0x${ex.word.toString(16).padStart(8, '0')}`, fieldsWithBits(def.fmt, exBits), 'example encoding'));
    const c = control(def), story = stageStory(def);
    const fieldRows = FORMATS[def.fmt].map(([name, hi, lo]) => `| \`${name}\` | ${hi}:${lo} | \`${tb.slice(31 - hi, 32 - lo)}\` | \`${exBits.slice(31 - hi, 32 - lo)}\` |`).join('\n');
    const md = `# \`${def.name}\` — ${def.desc}

[← all instructions](../README.md) · extension **${def.ext}** · format **${def.fmt}** · category *${def.cls}*

\`\`\`
${def.sem}
\`\`\`

## Encoding

![${def.name} encoding](../../docs/img/instructions/${def.name}.svg)

\`\`\`
bit:  31                              0
      ${tb.replace(/(.{4})/g, '$1 ').trim()}
\`\`\`

Fixed bits are \`0\`/\`1\`. Letters are filled in by the assembler:
\`d\` = rd, \`s\` = rs1, \`t\` = rs2, \`i\` = immediate, \`h\` = shift amount, \`f\` = funct3, \`m/p/u\` = fence fields.

## Example

\`${ex.src}\` assembles to **\`0x${ex.word.toString(16).padStart(8, '0')}\`** = \`${exBits}\`

![example](../../docs/img/instructions/${def.name}_example.svg)

| field | bits | template | example |
|---|---|---|---|
${fieldRows}

Try it yourself:

\`\`\`bash
node tools/rv.mjs encode "${ex.src.replace(/\+/, '')}"${def.syntax === 'branch' || def.syntax === 'jal' ? '   # use a label or a number for the offset' : ''}
node tools/rv.mjs decode ${ex.word.toString(16).padStart(8, '0')}
\`\`\`

## Control signals set by the decoder (\`rtl/decoder.v\`)

| signal | value | | signal | value |
|---|---|---|---|---|
| \`use_rs1\` | ${c.use_rs1} | | \`is_load\` | ${c.is_load} |
| \`use_rs2\` | ${c.use_rs2} | | \`is_store\` | ${c.is_store} |
| \`reg_write\` | ${c.reg_write} | | \`is_branch\` | ${c.is_branch} |
| \`alu_op\` | ${c.alu_op} | | \`is_jal\` / \`is_jalr\` | ${c.is_jal} / ${c.is_jalr} |
| \`a_sel\` | ${c.a_sel} | | \`wb_pc4\` | ${c.wb_pc4} |
| \`b_imm\` | ${c.b_imm} | | \`is_halt\` | ${c.is_halt} |
| \`is_word\` | ${c.is_word} | | | |

## Journey through the 6-stage pipeline

| stage | what happens to \`${def.name}\` |
|---|---|
${STAGES.map(s => `| **${s}** | ${story[s]} |`).join('\n')}
`;
    W(`binary/${def.ext}/${def.name}.md`, md);
    index.push({ def, tb });
  }

  // 3. index page
  const groups = {};
  for (const x of index) (groups[x.def.cls] ??= []).push(x);
  let idx = `# Instruction encodings — every RV64IM instruction in binary

This folder is generated by \`node tools/gendocs.mjs\` from the single ISA table in
[\`sim/isa.js\`](../sim/isa.js). Every instruction is exactly **32 bits**. The low 7 bits are
always the **opcode**; register numbers sit in the **same bit positions** in every format
(\`rd\` = bits 11:7, \`rs1\` = 19:15, \`rs2\` = 24:20) so the decoder can start reading the
register file before it even knows what the instruction is.

* [Opcode map](opcode_map.md) — which opcode means what
* [Assembled example programs](programs/) — every experiment as address / hex / binary / source

## The six formats

| | |
|---|---|
| ![R](../docs/img/formats/R.svg) | ![I](../docs/img/formats/I.svg) |
| ![S](../docs/img/formats/S.svg) | ![B](../docs/img/formats/B.svg) |
| ![U](../docs/img/formats/U.svg) | ![J](../docs/img/formats/J.svg) |
| ![I-sh64](../docs/img/formats/I-sh64.svg) | ![I-sh32](../docs/img/formats/I-sh32.svg) |

**Why are B and J immediates scrambled?** So that every immediate bit that exists in several
formats sits in the same instruction bit (e.g. imm[10:5] is always bits 30:25 and the sign is
always bit 31). That makes the immediate generator in \`rtl/imm_gen.v\` a set of simple wires,
not a big multiplexer. Branch/jump offsets are always even, so bit 0 is not stored at all.

## All ${INSTRUCTIONS.length} instructions

Letters in the pattern are the variable fields: \`d\` rd, \`s\` rs1, \`t\` rs2, \`i\` immediate,
\`h\` shift amount.

`;
  for (const [cls, list] of Object.entries(groups)) {
    idx += `### ${cls}\n\n| instruction | format | 32-bit pattern (bit 31 … bit 0) | meaning |\n|---|---|---|---|\n`;
    for (const { def, tb } of list) idx += `| [\`${def.name}\`](${def.ext}/${def.name}.md) | ${def.fmt} | \`${tb.slice(0, 7)} ${tb.slice(7, 12)} ${tb.slice(12, 17)} ${tb.slice(17, 20)} ${tb.slice(20, 25)} ${tb.slice(25)}\` | \`${def.sem.replace(/\|/g, '\\|')}\` |\n`;
    idx += '\n';
  }
  W('binary/README.md', idx);

  // 4. opcode map
  const opNames = Object.fromEntries(Object.entries(OPCODES).map(([k, v]) => [v, k]));
  let om = `# RISC-V major opcode map (RV64IM subset implemented here)

The opcode is \`inst[6:0]\`. For 32-bit instructions \`inst[1:0]\` is always \`11\`
(\`00\`, \`01\`, \`10\` mark 16-bit compressed instructions, not implemented here).
Rows are \`inst[6:5]\`, columns are \`inst[4:2]\`.

| inst[6:5] \\ inst[4:2] | 000 | 001 | 010 | 011 | 100 | 101 | 110 | 111 |
|---|---|---|---|---|---|---|---|---|
`;
  for (let r = 0; r < 4; r++) {
    om += `| **${b(r, 2)}** |`;
    for (let c = 0; c < 8; c++) {
      const op = (r << 5) | (c << 2) | 0b11;
      const name = opNames[op];
      om += name ? ` **${name}**<br>\`${b(op, 7)}\` |` : ` · |`;
    }
    om += '\n';
  }
  om += `\n## Instructions under each opcode\n\n`;
  for (const [name, op] of Object.entries(OPCODES)) {
    const list = INSTRUCTIONS.filter(i => i.opcode === op);
    om += `### ${name} \`${b(op, 7)}\`\n\n${list.map(i => `[\`${i.name}\`](${i.ext}/${i.name}.md)`).join(' · ')}\n\n`;
  }
  W('binary/opcode_map.md', om);

  // 5. assembled programs + pipeline pictures
  const progs = [...fs.readdirSync('programs').filter(f => f.endsWith('.s')).sort().map(f => 'programs/' + f)];
  for (const p of progs) {
    const name = path.basename(p, '.s');
    const img = assemble(fs.readFileSync(p, 'utf8'));
    W(`binary/programs/${name}.lst`, toListing(img));
    W(`binary/programs/${name}.hex`, toHex(img));
    W(`docs/img/pipeline/${name}.svg`, pipelineSVG(`${name}.s`, img));
  }
  // extra views for the branch-prediction story
  const img11 = assemble(fs.readFileSync('programs/11_gshare_patterns.s', 'utf8'));
  W('docs/img/pipeline/11_gshare_patterns_warm.svg', pipelineSVG('11_gshare_patterns.s after the predictor has trained', img11, 30, 22, { from: 900 }));
  W('docs/img/pipeline/11_gshare_patterns_nobp.svg', pipelineSVG('11_gshare_patterns.s with the predictor OFF', img11, 30, 22, { from: 900, bp: false }));
  const img05 = assemble(fs.readFileSync('programs/05_fibonacci.s', 'utf8'));
  W('docs/img/pipeline/05_fibonacci_nobp.svg', pipelineSVG('05_fibonacci.s with the predictor OFF', img05, 30, 22, { from: 100, bp: false }));
  W('docs/img/pipeline/05_fibonacci_warm.svg', pipelineSVG('05_fibonacci.s with gshare (trained)', img05, 30, 22, { from: 100 }));
  // sample programs for the web simulator (works without a server fetch)
  const bundle = Object.fromEntries(progs.map(p => [path.basename(p, '.s'), fs.readFileSync(p, 'utf8')]));
  W('web/programs.js', `// generated by tools/gendocs.mjs — every file in programs/\nexport const PROGRAMS = ${JSON.stringify(bundle, null, 1)};\n`);
  W('binary/programs/README.md', `# Assembled programs

Every file in [\`programs/\`](../../programs) assembled by \`sim/asm.js\`.

* \`.lst\` — listing: address, hex word, **binary word**, source line
* \`.hex\` — memory image for \`$readmemh\` (one byte per line, little-endian)

${progs.map(p => { const n = path.basename(p, '.s'); return `* [${n}.lst](${n}.lst) · [${n}.hex](${n}.hex)`; }).join('\n')}
`);

  // 6. block diagram
  W('docs/img/cpu_block_diagram.svg', blockDiagramSVG());
  console.log(`generated: ${INSTRUCTIONS.length} instruction pages, ${Object.keys(FORMATS).length} format diagrams, ${progs.length} pipeline charts, block diagram`);
}

main();
