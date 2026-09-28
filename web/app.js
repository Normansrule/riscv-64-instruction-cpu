// =============================================================================
// web/app.js: interactive front end for model/core.js, the cycle-exact twin of
// src/Riscv64.sv (the RTL is regression-tested against it every cycle).
// =============================================================================
import { assemble } from '../model/asm.js';
import { Core, STAGES, SHORT, DEFAULT_HISTORY_BITS, WB_NAMES, control } from '../model/core.js';
import { decode, disasm, FORMATS, ABI } from '../model/isa.js';
import { PROGRAMS } from './programs.js';

const $ = id => document.getElementById(id);
const STAGE_INFO = {
  FETCH1: 'PC + gshare lookup', FETCH2: 'predecode + redirect', DECODE: 'control, registers, forwarding',
  EXECUTE: 'ALU, branches, CSR', MEMORY: 'load data', WRITEBACK: 'write rd, retire',
};
const FRONT = ['FETCH1', 'FETCH2', 'DECODE'];
const hex = (v, n = 4) => '0x' + (v >>> 0).toString(16).padStart(n, '0');
const hex64 = v => '0x' + v.toString(16).padStart(16, '0');
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;');
const sgn = v => BigInt.asIntN(64, v);
const bin = (v, n) => v.toString(2).padStart(n, '0');

let img = null, core = null, events = [], timer = null, selAddr = null;
const opts = () => ({ bp: $('bp').checked, historyBits: Number($('hist').value) });
const textOf = x => (x ? core.instrs[x.id].text : '');

// ------------------------------------------------------------------ loading
function loadSource(src) {
  try { img = assemble(src); $('asmerr').textContent = ''; $('src').value = src; reset(); return true; }
  catch (e) { $('asmerr').textContent = e.message; return false; }
}
function reset() { stop(); core = new Core(img, opts()); events = []; render(); }
function step() { if (!core || core.halted) { stop(); return; } events.push(core.step()); render(); }
function back() {
  if (!events.length) return;
  const target = events.length - 1;
  stop(); core = new Core(img, opts()); events = [];
  while (events.length < target) events.push(core.step());
  render();
}
function run() {
  if (timer) { stop(); return; }
  $('run').textContent = 'Pause';
  const tick = () => {
    const perFrame = Math.max(1, Math.round(Number($('speed').value) / 8));
    for (let i = 0; i < perFrame && !core.halted; i++) events.push(core.step());
    render(); if (core.halted) stop();
  };
  timer = setInterval(tick, Math.max(16, 400 / Number($('speed').value)));
}
function stop() { if (timer) clearInterval(timer); timer = null; $('run').textContent = 'Run'; }

// ------------------------------------------------------------------ render
function render() {
  const ev = events[events.length - 1] || null, prev = events[events.length - 2] || null;
  $('cycle').textContent = ev ? ev.cycle : 0;
  const st = $('status'); st.className = 'status';
  if (!ev) st.textContent = 'reset: pipeline empty, FETCH1_PC = 0x2000';
  else if (ev.halt) { st.textContent = `halted: tohost = ${core.csr.tohost}${core.csr.tohost === 1n ? ' (PASS)' : ` (FAIL in test ${core.csr.tohost >> 1n})`}`; st.classList.add('halt'); }
  else if (ev.stall) { st.textContent = `LOAD_STALL${ev.loadStallReal ? '' : ' (false stall)'}`; st.classList.add('stall'); }
  else if (ev.busy) { st.textContent = 'MULTIPLY_DIVIDE_STALL: the M unit is iterating'; st.classList.add('stall'); }
  else if (ev.dmiss) { st.textContent = 'DATA_CACHE_STALL: the load waits for its cache line'; st.classList.add('stall'); }
  else if (ev.imiss) { st.textContent = 'Instruction cache miss: FETCH1 waits for main memory'; st.classList.add('stall'); }
  else if (ev.flush) { st.textContent = 'FLUSH_FETCH1_FETCH2_DECODE: wrong guess, 3 instructions squashed'; st.classList.add('flush'); }
  else if (ev.redirect) { st.textContent = 'FETCH2 redirect: 1 instruction squashed'; st.classList.add('flush'); }
  else st.textContent = '';
  renderStages(ev, prev); renderNarration(ev); renderChart(); renderListing(ev); renderRegs(ev); renderPredictor(ev); renderStats();
  $('output').textContent = core.output || '(nothing printed yet: programs print by storing a byte to 0x10000000)';
}

