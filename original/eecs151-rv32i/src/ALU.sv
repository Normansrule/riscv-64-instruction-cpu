// Fullest Optimized and Parallelized ALU:
// Optimized ALU: Uses a single shared adder/subtractor for ADD, SUB, SLT, SLTU, and JALR to reduce critical path
`default_nettype none

import opcode_pkg::*;
import alu_op_pkg::*;

module ALU (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  alu_op_t ALUop,
    output logic [31:0] ALUOut
);
    // ALU Function: ALU(A, B, RESULT):
    function automatic logic [31:0] alu (
        input logic [31:0] rs1, // First operand
        input logic [31:0] rs2, // Second operand
        input alu_op_t operation_code // The Operation Code
    );

    logic signed [31:0] signed_rs1; // For Signed Operations
    logic signed [31:0] signed_rs2; // For Signed Operations
    logic [4:0] bit_shift; // For 32 bits 2^5 = 32 which means shift is by 5 bits
    logic subtract_mode; // 0 for ADD/JALR, 1 for SUB/SLT/SLTU (uses two's complement: A - B = A + ~B + 1)
    logic [32:0] add_and_subtract_result; // Single Shared Adder/Subtractor Result (33-bit captures carry-out for unsigned compare)
    logic [31:0] and_result; // Precomputed AND Result
    logic [31:0] or_result; // Precomputed OR Result
    logic [31:0] xor_result; // Precomputed XOR Result
    logic [31:0] csr_result; // Precomputed CSR Clear-Bits Result
    logic [31:0] sll_result; // Precomputed Shift Left Logical Result
    logic [31:0] sra_result; // Precomputed Shift Right Arithmetic Result
    logic [31:0] srl_result; // Precomputed Shift Right Logical Result
    logic slt_result; // Precomputed Signed Less-Than Result (derived from shared adder)
    logic sltu_result; // Precomputed Unsigned Less-Than Result (derived from shared adder carry-out)
    logic [31:0] alu_result; // Store the result of the ALU operation
    
    begin
        signed_rs1 = $signed(rs1);
        signed_rs2 = $signed(rs2);
        bit_shift = rs2[4:0];

        // Single Shared Adder and Subtractor: Synthesis will now build a single 33-bit adder instead of 4 parallel ones (ADD, SUB, SLT, SLTU)
        subtract_mode = (operation_code == ALU_SUB) || (operation_code == ALU_SLT) || (operation_code == ALU_SLTU); // Subtract Mode for SUB, SLT, and SLTU since all three need A - B
        add_and_subtract_result = {1'b0, rs1} + {1'b0, (subtract_mode ? ~rs2 : rs2)} + {32'd0, subtract_mode}; // A + B if subtract_mode = 0, A - B = A + ~B + 1 if subtract_mode = 1

        // Precompute all results in parallel so ALUop only drives the final mux:
        and_result = rs1 & rs2; // Operand 1 AND Operand 2
        or_result = rs1 | rs2; // Operand 1 OR Operand 2
        xor_result = rs1 ^ rs2; // Operand 1 XOR Operand 2
        csr_result = rs1 & ~rs2; // CSRs Clear bits in rs1 where rs2 has any 1s
        sll_result = rs1 << bit_shift; // Shift Left Logical by 32 bit shift
        sra_result = signed_rs1 >>> bit_shift; // Shift Right Arithmetic by 32 bit shift
        srl_result = rs1 >> bit_shift; // Shift Right Logical by 32 bit shift
        slt_result = (rs1[31] != rs2[31]) ? rs1[31] : add_and_subtract_result[31]; // Signed Less-Than: sign bit of (A - B) gives the answer, unless signs differ then A's sign decides (handles overflow)
        sltu_result = ~add_and_subtract_result[32]; // Unsigned Less-Than: A < B (unsigned) means a borrow happened in A - B which means carry-out is 0
        alu_result = 32'd0;

        unique case (operation_code)
            ALU_ADD: alu_result = add_and_subtract_result[31:0]; // Operand 1 + Operand 2 (shared adder with subtract_mode = 0)
            ALU_SUB: alu_result = add_and_subtract_result[31:0]; // Operand 1 - Operand 2 (shared adder with subtract_mode = 1)
            ALU_AND: alu_result = and_result; // Operand 1 AND Operand 2
            ALU_OR: alu_result = or_result; // Operand 1 OR Operand 2
            ALU_XOR: alu_result = xor_result; // Operand 1 XOR Operand 2
            ALU_SLT: alu_result = {31'd0, slt_result}; // Set less Than if Operand 1 < Operand 2 (Signed, derived from shared adder)
            ALU_SLTU: alu_result = {31'd0, sltu_result}; // Set less Than if Operand 1 < Operand 2 (Unsigned, derived from shared adder)
            ALU_SLL: alu_result = sll_result; // Shift Left Logical by 32 bit shift
            ALU_SRA: alu_result = sra_result; // Shift Right Arithmetic by 32 bit shift
            ALU_SRL: alu_result = srl_result; // Shift Right Logical by 32 bit shift
            ALU_COPY_B: alu_result = rs2; // Just Forward whatever the value of RS2 (B)
            ALU_CSR: alu_result = csr_result; // CSRs Clear bits in rs1 where rs2 has any 1s
            ALU_JALR: alu_result = add_and_subtract_result[31:0]; // ALU_JALR: alu_result = (rs1 + rs2) & ~32'd1; // JALR requires even addresses (halfword aligned) this will be called in riscv core logic (shared adder with subtract_mode = 0)
            ALU_XXX: alu_result = 32'd0; // Default Case for XXX signal
            default: alu_result = 32'd0; // Default Case for any edge cases not covered 
        endcase
        return alu_result;
    end
    endfunction

    always_comb begin
        ALUOut = alu(A, B, ALUop);
    end

endmodule

`default_nettype wire

