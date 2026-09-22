`timescale 1ns/1ps
// =============================================================================
// rv64_core.v — a 6-stage, in-order, single-issue RV64IM pipeline.
//
//   ┌────┐   ┌────┐   ┌────┐   ┌────┐   ┌─────┐   ┌────┐
//   │ IF │──►│ ID │──►│ RR │──►│ EX │──►│ MEM │──►│ WB │
//   └────┘   └────┘   └────┘   └────┘   └─────┘   └────┘
//    fetch    decode   register ALU,     load/     write
//    instr    control  read     branch   store     rd
//          if_id    id_rr    rr_ex    ex_mem    mem_wb      ← pipeline latches
//
// Branch prediction: a gshare predictor + BTB (rtl/branch_predictor.v) picks
// the next PC in IF. Branches resolve in EX; only a MISPREDICTION costs the
// 3-cycle flush. Drive bp_enable = 0 to fall back to "predict not taken".
//
// Why 6 stages instead of the textbook 5? Register read gets its own stage
// (RR), separating "figure out what to do" (ID) from "fetch the operands"
// (RR). Each stage does less work, so the clock can be faster — but branches
// now cost 3 flushed instructions instead of 2. That trade-off is the lesson.
//
// sim/core.js is a cycle-exact software twin of this file.
// =============================================================================
`include "rv64_defines.vh"

