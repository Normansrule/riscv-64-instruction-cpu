`timescale 1ns/1ps
// =============================================================================
// hazard_unit.v — decide, every cycle, whether the front of the pipe moves.
//
//   flush : a jump/taken branch (or a halting instruction) is in EX.
//           Kill IF, ID, RR (they hold wrong-path instructions).
//   stall : LOAD-USE. The instruction in RR needs a register that the LOAD in
//           EX will only have after MEM. Freeze PC, IF/ID and ID/RR for one
//           cycle and send a bubble (nop) into EX. By the time the dependent
//           instruction reaches EX, the loaded value sits in the MEM/WB
//           latch and the forward unit delivers it.
// flush and stall can never both be true (EX can't hold a load AND a branch).
// =============================================================================
module hazard_unit (
    input  wire       id_rr_valid, id_rr_use_rs1, id_rr_use_rs2,
    input  wire [4:0] id_rr_rs1, id_rr_rs2,
    input  wire       rr_ex_valid, rr_ex_is_load,
    input  wire [4:0] rr_ex_rd,
    input  wire       ex_redirect, ex_halt,
    output wire       stall,
    output wire       flush
);
    wire load_use = rr_ex_valid && rr_ex_is_load && rr_ex_rd != 5'd0 && id_rr_valid &&
                    ((id_rr_use_rs1 && id_rr_rs1 == rr_ex_rd) ||
                     (id_rr_use_rs2 && id_rr_rs2 == rr_ex_rd));
    assign flush = ex_redirect | ex_halt;
    assign stall = load_use & ~flush;
endmodule
