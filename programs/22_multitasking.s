# =============================================================================
# 22_multitasking.s: a tiny preemptive operating-system kernel, three tasks
#
# Three programs share one CPU. None of them knows about the others: every 600
# cycles the machine timer interrupts whichever is running, and the kernel's
# handler SAVES all 31 of its registers and its PC (mepc) into its task control
# block, picks the next task (round robin), RESTORES that task's registers and
# PC, and returns into it with mret. That is a context switch, the heart of
# every multitasking operating system.
#
#   task 0: counts the primes below 500 (trial division: a lot of remu)
#   task 1: adds up the squares 1..400
#   task 2: prints four lines, with a delay loop between them
# A task that finishes stores its result, marks itself done and sleeps; when all
# three are done the kernel collects the results and halts.
#   a0 = primes below 500 (95), a1 = 1^2 + ... + 400^2 (21,413,400)
#   a2 = lines task 2 printed (4), a3 = context switches (hpmcounter9)
# mscratch always holds the address of the running task's control block, so the
# handler can save the first register before it has any free register to use.
# REGIONS: task0=task0 task1=task1 task2=task2 kernel=kernel_start asleep=task_done
# EXPECT: a0 = 95
# EXPECT: a1 = 21413400
# EXPECT: a2 = 4
# =============================================================================
    .equ DEVICES,  0x10000000
    .equ MTIME,    0x58
    .equ MTIMECMP, 0x60
    .equ QUANTUM,  600            # cycles each task runs before the next one's turn
    .equ TCB_SIZE, 272            # 31 registers + pc + done flag + next pointer, 8 bytes each
    .equ TCB_PC,   248
    .equ TCB_DONE, 256
    .equ TCB_NEXT, 264

# ---------------------------------------------------------------- the kernel starts here
kernel_start:
    la   t0, trap_handler
    csrw mtvec, t0
    # set up three task control blocks: entry point, stack, and a ring of next pointers
    la   t0, tcb0
    la   t1, task0
    sd   t1, TCB_PC(t0)
    li   t1, 0xE000
    sd   t1, 8(t0)                # x2 = sp
    la   t1, tcb1
    sd   t1, TCB_NEXT(t0)
    la   t0, tcb1
    la   t1, task1
    sd   t1, TCB_PC(t0)
    li   t1, 0xD000
    sd   t1, 8(t0)
    la   t1, tcb2
    sd   t1, TCB_NEXT(t0)
    la   t0, tcb2
    la   t1, task2
    sd   t1, TCB_PC(t0)
    li   t1, 0xC000
    sd   t1, 8(t0)
    la   t1, tcb0
    sd   t1, TCB_NEXT(t0)
    # the timer: first switch QUANTUM cycles from now
    li   t0, DEVICES
    ld   t1, MTIME(t0)
    addi t1, t1, QUANTUM
    sd   t1, MTIMECMP(t0)
    li   t1, 0x80
    csrw mie, t1                  # mie.MTIE
    # "return" into task 0 as if it had been interrupted: mret sets MIE from MPIE
    la   t6, tcb0
    li   t0, 0x80
    csrs mstatus, t0              # MPIE = 1, so interrupts are on inside the task
    j    restore

# ---------------------------------------------------------------- the timer interrupt: a context switch
trap_handler:
    csrrw t6, mscratch, t6        # t6 = this task's control block, mscratch = the task's t6
    sd   x1, 0(t6)
    sd   x2, 8(t6)
    sd   x3, 16(t6)
    sd   x4, 24(t6)
    sd   x5, 32(t6)
    sd   x6, 40(t6)
    sd   x7, 48(t6)
    sd   x8, 56(t6)
    sd   x9, 64(t6)
    sd   x10, 72(t6)
    sd   x11, 80(t6)
    sd   x12, 88(t6)
    sd   x13, 96(t6)
    sd   x14, 104(t6)
    sd   x15, 112(t6)
    sd   x16, 120(t6)
    sd   x17, 128(t6)
    sd   x18, 136(t6)
    sd   x19, 144(t6)
    sd   x20, 152(t6)
    sd   x21, 160(t6)
    sd   x22, 168(t6)
    sd   x23, 176(t6)
    sd   x24, 184(t6)
    sd   x25, 192(t6)
    sd   x26, 200(t6)
    sd   x27, 208(t6)
    sd   x28, 216(t6)
    sd   x29, 224(t6)
    sd   x30, 232(t6)
    csrr t0, mscratch
    sd   t0, 240(t6)              # the task's own t6 (x31)
    csrr t0, mepc
    sd   t0, TCB_PC(t6)           # where the task was interrupted
    # next timer tick
    li   t0, DEVICES
    ld   t1, MTIMECMP(t0)
    addi t1, t1, QUANTUM
    sd   t1, MTIMECMP(t0)
    # all three done? then collect the results and stop
    la   t0, tcb0
    ld   t1, TCB_DONE(t0)
    la   t0, tcb1
    ld   t2, TCB_DONE(t0)
    and  t1, t1, t2
    la   t0, tcb2
    ld   t2, TCB_DONE(t0)
    and  t1, t1, t2
    bnez t1, all_done
    # round robin: the next task whose done flag is 0
    ld   t6, TCB_NEXT(t6)
    ld   t1, TCB_DONE(t6)
    beqz t1, restore
    ld   t6, TCB_NEXT(t6)
    ld   t1, TCB_DONE(t6)
    beqz t1, restore
    ld   t6, TCB_NEXT(t6)
