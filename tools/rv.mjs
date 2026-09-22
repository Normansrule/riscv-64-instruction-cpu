#!/usr/bin/env node
// =============================================================================
// tools/rv.mjs — command-line front end for the RV64IM 6-stage CPU project.
//
//   node tools/rv.mjs asm    programs/05_fibonacci.s        -> build/05_fibonacci.{hex,lst}
//   node tools/rv.mjs run    programs/05_fibonacci.s        run on the pipeline model
//   node tools/rv.mjs pipe   programs/02_forwarding.s       ASCII pipeline chart
//   node tools/rv.mjs encode "add a0, a1, a2"               show the binary fields
//   node tools/rv.mjs decode 0x00c58533                     binary -> assembly
//   node tools/rv.mjs isa                                   list every instruction
// =============================================================================
import fs from 'node:fs';
import path from 'node:path';
import { assemble, toHex, toListing } from '../sim/asm.js';
import { Core, STAGES } from '../sim/core.js';
import { decode, disasm, INSTRUCTIONS, FORMATS, ABI, encode } from '../sim/isa.js';

const tty = process.stdout.isTTY && !process.env.NO_COLOR;
const C = (code, s) => (tty ? `\x1b[${code}m${s}\x1b[0m` : s);
const STAGE_COLOR = { IF: 36, ID: 34, RR: 35, EX: 33, MEM: 32, WB: 31 };
const STAGE_LETTER = { IF: 'F', ID: 'D', RR: 'R', EX: 'X', MEM: 'M', WB: 'W' };

function usage() {
  console.log(`usage: node tools/rv.mjs <command> [args]

  asm    <file.s> [-o outbase]     assemble to <outbase>.hex and <outbase>.lst (default build/<name>)
  run    <file.s> [--trace f] [--max N] [--quiet]
                                   run on the cycle-accurate pipeline model
  pipe   <file.s> [--cycles N] [--from C]
                                   print a pipeline chart (instruction x cycle)
  cycle  <file.s> <C>              explain everything that happens in cycle C
  bp     <file.s>                  compare no prediction / bimodal / gshare
  run/pipe/cycle accept --no-bp to disable the gshare predictor
  encode "<instruction>"           show the binary encoding field by field
  decode <hexword> [...]           decode 32-bit machine words
  isa                              table of every supported instruction`);
}

function load(file) {
  const src = fs.readFileSync(file, 'utf8');
  try { return { src, img: assemble(src) }; }
  catch (e) { console.error(C(31, `assembly failed for ${file}:\n`) + e.message); process.exit(1); }
}
function opt(args, name, def) { const i = args.indexOf(name); return i >= 0 ? args[i + 1] : def; }
const hex64 = v => '0x' + v.toString(16).padStart(16, '0');
const signed = v => BigInt.asIntN(64, v);

function cmdAsm(args) {
  const file = args[0];
  const { img } = load(file);
  const base = opt(args, '-o', path.join('build', path.basename(file).replace(/\.s$/, '')));
  fs.mkdirSync(path.dirname(base), { recursive: true });
  fs.writeFileSync(base + '.hex', toHex(img));
  fs.writeFileSync(base + '.lst', toListing(img));
  const n = img.listing.filter(l => l.word !== undefined).length;
  console.log(`${file}: ${n} instructions, ${img.used[1] - img.used[0]} bytes -> ${base}.hex, ${base}.lst`);
}

function printSummary(core) {
  const s = core.stats;
  const cpi = (s.cycles / s.retired).toFixed(2);
  console.log(C(1, '\n── pipeline statistics ─────────────────────────────'));
  console.log(`  cycles               ${s.cycles}`);
  console.log(`  instructions retired ${s.retired}`);
  console.log(`  CPI                  ${cpi}   (ideal = 1.00)`);
  console.log(`  load-use stalls      ${s.loadUseStalls}   (1 bubble each)`);
  console.log(`  branches / jumps     ${s.branches} / ${s.jumps}`);
  console.log(`  mispredictions       ${s.mispredicts}   (3 flushed slots each)${s.branches ? `   accuracy ${(100 * (1 - s.mispredicts / (s.branches + s.jumps))).toFixed(1)}% of control transfers` : ''}`);
  console.log(`  instructions flushed ${s.squashed}`);
  console.log(`  operands forwarded   ${s.forwards}`);
}

