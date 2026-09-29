#!/usr/bin/env node
// =============================================================================
// tools/fpga_image.mjs: build the memory image and the upload stream for the FPGA
//
//   node tools/fpga_image.mjs [program.s] [--out build/fpga]
//
//   <out>/memory.hex   the block RAM's initial contents (fpga/rtl/Main_Memory.sv): the boot firmware
//                      at 0x0000 and, if given, a program at 0x2000 ("r" runs it right after power-on).
//                      2048 lines of 64 hex digits, one 32-byte line each, byte 0 rightmost.
//   <out>/bios.lst     listing of the firmware
//   <out>/upload.hex   (with a program) the exact bytes tools/fpga_load.py sends over the UART:
//                      'l', address, length, the bytes, checksum, then 'r'. The system testbench
//                      (fpga/sim/system_testbench.sv) plays it into the UART receiver.
// =============================================================================
import fs from 'node:fs';
import path from 'node:path';
import { assemble, toListing } from '../model/asm.js';

const args = process.argv.slice(2);
let out = 'build/fpga', program = null;
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--out') out = args[++i];
  else program = args[i];
}
fs.mkdirSync(out, { recursive: true });

const bios = assemble(fs.readFileSync('fpga/firmware/bios.s', 'utf8'));
if (bios.used[1] > 0x1000) throw new Error(`the firmware is ${bios.used[1]} bytes: it must end below 0x1000 (0x1000..0x1FFF is its stack)`);
fs.writeFileSync(path.join(out, 'bios.lst'), toListing(bios) + '\n');
const memory = new Uint8Array(65536);
memory.set(bios.bytes.slice(0, 0x1000), 0);

if (program) {
  const img = assemble(fs.readFileSync(program, 'utf8'));
  const [lo, hi] = img.used;
  if (lo < 0x2000) throw new Error(`${program} uses 0x${lo.toString(16)}: programs must start at 0x2000 or above`);
  memory.set(img.bytes.slice(lo, hi), lo);
  const bytes = [...img.bytes.slice(lo, hi)];
  const word = v => [v & 255, (v >>> 8) & 255, (v >>> 16) & 255, (v >>> 24) & 255];
  const checksum = bytes.reduce((a, b) => (a + b) >>> 0, 0);
  const stream = ['l'.charCodeAt(0), ...word(lo), ...word(hi - lo), ...bytes, ...word(checksum), 'r'.charCodeAt(0)];
  fs.writeFileSync(path.join(out, 'upload.hex'), stream.map(b => b.toString(16).padStart(2, '0')).join('\n') + '\n');
  console.log(`${program}: ${hi - lo} bytes at 0x${lo.toString(16)}, upload stream ${stream.length} bytes`);
}

const lines = [];
for (let line = 0; line < 2048; line++) {
  let hex = '';
  for (let b = 31; b >= 0; b--) hex += memory[line * 32 + b].toString(16).padStart(2, '0');
  lines.push(hex);
}
fs.writeFileSync(path.join(out, 'memory.hex'), lines.join('\n') + '\n');
console.log(`firmware: ${bios.used[1]} bytes -> ${out}/memory.hex`);
