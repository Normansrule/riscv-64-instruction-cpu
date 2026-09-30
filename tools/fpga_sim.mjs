#!/usr/bin/env node
// =============================================================================
// tools/fpga_sim.mjs: the FPGA computer, simulated end to end, against the model
//
//   node tools/fpga_sim.mjs [program.s ...]     (default: every program and the ISA self-check)
//
// For each program: tools/fpga_image.mjs makes the upload stream, the Verilator build of
// fpga/sim/system_testbench.sv powers the system on, waits for the boot firmware's prompt, uploads
// the program over the simulated UART, runs it and reads the firmware's report. Checked:
//   * the firmware reports PASS (or the same FAIL as the model)
//   * the program's printed output, as it arrived over the UART, equals the model's
//   * the cycle count the system measured equals the cycle-exact model's
// So the block RAM main memory, the device registers, the boot firmware and the soft reset all
// behave exactly like the simulation platform that `make test` checks cycle by cycle.
// =============================================================================
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { assemble } from '../model/asm.js';
import { Core, CONFIGS } from '../model/core.js';

const BINARY = 'build/fsim/fsim';
const core = fs.readFileSync('src/sources.f', 'utf8').split('\n').filter(f => f && !/Scratchpad|Riscv64_top/.test(f));
const fpga = fs.readFileSync('fpga/sources.f', 'utf8').split('\n').filter(Boolean);
const sources = [...core, ...fpga, 'fpga/sim/system_testbench.sv'];
const newest = Math.max(...sources.map(f => fs.statSync(f).mtimeMs));
if (!fs.existsSync(BINARY) || fs.statSync(BINARY).mtimeMs < newest) {
  process.stdout.write('building the FPGA system simulation with Verilator... ');
  fs.mkdirSync('build/fsim', { recursive: true });
  execFileSync('verilator', ['--binary', '--timing', '-O2', '-DSIXFOLD_FPGA', '-Wno-fatal', '-Wno-TIMESCALEMOD', '-Wno-lint', '-Wno-style', ...sources,
    '--top-module', 'system_testbench', '-Mdir', 'build/fsim', '-o', 'fsim'], { stdio: ['ignore', 'ignore', 'inherit'] });
  console.log('done');
}

execFileSync('node', ['tools/fpga_image.mjs', '--out', 'build/fpga'], { stdio: 'ignore' }); // the power-on image: firmware only
let programs = process.argv.slice(2);
if (!programs.length) programs = ['programs', 'tests', 'fpga/examples'].flatMap(d => fs.readdirSync(d).filter(f => f.endsWith('.s')).sort().map(f => `${d}/${f}`));
let failed = 0;
for (const program of programs) {
  const name = path.basename(program, '.s');
  const out = `build/fpga/${name}`;
  fs.mkdirSync(out, { recursive: true });
  execFileSync('node', ['tools/fpga_image.mjs', program, '--out', out], { stdio: 'ignore' });
  const source = fs.readFileSync(program, 'utf8');
  const readsDevices = /^# FPGA: reads the clock rate/m.test(source); // runs longer on the board, on purpose
  const expected = /^# FPGA-EXPECT-OUTPUT: (.*)$/m.exec(source); // board-only programs (typed input): check what they print
  const model = new Core(assemble(source), { ...CONFIGS.performance, bp: true });
  if (!expected) model.run(5e6, false);
  const text = execFileSync(BINARY, [`+UPLOAD=${out}/upload.hex`, '+MAXCYCLES=20000000'], { encoding: 'latin1', maxBuffer: 1 << 26 });
  fs.writeFileSync(`${out}/uart.txt`, text);
  const start = text.indexOf('starting the program at 0x2000\r\n'), end = text.indexOf('\r\n[bios] program finished: ');
  const report = /program finished: (PASS|FAIL, test (\d+)) in (\d+) cycles/.exec(text);
  const problems = [];
  if (start < 0 || end < 0 || !report) problems.push('no report from the firmware (see ' + out + '/uart.txt)');
  else {
    const printed = text.slice(start + 'starting the program at 0x2000\r\n'.length, end);
    const tohost = report[1] === 'PASS' ? 1n : (BigInt(report[2]) << 1n) | 1n;
    if (expected) { if (report[1] !== 'PASS' || !printed.includes(expected[1])) problems.push(`expected ${JSON.stringify(expected[1])} in ${JSON.stringify(printed.slice(0, 80))}`); }
    else {
      if (tohost !== model.csr.tohost) problems.push(`TOHOST ${tohost}, model ${model.csr.tohost}`);
      if (printed !== model.output) problems.push(`output differs: ${JSON.stringify(printed.slice(0, 60))} vs model ${JSON.stringify(model.output.slice(0, 60))}`);
      if (!readsDevices && Number(report[3]) !== model.stats.cycles) problems.push(`${report[3]} cycles, model ${model.stats.cycles}`);
    }
  }
  if (problems.length) failed++;
  console.log(`${problems.length ? 'FAIL' : 'PASS'} ${program.padEnd(36)} ${report ? `${report[1].padEnd(4)} ${report[3].padStart(7)} cycles ${expected ? `(typed input; printed ${JSON.stringify(expected[1])})` : readsDevices ? '(waits on the clock rate: longer than the model, on purpose)' : '= model'}` : ''}${problems.length ? '  ' + problems.join('; ') : ''}`);
}
console.log(`\n${programs.length - failed} passed, ${failed} failed (the FPGA system, over its UART, against the model)`);
process.exit(failed ? 1 : 0);
