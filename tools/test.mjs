#!/usr/bin/env node
// =============================================================================
// tools/test.mjs — regression suite.
//
// For every program in programs/ and tests/:
//   1. assemble it                                   (sim/asm.js)
//   2. run it on the cycle-accurate model            (sim/core.js)
//   3. check the "# EXPECT:" lines in its header     (register values, output)
//   4. run the SAME image on the Verilog RTL         (iverilog + tb/tb_soc.v)
//   5. demand the RTL and the model agree on EVERY cycle's pipeline contents,
//      the cycle count, the program output and all 32 registers.
//
//   node tools/test.mjs              everything
//   node tools/test.mjs --no-rtl     model only (no Icarus Verilog needed)
//   node tools/test.mjs 05           only programs whose name contains "05"
//   node tools/test.mjs --bp=off     only the static not-taken configuration
//
// Every program runs TWICE: with the gshare predictor and with it disabled.
// =============================================================================
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync, spawnSync } from 'node:child_process';
import { assemble, toHex, toListing } from '../sim/asm.js';
import { Core } from '../sim/core.js';
import { regNum, ABI } from '../sim/isa.js';

const args = process.argv.slice(2);
const noRtl = args.includes('--no-rtl');
const filter = args.find(a => !a.startsWith('--'));
const bpArg = (args.find(a => a.startsWith('--bp=')) || '--bp=both').slice(5);
const MODES = bpArg === 'on' ? [true] : bpArg === 'off' ? [false] : [true, false];
const tty = process.stdout.isTTY;
const green = s => (tty ? `\x1b[32m${s}\x1b[0m` : s), red = s => (tty ? `\x1b[31m${s}\x1b[0m` : s);

const files = ['programs', 'tests'].flatMap(d => fs.readdirSync(d).filter(f => f.endsWith('.s')).sort().map(f => path.join(d, f)))
  .filter(f => !filter || f.includes(filter));

fs.mkdirSync('build', { recursive: true });
let haveRtl = false;
if (!noRtl) {
  const r = spawnSync('iverilog', ['-g2012', '-I', 'rtl', '-o', 'build/sim.vvp', 'tb/tb_soc.v', ...fs.readdirSync('rtl').filter(f => f.endsWith('.v')).map(f => 'rtl/' + f)], { encoding: 'utf8' });
  if (r.error) console.log('iverilog not found: skipping RTL comparison (sudo apt install iverilog)');
  else if (r.status !== 0) { console.log(red('RTL failed to compile:\n') + r.stderr); process.exit(1); }
  else haveRtl = true;
}

function parseExpect(src) {
  const regs = [], out = [];
  for (const m of src.matchAll(/^#\s*EXPECT:\s*(\w+)\s*=\s*(-?\w+)\s*$/gm)) regs.push([m[1], BigInt.asUintN(64, BigInt(m[2]))]);
  for (const m of src.matchAll(/^#\s*EXPECT-OUTPUT:\s?(.*)$/gm)) out.push(m[1].replace(/\\n/g, '\n'));
  return { regs, output: out.length ? out.join('') : null };
}

let pass = 0, fail = 0;
for (const f of files) {
  const name = path.basename(f, '.s');
  const src = fs.readFileSync(f, 'utf8');
  let img;
  try { img = assemble(src); } catch (e) { console.log(`${red('FAIL')} ${f}: assembly error\n${e.message}`); fail++; continue; }
  fs.writeFileSync(`build/${name}.hex`, toHex(img));
  fs.writeFileSync(`build/${name}.lst`, toListing(img));

  for (const bp of MODES) {
  const problems = [];
  const tag = bp ? 'gshare' : 'no-bp ';
  // ---------------- model ----------------
  const core = new Core(img.bytes, { bp });
  const trace = [];
  while (!core.halted && core.cycle < 2000000) trace.push(Core.traceLine(core.step()));
  if (!core.halted) problems.push('model did not halt');
  fs.writeFileSync(`build/${name}.${bp ? 'bp' : 'nobp'}.model.trace`, trace.join('\n') + '\n');
  const exp = parseExpect(src);
  for (const [r, v] of exp.regs) {
    const got = core.regs[regNum(r)];
    if (got !== v) problems.push(`model: ${r} = ${BigInt.asIntN(64, got)} (0x${got.toString(16)}), expected ${BigInt.asIntN(64, v)}`);
  }
  if (exp.output !== null && core.output !== exp.output) problems.push(`model: output ${JSON.stringify(core.output)}, expected ${JSON.stringify(exp.output)}`);
  if (core.illegal) problems.push('model halted on an illegal instruction');

  // ---------------- RTL ----------------
  let rtlNote = '';
  if (haveRtl && core.halted) {
    const r = spawnSync('vvp', ['-n', 'build/sim.vvp', `+HEX=build/${name}.hex`, `+TRACE=build/${name}.${bp ? 'bp' : 'nobp'}.rtl.trace`, '+MAXCYCLES=2000000', `+BP=${bp ? 1 : 0}`], { encoding: 'utf8', maxBuffer: 1 << 26 });
    const stdout = r.stdout || '';
    const k = stdout.indexOf('[tb] HALT');
    if (k < 0) problems.push('RTL did not halt:\n' + stdout.slice(-500));
    else {
      const rtlOut = stdout.slice(0, k).replace(/\n$/, '');
      if (rtlOut !== core.output) problems.push(`RTL output ${JSON.stringify(rtlOut)} != model ${JSON.stringify(core.output)}`);
      const regs = {};
      for (const m of stdout.matchAll(/^REG x(\d+) ([0-9a-f]+)$/gm)) regs[+m[1]] = BigInt('0x' + m[2]);
      for (let i = 0; i < 32; i++) if (regs[i] !== core.regs[i])
        problems.push(`RTL x${i}(${ABI[i]}) = 0x${(regs[i] ?? 0n).toString(16)}, model = 0x${core.regs[i].toString(16)}`);
      const rt = fs.readFileSync(`build/${name}.${bp ? 'bp' : 'nobp'}.rtl.trace`, 'utf8').trimEnd().split('\n');
      const n = Math.max(rt.length, trace.length);
      for (let i = 0; i < n; i++) if (rt[i] !== trace[i]) {
        problems.push(`pipeline trace differs at line ${i + 1}:\n      RTL:   ${rt[i]}\n      model: ${trace[i]}`); break;
      }
      rtlNote = ' | RTL ✓ cycle-exact';
    }
  }
  const s = core.stats;
  const info = `${String(s.cycles).padStart(6)} cycles, CPI ${(s.cycles / s.retired).toFixed(2)}, ${String(s.mispredicts).padStart(4)} redirects`;
  if (problems.length) { fail++; console.log(`${red('FAIL')} ${tag} ${f}  (${info})`); problems.slice(0, 8).forEach(p => console.log('   - ' + p)); }
  else { pass++; console.log(`${green('PASS')} ${tag} ${f.padEnd(34)} ${info}${rtlNote}`); }
  }
}
console.log(`\n${pass} passed, ${fail} failed${haveRtl ? '' : '  (RTL comparison skipped)'}`);
process.exit(fail ? 1 : 0);
