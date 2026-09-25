# =============================================================================
# 04_branch_penalty.s: what a branch costs in this 6-stage pipe
#
# Branches are RESOLVED in EXECUTE (stage 4), but GUESSED much earlier:
#   * FETCH1 reads the gshare counter; FETCH2 sees the instruction is a branch.
#     Predicted taken -> FETCH2 redirects to the target: 1 bubble (REDIRECT).
#   * If the guess was wrong, EXECUTE flushes FETCH1, FETCH2 and DECODE and
#     restarts at the right address: 3 bubbles (FLUSH).
#
# This loop's branch is taken 9 times, then falls through once.
#   predictor off (always not taken): 9 wrong guesses x 3 = 27 bubbles
#   gshare:  9 correct "taken" guesses x 1 + 1 wrong guess x 3 = 12 bubbles
# Run both:  node tools/rv.mjs run programs/04_branch_penalty.s --bp=off
#
# EXPECT: a0 = 55
# EXPECT: t0 = 0
# =============================================================================
    li   t0, 10          # loop counter
    li   a0, 0           # sum
loop:
    add  a0, a0, t0      # sum += counter
    addi t0, t0, -1
    bnez t0, loop        # taken 9 times, not taken once
    halt
