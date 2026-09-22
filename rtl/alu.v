`timescale 1ns/1ps
// =============================================================================
// alu.v — the EX-stage arithmetic unit: RV64I integer ops + RV64M mul/div.
//
// is_word selects the RV64 "W" variants: operate on the low 32 bits and
// sign-extend the 32-bit result to 64 bits (addw, sllw, mulw, divw, ...).
//
// NOTE: multiply and divide are single-cycle combinational here so every
// instruction takes exactly one cycle in EX. Real cores use multi-cycle
// dividers; see docs/EXPERIMENTS.md for how you would add a stall for it.
// =============================================================================
`include "rv64_defines.vh"

module alu (
    input  wire [4:0]  op,
    input  wire        is_word,
    input  wire [63:0] a,
    input  wire [63:0] b,
    output reg  [63:0] y
);
    // ---------------- 64-bit results ----------------------------------------
    wire [5:0]   sh   = b[5:0];
    wire [63:0]  add  = a + b;
    wire [63:0]  sub  = a - b;
    wire         a_neg = a[63], b_neg = b[63];

    // one 128-bit multiplier serves mul, mulh, mulhsu, mulhu:
    // extend each operand (sign or zero) to 128 bits, multiply modulo 2^128.
    wire         sa = (op == `ALU_MULH) || (op == `ALU_MULHSU);
    wire         sb = (op == `ALU_MULH);
    wire [127:0] ea = {{64{sa & a_neg}}, a};
    wire [127:0] eb = {{64{sb & b_neg}}, b};
    wire [127:0] prod = ea * eb;

    // signed division via magnitudes (avoids simulator-dependent signed '/')
    wire [63:0]  a_mag = a_neg ? -a : a;
    wire [63:0]  b_mag = b_neg ? -b : b;
    wire [63:0]  q_mag = (b == 64'd0) ? 64'd0 : a_mag / b_mag;
    wire [63:0]  r_mag = (b == 64'd0) ? 64'd0 : a_mag % b_mag;
    wire         ovf64 = (a == 64'h8000_0000_0000_0000) && (b == 64'hFFFF_FFFF_FFFF_FFFF);
    wire [63:0]  div_s = (b == 64'd0) ? 64'hFFFF_FFFF_FFFF_FFFF : ovf64 ? a :
                         ((a_neg ^ b_neg) ? -q_mag : q_mag);
    wire [63:0]  rem_s = (b == 64'd0) ? a : ovf64 ? 64'd0 : (a_neg ? -r_mag : r_mag);
    wire [63:0]  div_u = (b == 64'd0) ? 64'hFFFF_FFFF_FFFF_FFFF : a / b;
    wire [63:0]  rem_u = (b == 64'd0) ? a : a % b;

    // ---------------- 32-bit ("W") results ----------------------------------
    wire [31:0]  a32 = a[31:0], b32 = b[31:0];
    wire [4:0]   sh5 = b[4:0];
    wire         a32n = a32[31], b32n = b32[31];
    wire [31:0]  a32m = a32n ? -a32 : a32;
    wire [31:0]  b32m = b32n ? -b32 : b32;
    wire [31:0]  q32m = (b32 == 32'd0) ? 32'd0 : a32m / b32m;
    wire [31:0]  r32m = (b32 == 32'd0) ? 32'd0 : a32m % b32m;
    wire         ovf32 = (a32 == 32'h8000_0000) && (b32 == 32'hFFFF_FFFF);
    wire [31:0]  divw  = (b32 == 32'd0) ? 32'hFFFF_FFFF : ovf32 ? a32 : ((a32n ^ b32n) ? -q32m : q32m);
    wire [31:0]  remw  = (b32 == 32'd0) ? a32 : ovf32 ? 32'd0 : (a32n ? -r32m : r32m);
    wire [31:0]  divuw = (b32 == 32'd0) ? 32'hFFFF_FFFF : a32 / b32;
    wire [31:0]  remuw = (b32 == 32'd0) ? a32 : a32 % b32;
    wire [31:0]  sra32 = $signed(a32) >>> sh5;
    wire [63:0]  sra64 = $signed(a) >>> sh;

    reg  [31:0]  w;
    always @* begin
        // 32-bit word result (only used when is_word)
        case (op)
        `ALU_SUB:  w = sub[31:0];
        `ALU_SLL:  w = a32 << sh5;
        `ALU_SRL:  w = a32 >> sh5;
        `ALU_SRA:  w = sra32;
        `ALU_MUL:  w = prod[31:0];
        `ALU_DIV:  w = divw;
        `ALU_DIVU: w = divuw;
        `ALU_REM:  w = remw;
        `ALU_REMU: w = remuw;
        default:   w = add[31:0];
        endcase

        if (is_word) y = {{32{w[31]}}, w};
        else case (op)
        `ALU_ADD:    y = add;
        `ALU_SUB:    y = sub;
        `ALU_SLL:    y = a << sh;
        `ALU_SLT:    y = {63'd0, ($signed(a) < $signed(b))};
        `ALU_SLTU:   y = {63'd0, (a < b)};
        `ALU_XOR:    y = a ^ b;
        `ALU_SRL:    y = a >> sh;
        `ALU_SRA:    y = sra64;
        `ALU_OR:     y = a | b;
        `ALU_AND:    y = a & b;
        `ALU_MUL:    y = prod[63:0];
        `ALU_MULH, `ALU_MULHSU, `ALU_MULHU: y = prod[127:64];
        `ALU_DIV:    y = div_s;
        `ALU_DIVU:   y = div_u;
        `ALU_REM:    y = rem_s;
        `ALU_REMU:   y = rem_u;
        default:     y = add;
        endcase
    end
endmodule
