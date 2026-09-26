`default_nettype none

import const_pkg::*;

// riscv64_top: the whole "chip" for simulation: the Riscv64 core wired to its Scratchpad Memory
module riscv64_top #(
  parameter int GSHARE_HISTORY_BITS = 6,
  parameter bit BTB_ENABLE = 1'b1,
  parameter bit RAS_ENABLE = 1'b1,
  parameter bit PRECISE_LOAD_STALL = 1'b1,
  parameter bit ITERATIVE_MULTIPLY_DIVIDE = 1'b1
) (
  input  logic        clk,
  input  logic        reset,
  input  logic        BRANCH_PREDICTION_ENABLE,
  output logic [63:0] csr,
  output logic        HALTED,
  input  logic [4:0]  DEBUG_REGISTER_ADDRESS,
  output logic [63:0] DEBUG_REGISTER_DATA,
  output logic [5:0]  TRACE_VALID,
  output logic [63:0] TRACE_FETCH1_PC, TRACE_FETCH2_PC, TRACE_DECODE_PC, TRACE_EXECUTE_PC, TRACE_MEMORY_PC, TRACE_WRITEBACK_PC,
  output logic        TRACE_LOAD_STALL, TRACE_FLUSH, TRACE_REDIRECT, TRACE_MULTIPLY_DIVIDE_STALL
);

  logic [63:0] dcache_addr; // From cpu of Riscv64
  logic [63:0] dcache_din;  // From cpu of Riscv64
  logic [63:0] dcache_dout; // From mem of ScratchpadMemory
  logic [7:0]  dcache_we;   // From cpu of Riscv64
  logic [63:0] icache_addr; // From cpu of Riscv64
  logic [31:0] icache_dout; // From mem of ScratchpadMemory

  ScratchpadMemory mem (
    .clk                 (clk),
    .INSTRUCTION_ADDRESS (icache_addr),
    .INSTRUCTION_DATA    (icache_dout),
    .DATA_ADDRESS        (dcache_addr),
    .DATA_WRITE_MASK     (dcache_we),
    .DATA_WRITE_DATA     (dcache_din),
    .DATA_READ_DATA      (dcache_dout)
  );

  // RISC-V 64 CPU
  Riscv64 #(
    .GSHARE_HISTORY_BITS (GSHARE_HISTORY_BITS),
    .BTB_ENABLE (BTB_ENABLE),
    .RAS_ENABLE (RAS_ENABLE),
    .PRECISE_LOAD_STALL (PRECISE_LOAD_STALL),
    .ITERATIVE_MULTIPLY_DIVIDE (ITERATIVE_MULTIPLY_DIVIDE)
  ) cpu (
    .clk                      (clk),
    .reset                    (reset),
    .BRANCH_PREDICTION_ENABLE (BRANCH_PREDICTION_ENABLE),
    .dcache_addr              (dcache_addr),
    .icache_addr              (icache_addr),
    .dcache_we                (dcache_we),
    .dcache_din               (dcache_din),
    .dcache_dout              (dcache_dout),
    .icache_dout              (icache_dout),
    .csr                      (csr),
    .HALTED                   (HALTED),
    .DEBUG_REGISTER_ADDRESS   (DEBUG_REGISTER_ADDRESS),
    .DEBUG_REGISTER_DATA      (DEBUG_REGISTER_DATA),
    .TRACE_VALID              (TRACE_VALID),
    .TRACE_FETCH1_PC          (TRACE_FETCH1_PC),
    .TRACE_FETCH2_PC          (TRACE_FETCH2_PC),
    .TRACE_DECODE_PC          (TRACE_DECODE_PC),
    .TRACE_EXECUTE_PC         (TRACE_EXECUTE_PC),
    .TRACE_MEMORY_PC          (TRACE_MEMORY_PC),
    .TRACE_WRITEBACK_PC       (TRACE_WRITEBACK_PC),
    .TRACE_LOAD_STALL         (TRACE_LOAD_STALL),
    .TRACE_FLUSH              (TRACE_FLUSH),
    .TRACE_REDIRECT           (TRACE_REDIRECT),
    .TRACE_MULTIPLY_DIVIDE_STALL (TRACE_MULTIPLY_DIVIDE_STALL)
  );

endmodule

`default_nettype wire
