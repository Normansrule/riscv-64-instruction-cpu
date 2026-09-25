// Multiply Divide Unit (RV64M): MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU and the Word versions
// Placed right next to the ALU in the Execute Stage. Single cycle and fully combinational so every
// instruction takes exactly one cycle in Execute (real cores use a multi-cycle divider, see docs/EXPERIMENTS.md Lab 4)
`default_nettype none

import alu_op_pkg::*;

module MultiplyDivideUnit (
    input  logic [63:0] A, // rs1
    input  logic [63:0] B, // rs2
    input  alu_op_t MULTIPLY_DIVIDE_OPERATION, // Which M extension operation to perform
    input  logic IS_WORD_OPERATION, // 1 for MULW, DIVW, DIVUW, REMW, REMUW (32-bit, sign extended result)
    output logic [63:0] MULTIPLY_DIVIDE_RESULT // Result sent to the Execute Stage result mux
);

    // One 128-bit multiplier serves MUL, MULH, MULHSU, MULHU:
    // Extend each operand (sign or zero) to 128 bits then multiply modulo 2^128
    logic A_IS_SIGNED; // MULH and MULHSU treat A as signed
    logic B_IS_SIGNED; // Only MULH treats B as signed
    logic [127:0] EXTENDED_A; // A extended to 128 bits
    logic [127:0] EXTENDED_B; // B extended to 128 bits
    logic [127:0] PRODUCT; // Full 128-bit product
    assign A_IS_SIGNED = (MULTIPLY_DIVIDE_OPERATION == ALU_MULH) || (MULTIPLY_DIVIDE_OPERATION == ALU_MULHSU);
    assign B_IS_SIGNED = (MULTIPLY_DIVIDE_OPERATION == ALU_MULH);
    assign EXTENDED_A = {{64{A_IS_SIGNED & A[63]}}, A};
    assign EXTENDED_B = {{64{B_IS_SIGNED & B[63]}}, B};
    assign PRODUCT = EXTENDED_A * EXTENDED_B;

    // 64-bit Signed Division done on magnitudes (avoids simulator dependent signed division)
    logic A_IS_NEGATIVE; // Sign of the dividend
    logic B_IS_NEGATIVE; // Sign of the divisor
    logic [63:0] A_MAGNITUDE; // |A|
    logic [63:0] B_MAGNITUDE; // |B|
    logic [63:0] QUOTIENT_MAGNITUDE; // |A| / |B|
    logic [63:0] REMAINDER_MAGNITUDE; // |A| % |B|
    logic DIVIDE_BY_ZERO; // RISC-V defines x / 0 = -1 and x % 0 = x (no trap)
    logic SIGNED_OVERFLOW; // MIN / -1 overflows: RISC-V defines the quotient as MIN and remainder as 0
    assign A_IS_NEGATIVE = A[63];
    assign B_IS_NEGATIVE = B[63];
    assign A_MAGNITUDE = A_IS_NEGATIVE ? -A : A;
    assign B_MAGNITUDE = B_IS_NEGATIVE ? -B : B;
    assign DIVIDE_BY_ZERO = (B == 64'd0);
    assign SIGNED_OVERFLOW = (A == 64'h8000_0000_0000_0000) && (B == 64'hFFFF_FFFF_FFFF_FFFF);
    assign QUOTIENT_MAGNITUDE = DIVIDE_BY_ZERO ? 64'd0 : A_MAGNITUDE / B_MAGNITUDE;
    assign REMAINDER_MAGNITUDE = DIVIDE_BY_ZERO ? 64'd0 : A_MAGNITUDE % B_MAGNITUDE;

    // 32-bit Word Division (DIVW, DIVUW, REMW, REMUW) on the low 32 bits
    logic [31:0] WORD_A; // Low 32 bits of A
    logic [31:0] WORD_B; // Low 32 bits of B
    logic WORD_A_IS_NEGATIVE; // Sign of the Word dividend
    logic WORD_B_IS_NEGATIVE; // Sign of the Word divisor
    logic [31:0] WORD_A_MAGNITUDE; // |A[31:0]|
    logic [31:0] WORD_B_MAGNITUDE; // |B[31:0]|
    logic [31:0] WORD_QUOTIENT_MAGNITUDE; // Word Quotient Magnitude
    logic [31:0] WORD_REMAINDER_MAGNITUDE; // Word Remainder Magnitude
    logic WORD_DIVIDE_BY_ZERO; // Word divide by zero
    logic WORD_SIGNED_OVERFLOW; // Word MIN / -1
    assign WORD_A = A[31:0];
    assign WORD_B = B[31:0];
    assign WORD_A_IS_NEGATIVE = WORD_A[31];
    assign WORD_B_IS_NEGATIVE = WORD_B[31];
    assign WORD_A_MAGNITUDE = WORD_A_IS_NEGATIVE ? -WORD_A : WORD_A;
    assign WORD_B_MAGNITUDE = WORD_B_IS_NEGATIVE ? -WORD_B : WORD_B;
    assign WORD_DIVIDE_BY_ZERO = (WORD_B == 32'd0);
    assign WORD_SIGNED_OVERFLOW = (WORD_A == 32'h8000_0000) && (WORD_B == 32'hFFFF_FFFF);
    assign WORD_QUOTIENT_MAGNITUDE = WORD_DIVIDE_BY_ZERO ? 32'd0 : WORD_A_MAGNITUDE / WORD_B_MAGNITUDE;
    assign WORD_REMAINDER_MAGNITUDE = WORD_DIVIDE_BY_ZERO ? 32'd0 : WORD_A_MAGNITUDE % WORD_B_MAGNITUDE;

    logic [63:0] FULL_RESULT; // 64-bit operation result
    logic [31:0] WORD_RESULT; // 32-bit Word operation result

    always_comb begin
        unique case (MULTIPLY_DIVIDE_OPERATION)
            ALU_MUL: FULL_RESULT = PRODUCT[63:0]; // Low 64 bits of the product
            ALU_MULH, ALU_MULHSU, ALU_MULHU: FULL_RESULT = PRODUCT[127:64]; // High 64 bits of the product
            ALU_DIV: FULL_RESULT = DIVIDE_BY_ZERO ? 64'hFFFF_FFFF_FFFF_FFFF : SIGNED_OVERFLOW ? A : ((A_IS_NEGATIVE ^ B_IS_NEGATIVE) ? -QUOTIENT_MAGNITUDE : QUOTIENT_MAGNITUDE); // Signed Divide (rounds toward zero)
            ALU_DIVU: FULL_RESULT = DIVIDE_BY_ZERO ? 64'hFFFF_FFFF_FFFF_FFFF : A / B; // Unsigned Divide
            ALU_REM: FULL_RESULT = DIVIDE_BY_ZERO ? A : SIGNED_OVERFLOW ? 64'd0 : (A_IS_NEGATIVE ? -REMAINDER_MAGNITUDE : REMAINDER_MAGNITUDE); // Signed Remainder takes the sign of the dividend
            ALU_REMU: FULL_RESULT = DIVIDE_BY_ZERO ? A : A % B; // Unsigned Remainder
            default: FULL_RESULT = 64'd0;
        endcase

        unique case (MULTIPLY_DIVIDE_OPERATION)
            ALU_MUL: WORD_RESULT = PRODUCT[31:0]; // MULW: low 32 bits of the product
            ALU_DIV: WORD_RESULT = WORD_DIVIDE_BY_ZERO ? 32'hFFFF_FFFF : WORD_SIGNED_OVERFLOW ? WORD_A : ((WORD_A_IS_NEGATIVE ^ WORD_B_IS_NEGATIVE) ? -WORD_QUOTIENT_MAGNITUDE : WORD_QUOTIENT_MAGNITUDE); // DIVW
            ALU_DIVU: WORD_RESULT = WORD_DIVIDE_BY_ZERO ? 32'hFFFF_FFFF : WORD_A / WORD_B; // DIVUW
            ALU_REM: WORD_RESULT = WORD_DIVIDE_BY_ZERO ? WORD_A : WORD_SIGNED_OVERFLOW ? 32'd0 : (WORD_A_IS_NEGATIVE ? -WORD_REMAINDER_MAGNITUDE : WORD_REMAINDER_MAGNITUDE); // REMW
            ALU_REMU: WORD_RESULT = WORD_DIVIDE_BY_ZERO ? WORD_A : WORD_A % WORD_B; // REMUW
            default: WORD_RESULT = 32'd0;
        endcase

        MULTIPLY_DIVIDE_RESULT = IS_WORD_OPERATION ? {{32{WORD_RESULT[31]}}, WORD_RESULT} : FULL_RESULT; // Word results are sign extended from bit 31
    end

endmodule

`default_nettype wire
