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
    // Split counters: each 64-bit counter is two 32-bit halves. The low half's carry is REGISTERED and added
    // to the high half one cycle later, so no 64-bit carry chain sits between two flip-flops. (The high half
    // lags by one cycle once every 2^32 counts, which is harmless for performance counters.)
    logic CYCLE_CARRY_PENDING, INSTRET_CARRY_PENDING;
    logic [63:0] CSR_NEW_VALUE; // Value after applying the read-modify-write operation

    logic [31:0] CYCLE_LOW_NEXT, CYCLE_HIGH_NEXT, INSTRET_LOW_NEXT, INSTRET_HIGH_NEXT;
    logic CYCLE_LOW_CARRY, CYCLE_HIGH_CARRY_UNUSED, INSTRET_LOW_CARRY, INSTRET_HIGH_CARRY_UNUSED;
    ParallelPrefixAdder #(.WIDTH(32)) cycle_low_incrementer (.A (CSR_CYCLE_COUNTER[31:0]), .B (32'd0), .CARRY_IN (1'b1), .SUM (CYCLE_LOW_NEXT), .CARRY_OUT (CYCLE_LOW_CARRY));
    ParallelPrefixAdder #(.WIDTH(32)) cycle_high_incrementer (.A (CSR_CYCLE_COUNTER[63:32]), .B (32'd0), .CARRY_IN (CYCLE_CARRY_PENDING), .SUM (CYCLE_HIGH_NEXT), .CARRY_OUT (CYCLE_HIGH_CARRY_UNUSED));
    ParallelPrefixAdder #(.WIDTH(32)) instret_low_incrementer (.A (CSR_INSTRET_COUNTER[31:0]), .B (32'd0), .CARRY_IN (1'b1), .SUM (INSTRET_LOW_NEXT), .CARRY_OUT (INSTRET_LOW_CARRY));
    ParallelPrefixAdder #(.WIDTH(32)) instret_high_incrementer (.A (CSR_INSTRET_COUNTER[63:32]), .B (32'd0), .CARRY_IN (INSTRET_CARRY_PENDING), .SUM (INSTRET_HIGH_NEXT), .CARRY_OUT (INSTRET_HIGH_CARRY_UNUSED));

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
            CYCLE_CARRY_PENDING <= 1'b0;
            INSTRET_CARRY_PENDING <= 1'b0;
        end else begin
            CSR_CYCLE_COUNTER <= {CYCLE_HIGH_NEXT, CYCLE_LOW_NEXT}; // One more clock cycle has passed
            CYCLE_CARRY_PENDING <= CYCLE_LOW_CARRY; // The low half wrapped: the high half catches up next cycle
            CSR_INSTRET_COUNTER[63:32] <= INSTRET_HIGH_NEXT;
            INSTRET_CARRY_PENDING <= INSTRUCTION_RETIRED && INSTRET_LOW_CARRY;
            if (INSTRUCTION_RETIRED) begin
                CSR_INSTRET_COUNTER[31:0] <= INSTRET_LOW_NEXT; // One more instruction has finished
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
