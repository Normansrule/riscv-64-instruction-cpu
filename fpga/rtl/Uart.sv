`default_nettype none

// =====================================================================================================
// UART: the serial port the board's USB chip turns into a "COM port" / /dev/ttyUSB0 on the PC.
//
// One character = a start bit (0), 8 data bits (least significant first), a stop bit (1); the line idles
// at 1. There is no clock wire: both sides agree on the speed (BAUD bits per second) and the receiver
// samples each bit in its middle. CLOCKS_PER_BIT = CLOCK_HZ / BAUD (for example 25 MHz / 115200 = 217).
// =====================================================================================================
module UartTransmitter #(
    parameter int CLOCKS_PER_BIT = 217
) (
    input  logic clk,
    input  logic reset,
    input  logic SEND,            // pulse: send BYTE (ignored while BUSY)
    input  logic [7:0] BYTE,
    output logic BUSY,
    output logic TX               // the wire to the PC
);
    logic [9:0] SHIFT;            // {stop, data[7:0], start}, sent from bit 0
    logic [3:0] BITS_LEFT;
    logic [$clog2(CLOCKS_PER_BIT+1)-1:0] TIMER;
    assign BUSY = (BITS_LEFT != 4'd0);
    assign TX = BUSY ? SHIFT[0] : 1'b1;
    always_ff @(posedge clk) begin
        if (reset) begin
            BITS_LEFT <= 4'd0;
            TIMER <= '0;
            SHIFT <= 10'h3FF;
        end else if (!BUSY) begin
            if (SEND) begin
                SHIFT <= {1'b1, BYTE, 1'b0};
                BITS_LEFT <= 4'd10;
                TIMER <= CLOCKS_PER_BIT[$bits(TIMER)-1:0] - 1'b1;
            end
        end else if (TIMER == '0) begin
            SHIFT <= {1'b1, SHIFT[9:1]};
            BITS_LEFT <= BITS_LEFT - 4'd1;
            TIMER <= CLOCKS_PER_BIT[$bits(TIMER)-1:0] - 1'b1;
        end else begin
            TIMER <= TIMER - 1'b1;
        end
    end
endmodule

module UartReceiver #(
    parameter int CLOCKS_PER_BIT = 217
) (
    input  logic clk,
    input  logic reset,
    input  logic RX,              // the wire from the PC (asynchronous to clk)
    output logic RECEIVED,        // one-cycle pulse: BYTE is new
    output logic [7:0] BYTE
);
    logic [2:0] SYNCHRONIZER;     // two flip-flops against metastability, the third remembers the last level
    logic LINE;
    assign LINE = SYNCHRONIZER[1];
    logic ACTIVE;
    logic [3:0] BIT_INDEX;        // 0 = start bit, 1..8 = data, 9 = stop
    logic [$clog2(CLOCKS_PER_BIT+1)-1:0] TIMER;
    logic [7:0] DATA;
    always_ff @(posedge clk) begin
        SYNCHRONIZER <= {SYNCHRONIZER[1:0], RX};
        RECEIVED <= 1'b0;
        if (reset) begin
            ACTIVE <= 1'b0;
            SYNCHRONIZER <= 3'b111;
            BIT_INDEX <= 4'd0;
            TIMER <= '0;
            DATA <= 8'd0;
            BYTE <= 8'd0;
        end else if (!ACTIVE) begin
            if (!LINE) begin      // falling edge: a start bit begins; sample it half a bit later
                ACTIVE <= 1'b1;
                BIT_INDEX <= 4'd0;
                TIMER <= ($bits(TIMER))'(CLOCKS_PER_BIT / 2);
            end
        end else if (TIMER == '0) begin
            TIMER <= CLOCKS_PER_BIT[$bits(TIMER)-1:0] - 1'b1;
            if (BIT_INDEX == 4'd0) begin
                if (LINE) ACTIVE <= 1'b0; // not a real start bit (a glitch): back to idle
                else BIT_INDEX <= 4'd1;
            end else if (BIT_INDEX <= 4'd8) begin
                DATA <= {LINE, DATA[7:1]};
                BIT_INDEX <= BIT_INDEX + 4'd1;
            end else begin    // the stop bit
                ACTIVE <= 1'b0;
                if (LINE) begin
                    RECEIVED <= 1'b1;
                    BYTE <= DATA;
                end
            end
        end else begin
            TIMER <= TIMER - 1'b1;
        end
    end
endmodule

// A first-in first-out queue of bytes. READ pops the oldest byte.
//   SYNCHRONOUS_READ = 1 : block RAM; the popped byte appears on DATA_OUT in the NEXT cycle (transmit queue)
//   SYNCHRONOUS_READ = 0 : small LUT memory; DATA_OUT is always the oldest byte, right now (receive queue,
//                          which the CPU reads through a status register)
module ByteFifo #(
    parameter int DEPTH = 2048,
    parameter bit SYNCHRONOUS_READ = 1'b1
) (
    input  logic clk,
    input  logic reset,
    input  logic WRITE,
    input  logic [7:0] DATA_IN,
    input  logic READ,
    output logic [7:0] DATA_OUT,
    output logic EMPTY,
    output logic FULL
);
    localparam int BITS = $clog2(DEPTH);
    logic [7:0] STORAGE [0:DEPTH-1];
    logic [BITS:0] WRITE_POINTER, READ_POINTER; // one extra bit tells full from empty
    assign EMPTY = (WRITE_POINTER == READ_POINTER);
    assign FULL = (WRITE_POINTER[BITS-1:0] == READ_POINTER[BITS-1:0]) && (WRITE_POINTER[BITS] != READ_POINTER[BITS]);
    always_ff @(posedge clk) begin
        if (WRITE && !FULL) STORAGE[WRITE_POINTER[BITS-1:0]] <= DATA_IN;
    end
    generate
        if (SYNCHRONOUS_READ) begin : block_ram
            always_ff @(posedge clk) DATA_OUT <= STORAGE[READ_POINTER[BITS-1:0]];
        end else begin : lut_ram
            assign DATA_OUT = STORAGE[READ_POINTER[BITS-1:0]];
        end
    endgenerate
    always_ff @(posedge clk) begin
        if (reset) begin
            WRITE_POINTER <= '0;
            READ_POINTER <= '0;
        end else begin
            if (WRITE && !FULL) WRITE_POINTER <= WRITE_POINTER + 1'b1;
            if (READ && !EMPTY) READ_POINTER <= READ_POINTER + 1'b1;
        end
    end
endmodule

`default_nettype wire
