# =============================================================================
# fpga/firmware/bios.s: the boot firmware ("BIOS") of the Sixfold FPGA computer
#
# The core starts here (address 0x0000) after power-on or the reset button, just
# as a PC starts in its BIOS ROM. It is ordinary RV64 code that talks to the rest
# of the computer through memory-mapped device registers at 0x1000_0000
# (fpga/rtl/Sixfold_System.sv lists them). Over the UART it offers:
#
#   l  load a program sent by the PC (tools/fpga_load.py):
#        'l', address (4 bytes, little-endian), length (4 bytes), the bytes,
#        checksum (4 bytes: the sum of all bytes, modulo 2^32)
#   r  run the program at 0x2000 (a store to BOOT restarts the core there)
#   i  information: ISA, clock, memory, uptime
#   m  memory test of the program area (0x2000 .. 0xFFFF; erases the program)
#   h  help
# Without a PC: the centre button (FIRE1 on the ULX3S) runs the program too, and the
# seven-segment display (Basys 3) shows "bIOS", then "PASS" or "FAIL" after a program.
#
# When a program finishes (it writes TOHOST), the system restarts the core here
# with BOOT_REASON = 1 and the firmware prints PASS/FAIL and the cycle count.
#
# Memory map:  0x0000 .. 0x0FFF firmware code and text
#              0x1000 .. 0x1FFF firmware stack (grows down from 0x2000)
#              0x2000 .. 0xFFFF programs (the assembler puts code at 0x2000)
# =============================================================================
    .equ DEVICES,     0x10000000
    .equ PUTCHAR,     0x00
    .equ LEDS,        0x08
    .equ BUTTONS,     0x10
    .equ UART,        0x18      # bit0 byte arrived, bit1 transmit queue full, bit2 idle, 15:8 the byte
    .equ BOOT,        0x20
    .equ CLOCK,       0x28
    .equ LAST_TOHOST, 0x30
    .equ LAST_CYCLES, 0x38
    .equ BOOT_REASON, 0x40
    .equ TIMER,       0x48
    .equ BOOT_ADDRESS, 0x50
    .equ DISPLAY,     0x70      # seven-segment digits: one byte of segments per digit, leftmost in bits 31:24
    .equ SHOW_BIOS,   0x7C303F6D # b I O S
    .equ SHOW_PASS,   0x73776D6D # P A S S
    .equ SHOW_FAIL,   0x71773038 # F A I L
    .equ PROGRAM_START, 0x2000
    .equ MEMORY_END,  0x10000

    .org 0x0
bios:
    li   sp, PROGRAM_START     # the stack grows down from the program area
    li   s0, DEVICES           # s0 = base of the device registers, for the whole firmware
    li   t0, 0x81
    sd   t0, LEDS(s0)          # two LEDs on: the firmware is alive
    li   t0, SHOW_BIOS
    sw   t0, DISPLAY(s0)
    ld   t0, BOOT_REASON(s0)
    li   t1, 1
    beq  t0, t1, report        # a program just finished
    la   a0, text_banner
    call puts
    call info
    j    prompt

# ---------------------------------------------------------------- after a program
report:
    la   a0, text_finished
    call puts
    ld   t0, LAST_TOHOST(s0)
    li   t1, 1
    bne  t0, t1, report_fail
    li   t0, SHOW_PASS
    sw   t0, DISPLAY(s0)
    la   a0, text_pass
    call puts
    j    report_cycles
report_fail:
    li   t0, SHOW_FAIL
    sw   t0, DISPLAY(s0)
    la   a0, text_fail
    call puts
    ld   a0, LAST_TOHOST(s0)
    srli a0, a0, 1             # TOHOST = (test number << 1) | 1
    call print_decimal
report_cycles:
    la   a0, text_in
    call puts
    ld   a0, LAST_CYCLES(s0)
    call print_decimal
    la   a0, text_cycles
    call puts

# ---------------------------------------------------------------- the command loop
prompt:
    la   a0, text_prompt
    call puts
command:
    call getc
    li   t0, 'l'
    beq  a0, t0, command_load
    li   t0, 'r'
    beq  a0, t0, command_run
    li   t0, 'i'
    beq  a0, t0, command_info
    li   t0, 'm'
    beq  a0, t0, command_memory_test
    li   t0, 'h'
    beq  a0, t0, command_help
    li   t0, '?'
    beq  a0, t0, command_help
    li   t0, 13                # Enter: a fresh prompt
    beq  a0, t0, prompt
    li   t0, 10
    beq  a0, t0, command       # (ignore the line feed of CR LF)
    la   a0, text_unknown
    call puts
    j    prompt

command_help:
    la   a0, text_help
    call puts
    j    prompt

command_info:
    la   a0, text_newline
    call puts
    call info
    j    prompt

