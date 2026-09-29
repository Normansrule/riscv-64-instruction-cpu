# =============================================================================
# fpga/boards/arty_a7/build.tcl: Sixfold for the Arty A7-100T with AMD Vivado (non-project mode)
#
#   node tools/fpga_image.mjs programs/20_leds_and_buttons.s --out build/arty_a7
#   vivado -mode batch -source fpga/boards/arty_a7/build.tcl
#
# Vivado ML Standard (the free edition) supports the XC7A100T. Output in build/arty_a7/:
#   sixfold.bit, timing.txt (check "WNS" >= 0), utilization.txt
# Program the board: Hardware Manager, or  openFPGALoader -b arty_a7_100t build/arty_a7/sixfold.bit
# =============================================================================
set out build/arty_a7
file mkdir $out
set sources {}
foreach f [split [string trim [read [open src/sources.f]]] "\n"] {
  if {![string match *Scratchpad* $f] && ![string match *Riscv64_top* $f]} { lappend sources $f }
}
foreach f [split [string trim [read [open fpga/sources.f]]] "\n"] { lappend sources $f }
lappend sources fpga/boards/arty_a7/arty_a7_top.sv
read_verilog -sv $sources
read_xdc fpga/boards/arty_a7/arty_a7_100t.xdc
synth_design -top arty_a7_top -part xc7a100tcsg324-1 -generic "MEMORY_IMAGE=[file normalize $out/memory.hex]"
opt_design
place_design
phys_opt_design
route_design
report_timing_summary -file $out/timing.txt
report_utilization -file $out/utilization.txt
write_bitstream -force $out/sixfold.bit
