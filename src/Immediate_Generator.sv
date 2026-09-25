`default_nettype none

import immediate_op_pkg::*;

module ImmediateGenerator (
    input logic [31:0] INSTRUCTION, // Full 32-bit instruction
    input immediate_type_select_t IMMEDIATE_TYPE_SELECT, // Select which Immediate Type to Generate
    output logic [63:0] IMMEDIATE // Output the specified Immediate Value (sign extended to 64 bits for RV64)
);

    logic [63:0] I_TYPE_IMMEDIATE;
    logic [63:0] S_TYPE_IMMEDIATE;
    logic [63:0] B_TYPE_IMMEDIATE;
    logic [63:0] U_TYPE_IMMEDIATE;
    logic [63:0] J_TYPE_IMMEDIATE;
    logic [63:0] Z_TYPE_IMMEDIATE;

    // Prepare Immediate Types for all Cases (instruction bit 31 is ALWAYS the sign bit, which is why the RISC-V formats look scrambled):
    assign I_TYPE_IMMEDIATE = {{52{INSTRUCTION[31]}}, INSTRUCTION[31:20]}; // I-type uses Immediate bits 31-20: Format as Sign Extended 52 bits then associated 12 bits (31-20 bits)
    assign S_TYPE_IMMEDIATE = {{52{INSTRUCTION[31]}}, INSTRUCTION[31:25], INSTRUCTION[11:7]}; // S-type uses Immediate bits 31-25 and 11-7: Format as Sign Extended 52 bits then associated 12 bits (31-25 and 11-7 bits)
    assign B_TYPE_IMMEDIATE = {{51{INSTRUCTION[31]}}, INSTRUCTION[31], INSTRUCTION[7], INSTRUCTION[30:25], INSTRUCTION[11:8], 1'b0}; // B-type uses Immediate bits 31, 7, 30-25, 11-8 and the 0th bit: Format as Sign Extended 51 bits then associated 13 bits (31, 7, 30-25, 11-8 bits and the 0 bit being set to 0)
    assign U_TYPE_IMMEDIATE = {{32{INSTRUCTION[31]}}, INSTRUCTION[31:12], 12'b0}; // U-type uses Immediate bits 31-12: RV64 sign extends the 32-bit result into the upper 32 bits
    assign J_TYPE_IMMEDIATE = {{43{INSTRUCTION[31]}}, INSTRUCTION[31], INSTRUCTION[19:12], INSTRUCTION[20], INSTRUCTION[30:21], 1'b0}; // J-type uses Immediate bits 31, 19-12, 20, 30-21, and the 0th bit: Format as Sign Extended 43 bits then associated 21 bits (31, 19-12, 20, 30-21 bits and the 0th bit being set to 0)
    assign Z_TYPE_IMMEDIATE = {59'd0, INSTRUCTION[19:15]}; // Z-type uses Immediate bits 19-15: Format as with the top 59 bits being zero extended then associated 5 bits (19-15 bits)

    // Determine Immediate Value based on Selected Immediate Type:
    always_comb begin
        unique case (IMMEDIATE_TYPE_SELECT)
            IMMEDIATE_I: IMMEDIATE = I_TYPE_IMMEDIATE;
            IMMEDIATE_S: IMMEDIATE = S_TYPE_IMMEDIATE;
            IMMEDIATE_B: IMMEDIATE = B_TYPE_IMMEDIATE;
            IMMEDIATE_U: IMMEDIATE = U_TYPE_IMMEDIATE;
            IMMEDIATE_J: IMMEDIATE = J_TYPE_IMMEDIATE;
            IMMEDIATE_Z: IMMEDIATE = Z_TYPE_IMMEDIATE;
            default: IMMEDIATE = 64'd0;
        endcase
    end

endmodule

`default_nettype wire
