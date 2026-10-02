`default_nettype none

// =====================================================================================================
// Carry-Save Multiply Step (a Wallace tree with a carry-save accumulator)
//
//   SUM_VECTOR + CARRY_VECTOR = ACCUMULATOR_SUM + ACCUMULATOR_CARRY + MULTIPLICAND x MULTIPLIER   (exactly)
//
// One step of the iterative multiplier: 64 x 16 bits plus the running high part of the product.
// Written as "ACCUMULATOR + MULTIPLICAND * MULTIPLIER", synthesis builds 16 rows of ripple adders, each
// waiting for the carries of the row above: that was the slowest path of the whole core (747 ps on the
// 7 nm-class library). This module never waits for a carry at all:
//
//   level 0 : 16 partial products (MULTIPLICAND shifted left by j, kept only if multiplier bit j is 1)
//             + the accumulator, which is itself kept as TWO numbers (sum and carry) = 18 numbers
//   level k : take the numbers three at a time and put every column through a full adder
//             (a 3:2 "carry-save" compressor):  x + y + z = SUM_BITS + 2 x CARRY_BITS
//             SUM_BITS = x ^ y ^ z,  CARRY_BITS = majority(x, y, z) shifted one column left.
//             Three numbers become two, and no carry moves more than one column per level.
//             18 -> 12 -> 8 -> 6 -> 4 -> 3 -> 2   (6 levels, one full adder deep each)
//
// The two numbers that come out are NOT added here: they go straight back in as the next step's
// accumulator. Only when the whole product is finished does one prefix adder (in the SIGN cycle of
// src/Iterative_Multiply_Divide_Unit.sv) turn the pair into a single number. This is how the
// multipliers in real CPUs work (Wallace 1964; they also use Booth recoding to halve the rows).
//
// Width: every level can push a carry one column higher, so WIDTH = A_WIDTH + B_WIDTH + LEVELS columns
// hold the exact sum with no bit ever falling off the top (64 + 16 + 6 = 86).
//
// On an FPGA (SIXFOLD_FPGA) the step is written as a plain multiply-add instead: the FPGA has hard
// multipliers (DSP slices: 25 x 18 bits on an Artix-7, 18 x 18 on an ECP5) that do the partial products
// in silicon, and a carry chain for the adds. A tree of lookup tables would cost about 2,400 of them, an
// eighth of the Basys 3's chip. The answer is the same pair with CARRY_VECTOR = 0, so the product, and
// every cycle count, are unchanged.
// =====================================================================================================
module CarrySaveMultiplyStep #(
    parameter int A_WIDTH = 64,
    parameter int B_WIDTH = 16,
    parameter int WIDTH = 86, // A_WIDTH + B_WIDTH + number of compressor levels
    parameter int ACCUMULATOR_WIDTH = 70 // WIDTH - B_WIDTH: the part that is shifted back in
) (
    input  logic [A_WIDTH-1:0] MULTIPLICAND,
    input  logic [B_WIDTH-1:0] MULTIPLIER,
    input  logic [ACCUMULATOR_WIDTH-1:0] ACCUMULATOR_SUM,
    input  logic [ACCUMULATOR_WIDTH-1:0] ACCUMULATOR_CARRY,
    output logic [WIDTH-1:0] SUM_VECTOR,
    output logic [WIDTH-1:0] CARRY_VECTOR
);

    localparam int OPERANDS = B_WIDTH + 2; // partial products + the two halves of the accumulator

    // How many numbers are left after each level of 3:2 compressors
    function automatic int count_after(input int level);
        int n;
        n = OPERANDS;
        for (int i = 0; i < level; i++) n = 2 * (n / 3) + (n % 3);
        return n;
    endfunction
    function automatic int levels_needed();
        int n, levels;
        n = OPERANDS; levels = 0;
        while (n > 2) begin n = 2 * (n / 3) + (n % 3); levels++; end
        return levels;
    endfunction
    localparam int LEVELS = levels_needed();

`ifdef SIXFOLD_FPGA
    assign SUM_VECTOR = WIDTH'(ACCUMULATOR_SUM) + WIDTH'(ACCUMULATOR_CARRY) + WIDTH'(MULTIPLICAND) * WIDTH'(MULTIPLIER);
    assign CARRY_VECTOR = '0;
`else
    genvar LEVEL, ROW;
    generate
        for (LEVEL = 0; LEVEL <= LEVELS; LEVEL = LEVEL + 1) begin : level
            localparam int COUNT = count_after(LEVEL);
            logic [WIDTH-1:0] OPERAND [0:COUNT-1];
            if (LEVEL == 0) begin : partial_products
                for (ROW = 0; ROW < B_WIDTH; ROW = ROW + 1) begin : row
                    assign OPERAND[ROW] = MULTIPLIER[ROW] ? ({{(WIDTH-A_WIDTH){1'b0}}, MULTIPLICAND} << ROW) : '0;
                end
                assign OPERAND[B_WIDTH] = {{(WIDTH-ACCUMULATOR_WIDTH){1'b0}}, ACCUMULATOR_SUM};
                assign OPERAND[B_WIDTH+1] = {{(WIDTH-ACCUMULATOR_WIDTH){1'b0}}, ACCUMULATOR_CARRY};
            end else begin : compress
                localparam int PREVIOUS = count_after(LEVEL - 1);
                for (ROW = 0; ROW < PREVIOUS / 3; ROW = ROW + 1) begin : full_adders
                    logic [WIDTH-1:0] X, Y, Z;
                    assign X = level[LEVEL-1].OPERAND[3*ROW];
                    assign Y = level[LEVEL-1].OPERAND[3*ROW+1];
                    assign Z = level[LEVEL-1].OPERAND[3*ROW+2];
                    assign OPERAND[2*ROW] = X ^ Y ^ Z; // sum bit of every column
                    assign OPERAND[2*ROW+1] = {((X[WIDTH-2:0] & Y[WIDTH-2:0]) | (X[WIDTH-2:0] & Z[WIDTH-2:0]) | (Y[WIDTH-2:0] & Z[WIDTH-2:0])), 1'b0}; // carry, one column left
                end
                for (ROW = 0; ROW < PREVIOUS % 3; ROW = ROW + 1) begin : pass_through
                    assign OPERAND[2*(PREVIOUS/3)+ROW] = level[LEVEL-1].OPERAND[3*(PREVIOUS/3)+ROW];
                end
            end
        end
    endgenerate

    assign SUM_VECTOR = level[LEVELS].OPERAND[0];
    assign CARRY_VECTOR = level[LEVELS].OPERAND[1];
`endif

endmodule

`default_nettype wire
