`default_nettype none

// =====================================================================================================
// ulx3s_top: Sixfold on the ULX3S board (Lattice ECP5 LFE5U-85F, radiona.org / Radiona ULX3S v3.x)
//
//   clk_25mhz  -> PLL -> CLOCK_HZ (the whole system runs on this one clock; build.sh makes the PLL)
//   ftdi_txd   -> UART receive  (the PC -> the FPGA, through the FT231X USB chip)
//   ftdi_rxd   <- UART transmit (the FPGA -> the PC)
//   btn[0]     "PWR" button: reset (active low); the boot firmware starts again, memory is kept
//   btn[6:1]   FIRE1 FIRE2 UP DOWN LEFT RIGHT -> BUTTONS[5:0];  sw[1:0] -> BUTTONS[7:6]
//   sw[3:0]    the four DIP switches -> SWITCHES[3:0]
//   led[7:0]   the LEDS register (0x1000_0008)
//   wifi_gpio0 held high, so the ESP32 on the board does not take over the FPGA
// Pin names follow the board's official constraints file ulx3s_v20.lpf (fpga/boards/ulx3s/ulx3s.lpf).
// =====================================================================================================
module ulx3s_top #(
    parameter string MEMORY_IMAGE = "memory.hex",
    parameter int CLOCK_HZ = 20_000_000      // set by build.sh (CLOCK_MHZ), which generates the matching PLL
) (
    input  wire       clk_25mhz,
    input  wire [6:0] btn,
    input  wire [3:0] sw,
    output wire [7:0] led,
    input  wire       ftdi_txd,
    output wire       ftdi_rxd,
    output wire       wifi_gpio0
);

    assign wifi_gpio0 = 1'b1;

    wire clk, pll_locked;
    SixfoldPll pll (.clkin (clk_25mhz), .clkout0 (clk), .locked (pll_locked));

    // Power-on reset: hold the system in reset until the PLL is locked and ~1.6 ms more; the PWR
    // button (active low) resets it again at any time. Everything is synchronized to clk.
    logic [15:0] power_on_counter = 16'd0;
    logic [1:0] reset_button_sync = 2'b11;
    logic reset = 1'b1;
    always_ff @(posedge clk) begin
        reset_button_sync <= {reset_button_sync[0], btn[0]};
        if (!pll_locked || !reset_button_sync[1]) power_on_counter <= 16'd0;
        else if (power_on_counter != 16'hFFFF) power_on_counter <= power_on_counter + 16'd1;
        reset <= (power_on_counter != 16'hFFFF);
    end

    logic [7:0] buttons_meta, buttons_sync;
    logic [3:0] switches_meta, switches_sync;
    always_ff @(posedge clk) begin
        buttons_meta <= {sw[1:0], btn[6:1]};
        buttons_sync <= buttons_meta;
        switches_meta <= sw;
        switches_sync <= switches_meta;
    end
    wire [15:0] leds;
    assign led = leds[7:0];

    /* verilator lint_off PINCONNECTEMPTY */
    SixfoldSystem #(.CLOCK_HZ (CLOCK_HZ), .BAUD (115_200), .MEMORY_IMAGE (MEMORY_IMAGE)) system (
        .clk (clk), .reset (reset),
        .UART_RX (ftdi_txd), .UART_TX (ftdi_rxd),
        .BUTTONS (buttons_sync), .SWITCHES ({12'd0, switches_sync}), .LEDS (leds), .DISPLAY (),
        .CORE_HALTED (), .RUNNING_PROGRAM ()
    );
    /* verilator lint_on PINCONNECTEMPTY */

    wire unused = ^leds[15:8]; // the ULX3S has 8 LEDs and no seven-segment display
endmodule

`default_nettype wire
