# =============================================================================
# 10_print_numbers.s — print Fibonacci numbers in decimal using DIVU/REMU
#
# Converting a binary number to text is repeated division by 10: REMU gives
# the last digit, DIVU drops it. Digits come out backwards, so they are
# pushed into a buffer and printed in reverse.
#
# EXPECT-OUTPUT: 0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610\n
# EXPECT: s2 = 16
# =============================================================================
    li   sp, 0xF000
    li   s3, 0x10000000      # putchar
    li   s0, 0               # a = 0
    li   s1, 1               # b = 1
    li   s2, 0               # count
    li   s4, 16              # how many to print
next:
    mv   a0, s0
    call print_u64
    add  t0, s0, s1
    mv   s0, s1
    mv   s1, t0
    addi s2, s2, 1
    li   t1, ' '
    li   t2, '\n'
    bne  s2, s4, sep
    mv   t1, t2
sep:
    sb   t1, 0(s3)
    bne  s2, s4, next
    ecall

# print_u64(a0): print a0 as unsigned decimal
print_u64:
    addi t3, sp, -32         # t3 = end of a scratch buffer below the stack
    mv   t4, t3
    li   t5, 10
digit:
    remu t6, a0, t5          # t6 = a0 % 10
    divu a0, a0, t5          # a0 = a0 / 10
    addi t6, t6, '0'
    addi t4, t4, -1
    sb   t6, 0(t4)
    bnez a0, digit
out:
    lbu  t6, 0(t4)
    sb   t6, 0(s3)
    addi t4, t4, 1
    bne  t4, t3, out
    ret
