# =============================================================================
# 12_measure_cpi.s: a program that measures its OWN performance
#
# The CSR file has two read-only counters (src/Control_Status_Register_File.sv):
#   cycle   (rdcycle)   : clock cycles since reset
#   instret (rdinstret) : instructions retired (finished in WRITEBACK) since reset
# Reading both before and after a loop gives the loop's cycles, instructions
# and therefore its CPI = cycles / instructions, the most important number in
# computer architecture. Real RISC-V chips expose the same counters.
#
#   a0 = cycles between the two rdcycle reads
#   a1 = instructions retired between the two rdinstret reads
#   a2 = CPI x 100 (integer, computed with the M extension divider)
#
# The loop is 20 x 4 = 80 instructions, yet a1 is 82 or 83: the counters are
# READ in EXECUTE but instret COUNTS in WRITEBACK, so a few instructions that
# were still in flight around the reads land inside the window. Real CPUs have
# the same effect, which is why benchmarks measure long loops.
# The values are exact and repeatable because the pipeline is deterministic:
# `make test` checks them against BOTH the model and the RTL.
# EXPECT[gshare]: a0 = 104
# EXPECT[gshare]: a1 = 83
# EXPECT[gshare]: a2 = 125
# EXPECT[bp-off]: a0 = 139
# EXPECT[bp-off]: a1 = 82
# EXPECT[bp-off]: a2 = 169
# =============================================================================
    li   t0, 20              # loop 20 times
    li   t1, 0
    nop                      # let earlier bubbles drain before the first read
    nop
    nop
    rdcycle   s0             # start the stopwatch
    rdinstret s1
loop:
    addi t1, t1, 3           # 4 instructions per iteration
    xori t2, t1, 5
    addi t0, t0, -1
    bnez t0, loop
    rdcycle   s2             # stop the stopwatch
    rdinstret s3
    sub  a0, s2, s0          # cycles
    sub  a1, s3, s1          # instructions
    li   t3, 100
    mul  a2, a0, t3
    divu a2, a2, a1          # CPI x 100
    halt
