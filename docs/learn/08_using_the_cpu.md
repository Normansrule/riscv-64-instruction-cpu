# 8. Using the CPU: write and run your own program

## The rules of this machine

| thing | value |
|---|---|
| reset PC (first instruction) | `0x2000` |
| memory | 64 KiB, addresses wrap every `0x10000` |
| stack | start with `li sp, 0xF000` (grows down) |
| print a character | store a byte to `0x10000000` |
| finish | `halt` = `csrwi tohost, 1` then `j .` (reports PASS) |
| report failure number n | write `(n << 1) \| 1` to `tohost` |
| cycle / instruction counters | `rdcycle rd`, `rdinstret rd` |

## A first program

Save as `programs/my_program.s`:

```asm
# EXPECT: a0 = 55
    li   t0, 10          # count down from 10
    li   a0, 0           # sum
loop:
    add  a0, a0, t0
    addi t0, t0, -1
    bnez t0, loop
    halt
```

```bash
make run  PROG=my_program     # registers, cycles, CPI, predictor accuracy
make pipe PROG=my_program     # pipeline chart in the terminal
make rtl  PROG=my_program     # the same program on the SystemVerilog RTL
node tools/test.mjs my_program  # checks the EXPECT line on model AND RTL, cycle by cycle
```

`# EXPECT: reg = value` lines are checked by the test runner, so every program doubles as a test.
Use `# EXPECT[gshare]:` / `# EXPECT[bp-off]:` for timing numbers that depend on the predictor.

## Assembler cheat sheet

* Registers by number (`x10`) or ABI name (`a0`, `t0`, `s0`, `sp`, `ra`, `zero`).
* Pseudo-instructions: `li`, `la`, `mv`, `not`, `neg`, `nop`, `j`, `jr`, `ret`, `call`, `tail`,
  `beqz`, `bnez`, `bgt`, `ble`, `csrr`, `csrw`, `rdcycle`, `rdinstret`, `halt`.
* Data: `.byte .half .word .dword .zero .string .align .org`. Labels end with `:`. `.` is the current address.

## Debugging

* `make cycle PROG=my_program C=12`: everything that happens in cycle 12.
* `make wave PROG=my_program`: GTKWave with one signal group per stage (`docs/gtkwave/pipeline.gtkw`).
* The [web simulator](../../web/index.html): paste your code into **Edit source**, press
  **Assemble and load**, then Step forward and **Back**.

Back to the [learning path](README.md).