function renderStages(ev, prev) {
  $('stages').innerHTML = STAGES.map(s => {
    const x = ev && ev.stages[s];
    let body;
    if (!x) body = `<div class="empty">${ev ? 'bubble' : 'empty'}</div>`;
    else {
      const entered = !prev || !prev.stages[s] || prev.stages[s].id !== x.id;
      const tags = [];
      const stalled = ev.stall && FRONT.includes(s);
      const killed = (ev.flush && FRONT.includes(s)) || (ev.redirect && s === 'FETCH1');
      if (stalled) tags.push('<span class="tag stall">held</span>');
      if (s === 'FETCH1') tags.push(`<span class="tag pred">counter[${ev.predict.idx}] = ${bin(ev.predict.counter, 2)}: ${ev.predict.taken ? 'taken' : 'not taken'}</span>`);
      if (s === 'FETCH2' && ev.predecode) tags.push(`<span class="tag pred">${ev.predecode.kind === 'jal' ? 'JAL: redirect' : ev.predecode.predicted ? 'branch, predicted taken: redirect' : 'branch, predicted not taken'}</span>`);
      if (s === 'DECODE') {
        if (ev.fwd.a) tags.push(`<span class="tag fwd">rs1 ← ${ev.fwd.a}</span>`);
        if (ev.fwd.b) tags.push(`<span class="tag fwd">rs2 ← ${ev.fwd.b}</span>`);
      }
      if (s === 'EXECUTE') {
        if (ev.alu) tags.push(`<span class="tag ok">${ev.alu.unit} ${ev.alu.op}${ev.alu.word ? 'W' : ''}</span>`);
        if (ev.resolve && ev.resolve.kind !== 'jal') tags.push(ev.resolve.mispredict ? `<span class="tag miss">${ev.resolve.kind === 'jalr' ? 'JALR: always flush' : 'guess was wrong'}</span>` : '<span class="tag ok">guess was right</span>');
        if (ev.csrWrite) tags.push(`<span class="tag ok">CSR write</span>`);
      }
      if (s === 'MEMORY' && ev.memAccess && ev.memAccess.kind === 'load') tags.push(`<span class="tag ok">load ${hex(Number(ev.memAccess.addr & 0xffffffffn))}</span>`);
      if (s === 'EXECUTE' && ev.memAccess && ev.memAccess.kind === 'store') tags.push(`<span class="tag ok">store ${hex(Number(ev.memAccess.addr & 0xffffffffn))}</span>`);
      if (s === 'WRITEBACK' && ev.rfWrite) tags.push(`<span class="tag ok">${ABI[ev.rfWrite.rd]} ← ${sgn(ev.rfWrite.value)}</span>`);
      if (killed) tags.push('<span class="tag miss">squashed at the clock edge</span>');
      body = `<div class="chip${entered ? ' enter' : ''}${stalled ? ' stalled' : ''}" style="background:var(--${s})${killed ? ';opacity:.5' : ''}">
        <div class="pc">${hex(x.pc)}</div>${esc(textOf(x))}</div><div class="tags">${tags.join('')}</div>`;
    }
    return `<div class="stage"><h3>${s} <small>${STAGE_INFO[s]}</small></h3><div class="bar" style="background:var(--${s})"></div>${body}</div>`;
  }).join('');
}

