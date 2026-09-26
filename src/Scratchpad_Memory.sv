`default_nettype none

import const_pkg::*;

// Scratchpad Memory: 64 KiB of unified, byte-addressed, little-endian memory with two ports.
//
// In the baseline build this is the whole memory (single cycle, no stalls) so the
// pipeline can be studied without cache-miss stalls. Both ports read combinationally; the pipeline
// registers right after them (FETCH2_INSTRUCTION and MEMORY_DATA_CACHE_DATA) play the role of the
// SRAM's output register, exactly like a synchronous SRAM macro:
//   Instruction port : address sent in Fetch 1  -> instruction arrives in Fetch 2
//   Data port        : address sent in Execute  -> load data arrives in Memory, stores write at the clock edge
// A store to MMIO_PUTCHAR (0x1000_0000) prints a character instead of writing memory.
module ScratchpadMemory (
    input  logic clk,
    // ===== Instruction Port (Fetch 1) =====
    input  logic [63:0] INSTRUCTION_ADDRESS,
    output logic [31:0] INSTRUCTION_DATA,
    // ===== Data Port (Execute) =====
    input  logic [63:0] DATA_ADDRESS,
    input  logic [7:0]  DATA_WRITE_MASK, // One bit per byte lane, from Store Control
    input  logic [63:0] DATA_WRITE_DATA, // Already shifted into the right lanes by Store Control
    output logic [63:0] DATA_READ_DATA, // The whole aligned doubleword, Load Control picks the lanes
    // ===== Line refill ports (used when the caches are enabled: this memory is then "main memory") =====
    input  logic [63:0] INSTRUCTION_REFILL_ADDRESS,
    output logic [255:0] INSTRUCTION_REFILL_LINE,
    input  logic [63:0] DATA_REFILL_ADDRESS,
    output logic [255:0] DATA_REFILL_LINE
);

    logic [7:0] MEMORY [0:MEMORY_BYTES-1];
    logic [1023:0] HEX_FILE_NAME;
    integer MEMORY_INDEX;
    initial begin
        for (MEMORY_INDEX = 0; MEMORY_INDEX < MEMORY_BYTES; MEMORY_INDEX = MEMORY_INDEX + 1) MEMORY[MEMORY_INDEX] = 8'h00;
        // The program image comes from the simulator command line: +HEX=build/program.hex
        if ($value$plusargs("HEX=%s", HEX_FILE_NAME)) $readmemh(HEX_FILE_NAME, MEMORY);
        else $display("[ScratchpadMemory] no +HEX=<file> given, memory is all zeros");
    end

    // ===== Instruction Port: 32-bit read (addresses wrap inside the 64 KiB) =====
    logic [15:0] INSTRUCTION_BYTE_ADDRESS;
    assign INSTRUCTION_BYTE_ADDRESS = INSTRUCTION_ADDRESS[15:0];
    assign INSTRUCTION_DATA = {MEMORY[INSTRUCTION_BYTE_ADDRESS + 16'd3], MEMORY[INSTRUCTION_BYTE_ADDRESS + 16'd2],
                               MEMORY[INSTRUCTION_BYTE_ADDRESS + 16'd1], MEMORY[INSTRUCTION_BYTE_ADDRESS]};

    // ===== Data Port: aligned 64-bit doubleword =====
    logic IS_PUTCHAR; // The address is the character output register
    logic [15:0] DOUBLEWORD_BYTE_ADDRESS; // Address rounded down to a multiple of 8
    assign IS_PUTCHAR = (DATA_ADDRESS == MMIO_PUTCHAR);
    assign DOUBLEWORD_BYTE_ADDRESS = {DATA_ADDRESS[15:3], 3'b000};
    assign DATA_READ_DATA = IS_PUTCHAR ? 64'd0 :
        {MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd7], MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd6],
         MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd5], MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd4],
         MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd3], MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd2],
         MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd1], MEMORY[DOUBLEWORD_BYTE_ADDRESS]};

    // ===== 32-byte line reads for cache refills =====
    function automatic logic [255:0] read_line(input logic [63:0] address);
        logic [255:0] LINE;
        for (int BYTE_INDEX = 0; BYTE_INDEX < 32; BYTE_INDEX = BYTE_INDEX + 1)
            LINE[8*BYTE_INDEX +: 8] = MEMORY[{address[15:5], 5'd0} + BYTE_INDEX[15:0]];
        return LINE;
    endfunction
    assign INSTRUCTION_REFILL_LINE = read_line(INSTRUCTION_REFILL_ADDRESS);
    assign DATA_REFILL_LINE = read_line(DATA_REFILL_ADDRESS);

    // ===== Synchronous byte-lane writes =====
    always_ff @(posedge clk) begin
        if (IS_PUTCHAR) begin
            if (|DATA_WRITE_MASK) begin
                $write("%c", DATA_WRITE_DATA[7:0]); // Memory mapped character output
                $fflush();
            end
        end else begin
            if (DATA_WRITE_MASK[0]) MEMORY[DOUBLEWORD_BYTE_ADDRESS]          <= DATA_WRITE_DATA[7:0];
            if (DATA_WRITE_MASK[1]) MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd1]  <= DATA_WRITE_DATA[15:8];
            if (DATA_WRITE_MASK[2]) MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd2]  <= DATA_WRITE_DATA[23:16];
            if (DATA_WRITE_MASK[3]) MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd3]  <= DATA_WRITE_DATA[31:24];
            if (DATA_WRITE_MASK[4]) MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd4]  <= DATA_WRITE_DATA[39:32];
            if (DATA_WRITE_MASK[5]) MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd5]  <= DATA_WRITE_DATA[47:40];
            if (DATA_WRITE_MASK[6]) MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd6]  <= DATA_WRITE_DATA[55:48];
            if (DATA_WRITE_MASK[7]) MEMORY[DOUBLEWORD_BYTE_ADDRESS + 16'd7]  <= DATA_WRITE_DATA[63:56];
        end
    end

    /* verilator lint_off UNUSEDSIGNAL */
    logic UNUSED_ADDRESS_BITS; // Only 16 address bits are decoded (the space wraps every 64 KiB)
    assign UNUSED_ADDRESS_BITS = ^{INSTRUCTION_ADDRESS[63:16], DATA_ADDRESS[63:16], INSTRUCTION_REFILL_ADDRESS[63:16], INSTRUCTION_REFILL_ADDRESS[4:0], DATA_REFILL_ADDRESS[63:16], DATA_REFILL_ADDRESS[4:0]};
    /* verilator lint_on UNUSEDSIGNAL */

endmodule

`default_nettype wire