// // Optimized ALU: 
// `default_nettype none

// import opcode_pkg::*;
// import alu_op_pkg::*;

// module ALU (
//     input  logic [31:0] A,
//     input  logic [31:0] B,
//     input  alu_op_t ALUop,
//     output logic [31:0] ALUOut
// );
//     // ALU Function: ALU(A, B, RESULT):
//     function automatic logic [31:0] alu (
//         input logic [31:0] rs1, // First operand
//         input logic [31:0] rs2, // Second operand
//         input alu_op_t operation_code // The Operation Code
//     );
//         logic signed [31:0] signed_rs1; // For Signed Operations
//         logic signed [31:0] signed_rs2; // For Signed Operations
//         logic [4:0] bit_shift; // For 32 bits 2^5 = 32 which means shift is by 5 bits
//         logic [31:0] add_result; // Precomputed Add Result (shared by ADD and JALR)
//         logic [31:0] sub_result; // Precomputed Sub Result
//         logic [31:0] and_result; // Precomputed AND Result
//         logic [31:0] or_result; // Precomputed OR Result
//         logic [31:0] xor_result; // Precomputed XOR Result
//         logic [31:0] csr_result; // Precomputed CSR Clear-Bits Result
//         logic [31:0] sll_result; // Precomputed Shift Left Logical Result
//         logic [31:0] sra_result; // Precomputed Shift Right Arithmetic Result
//         logic [31:0] srl_result; // Precomputed Shift Right Logical Result
//         logic slt_result; // Precomputed Signed Less-Than Result
//         logic sltu_result; // Precomputed Unsigned Less-Than Result
//         logic [31:0] alu_result; // Store the result of the ALU operation
    
//     begin
//         signed_rs1 = $signed(rs1);
//         signed_rs2 = $signed(rs2);
//         bit_shift = rs2[4:0];

