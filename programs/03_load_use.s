# =============================================================================
# 03_load_use.s: the one data hazard forwarding cannot fix
#
# The data memory is read at the end of EXECUTE and the value only exists in
# the MEMORY stage. An instruction in DECODE that needs the loaded register
# while the load is still in EXECUTE would forward garbage, so LOAD_STALL
# holds FETCH1, FETCH2 and DECODE for one cycle and sends a NOP into EXECUTE.
# One cycle later the load is in MEMORY and its data is forwarded.
#
# Part A uses the value right away (2 stalls). Part B does the same work
# but puts an independent instruction between each load and its use,
# as a compiler would (0 stalls). Compare "load stalls" in the summary.
#
# EXPECT: a0 = 300
# EXPECT: a1 = 300
# =============================================================================
    la   s0, data
# ---- Part A: naive order ------------------------------------------------------
    ld   t0, 0(s0)
    add  a0, t0, zero        # LOAD_STALL: needs t0 while the load is in EXECUTE
    ld   t1, 8(s0)
    add  a0, a0, t1          # STALL again
# ---- Part B: scheduled order ------------------------------------------------
    ld   t2, 0(s0)
    ld   t3, 8(s0)           # independent work fills the gap
    add  a1, t2, zero        # t2's load is now in MEMORY -> forwarded, no stall
    add  a1, a1, t3          # t3 was loaded 2 instructions ago -> in MEMORY, no stall
    halt

    .align 3
data:
    .dword 100, 200
