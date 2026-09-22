// =============================================================================
// web/app.js — interactive front end for sim/core.js (the cycle-exact model
// that the Verilog RTL is regression-tested against).
// =============================================================================
import { assemble } from '../sim/asm.js';
import { Core, STAGES, GHR_BITS } from '../sim/core.js';
import { decode, disasm, FORMATS, ABI } from '../sim/isa.js';
import { PROGRAMS } from './programs.js';

const $ = id => document.getElementById(id);
const STAGE_INFO = {
  IF: 'fetch + predict', ID: 'decode', RR: 'register read', EX: 'execute', MEM: 'memory', WB: 'write back',
};
const hex = (v, n = 4) => '0x' + v.toString(16).padStart(n, '0');
const hex64 = v => '0x' + v.toString(16).padStart(16, '0');
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;');

let img = null, core = null, events = [], timer = null, selAddr = null;

// ------------------------------------------------------------------ loading
function loadSource(src) {
  try {
    img = assemble(src);
    $('asmerr').textContent = '';
    $('src').value = src;
    reset();
    return true;
  } catch (e) { $('asmerr').textContent = e.message; return false; }
}
function reset() {
  stop();
  core = new Core(img.bytes, { bp: $('bp').checked });
  events = [];
  render();
}
function step() {
  if (!core || core.halted) { stop(); return; }
  events.push(core.step());
  render();
}
function back() {
  if (!events.length) return;
  const target = events.length - 1;
  stop();
  core = new Core(img.bytes, { bp: $('bp').checked });
  events = [];
  while (events.length < target) events.push(core.step());
  render();
}
function run() {
  if (timer) { stop(); return; }
  $('run').textContent = 'Pause';
  const tick = () => {
    const perFrame = Math.max(1, Math.round(Number($('speed').value) / 8));
    for (let i = 0; i < perFrame && !core.halted; i++) events.push(core.step());
    render();
    if (core.halted) stop();
  };
  timer = setInterval(tick, Math.max(16, 400 / Number($('speed').value)));
}
function stop() { if (timer) clearInterval(timer); timer = null; $('run').textContent = 'Run'; }

// ------------------------------------------------------------------ render
function render() {
  const ev = events[events.length - 1] || null;
  const prev = events[events.length - 2] || null;
  $('cycle').textContent = ev ? ev.cycle : 0;
  const st = $('status');
  st.className = 'status';
  if (!ev) st.textContent = 'reset: pipeline empty, PC = 0x0000';
  else if (ev.halt) { st.textContent = `halted: ${core.illegal ? 'illegal instruction' : 'ecall reached WB'}`; st.classList.add('halt'); }
  else if (ev.stall) { st.textContent = 'load-use stall'; st.classList.add('stall'); }
  else if (ev.redirect !== undefined) { st.textContent = 'misprediction: flushing IF, ID, RR'; st.classList.add('flush'); }
  else if (ev.haltEx) { st.textContent = 'halt instruction in EX: stop fetching'; st.classList.add('flush'); }
  else st.textContent = '';
  renderStages(ev, prev);
  renderNarration(ev);
  renderChart();
  renderListing(ev);
  renderRegs(ev);
  renderPredictor(ev);
  renderStats();
  $('output').textContent = core.output || '(nothing printed yet — programs print by storing a byte to 0x10000000)';
}

