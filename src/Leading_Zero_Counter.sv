`default_nettype none

// =====================================================================================================
// Leading Zero Counter: how many 0 bits sit above the highest 1, as a tree (Oklobdzija 1994).
//
// Counting from the top one bit at a time is a chain of 64 tests. Instead neighbouring blocks are
// paired level by level:
//   block all zero = upper all zero AND lower all zero
//   block count    = upper all zero ? {1, lower count} : {0, upper count}
// 64 one-bit blocks -> 32 two-bit blocks -> ... -> 1 block of 64: six levels of one small multiplexer.
// COUNT is 63 for an all-zero input (the lowest bit is never counted); ALL_ZERO tells the two apart.
// Used by the divider (to skip the dividend's leading zeros) and by the ALU (clz, ctz, clzw, ctzw).
// =====================================================================================================
module LeadingZeroCounter (
    input  logic [63:0] X,
    output logic [5:0] COUNT,
    output logic ALL_ZERO
);

    genvar LEVEL, BLOCK;
    generate
        for (LEVEL = 1; LEVEL <= 6; LEVEL = LEVEL + 1) begin : zero_count
            localparam int BLOCKS = 64 >> LEVEL;
            logic [BLOCKS-1:0] BLOCK_ALL_ZERO;
            logic [LEVEL-1:0] BLOCK_COUNT [0:BLOCKS-1];
            for (BLOCK = 0; BLOCK < BLOCKS; BLOCK = BLOCK + 1) begin : block
                if (LEVEL == 1) begin : pair_of_bits
                    assign BLOCK_ALL_ZERO[BLOCK] = ~X[2*BLOCK+1] & ~X[2*BLOCK];
                    assign BLOCK_COUNT[BLOCK] = ~X[2*BLOCK+1];
                end else begin : pair_of_blocks
                    logic UPPER_ZERO;
                    assign UPPER_ZERO = zero_count[LEVEL-1].BLOCK_ALL_ZERO[2*BLOCK+1];
                    assign BLOCK_ALL_ZERO[BLOCK] = UPPER_ZERO & zero_count[LEVEL-1].BLOCK_ALL_ZERO[2*BLOCK];
                    assign BLOCK_COUNT[BLOCK] = UPPER_ZERO ? {1'b1, zero_count[LEVEL-1].BLOCK_COUNT[2*BLOCK]} : {1'b0, zero_count[LEVEL-1].BLOCK_COUNT[2*BLOCK+1]};
                end
            end
        end
    endgenerate
    assign COUNT = zero_count[6].BLOCK_COUNT[0];
    assign ALL_ZERO = zero_count[6].BLOCK_ALL_ZERO[0];

endmodule

`default_nettype wire
