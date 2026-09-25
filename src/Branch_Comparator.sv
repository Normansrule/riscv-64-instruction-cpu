`default_nettype none

import opcode_pkg::*;

module BranchComparator (
    input  logic [63:0] A, // rs1
    input  logic [63:0] B, // rs2
    input  logic [2:0] BRANCH_FUNCT3, // funct3 determines which branch condition to use
    output logic BRANCH_TAKEN // signal whether or not to branch
);

    logic BRANCH_EQUALS; // 1 if A == B, 0 otherwise
    logic BRANCH_LT_SIGNED; // 1 if A < B (signed), 0 otherwise
    logic BRANCH_LT_UNSIGNED; // 1 if A < B (unsigned), 0 otherwise

    always_comb begin
        BRANCH_EQUALS = (A == B); // Branch if rs1 == rs2
        BRANCH_LT_SIGNED = ($signed(A) < $signed(B)); // Branch if rs1 < rs2 (signed)
        BRANCH_LT_UNSIGNED = (A < B); // Branch if rs1 < rs2 (unsigned)

        unique case (BRANCH_FUNCT3)
            FNC_BEQ: BRANCH_TAKEN = BRANCH_EQUALS; // Branch if A Equals B
            FNC_BNE: BRANCH_TAKEN = ~BRANCH_EQUALS; // Branch if A Not Equals B
            FNC_BLT: BRANCH_TAKEN = BRANCH_LT_SIGNED; // Branch if A less than B (signed)
            FNC_BGE: BRANCH_TAKEN = ~BRANCH_LT_SIGNED; // Branch if A not less than (greater than or equal) to B (signed)
            FNC_BLTU: BRANCH_TAKEN = BRANCH_LT_UNSIGNED; // Branch if A less than B (unsigned)
            FNC_BGEU: BRANCH_TAKEN = ~BRANCH_LT_UNSIGNED; // Branch if A not less than (greater than or equal) to B (unsigned)
            default: BRANCH_TAKEN = 1'b0; // In general default case would be to not take the branch
        endcase
    end

endmodule

`default_nettype wire
