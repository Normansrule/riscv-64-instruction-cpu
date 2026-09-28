#!/usr/bin/env node
// =============================================================================
// tools/perf_report.mjs: measures every program on both builds and writes
//   docs/img/charts/performance.svg      CPI of each program, original vs performance edition
//   docs/img/charts/performance_table.md the numbers (included in docs/PERFORMANCE.md)
// Clock rates come from `make timing` (logic-only, sky130 typical corner); see docs/PERFORMANCE.md.
// =============================================================================
import fs from 'node:fs';
import { assemble } from '../model/asm.js';
import { Core, CONFIGS } from '../model/core.js';

export const CLOCK = { baselineWithM: 7.5, performance: 265, performance7nm: 1917 }; // MHz, logic only, from tools/timing.sh (sky130, and asap7 for the 7 nm column)
const FONT = "font-family=\"'IBM Plex Sans','Segoe UI',Helvetica,Arial,sans-serif\"";
const MONO = "font-family=\"'IBM Plex Mono',Consolas,monospace\"";
const rows = [];
for (const dir of ['programs', 'tests']) for (const f of fs.readdirSync(dir).filter(x => x.endsWith('.s')).sort()) {
  const src = fs.readFileSync(`${dir}/${f}`, 'utf8'), img = assemble(src);
  const r = {};
  for (const cfg of ['baseline', 'performance']) { const c = new Core(img, { ...CONFIGS[cfg], bp: true }); c.run(5e6, false); r[cfg] = c.stats; }
  const usesM = /\b(mul|mulh|mulhsu|mulhu|div|divu|rem|remu)w?\b/.test(src.replace(/#.*$/gm, ''));
  rows.push({ name: f.replace('.s', ''), usesM, base: r.baseline, perf: r.performance });
}
const cpi = s => s.cycles / s.retired;
let md = `| program | M ops | baseline: cycles | CPI | performance: cycles | CPI | time, baseline 130 nm (${CLOCK.baselineWithM} MHz) | time, performance 130 nm (${CLOCK.performance} MHz) | time, performance 7 nm (${(CLOCK.performance7nm / 1000).toFixed(2)} GHz) |\n|---|:-:|---:|---:|---:|---:|---:|---:|---:|\n`;
let geo = 0;
for (const r of rows) {
  const tb = r.base.cycles / CLOCK.baselineWithM, tp = r.perf.cycles / CLOCK.performance;
  geo += Math.log(tb / tp);
  md += `| \`${r.name}\` | ${r.usesM ? 'yes' : ''} | ${r.base.cycles.toLocaleString('en-US')} | ${cpi(r.base).toFixed(2)} | ${r.perf.cycles.toLocaleString('en-US')} | **${cpi(r.perf).toFixed(2)}** | ${tb.toFixed(1)} µs | ${tp.toFixed(2)} µs | ${(r.perf.cycles / CLOCK.performance7nm).toFixed(2)} µs |\n`;
}
md += `\nGeometric-mean speed-up of the performance edition over the baseline, both on 130 nm: **${Math.exp(geo / rows.length).toFixed(1)}x** (clock and cycles together). Cache misses are included: these programs are tiny, so their few cold misses weigh heavily.\n`;
fs.mkdirSync('docs/img/charts', { recursive: true });
fs.writeFileSync('docs/img/charts/performance_table.md', md);

// chart: CPI per program, two bars each
const W = 980, top = 76, rh = 30, lx = 230, bw = 560, H = top + rows.length * rh + 60, max = 3.5;
let o = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}"><rect width="100%" height="100%" rx="10" fill="#FBFCF8" stroke="#D5DBD0"/>`;
o += `<text x="16" y="28" ${FONT} font-size="17" font-weight="600" fill="#17251D">Cycles per instruction: baseline vs performance edition (predictor on, caches included)</text>`;
o += `<text x="16" y="48" ${FONT} font-size="12" fill="#4A5A50">Grey: baseline build. Blue: caches + tournament predictor + BTB + return address stack + precise load stalls + iterative M unit. The ideal is 1.0.</text>`;
const X = v => lx + bw * Math.min(v, max) / max;
for (let v = 0; v <= max; v += 0.5) o += `<line x1="${X(v)}" x2="${X(v)}" y1="${top - 8}" y2="${top + rows.length * rh}" stroke="${v === 1 ? '#17251D' : '#E3E8DF'}"${v === 1 ? ' stroke-dasharray="4 3"' : ''}/><text x="${X(v)}" y="${top - 12}" ${MONO} font-size="10" fill="#6B7A70" text-anchor="middle">${v.toFixed(1)}</text>`;
rows.forEach((r, i) => {
  const y = top + i * rh;
  o += `<text x="${lx - 10}" y="${y + 18}" ${MONO} font-size="11.5" fill="#17251D" text-anchor="end">${r.name}${r.usesM ? ' *' : ''}</text>`;
  o += `<rect x="${lx}" y="${y + 4}" width="${X(cpi(r.base)) - lx}" height="10" rx="2" fill="#B4BDB6"/>`;
  o += `<rect x="${lx}" y="${y + 15}" width="${X(cpi(r.perf)) - lx}" height="10" rx="2" fill="#2E86C1"/>`;
  o += `<text x="${X(Math.max(cpi(r.base), cpi(r.perf))) + 6}" y="${y + 19}" ${MONO} font-size="10.5" fill="#4A5A50">${cpi(r.base).toFixed(2)} → ${cpi(r.perf).toFixed(2)}${cpi(r.perf) > max ? ' (off scale)' : ''}</text>`;
});
o += `<text x="16" y="${H - 18}" ${FONT} font-size="11.5" fill="#4A5A50">* uses multiply or divide: slower per instruction on the performance edition (8 cycles per multiply, 4 + dividend bits per divide), in exchange for a ~27x faster clock. Cold cache misses weigh heavily on the shortest programs.</text></svg>\n`;
fs.writeFileSync('docs/img/charts/performance.svg', o);
console.log(md);