//         // Precompute all results in parallel so ALUop only drives the final mux:
//         add_result = rs1 + rs2; // Operand 1 + Operand 2
//         sub_result = rs1 - rs2; // Operand 1 - Operand 2
//         and_result = rs1 & rs2; // Operand 1 AND Operand 2
//         or_result = rs1 | rs2; // Operand 1 OR Operand 2
//         xor_result = rs1 ^ rs2; // Operand 1 XOR Operand 2
//         csr_result = rs1 & ~rs2; // CSRs Clear bits in rs1 where rs2 has any 1s
//         sll_result = rs1 << bit_shift; // Shift Left Logical by 32 bit shift
//         sra_result = signed_rs1 >>> bit_shift; // Shift Right Arithmetic by 32 bit shift
//         srl_result = rs1 >> bit_shift; // Shift Right Logical by 32 bit shift
//         slt_result = (signed_rs1 < signed_rs2); // Set less Than if Operand 1 < Operand 2 (Signed)
//         sltu_result = (rs1 < rs2); // Set less Than if Operand 1 < Operand 2 (Unsigned)

//         alu_result = 32'd0;

//         unique case (operation_code)
//             ALU_ADD: alu_result = add_result; // Operand 1 + Operand 2
//             ALU_SUB: alu_result = sub_result; // Operand 1 - Operand 2
//             ALU_AND: alu_result = and_result; // Operand 1 AND Operand 2
//             ALU_OR: alu_result = or_result; // Operand 1 OR Operand 2
//             ALU_XOR: alu_result = xor_result; // Operand 1 XOR Operand 2
//             ALU_SLT: alu_result = {31'd0, slt_result}; // Set less Than if Operand 1 < Operand 2 (Signed)
//             ALU_SLTU: alu_result = {31'd0, sltu_result}; // Set less Than if Operand 1 < Operand 2 (Unsigned)
//             ALU_SLL: alu_result = sll_result; // Shift Left Logical by 32 bit shift
//             ALU_SRA: alu_result = sra_result; // Shift Right Arithmetic by 32 bit shift
//             ALU_SRL: alu_result = srl_result; // Shift Right Logical by 32 bit shift
//             ALU_COPY_B: alu_result = rs2; // Just Forward whatever the value of RS2 (B)
//             ALU_CSR: alu_result = csr_result; // CSRs Clear bits in rs1 where rs2 has any 1s
//             ALU_JALR: alu_result = add_result; // ALU_JALR: alu_result = (rs1 + rs2) & ~32'd1; // JALR requires even addresses (halfword aligned) this will be called in riscv core logic
//             ALU_XXX: alu_result = 32'd0; // Default Case for XXX signal
//             default: alu_result = 32'd0; // Default Case for any edge cases not covered 
//         endcase
//         return alu_result;
//     end
//     endfunction

//     always_comb begin
//         ALUOut = alu(A, B, ALUop);
//     end

// endmodule

// `default_nettype wire

// `default_nettype none

// import opcode_pkg::*;
// import alu_op_pkg::*;

// module ALU (
//     input  logic [31:0] A,
//     input  logic [31:0] B,
//     input  alu_op_t     ALUop,
//     output logic [31:0] ALUOut
// );
//     // ALU Function: ALU(A, B, RESULT):
//     function automatic logic [31:0] alu (
//         input logic [31:0] rs1, // First operand
//         input logic [31:0] rs2, // Second operand
//         input alu_op_t operation_code // The Operation Code
//     );
//     Automatic Functions Allocate Unique Stacked Storge for Each Function Call:
//     Source: https://verificationguide.com/systemverilog/systemverilog-functions/#Automatic_Function   
//        
//         logic signed [31:0] signed_rs1; // For Signed Operations
//         logic signed [31:0] signed_rs2; // For Signed Operations
//         logic [4:0] bit_shift; // For 32 bits 2^5 = 32 which means shift is by 5 bits
//         logic [31:0] alu_result; // Store the result of the ALU operation
    
