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
//   cycle 2          PREPARE : count the dividend's leading zeros
//  (divide only)     ALIGN   : shift them away, so the loop only visits significant bits
//   then N cycles    BUSY    : multiply: 4 steps of 64 x 16 bits    (N = 4), carry-save (src/Carry_Save_Multiplier.sv)
//                              divide:   1 quotient bit per step     (N = significant bits of the dividend)
//   then             SIGN    : add the carry-save pair, apply signs and the RISC-V special cases into RESULT_REGISTER
//   then             DONE    : READY = 1, the registered result leaves with the instruction
//   multiply: 8 cycles in EXECUTE.  divide: 5 + significant bits of the dividend.
// (IDLE and PREPARE are separate clock cycles so no single cycle has to decode, negate AND normalize;
//  SIGN is its own cycle so a 128-bit negation never sits in front of the forwarding multiplexers.)
//
// Dividing a small number (like 1234 / 10 when printing decimals) needs only ~11 bits, so it takes
// ~16 cycles instead of 69. model/core.js uses exactly the same N.
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
    input  logic [2:0] PREDECODED, // {A signed, B signed, word divide}: decoded in DECODE, so IDLE starts from flip-flops
    output logic READY, // The result is valid this cycle: the instruction may leave EXECUTE
    output logic [63:0] MULTIPLY_DIVIDE_RESULT
);

    typedef enum logic [2:0] { STATE_IDLE = 3'd0, STATE_PREPARE = 3'd3, STATE_BUSY = 3'd1, STATE_ALIGN = 3'd5, STATE_SIGN = 3'd4, STATE_DONE = 3'd2 } unit_state_t;
    unit_state_t UNIT_STATE;

    // ---------------------------------------------------------------- decode the operation
    logic IS_DIVIDE; // DIV DIVU REM REMU (and the W forms)
    logic IS_REMAINDER; // REM REMU: the result is the remainder
    logic A_IS_SIGNED; // Treat A as a two's complement number
    logic B_IS_SIGNED; // Treat B as a two's complement number
    assign IS_DIVIDE = (MULTIPLY_DIVIDE_OPERATION == ALU_DIV) || (MULTIPLY_DIVIDE_OPERATION == ALU_DIVU) || (MULTIPLY_DIVIDE_OPERATION == ALU_REM) || (MULTIPLY_DIVIDE_OPERATION == ALU_REMU);
    assign IS_REMAINDER = (MULTIPLY_DIVIDE_OPERATION == ALU_REM) || (MULTIPLY_DIVIDE_OPERATION == ALU_REMU);
    assign A_IS_SIGNED = PREDECODED[2]; // MULH, MULHSU, DIV, REM (decoded into EXECUTE_MULTIPLY_DIVIDE_PREDECODED in src/Riscv64.sv)
    assign B_IS_SIGNED = PREDECODED[1]; // MULH, DIV, REM

    // Word division works on the 32-bit values extended to 64 bits: the 64-bit algorithm then gives the
    // exact RV64 W results (including MIN / -1 and divide by zero) once the low 32 bits are sign extended.
    logic [63:0] A_EFFECTIVE;
    logic [63:0] B_EFFECTIVE;
    assign A_EFFECTIVE = PREDECODED[0] ? (A_IS_SIGNED ? {{32{A[31]}}, A[31:0]} : {32'd0, A[31:0]}) : A; // PREDECODED[0]: word divide
    assign B_EFFECTIVE = PREDECODED[0] ? (B_IS_SIGNED ? {{32{B[31]}}, B[31:0]} : {32'd0, B[31:0]}) : B;

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

    // Skip the dividend's leading zeros. Counting them one "is the top half zero? then shift" at a time
    // chains six zero-tests, each waiting for the previous shift (599 ps at 7 nm). Instead a tree counts
    // them (a leading-zero counter): pair up neighbouring blocks, level by level,
    //   block all zero = upper all zero AND lower all zero
    //   block count    = upper all zero ? {1, lower count} : {0, upper count}
    // 64 one-bit blocks -> 32 two-bit blocks -> ... -> 1 block of 64: six levels of one small mux each.
    logic [6:0] DIVIDE_STEPS; // significant bits of |A| (1 for zero)
    logic [63:0] ALIGNED_DIVIDEND; // |A| << leading zeros
    logic [5:0] LEADING_ZEROS;
    logic DIVIDEND_IS_ZERO_UNUSED; // |A| = 0 counts 63 (the last bit is never counted): 1 step, as the loop expects
    LeadingZeroCounter count_dividend_zeros (.X (A_MAGNITUDE), .COUNT (LEADING_ZEROS), .ALL_ZERO (DIVIDEND_IS_ZERO_UNUSED));

    // The shift itself happens one cycle later (ALIGN), from the registered count: counting AND shifting
    // in the same cycle made this the longest path of the unit.
    logic [5:0] LATCHED_LEADING_ZEROS;
    assign DIVIDE_STEPS = 7'd64 - {1'b0, LATCHED_LEADING_ZEROS}; // |A| = 0 gives 63 leading zeros here -> 1 step, as intended
    always_comb begin
        logic [63:0] NORMALIZED;
        NORMALIZED = A_MAGNITUDE;
        if (LATCHED_LEADING_ZEROS[5]) NORMALIZED = NORMALIZED << 32;
        if (LATCHED_LEADING_ZEROS[4]) NORMALIZED = NORMALIZED << 16;
        if (LATCHED_LEADING_ZEROS[3]) NORMALIZED = NORMALIZED << 8;
        if (LATCHED_LEADING_ZEROS[2]) NORMALIZED = NORMALIZED << 4;
        if (LATCHED_LEADING_ZEROS[1]) NORMALIZED = NORMALIZED << 2;
        if (LATCHED_LEADING_ZEROS[0]) NORMALIZED = NORMALIZED << 1;
        ALIGNED_DIVIDEND = NORMALIZED;
    end

    // ---------------------------------------------------------------- iteration registers
    logic [6:0] STEPS_LEFT;
    logic LATCHED_IS_DIVIDE, LATCHED_IS_REMAINDER, LATCHED_IS_WORD, LATCHED_NEGATE_PRODUCT, LATCHED_NEGATE_QUOTIENT, LATCHED_NEGATE_REMAINDER, LATCHED_DIVIDE_BY_ZERO;
    alu_op_t LATCHED_OPERATION;
    logic [63:0] MULTIPLICAND; // |A| for multiplication
    // The product is kept in carry-save form: two numbers whose SUM is the product so far.
    // {running high part (70 bits), finished low bits / multiplier bits not used yet (64)}: shifts right 16 bits per step
    logic [133:0] PRODUCT_SUM;
    logic [133:0] PRODUCT_CARRY;
    logic [63:0] DIVISOR; // |B|
    logic [63:0] DIVIDEND_BITS; // |A| left-aligned: the next dividend bit is always bit 63
    logic [63:0] PARTIAL_REMAINDER;
    logic [63:0] QUOTIENT;
    logic [63:0] RESULT_REGISTER; // written in SIGN, read in DONE

    // One multiply step: add |A| x (next 16 multiplier bits) to the high part, without resolving any carry
    logic [85:0] MULTIPLY_STEP_SUM, MULTIPLY_STEP_CARRY;
    CarrySaveMultiplyStep #(.A_WIDTH(64), .B_WIDTH(16), .WIDTH(86), .ACCUMULATOR_WIDTH(70)) multiply_step ( // a Wallace tree, not 16 rows of ripple adders
        .MULTIPLICAND (MULTIPLICAND), .MULTIPLIER (PRODUCT_SUM[15:0]),
        .ACCUMULATOR_SUM (PRODUCT_SUM[133:64]), .ACCUMULATOR_CARRY (PRODUCT_CARRY[133:64]),
        .SUM_VECTOR (MULTIPLY_STEP_SUM), .CARRY_VECTOR (MULTIPLY_STEP_CARRY)
    );

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
            RESULT_REGISTER <= 64'd0;
            LATCHED_LEADING_ZEROS <= 6'd0;
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
                STATE_PREPARE: begin // Magnitudes; count the dividend's leading zeros
                    UNIT_STATE <= LATCHED_IS_DIVIDE ? STATE_ALIGN : STATE_BUSY;
                    LATCHED_LEADING_ZEROS <= LEADING_ZEROS;
                    MULTIPLICAND <= A_MAGNITUDE;
                    PRODUCT_SUM <= {70'd0, B_MAGNITUDE};
                    PRODUCT_CARRY <= 134'd0;
                    DIVISOR <= B_MAGNITUDE;
                    PARTIAL_REMAINDER <= 64'd0;
                    QUOTIENT <= 64'd0;
                    STEPS_LEFT <= 7'd4; // a divide sets its own count in ALIGN
                end
                STATE_ALIGN: begin // Divide only: left-align the dividend by the counted leading zeros
                    UNIT_STATE <= STATE_BUSY;
                    DIVIDEND_BITS <= ALIGNED_DIVIDEND;
                    STEPS_LEFT <= DIVIDE_STEPS;
                end
                STATE_BUSY: begin // One step
                    if (LATCHED_IS_DIVIDE) begin
                        PARTIAL_REMAINDER <= TRIAL_NO_BORROW ? TRIAL_DIFFERENCE[63:0] : SHIFTED_REMAINDER[63:0];
                        QUOTIENT <= {QUOTIENT[62:0], TRIAL_NO_BORROW};
                        DIVIDEND_BITS <= {DIVIDEND_BITS[62:0], 1'b0};
                    end else begin
                        PRODUCT_SUM <= {MULTIPLY_STEP_SUM, PRODUCT_SUM[63:16]};
                        PRODUCT_CARRY <= {MULTIPLY_STEP_CARRY, PRODUCT_CARRY[63:16]};
                    end
                    STEPS_LEFT <= STEPS_LEFT - 7'd1;
                    if (STEPS_LEFT == 7'd1) UNIT_STATE <= STATE_SIGN;
                end
                STATE_SIGN: begin // Register the finished result (signs applied)
                    RESULT_REGISTER <= FINISHED_RESULT;
                    UNIT_STATE <= STATE_DONE;
                end
                STATE_DONE: UNIT_STATE <= STATE_IDLE; // The instruction leaves EXECUTE at this edge
                default: UNIT_STATE <= STATE_IDLE;
            endcase
        end
    end

    // ---------------------------------------------------------------- SIGN: signs and special cases
    logic [127:0] SIGNED_PRODUCT;
    logic [63:0] SIGNED_QUOTIENT;
    logic [63:0] SIGNED_REMAINDER;
    logic [63:0] FULL_RESULT;
    logic [63:0] FINISHED_RESULT;
    logic [63:0] QUOTIENT_NEGATED, REMAINDER_NEGATED;
    // The product: add the carry-save pair AND negate if needed, with ONE 128-bit prefix adder.
    //   -(X + Y) = ~(X + Y - 1): add all ones (= -1) as a third number through one row of full adders,
    //   add, then invert. With NEGATE = 0 the third number is 0 and nothing is inverted.
    logic [127:0] PRODUCT_X, PRODUCT_Y, PRODUCT_Z, RESOLVE_SUM_BITS, RESOLVE_CARRY_BITS, RESOLVED_PRODUCT;
    logic RESOLVE_CARRY_UNUSED;
    assign PRODUCT_X = PRODUCT_SUM[127:0]; // bits above 127 cancel: the product is below 2^128
    assign PRODUCT_Y = PRODUCT_CARRY[127:0];
    assign PRODUCT_Z = {128{LATCHED_NEGATE_PRODUCT}};
    assign RESOLVE_SUM_BITS = PRODUCT_X ^ PRODUCT_Y ^ PRODUCT_Z;
    assign RESOLVE_CARRY_BITS = {((PRODUCT_X[126:0] & PRODUCT_Y[126:0]) | (PRODUCT_X[126:0] & PRODUCT_Z[126:0]) | (PRODUCT_Y[126:0] & PRODUCT_Z[126:0])), 1'b0};
    ParallelPrefixAdder #(.WIDTH(128)) resolve_product (
        .A (RESOLVE_SUM_BITS), .B (RESOLVE_CARRY_BITS), .CARRY_IN (1'b0), .SUM (RESOLVED_PRODUCT), .CARRY_OUT (RESOLVE_CARRY_UNUSED)
    );
    PrefixNegate #(.WIDTH(64)) negate_quotient (.X (QUOTIENT), .NEGATED (QUOTIENT_NEGATED));
    PrefixNegate #(.WIDTH(64)) negate_remainder (.X (PARTIAL_REMAINDER), .NEGATED (REMAINDER_NEGATED));
    assign SIGNED_PRODUCT = RESOLVED_PRODUCT ^ PRODUCT_Z;
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
        FINISHED_RESULT = LATCHED_IS_WORD ? {{32{FULL_RESULT[31]}}, FULL_RESULT[31:0]} : FULL_RESULT;
    end
    assign MULTIPLY_DIVIDE_RESULT = RESULT_REGISTER; // straight from a register: nothing in front of forwarding

    assign READY = (UNIT_STATE == STATE_DONE);

endmodule

`default_nettype wire