command_run:
    la   a0, text_run
    call puts
    li   t0, PROGRAM_START
    sd   t0, BOOT_ADDRESS(s0)
    # A program expects the registers a simulation starts with: all zero. Clear them all but tp, which
    # holds the device address for the last store (programs never use tp).
    li   tp, DEVICES
    li   ra, 0
    li   sp, 0
    li   gp, 0
    li   t0, 0
    li   t1, 0
    li   t2, 0
    li   s0, 0
    li   s1, 0
    li   a0, 0
    li   a1, 0
    li   a2, 0
    li   a3, 0
    li   a4, 0
    li   a5, 0
    li   a6, 0
    li   a7, 0
    li   s2, 0
    li   s3, 0
    li   s4, 0
    li   s5, 0
    li   s6, 0
    li   s7, 0
    li   s8, 0
    li   s9, 0
    li   s10, 0
    li   s11, 0
    li   t3, 0
    li   t4, 0
    li   t5, 0
    li   t6, 0
    sd   zero, BOOT(tp)        # the system resets the core and its caches and starts it at BOOT_ADDRESS
run_wait:
    j    run_wait              # (never reached: the core is already restarting)

# 'l': address, length, bytes, checksum. Bytes outside the program area are counted but not stored.
command_load:
    call get_word
    mv   s3, a0                # s3 = address
    call get_word
    mv   s4, a0                # s4 = length
    add  s7, s3, s4            # s7 = end address
    li   s8, 1                 # s8 = 1 if the whole range is inside the program area
    li   t0, PROGRAM_START
    bgeu s3, t0, load_low_ok
    li   s8, 0
load_low_ok:
    li   t0, MEMORY_END
    bleu s7, t0, load_high_ok
    li   s8, 0
load_high_ok:
    li   s5, 0                 # s5 = checksum
    mv   s6, s3                # s6 = where the next byte goes
    li   t0, 0x3C
    sd   t0, LEDS(s0)          # LEDs: loading
load_loop:
    beq  s6, s7, load_done
    call getc
    add  s5, s5, a0
    beqz s8, load_skip
    sb   a0, 0(s6)             # write-through: straight into main memory (and the data cache, if the line is there)
load_skip:
    addi s6, s6, 1
    j    load_loop
load_done:
    call get_word
    slli s5, s5, 32
    srli s5, s5, 32            # the checksum modulo 2^32
    li   t0, 0x81
    sd   t0, LEDS(s0)
    bne  a0, s5, load_bad_checksum
    beqz s8, load_bad_range
    la   a0, text_loaded
    call puts
    mv   a0, s4
    call print_decimal
    la   a0, text_bytes
    call puts
    j    prompt
load_bad_checksum:
    la   a0, text_bad_checksum
    call puts
    j    prompt
load_bad_range:
    la   a0, text_bad_range
    call puts
    j    prompt

# 'm': write a different 64-bit pattern to every doubleword of 0x2000 .. 0xFFFF, read all back
command_memory_test:
    la   a0, text_memory_test
    call puts
    rdcycle s9
    li   s3, PROGRAM_START
    li   s4, MEMORY_END
    li   s5, 0x9E3779B97F4A7C15 # the pattern is address x this odd constant (every address differs)
    mv   s6, s3
memory_write_loop:
    mul  t0, s6, s5
    sd   t0, 0(s6)
    addi s6, s6, 8
    bne  s6, s4, memory_write_loop
    li   s7, 0                 # s7 = errors
    mv   s6, s3
memory_read_loop:
    mul  t0, s6, s5
    ld   t1, 0(s6)
    beq  t0, t1, memory_ok
    addi s7, s7, 1
memory_ok:
    addi s6, s6, 8
    bne  s6, s4, memory_read_loop
    rdcycle s10
    mv   a0, s7
    call print_decimal
    la   a0, text_errors
    call puts
    sub  a0, s10, s9
    call print_decimal
    la   a0, text_cycles
    call puts
    j    prompt

# ---------------------------------------------------------------- information
info:
    addi sp, sp, -16
    sd   ra, 0(sp)
    la   a0, text_isa
    call puts
    ld   a0, CLOCK(s0)
    call print_decimal
    la   a0, text_hz
    call puts
    la   a0, text_memory
    call puts
    ld   a0, TIMER(s0)
    call print_decimal
    la   a0, text_cycles
    call puts
    ld   ra, 0(sp)
    addi sp, sp, 16
    ret

# ---------------------------------------------------------------- UART routines
# putc(a0): wait while the transmit queue is full, then store the character to PUTCHAR
putc:
    ld   t0, UART(s0)
    andi t0, t0, 2
    bnez t0, putc
    sb   a0, PUTCHAR(s0)
    ret