function renderNarration(ev) {
  const L = [];
  if (!ev) L.push('Press <b>Step</b> to clock the pipeline. In cycle 1 FETCH1 sends the reset PC 0x2000 to the instruction memory.');
  else {
    const S = ev.stages, p = ev.predict, H = core.bp.historyBits;
    L.push(`<b>FETCH1</b> ${hex(S.FETCH1.pc)}: gshare index = PC bits <code>${bin(p.pcBits, H)}</code> XOR history <code>${bin(p.ghr, H)}</code> = ${p.idx}, counter <code>${bin(p.counter, 2)}</code> → ${p.taken ? 'taken' : 'not taken'}.`);
    if (S.FETCH2) L.push(`<b>FETCH2</b> ${esc(textOf(S.FETCH2))} arrived.${ev.predecode ? (ev.predecode.predicted ? ` Target ${hex(ev.predecode.target)} precomputed: FETCH1 is redirected there.` : ' A branch, predicted not taken: keep going at PC + 4.') : ''}`);
    if (S.DECODE) {
      const c = control(core.instrs[S.DECODE.id].word);
      L.push(`<b>DECODE</b> ${esc(textOf(S.DECODE))}: ALU_OPERATION = ALU_${c.aluOp}, WRITEBACK_SELECT = WRITEBACK_${WB_NAMES[c.wbSel]}${c.regWrite ? ', REGISTER_WRITE_ENABLE' : ''}.${ev.fwd.a || ev.fwd.b ? ` Forwarded: ${[ev.fwd.a && `rs1 from ${ev.fwd.a}`, ev.fwd.b && `rs2 from ${ev.fwd.b}`].filter(Boolean).join(', ')}.` : ''}`);
    }
    if (S.EXECUTE && ev.alu) {
      L.push(`<b>EXECUTE</b> ${esc(textOf(S.EXECUTE))}: ${ev.alu.unit}(${sgn(ev.alu.a)}, ${sgn(ev.alu.b)}) = ${sgn(ev.alu.result)}.`);
      if (ev.resolve && ev.resolve.kind === 'branch') L.push(`<b>BranchControl</b> predicted ${ev.resolve.predicted ? 'taken' : 'not taken'}, actually ${ev.resolve.actual ? 'taken' : 'not taken'}: ${ev.resolve.mispredict ? '<b>wrong</b>, flush 3 and restart.' : 'right, no penalty.'}`);
      if (ev.resolve && ev.resolve.kind === 'jalr') L.push(`<b>BranchControl</b> JALR target ${hex(ev.resolve.target)} comes from a register, it could not be predicted: flush 3.`);
      if (ev.bpUpdate) L.push(`<b>gshare</b> train counter[${ev.bpUpdate.idx}] ${bin(ev.bpUpdate.before, 2)} → ${bin(ev.bpUpdate.after, 2)}.${ev.ghrRestore !== undefined ? ` History restored to <code>${bin(ev.ghrRestore, H)}</code>.` : ''}`);
    }
    if (ev.memAccess) L.push(`<b>${ev.memAccess.kind === 'load' ? 'MEMORY' : 'EXECUTE'}</b> ${ev.memAccess.kind} at ${hex(Number(ev.memAccess.addr & 0xffffffffn))}: ${sgn(ev.memAccess.value)}.`);
    if (ev.rfWrite) L.push(`<b>WRITEBACK</b> x${ev.rfWrite.rd} (${ABI[ev.rfWrite.rd]}) ← ${hex64(ev.rfWrite.value)}.`);
    if (ev.stall) L.push(`<b>LOAD_STALL</b> the load in EXECUTE has no data yet and DECODE's rs1/rs2 field matches its rd${ev.loadStallReal ? '' : ' (a <b>false</b> stall: the instruction does not really read that register, see Lab 5)'}: hold FETCH1, FETCH2, DECODE; NOP into EXECUTE.`);
    if (ev.halt) L.push('<b>HALT</b> the tohost write reached WRITEBACK. The program is finished.');
  }
  $('narration').innerHTML = L.map(x => `<li>${x}</li>`).join('');
}

