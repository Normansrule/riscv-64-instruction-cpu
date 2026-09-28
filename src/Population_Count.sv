`default_nettype none

// =====================================================================================================
// Population Count (cpop, cpopw): the number of 1 bits, as a tree of small adders.
//
//   level 1 : 32 two-bit sums of neighbouring bits      (0..2)
//   level 2 : 16 three-bit sums of neighbouring pairs   (0..4)
//   ...
//   level 6 : one seven-bit sum                          (0..64)
// Every level adds numbers one bit wider than the last, so the whole count is six small additions deep
// instead of 63 additions in a row. (The same idea, with full adders, is the Wallace tree in
// src/Carry_Save_Multiplier.sv.)
// =====================================================================================================
module PopulationCount (
    input  logic [63:0] X,
    output logic [6:0] COUNT
);

    genvar LEVEL, BLOCK;
    generate
        for (LEVEL = 1; LEVEL <= 6; LEVEL = LEVEL + 1) begin : sum_level
            localparam int BLOCKS = 64 >> LEVEL;
            logic [LEVEL:0] BLOCK_SUM [0:BLOCKS-1];
            for (BLOCK = 0; BLOCK < BLOCKS; BLOCK = BLOCK + 1) begin : block
                if (LEVEL == 1) begin : pair_of_bits
                    assign BLOCK_SUM[BLOCK] = {1'b0, X[2*BLOCK]} + {1'b0, X[2*BLOCK+1]};
                end else begin : pair_of_sums
                    assign BLOCK_SUM[BLOCK] = {1'b0, sum_level[LEVEL-1].BLOCK_SUM[2*BLOCK]} + {1'b0, sum_level[LEVEL-1].BLOCK_SUM[2*BLOCK+1]};
                end
            end
        end
    endgenerate
    assign COUNT = sum_level[6].BLOCK_SUM[0];

endmodule

`default_nettype wire
