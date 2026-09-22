#!/usr/bin/env node
// =============================================================================
// tools/verify_math.mjs — check the pipeline performance equation against
// the cycle-accurate model for every program, predictor on and off:
//
//     cycles = N + (S - 1) + L + P * M
//
//   N = instructions retired        S = 6 pipeline stages (fill/drain)
//   L = load-use stall cycles       P = 3 (branch resolves in stage 4 of 6)
//   M = mispredictions (redirects)
//
// and therefore CPI = cycles / N = 1 + (S-1)/N + L/N + P*M/N.
// See docs/MATH.md for the derivation.
// =============================================================================
import fs from 'node:fs';
import { assemble } from '../sim/asm.js';
import { Core } from '../sim/core.js';
const S = 6, P = 3;
let bad = 0;
console.log('program                         bp      N      L      M   predicted   measured   CPI');
for (const f of ['programs', 'tests'].flatMap(d => fs.readdirSync(d).filter(x => x.endsWith('.s')).sort().map(x => `${d}/${x}`))) {
  const img = assemble(fs.readFileSync(f, 'utf8'));
  for (const bp of [true, false]) {
    const c = new Core(img.bytes, { bp }); c.run(5e6, false);
    const { retired: N, loadUseStalls: L, mispredicts: M, cycles } = c.stats;
    const pred = N + (S - 1) + L + P * M;
    const ok = pred === cycles; if (!ok) bad++;
    console.log(`${f.replace(/^.*\//, '').padEnd(30)} ${bp ? 'on ' : 'off'} ${String(N).padStart(6)} ${String(L).padStart(6)} ${String(M).padStart(6)} ${String(pred).padStart(11)} ${String(cycles).padStart(10)}  ${(cycles / N).toFixed(3)} ${ok ? '✓' : '✗ MISMATCH'}`);
  }
}
console.log(bad ? `\n${bad} mismatches` : '\nThe equation holds exactly for every program.');
process.exit(bad ? 1 : 0);
