#!/usr/bin/env node
// =============================================================================
// tools/charts.mjs: performance charts measured on the cycle-exact model
//
//   docs/img/charts/cpi_stack.svg        where every cycle of every program goes
//   docs/img/charts/predictor_sweep.svg  branch accuracy vs gshare history length
//   docs/img/charts/predictor_sweep.md   the same numbers as a table
// =============================================================================
import fs from 'node:fs';
import { assemble } from '../model/asm.js';
import { Core, DEFAULT_HISTORY_BITS } from '../model/core.js';

const FONT = "font-family=\"'IBM Plex Sans','Segoe UI',Helvetica,Arial,sans-serif\"";
const MONO = "font-family=\"'IBM Plex Mono',Consolas,monospace\"";
const W = (p, s) => { fs.mkdirSync('docs/img/charts', { recursive: true }); fs.writeFileSync(p, s); };
const progs = fs.readdirSync('programs').filter(f => f.endsWith('.s')).sort();
const load = f => assemble(fs.readFileSync(`programs/${f}`, 'utf8'));
const run = (img, o) => { const c = new Core(img, o); c.run(5e6, false); return c.stats; };

// ---------------------------------------------------------------- CPI stack
const parts = [['retired', 'instructions (CPI 1.0 part)', '#2E86C1'], ['fill', 'pipeline fill (5)', '#B4BDB6'], ['loaduse', 'load stalls', '#E0A800'],
  ['flush', 'flushes: wrong guess or JALR (3 each)', '#C2185B'], ['redirect', 'FETCH2 redirects (1 each)', '#17A2B8']];
{
  const rows = [];
  for (const f of progs) for (const bp of [true, false]) { const s = run(load(f), { bp }); rows.push({ name: f.replace('.s', ''), bp, s }); }
  const lx = 250, bw = 560, rh = 17, top = 70, width = lx + bw + 170, height = top + rows.length * rh + (rows.length / 2) * 6 + 70;
  let o = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}"><rect width="100%" height="100%" rx="10" fill="#FBFCF8" stroke="#D5DBD0"/>`;
  o += `<text x="16" y="28" ${FONT} font-size="17" font-weight="600" fill="#17251D">Where the cycles go: CPI stack of every program (gshare on / predictor off)</text>`;
  o += `<text x="16" y="48" ${FONT} font-size="12" fill="#4A5A50">Each bar is 100% of the program's cycles. Blue is useful work; every other colour is a bubble, tagged by the event that created it.</text>`;
  let y = top;
  rows.forEach((r, i) => {
    const total = r.s.cycles, vals = { retired: r.s.retired, ...r.s.bubbles };
    if (i % 2 === 0) { y += 6; o += `<text x="16" y="${y + rh + 4}" ${MONO} font-size="11.5" fill="#17251D">${r.name}</text>`; }
    o += `<text x="${lx - 8}" y="${y + 12}" ${FONT} font-size="10" fill="#6B7A70" text-anchor="end">${r.bp ? 'gshare' : 'off'}</text>`;
    let x = lx;
    for (const [k, , col] of parts) { const w = bw * vals[k] / total; o += `<rect x="${x}" y="${y + 1}" width="${Math.max(0, w)}" height="${rh - 3}" fill="${col}"/>`; x += w; }
    o += `<text x="${lx + bw + 8}" y="${y + 12}" ${MONO} font-size="10.5" fill="#17251D">CPI ${(total / r.s.retired).toFixed(2)}  (${total})</text>`;
    y += rh;
  });
  let lxp = 16; y += 22;
  for (const [, lab, col] of parts) { o += `<rect x="${lxp}" y="${y - 10}" width="14" height="12" fill="${col}"/><text x="${lxp + 19}" y="${y}" ${FONT} font-size="11" fill="#4A5A50">${lab}</text>`; lxp += 30 + lab.length * 6.2; }
  W('docs/img/charts/cpi_stack.svg', o + '</svg>\n');
}

