// prints the README results table from the model (node tools/readme_table.mjs)
import fs from 'node:fs';
import { assemble } from '../model/asm.js';
import { Core } from '../model/core.js';
console.log('| program | what it shows | cycles (gshare) | CPI | cycles (predictor off) | CPI |\n|---|---|---:|---:|---:|---:|');
for (const f of fs.readdirSync('programs').filter(x => x.endsWith('.s')).sort()) {
  const src = fs.readFileSync('programs/' + f, 'utf8');
  const what = (src.split('\n')[1].split(': ')[1] || '').trim();
  const img = assemble(src);
  const r = [true, false].map(bp => { const c = new Core(img, { bp }); c.run(5e6, false); return c.stats; });
  console.log(`| [\`${f.replace('.s', '')}\`](programs/${f}) | ${what} | ${r[0].cycles} | ${(r[0].cycles / r[0].retired).toFixed(2)} | ${r[1].cycles} | ${(r[1].cycles / r[1].retired).toFixed(2)} |`);
}
