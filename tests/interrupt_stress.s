# =============================================================================
# interrupt_stress.s: timer interrupts landing on every kind of instruction
#
# The same workload runs twice: first with interrupts off, then with a timer
# interrupt every 17 to 47 cycles (the period changes every tick, so the
# interrupt lands on loads, stores, branches, calls, returns, multiplies,
# divides, cpop, bset, CSR accesses ...). Interrupts are precise, so both runs
# must produce the same checksum. make test also checks every cycle against the
# model, predictor on and off, both builds.
#   a0 = 1 if the two checksums agree
#   a1 = interrupts taken (hpmcounter9), a2 = the handler's own count (equal)
# EXPECT: a0 = 1
# =============================================================================
    .equ DEVICES,  0x10000000
    .equ MTIME,    0x58
    .equ MTIMECMP, 0x60
    li   sp, 0xF000
    li   s0, DEVICES
    la   t0, handler
    csrw mtvec, t0
    li   s1, 0                # ticks (handler)
    call reset_array
    call work
    mv   s2, a0               # checksum without interrupts
    call reset_array
    ld   t0, MTIME(s0)
    addi t0, t0, 20
    sd   t0, MTIMECMP(s0)
    li   t0, 0x80
    csrw mie, t0
    csrsi mstatus, 8          # interrupts on
    call work
    csrci mstatus, 8
    mv   s3, a0               # checksum with interrupts
    li   a0, 0
    bne  s2, s3, done
    li   a0, 1
done:
    csrr a1, hpmcounter9
    mv   a2, s1
    halt

reset_array:                  # array[i] = i * 0x9E3779B97F4A7C15 for i = 0..15
    la   t0, array
    li   t1, 0
    li   t2, 0x9E3779B97F4A7C15
    li   t3, 16
reset_loop:
    mul  t4, t1, t2
    sd   t4, 0(t0)
    addi t0, t0, 8
    addi t1, t1, 1
    bne  t1, t3, reset_loop
    ret

work:                         # returns a checksum in a0; uses a0 a3-a7 t0-t4 and the stack
    addi sp, sp, -16
    sd   ra, 8(sp)
    li   a0, 0
    li   a3, 0                # i
    li   a4, 120
work_loop:
    andi t0, a3, 15
    la   t1, array
    sh3add t1, t0, t1         # &array[i % 16]
    ld   t2, 0(t1)
    cpop t3, t2
    add  a0, a0, t3
    bseti t4, t2, 5
    bext t3, t2, a3
    add  a0, a0, t3
    xor  t2, t2, a0
    sd   t2, 0(t1)
    mv   a5, t2
    call mix                  # a call and a return: the return address stack must survive interrupts
    add  a0, a0, a5
    andi t0, a3, 7
    bnez t0, no_divide
    li   t0, 7
    remu t0, a0, t0
    add  a0, a0, t0
    divu t0, a0, a4
    add  a0, a0, t0
no_divide:
    csrw mscratch, a0         # a CSR write (interrupts wait for it)
    csrr t0, mscratch
    add  a0, a0, t0
    srli a0, a0, 1
    andi t0, a3, 3
    beqz t0, skip             # a data-dependent branch
    addi a0, a0, 3
skip:
    addi a3, a3, 1
    blt  a3, a4, work_loop
    ld   ra, 8(sp)
    addi sp, sp, 16
    ret

mix:                          # a5 = a5 * 31 ^ (a5 >> 7)
    li   a6, 31
    mul  a7, a5, a6
    srli a6, a5, 7
    xor  a5, a7, a6
    ret

handler:                      # uses only s1, t5, t6
    addi s1, s1, 1
    ld   t5, MTIMECMP(s0)
    andi t6, s1, 31           # next period: 17 + (ticks % 31)
    addi t6, t6, 17
    add  t5, t5, t6
    sd   t5, MTIMECMP(s0)
    ld   t6, MTIME(s0)        # never schedule in the past (a long divide may run through a tick)
    blt  t6, t5, handler_done
    addi t5, t6, 17
    sd   t5, MTIMECMP(s0)
handler_done:
    mret

    .align 3
array:
    .zero 128
