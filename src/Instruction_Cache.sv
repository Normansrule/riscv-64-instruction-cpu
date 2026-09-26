`default_nettype none

// =====================================================================================================
// Instruction Cache: 4 KiB, direct-mapped, 32-byte lines (8 instructions per line), 128 lines.
//
//   address bits:  [31:12] tag   [11:5] line index   [4:2] word in the line   [1:0] always 00
//
// FETCH1 looks up its PC every cycle. A hit returns the instruction the same cycle (like the
// scratchpad did). A miss makes HIT = 0: the core sends a bubble to FETCH2 and keeps its PC while
// the refill engine fetches the whole line from main memory, which takes MISS_LATENCY cycles.
// A miss therefore costs MISS_LATENCY + 1 cycles (1 to notice it). One refill at a time.
// Next-line prefetch: after a demand miss fills line X, the engine fetches line X + 1 on its own
// (if it is not already cached and FETCH1 is not missing), because code mostly runs straight on.
// Instruction memory is never written by the program (no self-modifying code), so no invalidation.
// =====================================================================================================
module InstructionCache #(
    parameter int MISS_LATENCY = 10
) (
    input  logic clk,
    input  logic reset,
    input  logic FREEZE,
    input  logic [63:0] FETCH_ADDRESS,
    output logic [31:0] INSTRUCTION,
    output logic HIT,
    // Main memory refill port
    output logic [63:0] REFILL_ADDRESS, // Line address being filled
    input  logic [255:0] REFILL_LINE // The 32 bytes at REFILL_ADDRESS (main memory answers after MISS_LATENCY cycles)
);

    logic [127:0] LINE_VALID;
    logic [19:0] LINE_TAG [0:127];
    logic [255:0] LINE_DATA [0:127];

    logic [6:0] FETCH_INDEX;
    assign FETCH_INDEX = FETCH_ADDRESS[11:5];
    assign HIT = LINE_VALID[FETCH_INDEX] && (LINE_TAG[FETCH_INDEX] == FETCH_ADDRESS[31:12]) && (FETCH_ADDRESS[63:32] == 32'd0);
    assign INSTRUCTION = LINE_DATA[FETCH_INDEX][32*FETCH_ADDRESS[4:2] +: 32];

    // Refill engine
    logic REFILL_BUSY;
    logic [5:0] REFILL_CYCLES_LEFT;
    logic [63:0] REFILL_LINE_ADDRESS;
    logic REFILL_IS_DEMAND; // This refill was caused by a FETCH1 miss (not a prefetch)
    logic PREFETCH_PENDING; // Line X + 1 should be fetched when the engine is free
    logic [63:0] PREFETCH_LINE_ADDRESS;
    logic PREFETCH_PRESENT; // ... but it may already be in the cache
    assign PREFETCH_PRESENT = LINE_VALID[PREFETCH_LINE_ADDRESS[11:5]] && (LINE_TAG[PREFETCH_LINE_ADDRESS[11:5]] == PREFETCH_LINE_ADDRESS[31:12]);
    assign REFILL_ADDRESS = REFILL_LINE_ADDRESS;

    always_ff @(posedge clk) begin
        if (reset) begin
            LINE_VALID <= '0;
            REFILL_BUSY <= 1'b0;
            REFILL_CYCLES_LEFT <= 6'd0;
            REFILL_LINE_ADDRESS <= 64'd0;
            REFILL_IS_DEMAND <= 1'b0;
            PREFETCH_PENDING <= 1'b0;
            PREFETCH_LINE_ADDRESS <= 64'd0;
        end else if (!FREEZE) begin
            if (!REFILL_BUSY) begin
                if (!HIT) begin // Start fetching the missing line (demand first)
                    REFILL_BUSY <= 1'b1;
                    REFILL_CYCLES_LEFT <= MISS_LATENCY[5:0];
                    REFILL_LINE_ADDRESS <= {FETCH_ADDRESS[63:5], 5'b00000};
                    REFILL_IS_DEMAND <= 1'b1;
                end else if (PREFETCH_PENDING) begin // Nothing missing now: fetch the next line ahead of time
                    PREFETCH_PENDING <= 1'b0;
                    if (!PREFETCH_PRESENT) begin
                        REFILL_BUSY <= 1'b1;
                        REFILL_CYCLES_LEFT <= MISS_LATENCY[5:0];
                        REFILL_LINE_ADDRESS <= PREFETCH_LINE_ADDRESS;
                        REFILL_IS_DEMAND <= 1'b0;
                    end
                end
            end else if (REFILL_CYCLES_LEFT == 6'd1) begin // Main memory delivers the line: install it
                REFILL_BUSY <= 1'b0;
                LINE_VALID[REFILL_LINE_ADDRESS[11:5]] <= 1'b1;
                if (REFILL_IS_DEMAND) begin
                    PREFETCH_PENDING <= 1'b1;
                    PREFETCH_LINE_ADDRESS <= REFILL_LINE_ADDRESS + 64'd32;
                end
            end else begin
                REFILL_CYCLES_LEFT <= REFILL_CYCLES_LEFT - 6'd1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!reset && !FREEZE && REFILL_BUSY && (REFILL_CYCLES_LEFT == 6'd1)) begin
            LINE_TAG[REFILL_LINE_ADDRESS[11:5]] <= REFILL_LINE_ADDRESS[31:12];
            LINE_DATA[REFILL_LINE_ADDRESS[11:5]] <= REFILL_LINE;
        end
    end

endmodule

`default_nettype wire
