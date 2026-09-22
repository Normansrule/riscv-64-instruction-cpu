# =============================================================================
# 02_forwarding.s — a chain of dependent instructions with ZERO stalls
#
# Each instruction needs the result of the one right before it. Without
# forwarding the pipeline would wait until the producer reached WB (3 extra
# cycles per instruction). The forward unit instead routes the value from the
# EX/MEM latch (1 instruction back) or the MEM/WB latch (2 back) straight
# into the ALU inputs.
#
#   What to look for: "fwd A: MEM" / "fwd A: WB" markers in the EX stage,
#                     and CPI = cycles / instructions staying low.
# EXPECT: a0 = 26
# EXPECT: a1 = 7
# =============================================================================
    li   a0, 1
    addi a0, a0, 2       # a0 = 3     needs a0 from 1 instr ago -> fwd from EX/MEM
    add  a0, a0, a0      # a0 = 6     again EX/MEM
    li   a1, 7           # independent
    add  a0, a0, a1      # a0 = 13    a1 from EX/MEM, a0 from MEM/WB
    slli a0, a0, 1       # a0 = 26
    ecall
