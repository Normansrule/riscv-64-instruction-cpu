#!/usr/bin/env bash
# =============================================================================
# tools/timing.sh: logic-only static timing of the core on SkyWater sky130
#
#   tools/timing.sh [performance|baseline] [sky130|asap7]
#
#   sky130 : SkyWater 130 nm open PDK, sky130_fd_sc_hd, typical corner 25 C 1.80 V (a real, manufacturable process)
#   asap7  : ASAP7 7 nm predictive FinFET PDK (Arizona State University + ARM), RVT cells, typical corner 25 C 0.70 V.
#            A research kit that models a 7 nm-class process; it cannot be manufactured, but its timing is realistic.
#
# Flow (the same for every number reported in docs/PERFORMANCE.md):
#   sv2v (SystemVerilog -> Verilog)  ->  yosys synth -noabc (no area-oriented rewriting)
#   -> dfflibmap + ABC delay-driven mapping onto sky130_fd_sc_hd (typical corner, 25 C, 1.80 V)
#   -> ABC "stime -p": the longest register-to-register path, in picoseconds.
# What it does NOT include: wire delay, clock skew, setup time, the slow corner. Real sign-off
# after place and route is typically 1.5x to 2.5x slower (see docs/PERFORMANCE.md).
# The baseline's single-cycle M unit is left out (black box): with it that design would be far slower.
# =============================================================================
set -euo pipefail
CFG=${1:-performance}
PDK=${2:-sky130}
LIB=build/sky130_hd_tt.lib
A7=https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/master/flow/platforms/asap7/lib/NLDM
mkdir -p build/synth
[ -f "$LIB" ] || curl -sL -o "$LIB" https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/master/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
[ -x build/sv2v ] || { curl -sL -o build/sv2v.zip https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip && unzip -qo build/sv2v.zip -d build && cp build/sv2v-Linux/sv2v build/sv2v; }
if [ "$PDK" = asap7 ]; then
  mkdir -p build/asap7
  for n in SIMPLE_RVT_TT_nldm_211120 INVBUF_RVT_TT_nldm_220122 AO_RVT_TT_nldm_211120 OA_RVT_TT_nldm_211120; do
    [ -f build/asap7/$n.lib ] || { curl -sL "$A7/asap7sc7p5t_$n.lib.gz" | gunzip > build/asap7/$n.lib; }
  done
  [ -f build/asap7/asap7_merged_tt.lib ] || python3 tools/merge_liberty.py build/asap7/asap7_merged_tt.lib build/asap7/SIMPLE_RVT_TT_nldm_211120.lib build/asap7/INVBUF_RVT_TT_nldm_220122.lib build/asap7/AO_RVT_TT_nldm_211120.lib build/asap7/OA_RVT_TT_nldm_211120.lib
  LIBARGS="-liberty build/asap7/asap7_merged_tt.lib"
  DFFMAP=""
else
  LIBARGS="-liberty $LIB"
  DFFMAP="dfflibmap -liberty $LIB"
fi
SRCS=$(grep -v -e Scratchpad -e Riscv64_top -e _Cache_ src/sources.f)
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
&st
&if -g
&st
&if -g
&b
&dch -f
&nf {D}
&put
buffer
upsize {D}
dnsize {D}
stime -p
ABC
TAG=${CFG}_${PDK}
cat > build/synth/timing_$TAG.ys <<YS
read_verilog build/synth/flat_$CFG.v
$PARAMS
$BLACKBOX
synth -noabc -noshare -top Riscv64 -flatten
$DFFMAP
abc -D 100 $LIBARGS -script build/synth/abc_timing.scr
YS
yosys -q -l build/synth/timing_$TAG.log -s build/synth/timing_$TAG.ys > /dev/null
DELAY=$(grep -E "Delay =" build/synth/timing_$TAG.log | tail -1 | sed -E 's/.*Delay = *([0-9.]+) ps.*/\1/')
AREA=$(grep -E "Delay =" build/synth/timing_$TAG.log | tail -1 | sed -E 's/.*Area = *([0-9.]+).*/\1/')
START=$(grep "Start-point" build/synth/timing_$TAG.log | tail -1 | sed -E 's/.*Start-point = [^(]*\(\\?([^)]*)\).*/\1/')
MHZ=$(awk -v d="$DELAY" 'BEGIN{printf "%.0f", 1e6/d}')
printf '%-12s %-7s logic delay %7.0f ps  ->  %5s MHz (logic only)   logic area %10.1f um2   path starts at %s\n' "$CFG" "$PDK" "$DELAY" "$MHZ" "$AREA" "$START"
