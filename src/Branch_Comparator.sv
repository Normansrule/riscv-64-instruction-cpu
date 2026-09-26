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

    // Less-than is a subtraction in disguise: A - B = A + ~B + 1, done by a prefix adder (6 levels, not 64 carry steps)
    logic [63:0] DIFFERENCE; // A - B
    logic NO_BORROW; // Carry out of A + ~B + 1: 1 means A >= B (unsigned)
    ParallelPrefixAdder #(.WIDTH(64)) compare_subtractor (
        .A (A),
        .B (~B),
        .CARRY_IN (1'b1),
        .SUM (DIFFERENCE),
        .CARRY_OUT (NO_BORROW)
    );

    always_comb begin
        BRANCH_EQUALS = (A == B); // Branch if rs1 == rs2 (64 XORs and an OR tree: already only a few levels)
        BRANCH_LT_UNSIGNED = !NO_BORROW; // A < B (unsigned) means A - B had to borrow
        BRANCH_LT_SIGNED = (A[63] != B[63]) ? A[63] : DIFFERENCE[63]; // Different signs: the negative one is smaller; same signs: the sign of A - B

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
