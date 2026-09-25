`default_nettype none

// Global Share (GShare) Branch Predictor (S. McFarling, "Combining Branch Predictors", DEC WRL TN-36, 1993)
//
//     FETCH_PC[HISTORY_BITS+1:2] ──┐
//                                  XOR ──► index ──► Branch History Table of 2-bit saturating counters
//     GLOBAL_HISTORY_REGISTER ─────┘                 counter >= 2'b10  ->  predict TAKEN
//
// Lifecycle of one branch through the 6 stage pipeline:
//   Fetch 1 : read the counter at index = PC xor GHR                                   (FETCH_PREDICTED_TAKEN)
//   Fetch 2 : the instruction is now known. If it IS a branch, shift the PREDICTED
//             direction into the Global History Register right away (speculative)  (SPECULATIVE_UPDATE)
//             and remember the GHR value it saw (the checkpoint) down the pipeline.
//   Execute : the real direction is known.
//             - train the counter that made the prediction                         (UPDATE_PREDICTION)
//             - on ANY flush, rewind the GHR to the checkpoint (+ the real outcome  (RESTORE_HISTORY)
//               if the flushing instruction is a branch), undoing the history the
//               wrong-path branches wrote.
// Improvement over the EECS 151 version: the history is only shifted for real branches (not every fetch)
// and a misprediction restores the exact checkpoint instead of shifting one more bit in.
module GSharePredictor #(
    parameter int HISTORY_BITS = 4 // 2^HISTORY_BITS counters: 4 bits gives the 16 entry table of the EECS 151 tape-out
) (
    input logic clk,
    input logic reset,
    input logic ENABLE, // 0 turns prediction off: every branch is predicted not taken (for experiments)
    // ===== Fetch 1: Prediction =====
    input logic [63:0] FETCH_PC, // FETCH 1 Stage Program Counter
    output logic FETCH_PREDICTED_TAKEN, // FETCH 1 Stage 0 means prediction is not taken, 1 means prediction is taken
    output logic [HISTORY_BITS-1:0] FETCH_PREDICTION_INDEX, // Branch History Table Index For this specific Branch
    output logic [HISTORY_BITS-1:0] GLOBAL_HISTORY, // Current Global History Register (Fetch 2 saves it as the checkpoint)
    // ===== Fetch 2: Speculative History Update =====
    input logic SPECULATIVE_UPDATE, // Fetch 2 holds a real branch that is moving on to Decode
    input logic SPECULATIVE_TAKEN, // ...and this is the direction that was predicted for it
    // ===== Execute: Training and Repair =====
    input logic UPDATE_PREDICTION, // Set to 0 for not a Branch, Set to 1 for is a Branch
    input logic [HISTORY_BITS-1:0] UPDATE_PREDICTION_INDEX, // Branch History Table Index used at the Prediction Time
    input logic ACTUAL_BRANCH_TAKEN, // Was Branch actually Taken this time? 0 Branch wasn't taken, 1 Branch was taken
    input logic RESTORE_HISTORY, // Execute is flushing the pipeline: rewind the history
    input logic [HISTORY_BITS-1:0] RESTORE_HISTORY_VALUE // The correct history after the flushing instruction
);

    localparam int BRANCH_HISTORY_TABLE_ENTRIES = (1 << HISTORY_BITS); // 16 entries for 4 History Bits
    logic [2*BRANCH_HISTORY_TABLE_ENTRIES-1:0] BRANCH_HISTORY_TABLE; // Packed 2-bit counters: entry i lives at [2*i +: 2]
    // Branch History Table States:
    // 2'b00 = strongly not taken
    // 2'b01 = weakly not taken
    // 2'b10 = weakly taken
    // 2'b11 = strongly taken

    logic [HISTORY_BITS-1:0] GLOBAL_HISTORY_REGISTER; // Store taken/not taken history to have branch history table correlate outcomes based on previous history
    logic [1:0] FETCH_COUNTER; // The counter read for the Fetch 1 prediction
    logic [1:0] UPDATE_COUNTER; // The counter being trained by the Execute Stage

    assign GLOBAL_HISTORY = GLOBAL_HISTORY_REGISTER;
    assign FETCH_PREDICTION_INDEX = FETCH_PC[HISTORY_BITS+1:2] ^ GLOBAL_HISTORY_REGISTER; // Index Prediction via Branch Address XOR Global History Register (The goal is to minimize having the same index)
    assign FETCH_COUNTER = BRANCH_HISTORY_TABLE[2*FETCH_PREDICTION_INDEX +: 2];
    assign FETCH_PREDICTED_TAKEN = ENABLE && FETCH_COUNTER[1]; // Fetch Predicted Taken is determined by most significant bit: 10 or 11 predict taken, 00 or 01 predict not taken
    assign UPDATE_COUNTER = BRANCH_HISTORY_TABLE[2*UPDATE_PREDICTION_INDEX +: 2];

    always_ff @(posedge clk) begin
        if (reset) begin
            GLOBAL_HISTORY_REGISTER <= '0; // Default just do not save any pattern reset it completely
            BRANCH_HISTORY_TABLE <= {BRANCH_HISTORY_TABLE_ENTRIES{2'b10}}; // On reset the default would be weakly taken with the goal that branches are more likely to be taken than not
        end
        else begin
            // Global History Register: a flush from Execute has priority because everything younger was on the wrong path
            if (RESTORE_HISTORY) begin
                GLOBAL_HISTORY_REGISTER <= RESTORE_HISTORY_VALUE; // Rewind the history to what actually happened
            end else if (SPECULATIVE_UPDATE) begin
                GLOBAL_HISTORY_REGISTER <= {GLOBAL_HISTORY_REGISTER[HISTORY_BITS-2:0], SPECULATIVE_TAKEN}; // Update Global History Register with the Fetch Prediction
            end

            if (UPDATE_PREDICTION) begin // If a Real Branch Occurs and history table needs to be corrected/updated
                unique case (UPDATE_COUNTER) // Look into the Branch History Table at Specific Index
                    2'b00: BRANCH_HISTORY_TABLE[2*UPDATE_PREDICTION_INDEX +: 2] <= ACTUAL_BRANCH_TAKEN ? 2'b01 : 2'b00; // Strongly Not Taken will be held unless a Branch was taken then update to Weakly Not Taken
                    2'b01: BRANCH_HISTORY_TABLE[2*UPDATE_PREDICTION_INDEX +: 2] <= ACTUAL_BRANCH_TAKEN ? 2'b10 : 2'b00; // Weakly Not Taken will go back to Strongly Not Taken unless a Branch was taken then becomes the Weakly Taken
                    2'b10: BRANCH_HISTORY_TABLE[2*UPDATE_PREDICTION_INDEX +: 2] <= ACTUAL_BRANCH_TAKEN ? 2'b11 : 2'b01; // Weakly Taken will go back to Weakly Not Taken unless a Branch was taken then becomes Strongly Taken
                    2'b11: BRANCH_HISTORY_TABLE[2*UPDATE_PREDICTION_INDEX +: 2] <= ACTUAL_BRANCH_TAKEN ? 2'b11 : 2'b10; // Strongly Taken will go back to Weakly Taken unless a Branch was taken then holds at Strongly Taken
                    default: BRANCH_HISTORY_TABLE[2*UPDATE_PREDICTION_INDEX +: 2] <= 2'b10; // In general the logic would be weakly taken given that most assembly branch instruction will be taken so slightly favor the taken branch
                endcase
            end
        end
    end

    /* verilator lint_off UNUSEDSIGNAL */
    logic UNUSED_PC_BITS; // Only PC[HISTORY_BITS+1:2] indexes the table
    assign UNUSED_PC_BITS = ^{FETCH_PC[63:HISTORY_BITS+2], FETCH_PC[1:0]};
    /* verilator lint_on UNUSEDSIGNAL */

endmodule

`default_nettype wire

// Resources: https://www.ece.ucdavis.edu/~akella/270W05/mcfarling93combining.pdf
//            https://cseweb.ucsd.edu/classes/fa04/cse141L/bp_tutorial.pdf
//            K. Skadron, M. Martonosi, D. Clark, "Speculative Updates of Local and Global Branch History", JILP 2000
// Referenced Gshare Verilog Code: https://github.com/openrisc/mor1kx/blob/master/rtl/verilog/mor1kx_branch_predictor_gshare.v
