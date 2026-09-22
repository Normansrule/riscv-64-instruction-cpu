`timescale 1ns/1ps
// =============================================================================
// branch_predictor.v — gshare direction predictor + branch target buffer.
//
// Why predict at all? Branches resolve in EX, 3 stages after IF. Guessing
// "not taken" costs 3 cycles on EVERY taken branch (most loop branches!).
// Guessing correctly in IF costs 0.
//
//   gshare (S. McFarling, "Combining Branch Predictors", DEC WRL TN-36, 1993):
//
//        PC[9:2] ──┐
//                  XOR ──► index ──► PHT[256] of 2-bit saturating counters
//        GHR[7:0] ─┘                 counter >= 2  ->  predict TAKEN
//
//   XOR-ing the global history (outcomes of the last 8 branches) into the
//   index lets the same branch use different counters in different contexts,
//   so correlated branches (if/else chains, loop exits) are learned.
//
//   2-bit counter (J. E. Smith, ISCA 1981):
//       00 strong NT ⇄ 01 weak NT ⇄ 10 weak T ⇄ 11 strong T
//       taken → count up, not taken → count down (saturating)
//
//   BTB: IF only knows the PC, not the instruction, so a 32-entry direct-
//   mapped branch target buffer remembers {tag, target, is_jump} for PCs
//   that were taken before. Predict taken = BTB hit && (is_jump || ctr>=2).
//
// Update policy: tables and GHR are written when the branch RESOLVES in EX
// (non-speculative history). Simple and exact, slightly less accurate than
// speculative history with repair (see docs/MATH.md).
// =============================================================================
module branch_predictor #(
    parameter GHR_BITS = 8,          // PHT has 2^GHR_BITS counters
    parameter BTB_BITS = 5           // BTB has 2^BTB_BITS entries
) (
    input  wire                clk,
    input  wire                rst,
    input  wire                enable,        // 0 = static "predict not taken"
    // ---- predict, in IF (combinational) ----
    input  wire [63:0]         if_pc,
    output wire                pred_taken,
    output wire [63:0]         pred_target,
    output wire [GHR_BITS-1:0] pred_idx,      // carried down the pipe for the update
    // ---- update, from EX (on the clock edge) ----
    input  wire                upd_valid,
    input  wire                upd_is_branch,
    input  wire                upd_is_jump,
    input  wire                upd_taken,
    input  wire [63:0]         upd_pc,
    input  wire [63:0]         upd_target,
    input  wire [GHR_BITS-1:0] upd_idx
);
    localparam PHT_N = 1 << GHR_BITS, BTB_N = 1 << BTB_BITS;

    reg [2*PHT_N-1:0]  pht;                       // PHT_N packed 2-bit counters: pht[2*i +: 2]
    reg [GHR_BITS-1:0] ghr;
    reg [BTB_N-1:0]    btb_valid;
    reg [24:0]         btb_tag   [0:BTB_N-1];     // PC[31:7]
    reg [63:0]         btb_tgt   [0:BTB_N-1];
    reg                btb_jump  [0:BTB_N-1];

    // ---------------- predict ----------------
    wire [BTB_BITS-1:0] bi  = if_pc[BTB_BITS+1:2];
    wire                hit = btb_valid[bi] && (btb_tag[bi] == if_pc[31:7]);
    assign pred_idx    = if_pc[GHR_BITS+1:2] ^ ghr;
    wire                ctr_msb = pht[2*pred_idx + 1];   // counter >= 2  <=>  top bit set
    assign pred_taken  = enable && hit && (btb_jump[bi] || ctr_msb);
    assign pred_target = pred_taken ? btb_tgt[bi] : 64'd0;

    // ---------------- update ----------------
    wire [BTB_BITS-1:0] ui = upd_pc[BTB_BITS+1:2];
    wire [1:0]          uctr = pht[2*upd_idx +: 2];
    always @(posedge clk) begin
        if (rst) begin
            ghr       <= {GHR_BITS{1'b0}};
            pht       <= {PHT_N{2'b01}};                  // every counter weakly not-taken
            btb_valid <= {BTB_N{1'b0}};
        end else if (upd_valid) begin
            if (upd_is_branch) begin
                if (upd_taken && uctr != 2'b11)  pht[2*upd_idx +: 2] <= uctr + 2'b01;
                if (!upd_taken && uctr != 2'b00) pht[2*upd_idx +: 2] <= uctr - 2'b01;
                ghr <= {ghr[GHR_BITS-2:0], upd_taken};
            end
            if ((upd_is_branch && upd_taken) || upd_is_jump) begin
                btb_valid[ui] <= 1'b1;
                btb_tag[ui]   <= upd_pc[31:7];
                btb_tgt[ui]   <= upd_target;
                btb_jump[ui]  <= upd_is_jump;
            end
        end
    end

    // unused upper PC bits (memory is 64 KiB; tags keep bits 31:7)
    /* verilator lint_off UNUSEDSIGNAL */
    wire unused = &{if_pc[63:32], upd_pc[63:32], upd_pc[1:0], if_pc[1:0]};
    /* verilator lint_on UNUSEDSIGNAL */
endmodule
