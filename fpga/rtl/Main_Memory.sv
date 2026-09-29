`default_nettype none

// =====================================================================================================
// Main Memory for the FPGA: 64 KiB of block RAM behind the two caches.
//
// In simulation (src/Scratchpad_Memory.sv) main memory answers a 32-byte line read instantly. On an FPGA,
// block RAM is SYNCHRONOUS: an address given in one cycle returns its data the next. That fits the caches
// perfectly, because a refill keeps its line address steady for MISS_LATENCY (10) cycles before it
// installs the line: by then the block RAM output has long settled on the right line.
//
//   organisation : 2048 lines x 256 bits (one cache line per word), byte write enables
//   write port   : the core's stores (write-through from the data cache), 8 bytes at a time
//   read ports   : one line for the instruction cache refill, one for the data cache refill
//
// Block RAMs have two ports, and we need three (1 write + 2 reads), so there are two identical copies:
// every store writes both; each copy serves one refill port. (64 KiB x 2 = 1 Mbit of the ECP5-85F's 3.7.)
//
// One subtlety: the simulated memory is read combinationally, so a line installed in cycle T includes a
// store made in cycle T - 1. The block RAM output in cycle T was read at the same clock edge that did that
// store (read-before-write), so the last write is remembered and merged into the output ("bypass").
// With it, this memory returns exactly what src/Scratchpad_Memory.sv would, cycle for cycle.
// =====================================================================================================
module MainMemory #(
    parameter string INIT_FILE = "",       // $readmemh image: 64 hex digits per line, byte 0 rightmost
    parameter int LINES = 2048
) (
    input  logic clk,
    input  logic [15:0] WRITE_ADDRESS,     // byte address of the doubleword
    input  logic [7:0]  WRITE_MASK,        // byte lanes (0 = no store)
    input  logic [63:0] WRITE_DATA,
    input  logic [15:0] INSTRUCTION_REFILL_ADDRESS,
    output logic [255:0] INSTRUCTION_REFILL_LINE,
    input  logic [15:0] DATA_REFILL_ADDRESS,
    output logic [255:0] DATA_REFILL_LINE
);

    localparam int INDEX_BITS = $clog2(LINES);

    // The store, widened to a whole line: its 8 bytes placed in their doubleword, 32 byte enables
    logic [INDEX_BITS-1:0] WRITE_INDEX;
    logic [31:0] WRITE_ENABLES;
    logic [255:0] WRITE_LINE;
    assign WRITE_INDEX = WRITE_ADDRESS[INDEX_BITS+4:5];
    assign WRITE_LINE = {4{WRITE_DATA}};
    always_comb begin
        WRITE_ENABLES = 32'd0;
        WRITE_ENABLES[8*WRITE_ADDRESS[4:3] +: 8] = WRITE_MASK;
    end

    // The last write, for the read-before-write bypass
    logic [INDEX_BITS-1:0] LAST_WRITE_INDEX;
    logic [31:0] LAST_WRITE_ENABLES;
    logic [255:0] LAST_WRITE_LINE;
    always_ff @(posedge clk) begin
        LAST_WRITE_INDEX <= WRITE_INDEX;
        LAST_WRITE_ENABLES <= WRITE_ENABLES;
        LAST_WRITE_LINE <= WRITE_LINE;
    end

    logic [INDEX_BITS-1:0] READ_INDEX [0:1];
    logic [255:0] READ_LINE [0:1];
    assign READ_INDEX[0] = INSTRUCTION_REFILL_ADDRESS[INDEX_BITS+4:5];
    assign READ_INDEX[1] = DATA_REFILL_ADDRESS[INDEX_BITS+4:5];

    genvar COPY;
    generate
        for (COPY = 0; COPY < 2; COPY = COPY + 1) begin : copy
            logic [255:0] RAM [0:LINES-1];
            logic [255:0] RAM_OUTPUT;
            logic [INDEX_BITS-1:0] REGISTERED_READ_INDEX;
            initial if (INIT_FILE != "") $readmemh(INIT_FILE, RAM);
            always_ff @(posedge clk) begin
                for (int LANE = 0; LANE < 32; LANE = LANE + 1)
                    if (WRITE_ENABLES[LANE]) RAM[WRITE_INDEX][8*LANE +: 8] <= WRITE_LINE[8*LANE +: 8];
                RAM_OUTPUT <= RAM[READ_INDEX[COPY]];
                REGISTERED_READ_INDEX <= READ_INDEX[COPY];
            end
            always_comb begin
                READ_LINE[COPY] = RAM_OUTPUT;
                if (REGISTERED_READ_INDEX == LAST_WRITE_INDEX)
                    for (int LANE = 0; LANE < 32; LANE = LANE + 1)
                        if (LAST_WRITE_ENABLES[LANE]) READ_LINE[COPY][8*LANE +: 8] = LAST_WRITE_LINE[8*LANE +: 8];
            end
        end
    endgenerate

    assign INSTRUCTION_REFILL_LINE = READ_LINE[0];
    assign DATA_REFILL_LINE = READ_LINE[1];

endmodule

`default_nettype wire
