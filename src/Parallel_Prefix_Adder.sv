`default_nettype none

// =====================================================================================================
// Parallel Prefix Adder (Kogge-Stone): SUM = A + B + CARRY_IN in log2(WIDTH) levels of logic.
//
// Why: a ripple-carry adder makes bit i wait for the carry of bit i-1, so a 64-bit add is 64 carry
// steps in a row (about 21 ns on sky130; 14.3 ns of the EECS 151 chip's 26 ns clock was exactly this).
// A prefix adder computes every carry at once from "generate" and "propagate" signals:
//
//   level 0 : GENERATE[i] = A[i] & B[i]          PROPAGATE[i] = A[i] ^ B[i]
//   level k : combine each bit with the bit 2^(k-1) places to its right
//             (G, P) o (G', P') = (G | P & G', P & P')
//   after log2(WIDTH) levels every bit knows whether a carry reaches it  -> SUM[i] = PROPAGATE[i] ^ CARRY[i]
//
// Kogge and Stone (1973) use the most wires but the fewest levels: 6 levels for 64 bits.
// =====================================================================================================
module ParallelPrefixAdder #(
    parameter int WIDTH = 64
) (
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic CARRY_IN,
    output logic [WIDTH-1:0] SUM,
    output logic CARRY_OUT
);

    localparam int LEVELS = $clog2(WIDTH + 1); // + 1 because the carry-in behaves like an extra bit below bit 0

    // Bit 0 of every level is the carry-in "bit", so position i of each level is adder bit i-1.
    // One named GENERATE/PROPAGATE pair per level (level k only reads level k-1).
    logic [WIDTH-1:0] BIT_PROPAGATE; // A ^ B for each bit (needed again for the final sum)
    assign BIT_PROPAGATE = A ^ B;

    genvar LEVEL, BIT_INDEX;
    generate
        for (LEVEL = 0; LEVEL <= LEVELS; LEVEL = LEVEL + 1) begin : prefix_level
            logic [WIDTH:0] GENERATE;
            logic [WIDTH:0] PROPAGATE;
            if (LEVEL == 0) begin : inputs
                assign GENERATE = {A & B, CARRY_IN}; // The carry-in generates a carry into bit 0
                assign PROPAGATE = {BIT_PROPAGATE, 1'b0};
            end else begin : combine_level
                localparam int DISTANCE = 1 << (LEVEL - 1); // 1, 2, 4, 8, 16, 32, 64
                for (BIT_INDEX = 0; BIT_INDEX <= WIDTH; BIT_INDEX = BIT_INDEX + 1) begin : prefix_bit
                    if (BIT_INDEX >= DISTANCE) begin : combine
                        assign GENERATE[BIT_INDEX] = prefix_level[LEVEL-1].GENERATE[BIT_INDEX] | (prefix_level[LEVEL-1].PROPAGATE[BIT_INDEX] & prefix_level[LEVEL-1].GENERATE[BIT_INDEX-DISTANCE]);
                        assign PROPAGATE[BIT_INDEX] = prefix_level[LEVEL-1].PROPAGATE[BIT_INDEX] & prefix_level[LEVEL-1].PROPAGATE[BIT_INDEX-DISTANCE];
                    end else begin : pass
                        assign GENERATE[BIT_INDEX] = prefix_level[LEVEL-1].GENERATE[BIT_INDEX]; // Already final: nothing further right to combine with
                        assign PROPAGATE[BIT_INDEX] = prefix_level[LEVEL-1].PROPAGATE[BIT_INDEX];
                    end
                end
            end
        end
    endgenerate

    // prefix_level[LEVELS].GENERATE[i] = "a carry comes out of bit i-1" = the carry INTO adder bit i
    assign SUM = BIT_PROPAGATE ^ prefix_level[LEVELS].GENERATE[WIDTH-1:0];
    assign CARRY_OUT = prefix_level[LEVELS].GENERATE[WIDTH];

endmodule

`default_nettype wire
