`default_nettype none

import const_pkg::*;
import opcode_pkg::*;

module CSRFile (
    input logic clk,
    input logic reset,
    input logic CSR_WRITE_ENABLE,
    input logic [11:0] CSR_ADDRESS,
    input logic [2:0] CSR_OPERATION, // funct3: CSRRW(I) write, CSRRS(I) set bits, CSRRC(I) clear bits
    input logic [63:0] CSR_WRITE_DATA, // rs1 value or the 5-bit zero extended immediate
    input logic INSTRUCTION_RETIRED, // An instruction finished in Writeback this cycle (counts instret)
    output logic [63:0] CSR_READ_DATA,
    output logic [63:0] TOHOST
);

    logic [63:0] CSR_TOHOST_REGISTER;
    logic [63:0] CSR_STATUS_REGISTER;
    logic [63:0] CSR_CYCLE_COUNTER; // Counts every clock cycle since reset (read with rdcycle)
    logic [63:0] CSR_INSTRET_COUNTER; // Counts every retired instruction since reset (read with rdinstret)
    logic [63:0] CSR_NEW_VALUE; // Value after applying the read-modify-write operation

    // The counters' + 1 is an increment whose carry would ripple through 64 bits: use prefix adders
    logic [63:0] CYCLE_COUNTER_NEXT, INSTRET_COUNTER_NEXT;
    logic CYCLE_CARRY_UNUSED, INSTRET_CARRY_UNUSED;
    ParallelPrefixAdder #(.WIDTH(64)) cycle_incrementer (.A (CSR_CYCLE_COUNTER), .B (64'd0), .CARRY_IN (1'b1), .SUM (CYCLE_COUNTER_NEXT), .CARRY_OUT (CYCLE_CARRY_UNUSED));
    ParallelPrefixAdder #(.WIDTH(64)) instret_incrementer (.A (CSR_INSTRET_COUNTER), .B (64'd0), .CARRY_IN (1'b1), .SUM (INSTRET_COUNTER_NEXT), .CARRY_OUT (INSTRET_CARRY_UNUSED));

    // Read-Modify-Write: CSRRW replaces, CSRRS sets the 1 bits, CSRRC clears the 1 bits
    always_comb begin
        unique case (CSR_OPERATION)
            FNC_RS, FNC_RSI: CSR_NEW_VALUE = CSR_READ_DATA | CSR_WRITE_DATA; // Set Bits
            FNC_RC, FNC_RCI: CSR_NEW_VALUE = CSR_READ_DATA & ~CSR_WRITE_DATA; // Clear Bits
            default: CSR_NEW_VALUE = CSR_WRITE_DATA; // Read and Write
        endcase
    end

    // Synchronous Write:
    always_ff @(posedge clk) begin
        if (reset) begin // On reset set all CSRs to 0
            CSR_TOHOST_REGISTER <= 64'd0;
            CSR_STATUS_REGISTER <= 64'd0;
            CSR_CYCLE_COUNTER <= 64'd0;
            CSR_INSTRET_COUNTER <= 64'd0;
        end else begin
            CSR_CYCLE_COUNTER <= CYCLE_COUNTER_NEXT; // One more clock cycle has passed
            if (INSTRUCTION_RETIRED) begin
                CSR_INSTRET_COUNTER <= INSTRET_COUNTER_NEXT; // One more instruction has finished
            end
            if (CSR_WRITE_ENABLE) begin
                unique case (CSR_ADDRESS)
                    CSR_TOHOST: CSR_TOHOST_REGISTER <= CSR_NEW_VALUE;
                    CSR_STATUS: CSR_STATUS_REGISTER <= CSR_NEW_VALUE;
                    default: begin
                    // Whatever the previous values are just keep them as is by default (the counters are read-only)
                    end
                endcase
            end
        end
    end

    // Asynchronous Read:
    always_comb begin
        unique case (CSR_ADDRESS)
            CSR_TOHOST: CSR_READ_DATA = CSR_TOHOST_REGISTER;
            CSR_STATUS: CSR_READ_DATA = CSR_STATUS_REGISTER;
            CSR_HARTID: CSR_READ_DATA = 64'd0; // Only one core so just set id to 0
            CSR_MHARTID: CSR_READ_DATA = 64'd0; // Standard Machine Hardware Thread ID: also 0
            CSR_CYCLE: CSR_READ_DATA = CSR_CYCLE_COUNTER;
            CSR_INSTRET: CSR_READ_DATA = CSR_INSTRET_COUNTER;
            default: CSR_READ_DATA = 64'd0;
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
