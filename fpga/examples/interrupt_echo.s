# =============================================================================
# fpga/examples/interrupt_echo.s: a program driven entirely by interrupts
#
# For the FPGA board (or the console on the site). The main program only
# sleeps; two interrupts do all the work:
#   external interrupt (mcause = bit 63 + 11): the UART received a byte. The
#       handler takes it, echoes it in upper case, and stops at 'q'.
#   timer interrupt (mcause = bit 63 + 7): four times a second LED 0 blinks.
# Both need their enable bit in mie (bit 11 MEIE, bit 7 MTIE) and mstatus.MIE.
#
# FPGA-INPUT: sixfold!q
# FPGA-EXPECT-OUTPUT: SIXFOLD!
# =============================================================================
    .equ DEVICES,  0x10000000
    .equ PUTCHAR,  0x00
    .equ LEDS,     0x08
    .equ UART,     0x18
    .equ CLOCK,    0x28
    .equ MTIME,    0x58
    .equ MTIMECMP, 0x60
    li   sp, 0xF000
    li   s0, DEVICES
    la   t0, handler
    csrw mtvec, t0
    la   a0, hello
    call puts
    ld   s3, CLOCK(s0)
    srli s3, s3, 2            # timer period: a quarter of a second
    bnez s3, period_ok
    li   s3, 1000             # (the clock rate reads 0 in plain simulation)
period_ok:
    ld   t0, MTIME(s0)
    add  t0, t0, s3
    sd   t0, MTIMECMP(s0)
    li   t0, 0x880
    csrw mie, t0              # MEIE (bit 11) and MTIE (bit 7)
    li   s1, 0                # set to 1 by the handler on 'q'
    li   s4, 0                # characters echoed
    li   s5, 0                # timer ticks
    csrsi mstatus, 8          # interrupts on: from here on, everything happens in the handler
idle:
    wfi
    beqz s1, idle
    csrci mstatus, 8
    sd   zero, LEDS(s0)
    la   a0, bye
    call puts
    halt

handler:                      # uses t3..t6 only
    csrr t3, mcause
    andi t3, t3, 0xff
    li   t4, 11
    beq  t3, t4, external
timer:
    ld   t5, MTIMECMP(s0)
    add  t5, t5, s3
    sd   t5, MTIMECMP(s0)
    ld   t6, LEDS(s0)
    xori t6, t6, 1
    sd   t6, LEDS(s0)
    addi s5, s5, 1
    mret
external:
    ld   t5, UART(s0)
    srli t5, t5, 8
    andi t5, t5, 255          # the received byte
    sd   zero, UART(s0)       # take it (the interrupt line drops when the queue is empty)
    li   t6, 'q'
    beq  t5, t6, quit
    li   t6, 'a'
    blt  t5, t6, echo
    li   t6, 'z'
    bgt  t5, t6, echo
    addi t5, t5, -32          # a..z -> A..Z
echo:
    sb   t5, PUTCHAR(s0)
    addi s4, s4, 1
    mret
quit:
    li   s1, 1
    mret

puts:                         # a0 = string (interrupts are off while this runs)
    lbu  t0, 0(a0)
    beqz t0, puts_done
puts_wait:
    ld   t1, UART(s0)
    andi t1, t1, 2
    bnez t1, puts_wait
    sb   t0, PUTCHAR(s0)
    addi a0, a0, 1
    j    puts
puts_done:
    ret

hello:
    .string "type something (q quits): "
bye:
    .string "\ngoodbye\n"
