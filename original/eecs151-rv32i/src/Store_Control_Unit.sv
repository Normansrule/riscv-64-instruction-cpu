`default_nettype none

import opcode_pkg::*;

module StoreControl (
    input logic [2:0] STORE_FUNCT3, // funct3 determines which store process to use
    input logic  [31:0] MEMORY_ADDRESS,
    input logic [31:0] MEMORY_INFO,
    output logic [3:0] WRITE_MASK_FOR_STORE,
    output logic [31:0] DATA_TO_STORE
);

    wire [1:0] BYTE_FORMATTING = MEMORY_ADDRESS[1:0]; // Last 2 bits of Memory Address Select which byte/half to store
    wire [7:0] BYTE_TO_STORE = MEMORY_INFO[7:0]; // Store Byte
    wire [15:0] HALF_TO_STORE = MEMORY_INFO[15:0]; // Store Halfword 
    wire [31:0] WORD_TO_STORE = MEMORY_INFO; // Store Full Word

    // Store Byte Logic:
    wire [31:0] STORE_BYTE_ALIGNED =
        (BYTE_FORMATTING == 2'b00) ? {24'd0, BYTE_TO_STORE} : // Byte stored at 0001
        (BYTE_FORMATTING == 2'b01) ? {16'd0, BYTE_TO_STORE, 8'd0} : // Byte stored at 0010
        (BYTE_FORMATTING == 2'b10) ? {8'd0,  BYTE_TO_STORE, 16'd0} : // Byte stored at 0100
        (BYTE_FORMATTING == 2'b11) ? {BYTE_TO_STORE, 24'd0} : // Byte stored at 1000
        32'd0; // Default case should be to leave data to store as empty

    wire [3:0] STORE_BYTE_MASK =
        (BYTE_FORMATTING == 2'b00) ? 4'b0001 :
        (BYTE_FORMATTING == 2'b01) ? 4'b0010 :
        (BYTE_FORMATTING == 2'b10) ? 4'b0100 :
        (BYTE_FORMATTING == 2'b11) ? 4'b1000 :
        4'b0000;

    // Store Halfword Logic:
    wire [31:0] STORE_HALF_ALIGNED =
        (BYTE_FORMATTING == 2'b00) ? {16'd0, HALF_TO_STORE} : // Halfword stored at 0011
        (BYTE_FORMATTING == 2'b01) ? {16'd0, HALF_TO_STORE} : // Halfword stored at 0011 (technically misaligned but specification said this is not an issue)
        (BYTE_FORMATTING == 2'b10) ? {HALF_TO_STORE, 16'd0} : // Halfword stored at 1100
        (BYTE_FORMATTING == 2'b11) ? {HALF_TO_STORE, 16'd0} : // Halfword stored at 1100 (technically misaligned but specification said this is not an issue)
        32'd0; // Default case should be to leave data to store as empty

    wire [3:0] STORE_HALF_MASK =
        (BYTE_FORMATTING == 2'b00) ? 4'b0011 :
        (BYTE_FORMATTING == 2'b01) ? 4'b0011 :
        (BYTE_FORMATTING == 2'b10) ? 4'b1100 :
        (BYTE_FORMATTING == 2'b11) ? 4'b1100 :
        4'b0000;

    always_comb begin
        WRITE_MASK_FOR_STORE = 4'b0000;
        DATA_TO_STORE = 32'd0;

        unique case (STORE_FUNCT3)
            FNC_SB: begin // Store the Byte
                WRITE_MASK_FOR_STORE = STORE_BYTE_MASK;
                DATA_TO_STORE = STORE_BYTE_ALIGNED;
            end

            FNC_SH: begin // Store the Halfword
                WRITE_MASK_FOR_STORE = STORE_HALF_MASK;
                DATA_TO_STORE = STORE_HALF_ALIGNED;
            end

            FNC_SW: begin // Store the Full Word
                WRITE_MASK_FOR_STORE = 4'b1111;
                DATA_TO_STORE = WORD_TO_STORE;
            end

            default: begin // Default is to store empty data
                WRITE_MASK_FOR_STORE = 4'b0000;
                DATA_TO_STORE = 32'd0;
            end
        endcase
    end

endmodule

`default_nettype wire