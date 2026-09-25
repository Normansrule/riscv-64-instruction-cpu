`default_nettype none

module RegisterFile (
    input logic clk,
    input logic reset,
    input logic REGISTER_WRITE_ENABLE,
    input logic [4:0] READ_ADDRESS1,
    input logic [4:0] READ_ADDRESS2,
    input logic [4:0] WRITE_ADDRESS,
    input logic [31:0] WRITE_DATA,
    output logic [31:0] READ_DATA1,
    output logic [31:0] READ_DATA2
);

    parameter int DEPTH = 32;
    logic [31:0] MEMORY [0:DEPTH-1];
    integer MEMORY_INDEX;

    // Asynchronous Read Ports:
    assign READ_DATA1 = (READ_ADDRESS1 == 5'd0) ? 32'd0 : MEMORY[READ_ADDRESS1];
    assign READ_DATA2 = (READ_ADDRESS2 == 5'd0) ? 32'd0 : MEMORY[READ_ADDRESS2];

    // Synchronous Write Port:
    always_ff @(posedge clk) begin
        if (reset) begin
            // When reset is high set all registers to 0 (except x0 it should always be 0)
            for (MEMORY_INDEX = 0; MEMORY_INDEX < DEPTH; MEMORY_INDEX = MEMORY_INDEX + 1) begin
                MEMORY[MEMORY_INDEX] <= 32'd0;
            end
        end else if (REGISTER_WRITE_ENABLE && (WRITE_ADDRESS != 5'd0)) begin
            MEMORY[WRITE_ADDRESS] <= WRITE_DATA; // Synchronously write to register at the provided address
        end
        MEMORY[5'd0] <= 32'd0; // x0 is always 0 no matter what
    end

    // property p_write_to_x0;
    //     @(posedge clk) disable iff (reset) 
    //         !(REGISTER_WRITE_ENABLE && (WRITE_ADDRESS == 5'd0));
    // endproperty

    // property p_read_x0_is_0_port1;
    //     @(posedge clk) (READ_ADDRESS1 == 5'd0) |-> (READ_DATA1 == 32'd0);
    // endproperty

    // property p_read_x0_is_0_port2;
    //     @(posedge clk) (READ_ADDRESS2 == 5'd0) |-> (READ_DATA2 == 32'd0);
    // endproperty

    // Assertion in anticipation of potential bugs when running testbenches
    // property p_x0_storage_always_zero;
    //     @(posedge clk) disable iff ((reset !== 1'b0) || $isunknown(MEMORY[5'd0]))
    //         MEMORY[5'd0] == 32'd0;
    // endproperty

    // property p_x0_read_port1_zero;
    //     @(posedge clk) disable iff (reset !== 1'b0)
    //         (READ_ADDRESS1 == 5'd0) |-> (READ_DATA1 == 32'd0);
    // endproperty

    // property p_x0_read_port2_zero;
    //     @(posedge clk) disable iff (reset !== 1'b0)
    //         (READ_ADDRESS2 == 5'd0) |-> (READ_DATA2 == 32'd0);
    // endproperty

    // a_x0_storage_always_zero: assert property (p_x0_storage_always_zero);
    // a_x0_read_port1_zero:     assert property (p_x0_read_port1_zero);
    // a_x0_read_port2_zero:     assert property (p_x0_read_port2_zero);

    // a_write_to_x0: assert property (p_write_to_x0)
    //     else $error("Writing to x0");

    // a_read_x0_is_0_port1: assert property (p_read_x0_is_0_port1)
    //     else $error("Reading from x0 is not giving x0");

    // a_read_x0_is_0_port2: assert property (p_read_x0_is_0_port2)
    //     else $error("Reading from x0 is not giving x0");

endmodule

`default_nettype wire
