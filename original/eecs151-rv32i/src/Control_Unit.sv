`default_nettype none

import opcode_pkg::*;
import immediate_op_pkg::*;
import alu_op_pkg::*;
import writeback_op_pkg::*;

module ControlUnit (
    input logic [31:0] INSTRUCTION,
    output logic REGISTER_WRITE_ENABLE,
    output logic MEMORY_READ_ENABLE,
    output logic MEMORY_WRITE_ENABLE,
    output logic CSR_WRITE_ENABLE,
    output logic CSR_WRITE_USING_IMMEDIATE,
    output logic ALU_INPUT_A_IS_PC,
    output logic ALU_INPUT_B_IS_IMMEDIATE,
    output logic IS_A_BRANCH_INSTRUCTION,
    output logic IS_A_JAL_INSTRUCTION,
    output logic IS_A_JALR_INSTRUCTION,
    output immediate_type_select_t IMMEDIATE_TYPE_SELECT,
    output writeback_select_t WRITEBACK_SELECT,
    output alu_op_t ALU_OPERATION
);

    logic [6:0] INSTRUCTION_OPCODE;
    logic [2:0] INSTRUCTION_FUNCT3;
    logic [6:0] INSTRUCTION_FUNCT7;
    logic INSTRUCTION_ADD_RSHIFT_TYPE; // if 0 its an ADD or Right Logical shift, if 1 its an SUB or Right Arithmetic Shift

    assign INSTRUCTION_OPCODE = INSTRUCTION[6:0];
    assign INSTRUCTION_FUNCT3 = INSTRUCTION[14:12];
    assign INSTRUCTION_FUNCT7 = INSTRUCTION[31:25]; // Unused 
    assign INSTRUCTION_ADD_RSHIFT_TYPE = INSTRUCTION[30];

    ALUdec alu_decode (
        .opcode(INSTRUCTION_OPCODE),
        .funct(INSTRUCTION_FUNCT3),
        .add_rshift_type(INSTRUCTION_ADD_RSHIFT_TYPE),
        .ALUop(ALU_OPERATION)
    );

    always_comb begin
        REGISTER_WRITE_ENABLE = 1'b0;
        MEMORY_READ_ENABLE = 1'b0;
        MEMORY_WRITE_ENABLE = 1'b0;
        CSR_WRITE_ENABLE = 1'b0;
        CSR_WRITE_USING_IMMEDIATE = 1'b0;
        ALU_INPUT_A_IS_PC = 1'b0; // 0 means assume register 1, 1 means assume PC 
        ALU_INPUT_B_IS_IMMEDIATE = 1'b0; // 0 means assume register 2, 1 means assume Immediate    
        IS_A_BRANCH_INSTRUCTION = 1'b0;
        IS_A_JAL_INSTRUCTION = 1'b0;
        IS_A_JALR_INSTRUCTION = 1'b0;
        IMMEDIATE_TYPE_SELECT = IMMEDIATE_I;
        WRITEBACK_SELECT = WRITEBACK_ALU;

        unique case (INSTRUCTION_OPCODE)
            OPC_LUI: begin
                REGISTER_WRITE_ENABLE = 1'b1;
                ALU_INPUT_B_IS_IMMEDIATE = 1'b1;
                IMMEDIATE_TYPE_SELECT = IMMEDIATE_U;
                WRITEBACK_SELECT = WRITEBACK_ALU;
            end

            OPC_AUIPC: begin
                REGISTER_WRITE_ENABLE = 1'b1;
                ALU_INPUT_A_IS_PC = 1'b1;
                ALU_INPUT_B_IS_IMMEDIATE = 1'b1;
                IMMEDIATE_TYPE_SELECT = IMMEDIATE_U;
                WRITEBACK_SELECT = WRITEBACK_ALU;
            end

            OPC_JAL: begin
                IS_A_JAL_INSTRUCTION    = 1'b1;
                REGISTER_WRITE_ENABLE = 1'b1;
                ALU_INPUT_A_IS_PC = 1'b1;
                ALU_INPUT_B_IS_IMMEDIATE = 1'b1;
                IMMEDIATE_TYPE_SELECT = IMMEDIATE_J;
                WRITEBACK_SELECT = WRITEBACK_PC_ADD_4;
            end

            OPC_JALR: begin
                IS_A_JALR_INSTRUCTION  = 1'b1;
                REGISTER_WRITE_ENABLE = 1'b1;
                ALU_INPUT_B_IS_IMMEDIATE = 1'b1;
                IMMEDIATE_TYPE_SELECT = IMMEDIATE_I;
                WRITEBACK_SELECT = WRITEBACK_PC_ADD_4;
            end

            OPC_BRANCH: begin
                IS_A_BRANCH_INSTRUCTION = 1'b1;
                ALU_INPUT_A_IS_PC = 1'b1;
                ALU_INPUT_B_IS_IMMEDIATE = 1'b1;
                IMMEDIATE_TYPE_SELECT = IMMEDIATE_B;
            end

            OPC_STORE: begin
                MEMORY_WRITE_ENABLE = 1'b1;
                ALU_INPUT_B_IS_IMMEDIATE = 1'b1;
                IMMEDIATE_TYPE_SELECT = IMMEDIATE_S;
            end

            OPC_LOAD: begin
                REGISTER_WRITE_ENABLE = 1'b1;
                MEMORY_READ_ENABLE = 1'b1;
                ALU_INPUT_B_IS_IMMEDIATE = 1'b1;
                IMMEDIATE_TYPE_SELECT = IMMEDIATE_I;
                WRITEBACK_SELECT = WRITEBACK_MEMORY;
            end

            OPC_ARI_RTYPE: begin
                REGISTER_WRITE_ENABLE = 1'b1;
                WRITEBACK_SELECT = WRITEBACK_ALU;
            end

            OPC_ARI_ITYPE: begin
                REGISTER_WRITE_ENABLE = 1'b1;
                ALU_INPUT_B_IS_IMMEDIATE = 1'b1;
                IMMEDIATE_TYPE_SELECT = IMMEDIATE_I;
                WRITEBACK_SELECT = WRITEBACK_ALU;
            end

            OPC_CSR: begin
                CSR_WRITE_ENABLE = (INSTRUCTION_FUNCT3 != 3'b000);
                REGISTER_WRITE_ENABLE = (INSTRUCTION_FUNCT3 != 3'b000); // Regfile will ignore x0 writes by default
                WRITEBACK_SELECT = WRITEBACK_CSR;

                if ((INSTRUCTION_FUNCT3 == FNC_RWI) || (INSTRUCTION_FUNCT3 == FNC_RSI) || (INSTRUCTION_FUNCT3 == FNC_RCI)) begin
                    CSR_WRITE_USING_IMMEDIATE = 1'b1;
                    IMMEDIATE_TYPE_SELECT = IMMEDIATE_Z;
                end else begin
                    CSR_WRITE_USING_IMMEDIATE = 1'b0;
                    IMMEDIATE_TYPE_SELECT = IMMEDIATE_I;
                end
            end

            default: begin
                REGISTER_WRITE_ENABLE = 1'b0;
                MEMORY_READ_ENABLE = 1'b0;
                MEMORY_WRITE_ENABLE = 1'b0;
                CSR_WRITE_ENABLE = 1'b0;
                CSR_WRITE_USING_IMMEDIATE = 1'b0;
                ALU_INPUT_A_IS_PC = 1'b0;
                ALU_INPUT_B_IS_IMMEDIATE = 1'b0;
                IS_A_BRANCH_INSTRUCTION = 1'b0;
                IS_A_JAL_INSTRUCTION = 1'b0;
                IS_A_JALR_INSTRUCTION = 1'b0;
                IMMEDIATE_TYPE_SELECT = IMMEDIATE_I;
                WRITEBACK_SELECT = WRITEBACK_ALU;
            end
        endcase
    end

endmodule

`default_nettype wire