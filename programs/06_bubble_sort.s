# =============================================================================
# 06_bubble_sort.s — sort 10 signed 64-bit numbers in memory
#
# Lots of loads, stores, compares and branches: a realistic mix to study
# CPI. Afterwards a0 = 1 if the array is sorted ascending, and a1 is a
# position-weighted checksum (sum of (i+1) * array[i]) that only matches
# if every element landed in the right slot.
#
# EXPECT: a0 = 1
# EXPECT: a1 = 2097
# =============================================================================
    la   s0, array
    li   s1, 10              # n
outer:
    li   t0, 0               # swapped = 0
    li   t1, 1               # i = 1
inner:
    bge  t1, s1, inner_done
    slli t2, t1, 3           # byte offset = i * 8
    add  t2, s0, t2
    ld   t3, -8(t2)          # array[i-1]
    ld   t4, 0(t2)           # array[i]
    ble  t3, t4, no_swap
    sd   t4, -8(t2)
    sd   t3, 0(t2)
    li   t0, 1
no_swap:
    addi t1, t1, 1
    j    inner
inner_done:
    bnez t0, outer
# ---- verify ------------------------------------------------------------------
    li   a0, 1
    li   a1, 0
    li   t1, 0
check:
    bge  t1, s1, finished
    slli t2, t1, 3
    add  t2, s0, t2
    ld   t3, 0(t2)
    addi t5, t1, 1
    mul  t6, t3, t5
    add  a1, a1, t6          # checksum += (i+1) * array[i]
    beqz t1, next
    ld   t4, -8(t2)
    ble  t4, t3, next
    li   a0, 0               # out of order!
next:
    addi t1, t1, 1
    j    check
finished:
    ecall

    .align 3
array:
    .dword 42, -7, 19, 88, 0, 3, -50, 61, 19, 25
