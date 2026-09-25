# =============================================================================
# 11_gshare_patterns.s: a branch that ALTERNATES taken / not-taken
#
# A per-branch 2-bit counter ("bimodal", Smith 1981) cannot learn T,N,T,N:
# the counter just wobbles between weak states and guesses wrong about half
# the time. gshare XORs the global history into the table index, so
# "last outcome was T" and "last outcome was N" use DIFFERENT counters.
# Each counter then sees a constant direction and trains to it.
#
# Compare (model):  node tools/rv.mjs bp programs/11_gshare_patterns.s
#
# EXPECT: a0 = 100
# EXPECT: a1 = 100
# =============================================================================
    li   t0, 200         # iterations
    li   a0, 0           # even count
    li   a1, 0           # odd count
loop:
    andi t1, t0, 1
    beqz t1, even        # alternates: taken, not taken, taken, ...
    addi a1, a1, 1       # odd
    j    next
even:
    addi a0, a0, 1
next:
    addi t0, t0, -1
    bnez t0, loop        # taken 199 times, then falls through
    halt
