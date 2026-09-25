`default_nettype none

module GSharePredictor #(
    parameter int HISTORY_BITS = 4 // 2^HISTORY_BITS gives in this case 16 entries gives around 90 percent accuracy versus 50 percent with no prediction
) (
    input logic clk,
    input logic reset,
    input logic [31:0] FETCH_PC, // FETCH Stage Program Counter
    input logic FETCH_IS_A_BRANCH_INSTRUCTION, // FETCH Stage Instruction is a Branch type
    output logic FETCH_PREDICTED_TAKEN, // FETCH Stage 0 means prediction is not taken, 1 means prediction is taken
    output logic [HISTORY_BITS-1:0] FETCH_PREDICTION_INDEX, // Branch History Table Index For this specific Branch
    input logic UPDATE_PREDICTION, // Set to 0 for not a Branch, Set to 1 for is a Branch
    input logic [HISTORY_BITS-1:0] UPDATE_PREDICTION_INDEX, // Branch History Table Index used at the Prediction Time
    input logic ACTUAL_BRANCH_TAKEN, // Was Branch actually Taken this time? 0 Branch wasn't taken, 1 Branch was taken
    input logic UPDATE_MISPREDICTION // 0 if prediction was correct, 1 if prediction was not meaning its a misprediction
);

    localparam int BRANCH_HISTORY_TABLE_ENTRIES = (1 << HISTORY_BITS); // Store up to 64 entries for 6 History Bits
    logic [1:0] BRANCH_HISTORY_TABLE [0:BRANCH_HISTORY_TABLE_ENTRIES-1]; 
    // Branch History Table States:
    // 2'b00 = strongly not taken
    // 2'b01 = weakly not taken
    // 2'b10 = weakly taken
    // 2'b11 = strongly taken

    // Example Branch History Table with 4 History Bits (16 Entries):
    // Index | History (2 bits) | Prediction
    // 0     | 00               | Strongly Not Taken
    // 1     | 00               | Strongly Not Taken
    // 2     | 00               | Strongly Not Taken
    // 3     | 00               | Strongly Not Taken
    // 4     | 01               | Weakly Not Taken
    // 5     | 01               | Weakly Not Taken
    // 6     | 01               | Weakly Not Taken
    // 7     | 01               | Weakly Not Taken
    // 8     | 10               | Weakly Taken
    // 9     | 10               | Weakly Taken
    // 10    | 10               | Weakly Taken
    // 11    | 10               | Weakly Taken
    // 12    | 11               | Strongly Taken
    // 13    | 11               | Strongly Taken
    // 14    | 11               | Strongly Taken
    // 15    | 11               | Strongly Taken

    logic [HISTORY_BITS-1:0] GLOBAL_HISTORY_REGISTER; // Store taken/not taken history to have branch history table correlate outcomes based on previous history
    assign FETCH_PREDICTION_INDEX = FETCH_PC[HISTORY_BITS+1:2] ^ GLOBAL_HISTORY_REGISTER; // Index Prediction via Branch Address XOR Global History Register (The goal is to minimize haivng the same index) 

    always_comb begin
        if (FETCH_IS_A_BRANCH_INSTRUCTION) begin // If FETCH Instruction is a Branch type
            FETCH_PREDICTED_TAKEN = BRANCH_HISTORY_TABLE[FETCH_PREDICTION_INDEX][1]; // Look at Branch HIstory Table at determined index and place a 1 (with logic that minimizes overlap)
            // Fetch Predicted Taken is determined by most significant bit if 10 or 11 then predict that branch is taken, if its a 00 or 01 then predict that branch is not taken
        end else begin
            FETCH_PREDICTED_TAKEN = 1'b0; // Otherwise FETCH Prediction is just not taken
        end
    end

    integer BRANCH_HISTORY_TABLE_INDEX;

    always_ff @(posedge clk) begin
        if (reset) begin
            GLOBAL_HISTORY_REGISTER <= '0; // Default just do not save any pattern reset it completely
            for (BRANCH_HISTORY_TABLE_INDEX = 0; BRANCH_HISTORY_TABLE_INDEX < BRANCH_HISTORY_TABLE_ENTRIES; BRANCH_HISTORY_TABLE_INDEX = BRANCH_HISTORY_TABLE_INDEX + 1) begin
                BRANCH_HISTORY_TABLE[BRANCH_HISTORY_TABLE_INDEX] <= 2'b10; // On reset the default would be weakly taken with the goal that branchs are more likely to be taken than not
            end
        end
        else begin
            if (FETCH_IS_A_BRANCH_INSTRUCTION) begin // If FETCH Instruction is a Branch type
                GLOBAL_HISTORY_REGISTER <= {GLOBAL_HISTORY_REGISTER[HISTORY_BITS-2:0], FETCH_PREDICTED_TAKEN}; // Update Global History Register with the FETCH Prediction
            end

            if (UPDATE_PREDICTION && UPDATE_MISPREDICTION) begin // If a Real Branch Occured and it was a Misprediction 
                GLOBAL_HISTORY_REGISTER <= {GLOBAL_HISTORY_REGISTER[HISTORY_BITS-2:0], ACTUAL_BRANCH_TAKEN}; // Update Global History Register with the Actual Branch Taken Value to make sure actual branch history is correct
            end

            if (UPDATE_PREDICTION) begin // If a Real Branch Occurs and history table needs to be corrected/updated
                unique case (BRANCH_HISTORY_TABLE[UPDATE_PREDICTION_INDEX]) // Look into the Branch History Table at Specific Index 
                    2'b00: BRANCH_HISTORY_TABLE[UPDATE_PREDICTION_INDEX] <= ACTUAL_BRANCH_TAKEN ? 2'b01 : 2'b00; // Strongly Not Taken will be held unless a Branch was taken then update to Weakly Not Taken
                    2'b01: BRANCH_HISTORY_TABLE[UPDATE_PREDICTION_INDEX] <= ACTUAL_BRANCH_TAKEN ? 2'b10 : 2'b00; // Weakly Not Taken will go back to Strongly Not Taken unless a Branch was taken then becomes the Weakly Taken
                    2'b10: BRANCH_HISTORY_TABLE[UPDATE_PREDICTION_INDEX] <= ACTUAL_BRANCH_TAKEN ? 2'b11 : 2'b01; // Weakly Taken will go back to Weakly Not Taken unless a Branch was taken then becomes Strongly Taken
                    2'b11: BRANCH_HISTORY_TABLE[UPDATE_PREDICTION_INDEX] <= ACTUAL_BRANCH_TAKEN ? 2'b11 : 2'b10; // Strongly Taken will will go back to Weakly Taken unless a Branch was takn then holds at Strongly Taken
                    default: BRANCH_HISTORY_TABLE[UPDATE_PREDICTION_INDEX] <= 2'b10; // In general the logic would be weakly taken given that most assembly branch instruction will be taken so slightly favor the taken branch
                endcase
            end
        end
    end

endmodule

`default_nettype wire

// Resources: https://www.ece.ucdavis.edu/~akella/270W05/mcfarling93combining.pdf
//            https://cseweb.ucsd.edu/classes/fa04/cse141L/bp_tutorial.pdf
// Referenced Gshare Verilog Code: https://github.com/openrisc/mor1kx/blob/master/rtl/verilog/mor1kx_branch_predictor_gshare.v