function renderChart() {
  const N = 26, last = events.length, first = Math.max(1, last - N + 1);
  const rows = new Map();
  for (const ev of events.slice(first - 1, last)) for (const s of STAGES) {
    const x = ev.stages[s]; if (!x) continue;
    if (!rows.has(x.id)) rows.set(x.id, { pc: x.pc, cells: {} });
    rows.get(x.id).cells[ev.cycle] = { s, st: ev.stall && FRONT.includes(s), fw: s === 'DECODE' && (ev.fwd.a || ev.fwd.b) };
  }
  const ids = [...rows.keys()].sort((a, b) => a - b).slice(-18);
  const end = Math.max(last, first + N - 1);
  let h = '<tr><th></th>';
  for (let c = first; c <= end; c++) h += `<th>${c}</th>`;
  h += '</tr>';
  for (const id of ids) {
    const r = rows.get(id), sq = core.instrs[id].squashed;
    h += `<tr><td class="label${sq ? ' sq' : ''}">${hex(r.pc)} ${esc(core.instrs[id].text.slice(0, 24))}</td>`;
    for (let c = first; c <= end; c++) {
      const cell = r.cells[c];
      h += cell ? `<td class="c${sq ? ' sq' : ''}${cell.st ? ' st' : ''}${cell.fw ? ' fw' : ''}${c === last ? ' now' : ''}" style="background:var(--${cell.s})">${SHORT[cell.s]}</td>` : '<td></td>';
    }
    h += '</tr>';
  }
  h += '<tr class="hz"><td class="label" style="color:var(--sub)">hazard events</td>';
  for (let c = first; c <= end; c++) {
    const ev = events[c - 1];
    h += !ev ? '<td></td>' : ev.stall ? '<td style="background:var(--stall)">stall</td>' : ev.flush ? '<td style="background:var(--redirect)">flush</td>' : ev.redirect ? '<td style="background:var(--FETCH2)">redir</td>' : '<td></td>';
  }
  $('chart').innerHTML = h + '</tr>';
}