function printRegs(core) {
  console.log(C(1, '\n── registers (non-zero) ─────────────────────────────'));
  for (let i = 1; i < 32; i++) {
    const v = core.regs[i];
    if (v === 0n) continue;
    console.log(`  x${String(i).padEnd(2)} ${ABI[i].padEnd(4)} ${hex64(v)}  ${signed(v)}`);
  }
}

function cmdRun(args) {
  const file = args[0];
  const { img } = load(file);
  const core = new Core(img.bytes, { bp: !args.includes('--no-bp') });
  const max = Number(opt(args, '--max', 2000000));
  const traceFile = opt(args, '--trace', null);
  const lines = [];
  while (!core.halted && core.cycle < max) {
    const ev = core.step();
    if (traceFile) lines.push(Core.traceLine(ev));
  }
  if (traceFile) fs.writeFileSync(traceFile, lines.join('\n') + '\n');
  if (!core.halted) { console.error(C(31, `no halt after ${max} cycles`)); process.exit(2); }
  if (core.output) { console.log(C(1, '── program output ─────────────────────────────────')); process.stdout.write(core.output); if (!core.output.endsWith('\n')) console.log(); }
  if (core.illegal) console.log(C(31, 'halted on an ILLEGAL instruction'));
  if (!args.includes('--quiet')) printRegs(core);
  printSummary(core);
}

function pipelineChart(img, { from = 1, cycles = 40, bp = true } = {}) {
  const core = new Core(img.bytes, { bp });
  const events = core.run();
  const last = Math.min(events.length, from + cycles - 1);
  const rows = new Map(); // id -> {pc, text, cells: {cycle: stage}}
  const marks = {};
  for (const ev of events) {
    if (ev.cycle < from || ev.cycle > last) continue;
    for (const s of STAGES) {
      const st = ev.stages[s];
      if (!st) continue;
      if (!rows.has(st.id)) rows.set(st.id, { pc: st.pc, text: st.text || '', cells: {} });
      const r = rows.get(st.id);
      if (!r.text && st.text) r.text = st.text;
      r.cells[ev.cycle] = { s, stall: ev.stall && ['IF', 'ID', 'RR'].includes(s), fwd: s === 'EX' && (ev.fwd.a || ev.fwd.b) };
    }
    marks[ev.cycle] = ev.stall ? 'S' : (ev.redirect !== undefined || ev.haltEx) ? 'F' : ' ';
  }
  const ids = [...rows.keys()].sort((a, b) => a - b);
  const W = 3;
  let head = ' '.repeat(36) + '│';
  for (let c = from; c <= last; c++) head += String(c).padStart(W);
  const outLines = [C(1, head)];
  let mk = ' '.repeat(28) + 'hazard: │';
  for (let c = from; c <= last; c++) mk += (marks[c] === 'S' ? C(41, '  S') : marks[c] === 'F' ? C(45, '  F') : '   ');
  for (const id of ids) {
    const r = rows.get(id);
    const inst = core.instrs[id];
    const squashed = inst && inst.squashed;
    let line = `${r.pc.toString(16).padStart(5, '0')}  ${(r.text || '').slice(0, 28).padEnd(29)}│`;
    for (let c = from; c <= last; c++) {
      const cell = r.cells[c];
      if (!cell) { line += C(90, '  ·'); continue; }
      let t = STAGE_LETTER[cell.s];
      if (cell.fwd) t = t + '*';
      t = t.padStart(W);
      if (squashed) line += C(90, t.toLowerCase().replace(/[a-z]/, 'x'));
      else if (cell.stall) line += C('7;' + STAGE_COLOR[cell.s], t);
      else line += C(STAGE_COLOR[cell.s], t);
    }
    outLines.push(squashed ? line + C(90, '  ← flushed') : line);
  }
  outLines.push(mk);
  return { text: outLines.join('\n'), core, events };
}

