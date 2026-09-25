#!/usr/bin/env node
// =============================================================================
// tools/verify_math.mjs: checks the timing equation of docs/MATH.md on every program.
//
//   cycles = N + (S - 1) + L + P_flush * F + R_eff
//
//   N       instructions retired
//   S - 1   = 5 pipeline-fill cycles (6 stages)
//   L       load stalls (1 bubble each: the NOP sent into EXECUTE)
//   F       flushes from EXECUTE (wrong branch guesses + every JALR), P_flush = 3
//           bubbles each (FETCH1, FETCH2 and DECODE are squashed)
//   R_eff   FETCH2 redirects whose 1 bubble survived (a redirect bubble that is
//           itself flushed a cycle later is already counted inside that flush)
//
// Every bubble that reaches WRITEBACK is tagged with the event that created it
// (model/core.js), so the equation must hold EXACTLY, not approximately.
// =============================================================================
import fs from 'node:fs';
import { assemble } from '../model/asm.js';
import { Core } from '../model/core.js';

const S = 6, P_FLUSH = 3;
let bad = 0;
console.log('program                          predictor    cycles =    N + 5 +    L + 3*F    + R_eff   check');
for (const dir of ['programs', 'tests']) {
  for (const f of fs.readdirSync(dir).filter(x => x.endsWith('.s')).sort()) {
    const img = assemble(fs.readFileSync(`${dir}/${f}`, 'utf8'));
    for (const bp of [true, false]) {
      const c = new Core(img, { bp }); c.run(5e6, false);
      const s = c.stats, b = s.bubbles;
      const F = s.flushes, L = s.loadStalls, R = b.redirect;
      const predicted = s.retired + (S - 1) + L + P_FLUSH * F + R;
      const ok = predicted === s.cycles && b.flush === P_FLUSH * F && b.loaduse === L && b.fill === S - 1 && R <= s.redirects;
      if (!ok) bad++;
      console.log(`${f.padEnd(32)} ${(bp ? 'gshare' : 'off').padEnd(9)} ${String(s.cycles).padStart(8)} = ${String(s.retired).padStart(5)} + 5 + ${String(L).padStart(4)} + 3*${String(F).padEnd(4)} + ${String(R).padStart(5)}   ${ok ? 'OK' : 'MISMATCH (' + predicted + ')'}`);
    }
  }
}
console.log(bad ? `\n${bad} mismatches` : '\nthe equation holds exactly for every program in both predictor modes');
process.exit(bad ? 1 : 0);
