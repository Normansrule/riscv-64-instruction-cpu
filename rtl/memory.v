`timescale 1ns/1ps
// =============================================================================
// memory.v — 64 KiB unified, byte-addressed, little-endian memory.
//
// Two ports, like the split I-cache / D-cache of a real core:
//   * fetch port : 32-bit instruction at iaddr        (combinational)
//   * data port  : 64-bit read at daddr (combinational), sized write on clk
// Address bits above [15:0] are ignored (the space wraps), except for one
// memory-mapped I/O register: a store to 0x1000_0000 prints a character.
// =============================================================================
`include "rv64_defines.vh"

module memory (
    input  wire        clk,
    input  wire [63:0] iaddr,
    output wire [31:0] idata,
    input  wire [63:0] daddr,
    input  wire        dwe,
    input  wire [1:0]  dsize,
    input  wire [63:0] dwdata,
    output wire [63:0] drdata
);
    reg [7:0] ram [0:65535];
    integer i;
    reg [1023:0] hexfile;
    initial begin
        for (i = 0; i < 65536; i = i + 1) ram[i] = 8'h00;
        // program image comes from the simulator command line: +HEX=build/prog.hex
        if ($value$plusargs("HEX=%s", hexfile)) $readmemh(hexfile, ram);
        else $display("[memory] no +HEX=<file> given, memory is all zeros");
    end

    /* verilator lint_off UNUSEDSIGNAL */
    wire [63:16] unused_ia = iaddr[63:16];  // memory only decodes 16 address bits
    /* verilator lint_on UNUSEDSIGNAL */
    wire [15:0] ia = iaddr[15:0];
    assign idata = {ram[ia + 16'd3], ram[ia + 16'd2], ram[ia + 16'd1], ram[ia]};

    wire        is_io = (daddr == `MMIO_PUTCHAR);
    wire [15:0] da = daddr[15:0];
    assign drdata = is_io ? 64'd0 :
        {ram[da + 16'd7], ram[da + 16'd6], ram[da + 16'd5], ram[da + 16'd4],
         ram[da + 16'd3], ram[da + 16'd2], ram[da + 16'd1], ram[da]};

    always @(posedge clk) begin
        if (dwe) begin
            if (is_io) begin
                $write("%c", dwdata[7:0]);
                $fflush();
            end else begin
                ram[da] <= dwdata[7:0];
                if (dsize >= `SZ_H) ram[da + 16'd1] <= dwdata[15:8];
                if (dsize >= `SZ_W) begin ram[da + 16'd2] <= dwdata[23:16]; ram[da + 16'd3] <= dwdata[31:24]; end
                if (dsize == `SZ_D) begin
                    ram[da + 16'd4] <= dwdata[39:32]; ram[da + 16'd5] <= dwdata[47:40];
                    ram[da + 16'd6] <= dwdata[55:48]; ram[da + 16'd7] <= dwdata[63:56];
                end
            end
        end
    end
endmodule