function cmdPipe(args) {
  const { img } = load(args[0]);
  const from = Number(opt(args, '--from', 1)), cycles = Number(opt(args, '--cycles', 40));
  const { text, core } = pipelineChart(img, { from, cycles, bp: !args.includes('--no-bp') });
  console.log(text);
  console.log(`\nlegend: F=IF D=ID R=RR X=EX M=MEM W=WB   X*=operand forwarded into EX` +
    `\n        inverse video = stalled (load-use)   x = flushed wrong-path instruction` +
    `\n        hazard row: S = load-use stall this cycle, F = flush (taken branch/jump/halt)`);
  printSummary(core);
}

function cmdCycle(args) {
  const { img } = load(args[0]);
  const target = Number(args[1]);
  const core = new Core(img.bytes, { bp: !args.includes('--no-bp') });
  let ev;
  while (!core.halted) { ev = core.step(); if (ev.cycle === target) break; }
  if (!ev || ev.cycle !== target) { console.log(`program halted before cycle ${target}`); return; }
  console.log(C(1, `cycle ${target}`));
  for (const s of STAGES) {
    const st = ev.stages[s];
    console.log(`  ${C(STAGE_COLOR[s], s.padEnd(4))} ${st ? `0x${st.pc.toString(16).padStart(4, '0')}  ${st.text}` : C(90, '(bubble)')}`);
  }
  if (ev.fwd.a) console.log(`  forward: EX operand A <- ${ev.fwd.a === 'MEM' ? 'EX/MEM latch (1 instr ahead)' : 'MEM/WB latch (2 instrs ahead)'}`);
  if (ev.fwd.b) console.log(`  forward: EX operand B <- ${ev.fwd.b === 'MEM' ? 'EX/MEM latch (1 instr ahead)' : 'MEM/WB latch (2 instrs ahead)'}`);
  if (ev.alu) console.log(`  ALU: a=${hex64(ev.alu.a)} b=${hex64(ev.alu.b)} -> ${hex64(ev.alu.result)}`);
  if (ev.memAccess) console.log(`  MEM: ${ev.memAccess.kind} ${ev.memAccess.size} byte(s) @ 0x${ev.memAccess.addr.toString(16)} = ${hex64(ev.memAccess.value)}`);
  if (ev.rfWrite) console.log(`  WB : x${ev.rfWrite.rd} (${ABI[ev.rfWrite.rd]}) <- ${hex64(ev.rfWrite.value)}`);
  if (ev.stall) console.log(C(33, '  LOAD-USE STALL: PC, IF/ID, ID/RR hold; bubble into EX'));
  if (ev.predict) console.log(`  predictor (IF): index ${ev.predict.idx} counter ${ev.predict.counter} BTB ${ev.predict.hit ? 'hit' : 'miss'} -> predict ${ev.predict.taken ? 'TAKEN to 0x' + ev.predict.target.toString(16) : 'not taken'}`);
  if (ev.resolve) console.log(`  resolve (EX): predicted ${ev.resolve.predicted ? 'T' : 'N'}, actual ${ev.resolve.actual ? 'T' : 'N'} -> ${ev.resolve.mispredict ? C(31, 'MISPREDICT') : C(32, 'correct')}`);
  if (ev.redirect !== undefined) console.log(C(35, `  REDIRECT to 0x${ev.redirect.toString(16)}: flush IF, ID, RR`));
  if (ev.haltEx) console.log(C(35, '  HALT instruction in EX: flush younger, stop fetching'));
  if (ev.halt) console.log(C(31, '  HALT reached WB: simulation ends'));
}