// ---------------------------------------------------------------- predictor sweep
{
  const pick = ['04_branch_penalty.s', '06_bubble_sort.s', '09_primes_sieve.s', '10_print_numbers.s', '11_gshare_patterns.s'];
  const cols = ['#2E86C1', '#C2185B', '#27AE60', '#E08E0B', '#6A5ACD'];
  const H = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  const data = pick.map(f => H.map(h => { const s = run(load(f), h ? { bp: true, historyBits: h } : { bp: false }); return { acc: s.branches ? 1 - s.mispredicts / s.branches : 1, cpi: s.cycles / s.retired, cycles: s.cycles }; }));
  const px = 70, py = 70, pw = 620, ph = 300, width = px + pw + 250, height = py + ph + 80;
  const X = h => px + pw * h / 12, Y = a => py + ph * (1 - a);
  let o = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}"><rect width="100%" height="100%" rx="10" fill="#FBFCF8" stroke="#D5DBD0"/>`;
  o += `<text x="16" y="28" ${FONT} font-size="17" font-weight="600" fill="#17251D">Branch prediction accuracy vs gshare history length</text>`;
  o += `<text x="16" y="48" ${FONT} font-size="12" fill="#4A5A50">0 = predictor off (always not taken). The EECS 151 tape-out used 4 bits (16 counters). More is not always better on short programs.</text>`;
  for (let a = 0; a <= 1.0001; a += 0.2) o += `<line x1="${px}" x2="${px + pw}" y1="${Y(a)}" y2="${Y(a)}" stroke="#E3E8DF"/><text x="${px - 8}" y="${Y(a) + 4}" ${MONO} font-size="10.5" fill="#6B7A70" text-anchor="end">${Math.round(a * 100)}%</text>`;
  for (const h of H) o += `<text x="${X(h)}" y="${py + ph + 18}" ${MONO} font-size="10.5" fill="#6B7A70" text-anchor="middle">${h}</text>`;
  o += `<text x="${px + pw / 2}" y="${py + ph + 38}" ${FONT} font-size="11.5" fill="#4A5A50" text-anchor="middle">GSHARE_HISTORY_BITS (table has 2^bits counters)</text>`;
  o += `<line x1="${X(DEFAULT_HISTORY_BITS)}" x2="${X(DEFAULT_HISTORY_BITS)}" y1="${py}" y2="${py + ph}" stroke="#17251D" stroke-dasharray="4 4"/><text x="${X(DEFAULT_HISTORY_BITS) + 4}" y="${py + 12}" ${FONT} font-size="10.5" fill="#17251D">tape-out</text>`;
  data.forEach((d, i) => {
    o += `<polyline fill="none" stroke="${cols[i]}" stroke-width="2.4" points="${d.map((v, h) => `${X(h)},${Y(v.acc)}`).join(' ')}"/>`;
    d.forEach((v, h) => { o += `<circle cx="${X(h)}" cy="${Y(v.acc)}" r="3" fill="${cols[i]}"/>`; });
    o += `<rect x="${px + pw + 20}" y="${py + 10 + i * 24}" width="14" height="4" fill="${cols[i]}"/><text x="${px + pw + 40}" y="${py + 16 + i * 24}" ${MONO} font-size="11" fill="#17251D">${pick[i].replace('.s', '')}</text>`;
  });
  W('docs/img/charts/predictor_sweep.svg', o + '</svg>\n');
  let md = `# Predictor sweep (generated by tools/charts.mjs)\n\nCycles for each program with the predictor off (0) and with gshare using 1 to 12 history bits.\nBold = fastest.\n\n| program | ${H.map(h => (h ? h + ' bits' : 'off')).join(' | ')} |\n|---|${H.map(() => '---:').join('|')}|\n`;
  data.forEach((d, i) => { const best = Math.min(...d.map(v => v.cycles)); md += `| ${pick[i].replace('.s', '')} | ${d.map(v => (v.cycles === best ? `**${v.cycles}**` : v.cycles)).join(' | ')} |\n`; });
  W('docs/img/charts/predictor_sweep.md', md);
}
console.log('wrote docs/img/charts/{cpi_stack.svg,predictor_sweep.svg,predictor_sweep.md}');
