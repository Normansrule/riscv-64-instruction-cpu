`default_nettype none

// =====================================================================================================
// Data Cache: 4 KiB, 2-way set-associative, 32-byte lines (4 doublewords), 64 sets x 2 ways, write-through.
//
//   address bits:  [31:11] tag   [10:5] set index   [4:3] doubleword in the line   [2:0] byte
//
// Loads look up the address the ALU computed in EXECUTE. A hit (either way) returns the doubleword that
// cycle; a miss makes HIT = 0 and the core holds the load in EXECUTE (DATA_CACHE_STALL) while the refill
// engine brings the line from main memory: MISS_LATENCY + 1 cycles in total.
// Stores go straight to main memory (write-through) and also update the cached line if it is present
// (no allocation on a store miss). Replacement: an empty way first, otherwise the least recently used.
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

    logic [63:0] WAY0_VALID, WAY1_VALID;
    logic [20:0] WAY0_TAG [0:63];
    logic [20:0] WAY1_TAG [0:63];
    logic [255:0] WAY0_DATA [0:63];
    logic [255:0] WAY1_DATA [0:63];
    logic [63:0] LEAST_RECENTLY_USED;

    logic [5:0] SET;
    logic HIT_WAY0, HIT_WAY1, LINE_PRESENT;
    assign SET = ADDRESS[10:5];
    assign HIT_WAY0 = WAY0_VALID[SET] && (WAY0_TAG[SET] == ADDRESS[31:11]) && (ADDRESS[63:32] == 32'd0);
    assign HIT_WAY1 = WAY1_VALID[SET] && (WAY1_TAG[SET] == ADDRESS[31:11]) && (ADDRESS[63:32] == 32'd0);
    assign LINE_PRESENT = HIT_WAY0 || HIT_WAY1;
    assign HIT = !LOAD_REQUEST || LINE_PRESENT;
    assign READ_DATA = HIT_WAY1 ? WAY1_DATA[SET][64*ADDRESS[4:3] +: 64] : WAY0_DATA[SET][64*ADDRESS[4:3] +: 64];

    logic REFILL_BUSY;
    logic [5:0] REFILL_CYCLES_LEFT;
    logic [63:0] REFILL_LINE_ADDRESS;
    logic [5:0] REFILL_SET;
    logic REFILL_VICTIM_WAY;
    logic INSTALL;
    logic STORE_HIT; // A store to a line that is cached: update it
    assign REFILL_SET = REFILL_LINE_ADDRESS[10:5];
    assign REFILL_VICTIM_WAY = !WAY0_VALID[REFILL_SET] ? 1'b0 : !WAY1_VALID[REFILL_SET] ? 1'b1 : LEAST_RECENTLY_USED[REFILL_SET];
    assign INSTALL = REFILL_BUSY && (REFILL_CYCLES_LEFT == 6'd1);
    assign STORE_HIT = (|WRITE_MASK) && LINE_PRESENT;
    assign REFILL_ADDRESS = REFILL_LINE_ADDRESS;

    always_ff @(posedge clk) begin
        if (reset) begin
            WAY0_VALID <= '0;
            WAY1_VALID <= '0;
            LEAST_RECENTLY_USED <= '0;
            REFILL_BUSY <= 1'b0;
            REFILL_CYCLES_LEFT <= 6'd0;
            REFILL_LINE_ADDRESS <= 64'd0;
        end else if (!FREEZE) begin
            if ((LOAD_REQUEST || (|WRITE_MASK)) && LINE_PRESENT) LEAST_RECENTLY_USED[SET] <= HIT_WAY0; // used: the other way is now LRU
            if (!REFILL_BUSY) begin
                if (LOAD_REQUEST && !LINE_PRESENT) begin
                    REFILL_BUSY <= 1'b1;
                    REFILL_CYCLES_LEFT <= MISS_LATENCY[5:0];
                    REFILL_LINE_ADDRESS <= {ADDRESS[63:5], 5'b00000};
                end
            end else if (INSTALL) begin
                REFILL_BUSY <= 1'b0;
                if (REFILL_VICTIM_WAY) WAY1_VALID[REFILL_SET] <= 1'b1; else WAY0_VALID[REFILL_SET] <= 1'b1;
                LEAST_RECENTLY_USED[REFILL_SET] <= !REFILL_VICTIM_WAY;
            end else begin
                REFILL_CYCLES_LEFT <= REFILL_CYCLES_LEFT - 6'd1;
            end
        end
    end

    // Line data: refill writes a whole line; a store hit merges its bytes into the way that hit
    // (stores never happen during a data refill: the missing load is holding EXECUTE)
    logic [255:0] MERGED_LINE;
    always_comb begin
        MERGED_LINE = HIT_WAY1 ? WAY1_DATA[SET] : WAY0_DATA[SET];
        for (int BYTE_LANE = 0; BYTE_LANE < 8; BYTE_LANE = BYTE_LANE + 1)
            if (WRITE_MASK[BYTE_LANE]) MERGED_LINE[64*ADDRESS[4:3] + 8*BYTE_LANE +: 8] = WRITE_DATA[8*BYTE_LANE +: 8];
    end
    always_ff @(posedge clk) begin
        if (!reset && !FREEZE) begin
            if (INSTALL) begin
                if (REFILL_VICTIM_WAY) begin
                    WAY1_TAG[REFILL_SET] <= REFILL_LINE_ADDRESS[31:11];
                    WAY1_DATA[REFILL_SET] <= REFILL_LINE;
                end else begin
                    WAY0_TAG[REFILL_SET] <= REFILL_LINE_ADDRESS[31:11];
                    WAY0_DATA[REFILL_SET] <= REFILL_LINE;
                end
            end else if (STORE_HIT) begin
                if (HIT_WAY1) WAY1_DATA[SET] <= MERGED_LINE; else WAY0_DATA[SET] <= MERGED_LINE;
            end
        end
    end

endmodule

`default_nettype wire
