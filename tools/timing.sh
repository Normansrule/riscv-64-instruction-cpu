#!/usr/bin/env bash
# =============================================================================
# tools/timing.sh: logic-only static timing of the core on SkyWater sky130
#
#   tools/timing.sh [performance|baseline]
#
# Flow (the same for every number reported in docs/PERFORMANCE.md):
#   sv2v (SystemVerilog -> Verilog)  ->  yosys synth -noabc (no area-oriented rewriting)
#   -> dfflibmap + ABC delay-driven mapping onto sky130_fd_sc_hd (typical corner, 25 C, 1.80 V)
#   -> ABC "stime -p": the longest register-to-register path, in picoseconds.
# What it does NOT include: wire delay, clock skew, setup time, the slow corner. Real sign-off
# after place and route is typically 1.5x to 2.5x slower (the EECS 151 chip: see docs/PERFORMANCE.md).
# The baseline's single-cycle M unit is left out (black box): with it that design would be far slower.
# =============================================================================
set -euo pipefail
CFG=${1:-performance}
LIB=build/sky130_hd_tt.lib
mkdir -p build/synth
[ -f "$LIB" ] || curl -sL -o "$LIB" https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/master/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
[ -x build/sv2v ] || { curl -sL -o build/sv2v.zip https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip && unzip -qo build/sv2v.zip -d build && cp build/sv2v-Linux/sv2v build/sv2v; }
SRCS=$(grep -v -e Scratchpad -e Riscv64_top src/sources.f)
if [ "$CFG" = baseline ]; then
  ./build/sv2v -DBASELINE $SRCS > build/synth/flat_$CFG.v
  PARAMS="chparam -set GSHARE_HISTORY_BITS 4 -set BTB_ENABLE 0 -set RAS_ENABLE 0 -set PRECISE_LOAD_STALL 0 -set ITERATIVE_MULTIPLY_DIVIDE 0 Riscv64"
  BLACKBOX="blackbox MultiplyDivideUnit"
else
  ./build/sv2v $SRCS > build/synth/flat_$CFG.v
  PARAMS=""; BLACKBOX=""
fi
cat > build/synth/abc_timing.scr <<'ABC'
strash
&get -n

&dch -f
&nf {D}
&put
buffer
upsize {D}
dnsize {D}
stime -p
ABC
cat > build/synth/timing_$CFG.ys <<YS
read_verilog build/synth/flat_$CFG.v
$PARAMS
$BLACKBOX
synth -noabc -top Riscv64 -flatten
dfflibmap -liberty $LIB
abc -D 1000 -liberty $LIB -script build/synth/abc_timing.scr
stat -liberty $LIB
YS
yosys -q -l build/synth/timing_$CFG.log -s build/synth/timing_$CFG.ys > /dev/null
DELAY=$(grep -E "Delay =" build/synth/timing_$CFG.log | tail -1 | sed -E 's/.*Delay = *([0-9.]+) ps.*/\1/')
AREA=$(grep "Chip area" build/synth/timing_$CFG.log | tail -1 | awk '{print $NF}')
START=$(grep "Start-point" build/synth/timing_$CFG.log | tail -1 | sed -E 's/.*Start-point = [^(]*\(\\?([^)]*)\).*/\1/')
MHZ=$(awk -v d="$DELAY" 'BEGIN{printf "%.0f", 1e6/d}')
printf '%-12s logic delay %8.0f ps  ->  %4s MHz (logic only)   cell area %10.0f um2   path starts at %s\n' "$CFG" "$DELAY" "$MHZ" "$AREA" "$START"
