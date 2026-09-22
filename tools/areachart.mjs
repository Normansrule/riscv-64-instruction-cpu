#!/usr/bin/env node
// tools/areachart.mjs — docs/img/silicon_gate_budget.svg from docs/synth_stat.txt
// (Yosys generic-gate counts: a proxy for area, NOT a real layout.)
import fs from 'node:fs';
const txt = fs.readFileSync('docs/synth_stat.txt', 'utf8');
const counts = {};
for (const m of txt.matchAll(/=== (?:\$paramod\S*\\)?(\w+) ===[\s\S]*?Number of cells:\s+(\d+)/g)) if (m[1] !== 'design') counts[m[1]] = +m[2];
const total = Object.values(counts).reduce((a, b) => a + b, 0);
const NICE = { alu: 'ALU (64-bit add/shift/compare + single-cycle mul/div)', branch_predictor: 'gshare predictor + BTB', regfile: 'Register file (31 x 64 flip-flops + read muxes)',
  rv64_core: 'Pipeline registers + forwarding/PC muxes', branch_unit: 'Branch unit', imm_gen: 'Immediate generator', decoder: 'Decoder', hazard_unit: 'Hazard unit', forward_unit: 'Forward units' };
const COLORS = { alu: '#E08E0B', branch_predictor: '#138A8A', regfile: '#9B59B6', rv64_core: '#5B6472', branch_unit: '#C2185B', imm_gen: '#6A5ACD', decoder: '#3C8DBC', hazard_unit: '#B8860B', forward_unit: '#E07B00' };
const rows = Object.entries(counts).sort((a, b) => b[1] - a[1]);
const W = 900, x0 = 20, bw = W - 40, top = 70;
let s = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${top + 60 + rows.length * 26 + 40}" width="${W}"><rect width="100%" height="100%" rx="10" fill="#FBFCF8" stroke="#D5DBD0"/>`;
const F = "font-family=\"'IBM Plex Sans',Helvetica,Arial,sans-serif\"";
s += `<text x="20" y="28" ${F} font-size="17" font-weight="600" fill="#17251D">Where the gates go: Yosys synthesis of rv64_core (${total.toLocaleString('en-US')} generic cells)</text>`;
s += `<text x="20" y="48" ${F} font-size="12" fill="#4A5A50">Generic gate count is a rough proxy for silicon area. Memories are excluded. Regenerate: yosys -s tools/synth.ys; node tools/areachart.mjs</text>`;
let x = x0;
for (const [k, v] of rows) { const w = bw * v / total; s += `<rect x="${x}" y="${top}" width="${Math.max(w, 1)}" height="44" fill="${COLORS[k] || '#999'}"/>`; if (w > 60) s += `<text x="${x + 8}" y="${top + 27}" ${F} font-size="12" font-weight="700" fill="#fff">${k} ${(100 * v / total).toFixed(1)}%</text>`; x += w; }
rows.forEach(([k, v], i) => {
  const y = top + 76 + i * 26;
  s += `<rect x="20" y="${y - 12}" width="14" height="14" rx="2" fill="${COLORS[k] || '#999'}"/>`;
  s += `<text x="42" y="${y}" ${F} font-size="12.5" fill="#17251D">${NICE[k] || k}</text>`;
  s += `<text x="${W - 150}" y="${y}" ${F} font-size="12.5" fill="#17251D" text-anchor="end">${v.toLocaleString('en-US')}</text>`;
  s += `<text x="${W - 30}" y="${y}" ${F} font-size="12.5" fill="#4A5A50" text-anchor="end">${(100 * v / total).toFixed(1)}%</text>`;
});
fs.writeFileSync('docs/img/silicon_gate_budget.svg', s + '</svg>\n');
console.log('docs/img/silicon_gate_budget.svg', total, 'cells');
