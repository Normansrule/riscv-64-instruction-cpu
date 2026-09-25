`default_nettype none

import opcode_pkg::*;

// Branch Control: compares what the Branch Predictor guessed back in Fetch with what REALLY happened in Execute
//   Branch : predicted taken/not taken by the GShare predictor, resolved here -> flush only if the guess was wrong
//   JAL    : always redirected in Fetch 2 (target is known from the instruction bits) -> never wrong
//   JALR   : target depends on a register -> not predicted -> always flushes (see docs/EXPERIMENTS.md Lab 6 for a fix)
module BranchControl (
    input logic IS_A_BRANCH_INSTRUCTION,
    input logic IS_A_JAL_INSTRUCTION,
    input logic IS_A_JALR_INSTRUCTION,
    input logic ACTUALLY_TAKEN_BRANCH,
    input logic PREDICTED_BRANCH_TAKEN,
    input logic [63:0] PC_ADD_4,
    input logic [63:0] BRANCH_TARGET,
    input logic [63:0] JALR_TARGET,
    output logic BRANCH_WAS_ACTUALLY_TAKEN,
    output logic PREDICTION_WAS_WRONG,
    output logic FLUSH,
    output logic UPDATE_BRANCH_PREDICTOR,
    output logic [63:0] ADJUST_NEXT_PC
);

    always_comb begin
        BRANCH_WAS_ACTUALLY_TAKEN = 1'b0;
        PREDICTION_WAS_WRONG = 1'b0;
        FLUSH = 1'b0;
        UPDATE_BRANCH_PREDICTOR = 1'b0;
        ADJUST_NEXT_PC = PC_ADD_4;

        if (IS_A_BRANCH_INSTRUCTION) begin
            BRANCH_WAS_ACTUALLY_TAKEN = ACTUALLY_TAKEN_BRANCH;
            UPDATE_BRANCH_PREDICTOR = 1'b1;
            ADJUST_NEXT_PC = ACTUALLY_TAKEN_BRANCH ? BRANCH_TARGET : PC_ADD_4;
            PREDICTION_WAS_WRONG = (ACTUALLY_TAKEN_BRANCH != PREDICTED_BRANCH_TAKEN);
            FLUSH = (ACTUALLY_TAKEN_BRANCH != PREDICTED_BRANCH_TAKEN);
        end

        else if (IS_A_JAL_INSTRUCTION) begin
            BRANCH_WAS_ACTUALLY_TAKEN = 1'b1;
            ADJUST_NEXT_PC = BRANCH_TARGET;
            PREDICTION_WAS_WRONG = 1'b0;
            FLUSH = 1'b0;
        end

        else if (IS_A_JALR_INSTRUCTION) begin
            BRANCH_WAS_ACTUALLY_TAKEN = 1'b1;
            ADJUST_NEXT_PC = JALR_TARGET;
            PREDICTION_WAS_WRONG = 1'b1;
            FLUSH = 1'b1;
        end
    end

endmodule

`default_nettype wire
