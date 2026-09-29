# Arty A7-100T board sheet (for Sixfold)

A one-page summary of the board facts Sixfold depends on, gathered from Digilent's material. This is
**not** the official reference manual. For anything electrical, check the documents under
[Official documents](#official-documents).

## The board

| | Digilent Arty A7-100T |
|---|---|
| FPGA | AMD (Xilinx) Artix-7 **XC7A100TCSG324-1** |
| Logic | 101,440 logic cells: 15,850 slices = 63,400 LUT6 + 126,800 flip-flops |
| Block RAM | 4,860 Kbit (135 x 36 Kbit RAMB36, each splittable into two 18 Kbit halves) |
| DSP | 240 DSP48E1 slices |
| Clock | 100 MHz oscillator on pin **E3**; 6 clock management tiles (MMCM + PLL each) |
| USB | **FTDI FT2232HQ**: JTAG programming on one channel, USB serial port on the other (micro-B cable) |
| Memory on the board | 256 MB DDR3L (16-bit bus, 333 MHz, 667 MT/s), 16 MB quad-SPI flash |
| User I/O | 4 green LEDs, 4 RGB LEDs, 4 buttons, 4 switches, 1 red RESET button |
| Other | 10/100 Ethernet, 4 Pmod ports, Arduino/chipKIT shield connector, on-chip ADC (XADC) |
| Power | USB, or any 7 V to 15 V source |

## Pins Sixfold uses

From Digilent's `Arty-A7-100-Master.xdc`; copied into
[`fpga/boards/arty_a7/arty_a7_100t.xdc`](../../fpga/boards/arty_a7/arty_a7_100t.xdc). All pins are LVCMOS33.

| Signal | Pin | Direction | Sixfold |
|---|---|---|---|
| `CLK100MHZ` | E3 | in | MMCM input, 100 MHz to 25 MHz (raise it if timing allows) |
| `ck_rst` | C2 | in, pressed = 0 | reset: back to the boot firmware |
| `uart_txd_in` | A9 | in | UART receive (the PC sends) |
| `uart_rxd_out` | D10 | out | UART transmit (the PC receives) |
| `led[0..3]` | H5 J5 T9 T10 | out | `LEDS[3:0]` |
| `led0_g..led3_g` | F6 J4 J2 H6 | out | `LEDS[7:4]` (green part of the RGB LEDs) |
| `btn[0..3]` | D9 C9 B9 B8 | in, pressed = 1 | `BUTTONS[3:0]` |
| `sw[0..3]` | A8 C11 C10 A10 | in | `BUTTONS[7:4]` |

## Build and program

With AMD Vivado (the free "ML Standard" edition supports the XC7A100T):

```
make fpga-arty PROG=20_leds_and_buttons      # runs fpga/boards/arty_a7/build.tcl in batch mode
openFPGALoader -b arty_a7_100t build/arty_a7/sixfold.bit      # or Vivado's Hardware Manager
```

Check `build/arty_a7/timing.txt`: the worst negative slack (WNS) must be 0 or positive. If it is negative,
lower the clock in [`arty_a7_top.sv`](../../fpga/boards/arty_a7/arty_a7_top.sv) (`CLOCK_DIVIDE` and
`CLOCK_HZ` together). The serial port is the **second** of the two ports the FT2232HQ creates
(often `/dev/ttyUSB1` on Linux).

## Official documents

* [Arty A7 Reference Manual](https://digilent.com/reference/programmable-logic/arty-a7/reference-manual) and
  [schematic](https://digilent.com/reference/programmable-logic/arty-a7/start) (Digilent)
* [Arty-A7-100-Master.xdc](https://github.com/Digilent/digilent-xdc/blob/master/Arty-A7-100-Master.xdc)
* FPGA: AMD [7 Series FPGAs Data Sheet: Overview (DS180)](https://docs.amd.com/v/u/en-US/ds180_7Series_Overview) and
  [Artix-7 Data Sheet: DC and AC Switching Characteristics (DS181)](https://docs.amd.com/v/u/en-US/ds181_Artix_7_Data_Sheet)
* [7 Series Clocking Resources (UG472)](https://docs.amd.com/v/u/en-US/ug472_7Series_Clocking) for the MMCM,
  [7 Series Memory Resources (UG473)](https://docs.amd.com/v/u/en-US/ug473_7Series_Memory_Resources) for block RAM
