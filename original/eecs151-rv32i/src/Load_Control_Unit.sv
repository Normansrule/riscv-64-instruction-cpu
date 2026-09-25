`default_nettype none

import opcode_pkg::*;

module LoadControl (
    input logic [2:0] LOAD_FUNCT3, // funct3 determines which load process to use
    input logic [31:0] MEMORY_ADDRESS,
    input logic [31:0] MEMORY_INFO,
    output logic [31:0] DATA_TO_LOAD
    );

    wire [1:0] BYTE_FORMATTING = MEMORY_ADDRESS[1:0]; // Last 2 bits of Memory Address Selects which byte/half to load
    wire [7:0] BYTE0 = MEMORY_INFO[7:0]; // Store First Byte of Memory Information
    wire [7:0] BYTE1 = MEMORY_INFO[15:8]; // Store Second Byte of Memory Information
    wire [7:0] BYTE2 = MEMORY_INFO[23:16]; // Store Third Byte of Memory Information
    wire [7:0] BYTE3 = MEMORY_INFO[31:24]; // Store Fourth Byte of Memory Information
    wire [15:0] HALF0 = MEMORY_INFO[15:0]; // Store First Halfword of Memory Information
    wire [15:0] HALF1 = MEMORY_INFO[31:16]; // Store Second Halfword of Memory Information
    
    // Load Byte Logic:
    wire [7:0] SELECT_BYTE_TO_LOAD = 
        (BYTE_FORMATTING == 2'b00) ? BYTE0 : // First Byte associated with 00
        (BYTE_FORMATTING == 2'b01) ? BYTE1 : // Second Byte associated with 01
        (BYTE_FORMATTING == 2'b10) ? BYTE2 : // Third Byte associated with 10
        (BYTE_FORMATTING == 2'b11) ? BYTE3 : // Fourth Byte associated with 11
        BYTE0;

    // Load Halfword Logic:
    wire [15:0] SELECT_HALF_TO_LOAD = 
        (BYTE_FORMATTING == 2'b00) ? HALF0 : // First Halfword associated with 00
        (BYTE_FORMATTING == 2'b01) ? HALF0 : // First Halfword associated with 01 (technically misaligned but specification said this is not an issue)
        (BYTE_FORMATTING == 2'b10) ? HALF1 : // Second Halfword associated with 10
        (BYTE_FORMATTING == 2'b11) ? HALF1 : // Second Halfword associated with 11 (technically misaligned but specification said this is not an issue)
        HALF0;

    always_comb begin
        unique case (LOAD_FUNCT3)
            FNC_LB:  DATA_TO_LOAD = {{24{SELECT_BYTE_TO_LOAD[7]}}, SELECT_BYTE_TO_LOAD}; // Load the Byte
            FNC_LH:  DATA_TO_LOAD = {{16{SELECT_HALF_TO_LOAD[15]}}, SELECT_HALF_TO_LOAD}; // Load the Halfword
            FNC_LW:  DATA_TO_LOAD = MEMORY_INFO; // Load the Full Word
            FNC_LBU: DATA_TO_LOAD = {24'd0, SELECT_BYTE_TO_LOAD}; // Load the Unsigned Byte
            FNC_LHU: DATA_TO_LOAD = {16'd0, SELECT_HALF_TO_LOAD}; // Load the Unsigned Halfword
            default: DATA_TO_LOAD = 32'd0; // Default is to leave the information to load as empty
        endcase
    end

endmodule

`default_nettype wire