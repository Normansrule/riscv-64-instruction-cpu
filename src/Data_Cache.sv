`default_nettype none

// =====================================================================================================
// Data Cache: 4 KiB, direct-mapped, 32-byte lines (4 doublewords per line), 128 lines, write-through.
//
//   address bits:  [31:12] tag   [11:5] line index   [4:3] doubleword in the line   [2:0] byte
//
// Loads look up the address the ALU computed in EXECUTE. A hit returns the doubleword that cycle;
// a miss makes HIT = 0 and the core holds the load in EXECUTE (DATA_CACHE_STALL) while the refill
// engine brings the line from main memory: MISS_LATENCY + 1 cycles in total.
// Stores go straight to main memory (write-through: memory is always up to date, so a line can be
// dropped at any time) and also update the cached line if it is present (no allocation on a store miss).
// =====================================================================================================
module DataCache #(
    parameter int MISS_LATENCY = 10
) (
    input  logic clk,
    input  logic reset,
    input  logic FREEZE,
    input  logic LOAD_REQUEST, // A load is in EXECUTE
    input  logic [63:0] ADDRESS,
    input  logic [7:0] WRITE_MASK, // Store byte lanes (from StoreControl)
    input  logic [63:0] WRITE_DATA,
    output logic [63:0] READ_DATA, // The aligned doubleword
    output logic HIT, // 1 unless a load is waiting for its line
    // Main memory refill port
    output logic [63:0] REFILL_ADDRESS,
    input  logic [255:0] REFILL_LINE
);

    logic [127:0] LINE_VALID;
    logic [19:0] LINE_TAG [0:127];
    logic [255:0] LINE_DATA [0:127];

    logic [6:0] INDEX;
    logic LINE_PRESENT;
    assign INDEX = ADDRESS[11:5];
    assign LINE_PRESENT = LINE_VALID[INDEX] && (LINE_TAG[INDEX] == ADDRESS[31:12]) && (ADDRESS[63:32] == 32'd0);
    assign HIT = !LOAD_REQUEST || LINE_PRESENT;
    assign READ_DATA = LINE_DATA[INDEX][64*ADDRESS[4:3] +: 64];

    logic REFILL_BUSY;
    logic [5:0] REFILL_CYCLES_LEFT;
    logic [63:0] REFILL_LINE_ADDRESS;
    assign REFILL_ADDRESS = REFILL_LINE_ADDRESS;

    always_ff @(posedge clk) begin
        if (reset) begin
            LINE_VALID <= '0;
            REFILL_BUSY <= 1'b0;
            REFILL_CYCLES_LEFT <= 6'd0;
            REFILL_LINE_ADDRESS <= 64'd0;
        end else if (!FREEZE) begin
            if (!REFILL_BUSY) begin
                if (LOAD_REQUEST && !LINE_PRESENT) begin
                    REFILL_BUSY <= 1'b1;
                    REFILL_CYCLES_LEFT <= MISS_LATENCY[5:0];
                    REFILL_LINE_ADDRESS <= {ADDRESS[63:5], 5'b00000};
                end
            end else if (REFILL_CYCLES_LEFT == 6'd1) begin
                REFILL_BUSY <= 1'b0;
                LINE_VALID[REFILL_LINE_ADDRESS[11:5]] <= 1'b1;
            end else begin
                REFILL_CYCLES_LEFT <= REFILL_CYCLES_LEFT - 6'd1;
            end
        end
    end

    // Line data: refill writes the whole line; a store hit merges its bytes (stores never happen during a refill:
    // the missing load is holding EXECUTE)
    logic [255:0] MERGED_LINE; // The cached line with the store's bytes written in
    always_comb begin
        MERGED_LINE = LINE_DATA[INDEX];
        for (int BYTE_LANE = 0; BYTE_LANE < 8; BYTE_LANE = BYTE_LANE + 1)
            if (WRITE_MASK[BYTE_LANE]) MERGED_LINE[64*ADDRESS[4:3] + 8*BYTE_LANE +: 8] = WRITE_DATA[8*BYTE_LANE +: 8];
    end
    always_ff @(posedge clk) begin
        if (!reset && !FREEZE) begin
            if (REFILL_BUSY && (REFILL_CYCLES_LEFT == 6'd1)) begin
                LINE_TAG[REFILL_LINE_ADDRESS[11:5]] <= REFILL_LINE_ADDRESS[31:12];
                LINE_DATA[REFILL_LINE_ADDRESS[11:5]] <= REFILL_LINE;
            end else if ((|WRITE_MASK) && LINE_PRESENT) begin
                LINE_DATA[INDEX] <= MERGED_LINE;
            end
        end
    end

endmodule

`default_nettype wire
