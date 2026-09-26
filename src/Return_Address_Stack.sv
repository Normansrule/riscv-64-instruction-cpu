`default_nettype none

// =====================================================================================================
// Return Address Stack (RAS): predicts where "ret" goes.
//
// A return is "jalr x0, 0(ra)": its target lives in a register, so FETCH cannot compute it and the
// EECS 151 design always flushed 3 instructions for it. But returns follow calls in last-in first-out
// order, so a tiny stack of return addresses predicts them almost perfectly:
//
//   FETCH2 sees a call   (jal or jalr with rd = ra or t0)  : push PC + 4
//   FETCH2 sees a return (jalr x0, 0(ra) or 0(t0))         : pop, redirect FETCH1 there (1 bubble, not 3)
//   EXECUTE checks the real target; only a wrong prediction flushes.
//
// The stack is updated speculatively in FETCH2, so every instruction carries a checkpoint of the stack
// pointer; a flush restores it (the same trick the GSharePredictor uses for its history).
// A circular buffer: overflowing simply overwrites the oldest entry.
// =====================================================================================================
module ReturnAddressStack #(
    parameter int DEPTH = 8
) (
    input  logic clk,
    input  logic reset,
    output logic [63:0] TOP_ADDRESS, // Prediction for a return in FETCH2
    output logic [$clog2(DEPTH)-1:0] POINTER, // Checkpoint saved by every instruction leaving FETCH2
    input  logic PUSH, // A call is leaving FETCH2
    input  logic POP, // A return is leaving FETCH2
    input  logic [63:0] PUSH_ADDRESS, // The call's PC + 4
    input  logic RESTORE, // Execute flushed: rewind the pointer
    input  logic [$clog2(DEPTH)-1:0] RESTORE_POINTER
);

    logic [63:0] STACK [0:DEPTH-1];
    logic [$clog2(DEPTH)-1:0] TOP_POINTER; // Index of the newest entry

    assign TOP_ADDRESS = STACK[TOP_POINTER];
    assign POINTER = TOP_POINTER;

    integer STACK_INDEX;
    initial begin
        for (STACK_INDEX = 0; STACK_INDEX < DEPTH; STACK_INDEX = STACK_INDEX + 1) STACK[STACK_INDEX] = 64'd0;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            TOP_POINTER <= '0;
        end else if (RESTORE) begin
            TOP_POINTER <= RESTORE_POINTER;
        end else if (PUSH) begin
            TOP_POINTER <= TOP_POINTER + 1'b1;
            STACK[TOP_POINTER + 1'b1] <= PUSH_ADDRESS;
        end else if (POP) begin
            TOP_POINTER <= TOP_POINTER - 1'b1;
        end
    end

endmodule

`default_nettype wire
