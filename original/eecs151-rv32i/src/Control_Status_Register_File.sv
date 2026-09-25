`default_nettype none

import const_pkg::*;

module CSRFile (
    input logic clk,
    input logic reset,
    input logic CSR_WRITE_ENABLE,
    input logic [11:0] CSR_ADDRESS,
    input logic [31:0] CSR_WRITE_DATA,
    output logic [31:0] CSR_READ_DATA,
    output logic [31:0] TOHOST
);

    logic [31:0] CSR_TOHOST_REGISTER;
    logic [31:0] CSR_STATUS_REGISTER;

    // Synchronous Write:
    always_ff @(posedge clk) begin
        if (reset) begin // On reset set all CSRs to 0
            CSR_TOHOST_REGISTER <= 32'd0;
            CSR_STATUS_REGISTER <= 32'd0;
        end else if (CSR_WRITE_ENABLE) begin
            unique case (CSR_ADDRESS)
                CSR_TOHOST: CSR_TOHOST_REGISTER <= CSR_WRITE_DATA;
                CSR_STATUS: CSR_STATUS_REGISTER <= CSR_WRITE_DATA;
                default: begin
                // Whatever the previous values are just keep them as is by default
                end
            endcase
            
        end
    end

    // Asynchronous Read:
    always_comb begin
        unique case (CSR_ADDRESS)
            CSR_TOHOST: CSR_READ_DATA = CSR_TOHOST_REGISTER;
            CSR_STATUS: CSR_READ_DATA = CSR_STATUS_REGISTER;
            CSR_HARTID: CSR_READ_DATA = 32'd0; // Only one core so just set id to 0
            default: CSR_READ_DATA = 32'd0;
        endcase
    end

    // Output to host value for testing purposes
    // for real applications this would be used to communicate with actual host hardware
    assign TOHOST = CSR_TOHOST_REGISTER;

endmodule

`default_nettype wire

// Research Results:
// Machine Hardware Thread ID
// CSR_MHARTID: Machine Hardware thread ID
// for this thread address is (address 0xF14)
// In real world applications multiple cores are used and to distinguish between them each core is assigned a unique hardware thread ID 
// For this design the ID would be 0, but in the future for a multi-core design each core would need to be assigned an appropriate ID

// RISC-V Official Documentation CSR: https://docs.riscv.org/reference/isa/priv/priv-csrs.html