module rv64_core (
    input  wire        clk,
    input  wire        rst,
    input  wire        bp_enable,          // 1 = gshare predictor, 0 = static not-taken
    // instruction fetch port (combinational read)
    output wire [63:0] imem_addr,
    input  wire [31:0] imem_rdata,
    // data port (combinational read, write on clock edge)
    output wire [63:0] dmem_addr,
    output wire        dmem_we,
    output wire [1:0]  dmem_size,
    output wire [63:0] dmem_wdata,
    input  wire [63:0] dmem_rdata,
    // status
    output reg         halted,
    output reg         illegal_halt,
    output reg  [63:0] cycle_count,
    output reg  [63:0] retired_count,
    output reg  [63:0] branch_count,        // conditional branches resolved
    output reg  [63:0] mispredict_count,    // redirects caused by a wrong guess
    // register dump for the testbench
    input  wire [4:0]  dbg_reg_addr,
    output wire [63:0] dbg_reg_data,
    // pipeline trace (what's in each stage this cycle)
    output wire [5:0]  t_valid,            // {WB,MEM,EX,RR,ID,IF}
    output wire [63:0] t_pc_if, t_pc_id, t_pc_rr, t_pc_ex, t_pc_mem, t_pc_wb,
    output wire        t_stall, t_flush,
    output wire [1:0]  t_fwd_a, t_fwd_b
);
    // =========================================================================
    // Pipeline latches
    // =========================================================================
    reg  [63:0] pc;
    reg         stop_fetch;               // set when ecall/ebreak reaches EX

    // ---- IF/ID ----
    reg         if_id_valid;
    reg  [63:0] if_id_pc;
    reg  [31:0] if_id_instr;
    reg         if_id_pred_taken;         // what the predictor guessed in IF
    reg  [63:0] if_id_pred_target;
    reg  [7:0]  if_id_pred_idx;

    // ---- ID/RR : decoded control ----
    reg         id_rr_valid;
    reg  [63:0] id_rr_pc, id_rr_imm;
    reg  [4:0]  id_rr_rs1, id_rr_rs2, id_rr_rd, id_rr_alu_op;
    reg         id_rr_use_rs1, id_rr_use_rs2, id_rr_reg_write, id_rr_b_imm, id_rr_is_word;
    reg  [1:0]  id_rr_a_sel, id_rr_mem_size;
    reg         id_rr_is_load, id_rr_is_store, id_rr_mem_unsigned;
    reg         id_rr_is_branch, id_rr_is_jal, id_rr_is_jalr, id_rr_wb_pc4, id_rr_is_halt, id_rr_illegal;
    reg  [2:0]  id_rr_funct3;
    reg         id_rr_pred_taken;
    reg  [63:0] id_rr_pred_target;
    reg  [7:0]  id_rr_pred_idx;

    // ---- RR/EX : control + operand values ----
    reg         rr_ex_valid;
    reg  [63:0] rr_ex_pc, rr_ex_imm, rr_ex_rs1_val, rr_ex_rs2_val;
    reg  [4:0]  rr_ex_rs1, rr_ex_rs2, rr_ex_rd, rr_ex_alu_op;
    reg         rr_ex_use_rs1, rr_ex_use_rs2, rr_ex_reg_write, rr_ex_b_imm, rr_ex_is_word;
    reg  [1:0]  rr_ex_a_sel, rr_ex_mem_size;
    reg         rr_ex_is_load, rr_ex_is_store, rr_ex_mem_unsigned;
    reg         rr_ex_is_branch, rr_ex_is_jal, rr_ex_is_jalr, rr_ex_wb_pc4, rr_ex_is_halt, rr_ex_illegal;
    reg  [2:0]  rr_ex_funct3;
    reg         rr_ex_pred_taken;
    reg  [63:0] rr_ex_pred_target;
    reg  [7:0]  rr_ex_pred_idx;

    // ---- EX/MEM ----
    reg         ex_mem_valid;
    reg  [63:0] ex_mem_pc, ex_mem_wb_val, ex_mem_addr, ex_mem_store_data;
    reg  [4:0]  ex_mem_rd;
    reg         ex_mem_reg_write, ex_mem_is_load, ex_mem_is_store, ex_mem_mem_unsigned;
    reg  [1:0]  ex_mem_mem_size;
    reg         ex_mem_is_halt, ex_mem_illegal;

    // ---- MEM/WB ----
    reg         mem_wb_valid;
    reg  [63:0] mem_wb_pc, mem_wb_wb_val;
    reg  [4:0]  mem_wb_rd;
    reg         mem_wb_reg_write, mem_wb_is_halt, mem_wb_illegal;

    // =========================================================================
    // Stage 6 — WB : write the result back to the register file
    // =========================================================================
    wire        wb_we   = mem_wb_valid && mem_wb_reg_write;
    wire        halt_now = mem_wb_valid && mem_wb_is_halt;

    // =========================================================================
    // Stage 5 — MEM : loads and stores
    // =========================================================================
    assign dmem_addr  = ex_mem_addr;
    assign dmem_size  = ex_mem_mem_size;
    assign dmem_wdata = ex_mem_store_data;
    assign dmem_we    = ex_mem_valid && ex_mem_is_store && !halted;

    reg [63:0] load_val;
    always @* begin
        case (ex_mem_mem_size)
        `SZ_B: load_val = ex_mem_mem_unsigned ? {56'd0, dmem_rdata[7:0]}  : {{56{dmem_rdata[7]}},  dmem_rdata[7:0]};
        `SZ_H: load_val = ex_mem_mem_unsigned ? {48'd0, dmem_rdata[15:0]} : {{48{dmem_rdata[15]}}, dmem_rdata[15:0]};
        `SZ_W: load_val = ex_mem_mem_unsigned ? {32'd0, dmem_rdata[31:0]} : {{32{dmem_rdata[31]}}, dmem_rdata[31:0]};
        default: load_val = dmem_rdata;
        endcase
    end
    wire [63:0] mem_result = ex_mem_is_load ? load_val : ex_mem_wb_val;

    // =========================================================================
    // Stage 4 — EX : forwarding muxes, ALU, branch resolution
    // =========================================================================
    wire [1:0] fwd_a, fwd_b;
    forward_unit u_fwd_a (.use_rs(rr_ex_use_rs1), .rs(rr_ex_rs1),
        .ex_mem_valid(ex_mem_valid), .ex_mem_reg_write(ex_mem_reg_write), .ex_mem_rd(ex_mem_rd),
        .mem_wb_valid(mem_wb_valid), .mem_wb_reg_write(mem_wb_reg_write), .mem_wb_rd(mem_wb_rd), .sel(fwd_a));
    forward_unit u_fwd_b (.use_rs(rr_ex_use_rs2), .rs(rr_ex_rs2),
        .ex_mem_valid(ex_mem_valid), .ex_mem_reg_write(ex_mem_reg_write), .ex_mem_rd(ex_mem_rd),
        .mem_wb_valid(mem_wb_valid), .mem_wb_reg_write(mem_wb_reg_write), .mem_wb_rd(mem_wb_rd), .sel(fwd_b));

    wire [63:0] ex_rs1 = (fwd_a == 2'b01) ? ex_mem_wb_val : (fwd_a == 2'b10) ? mem_wb_wb_val : rr_ex_rs1_val;
    wire [63:0] ex_rs2 = (fwd_b == 2'b01) ? ex_mem_wb_val : (fwd_b == 2'b10) ? mem_wb_wb_val : rr_ex_rs2_val;

    wire [63:0] alu_a = (rr_ex_a_sel == `A_PC) ? rr_ex_pc : (rr_ex_a_sel == `A_ZERO) ? 64'd0 : ex_rs1;
    wire [63:0] alu_b = rr_ex_b_imm ? rr_ex_imm : ex_rs2;
    wire [63:0] alu_y;
    alu u_alu (.op(rr_ex_alu_op), .is_word(rr_ex_is_word), .a(alu_a), .b(alu_b), .y(alu_y));

    /* verilator lint_off UNUSEDSIGNAL */
    wire        br_taken;              // visible in waveforms; redirect is what matters
    /* verilator lint_on UNUSEDSIGNAL */
    wire        br_redirect;
    wire [63:0] br_target;
    branch_unit u_br (.is_branch(rr_ex_is_branch), .is_jal(rr_ex_is_jal), .is_jalr(rr_ex_is_jalr),
        .funct3(rr_ex_funct3), .pc(rr_ex_pc), .a(ex_rs1), .b(ex_rs2), .imm(rr_ex_imm),
        .taken(br_taken), .redirect(br_redirect), .target(br_target));

    // ---- compare the actual outcome with the prediction made in IF ----
    wire        actual_taken = br_redirect;                 // taken branch, jal or jalr
    wire        mispredict   = (actual_taken != rr_ex_pred_taken) ||
                               (actual_taken && (br_target != rr_ex_pred_target));
    wire        ex_redirect  = rr_ex_valid && mispredict;
    wire [63:0] fix_pc       = actual_taken ? br_target : (rr_ex_pc + 64'd4);
    wire        ex_halt     = rr_ex_valid && rr_ex_is_halt;
    wire [63:0] ex_wb_val   = rr_ex_wb_pc4 ? (rr_ex_pc + 64'd4) : alu_y;

    // =========================================================================
    // Stage 3 — RR : read the register file (write-first bypass from WB)
    // =========================================================================
    wire [63:0] rf_rd1, rf_rd2;
    regfile u_rf (.clk(clk), .ra1(id_rr_rs1), .ra2(id_rr_rs2), .rd1(rf_rd1), .rd2(rf_rd2),
        .we(wb_we && !halted), .wa(mem_wb_rd), .wd(mem_wb_wb_val),
        .dbg_addr(dbg_reg_addr), .dbg_data(dbg_reg_data));

    // =========================================================================
    // Stage 2 — ID : decode
    // =========================================================================
    wire [4:0]  d_rs1, d_rs2, d_rd, d_alu_op;
    wire        d_use_rs1, d_use_rs2, d_reg_write, d_b_imm, d_is_word, d_is_load, d_is_store, d_mem_unsigned;
    wire        d_is_branch, d_is_jal, d_is_jalr, d_wb_pc4, d_is_halt, d_illegal;
    wire [1:0]  d_a_sel, d_mem_size;
    wire [2:0]  d_funct3;
    wire [63:0] d_imm;
    decoder u_dec (.instr(if_id_instr), .rs1(d_rs1), .rs2(d_rs2), .rd(d_rd),
        .use_rs1(d_use_rs1), .use_rs2(d_use_rs2), .reg_write(d_reg_write), .alu_op(d_alu_op),
        .a_sel(d_a_sel), .b_imm(d_b_imm), .is_word(d_is_word), .is_load(d_is_load), .is_store(d_is_store),
        .mem_size(d_mem_size), .mem_unsigned(d_mem_unsigned), .is_branch(d_is_branch), .is_jal(d_is_jal),
        .is_jalr(d_is_jalr), .wb_pc4(d_wb_pc4), .is_halt(d_is_halt), .illegal(d_illegal),
        .funct3(d_funct3), .imm(d_imm));

    // =========================================================================
    // Stage 1 — IF : fetch
    // =========================================================================
    assign imem_addr = pc;

    wire        bp_taken;
    wire [63:0] bp_target;
    wire [7:0]  bp_idx;
    branch_predictor #(.GHR_BITS(8), .BTB_BITS(5)) u_bp (
        .clk(clk), .rst(rst), .enable(bp_enable),
        .if_pc(pc), .pred_taken(bp_taken), .pred_target(bp_target), .pred_idx(bp_idx),
        .upd_valid(rr_ex_valid && !halted && !halt_now), .upd_is_branch(rr_ex_is_branch),
        .upd_is_jump(rr_ex_is_jal | rr_ex_is_jalr), .upd_taken(actual_taken),
        .upd_pc(rr_ex_pc), .upd_target(br_target), .upd_idx(rr_ex_pred_idx));
    wire [63:0] next_pc = bp_taken ? bp_target : (pc + 64'd4);

    // =========================================================================
    // Hazard control
    // =========================================================================
    wire stall, flush;
    hazard_unit u_haz (.id_rr_valid(id_rr_valid), .id_rr_use_rs1(id_rr_use_rs1), .id_rr_use_rs2(id_rr_use_rs2),
        .id_rr_rs1(id_rr_rs1), .id_rr_rs2(id_rr_rs2), .rr_ex_valid(rr_ex_valid), .rr_ex_is_load(rr_ex_is_load),
        .rr_ex_rd(rr_ex_rd), .ex_redirect(ex_redirect), .ex_halt(ex_halt), .stall(stall), .flush(flush));

    // =========================================================================
    // The clock edge: every latch captures its stage's output at once
    // =========================================================================
    always @(posedge clk) begin
        if (rst) begin
            pc <= 64'd0; stop_fetch <= 1'b0; halted <= 1'b0; illegal_halt <= 1'b0;
            cycle_count <= 64'd0; retired_count <= 64'd0; branch_count <= 64'd0; mispredict_count <= 64'd0;
            if_id_valid <= 1'b0; id_rr_valid <= 1'b0; rr_ex_valid <= 1'b0;
            ex_mem_valid <= 1'b0; mem_wb_valid <= 1'b0;
        end else if (!halted) begin
            cycle_count <= cycle_count + 64'd1;
            if (mem_wb_valid) retired_count <= retired_count + 64'd1;
            if (rr_ex_valid && rr_ex_is_branch) branch_count <= branch_count + 64'd1;
            if (ex_redirect) mispredict_count <= mispredict_count + 64'd1;

            if (halt_now) begin
                halted <= 1'b1;          // freeze: the program has finished
                illegal_halt <= mem_wb_illegal;
            end else begin
                // ---------------- MEM → WB (always advances) ----------------
                mem_wb_valid     <= ex_mem_valid;
                mem_wb_pc        <= ex_mem_pc;
                mem_wb_rd        <= ex_mem_rd;
                mem_wb_reg_write <= ex_mem_reg_write;
                mem_wb_wb_val    <= mem_result;
                mem_wb_is_halt   <= ex_mem_is_halt;
                mem_wb_illegal   <= ex_mem_illegal;

                // ---------------- EX → MEM (always advances) ----------------
                ex_mem_valid        <= rr_ex_valid;
                ex_mem_pc           <= rr_ex_pc;
                ex_mem_rd           <= rr_ex_rd;
                ex_mem_reg_write    <= rr_ex_reg_write;
                ex_mem_wb_val       <= ex_wb_val;
                ex_mem_addr         <= alu_y;
                ex_mem_store_data   <= ex_rs2;
                ex_mem_is_load      <= rr_ex_is_load;
                ex_mem_is_store     <= rr_ex_is_store;
                ex_mem_mem_size     <= rr_ex_mem_size;
                ex_mem_mem_unsigned <= rr_ex_mem_unsigned;
                ex_mem_is_halt      <= rr_ex_is_halt;
                ex_mem_illegal      <= rr_ex_illegal;

                if (flush) begin
                    // ---- jump / taken branch / halt in EX: kill IF, ID, RR ----
                    if_id_valid <= 1'b0;
                    id_rr_valid <= 1'b0;
                    rr_ex_valid <= 1'b0;
                    if (ex_redirect) pc <= fix_pc;
                    if (ex_halt)     stop_fetch <= 1'b1;
                end else if (stall) begin
                    // ---- load-use: hold PC, IF/ID, ID/RR; bubble into EX ----
                    rr_ex_valid <= 1'b0;
                end else begin
                    // ---------------- RR → EX ----------------
                    rr_ex_valid        <= id_rr_valid;
                    rr_ex_pc           <= id_rr_pc;
                    rr_ex_imm          <= id_rr_imm;
                    rr_ex_rs1_val      <= rf_rd1;
                    rr_ex_rs2_val      <= rf_rd2;
                    rr_ex_rs1          <= id_rr_rs1;
                    rr_ex_rs2          <= id_rr_rs2;
                    rr_ex_rd           <= id_rr_rd;
                    rr_ex_alu_op       <= id_rr_alu_op;
                    rr_ex_use_rs1      <= id_rr_use_rs1;
                    rr_ex_use_rs2      <= id_rr_use_rs2;
                    rr_ex_reg_write    <= id_rr_reg_write;
                    rr_ex_b_imm        <= id_rr_b_imm;
                    rr_ex_is_word      <= id_rr_is_word;
                    rr_ex_a_sel        <= id_rr_a_sel;
                    rr_ex_mem_size     <= id_rr_mem_size;
                    rr_ex_is_load      <= id_rr_is_load;
                    rr_ex_is_store     <= id_rr_is_store;
                    rr_ex_mem_unsigned <= id_rr_mem_unsigned;
                    rr_ex_is_branch    <= id_rr_is_branch;
                    rr_ex_is_jal       <= id_rr_is_jal;
                    rr_ex_is_jalr      <= id_rr_is_jalr;
                    rr_ex_wb_pc4       <= id_rr_wb_pc4;
                    rr_ex_is_halt      <= id_rr_is_halt;
                    rr_ex_illegal      <= id_rr_illegal;
                    rr_ex_funct3       <= id_rr_funct3;
                    rr_ex_pred_taken   <= id_rr_pred_taken;
                    rr_ex_pred_target  <= id_rr_pred_target;
                    rr_ex_pred_idx     <= id_rr_pred_idx;

                    // ---------------- ID → RR ----------------
                    id_rr_valid        <= if_id_valid;
                    id_rr_pc           <= if_id_pc;
                    id_rr_imm          <= d_imm;
                    id_rr_rs1          <= d_rs1;
                    id_rr_rs2          <= d_rs2;
                    id_rr_rd           <= d_rd;
                    id_rr_alu_op       <= d_alu_op;
                    id_rr_use_rs1      <= d_use_rs1;
                    id_rr_use_rs2      <= d_use_rs2;
                    id_rr_reg_write    <= d_reg_write;
                    id_rr_b_imm        <= d_b_imm;
                    id_rr_is_word      <= d_is_word;
                    id_rr_a_sel        <= d_a_sel;
                    id_rr_mem_size     <= d_mem_size;
                    id_rr_is_load      <= d_is_load;
                    id_rr_is_store     <= d_is_store;
                    id_rr_mem_unsigned <= d_mem_unsigned;
                    id_rr_is_branch    <= d_is_branch;
                    id_rr_is_jal       <= d_is_jal;
                    id_rr_is_jalr      <= d_is_jalr;
                    id_rr_wb_pc4       <= d_wb_pc4;
                    id_rr_is_halt      <= d_is_halt;
                    id_rr_illegal      <= d_illegal;
                    id_rr_funct3       <= d_funct3;
                    id_rr_pred_taken   <= if_id_pred_taken;
                    id_rr_pred_target  <= if_id_pred_target;
                    id_rr_pred_idx     <= if_id_pred_idx;

                    // ---------------- IF → ID ----------------
                    if_id_valid <= !stop_fetch;
                    if_id_pc    <= pc;
                    if_id_instr <= imem_rdata;
                    if_id_pred_taken  <= bp_taken;
                    if_id_pred_target <= bp_target;
                    if_id_pred_idx    <= bp_idx;
                    if (!stop_fetch) pc <= next_pc;
                end
            end
        end
    end

    // =========================================================================
    // Trace outputs (for the testbench / waveform viewer)
    // =========================================================================
    assign t_valid  = {mem_wb_valid, ex_mem_valid, rr_ex_valid, id_rr_valid, if_id_valid, !stop_fetch};
    assign t_pc_if  = pc;        assign t_pc_id  = if_id_pc;  assign t_pc_rr = id_rr_pc;
    assign t_pc_ex  = rr_ex_pc;  assign t_pc_mem = ex_mem_pc; assign t_pc_wb = mem_wb_pc;
    assign t_stall  = stall;
    assign t_flush  = flush;
    assign t_fwd_a  = rr_ex_valid ? fwd_a : 2'b00;
    assign t_fwd_b  = rr_ex_valid ? fwd_b : 2'b00;
endmodule
