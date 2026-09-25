`default_nettype none

import writeback_op_pkg::*;

module WriteControl (
    input logic REGISTER_WRITE_ENABLE_INPUT,
    input writeback_select_t WRITEBACK_SELECT,
    input logic [31:0] ALU_RESULT,
    input logic [31:0] MEMORY_DATA,
    input logic [31:0] PC_ADD_4,
    input logic [31:0] CSR_DATA,
    output logic REGISTER_WRITE_ENABLE_OUTPUT,
    output logic [31:0] WRITEBACK_DATA
);

    always_comb begin
        REGISTER_WRITE_ENABLE_OUTPUT = REGISTER_WRITE_ENABLE_INPUT; // Forward the Write Enable Signal by default
        WRITEBACK_DATA = 32'd0;

        // Writeback MUX:
        unique case (WRITEBACK_SELECT)
            WRITEBACK_ALU: WRITEBACK_DATA = ALU_RESULT;
            WRITEBACK_MEMORY: WRITEBACK_DATA = MEMORY_DATA;
            WRITEBACK_PC_ADD_4: WRITEBACK_DATA = PC_ADD_4;
            WRITEBACK_CSR: WRITEBACK_DATA = CSR_DATA;
            default: WRITEBACK_DATA = 32'd0;
        endcase
    end

endmodule

`default_nettype wire