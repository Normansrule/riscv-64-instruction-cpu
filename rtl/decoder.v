`timescale 1ns/1ps
// =============================================================================
// decoder.v — ID stage: turns a 32-bit instruction into control signals.
//
// Everything downstream (register read, ALU, memory, write-back) is steered by
// these wires. Compare with sim/isa.js: the matching rules are identical, so
// the JS model and this RTL agree even on garbage fetched down a wrong path.
// =============================================================================
`include "rv64_defines.vh"

module decoder (
    input  wire [31:0] instr,
    output reg  [4:0]  rs1, rs2, rd,
    output reg         use_rs1,     // instruction reads rs1
    output reg         use_rs2,     // instruction reads rs2
    output reg         reg_write,   // instruction writes rd (and rd != x0)
    output reg  [4:0]  alu_op,
    output reg  [1:0]  a_sel,       // ALU input A: rs1 / pc / zero
    output reg         b_imm,       // ALU input B: 1 = immediate, 0 = rs2
    output reg         is_word,     // RV64 "W" op: 32-bit result, sign-extended
    output reg         is_load,
    output reg         is_store,
    output reg  [1:0]  mem_size,
    output reg         mem_unsigned,
    output reg         is_branch,
    output reg         is_jal,
    output reg         is_jalr,
    output reg         wb_pc4,      // write-back value is pc+4 (jal/jalr)
    output reg         is_halt,     // ecall / ebreak / illegal: stop the core
    output reg         illegal,
    output reg  [2:0]  funct3,
    output wire [63:0] imm
);
    wire [6:0] opcode = instr[6:0];
    wire [2:0] f3     = instr[14:12];
    wire [6:0] f7     = instr[31:25];
    wire [5:0] f6     = instr[31:26];

    reg [2:0] fmt;  // which immediate format to generate
    localparam F_I = 3'd0, F_S = 3'd1, F_B = 3'd2, F_U = 3'd3, F_J = 3'd4, F_SH6 = 3'd5, F_SH5 = 3'd6, F_NONE = 3'd7;

    imm_gen u_imm (.instr(instr), .fmt(fmt), .imm(imm));

    reg use_rd;
    always @* begin
        // ---- safe defaults: a bubble that does nothing -----------------------
        use_rs1 = 1'b0; use_rs2 = 1'b0; use_rd = 1'b0;
        alu_op = `ALU_ADD; a_sel = `A_RS1; b_imm = 1'b0; is_word = 1'b0;
        is_load = 1'b0; is_store = 1'b0; mem_size = f3[1:0]; mem_unsigned = f3[2];
        is_branch = 1'b0; is_jal = 1'b0; is_jalr = 1'b0; wb_pc4 = 1'b0;
        illegal = 1'b0; fmt = F_NONE; funct3 = f3;

        case (opcode)
        `OP_LUI:   begin use_rd = 1; a_sel = `A_ZERO; b_imm = 1; fmt = F_U; end
        `OP_AUIPC: begin use_rd = 1; a_sel = `A_PC;   b_imm = 1; fmt = F_U; end
        `OP_JAL:   begin use_rd = 1; is_jal = 1; wb_pc4 = 1; fmt = F_J; end
        `OP_JALR:  if (f3 == 3'b000) begin
                       use_rd = 1; use_rs1 = 1; is_jalr = 1; wb_pc4 = 1; b_imm = 1; fmt = F_I;
                   end else illegal = 1;
        `OP_BRANCH: if (f3 != 3'b010 && f3 != 3'b011) begin
                       use_rs1 = 1; use_rs2 = 1; is_branch = 1; fmt = F_B;
                   end else illegal = 1;
        `OP_LOAD:  if (f3 != 3'b111) begin
                       use_rd = 1; use_rs1 = 1; is_load = 1; b_imm = 1; fmt = F_I;
                   end else illegal = 1;
        `OP_STORE: if (f3[2] == 1'b0) begin
                       use_rs1 = 1; use_rs2 = 1; is_store = 1; b_imm = 1; fmt = F_S;
                   end else illegal = 1;
        `OP_OP_IMM: begin
            use_rd = 1; use_rs1 = 1; b_imm = 1; fmt = F_I;
            case (f3)
            3'b000: alu_op = `ALU_ADD;
            3'b010: alu_op = `ALU_SLT;
            3'b011: alu_op = `ALU_SLTU;
            3'b100: alu_op = `ALU_XOR;
            3'b110: alu_op = `ALU_OR;
            3'b111: alu_op = `ALU_AND;
            3'b001: begin fmt = F_SH6; alu_op = `ALU_SLL; if (f6 != 6'b000000) illegal = 1; end
            3'b101: begin fmt = F_SH6;
                    if (f6 == 6'b000000) alu_op = `ALU_SRL;
                    else if (f6 == 6'b010000) alu_op = `ALU_SRA;
                    else illegal = 1; end
            endcase
        end
        `OP_OP_IMM_32: begin
            use_rd = 1; use_rs1 = 1; b_imm = 1; is_word = 1; fmt = F_I;
            case (f3)
            3'b000: alu_op = `ALU_ADD;
            3'b001: begin fmt = F_SH5; alu_op = `ALU_SLL; if (f7 != 7'b0000000) illegal = 1; end
            3'b101: begin fmt = F_SH5;
                    if (f7 == 7'b0000000) alu_op = `ALU_SRL;
                    else if (f7 == 7'b0100000) alu_op = `ALU_SRA;
                    else illegal = 1; end
            default: illegal = 1;
            endcase
        end
        `OP_OP, `OP_OP_32: begin
            use_rd = 1; use_rs1 = 1; use_rs2 = 1; is_word = (opcode == `OP_OP_32);
            if (f7 == 7'b0000001) begin                    // ---- M extension
                case (f3)
                3'b000: alu_op = `ALU_MUL;
                3'b001: alu_op = `ALU_MULH;
                3'b010: alu_op = `ALU_MULHSU;
                3'b011: alu_op = `ALU_MULHU;
                3'b100: alu_op = `ALU_DIV;
                3'b101: alu_op = `ALU_DIVU;
                3'b110: alu_op = `ALU_REM;
                3'b111: alu_op = `ALU_REMU;
                endcase
                if (is_word && (f3 == 3'b001 || f3 == 3'b010 || f3 == 3'b011)) illegal = 1;
            end else if (f7 == 7'b0000000) begin
                case (f3)
                3'b000: alu_op = `ALU_ADD;
                3'b001: alu_op = `ALU_SLL;
                3'b010: alu_op = `ALU_SLT;
                3'b011: alu_op = `ALU_SLTU;
                3'b100: alu_op = `ALU_XOR;
                3'b101: alu_op = `ALU_SRL;
                3'b110: alu_op = `ALU_OR;
                3'b111: alu_op = `ALU_AND;
                endcase
                if (is_word && !(f3 == 3'b000 || f3 == 3'b001 || f3 == 3'b101)) illegal = 1;
            end else if (f7 == 7'b0100000 && f3 == 3'b000) alu_op = `ALU_SUB;
            else if (f7 == 7'b0100000 && f3 == 3'b101) alu_op = `ALU_SRA;
            else illegal = 1;
        end
        `OP_MISC_MEM: if (f3 != 3'b000) illegal = 1;           // FENCE = no-op here
        `OP_SYSTEM: begin
            // only ECALL (imm=0) and EBREAK (imm=1) with all other fields zero
            if (!(instr[11:7] == 5'd0 && instr[19:15] == 5'd0 && f3 == 3'b000 &&
                  (instr[31:20] == 12'd0 || instr[31:20] == 12'd1))) illegal = 1;
        end
        default: illegal = 1;
        endcase

        // An illegal instruction reads/writes nothing (keeps hazards identical to sim/)
        if (illegal) begin
            use_rs1 = 0; use_rs2 = 0; use_rd = 0; is_load = 0; is_store = 0;
            is_branch = 0; is_jal = 0; is_jalr = 0;
        end
        is_halt   = illegal || (opcode == `OP_SYSTEM);
        rs1       = instr[19:15];
        rs2       = instr[24:20];
        rd        = use_rd ? instr[11:7] : 5'd0;
        reg_write = use_rd && (instr[11:7] != 5'd0);
    end
endmodule
