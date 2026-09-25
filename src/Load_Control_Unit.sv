`default_nettype none

import opcode_pkg::*;

module LoadControl (
    input logic [2:0] LOAD_FUNCT3, // funct3 determines which load process to use
    input logic [63:0] MEMORY_ADDRESS,
    input logic [63:0] MEMORY_INFO, // The aligned 64-bit doubleword that contains the addressed data
    output logic [63:0] DATA_TO_LOAD
    );

    wire [2:0] BYTE_FORMATTING = MEMORY_ADDRESS[2:0]; // Last 3 bits of Memory Address Selects which byte/half/word to load
    wire [7:0] BYTE0 = MEMORY_INFO[7:0]; // Store First Byte of Memory Information
    wire [7:0] BYTE1 = MEMORY_INFO[15:8]; // Store Second Byte of Memory Information
    wire [7:0] BYTE2 = MEMORY_INFO[23:16]; // Store Third Byte of Memory Information
    wire [7:0] BYTE3 = MEMORY_INFO[31:24]; // Store Fourth Byte of Memory Information
    wire [7:0] BYTE4 = MEMORY_INFO[39:32]; // Store Fifth Byte of Memory Information
    wire [7:0] BYTE5 = MEMORY_INFO[47:40]; // Store Sixth Byte of Memory Information
    wire [7:0] BYTE6 = MEMORY_INFO[55:48]; // Store Seventh Byte of Memory Information
    wire [7:0] BYTE7 = MEMORY_INFO[63:56]; // Store Eighth Byte of Memory Information
    wire [15:0] HALF0 = MEMORY_INFO[15:0]; // Store First Halfword of Memory Information
    wire [15:0] HALF1 = MEMORY_INFO[31:16]; // Store Second Halfword of Memory Information
    wire [15:0] HALF2 = MEMORY_INFO[47:32]; // Store Third Halfword of Memory Information
    wire [15:0] HALF3 = MEMORY_INFO[63:48]; // Store Fourth Halfword of Memory Information
    wire [31:0] WORD0 = MEMORY_INFO[31:0]; // Store Lower Word of Memory Information
    wire [31:0] WORD1 = MEMORY_INFO[63:32]; // Store Upper Word of Memory Information

    // Load Byte Logic:
    wire [7:0] SELECT_BYTE_TO_LOAD =
        (BYTE_FORMATTING == 3'd0) ? BYTE0 : // First Byte associated with 000
        (BYTE_FORMATTING == 3'd1) ? BYTE1 : // Second Byte associated with 001
        (BYTE_FORMATTING == 3'd2) ? BYTE2 : // Third Byte associated with 010
        (BYTE_FORMATTING == 3'd3) ? BYTE3 : // Fourth Byte associated with 011
        (BYTE_FORMATTING == 3'd4) ? BYTE4 : // Fifth Byte associated with 100
        (BYTE_FORMATTING == 3'd5) ? BYTE5 : // Sixth Byte associated with 101
        (BYTE_FORMATTING == 3'd6) ? BYTE6 : // Seventh Byte associated with 110
        BYTE7;                              // Eighth Byte associated with 111

    // Load Halfword Logic (address bit 0 is ignored: misaligned accesses are not supported, just like the original):
    wire [15:0] SELECT_HALF_TO_LOAD =
        (BYTE_FORMATTING[2:1] == 2'd0) ? HALF0 :
        (BYTE_FORMATTING[2:1] == 2'd1) ? HALF1 :
        (BYTE_FORMATTING[2:1] == 2'd2) ? HALF2 :
        HALF3;

    // Load Word Logic (address bits 1 and 0 are ignored):
    wire [31:0] SELECT_WORD_TO_LOAD = BYTE_FORMATTING[2] ? WORD1 : WORD0;

    always_comb begin
        unique case (LOAD_FUNCT3)
            FNC_LB:  DATA_TO_LOAD = {{56{SELECT_BYTE_TO_LOAD[7]}}, SELECT_BYTE_TO_LOAD}; // Load the Byte
            FNC_LH:  DATA_TO_LOAD = {{48{SELECT_HALF_TO_LOAD[15]}}, SELECT_HALF_TO_LOAD}; // Load the Halfword
            FNC_LW:  DATA_TO_LOAD = {{32{SELECT_WORD_TO_LOAD[31]}}, SELECT_WORD_TO_LOAD}; // Load the Word (RV64: sign extended)
            FNC_LD:  DATA_TO_LOAD = MEMORY_INFO; // Load the Full Doubleword
            FNC_LBU: DATA_TO_LOAD = {56'd0, SELECT_BYTE_TO_LOAD}; // Load the Unsigned Byte
            FNC_LHU: DATA_TO_LOAD = {48'd0, SELECT_HALF_TO_LOAD}; // Load the Unsigned Halfword
            FNC_LWU: DATA_TO_LOAD = {32'd0, SELECT_WORD_TO_LOAD}; // Load the Unsigned Word
            default: DATA_TO_LOAD = 64'd0; // Default is to leave the information to load as empty
        endcase
    end

endmodule

`default_nettype wire
