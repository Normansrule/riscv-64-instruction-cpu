`timescale 1ns/1ps
// =============================================================================
// soc_top.v — the whole "chip": the 6-stage core wired to its memory.
// =============================================================================
module soc_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        bp_enable,
    output wire        halted,
    output wire        illegal_halt,
    output wire [63:0] cycle_count,
    output wire [63:0] retired_count,
    output wire [63:0] branch_count,
    output wire [63:0] mispredict_count,
    input  wire [4:0]  dbg_reg_addr,
    output wire [63:0] dbg_reg_data,
    output wire [5:0]  t_valid,
    output wire [63:0] t_pc_if, t_pc_id, t_pc_rr, t_pc_ex, t_pc_mem, t_pc_wb,
    output wire        t_stall, t_flush,
    output wire [1:0]  t_fwd_a, t_fwd_b
);
    wire [63:0] imem_addr, dmem_addr, dmem_wdata, dmem_rdata;
    wire [31:0] imem_rdata;
    wire        dmem_we;
    wire [1:0]  dmem_size;

    rv64_core core (
        .clk(clk), .rst(rst), .bp_enable(bp_enable),
        .imem_addr(imem_addr), .imem_rdata(imem_rdata),
        .dmem_addr(dmem_addr), .dmem_we(dmem_we), .dmem_size(dmem_size),
        .dmem_wdata(dmem_wdata), .dmem_rdata(dmem_rdata),
        .halted(halted), .illegal_halt(illegal_halt),
        .cycle_count(cycle_count), .retired_count(retired_count),
        .branch_count(branch_count), .mispredict_count(mispredict_count),
        .dbg_reg_addr(dbg_reg_addr), .dbg_reg_data(dbg_reg_data),
        .t_valid(t_valid), .t_pc_if(t_pc_if), .t_pc_id(t_pc_id), .t_pc_rr(t_pc_rr),
        .t_pc_ex(t_pc_ex), .t_pc_mem(t_pc_mem), .t_pc_wb(t_pc_wb),
        .t_stall(t_stall), .t_flush(t_flush), .t_fwd_a(t_fwd_a), .t_fwd_b(t_fwd_b));

    memory mem (
        .clk(clk), .iaddr(imem_addr), .idata(imem_rdata),
        .daddr(dmem_addr), .dwe(dmem_we), .dsize(dmem_size),
        .dwdata(dmem_wdata), .drdata(dmem_rdata));
endmodule
