#!/usr/bin/env node
// =============================================================================
// tools/verify_math.mjs: checks the timing equation of docs/MATH.md on every program.
//
//   cycles = N + (S - 1) + L + P_flush * F + R_eff + K + I + D + X
//
//   N       instructions retired
//   S - 1   = 5 pipeline-fill cycles (6 stages)
//   L       load stalls (1 bubble each: the NOP sent into EXECUTE)
//   F       flushes from EXECUTE (wrong branch guesses + every JALR), P_flush = 3
//           bubbles each (FETCH1, FETCH2 and DECODE are squashed)
//   R_eff   FETCH2 redirects whose 1 bubble survived (a redirect bubble that is
//           itself flushed a cycle later is already counted inside that flush)
//   K       cycles an M instruction kept EXECUTE busy (performance build only: the
//           iterative multiply/divide unit), 1 bubble each
//   I       bubbles FETCH2 received while the instruction cache was refilling
//   D       cycles a load waited in EXECUTE for its data-cache line
//   X       interrupts taken: the pseudo-instruction that replaced a DECODE instruction never
//           retires, so each costs 1 bubble on top of its flush (which F already counts)
//
// Every bubble that reaches WRITEBACK is tagged with the event that created it
// (model/core.js), so the equation must hold EXACTLY, not approximately.
// =============================================================================
import fs from 'node:fs';
import { assemble } from '../model/asm.js';
import { Core, CONFIGS } from '../model/core.js';

const S = 6, P_FLUSH = 3;
let bad = 0;
console.log('program                         build predictor  cycles =     N + 5 +    L + 3*F    + R_eff +     K +     I +     D +    X   check');
for (const dir of ['programs', 'tests']) {
  for (const f of fs.readdirSync(dir).filter(x => x.endsWith('.s')).sort()) {
    const img = assemble(fs.readFileSync(`${dir}/${f}`, 'utf8'));
    for (const cfg of ['performance', 'baseline']) for (const bp of [true, false]) {
      const c = new Core(img, { ...CONFIGS[cfg], bp }); c.run(5e6, false);
      const s = c.stats, b = s.bubbles;
      const F = s.flushes, L = s.loadStalls, R = b.redirect, K = b.muldiv, I = b.imiss, D = b.dmiss, X = s.interrupts;
      const predicted = s.retired + (S - 1) + L + P_FLUSH * F + R + K + I + D + X;
      const ok = predicted === s.cycles && b.flush === P_FLUSH * F && b.loaduse === L && b.fill === S - 1 && R <= s.redirects && K === s.multiplyDivideBusy && b.interrupt === X;
      if (!ok) bad++;
      console.log(`${f.padEnd(31)} ${cfg.slice(0, 5).padEnd(5)} ${(bp ? 'gshare' : 'off').padEnd(9)} ${String(s.cycles).padStart(7)} = ${String(s.retired).padStart(5)} + 5 + ${String(L).padStart(4)} + 3*${String(F).padEnd(4)} + ${String(R).padStart(5)} + ${String(K).padStart(5)} + ${String(I).padStart(5)} + ${String(D).padStart(5)} + ${String(X).padStart(4)}   ${ok ? 'OK' : 'MISMATCH (' + predicted + ')'}`);
    }
  }
}
console.log(bad ? `\n${bad} mismatches` : '\nthe equation holds exactly for every program, both builds, both predictor modes');
process.exit(bad ? 1 : 0);
