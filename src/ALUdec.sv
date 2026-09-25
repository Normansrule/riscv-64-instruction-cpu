`default_nettype none

// Module: ALUdec
// Desc:   Sets the ALU operation
// Inputs:
//   opcode               : instruction opcode
//   funct                : funct3 field (for R-type / I-type instructions)
//   add_rshift_type      : distinguishes ADD vs SUB, or SRL vs SRA (instruction bit 30)
//   multiply_divide_type : funct7 == 0000001 selects the M extension (MUL, DIV, REM, ...)
// Outputs:
//   ALUop                : selects the ALU operation

import opcode_pkg::*;
import alu_op_pkg::*;

module ALUdec (
  input  logic [6:0] opcode,
  input  logic [2:0] funct,
  input  logic       add_rshift_type,
  input  logic       multiply_divide_type,
  output alu_op_t    ALUop
);

  always_comb begin
    ALUop = ALU_XXX;
    unique case (opcode)
      OPC_LUI: ALUop = ALU_COPY_B;
      OPC_AUIPC: ALUop = ALU_ADD;
      OPC_JAL: ALUop = ALU_ADD;
      OPC_JALR: ALUop = ALU_JALR;
      OPC_BRANCH: ALUop = ALU_ADD;
      OPC_LOAD: ALUop = ALU_ADD;
      OPC_STORE: ALUop = ALU_ADD;
      OPC_ARI_ITYPE, OPC_ARI_ITYPE_WORD: begin
        unique case (funct)
          FNC_ADD_SUB: ALUop = ALU_ADD;
          FNC_SLT: ALUop = ALU_SLT;
          FNC_SLTU: ALUop = ALU_SLTU;
          FNC_XOR: ALUop = ALU_XOR;
          FNC_OR: ALUop = ALU_OR;
          FNC_AND: ALUop = ALU_AND;
          FNC_SLL: ALUop = ALU_SLL;
          FNC_SRL_SRA: if (add_rshift_type == FNC2_SRA) ALUop = ALU_SRA; else ALUop = ALU_SRL;
          default: ALUop = ALU_XXX;
        endcase
      end
      OPC_ARI_RTYPE, OPC_ARI_RTYPE_WORD: begin
        if (multiply_divide_type) begin // ===== M extension (funct7 = 0000001) =====
          unique case (funct)
            FNC_MUL: ALUop = ALU_MUL;
            FNC_MULH: ALUop = ALU_MULH;
            FNC_MULHSU: ALUop = ALU_MULHSU;
            FNC_MULHU: ALUop = ALU_MULHU;
            FNC_DIV: ALUop = ALU_DIV;
            FNC_DIVU: ALUop = ALU_DIVU;
            FNC_REM: ALUop = ALU_REM;
            FNC_REMU: ALUop = ALU_REMU;
            default: ALUop = ALU_XXX;
          endcase
        end else begin
          unique case (funct)
            FNC_ADD_SUB: if (add_rshift_type == FNC2_SUB) ALUop = ALU_SUB; else ALUop = ALU_ADD;
            FNC_SLL: ALUop = ALU_SLL;
            FNC_SLT: ALUop = ALU_SLT;
            FNC_SLTU: ALUop = ALU_SLTU;
            FNC_XOR: ALUop = ALU_XOR;
            FNC_SRL_SRA: if (add_rshift_type == FNC2_SRA) ALUop = ALU_SRA; else ALUop = ALU_SRL;
            FNC_OR: ALUop = ALU_OR;
            FNC_AND: ALUop = ALU_AND;
            default: ALUop = ALU_XXX;
          endcase
        end
      end
      OPC_CSR: begin
        unique case (funct)
          FNC_RW: ALUop = ALU_COPY_B;
          FNC_RWI: ALUop = ALU_COPY_B;
          default: ALUop = ALU_XXX;
        endcase
      end
    default: ALUop = ALU_XXX;
    endcase
  end

endmodule

`default_nettype wire
