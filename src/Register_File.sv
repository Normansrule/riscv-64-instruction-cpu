`default_nettype none

module RegisterFile (
    input logic clk,
    input logic reset,
    input logic REGISTER_WRITE_ENABLE,
    input logic [4:0] READ_ADDRESS1,
    input logic [4:0] READ_ADDRESS2,
    input logic [4:0] WRITE_ADDRESS,
    input logic [63:0] WRITE_DATA,
    output logic [63:0] READ_DATA1,
    output logic [63:0] READ_DATA2,
    input logic [4:0] DEBUG_READ_ADDRESS, // Testbench port: dump all 32 registers when the program finishes
    output logic [63:0] DEBUG_READ_DATA
);

    parameter int DEPTH = 32;
    logic [63:0] MEMORY [1:DEPTH-1]; // x1 to x31 (x0 is not stored at all: it is hard-wired to zero)

    // Simulation start-up value. Real register files are usually NOT reset (it costs a mux per bit),
    // so the original EECS 151 reset loop was replaced: software never reads a register before writing it.
    integer MEMORY_INDEX;
    initial begin
        for (MEMORY_INDEX = 1; MEMORY_INDEX < DEPTH; MEMORY_INDEX = MEMORY_INDEX + 1) begin
            MEMORY[MEMORY_INDEX] = 64'd0;
        end
    end

    // Asynchronous Read Ports:
    assign READ_DATA1 = (READ_ADDRESS1 == 5'd0) ? 64'd0 : MEMORY[READ_ADDRESS1];
    assign READ_DATA2 = (READ_ADDRESS2 == 5'd0) ? 64'd0 : MEMORY[READ_ADDRESS2];
    assign DEBUG_READ_DATA = (DEBUG_READ_ADDRESS == 5'd0) ? 64'd0 : MEMORY[DEBUG_READ_ADDRESS];

    // Synchronous Write Port:
    always_ff @(posedge clk) begin
        if (!reset && REGISTER_WRITE_ENABLE && (WRITE_ADDRESS != 5'd0)) begin
            MEMORY[WRITE_ADDRESS] <= WRITE_DATA; // Synchronously write to register at the provided address (x0 writes are ignored)
        end
    end

endmodule

`default_nettype wire
