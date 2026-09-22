# =============================================================================
# 04_branch_penalty.s — what a taken branch costs in a 6-stage pipe
#
# The core predicts "not taken" and keeps fetching the next instructions.
# Branches resolve in EX (stage 4), so when one IS taken, the 3 younger
# instructions in IF, ID and RR are wrong and get flushed.
#
# This loop runs 10 times: 9 taken branches x 3 flushed slots = 27 wasted
# cycles. Try it: change the count and watch "flushed" in the summary.
#
# EXPECT: a0 = 55
# EXPECT: t0 = 0
# =============================================================================
    li   t0, 10          # loop counter
    li   a0, 0           # sum
loop:
    add  a0, a0, t0      # sum += counter
    addi t0, t0, -1
    bnez t0, loop        # TAKEN 9 times -> 3 flushes each
    ecall
