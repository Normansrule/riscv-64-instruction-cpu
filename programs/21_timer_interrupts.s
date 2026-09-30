# =============================================================================
# 21_timer_interrupts.s: a timer interrupt, taken precisely in the middle of a loop
#
# Every RISC-V system has a machine timer: MTIME counts clock cycles, and when it
# reaches MTIMECMP the timer interrupt line goes up. With interrupts enabled
# (mstatus.MIE and mie.MTIE), the CPU stops what it is doing between two
# instructions, saves the address to come back to in mepc, the reason in mcause
# (bit 63 set + 7: machine timer interrupt) and jumps to mtvec. The handler
# moves MTIMECMP forward and returns with mret.
#
# Sixfold takes the interrupt in DECODE: the instruction there is replaced by a
# pseudo-instruction that traps (src/Riscv64.sv DECODE_TAKES_INTERRUPT). The main
# loop never notices: its sum comes out right however often it is interrupted.
#
#   a0 = 1 + 2 + ... + 3000 (the loop's work, interrupts or not)
#   a1 = ticks: how many timer interrupts the handler saw
#   a2 = the mcause the handler saw (0x8000000000000007)
#   a3 = interrupts counted by the hardware (hpmcounter9), must equal a1
#   then wfi waits for two more ticks with interrupts on
# EXPECT: a0 = 4501500
# EXPECT: a2 = -9223372036854775801
# =============================================================================
    .equ DEVICES,  0x10000000
    .equ MTIME,    0x58
    .equ MTIMECMP, 0x60
    .equ PERIOD,   400
    la   t0, handler
    csrw mtvec, t0
    li   s0, DEVICES
    li   s1, 0               # ticks
    ld   t0, MTIME(s0)
    addi t0, t0, PERIOD
    sd   t0, MTIMECMP(s0)    # first tick PERIOD cycles from now
    li   t0, 0x80
    csrw mie, t0             # mie.MTIE: the timer may interrupt
    csrsi mstatus, 8         # mstatus.MIE: interrupts on
    li   a0, 0
    li   t1, 0
    li   t2, 3000
loop:
    addi t1, t1, 1           # any of these can be the one the interrupt replaces
    add  a0, a0, t1
    blt  t1, t2, loop
    addi s2, s1, 2           # wait for two more ticks
sleep:
    wfi                      # "nothing to do until an interrupt" (a nop here: the loop does the waiting)
    blt  s1, s2, sleep
    csrci mstatus, 8         # interrupts off
    mv   a1, s1
    csrr a3, hpmcounter9
    halt

handler:                     # uses only t3, t4 and s1 (the main code never touches t3, t4)
    addi s1, s1, 1
    csrr a2, mcause
    ld   t3, MTIMECMP(s0)
    addi t3, t3, PERIOD      # next tick
    sd   t3, MTIMECMP(s0)
    mret                     # back to the replaced instruction
