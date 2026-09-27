# =============================================================================
# 16_cache_conflicts.s: why caches have "ways"
#
# The data cache has 64 SETS; address bits [10:5] choose the set. Addresses
# exactly 2 KiB (0x800) apart land in the SAME set. Each set has 2 WAYS, so it
# can hold two such lines at once; the third one forces an eviction of the
# least recently used line.
#
#   loop A: reads arrays at 0x8000 and 0x8800        -> 2 lines per set: fit
#   loop B: reads arrays at 0x8000, 0x8800, 0x9000   -> 3 lines per set: every
#           access evicts the line needed next ("thrashing")
#
# Both loops do 4 passes over 2 lines of each array; a0 and a1 time them with
# rdcycle. After loop A's first pass everything hits; loop B misses forever.
# On the baseline build (no caches) both loops cost the same per load.
#
# EXPECT[gshare]: a0 = 86
# EXPECT[gshare]: a1 = 102
# EXPECT[bp-off]: a0 = 91
# EXPECT[bp-off]: a1 = 107
# EXPECT[perf]: a0 = 134
# EXPECT[perf]: a1 = 334
# EXPECT[perf-bp-off]: a0 = 138
# EXPECT[perf-bp-off]: a1 = 338
# =============================================================================
    li   s0, 0x8000          # array A
    li   s1, 0x8800          # array B: same sets as A (2 KiB apart)
    li   s2, 0x9000          # array C: same sets again
    nop
    nop
    nop
    rdcycle t5
    li   t0, 4               # loop A: 4 passes, 2 arrays
passA:
    li   t1, 0
lineA:
    add  t2, s0, t1
    ld   t3, 0(t2)
    add  t2, s1, t1
    ld   t3, 0(t2)
    addi t1, t1, 32          # next line (32 bytes)
    li   t4, 64
    blt  t1, t4, lineA       # 2 lines per array
    addi t0, t0, -1
    bnez t0, passA
    rdcycle t6
    sub  a0, t6, t5          # cycles for loop A
    nop
    nop
    nop
    rdcycle t5
    li   t0, 4               # loop B: 4 passes, 3 arrays
passB:
    li   t1, 0
lineB:
    add  t2, s0, t1
    ld   t3, 0(t2)
    add  t2, s1, t1
    ld   t3, 0(t2)
    add  t2, s2, t1
    ld   t3, 0(t2)
    addi t1, t1, 32
    li   t4, 64
    blt  t1, t4, lineB
    addi t0, t0, -1
    bnez t0, passB
    rdcycle t6
    sub  a1, t6, t5          # cycles for loop B
    halt