function renderStages(ev, prev) {
  const flushing = ev && (ev.redirect !== undefined || ev.haltEx);
  $('stages').innerHTML = STAGES.map(s => {
    const x = ev && ev.stages[s];
    let body;
    if (!x) body = `<div class="empty">${ev ? 'bubble' : 'empty'}</div>`;
    else {
      const entered = !prev || !prev.stages[s] || prev.stages[s].id !== x.id;
      const tags = [];
      const stalled = ev.stall && ['IF', 'ID', 'RR'].includes(s);
      if (stalled) tags.push('<span class="tag stall">stalled</span>');
      if (s === 'IF' && ev.predict) tags.push(ev.predict.taken ? `<span class="tag pred">predict taken → ${hex(ev.predict.target)}</span>` : `<span class="tag pred">predict pc+4${ev.predict.hit ? '' : ' (BTB miss)'}</span>`);
      if (s === 'EX') {
        if (ev.fwd.a) tags.push(`<span class="tag fwd">rs1 ← ${ev.fwd.a === 'MEM' ? 'EX/MEM' : 'MEM/WB'}</span>`);
        if (ev.fwd.b) tags.push(`<span class="tag fwd">rs2 ← ${ev.fwd.b === 'MEM' ? 'EX/MEM' : 'MEM/WB'}</span>`);
        if (ev.resolve) tags.push(ev.resolve.mispredict ? '<span class="tag miss">mispredicted</span>' : '<span class="tag ok">prediction correct</span>');
      }
      if (s === 'MEM' && ev.memAccess) tags.push(`<span class="tag ok">${ev.memAccess.kind} ${hex(Number(ev.memAccess.addr & 0xffffffffn))}</span>`);
      if (s === 'WB' && ev.rfWrite) tags.push(`<span class="tag ok">${ABI[ev.rfWrite.rd]} ← ${BigInt.asIntN(64, ev.rfWrite.value)}</span>`);
      if (flushing && ['IF', 'ID', 'RR'].includes(s)) tags.push('<span class="tag miss">flushed at clock edge</span>');
      body = `<div class="chip${entered ? ' enter' : ''}${stalled ? ' stalled' : ''}" style="background:var(--${s})${flushing && ['IF', 'ID', 'RR'].includes(s) ? ';opacity:.5' : ''}">
        <div class="pc">${hex(x.pc)}</div>${esc(x.text || '')}</div><div class="tags">${tags.join('')}</div>`;
    }
    return `<div class="stage"><h3>${s} <small>${STAGE_INFO[s]}</small></h3><div class="bar" style="background:var(--${s})"></div>${body}</div>`;
  }).join('');
}

function renderNarration(ev) {
  const L = [];
  if (!ev) { L.push('Press <b>Step</b> to clock the pipeline. In cycle 1 the first instruction is fetched from address 0x0000.'); }
  else {
    const S = ev.stages;
    if (S.IF) L.push(`<b>IF</b> fetch ${hex(S.IF.pc)} <b>${esc(S.IF.text)}</b>. gshare index ${ev.predict.idx} (counter ${ev.predict.counter}), BTB ${ev.predict.hit ? 'hit' : 'miss'}: next PC ${ev.predict.taken ? hex(ev.predict.target) + ' (predicted taken)' : 'PC+4'}.`);
    else L.push('<b>IF</b> fetch stopped (a halt instruction is in flight).');
    if (S.ID) L.push(`<b>ID</b> decode ${esc(S.ID.text)} into control signals and an immediate.`);
    if (S.RR) L.push(`<b>RR</b> read source registers of ${esc(S.RR.text)}.`);
    if (S.EX) {
      L.push(`<b>EX</b> ${esc(S.EX.text)}: ALU(${BigInt.asIntN(64, ev.alu.a)}, ${BigInt.asIntN(64, ev.alu.b)}) = ${BigInt.asIntN(64, ev.alu.result)}.`);
      if (ev.fwd.a || ev.fwd.b) L.push(`<b>FWD</b> ${[ev.fwd.a && `rs1 from ${ev.fwd.a === 'MEM' ? 'EX/MEM (1 instruction ahead)' : 'MEM/WB (2 ahead)'}`, ev.fwd.b && `rs2 from ${ev.fwd.b === 'MEM' ? 'EX/MEM (1 ahead)' : 'MEM/WB (2 ahead)'}`].filter(Boolean).join(', ')}: no stall needed.`);
      if (ev.resolve) L.push(`<b>BRANCH</b> predicted ${ev.resolve.predicted ? 'taken' : 'not taken'}, actually ${ev.resolve.actual ? 'taken to ' + hex(ev.resolve.target) : 'not taken'}: ${ev.resolve.mispredict ? '<b>mispredict</b>, 3 younger instructions are thrown away.' : 'correct, no penalty.'}`);
      if (ev.bpUpdate && ev.bpUpdate.counter) L.push(`<b>BP</b> counter[${ev.bpUpdate.idx}] ${ev.bpUpdate.counter[0]} → ${ev.bpUpdate.counter[1]}; history shifts in ${ev.bpUpdate.taken ? 1 : 0}.`);
    }
    if (ev.memAccess) L.push(`<b>MEM</b> ${ev.memAccess.kind} ${ev.memAccess.size} byte(s) at ${hex(Number(ev.memAccess.addr & 0xffffffffn))}: ${BigInt.asIntN(64, ev.memAccess.value)}.`);
    if (ev.rfWrite) L.push(`<b>WB</b> x${ev.rfWrite.rd} (${ABI[ev.rfWrite.rd]}) ← ${hex64(ev.rfWrite.value)}.`);
    if (ev.stall) L.push('<b>HAZARD</b> RR needs the value a load in EX has not read yet: hold IF, ID, RR and send a bubble into EX.');
    if (ev.halt) L.push('<b>HALT</b> ecall/ebreak reached write-back. The program is finished.');
  }
  $('narration').innerHTML = L.map(x => `<li>${x}</li>`).join('');
}

