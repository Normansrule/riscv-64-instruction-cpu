`timescale 1ns/1ps
// =============================================================================
// forward_unit.v — solve read-after-write hazards without stalling.
//
// The instruction in EX may need a register that an OLDER instruction has
// computed but not yet written back. Grab the value straight from the
// pipeline latch instead of the (stale) register-file copy:
//
//   sel = 2'b01 : from EX/MEM  (the instruction 1 ahead, now in MEM)
//   sel = 2'b10 : from MEM/WB  (the instruction 2 ahead, now in WB)
//   sel = 2'b00 : no hazard, use the value read in RR
//
// The nearest (youngest) producer wins, so EX/MEM is checked first.
// =============================================================================
module forward_unit (
    input  wire       use_rs,
    input  wire [4:0] rs,
    input  wire       ex_mem_valid, ex_mem_reg_write,
    input  wire [4:0] ex_mem_rd,
    input  wire       mem_wb_valid, mem_wb_reg_write,
    input  wire [4:0] mem_wb_rd,
    output wire [1:0] sel
);
    wire hit_mem = use_rs && rs != 5'd0 && ex_mem_valid && ex_mem_reg_write && ex_mem_rd == rs;
    wire hit_wb  = use_rs && rs != 5'd0 && mem_wb_valid && mem_wb_reg_write && mem_wb_rd == rs;
    assign sel = hit_mem ? 2'b01 : hit_wb ? 2'b10 : 2'b00;
endmodule