restore:                          # t6 = the control block of the task to run
    csrw mscratch, t6
    ld   t0, TCB_PC(t6)
    csrw mepc, t0
    ld   x1, 0(t6)
    ld   x2, 8(t6)
    ld   x3, 16(t6)
    ld   x4, 24(t6)
    ld   x5, 32(t6)
    ld   x6, 40(t6)
    ld   x7, 48(t6)
    ld   x8, 56(t6)
    ld   x9, 64(t6)
    ld   x10, 72(t6)
    ld   x11, 80(t6)
    ld   x12, 88(t6)
    ld   x13, 96(t6)
    ld   x14, 104(t6)
    ld   x15, 112(t6)
    ld   x16, 120(t6)
    ld   x17, 128(t6)
    ld   x18, 136(t6)
    ld   x19, 144(t6)
    ld   x20, 152(t6)
    ld   x21, 160(t6)
    ld   x22, 168(t6)
    ld   x23, 176(t6)
    ld   x24, 184(t6)
    ld   x25, 192(t6)
    ld   x26, 200(t6)
    ld   x27, 208(t6)
    ld   x28, 216(t6)
    ld   x29, 224(t6)
    ld   x30, 232(t6)
    ld   x31, 240(t6)             # last: t6 itself
    mret                          # into the task, interrupts on again (MIE = MPIE)

all_done:
    la   t0, results
    ld   a0, 0(t0)
    ld   a1, 8(t0)
    ld   a2, 16(t0)
    csrr a3, hpmcounter9
    halt

# ---------------------------------------------------------------- the tasks: ordinary programs
task_done:                        # a0 = the result slot to fill, a1 = the value, a2 = my control block
    sd   a1, 0(a0)
    li   t0, 1
    sd   t0, TCB_DONE(a2)
sleep:
    wfi
    j    sleep                    # until the kernel switches away (and never back)

task0:                            # count the primes below 500 by trial division
    li   s0, 0
    li   s1, 2
t0_next:
    li   s2, 2
t0_try:
    mul  t0, s2, s2
    bgt  t0, s1, t0_prime
    remu t0, s1, s2
    beqz t0, t0_composite
    addi s2, s2, 1
    j    t0_try
t0_prime:
    addi s0, s0, 1
t0_composite:
    addi s1, s1, 1
    li   t0, 500
    blt  s1, t0, t0_next
    la   a0, results
    mv   a1, s0
    la   a2, tcb0
    j    task_done

task1:                            # 1^2 + 2^2 + ... + 400^2, with a call per term
    li   s0, 0
    li   s1, 1
t1_loop:
    mv   a0, s1
    call square
    add  s0, s0, a0
    addi s1, s1, 1
    li   t0, 400
    ble  s1, t0, t1_loop
    la   a0, results + 8
    mv   a1, s0
    la   a2, tcb1
    j    task_done
square:
    mul  a0, a0, a0
    ret

task2:                            # print four lines, slowly
    li   s0, DEVICES
    li   s1, 0
t2_line:
    la   t1, message
t2_char:
    lbu  t2, 0(t1)
    beqz t2, t2_end
    sb   t2, 0(s0)
    addi t1, t1, 1
    j    t2_char
t2_end:
    addi t2, s1, '1'
    sb   t2, 0(s0)                # the line number
    li   t2, 10
    sb   t2, 0(s0)
    addi s1, s1, 1
    li   t3, 300                  # a delay loop: the other tasks run meanwhile
t2_delay:
    addi t3, t3, -1
    bnez t3, t2_delay
    li   t0, 4
    blt  s1, t0, t2_line
    la   a0, results + 16
    mv   a1, s1
    la   a2, tcb2
    j    task_done

message:
    .string "task 2 says hello, line "
    .align 3
results:
    .zero 24
tcb0:
    .zero 272
tcb1:
    .zero 272
tcb2:
    .zero 272
