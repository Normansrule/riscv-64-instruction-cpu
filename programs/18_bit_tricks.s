# =============================================================================
# 18_bit_tricks.s: the Zba and Zbb extensions, measured against plain RV64I code
#
# Zbb ("basic bit manipulation") and Zba ("address generation") are in every
# current RISC-V application processor (the RVA22 and RVA23 profiles require
# them). Each replaces a small loop or a few instructions with ONE instruction:
#
#   a0 / a1 : count the 1 bits of 0x0123456789ABCDEF: a 64-trip loop vs cpop
#   a2      : the answer (32), checked
#   a3      : strlen("Sixfold, a RISC-V CPU!") with orc.b + ctz (8 bytes per step)
#   a4 / a5 : cycles for that strlen: byte by byte vs 8 bytes at a time
#   a6      : the largest of 8 signed numbers with max (no branches to mispredict)
#   a7      : sum of array[i] with sh3add (address = base + i * 8 in one instruction)
#
# cpop, min and max have a 2-cycle latency on Sixfold (src/ALU.sv explains why);
# the loops below are arranged so nothing has to wait for them.
# EXPECT: a2 = 32
# EXPECT: a3 = 22
# EXPECT: a6 = 109
# EXPECT: a7 = 204
# =============================================================================
    li   s0, 0x0123456789ABCDEF
    nop
    nop
    nop
    # ---------------- popcount, RV64I: test every bit ----------------
    rdcycle t5
    mv   t0, s0
    li   t1, 0               # count
    li   t2, 64
pop_loop:
    andi t3, t0, 1
    add  t1, t1, t3
    srli t0, t0, 1
    addi t2, t2, -1
    bnez t2, pop_loop
    rdcycle t6
    sub  a0, t6, t5          # a0 = cycles for the loop
    mv   s1, t1
    # ---------------- popcount, Zbb: one instruction ----------------
    rdcycle t5
    cpop t1, s0
    rdcycle t6
    sub  a1, t6, t5          # a1 = cycles for cpop (the rdcycle pair itself costs a few)
    sub  t4, t1, s1
    bnez t4, fail            # both methods must agree
    mv   a2, t1

    # ---------------- strlen, byte by byte ----------------
    la   s2, text
    rdcycle t5
    mv   t0, s2
byte_loop:
    lbu  t1, 0(t0)
    beqz t1, byte_done
    addi t0, t0, 1
    j    byte_loop
byte_done:
    sub  s3, t0, s2
    rdcycle t6
    sub  a4, t6, t5
    # ---------------- strlen, 8 bytes per step (orc.b finds a zero byte) ----------------
    rdcycle t5
    mv   t0, s2
word_loop:
    ld   t1, 0(t0)
    orc.b t2, t1             # 0xFF in every byte that is NOT zero
    not  t2, t2              # ... so now 0xFF marks the zero bytes
    bnez t2, word_found
    addi t0, t0, 8
    j    word_loop
word_found:
    ctz  t2, t2              # bit position of the first zero byte (little-endian)
    srli t2, t2, 3           # ... as a byte index
    sub  t0, t0, s2
    add  a3, t0, t2
    rdcycle t6
    sub  a5, t6, t5
    sub  t4, a3, s3
    bnez t4, fail

    # ---------------- max without branches ----------------
    la   t0, numbers
    ld   a6, 0(t0)
    li   t1, 1
max_loop:
    sh3add t2, t1, t0        # t2 = numbers + t1 * 8
    ld   t3, 0(t2)
    addi t1, t1, 1
    max  a6, a6, t3
    li   t4, 8
    bne  t1, t4, max_loop

    # ---------------- sum with sh3add ----------------
    li   a7, 0
    li   t1, 0
sum_loop:
    sh3add t2, t1, t0
    ld   t3, 0(t2)
    addi t1, t1, 1
    add  a7, a7, t3
    li   t4, 8
    bne  t1, t4, sum_loop
    halt
fail:
    li   a2, -1
    halt

    .align 3
text:
    .string "Sixfold, a RISC-V CPU!"
    .zero 16
    .align 3
numbers:
    .dword 42, -7, 19, 88, 0, 3, -50, 109
