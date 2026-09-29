`default_nettype none

// =====================================================================================================
// Population Count (cpop, cpopw): the number of 1 bits, split across two pipeline stages.
//
//   EXECUTE  (PopulationCount)        16 nibble counts, each a 4-input function (0..4), then four
//                                     4-operand sums, one per 16-bit quarter (0..16 each, 5 bits)
//   MEMORY   (PopulationCountFinish)  cpop : quarter 0 + 1 + 2 + 3  (0..64)
//                                     cpopw: quarter 0 + 1          (0..32)
//
// cpop is a "late" instruction anyway (its result is forwarded from MEMORY, like a load's), so its
// last addition can happen in MEMORY for free: the four quarter counts travel in the low 20 bits of the
// EXECUTE result register, and MEMORY adds them next to LoadControl's byte selection, which is slower.
// Without the split, the whole 64-bit count had to fit in EXECUTE's cycle and was the longest path of
// the 130 nm build. A four-bit lookup replaces two levels of tiny adders, and a multi-operand sum lets
// synthesis build a carry-save tree with a single carry-propagating add.
// =====================================================================================================
module PopulationCount (
    input  logic [63:0] X,
    output logic [19:0] QUARTER_COUNTS  // {ones in X[63:48], X[47:32], X[31:16], X[15:0]}, 5 bits each
);

    // Ones in one nibble (0..4). Written as equations, not a case table, so synthesis never makes a ROM
    // of it (which it could retime into the operand register):
    //   bit 0 = an odd number of ones, bit 1 = two or three ones, bit 2 = all four
    function automatic logic [2:0] nibble_count(input logic [3:0] n);
        logic at_least_two;
        at_least_two = (n[0] & n[1]) | (n[0] & n[2]) | (n[0] & n[3]) | (n[1] & n[2]) | (n[1] & n[3]) | (n[2] & n[3]);
        nibble_count = {&n, at_least_two & ~(&n), ^n};
    endfunction

    always_comb begin
        for (int quarter = 0; quarter < 4; quarter++) begin
            QUARTER_COUNTS[5*quarter +: 5] = 5'd0;
            for (int nibble = 0; nibble < 4; nibble++)
                QUARTER_COUNTS[5*quarter +: 5] = QUARTER_COUNTS[5*quarter +: 5] + {2'd0, nibble_count(X[16*quarter + 4*nibble +: 4])};
        end
    end

endmodule

module PopulationCountFinish (
    input  logic [19:0] QUARTER_COUNTS,
    input  logic        WORD,           // cpopw: only the low 32 bits count
    output logic [6:0]  COUNT
);
    logic [5:0] LOW_HALF, HIGH_HALF;
    assign LOW_HALF = {1'b0, QUARTER_COUNTS[4:0]} + {1'b0, QUARTER_COUNTS[9:5]};
    assign HIGH_HALF = WORD ? 6'd0 : {1'b0, QUARTER_COUNTS[14:10]} + {1'b0, QUARTER_COUNTS[19:15]};
    assign COUNT = {1'b0, LOW_HALF} + {1'b0, HIGH_HALF};
endmodule

`default_nettype wire
