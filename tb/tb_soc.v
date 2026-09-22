// =============================================================================
// tb_soc.v — testbench: clock, reset, per-cycle pipeline trace, register dump.
//
//   +HEX=build/prog.hex     program image ($readmemh, one byte per line)
//   +TRACE=build/prog.trace write the per-cycle trace (diffed against sim/)
//   +VCD=build/prog.vcd     dump waveforms for GTKWave
//   +MAXCYCLES=N            safety limit (default 200000)
//   +BP=0                   disable the gshare predictor (static not-taken)
// =============================================================================
`timescale 1ns/1ps
module tb_soc;
    reg clk = 1'b0, rst = 1'b1;
    always #5 clk = ~clk;                      // 100 MHz

    wire        halted, illegal_halt, t_stall, t_flush;
    wire [63:0] cycle_count, retired_count, dbg_reg_data;
    wire [63:0] t_pc_if, t_pc_id, t_pc_rr, t_pc_ex, t_pc_mem, t_pc_wb;
    wire [5:0]  t_valid;
    wire [1:0]  t_fwd_a, t_fwd_b;
    reg  [4:0]  dbg_reg_addr = 5'd0;
    reg         bp_enable = 1'b1;
    wire [63:0] branch_count, mispredict_count;
    integer     bparg;

    soc_top dut (
        .clk(clk), .rst(rst), .bp_enable(bp_enable),
        .branch_count(branch_count), .mispredict_count(mispredict_count), .halted(halted), .illegal_halt(illegal_halt),
        .cycle_count(cycle_count), .retired_count(retired_count),
        .dbg_reg_addr(dbg_reg_addr), .dbg_reg_data(dbg_reg_data),
        .t_valid(t_valid), .t_pc_if(t_pc_if), .t_pc_id(t_pc_id), .t_pc_rr(t_pc_rr),
        .t_pc_ex(t_pc_ex), .t_pc_mem(t_pc_mem), .t_pc_wb(t_pc_wb),
        .t_stall(t_stall), .t_flush(t_flush), .t_fwd_a(t_fwd_a), .t_fwd_b(t_fwd_b));

    reg [1023:0] tracefile, vcdfile;
    integer tf = 0, maxcycles, cyc = 0, i;
    reg [8*9-1:0] s_if, s_id, s_rr, s_ex, s_mem, s_wb;

    function [8*8-1:0] hex8(input v, input [63:0] pc);
        begin hex8 = v ? {hexdig(pc[31:28]), hexdig(pc[27:24]), hexdig(pc[23:20]), hexdig(pc[19:16]),
                          hexdig(pc[15:12]), hexdig(pc[11:8]),  hexdig(pc[7:4]),   hexdig(pc[3:0])}
                       : "--------"; end
    endfunction
    function [7:0] hexdig(input [3:0] n);
        hexdig = (n < 10) ? ("0" + n) : ("a" + n - 10);
    endfunction

    initial begin
        if (!$value$plusargs("MAXCYCLES=%d", maxcycles)) maxcycles = 200000;
        if ($value$plusargs("BP=%d", bparg)) bp_enable = (bparg != 0);
        if ($value$plusargs("TRACE=%s", tracefile)) tf = $fopen(tracefile, "w");
        if ($value$plusargs("VCD=%s", vcdfile)) begin $dumpfile(vcdfile); $dumpvars(0, tb_soc); end
        repeat (2) @(posedge clk);
        @(negedge clk) rst = 1'b0;
    end

    // one trace line per cycle, sampled just before the clock edge
    always @(posedge clk) if (!rst && !halted) begin
        cyc = cyc + 1;
        if (tf) begin
            $fwrite(tf, "C%0d IF:%s ID:%s RR:%s EX:%s MEM:%s WB:%s", cyc,
                hex8(t_valid[0], t_pc_if), hex8(t_valid[1], t_pc_id), hex8(t_valid[2], t_pc_rr),
                hex8(t_valid[3], t_pc_ex), hex8(t_valid[4], t_pc_mem), hex8(t_valid[5], t_pc_wb));
            if (t_stall) $fwrite(tf, " STALL");
            if (t_flush) $fwrite(tf, " FLUSH");
            $fwrite(tf, "\n");
        end
        if (cyc >= maxcycles) begin
            $display("\n[tb] ERROR: no halt after %0d cycles", cyc); $finish;
        end
    end

    always @(posedge halted) begin
        #1;
        if (tf) $fclose(tf);
        $display("");
        if (illegal_halt) $display("[tb] ILLEGAL INSTRUCTION reached write-back");
        $display("[tb] HALT after %0d cycles, %0d instructions retired (CPI %0d.%02d)",
            cycle_count, retired_count,
            cycle_count / retired_count, (cycle_count * 100 / retired_count) % 100);
        $display("[tb] predictor %s: %0d conditional branches, %0d mispredictions (redirects)",
            bp_enable ? "gshare" : "off", branch_count, mispredict_count);
        for (i = 0; i < 32; i = i + 1) begin
            dbg_reg_addr = i; #1;
            $display("REG x%0d %016h", i, dbg_reg_data);
        end
        $finish;
    end
endmodule
