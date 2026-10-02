#!/usr/bin/env bash
# =============================================================================
# fpga/boards/ulx3s/build.sh: Sixfold for the ULX3S (ECP5-85F), with the open-source flow
#
#   fpga/boards/ulx3s/build.sh [program.s]      (default program: programs/20_leds_and_buttons.s)
#   CLOCK_MHZ=24 fpga/boards/ulx3s/build.sh     (a different clock: the PLL is generated to match; 20 has a safe margin)
#
#   ecppll          the PLL: 25 MHz -> CLOCK_MHZ
#   sv2v            SystemVerilog -> Verilog, with SIXFOLD_FPGA defined (adders on the carry chain)
#   yosys           synth_ecp5: logic -> ECP5 LUT4s, carry chains, block RAM (DP16KD), multipliers
#   nextpnr-ecp5    placement, routing and static timing (the real maximum clock of this layout)
#   ecppack         the bitstream: build/ulx3s/sixfold.bit
# Program the board with:  openFPGALoader -b ulx3s build/ulx3s/sixfold.bit
# (Ubuntu: apt install yosys nextpnr-ecp5 fpga-trellis openfpgaloader)
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")/../../.."
PROGRAM=${1:-programs/20_leds_and_buttons.s}
CLOCK_MHZ=${CLOCK_MHZ:-20}
OUT=build/ulx3s
mkdir -p $OUT
[ -x build/sv2v ] || { curl -sL -o build/sv2v.zip https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip && unzip -qo build/sv2v.zip -d build && cp build/sv2v-Linux/sv2v build/sv2v; }
node tools/fpga_image.mjs "$PROGRAM" --out $OUT
CORE=$(grep -v -e Scratchpad -e Riscv64_top src/sources.f)
ecppll -i 25 -o $CLOCK_MHZ -n SixfoldPll -f $OUT/pll.v > $OUT/pll.txt
./build/sv2v -DSIXFOLD_FPGA $CORE $(cat fpga/sources.f) fpga/boards/ulx3s/ulx3s_top.sv > $OUT/sixfold.v
sed -i "s#\"[^\"]*memory.hex\"#\"$OUT/memory.hex\"#g" $OUT/sixfold.v
# synth_ecp5, with one pass left out: "share" would merge the ALU's adder with the branch comparator's
# subtractor behind a multiplexer, chaining the branch decision into the load/store address (the same
# reason tools/timing.sh uses "synth -noshare"). Everything else is synth_ecp5's own script.
cat > $OUT/synth.ys <<YS
read_verilog $OUT/sixfold.v $OUT/pll.v
chparam -set CLOCK_HZ $((CLOCK_MHZ * 1000000)) ulx3s_top
synth_ecp5 -top ulx3s_top -run begin:coarse
proc; flatten; tribuf -logic; deminout; opt_expr; opt_clean; check; opt -nodffe -nosdff; fsm; opt; wreduce; peepopt; opt_clean
techmap -map +/cmp2lut.v -D LUT_WIDTH=4; opt_expr; opt_clean
techmap -map +/mul2dsp.v -map +/ecp5/dsp_map.v -D DSP_A_MAXWIDTH=18 -D DSP_B_MAXWIDTH=18 -D DSP_A_MINWIDTH=2 -D DSP_B_MINWIDTH=2 -D DSP_NAME=\$__MUL18X18
chtype -set \$mul t:\$__soft_mul
alumacc; opt; memory -nomap; opt_clean
synth_ecp5 -top ulx3s_top -run map_ram: -json $OUT/sixfold.json
YS
yosys -q -l $OUT/yosys.log -s $OUT/synth.ys
grep -A40 "Printing statistics" $OUT/yosys.log | tail -40 > $OUT/resources.txt || true
nextpnr-ecp5 --85k --package CABGA381 --speed 6 --json $OUT/sixfold.json --lpf fpga/boards/ulx3s/ulx3s.lpf \
  --textcfg $OUT/sixfold.config --freq $CLOCK_MHZ --router router2 --timing-allow-fail --report $OUT/report.json -l $OUT/nextpnr.log --seed ${SEED:-1}
ecppack --compress $OUT/sixfold.config $OUT/sixfold.bit
grep -E "Max frequency|Info: Device utilisation" -A12 $OUT/nextpnr.log | grep -E "MHz|TRELLIS_SLICE|DP16KD|MULT18|TRELLIS_FF|LUT" | tail -12
echo "bitstream: $OUT/sixfold.bit   (openFPGALoader -b ulx3s $OUT/sixfold.bit)"
