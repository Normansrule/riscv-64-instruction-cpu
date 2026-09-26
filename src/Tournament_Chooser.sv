`default_nettype none

// =====================================================================================================
// Tournament Chooser: a per-branch Branch History Table (BHT) plus a chooser, next to the GSharePredictor.
//
// Two predictors are good at different branches:
//   BHT (bimodal) : one 2-bit counter per branch address. Learns fast; ideal for "almost always taken".
//   GShare        : counter picked by address XOR global history. Learns patterns across branches,
//                   but needs more time to warm up and suffers from aliasing.
// The chooser keeps one more 2-bit counter per branch address saying WHICH predictor to trust
// (>= 2'b10: trust GShare). When the two disagree, the chooser moves toward the one that was right.
// This is the scheme of the Alpha 21264 (Kessler 1999) and McFarling's "combining" predictor (1993).
// =====================================================================================================
module TournamentChooser #(
    parameter int INDEX_BITS = 7 // 128 BHT counters + 128 chooser counters
) (
    input  logic clk,
    input  logic reset,
    input  logic ENABLE,
    // ===== Fetch 1 =====
    input  logic [63:0] FETCH_PC,
    output logic BHT_PREDICTED_TAKEN, // The per-branch counter's guess
    output logic CHOOSE_GSHARE, // Trust GShare (1) or the BHT (0) for this branch
    // ===== Execute: training =====
    input  logic UPDATE, // A branch resolved in Execute
    input  logic [63:0] UPDATE_PC,
    input  logic ACTUAL_BRANCH_TAKEN,
    input  logic BHT_WAS_TAKEN, // What the BHT predicted for it back in Fetch 1
    input  logic GSHARE_WAS_TAKEN // What GShare predicted for it back in Fetch 1
);

    localparam int ENTRIES = 1 << INDEX_BITS;
    logic [2*ENTRIES-1:0] BRANCH_HISTORY_TABLE; // 2-bit counters, entry i at [2*i +: 2]
    logic [2*ENTRIES-1:0] CHOOSER_TABLE;

    logic [INDEX_BITS-1:0] FETCH_INDEX, UPDATE_INDEX;
    assign FETCH_INDEX = FETCH_PC[INDEX_BITS+1:2];
    assign UPDATE_INDEX = UPDATE_PC[INDEX_BITS+1:2];

    logic [1:0] FETCH_BHT_COUNTER, FETCH_CHOOSER_COUNTER, UPDATE_BHT_COUNTER, UPDATE_CHOOSER_COUNTER;
    assign FETCH_BHT_COUNTER = BRANCH_HISTORY_TABLE[2*FETCH_INDEX +: 2];
    assign FETCH_CHOOSER_COUNTER = CHOOSER_TABLE[2*FETCH_INDEX +: 2];
    assign UPDATE_BHT_COUNTER = BRANCH_HISTORY_TABLE[2*UPDATE_INDEX +: 2];
    assign UPDATE_CHOOSER_COUNTER = CHOOSER_TABLE[2*UPDATE_INDEX +: 2];
    assign BHT_PREDICTED_TAKEN = ENABLE && FETCH_BHT_COUNTER[1];
    assign CHOOSE_GSHARE = FETCH_CHOOSER_COUNTER[1];

    logic GSHARE_WAS_RIGHT, BHT_WAS_RIGHT;
    assign GSHARE_WAS_RIGHT = (GSHARE_WAS_TAKEN == ACTUAL_BRANCH_TAKEN);
    assign BHT_WAS_RIGHT = (BHT_WAS_TAKEN == ACTUAL_BRANCH_TAKEN);

    always_ff @(posedge clk) begin
        if (reset) begin
            BRANCH_HISTORY_TABLE <= {ENTRIES{2'b10}}; // weakly taken
            CHOOSER_TABLE <= {ENTRIES{2'b01}}; // weakly trust the BHT: it warms up faster
        end else if (UPDATE) begin
            // BHT: ordinary 2-bit saturating counter
            if (ACTUAL_BRANCH_TAKEN && (UPDATE_BHT_COUNTER != 2'b11)) BRANCH_HISTORY_TABLE[2*UPDATE_INDEX +: 2] <= UPDATE_BHT_COUNTER + 2'b01;
            else if (!ACTUAL_BRANCH_TAKEN && (UPDATE_BHT_COUNTER != 2'b00)) BRANCH_HISTORY_TABLE[2*UPDATE_INDEX +: 2] <= UPDATE_BHT_COUNTER - 2'b01;
            // Chooser: only learns when the two predictors disagreed
            if (GSHARE_WAS_RIGHT && !BHT_WAS_RIGHT && (UPDATE_CHOOSER_COUNTER != 2'b11)) CHOOSER_TABLE[2*UPDATE_INDEX +: 2] <= UPDATE_CHOOSER_COUNTER + 2'b01;
            else if (BHT_WAS_RIGHT && !GSHARE_WAS_RIGHT && (UPDATE_CHOOSER_COUNTER != 2'b00)) CHOOSER_TABLE[2*UPDATE_INDEX +: 2] <= UPDATE_CHOOSER_COUNTER - 2'b01;
        end
    end

    /* verilator lint_off UNUSEDSIGNAL */
    logic UNUSED_BITS;
    assign UNUSED_BITS = ^{FETCH_PC[63:INDEX_BITS+2], FETCH_PC[1:0], UPDATE_PC[63:INDEX_BITS+2], UPDATE_PC[1:0]};
    /* verilator lint_on UNUSEDSIGNAL */

endmodule

`default_nettype wire
