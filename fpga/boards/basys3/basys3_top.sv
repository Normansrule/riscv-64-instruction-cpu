`default_nettype none

// =====================================================================================================
// basys3_top: Sixfold on the Digilent Basys 3 (AMD Artix-7 XC7A35T-1CPG236C)
//
//   clk (100 MHz, W5) -> MMCM -> CLOCK_HZ (20 MHz)
//   RsRx / RsTx       the USB serial port (FT2232HQ), 115200 baud: the boot firmware's console
//   sw[15:0]          -> SWITCHES (0x1000_0068)
//   btnC btnU btnD btnL btnR -> BUTTONS bits 0, 2, 3, 4, 5 (the same bits as the ULX3S's FIRE1 UP DOWN LEFT RIGHT)
//   led[15:0]         <- LEDS (0x1000_0008)
//   seg, dp, an       <- DISPLAY (0x1000_0070), multiplexed by SevenSegmentDisplay
//   btnL + btnR held together for half a second: reset (the boot firmware starts again, memory is kept).
//     The Basys 3 has no spare reset button: its red PROG button reloads the FPGA and erases memory.
// Pin names follow Digilent's Basys-3-Master.xdc (fpga/boards/basys3/basys3.xdc).
// =====================================================================================================
module basys3_top #(
    parameter string MEMORY_IMAGE = "memory.hex",
    // 100 MHz x CLOCK_MULTIPLY / CLOCK_DIVIDE; the VCO (100 MHz x CLOCK_MULTIPLY) must stay within
    // 600..1200 MHz. 10 / 50 = 20 MHz, with a margin: the slowest path (an address checked against the data
    // cache's tags in one cycle) is about 40 ns in an ECP5. If Vivado's timing.txt shows positive slack, try
    // 10 / 40 (25 MHz) or 10 / 30 (33.3 MHz) and set CLOCK_HZ to match (the UART and the CLOCK register use it).
    parameter real CLOCK_MULTIPLY = 10.0,
    parameter real CLOCK_DIVIDE = 50.0,
    parameter int CLOCK_HZ = 20_000_000
) (
    input  wire        clk,
    input  wire [15:0] sw,
    input  wire        btnC, btnU, btnD, btnL, btnR,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire        dp,
    output wire [3:0]  an,
    input  wire        RsRx,
    output wire        RsTx
);
    wire clock, clock_unbuffered, feedback, locked;
    MMCME2_BASE #(
        .CLKIN1_PERIOD (10.0), .CLKFBOUT_MULT_F (CLOCK_MULTIPLY), .CLKOUT0_DIVIDE_F (CLOCK_DIVIDE), .DIVCLK_DIVIDE (1)
    ) mmcm (
        .CLKIN1 (clk), .CLKFBIN (feedback), .CLKFBOUT (feedback), .CLKOUT0 (clock_unbuffered),
        .LOCKED (locked), .PWRDWN (1'b0), .RST (1'b0),
        .CLKFBOUTB (), .CLKOUT0B (), .CLKOUT1 (), .CLKOUT1B (), .CLKOUT2 (), .CLKOUT2B (), .CLKOUT3 (), .CLKOUT3B (),
        .CLKOUT4 (), .CLKOUT5 (), .CLKOUT6 ()
    );
    BUFG clock_buffer (.I (clock_unbuffered), .O (clock));

    // Two flip-flops on every input from the outside world (they change at any time, not on our clock)
    logic [20:0] inputs_meta, inputs_sync;
    always_ff @(posedge clock) begin
        inputs_meta <= {sw, btnR, btnL, btnD, btnU, btnC};
        inputs_sync <= inputs_meta;
    end
    wire [15:0] switches = inputs_sync[20:5];
    wire [7:0] buttons = {2'b00, inputs_sync[4], inputs_sync[3], inputs_sync[2], inputs_sync[1], 1'b0, inputs_sync[0]};

    // Reset: power on (until the MMCM locks, then 65,536 more cycles), or left + right held for 0.5 s
    localparam int HOLD_CYCLES = CLOCK_HZ / 2;
    logic [$clog2(HOLD_CYCLES + 1)-1:0] hold_counter = '0;
    logic [15:0] power_on_counter = 16'd0;
    logic reset = 1'b1;
    always_ff @(posedge clock) begin
        if (buttons[4] && buttons[5]) begin
            if (hold_counter != HOLD_CYCLES[$bits(hold_counter)-1:0]) hold_counter <= hold_counter + 1'b1;
        end else hold_counter <= '0;
        if (!locked || hold_counter == HOLD_CYCLES[$bits(hold_counter)-1:0]) power_on_counter <= 16'd0;
        else if (power_on_counter != 16'hFFFF) power_on_counter <= power_on_counter + 16'd1;
        reset <= (power_on_counter != 16'hFFFF);
    end

    wire [31:0] display;
    SixfoldSystem #(.CLOCK_HZ (CLOCK_HZ), .BAUD (115_200), .MEMORY_IMAGE (MEMORY_IMAGE)) system (
        .clk (clock), .reset (reset),
        .UART_RX (RsRx), .UART_TX (RsTx),
        .BUTTONS (buttons), .SWITCHES (switches), .LEDS (led), .DISPLAY (display),
        .CORE_HALTED (), .RUNNING_PROGRAM ()
    );

    SevenSegmentDisplay #(.CLOCK_HZ (CLOCK_HZ)) seven_segment_display (
        .clk (clock), .reset (reset), .SEGMENTS (display),
        .SEGMENT_N (seg), .DECIMAL_POINT_N (dp), .ANODE_N (an)
    );
endmodule

`default_nettype wire