//     begin
//         signed_rs1 = $signed(rs1);
//         signed_rs2 = $signed(rs2);
//         bit_shift = rs2[4:0];
//         alu_result = 32'd0;

//         unique case (operation_code)
//             ALU_ADD: alu_result = rs1 + rs2; // Operand 1 + Operand 2
//             ALU_SUB: alu_result = rs1 - rs2; // Operand 1 - Operand 2
//             ALU_AND: alu_result = rs1 & rs2; // Operand 1 AND Operand 2
//             ALU_OR: alu_result = rs1 | rs2; // Operand 1 OR Operand 2
//             ALU_XOR: alu_result = rs1 ^ rs2; // Operand 1 XOR Operand 2
//             ALU_SLT: alu_result = (signed_rs1 < signed_rs2) ? 32'd1 : 32'd0; // Set less Than if Operand 1 < Operand 2 (Signed)
//             ALU_SLTU: alu_result = (rs1 < rs2) ? 32'd1 : 32'd0; // Set less Than if Operand 1 < Operand 2 (Unsigned)
//             ALU_SLL: alu_result = rs1 << bit_shift; // Shift Left Logical by 32 bit shift
//             ALU_SRA: alu_result = signed_rs1 >>> bit_shift; // Shift Right Arithmetic by 32 bit shift
//             ALU_SRL: alu_result = rs1 >> bit_shift; // Shift Right Logical by 32 bit shift
//             ALU_COPY_B: alu_result = rs2; // Just Forward whatever the value of RS2 (B)
//             ALU_CSR: alu_result = rs1 & ~rs2; // CSRs Clear bits in rs1 where rs2 has any 1s
//             ALU_JALR: alu_result = rs1 + rs2; // ALU_JALR: alu_result = (rs1 + rs2) & ~32'd1; // JALR requires even addresses (halfword aligned) this will be called in riscv core logic
//             ALU_XXX: alu_result = 32'd0; // Default Case for XXX signal
//             default: alu_result = 32'd0; // Default Case for any edge cases not covered 
//         endcase
//         return alu_result;
//     end
//     endfunction

//     always_comb begin
//         ALUOut = alu(A, B, ALUop);
//     end

// endmodule

// `default_nettype wire

// ==============================
// ALU OPERATION EXTENSION NOTES:
// ==============================

// CSRRC rd, csr, rs1
// Read old CSR value into target
// Clear any CSR bits where rs1 has a 1
// Write old CSR value to rd
// target = CSRs[csr]; 
// CSRs[csr] = target & ∼x[rs1]; 
// x[rd] = target

// CSRRI, rd, csr, uimm
// Read old CSR value into target
// Clear any CSR bits where unsigned immediate has a 1
// Write old CSR value to rd
// target = CSRs[csr];
// CSR[csr] = target & ∼uimm;
// x[rd] = target

// Notice: CSRs always will use a & ~b format so making a quick operation added to ALU will be useful later on

// JALR rd, rs1, offset
// Jump to address and place return address in rd
// target = pc + 4;
// pc = (x[rs1] + sext(offset)) & ∼1;
// x[rd] = target

// Notice: jal bases address off of Program counter while jalr bases it off the register rs1 
// this means that the jal is already aligned with the program counter so no fixes are necessary 
// after a jump to an address, but for jalr it needs to be at least halfword aligned so by using 
// the & ~1 it forces the address to be even which is the minimum alignment for the instruction to
// work properly, however if full word alignment is needed for specific addresses for the jalr, then
// more control logic will need to be added in the future 

// Research Results:
// ALU should add two more operations for the specific CSR and JALR instructions
// For simplicity CSR can use the operation a & ~b
// For simplicity JALR can use the operation (a + b) & ~1

// RISC-V Instructions Credit: https://msyksphinz-self.github.io/riscv-isadoc/html/rvi.html
