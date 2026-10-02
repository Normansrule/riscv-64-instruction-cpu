`default_nettype none

// =====================================================================================================
// SevenSegmentDisplay: drives a 4-digit, common-anode, multiplexed seven-segment display (the Basys 3 has
// one). The CPU writes the DISPLAY device register (0x1000_0070) with the raw segments of each digit:
//
//   DISPLAY[ 7: 0]  digit 0 (rightmost)     bit 0 = segment a (top), 1 = b, 2 = c, 3 = d (bottom),
//   DISPLAY[15: 8]  digit 1                 4 = e, 5 = f, 6 = g (middle), 7 = the decimal point
//   DISPLAY[23:16]  digit 2                       a
//   DISPLAY[31:24]  digit 3 (leftmost)          f   b       a 1 lights a segment
//                                                 g
//                                               e   c
//                                                 d   .dp
//
// The four digits share their eight segment wires; only one digit's anode is on at a time, switched
// about every 1 ms (CLOCK_HZ / 1000 cycles), so all four look lit at once. The board's segment and
// anode lines are active low (0 = on), as on the Basys 3.
// The digits are the CPU's job: software turns a number into segments (fpga/examples/calculator.s).
// =====================================================================================================
module SevenSegmentDisplay #(
    parameter int CLOCK_HZ = 25_000_000
) (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] SEGMENTS,       // the DISPLAY register
    output logic [6:0]  SEGMENT_N,      // a..g, active low
    output logic        DECIMAL_POINT_N, // active low
    output logic [3:0]  ANODE_N         // digit select, active low
);
    localparam int CYCLES_PER_DIGIT = (CLOCK_HZ / 1000 > 1) ? CLOCK_HZ / 1000 : 2;
    localparam int COUNTER_BITS = $clog2(CYCLES_PER_DIGIT);

    logic [COUNTER_BITS-1:0] COUNTER;
    logic [1:0] DIGIT;
    always_ff @(posedge clk) begin
        if (reset) begin
            COUNTER <= '0;
            DIGIT <= 2'd0;
        end else if (COUNTER == COUNTER_BITS'(CYCLES_PER_DIGIT - 1)) begin
            COUNTER <= '0;
            DIGIT <= DIGIT + 2'd1;
        end else begin
            COUNTER <= COUNTER + 1'b1;
        end
    end

    logic [7:0] PATTERN;
    assign PATTERN = SEGMENTS[8*DIGIT +: 8];
    always_ff @(posedge clk) begin // registered outputs: no glitches on the pins
        SEGMENT_N <= ~PATTERN[6:0];
        DECIMAL_POINT_N <= ~PATTERN[7];
        ANODE_N <= ~(4'b0001 << DIGIT);
    end
endmodule

`default_nettype wire
