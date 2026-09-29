`default_nettype none

// =====================================================================================================
// arty_a7_top: Sixfold on the Digilent Arty A7-100T (Xilinx Artix-7 XC7A100T-1CSG324C)
//
//   CLK100MHZ  -> MMCM -> CLOCK_MHZ
//   uart_txd_in  -> UART receive  (the PC -> the FPGA, through the FT2232HQ USB chip)
//   uart_rxd_out <- UART transmit (the FPGA -> the PC)
//   ck_rst     the red RESET button (active low): the boot firmware starts again, memory is kept
//   btn[3:0] -> BUTTONS[3:0], sw[3:0] -> BUTTONS[7:4]
//   led[3:0]  (green) <- LEDS[3:0];  the green part of the four RGB LEDs <- LEDS[7:4]
// Pin names follow Digilent's Arty-A7-100-Master.xdc (fpga/boards/arty_a7/arty_a7_100t.xdc).
// =====================================================================================================
module arty_a7_top #(
    parameter string MEMORY_IMAGE = "memory.hex",
    // 100 MHz x CLOCK_MULTIPLY / CLOCK_DIVIDE. The VCO (100 MHz x CLOCK_MULTIPLY) must stay within
    // 600..1200 MHz. 10 / 40 = 25 MHz, a safe start: if Vivado's timing report shows positive slack,
    // try 10 / 30 (33.3 MHz) or 10 / 25 (40 MHz), and change CLOCK_HZ to match (the UART divides it).
    parameter real CLOCK_MULTIPLY = 10.0,
    parameter real CLOCK_DIVIDE = 40.0,
    parameter int CLOCK_HZ = 25_000_000
) (
    input  wire       CLK100MHZ,
    input  wire       ck_rst,
    input  wire [3:0] btn,
    input  wire [3:0] sw,
    output wire [3:0] led,
    output wire       led0_g, led1_g, led2_g, led3_g,
    input  wire       uart_txd_in,
    output wire       uart_rxd_out
);
    wire clk, clk_unbuffered, feedback, locked;
    MMCME2_BASE #(
        .CLKIN1_PERIOD (10.0), .CLKFBOUT_MULT_F (CLOCK_MULTIPLY), .CLKOUT0_DIVIDE_F (CLOCK_DIVIDE), .DIVCLK_DIVIDE (1)
    ) mmcm (
        .CLKIN1 (CLK100MHZ), .CLKFBIN (feedback), .CLKFBOUT (feedback), .CLKOUT0 (clk_unbuffered),
        .LOCKED (locked), .PWRDWN (1'b0), .RST (1'b0),
        .CLKFBOUTB (), .CLKOUT0B (), .CLKOUT1 (), .CLKOUT1B (), .CLKOUT2 (), .CLKOUT2B (), .CLKOUT3 (), .CLKOUT3B (),
        .CLKOUT4 (), .CLKOUT5 (), .CLKOUT6 ()
    );
    BUFG clock_buffer (.I (clk_unbuffered), .O (clk));

    logic [15:0] power_on_counter = 16'd0;
    logic [1:0] reset_button_sync = 2'b11;
    logic reset = 1'b1;
    always_ff @(posedge clk) begin
        reset_button_sync <= {reset_button_sync[0], ck_rst};
        if (!locked || !reset_button_sync[1]) power_on_counter <= 16'd0;
        else if (power_on_counter != 16'hFFFF) power_on_counter <= power_on_counter + 16'd1;
        reset <= (power_on_counter != 16'hFFFF);
    end

    logic [7:0] buttons_meta, buttons_sync;
    always_ff @(posedge clk) begin
        buttons_meta <= {sw, btn};
        buttons_sync <= buttons_meta;
    end

    wire [7:0] leds;
    assign led = leds[3:0];
    assign {led3_g, led2_g, led1_g, led0_g} = leds[7:4];

    SixfoldSystem #(.CLOCK_HZ (CLOCK_HZ), .BAUD (115_200), .MEMORY_IMAGE (MEMORY_IMAGE)) system (
        .clk (clk), .reset (reset),
        .UART_RX (uart_txd_in), .UART_TX (uart_rxd_out),
        .BUTTONS (buttons_sync), .LEDS (leds),
        .CORE_HALTED (), .RUNNING_PROGRAM ()
    );
endmodule

`default_nettype wire