const FIELD_CLASS = n => { const k = n.split('[')[0]; return ['opcode', 'rd', 'rs1', 'rs2', 'funct3', 'funct7'].includes(k) ? 'f-' + k : (k === 'funct6' || k === 'funct12' ? 'f-funct7' : k === 'csr' ? 'f-funct7' : 'f-imm'); };
function binFields(word) {
  const d = decode(word), b = word.toString(2).padStart(32, '0');
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
      <td class="addr">${hex(l.addr)}</td><td>${stg.map(s => `<span class="stg" style="background:var(--${s})">${SHORT[s]}</span>`).join(' ')}</td>
      <td class="bin">${binFields(l.word).html}</td><td class="src">${esc(l.src)}</td></tr>`;
  }).join('');
  const sel = rows.find(l => l.addr === selAddr) || null;
  if (!sel) { $('bits').innerHTML = '<p class="hint">Click an instruction to see its 32-bit encoding field by field and the control signals the ControlUnit makes from it.</p>'; return; }
  const { d, parts } = binFields(sel.word);
  const c = control(sel.word);
  $('bits').innerHTML = d.def ? `<b>${esc(disasm(d, sel.addr))}</b>: ${esc(d.def.desc)} (${d.fmt}-type) = <code>0x${sel.word.toString(16).padStart(8, '0')}</code>
    <div class="fields">${parts.map(p => `<div class="fld ${p.cls}">${p.bits}<small>${p.n}</small></div>`).join('')}</div>
    <code>${esc(d.def.sem)}</code><p class="hint">ALU_OPERATION = ALU_${c.aluOp} · IMMEDIATE_${c.immType} · WRITEBACK_${WB_NAMES[c.wbSel]} · REGISTER_WRITE_ENABLE = ${c.regWrite} · MEMORY_READ/WRITE = ${c.memRead}/${c.memWrite}</p>` : 'not an instruction';
}

function renderRegs(ev) {
  const w = ev && ev.rfWrite ? ev.rfWrite.rd : -1;
  $('regs').innerHTML = core.regs.map((v, i) =>
    `<div class="${i === w ? 'w' : ''}"><span class="n">x${i} ${ABI[i]}</span><span class="${v === 0n ? 'z' : ''}">${v === 0n ? '0' : hex64(v)}</span></div>`).join('');
}

function renderPredictor(ev) {
  const bp = core.bp, H = bp.historyBits;
  $('ghr').innerHTML = [...bin(bp.ghr, H)].map(t => `<span class="${t === '1' ? 't' : ''}">${t}</span>`).join('');
  const rd = ev ? ev.predict.idx : -1, up = ev && ev.bpUpdate ? ev.bpUpdate.idx : -1;
  let h = '';
  for (let i = 0; i < bp.pht.length; i++) h += `<i class="s${bp.pht[i]}${i === rd ? ' rd' : ''}${i === up ? ' up' : ''}" title="counter ${i}: ${bin(bp.pht[i], 2)}"></i>`;
  $('pht').innerHTML = h;
  $('bpinfo').innerHTML = `${bp.enabled ? `${bp.pht.length} two-bit counters, index = <code>PC[${H + 1}:2] XOR GLOBAL_HISTORY_REGISTER</code> (${H} bits).` : 'Predictor OFF: every branch is predicted not taken (JAL still redirects in FETCH2).'} Outline = read in FETCH1 this cycle, ring = trained by the branch in EXECUTE.`;
  $('ghrnote').textContent = ev && ev.ghrRestore !== undefined ? `restored from checkpoint after a flush: ${bin(ev.ghrRestore, H)}` : ev && ev.ghrShift !== undefined ? `a branch left FETCH2: shifted in its predicted direction (${ev.ghrShift})` : '';
}

function renderStats() {
  const s = core.stats, b = s.bubbles;
  const items = [
    ['cycles', s.cycles, true], ['instructions retired', s.retired], ['CPI', s.retired ? (s.cycles / s.retired).toFixed(3) : '-', true],
    ['load stalls (false)', `${s.loadStalls} (${s.falseLoadStalls})`], ['flushes: wrong guess / JALR', `${s.mispredicts} / ${s.jalrFlushes}`],
    ['FETCH2 redirects / BTB hits', `${s.redirects} / ${s.btbRedirects}`], ['multiply/divide busy cycles', s.multiplyDivideBusy], ['cache misses: instruction / data', `${s.icacheMisses} / ${s.dcacheMisses}`], ['branch accuracy', s.branches ? (100 * (1 - s.mispredicts / s.branches)).toFixed(1) + '%' : '-'], ['operands forwarded', s.forwards],
    ['hardware counters hpm3..8 (L F R K I D)', core.hpm ? ['stall', 'flush', 'redirect', 'busy', 'imiss', 'dmiss'].map(k => String(core.hpm[k])).join(' · ') : '-'],
  ];
  if (core.halted) {
    const pred = s.retired + 5 + s.loadStalls + 3 * s.flushes + b.redirect + b.muldiv + b.imiss + b.dmiss;
    items.push(['equation check', `${s.retired} + 5 + ${s.loadStalls} + 3×${s.flushes} + ${b.redirect} + ${b.muldiv} + ${b.imiss} + ${b.dmiss} = ${pred} ${pred === s.cycles ? '✓' : '✗'}`]);
  }
  $('stats').innerHTML = items.map(([k, v, big]) => `<dt>${k}</dt><dd class="${big ? 'big' : ''}">${v}</dd>`).join('');
}

// ------------------------------------------------------------------ wiring
const sel = $('prog');
for (const name of Object.keys(PROGRAMS)) sel.add(new Option(name.replace(/_/g, ' '), name));
for (let h = 1; h <= 10; h++) $('hist').add(new Option(`${h} bits (${1 << h} counters)${h === 4 ? ', baseline' : h === DEFAULT_HISTORY_BITS ? ', default' : ''}`, h));
$('hist').value = DEFAULT_HISTORY_BITS;
const wanted = new URLSearchParams(location.search).get('prog');
sel.value = wanted in PROGRAMS ? wanted : '03_load_use' in PROGRAMS ? '03_load_use' : Object.keys(PROGRAMS)[0];
sel.onchange = () => loadSource(PROGRAMS[sel.value]);
$('step').onclick = step; $('back').onclick = back; $('run').onclick = run; $('reset').onclick = reset;
$('bp').onchange = reset; $('hist').onchange = reset;
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
