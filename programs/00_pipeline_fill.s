# =============================================================================
# 00_pipeline_fill.s — watch an empty pipeline fill up
#
# Four INDEPENDENT instructions: no instruction needs another's result, so
# nothing ever waits. Instruction 1 enters IF in cycle 1 and leaves WB in
# cycle 6; after that one instruction finishes every cycle.
#
#   What to look for:  the diagonal "staircase" in the pipeline chart,
#                      and that the first result needs 6 cycles (latency)
#                      while later ones arrive every cycle (throughput).
# EXPECT: a0 = 10
# EXPECT: a1 = 20
# EXPECT: a2 = 30
# EXPECT: a3 = 40
# =============================================================================
    addi a0, zero, 10
    addi a1, zero, 20
    addi a2, zero, 30
    addi a3, zero, 40
    ecall                   # halt: the simulator stops when this reaches WB
