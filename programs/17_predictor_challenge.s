# =============================================================================
# 17_predictor_challenge.s: branches that need history, and a branch that needs OTHER branches
#
# 300 loop iterations, three branches in each:
#   b1 is taken when i mod 7 < 3      (a period-7 pattern: T T T N N N N)
#   b2 is taken when i mod 3 != 0     (a period-3 pattern: N T T)
#   b3 is taken when b1 and b2 went the SAME way: it is predictable only by
#      looking at the two branches just before it (correlation)
#
# A per-branch counter (BHT) cannot learn any of these well. Predictors that
# look at global history (gshare, perceptron, TAGE) can. Compare them in the
# predictor arena:  node tools/predictor_arena.mjs  (or the site's arena).
#
# EXPECT: a0 = 999
# =============================================================================
    li   s0, 300             # iterations
    li   s1, 0               # i mod 7
    li   s2, 0               # i mod 3
    li   a0, 0               # a checksum of the paths taken
loop:
    li   t0, 3
    blt  s1, t0, b1_taken    # b1: taken when i mod 7 < 3
    addi a0, a0, 1
b1_taken:
    bnez s2, b2_taken        # b2: taken when i mod 3 != 0
    addi a0, a0, 2
b2_taken:
    slti t1, s1, 3           # t1 = b1's direction
    sltiu t2, s2, 1          # t2 = 1 when i mod 3 == 0 (b2 NOT taken)
    xori t2, t2, 1           # t2 = b2's direction
    beq  t1, t2, b3_taken    # b3: taken when b1 and b2 agreed
    addi a0, a0, 4
b3_taken:
    addi s1, s1, 1
    li   t0, 7
    bne  s1, t0, keep7
    li   s1, 0
keep7:
    addi s2, s2, 1
    li   t0, 3
    bne  s2, t0, keep3
    li   s2, 0
keep3:
    addi s0, s0, -1
    bnez s0, loop
    halt
