# =============================================================================
# 15_system_calls.s: traps, the way an operating system gets control
#
# "ecall" asks for a service. The CPU does not run the next instruction;
# instead, in EXECUTE it
#   1. saves the ecall's address in mepc and the reason (11 = ecall) in mcause,
#   2. jumps to the address in mtvec: the TRAP HANDLER (the "kernel"),
# which looks at a7 to see what was asked for, does it, moves mepc past the
# ecall (+4) and executes "mret" to jump back. Every real OS starts this way.
#
# This tiny kernel offers two services:
#   a7 = 1 : print the character in a0
#   a7 = 2 : return a0 + a1 in a0
# Each ecall and each mret flushes the pipeline (3 bubbles), like a JALR.
#
# EXPECT-OUTPUT: OK\n
# EXPECT: a0 = 42
# EXPECT: s2 = 4
# EXPECT: s3 = 11
# =============================================================================
    la   t0, kernel
    csrw mtvec, t0           # traps go to "kernel"
    li   s2, 0               # number of system calls handled (counted by the kernel)
    li   a7, 1               # service 1: print a character
    li   a0, 79              # 'O'
    ecall
    li   a0, 75              # 'K'
    ecall
    li   a0, 10              # newline
    ecall
    li   a7, 2               # service 2: add
    li   a0, 40
    li   a1, 2
    ecall                    # a0 = 42
    csrr s3, mcause          # 11: environment call
    halt

kernel:                      # the trap handler
    addi s2, s2, 1
    li   t1, 1
    beq  a7, t1, print
    add  a0, a0, a1          # service 2
    j    done
print:
    li   t2, 0x10000000      # memory-mapped character output
    sb   a0, 0(t2)
done:
    csrr t3, mepc            # return to the instruction AFTER the ecall
    addi t3, t3, 4
    csrw mepc, t3
    mret
