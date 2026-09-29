`default_nettype none

// =====================================================================================================
// Prefix Negate: two's complement -X in log2(WIDTH) levels.
//
// -X = ~X + 1 is an increment, and an increment's carry ripples through every bit. The same result has a
// carry-free description: keep every bit up to and including the LOWEST 1, invert every bit above it.
//   NEGATED[i] = X[i] ^ ANY_LOWER_BIT_SET[i],   ANY_LOWER_BIT_SET[i] = X[i-1] | X[i-2] | ... | X[0]
// ANY_LOWER_BIT_SET is a prefix OR, computed Kogge-Stone style (6 levels for 64 bits, 7 for 128).
// =====================================================================================================
module PrefixNegate #(
    parameter int WIDTH = 64
) (
    input  logic [WIDTH-1:0] X,
    output logic [WIDTH-1:0] NEGATED
);

`ifdef SIXFOLD_FPGA
    assign NEGATED = -X; // the FPGA carry chain (see src/Parallel_Prefix_Adder.sv)
`else
    localparam int LEVELS = $clog2(WIDTH);

    genvar LEVEL, BIT_INDEX;
    generate
        for (LEVEL = 0; LEVEL <= LEVELS; LEVEL = LEVEL + 1) begin : or_level
            logic [WIDTH-1:0] ANY_SET; // at the last level: OR of X[i:0]
            if (LEVEL == 0) begin : inputs
                assign ANY_SET = X;
            end else begin : combine_level
                localparam int DISTANCE = 1 << (LEVEL - 1);
                for (BIT_INDEX = 0; BIT_INDEX < WIDTH; BIT_INDEX = BIT_INDEX + 1) begin : or_bit
                    if (BIT_INDEX >= DISTANCE) begin : combine
                        assign ANY_SET[BIT_INDEX] = or_level[LEVEL-1].ANY_SET[BIT_INDEX] | or_level[LEVEL-1].ANY_SET[BIT_INDEX-DISTANCE];
                    end else begin : pass
                        assign ANY_SET[BIT_INDEX] = or_level[LEVEL-1].ANY_SET[BIT_INDEX];
                    end
                end
            end
        end
    endgenerate

    // Bit i flips when any bit BELOW i is set: shift the inclusive prefix OR up by one
    assign NEGATED = X ^ {or_level[LEVELS].ANY_SET[WIDTH-2:0], 1'b0};
`endif

endmodule

`default_nettype wire