function renderChart() {
  const N = 26;
  const last = events.length, first = Math.max(1, last - N + 1);
  const win = events.slice(first - 1, last);
  const rows = new Map();
  for (const ev of win) for (const s of STAGES) {
    const x = ev.stages[s]; if (!x) continue;
    if (!rows.has(x.id)) rows.set(x.id, { pc: x.pc, text: x.text, cells: {} });
    const r = rows.get(x.id); if (!r.text && x.text) r.text = x.text;
    r.cells[ev.cycle] = { s, st: ev.stall && ['IF', 'ID', 'RR'].includes(s), fw: s === 'EX' && (ev.fwd.a || ev.fwd.b) };
  }
  const ids = [...rows.keys()].sort((a, b) => a - b).slice(-18);
  let h = '<tr><th></th>';
  for (let c = first; c <= Math.max(last, first + N - 1); c++) h += `<th>${c}</th>`;
  h += '</tr>';
  for (const id of ids) {
    const r = rows.get(id), sq = core.instrs[id]?.squashed;
    h += `<tr><td class="label${sq ? ' sq' : ''}">${hex(r.pc)} ${esc((r.text || '').slice(0, 24))}</td>`;
    for (let c = first; c <= Math.max(last, first + N - 1); c++) {
      const cell = r.cells[c];
      h += cell ? `<td class="c${sq ? ' sq' : ''}${cell.st ? ' st' : ''}${cell.fw ? ' fw' : ''}${c === last ? ' now' : ''}" style="background:var(--${cell.s})">${cell.s}</td>` : '<td></td>';
    }
    h += '</tr>';
  }
  h += '<tr class="hz"><td class="label" style="color:var(--sub)">hazard unit</td>';
  for (let c = first; c <= Math.max(last, first + N - 1); c++) {
    const ev = events[c - 1];
    h += !ev ? '<td></td>' : ev.stall ? '<td style="background:var(--stall)">stall</td>' : (ev.redirect !== undefined || ev.haltEx) ? '<td style="background:var(--redirect)">flush</td>' : '<td></td>';
  }
  $('chart').innerHTML = h + '</tr>';
}

const FIELD_CLASS = n => { const k = n.split('[')[0]; return ['opcode', 'rd', 'rs1', 'rs2', 'funct3', 'funct7'].includes(k) ? 'f-' + k : (k === 'funct6' || k === 'funct12' ? 'f-funct7' : 'f-imm'); };
function binFields(word) {
  const d = decode(word);
  const b = word.toString(2).padStart(32, '0');
  if (!d.def) return { d, html: `<span>${b}</span>` };
  return { d, parts: FORMATS[d.fmt].map(([n, hi, lo]) => ({ n, bits: b.slice(31 - hi, 32 - lo), cls: FIELD_CLASS(n) })),
    html: FORMATS[d.fmt].map(([n, hi, lo]) => `<span class="${FIELD_CLASS(n)}">${b.slice(31 - hi, 32 - lo)}</span>`).join(' ') };
}
function renderListing(ev) {
  const at = {};
  if (ev) for (const s of STAGES) if (ev.stages[s]) (at[ev.stages[s].pc] ??= []).push(s);
  const rows = img.listing.filter(l => l.word !== undefined);
  $('listing').innerHTML = rows.map(l => {
    const stg = at[l.addr] || [];
    const border = stg.length ? `border-left-color:var(--${stg[stg.length - 1]})` : '';
    return `<tr data-addr="${l.addr}" class="${selAddr === l.addr ? 'sel' : ''}" style="${border}">
      <td class="addr">${hex(l.addr)}</td><td>${stg.map(s => `<span class="stg" style="background:var(--${s})">${s}</span>`).join(' ')}</td>
      <td class="bin">${binFields(l.word).html}</td><td class="src">${esc(l.src)}</td></tr>`;
  }).join('');
  const sel = rows.find(l => l.addr === selAddr) || null;
  if (!sel) { $('bits').innerHTML = '<p class="hint">Click an instruction to see its 32-bit encoding field by field.</p>'; return; }
  const { d, parts } = binFields(sel.word);
  $('bits').innerHTML = d.def ? `<b>${esc(disasm(d, sel.addr))}</b> — ${esc(d.def.desc)} (${d.fmt}-type) = <code>0x${sel.word.toString(16).padStart(8, '0')}</code>
    <div class="fields">${parts.map(p => `<div class="fld ${p.cls}">${p.bits}<small>${p.n}</small></div>`).join('')}</div>
    <code>${esc(d.def.sem)}</code>` : 'not an instruction';
}

