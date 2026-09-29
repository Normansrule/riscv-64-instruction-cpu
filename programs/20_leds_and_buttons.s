# =============================================================================
# 20_leds_and_buttons.s: talking to devices (memory-mapped I/O) and Zbs
#
# Addresses 0x1000_0000 .. 0x1000_00FF are not memory but device registers
# (docs/FPGA.md has the full map). A store to 0x1000_0008 sets the 8 LEDs; a
# load from 0x1000_0010 reads the buttons; 0x1000_0028 holds the clock rate.
# On the FPGA board a light sweeps back and forth across the LEDs, one step
# every 1/8 second, until you press a button (or after 48 steps).
# In simulation the buttons read 0 and the clock rate reads 0, so the delay is
# zero and all 48 steps run in a few hundred cycles (same instructions, same
# answer): the web lab shows the LEDs as they change.
# FPGA: reads the clock rate, so on the board it runs about 6 seconds, not 1196 cycles
#
# The single-bit instructions (Zbs) do the bit work:
#   bset  rd, rs1, rs2   set bit rs2        binv  rd, rs1, rs2   flip bit rs2
#   bclr  rd, rs1, rs2   clear bit rs2      bext  rd, rs1, rs2   read bit rs2
#
#   a0 = steps taken (48 when no button is pressed)
#   a1 = "visited an odd number of times" mask: bit i flips each time the light is on LED i
#   a2 = bit 3 of a1, extracted with bexti
# EXPECT: a0 = 48
# EXPECT: a1 = 190
# EXPECT: a2 = 1
# =============================================================================
    li   s0, 0x10000000      # the device registers
    la   t0, message
print:
    lbu  t1, 0(t0)
    beqz t1, printed
    sb   t1, 0(s0)           # PUTCHAR
    addi t0, t0, 1
    j    print
printed:
    ld   s1, 0x28(s0)        # CLOCK: cycles per second (0 in simulation)
    srli s1, s1, 3           # one step every 1/8 second
    li   s2, 0               # position of the light (0..7)
    li   s3, 1               # direction: +1 or -1
    li   a0, 0               # steps
    li   a1, 0               # visit parity mask
    li   s4, 48
step:
    bset t0, zero, s2        # t0 = 1 << position
    bseti t0, t0, 8          # (bit 8 is not an LED: bclri removes it again, just to show both)
    bclri t0, t0, 8
    sd   t0, 0x08(s0)        # LEDS
    binv a1, a1, s2          # flip this LED's parity bit
    rdcycle t1               # wait s1 cycles
    add  t2, t1, s1
wait:
    rdcycle t1
    bltu t1, t2, wait
    ld   t3, 0x10(s0)        # BUTTONS
    bnez t3, stop
    add  s2, s2, s3          # move, and bounce at both ends
    beqz s2, bounce
    li   t4, 7
    bne  s2, t4, moved
bounce:
    neg  s3, s3
moved:
    addi a0, a0, 1
    bne  a0, s4, step
stop:
    sd   zero, 0x08(s0)      # LEDs off
    bexti a2, a1, 3
    halt
message:
    .string "LED sweep: press any button to stop\n"
