# =============================================================================
# 13_function_call_cost.s: why function calls are not free on this pipeline
#
#   call square  = jal ra, square : FETCH2 knows the target from the
#                  instruction bits -> redirect, 1 bubble
#   ret          = jalr x0, 0(ra)  : the target is in a REGISTER, only known in
#                  EXECUTE -> BranchControl always flushes, 3 bubbles
#
# The same work is done twice, measured with rdcycle:
#   a0 = cycles for 8 calls to square()
#   a1 = cycles for the same 8 squares written inline
#   a2 = a0 - a1 = the price of calling: 56 / 8 = 7 cycles per call
#        = 1 redirect bubble + 3 flush bubbles + the mv, jal and ret instructions
# The performance edition fixes both: the Branch Target Buffer makes "call" free
# (0 bubbles) and the Return Address Stack predicts "ret" in FETCH2 (1 bubble, no
# flush): 56 -> 33 cycles for 8 calls. But its multiply takes 7 cycles instead of
# 1 (for a faster clock), so the inline loop gets slower: 43 -> 85. A real trade-off.
#
# EXPECT: a3 = 204
# EXPECT: a4 = 204
# EXPECT[gshare]: a0 = 99
# EXPECT[gshare]: a1 = 43
# EXPECT[gshare]: a2 = 56
# EXPECT[bp-off]: a0 = 110
# EXPECT[bp-off]: a1 = 54
# EXPECT[bp-off]: a2 = 56
# EXPECT[perf]: a0 = 118
# EXPECT[perf]: a1 = 85
# EXPECT[perf]: a2 = 33
# EXPECT[perf-bp-off]: a0 = 135
# EXPECT[perf-bp-off]: a1 = 102
# EXPECT[perf-bp-off]: a2 = 33
# =============================================================================
    li   sp, 0xF000
    li   s4, 0               # sum of squares (called version)
    li   s5, 8
    li   a0, 1
    call square              # warm-up call: brings square() into the instruction cache
    nop
    nop
    nop
    rdcycle s0
call_loop:
    mv   a0, s5
    call square              # jal ra, square
    add  s4, s4, a0
    addi s5, s5, -1
    bnez s5, call_loop
    rdcycle s1
    li   s6, 0               # sum of squares (inline version)
    li   s5, 8
    nop
    nop
    nop
    rdcycle s2
inline_loop:
    mul  t0, s5, s5
    add  s6, s6, t0
    addi s5, s5, -1
    bnez s5, inline_loop
    rdcycle s3
    mv   a3, s4              # 1+4+9+...+64 = 204
    mv   a4, s6
    sub  a0, s1, s0
    sub  a1, s3, s2
    sub  a2, a0, a1
    halt

square:                      # a0 = a0 * a0
    mul  a0, a0, a0
    ret                      # jalr x0, 0(ra): always a 3-bubble flush