# getc() -> a0: wait for a byte, take it, drop it from the receive queue (a store to UART)
getc:
    ld   t0, BUTTONS(s0)
    andi t0, t0, 1
    bnez t0, getc_button       # the centre button: "r"
    ld   t0, UART(s0)
    andi t1, t0, 1
    beqz t1, getc
    srli a0, t0, 8
    andi a0, a0, 255
    sd   zero, UART(s0)
    ret

getc_button:                   # wait for the release, so the program does not see the press
    ld   t0, BUTTONS(s0)
    andi t0, t0, 1
    bnez t0, getc_button
    ld   t0, CLOCK(s0)          # then 20 ms more: the contacts bounce when released too
    li   t1, 50
    divu t0, t0, t1
    ld   t1, TIMER(s0)
    add  t0, t0, t1
getc_settle:
    ld   t1, TIMER(s0)
    bltu t1, t0, getc_settle
    li   a0, 'r'
    ret

# puts(a0 = address of a zero-terminated string)
puts:
    addi sp, sp, -16
    sd   ra, 0(sp)
    sd   s1, 8(sp)
    mv   s1, a0
puts_loop:
    lbu  a0, 0(s1)
    beqz a0, puts_done
    call putc
    addi s1, s1, 1
    j    puts_loop
puts_done:
    ld   ra, 0(sp)
    ld   s1, 8(sp)
    addi sp, sp, 16
    ret

# print_decimal(a0, unsigned): digits come out lowest first, so they are built backwards on the stack
print_decimal:
    addi sp, sp, -48
    sd   ra, 40(sp)
    sd   s1, 32(sp)
    addi s1, sp, 31
    sb   zero, 0(s1)           # the terminating zero
    li   t2, 10
decimal_loop:
    remu t1, a0, t2            # the M extension's divider does the work (5 + bits cycles each)
    divu a0, a0, t2
    addi t1, t1, '0'
    addi s1, s1, -1
    sb   t1, 0(s1)
    bnez a0, decimal_loop
    mv   a0, s1
    call puts
    ld   ra, 40(sp)
    ld   s1, 32(sp)
    addi sp, sp, 48
    ret

# get_word() -> a0: 4 bytes, least significant first
get_word:
    addi sp, sp, -32
    sd   ra, 0(sp)
    sd   s1, 8(sp)
    sd   s2, 16(sp)
    li   s1, 0
    li   s2, 0
get_word_loop:
    call getc
    sll  a0, a0, s2
    or   s1, s1, a0
    addi s2, s2, 8
    li   t0, 32
    bne  s2, t0, get_word_loop
    mv   a0, s1
    ld   ra, 0(sp)
    ld   s1, 8(sp)
    ld   s2, 16(sp)
    addi sp, sp, 32
    ret

# ---------------------------------------------------------------- text
text_banner:
    .string "\r\n\r\n  ____  _       __       _     _\r\n / ___|(_)_  __/ _| ___ | | __| |\r\n \\___ \\| \\ \\/ / |_ / _ \\| |/ _` |\r\n  ___) | |>  <|  _| (_) | | (_| |\r\n |____/|_/_/\\_\\_|  \\___/|_|\\__,_|   boot firmware\r\n\r\n"
text_isa:
    .string "  cpu     : Sixfold RV64IM_Zicsr_Zba_Zbb_Zbs, 6-stage pipeline\r\n  clock   : "
text_hz:
    .string " Hz\r\n"
text_memory:
    .string "  memory  : 64 KiB block RAM (firmware 0x0000, programs 0x2000), 4 KiB I-cache + 4 KiB D-cache\r\n  devices : UART, LEDs, buttons, switches, 7-segment digits at 0x1000_0000\r\n  uptime  : "
text_cycles:
    .string " cycles\r\n"
text_prompt:
    .string "sixfold> "
text_help:
    .string "\r\n  l  load a program (use tools/fpga_load.py)\r\n  r  run the program at 0x2000 (or press the centre button)\r\n  i  information\r\n  m  memory test (erases the program)\r\n  h  this help\r\n"
text_unknown:
    .string "\r\n  unknown command, h for help\r\n"
text_newline:
    .string "\r\n"
text_run:
    .string "\r\n[bios] starting the program at 0x2000\r\n"
text_finished:
    .string "\r\n[bios] program finished: "
text_pass:
    .string "PASS"
text_fail:
    .string "FAIL, test "
text_in:
    .string " in "
text_loaded:
    .string "\r\n[bios] loaded "
text_bytes:
    .string " bytes\r\n"
text_bad_checksum:
    .string "\r\n[bios] checksum error, nothing to run\r\n"
text_bad_range:
    .string "\r\n[bios] the program must lie in 0x2000 .. 0xFFFF\r\n"
text_memory_test:
    .string "\r\n[bios] memory test 0x2000 .. 0xFFFF: "
text_errors:
    .string " errors, "
