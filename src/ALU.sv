// Fullest Optimized and Parallelized ALU (RV64):
// Optimized ALU: Uses a single shared adder/subtractor for ADD, SUB, SLT, SLTU, and JALR to reduce critical path
// Performance edition: that shared adder is a Kogge-Stone parallel prefix adder (src/Parallel_Prefix_Adder.sv)
// RV64 addition: ALU_IS_WORD_OPERATION selects the 32-bit "W" variants (ADDW, SUBW, SLLW, SRLW, SRAW)
//                which compute on the low 32 bits and sign-extend the 32-bit result back to 64 bits
`default_nettype none

import opcode_pkg::*;
import alu_op_pkg::*;

module ALU (
    input  logic [63:0] A,
    input  logic [63:0] B,
    input  alu_op_t ALUop,
    input  logic SUBTRACT_MODE, // SUB, SLT, SLTU: decoded from ALUop one stage earlier (it steers all 64 adder inputs)
    input  logic ALU_IS_WORD_OPERATION, // 0 means full 64-bit operation, 1 means 32-bit Word operation (sign extended)
    output logic [63:0] ALUOut
);

    // Single Shared Adder and Subtractor, built as a Parallel Prefix (Kogge-Stone) adder:
    // A + B if SUBTRACT_MODE = 0, A - B = A + ~B + 1 if SUBTRACT_MODE = 1 (SUB, SLT, SLTU all need A - B)
    logic [63:0] ADDER_SUM;
    logic ADDER_CARRY_OUT;
    ParallelPrefixAdder #(.WIDTH(64)) shared_adder (
        .A (A),
        .B (SUBTRACT_MODE ? ~B : B),
        .CARRY_IN (SUBTRACT_MODE),
        .SUM (ADDER_SUM),
        .CARRY_OUT (ADDER_CARRY_OUT)
    );

    // ALU Function: ALU(A, B, RESULT):
    function automatic logic [63:0] alu (
        input logic [63:0] rs1, // First operand
        input logic [63:0] rs2, // Second operand
        input alu_op_t operation_code, // The Operation Code
        input logic is_word, // Word (32-bit) operation?
        input logic [64:0] add_and_subtract_result // {carry out, sum} from the shared prefix adder
    );
    logic signed [63:0] signed_rs1; // For Signed Operations
    logic [5:0] bit_shift; // For 64 bits 2^6 = 64 which means shift is by 6 bits
    logic [4:0] word_bit_shift; // For 32 bit Word operations 2^5 = 32 which means shift is by 5 bits
    logic [63:0] and_result; // Precomputed AND Result
    logic [63:0] or_result; // Precomputed OR Result
    logic [63:0] xor_result; // Precomputed XOR Result
    logic [63:0] csr_result; // Precomputed CSR Clear-Bits Result
    logic [63:0] sll_result; // Precomputed Shift Left Logical Result
    logic [63:0] sra_result; // Precomputed Shift Right Arithmetic Result
    logic [63:0] srl_result; // Precomputed Shift Right Logical Result
    logic [31:0] word_sll_result; // Precomputed Word Shift Left Logical Result
    logic [31:0] word_srl_result; // Precomputed Word Shift Right Logical Result
    logic [31:0] word_sra_result; // Precomputed Word Shift Right Arithmetic Result
    logic slt_result; // Precomputed Signed Less-Than Result (derived from shared adder)
    logic sltu_result; // Precomputed Unsigned Less-Than Result (derived from shared adder carry-out)
    logic [63:0] alu_result; // Store the result of the 64-bit ALU operation
    logic [31:0] word_result; // Store the result of the 32-bit Word ALU operation
    begin
        signed_rs1 = $signed(rs1);
        bit_shift = rs2[5:0];
        word_bit_shift = rs2[4:0];

        // The shared adder result arrives from the ParallelPrefixAdder instance above (a function cannot contain a module)
        // Precompute all results in parallel so ALUop only drives the final mux:
        and_result = rs1 & rs2; // Operand 1 AND Operand 2
        or_result = rs1 | rs2; // Operand 1 OR Operand 2
        xor_result = rs1 ^ rs2; // Operand 1 XOR Operand 2
        csr_result = rs1 & ~rs2; // CSRs Clear bits in rs1 where rs2 has any 1s
        sll_result = rs1 << bit_shift; // Shift Left Logical by 64 bit shift
        sra_result = signed_rs1 >>> bit_shift; // Shift Right Arithmetic by 64 bit shift
        srl_result = rs1 >> bit_shift; // Shift Right Logical by 64 bit shift
        word_sll_result = rs1[31:0] << word_bit_shift; // Word Shift Left Logical (only the low 32 bits matter)
        word_srl_result = rs1[31:0] >> word_bit_shift; // Word Shift Right Logical (zeros shift in at bit 31)
        word_sra_result = $signed(rs1[31:0]) >>> word_bit_shift; // Word Shift Right Arithmetic (bit 31 copies shift in)
        slt_result = (rs1[63] != rs2[63]) ? rs1[63] : add_and_subtract_result[63]; // Signed Less-Than: sign bit of (A - B) gives the answer, unless signs differ then A's sign decides (handles overflow)
        sltu_result = ~add_and_subtract_result[64]; // Unsigned Less-Than: A < B (unsigned) means a borrow happened in A - B which means carry-out is 0

        alu_result = 64'd0;
        unique case (operation_code)
            ALU_ADD: alu_result = add_and_subtract_result[63:0]; // Operand 1 + Operand 2 (shared adder with subtract_mode = 0)
            ALU_SUB: alu_result = add_and_subtract_result[63:0]; // Operand 1 - Operand 2 (shared adder with subtract_mode = 1)
            ALU_AND: alu_result = and_result; // Operand 1 AND Operand 2
            ALU_OR: alu_result = or_result; // Operand 1 OR Operand 2
            ALU_XOR: alu_result = xor_result; // Operand 1 XOR Operand 2
            ALU_SLT: alu_result = {63'd0, slt_result}; // Set less Than if Operand 1 < Operand 2 (Signed, derived from shared adder)
            ALU_SLTU: alu_result = {63'd0, sltu_result}; // Set less Than if Operand 1 < Operand 2 (Unsigned, derived from shared adder)
            ALU_SLL: alu_result = sll_result; // Shift Left Logical by 64 bit shift
            ALU_SRA: alu_result = sra_result; // Shift Right Arithmetic by 64 bit shift
            ALU_SRL: alu_result = srl_result; // Shift Right Logical by 64 bit shift
            ALU_COPY_B: alu_result = rs2; // Just Forward whatever the value of RS2 (B)
            ALU_CSR: alu_result = csr_result; // CSRs Clear bits in rs1 where rs2 has any 1s
            ALU_JALR: alu_result = add_and_subtract_result[63:0]; // JALR requires even addresses (halfword aligned) this will be handled in riscv core logic (shared adder with subtract_mode = 0)
            default: alu_result = 64'd0; // Default Case for any edge cases not covered (ALU_XXX and the M extension which uses the Multiply Divide Unit)
        endcase

        // Word (32-bit) Operation Results: compute on the low 32 bits
        unique case (operation_code)
            ALU_SLL: word_result = word_sll_result; // SLLW / SLLIW
            ALU_SRL: word_result = word_srl_result; // SRLW / SRLIW
            ALU_SRA: word_result = word_sra_result; // SRAW / SRAIW
            default: word_result = add_and_subtract_result[31:0]; // ADDW / ADDIW / SUBW use the low half of the shared adder
        endcase

        return is_word ? {{32{word_result[31]}}, word_result} : alu_result; // Word results are sign extended from bit 31 back to 64 bits
    end
    endfunction

    always_comb begin
        ALUOut = alu(A, B, ALUop, ALU_IS_WORD_OPERATION, {ADDER_CARRY_OUT, ADDER_SUM});
    end

endmodule

`default_nettype wire
