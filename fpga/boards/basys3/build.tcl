# =============================================================================
# fpga/boards/basys3/build.tcl: Sixfold for the Basys 3 with AMD Vivado (non-project mode)
#
#   node tools/fpga_image.mjs fpga/examples/calculator.s --out build/basys3
#   vivado -mode batch -source fpga/boards/basys3/build.tcl
#
# Vivado ML Standard (the free edition) supports the XC7A35T. Output in build/basys3/:
#   sixfold.bit, timing.txt (check "WNS" >= 0), utilization.txt
# Program the board: Hardware Manager, or  openFPGALoader -b basys3 build/basys3/sixfold.bit
# =============================================================================
set out build/basys3
file mkdir $out
set sources {}
foreach f [split [string trim [read [open src/sources.f]]] "\n"] {
  if {![string match *Scratchpad* $f] && ![string match *Riscv64_top* $f]} { lappend sources $f }
}
foreach f [split [string trim [read [open fpga/sources.f]]] "\n"] { lappend sources $f }
lappend sources fpga/boards/basys3/basys3_top.sv
read_verilog -sv $sources
read_xdc fpga/boards/basys3/basys3.xdc
synth_design -top basys3_top -part xc7a35tcpg236-1 -verilog_define SIXFOLD_FPGA -generic "MEMORY_IMAGE=[file normalize $out/memory.hex]"
opt_design
place_design
phys_opt_design
route_design
report_timing_summary -file $out/timing.txt
report_utilization -file $out/utilization.txt
write_bitstream -force $out/sixfold.bit
