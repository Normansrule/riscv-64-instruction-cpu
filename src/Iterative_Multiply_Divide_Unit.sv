`default_nettype none

import alu_op_pkg::*;

// =====================================================================================================
// Iterative Multiply Divide Unit: the M extension in several short clock cycles instead of one huge one.
//
// A single-cycle 64-bit divider is 64 subtract-and-compare steps in a row: it alone would limit the
// whole CPU to a few tens of MHz. This unit does ONE small step per clock and holds the instruction
// in EXECUTE until it is done (MULTIPLY_DIVIDE_STALL in src/Riscv64.sv):
//
//   cycle 1          IDLE    : capture the operation and the operands' magnitudes
//   cycle 2          PREPARE : skip the dividend's leading zeros
//   cycles 3..N+2    BUSY    : multiply: 4 steps of 64 x 16 bits    (N = 4)
//                              divide:   1 quotient bit per step     (N = significant bits of the dividend)
//   cycle N+3        DONE    : apply signs and the RISC-V special cases, READY = 1, the instruction moves on
// (IDLE and PREPARE are separate clock cycles so no single cycle has to decode, negate AND normalize.)
//
// Dividing a small number (like 1234 / 10 when printing decimals) needs only ~11 bits, so it takes
// ~14 cycles instead of 67. model/core.js uses exactly the same N.
// =====================================================================================================
module IterativeMultiplyDivideUnit (
    input  logic clk,
    input  logic reset,
    input  logic FREEZE, // The core is halting: change nothing
    input  logic REQUEST, // An M instruction is in EXECUTE
    input  logic [63:0] A, // rs1
    input  logic [63:0] B, // rs2
    input  alu_op_t MULTIPLY_DIVIDE_OPERATION,
    input  logic IS_WORD_OPERATION, // MULW, DIVW, DIVUW, REMW, REMUW
    output logic READY, // The result is valid this cycle: the instruction may leave EXECUTE
    output logic [63:0] MULTIPLY_DIVIDE_RESULT
);

    typedef enum logic [1:0] { STATE_IDLE = 2'd0, STATE_PREPARE = 2'd3, STATE_BUSY = 2'd1, STATE_DONE = 2'd2 } unit_state_t;
    unit_state_t UNIT_STATE;

    // ---------------------------------------------------------------- decode the operation
    logic IS_DIVIDE; // DIV DIVU REM REMU (and the W forms)
    logic IS_REMAINDER; // REM REMU: the result is the remainder
    logic A_IS_SIGNED; // Treat A as a two's complement number
    logic B_IS_SIGNED; // Treat B as a two's complement number
    assign IS_DIVIDE = (MULTIPLY_DIVIDE_OPERATION == ALU_DIV) || (MULTIPLY_DIVIDE_OPERATION == ALU_DIVU) || (MULTIPLY_DIVIDE_OPERATION == ALU_REM) || (MULTIPLY_DIVIDE_OPERATION == ALU_REMU);
    assign IS_REMAINDER = (MULTIPLY_DIVIDE_OPERATION == ALU_REM) || (MULTIPLY_DIVIDE_OPERATION == ALU_REMU);
    assign A_IS_SIGNED = (MULTIPLY_DIVIDE_OPERATION == ALU_MULH) || (MULTIPLY_DIVIDE_OPERATION == ALU_MULHSU) || (MULTIPLY_DIVIDE_OPERATION == ALU_DIV) || (MULTIPLY_DIVIDE_OPERATION == ALU_REM);
    assign B_IS_SIGNED = (MULTIPLY_DIVIDE_OPERATION == ALU_MULH) || (MULTIPLY_DIVIDE_OPERATION == ALU_DIV) || (MULTIPLY_DIVIDE_OPERATION == ALU_REM);

    // Word division works on the 32-bit values extended to 64 bits: the 64-bit algorithm then gives the
    // exact RV64 W results (including MIN / -1 and divide by zero) once the low 32 bits are sign extended.
    logic [63:0] A_EFFECTIVE;
    logic [63:0] B_EFFECTIVE;
    assign A_EFFECTIVE = (IS_WORD_OPERATION && IS_DIVIDE) ? (A_IS_SIGNED ? {{32{A[31]}}, A[31:0]} : {32'd0, A[31:0]}) : A;
    assign B_EFFECTIVE = (IS_WORD_OPERATION && IS_DIVIDE) ? (B_IS_SIGNED ? {{32{B[31]}}, B[31:0]} : {32'd0, B[31:0]}) : B;

    logic A_IS_NEGATIVE; // decided in IDLE from the incoming operands
    logic B_IS_NEGATIVE;
    assign A_IS_NEGATIVE = A_IS_SIGNED && A_EFFECTIVE[63];
    assign B_IS_NEGATIVE = B_IS_SIGNED && B_EFFECTIVE[63];

    // Captured in IDLE, used in PREPARE
    logic [63:0] LATCHED_A, LATCHED_B; // magnitudes of the extended operands
    logic LATCHED_A_IS_NEGATIVE, LATCHED_B_IS_NEGATIVE;
    logic [63:0] A_MAGNITUDE; // |A| (as an unsigned 64-bit number: |MIN| = 2^63 fits)
    logic [63:0] B_MAGNITUDE;
    // Negation is ~x + 1: an increment whose carry would ripple through 64 bits, so it uses a prefix negate (src/Prefix_Negate.sv)
    logic [63:0] A_NEGATED, B_NEGATED;
    // Magnitudes are taken in the IDLE cycle and latched, so PREPARE only has to normalize
    PrefixNegate #(.WIDTH(64)) negate_a (.X (A_EFFECTIVE), .NEGATED (A_NEGATED));
    PrefixNegate #(.WIDTH(64)) negate_b (.X (B_EFFECTIVE), .NEGATED (B_NEGATED));
    assign A_MAGNITUDE = LATCHED_A; // already |A|
    assign B_MAGNITUDE = LATCHED_B; // already |B|

    // Skip the dividend's leading zeros: normalize by halves (6 steps of "is the top half-width zero? then shift"),
    // which counts the leading zeros AND left-aligns |A| at once. log2(64) = 6 levels instead of a 64-step search.
    logic [6:0] DIVIDE_STEPS; // significant bits of |A| (1 for zero)
    logic [63:0] ALIGNED_DIVIDEND; // |A| << leading zeros
    always_comb begin
        logic [63:0] NORMALIZED;
        logic [5:0] LEADING_ZEROS;
        NORMALIZED = A_MAGNITUDE;
        LEADING_ZEROS = 6'd0;
        if (NORMALIZED[63:32] == 32'd0) begin NORMALIZED = NORMALIZED << 32; LEADING_ZEROS[5] = 1'b1; end
        if (NORMALIZED[63:48] == 16'd0) begin NORMALIZED = NORMALIZED << 16; LEADING_ZEROS[4] = 1'b1; end
        if (NORMALIZED[63:56] == 8'd0)  begin NORMALIZED = NORMALIZED << 8;  LEADING_ZEROS[3] = 1'b1; end
        if (NORMALIZED[63:60] == 4'd0)  begin NORMALIZED = NORMALIZED << 4;  LEADING_ZEROS[2] = 1'b1; end
        if (NORMALIZED[63:62] == 2'd0)  begin NORMALIZED = NORMALIZED << 2;  LEADING_ZEROS[1] = 1'b1; end
        if (NORMALIZED[63] == 1'b0)     begin NORMALIZED = NORMALIZED << 1;  LEADING_ZEROS[0] = 1'b1; end
        ALIGNED_DIVIDEND = NORMALIZED;
        DIVIDE_STEPS = 7'd64 - {1'b0, LEADING_ZEROS}; // |A| = 0 gives 63 leading zeros here -> 1 step, as intended
    end

    // ---------------------------------------------------------------- iteration registers
    logic [6:0] STEPS_LEFT;
    logic LATCHED_IS_DIVIDE, LATCHED_IS_REMAINDER, LATCHED_IS_WORD, LATCHED_NEGATE_PRODUCT, LATCHED_NEGATE_QUOTIENT, LATCHED_NEGATE_REMAINDER, LATCHED_DIVIDE_BY_ZERO;
    alu_op_t LATCHED_OPERATION;
    logic [63:0] MULTIPLICAND; // |A| for multiplication
    logic [127:0] PRODUCT; // {running high part, multiplier bits not used yet}: shifts right 16 bits per step
    logic [63:0] DIVISOR; // |B|
    logic [63:0] DIVIDEND_BITS; // |A| left-aligned: the next dividend bit is always bit 63
    logic [63:0] PARTIAL_REMAINDER;
    logic [63:0] QUOTIENT;

    // One multiply step: add |A| x (next 16 multiplier bits) to the high part
    logic [79:0] MULTIPLY_STEP_SUM;
    assign MULTIPLY_STEP_SUM = {16'd0, PRODUCT[127:64]} + (MULTIPLICAND * PRODUCT[15:0]);

    // One divide step: bring down the next dividend bit, try to subtract the divisor (65-bit prefix subtractor)
    logic [64:0] SHIFTED_REMAINDER;
    logic [64:0] TRIAL_DIFFERENCE;
    logic TRIAL_NO_BORROW; // 1 means SHIFTED_REMAINDER >= DIVISOR: the quotient bit is 1
    assign SHIFTED_REMAINDER = {PARTIAL_REMAINDER, DIVIDEND_BITS[63]};
    ParallelPrefixAdder #(.WIDTH(65)) divide_subtractor (
        .A (SHIFTED_REMAINDER),
        .B (~{1'b0, DIVISOR}),
        .CARRY_IN (1'b1),
        .SUM (TRIAL_DIFFERENCE),
        .CARRY_OUT (TRIAL_NO_BORROW)
    );

    always_ff @(posedge clk) begin
        if (reset) begin
            UNIT_STATE <= STATE_IDLE;
            STEPS_LEFT <= 7'd0;
        end else if (!FREEZE) begin
            unique case (UNIT_STATE)
                STATE_IDLE: if (REQUEST) begin // Capture the operands
                    UNIT_STATE <= STATE_PREPARE;
                    LATCHED_A <= A_IS_NEGATIVE ? A_NEGATED : A_EFFECTIVE; // |A|
                    LATCHED_B <= B_IS_NEGATIVE ? B_NEGATED : B_EFFECTIVE; // |B|
                    LATCHED_A_IS_NEGATIVE <= A_IS_NEGATIVE;
                    LATCHED_B_IS_NEGATIVE <= B_IS_NEGATIVE;
                    LATCHED_OPERATION <= MULTIPLY_DIVIDE_OPERATION;
                    LATCHED_IS_DIVIDE <= IS_DIVIDE;
                    LATCHED_IS_REMAINDER <= IS_REMAINDER;
                    LATCHED_IS_WORD <= IS_WORD_OPERATION;
                    LATCHED_NEGATE_PRODUCT <= A_IS_NEGATIVE ^ B_IS_NEGATIVE;
                    LATCHED_NEGATE_QUOTIENT <= A_IS_NEGATIVE ^ B_IS_NEGATIVE;
                    LATCHED_NEGATE_REMAINDER <= A_IS_NEGATIVE;
                    LATCHED_DIVIDE_BY_ZERO <= (B_EFFECTIVE == 64'd0);
                end
                STATE_PREPARE: begin // Magnitudes and the aligned dividend
                    UNIT_STATE <= STATE_BUSY;
                    MULTIPLICAND <= A_MAGNITUDE;
                    PRODUCT <= {64'd0, B_MAGNITUDE};
                    DIVISOR <= B_MAGNITUDE;
                    DIVIDEND_BITS <= ALIGNED_DIVIDEND;
                    PARTIAL_REMAINDER <= 64'd0;
                    QUOTIENT <= 64'd0;
                    STEPS_LEFT <= LATCHED_IS_DIVIDE ? DIVIDE_STEPS : 7'd4;
                end
                STATE_BUSY: begin // One step
                    if (LATCHED_IS_DIVIDE) begin
                        PARTIAL_REMAINDER <= TRIAL_NO_BORROW ? TRIAL_DIFFERENCE[63:0] : SHIFTED_REMAINDER[63:0];
                        QUOTIENT <= {QUOTIENT[62:0], TRIAL_NO_BORROW};
                        DIVIDEND_BITS <= {DIVIDEND_BITS[62:0], 1'b0};
                    end else begin
                        PRODUCT <= {MULTIPLY_STEP_SUM, PRODUCT[63:16]};
                    end
                    STEPS_LEFT <= STEPS_LEFT - 7'd1;
                    if (STEPS_LEFT == 7'd1) UNIT_STATE <= STATE_DONE;
                end
                STATE_DONE: UNIT_STATE <= STATE_IDLE; // The instruction leaves EXECUTE at this edge
                default: UNIT_STATE <= STATE_IDLE;
            endcase
        end
    end

    // ---------------------------------------------------------------- DONE: signs and special cases
    logic [127:0] SIGNED_PRODUCT;
    logic [63:0] SIGNED_QUOTIENT;
    logic [63:0] SIGNED_REMAINDER;
    logic [63:0] FULL_RESULT;
    logic [127:0] PRODUCT_NEGATED;
    logic [63:0] QUOTIENT_NEGATED, REMAINDER_NEGATED;
    PrefixNegate #(.WIDTH(128)) negate_product (.X (PRODUCT), .NEGATED (PRODUCT_NEGATED));
    PrefixNegate #(.WIDTH(64)) negate_quotient (.X (QUOTIENT), .NEGATED (QUOTIENT_NEGATED));
    PrefixNegate #(.WIDTH(64)) negate_remainder (.X (PARTIAL_REMAINDER), .NEGATED (REMAINDER_NEGATED));
    assign SIGNED_PRODUCT = LATCHED_NEGATE_PRODUCT ? PRODUCT_NEGATED : PRODUCT;
    assign SIGNED_QUOTIENT = LATCHED_NEGATE_QUOTIENT ? QUOTIENT_NEGATED : QUOTIENT;
    assign SIGNED_REMAINDER = LATCHED_NEGATE_REMAINDER ? REMAINDER_NEGATED : PARTIAL_REMAINDER; // remainder takes the dividend's sign; x % 0 = x falls out naturally

    always_comb begin
        if (LATCHED_IS_DIVIDE) begin
            if (LATCHED_IS_REMAINDER) FULL_RESULT = SIGNED_REMAINDER;
            else FULL_RESULT = LATCHED_DIVIDE_BY_ZERO ? 64'hFFFF_FFFF_FFFF_FFFF : SIGNED_QUOTIENT; // x / 0 = all ones
        end else begin
            unique case (LATCHED_OPERATION)
                ALU_MULH, ALU_MULHSU, ALU_MULHU: FULL_RESULT = SIGNED_PRODUCT[127:64];
                default: FULL_RESULT = SIGNED_PRODUCT[63:0]; // MUL, MULW
            endcase
        end
        MULTIPLY_DIVIDE_RESULT = LATCHED_IS_WORD ? {{32{FULL_RESULT[31]}}, FULL_RESULT[31:0]} : FULL_RESULT;
    end

    assign READY = (UNIT_STATE == STATE_DONE);

endmodule

`default_nettype wire