function renderRegs(ev) {
  const w = ev && ev.rfWrite ? ev.rfWrite.rd : -1;
  $('regs').innerHTML = core.regs.map((v, i) =>
    `<div class="${i === w ? 'w' : ''}"><span class="n">x${i} ${ABI[i]}</span><span class="${v === 0n ? 'z' : ''}">${v === 0n ? '0' : hex64(v)}</span></div>`).join('');
}

function renderPredictor(ev) {
  const bp = core.bp;
  const g = [];
  for (let i = GHR_BITS - 1; i >= 0; i--) { const t = (bp.ghr >> i) & 1; g.push(`<span class="${t ? 't' : ''}">${t}</span>`); }
  $('ghr').innerHTML = g.join('');
  const rd = ev && ev.predict ? ev.predict.idx : -1, up = ev && ev.bpUpdate && ev.bpUpdate.counter ? ev.bpUpdate.idx : -1;
  let h = '';
  for (let i = 0; i < bp.pht.length; i++) h += `<i class="s${bp.pht[i]}${i === rd ? ' rd' : ''}${i === up ? ' up' : ''}" title="index ${i}: ${bp.pht[i].toString(2).padStart(2, '0')}"></i>`;
  $('pht').innerHTML = h;
  const valid = bp.btb.map((e, i) => ({ ...e, i })).filter(e => e.valid);
  $('btb').innerHTML = valid.length ? '<tr><th>slot</th><th>branch PC</th><th>target</th><th>kind</th></tr>' + valid.map(e =>
    `<tr><td>${e.i}</td><td>${hex((e.tag << 7) | (e.i << 2))}</td><td>${hex(e.target)}</td><td>${e.jump ? 'jump' : 'branch'}</td></tr>`).join('')
    : '<tr><td class="hint">empty: no taken branch has resolved yet</td></tr>';
}

function renderStats() {
  const s = core.stats, n = s.branches + s.jumps;
  const items = [
    ['cycles', s.cycles, true], ['instructions retired', s.retired], ['CPI', s.retired ? (s.cycles / s.retired).toFixed(3) : '—', true],
    ['load-use stalls', s.loadUseStalls], ['branches / jumps', `${s.branches} / ${s.jumps}`], ['mispredictions', s.mispredicts],
    ['prediction accuracy', n ? (100 * (1 - s.mispredicts / n)).toFixed(1) + '%' : '—'], ['operands forwarded', s.forwards],
  ];
  if (core.halted) {
    const pred = s.retired + 5 + s.loadUseStalls + 3 * s.mispredicts;
    items.push(['equation check', `${s.retired} + 5 + ${s.loadUseStalls} + 3×${s.mispredicts} = ${pred} ${pred === s.cycles ? '✓' : '✗'}`]);
  }
  $('stats').innerHTML = items.map(([k, v, big]) => `<dt>${k}</dt><dd class="${big ? 'big' : ''}">${v}</dd>`).join('');
}

// ------------------------------------------------------------------ wiring
const sel = $('prog');
for (const name of Object.keys(PROGRAMS)) sel.add(new Option(name.replace(/_/g, ' '), name));
sel.value = '11_gshare_patterns' in PROGRAMS ? '03_load_use' : Object.keys(PROGRAMS)[0];
sel.onchange = () => loadSource(PROGRAMS[sel.value]);
$('step').onclick = step;
$('back').onclick = back;
$('run').onclick = run;
$('reset').onclick = reset;
$('bp').onchange = reset;
$('assemble').onclick = () => { if (loadSource($('src').value)) switchTab('listing'); };
$('listing').onclick = e => { const tr = e.target.closest('tr'); if (tr) { selAddr = Number(tr.dataset.addr); render(); } };
function switchTab(t) {
  document.querySelectorAll('.tabs button').forEach(b => b.setAttribute('aria-selected', String(b.dataset.tab === t)));
  $('tab-listing').hidden = t !== 'listing'; $('tab-edit').hidden = t !== 'edit';
}
document.querySelectorAll('.tabs button').forEach(b => { b.onclick = () => switchTab(b.dataset.tab); });
document.addEventListener('keydown', e => {
  if (e.target.matches('textarea, input, select')) return;
  if (e.key === 'ArrowRight' || e.key === ' ') { e.preventDefault(); step(); }
  else if (e.key === 'ArrowLeft') back();
  else if (e.key === 'r' || e.key === 'R') run();
});
loadSource(PROGRAMS[sel.value]);