export function fieldBreakdown(word, fmt) {
  const b = word.toString(2).padStart(32, '0');
  return FORMATS[fmt].map(([name, hi, lo]) => ({ name, hi, lo, bits: b.slice(31 - hi, 32 - lo) }));
}

function showFields(word) {
  const d = decode(word);
  if (!d.def) { console.log(`0x${word.toString(16).padStart(8, '0')}  ->  illegal / unsupported`); return; }
  const f = fieldBreakdown(word, d.fmt);
  console.log(`${C(1, disasm(d))}    [${d.def.desc}, ${d.fmt}-type, ${d.def.ext}]`);
  console.log(`  hex     0x${word.toString(16).padStart(8, '0')}`);
  console.log(`  binary  ${f.map(x => C(STAGE_COLOR[['IF', 'ID', 'RR', 'EX', 'MEM', 'WB'][f.indexOf(x) % 6]], x.bits)).join(' ')}`);
  for (const x of f) console.log(`          ${x.name.padEnd(24)} [${String(x.hi).padStart(2)}:${String(x.lo).padStart(2)}]  ${x.bits}`);
  console.log(`  meaning ${d.def.sem}`);
}

function cmdEncode(args) {
  const src = args.join(' ');
  let img;
  try { img = assemble(src); } catch (e) { console.error(e.message); process.exit(1); }
  for (const l of img.listing) if (l.word !== undefined) { showFields(l.word); console.log(); }
}

function cmdDecode(args) {
  for (const a of args) { showFields(parseInt(a.replace(/_/g, ''), 16) >>> 0); console.log(); }
}

function cmdBp(args) {
  const { img } = load(args[0]);
  const rows = [['none (predict not-taken)', { bp: false }], ['bimodal (2-bit counters, no history)', { bp: true, history: false }], ['gshare (PC xor 8-bit history)', { bp: true }]];
  console.log('predictor                              cycles    CPI   mispredicts   accuracy');
  for (const [label, o] of rows) {
    const core = new Core(img.bytes, o); core.run(5e6, false);
    const s = core.stats, n = s.branches + s.jumps;
    console.log(`${label.padEnd(38)} ${String(s.cycles).padStart(7)}  ${(s.cycles / s.retired).toFixed(2)}  ${String(s.mispredicts).padStart(11)}   ${n ? (100 * (1 - s.mispredicts / n)).toFixed(1) + '%' : '-'}`);
  }
  console.log('\naccuracy = correctly predicted control transfers (branches + jumps) / all of them');
}

function cmdIsa() {
  console.log('NAME     FMT     OPCODE   F3   F7/F6    EXT    DESCRIPTION');
  for (const i of INSTRUCTIONS) {
    const f3 = i.funct3 === null ? '---' : i.funct3.toString(2).padStart(3, '0');
    const f7 = i.funct7 === null ? '-------' : i.funct7.toString(2).padStart(i.fmt === 'I-sh64' ? 6 : 7, '0');
    console.log(`${i.name.padEnd(8)} ${i.fmt.padEnd(7)} ${i.opcode.toString(2).padStart(7, '0')}  ${f3}  ${f7.padEnd(8)} ${i.ext.padEnd(6)} ${i.desc}`);
  }
  console.log(`\n${INSTRUCTIONS.length} instructions`);
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === path.resolve(new URL(import.meta.url).pathname);
if (isMain) {
  const [cmd, ...args] = process.argv.slice(2);
  const cmds = { asm: cmdAsm, run: cmdRun, pipe: cmdPipe, cycle: cmdCycle, bp: cmdBp, encode: cmdEncode, decode: cmdDecode, isa: cmdIsa };
  if (!cmds[cmd] || (cmd !== 'isa' && !args.length)) { usage(); process.exit(cmd ? 1 : 0); }
  cmds[cmd](args);
}
export { pipelineChart };
