# =============================================================================
# 03_load_use.s — the one hazard forwarding cannot fix
#
# A load only has its data at the END of MEM. An instruction that uses the
# loaded register immediately is already in EX by then, too late. The hazard
# unit freezes IF/ID/RR for one cycle and injects a bubble into EX.
#
# Part A uses the value right away (2 stalls). Part B does the same work
# but schedules an independent instruction between each load and its use,
# as a compiler would (0 stalls). Compare "load-use stalls" in the summary.
#
# EXPECT: a0 = 300
# EXPECT: a1 = 300
# =============================================================================
    la   s0, data
# ---- Part A: naive order ------------------------------------------------------
    ld   t0, 0(s0)
    add  a0, t0, zero        # STALL: needs t0 from the load in EX
    ld   t1, 8(s0)
    add  a0, a0, t1          # STALL again
# ---- Part B: scheduled order ------------------------------------------------
    ld   t2, 0(s0)
    ld   t3, 8(s0)           # independent work fills the gap
    add  a1, t2, zero        # t2's load is now in MEM -> forwarded, no stall
    add  a1, a1, t3          # still a stall? t3 was loaded 2 instrs ago -> no
    ecall

    .align 3
data:
    .dword 100, 200
