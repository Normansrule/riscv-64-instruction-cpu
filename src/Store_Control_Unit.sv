`default_nettype none

import opcode_pkg::*;

module StoreControl (
    input logic [2:0] STORE_FUNCT3, // funct3 determines which store process to use
    input logic [63:0] MEMORY_ADDRESS,
    input logic [63:0] MEMORY_INFO,
    output logic [7:0] WRITE_MASK_FOR_STORE, // One bit per byte lane of the 64-bit memory word
    output logic [63:0] DATA_TO_STORE
);

    wire [2:0] BYTE_FORMATTING = MEMORY_ADDRESS[2:0]; // Last 3 bits of Memory Address Select which byte/half/word to store
    wire [7:0] BYTE_TO_STORE = MEMORY_INFO[7:0]; // Store Byte
    wire [15:0] HALF_TO_STORE = MEMORY_INFO[15:0]; // Store Halfword
    wire [31:0] WORD_TO_STORE = MEMORY_INFO[31:0]; // Store Word
    wire [63:0] DOUBLE_TO_STORE = MEMORY_INFO; // Store Full Doubleword

    // Store Byte Logic: replicate the byte into its lane and enable exactly one lane
    wire [63:0] STORE_BYTE_ALIGNED = {56'd0, BYTE_TO_STORE} << (8 * BYTE_FORMATTING); // Byte moved to its lane
    wire [7:0] STORE_BYTE_MASK = 8'b0000_0001 << BYTE_FORMATTING; // 0000_0001, 0000_0010, ... 1000_0000

    // Store Halfword Logic (address bit 0 ignored):
    wire [63:0] STORE_HALF_ALIGNED = {48'd0, HALF_TO_STORE} << (16 * BYTE_FORMATTING[2:1]);
    wire [7:0] STORE_HALF_MASK = 8'b0000_0011 << (2 * BYTE_FORMATTING[2:1]);

    // Store Word Logic (address bits 1 and 0 ignored):
    wire [63:0] STORE_WORD_ALIGNED = BYTE_FORMATTING[2] ? {WORD_TO_STORE, 32'd0} : {32'd0, WORD_TO_STORE};
    wire [7:0] STORE_WORD_MASK = BYTE_FORMATTING[2] ? 8'b1111_0000 : 8'b0000_1111;

    always_comb begin
        WRITE_MASK_FOR_STORE = 8'b0000_0000;
        DATA_TO_STORE = 64'd0;
        unique case (STORE_FUNCT3)
            FNC_SB: begin // Store the Byte
                WRITE_MASK_FOR_STORE = STORE_BYTE_MASK;
                DATA_TO_STORE = STORE_BYTE_ALIGNED;
            end
            FNC_SH: begin // Store the Halfword
                WRITE_MASK_FOR_STORE = STORE_HALF_MASK;
                DATA_TO_STORE = STORE_HALF_ALIGNED;
            end
            FNC_SW: begin // Store the Word
                WRITE_MASK_FOR_STORE = STORE_WORD_MASK;
                DATA_TO_STORE = STORE_WORD_ALIGNED;
            end
            FNC_SD: begin // Store the Full Doubleword
                WRITE_MASK_FOR_STORE = 8'b1111_1111;
                DATA_TO_STORE = DOUBLE_TO_STORE;
            end
            default: begin // Default is to store empty data
                WRITE_MASK_FOR_STORE = 8'b0000_0000;
                DATA_TO_STORE = 64'd0;
            end
        endcase
    end

endmodule

`default_nettype wire
