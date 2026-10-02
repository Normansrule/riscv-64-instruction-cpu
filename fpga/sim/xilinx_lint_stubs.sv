// =====================================================================================================
// fpga/sim/xilinx_lint_stubs.sv: stand-ins for the two Xilinx primitives the Artix-7 board tops use
// (MMCME2_BASE, BUFG), so `make fpga-lint` can lint fpga/boards/basys3 and fpga/boards/arty_a7 too.
// For lint only: Vivado uses its own models, and these do not divide the clock.
// =====================================================================================================
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */
module MMCME2_BASE #(
    parameter real CLKIN1_PERIOD = 10.0, parameter real CLKFBOUT_MULT_F = 10.0,
    parameter real CLKOUT0_DIVIDE_F = 40.0, parameter int DIVCLK_DIVIDE = 1
) (
    input  wire CLKIN1, CLKFBIN, PWRDWN, RST,
    output wire CLKFBOUT, CLKOUT0, LOCKED,
    output wire CLKFBOUTB, CLKOUT0B, CLKOUT1, CLKOUT1B, CLKOUT2, CLKOUT2B, CLKOUT3, CLKOUT3B, CLKOUT4, CLKOUT5, CLKOUT6
);
    assign CLKOUT0 = CLKIN1;
    assign CLKFBOUT = 1'b0;
    assign LOCKED = 1'b1;
endmodule
module BUFG (input wire I, output wire O);
    assign O = I;
endmodule
/* verilator lint_on UNDRIVEN */
/* verilator lint_on UNUSEDSIGNAL */
