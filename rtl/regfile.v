`timescale 1ns/1ps
// =============================================================================
// regfile.v — 32 x 64-bit integer registers, 2 read ports, 1 write port.
//
// x0 is hard-wired to zero. Reads are "write-first": if WB writes a register
// in the same cycle RR reads it, RR gets the NEW value (internal bypass). This
// removes one forwarding path from the pipeline.
// =============================================================================
module regfile (
    input  wire        clk,
    input  wire [4:0]  ra1, ra2,
    output wire [63:0] rd1, rd2,
    input  wire        we,
    input  wire [4:0]  wa,
    input  wire [63:0] wd,
    input  wire [4:0]  dbg_addr,     // testbench register dump port
    output wire [63:0] dbg_data
);
    reg [63:0] regs [1:31];
    integer i;
    initial for (i = 1; i < 32; i = i + 1) regs[i] = 64'd0;

    always @(posedge clk)
        if (we && wa != 5'd0) regs[wa] <= wd;

    assign rd1 = (ra1 == 5'd0) ? 64'd0 : (we && wa == ra1) ? wd : regs[ra1];
    assign rd2 = (ra2 == 5'd0) ? 64'd0 : (we && wa == ra2) ? wd : regs[ra2];
    assign dbg_data = (dbg_addr == 5'd0) ? 64'd0 : regs[dbg_addr];
endmodule
