// =====================================================================================================
// fpga/sim/system_testbench.sv: the whole FPGA computer in simulation, talked to only through its UART
//
// What a person does with the board, done by this testbench instead:
//   1. power on: the core starts in the boot firmware at 0x0000, which prints its banner and a prompt
//   2. once the prompt "sixfold> " appears, send the upload stream (+UPLOAD=build/fpga/<program>/upload.hex, made
//      by tools/fpga_image.mjs): 'l', address, length, program bytes, checksum, then 'r' to run it
//   3. print every character the system sends back; stop at the prompt after "program finished"
// The clock is 1 MHz and the UART 125000 baud (8 clocks per bit) to keep the simulation short; the
// hardware is identical to the board's except for those two numbers.
// tools/fpga_sim.mjs checks that the cycle count the firmware reports equals the model's.
// =====================================================================================================
`timescale 1ns/1ps
`default_nettype none
`ifndef MEMORY_IMAGE
  `define MEMORY_IMAGE "build/fpga/memory.hex"  // firmware only: node tools/fpga_image.mjs --out build/fpga
`endif

module system_testbench;
    localparam int CLOCK_HZ = 1_000_000;
    localparam int BAUD = 125_000;
    localparam int CLOCKS_PER_BIT = CLOCK_HZ / BAUD;

    logic clk = 1'b0;
    logic reset = 1'b1;
    always #5 clk = ~clk;

    logic UART_RX = 1'b1; // the PC's transmit line = the system's receive line
    logic UART_TX;
    logic [7:0] LEDS;
    logic CORE_HALTED, RUNNING_PROGRAM;

    SixfoldSystem #(.CLOCK_HZ (CLOCK_HZ), .BAUD (BAUD), .MEMORY_IMAGE (`MEMORY_IMAGE)) system (
        .clk (clk), .reset (reset), .UART_RX (UART_RX), .UART_TX (UART_TX), .BUTTONS (8'd0), .LEDS (LEDS),
        .CORE_HALTED (CORE_HALTED), .RUNNING_PROGRAM (RUNNING_PROGRAM)
    );

    // ---------------------------------------------------------------- receive what the system sends
    logic [8*16-1:0] RECENT = '0;     // the last 16 characters, to spot the prompt
    integer PROMPTS = 0, FINISHED = 0;
    logic [8*9-1:0] PROMPT_TEXT = "sixfold> ";
    logic [8*9-1:0] FINISHED_TEXT = "finished:";
    task automatic receive_byte(output logic [7:0] value);
        repeat (CLOCKS_PER_BIT / 2) @(posedge clk);          // middle of the start bit
        for (int b = 0; b < 8; b++) begin
            repeat (CLOCKS_PER_BIT) @(posedge clk);
            value[b] = UART_TX;
        end
        repeat (CLOCKS_PER_BIT) @(posedge clk);              // the stop bit
    endtask
    initial begin : monitor
        logic [7:0] c;
        forever begin
            @(negedge UART_TX);
            receive_byte(c);
            $write("%c", c);
            $fflush();
            RECENT = {RECENT[8*15-1:0], c};
            if (RECENT[8*9-1:0] == PROMPT_TEXT) PROMPTS = PROMPTS + 1;
            if (RECENT[8*9-1:0] == FINISHED_TEXT) FINISHED = FINISHED + 1;
        end
    end

    // ---------------------------------------------------------------- send the upload stream
    logic [8:0] UPLOAD [0:65535]; // bit 8 marks "no byte here" (works in 2-state simulators too)
    integer UPLOAD_BYTES = 0;
    logic [1023:0] UPLOAD_FILE;
    task automatic send_byte(input logic [7:0] value);
        UART_RX = 1'b0;
        repeat (CLOCKS_PER_BIT) @(posedge clk);
        for (int b = 0; b < 8; b++) begin
            UART_RX = value[b];
            repeat (CLOCKS_PER_BIT) @(posedge clk);
        end
        UART_RX = 1'b1;
        repeat (CLOCKS_PER_BIT) @(posedge clk);
    endtask

    integer CYCLE = 0, MAX_CYCLES;
    always @(posedge clk) CYCLE <= CYCLE + 1;

    initial begin
        if (!$value$plusargs("MAXCYCLES=%d", MAX_CYCLES)) MAX_CYCLES = 3_000_000;
        for (int i = 0; i < 65536; i++) UPLOAD[i] = 9'h100;
        if ($value$plusargs("UPLOAD=%s", UPLOAD_FILE)) begin
            $readmemh(UPLOAD_FILE, UPLOAD);
            while (UPLOAD_BYTES < 65536 && !UPLOAD[UPLOAD_BYTES][8]) UPLOAD_BYTES = UPLOAD_BYTES + 1;
        end
        repeat (4) @(posedge clk);
        reset = 1'b0;
        wait (PROMPTS == 1);                                  // the firmware is ready
        for (int i = 0; i < UPLOAD_BYTES; i++) send_byte(UPLOAD[i][7:0]);
        if (UPLOAD_BYTES == 0) begin
            $display("\n[testbench] no +UPLOAD=<file>: stopping at the prompt");
            $finish;
        end
        wait (FINISHED == 1 && PROMPTS == 3);                 // loaded prompt, then the one after the report
        repeat (10) @(posedge clk);
        $display("\n[testbench] done after %0d cycles, LEDs %08b", CYCLE, LEDS);
        $finish;
    end
    always @(posedge clk) if (CYCLE >= MAX_CYCLES) begin
        $display("\n[testbench] TIMEOUT after %0d cycles", CYCLE);
        $finish;
    end
`ifdef DEBUG_UART
    always @(posedge clk) begin
        if (system.RX_RECEIVED) $display("\n[rx] %h", system.RX_BYTE);
        if (system.RX_POP) $display("\n[pop] empty=%b pc=%h", system.RX_QUEUE_EMPTY, system.core.EXECUTE_PC);
    end
`endif
endmodule

`default_nettype wire
