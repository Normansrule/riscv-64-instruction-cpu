`timescale 1ns/1ps
// =============================================================================
// imm_gen.v — reassemble the scattered immediate bits into a 64-bit value.
//
//   I : imm[11:0]           = instr[31:20]
//   S : imm[11:5|4:0]       = instr[31:25] | instr[11:7]
//   B : imm[12|10:5|4:1|11] = instr[31] | instr[30:25] | instr[11:8] | instr[7]
//   U : imm[31:12]          = instr[31:12]
//   J : imm[20|10:1|11|19:12] = instr[31] | instr[30:21] | instr[20] | instr[19:12]
// All are sign-extended from their top bit (instr[31] — always the same wire,
// which is why RISC-V puts the sign bit there in every format).
// =============================================================================
module imm_gen (
    /* verilator lint_off UNUSEDSIGNAL */   // instr[6:0] (the opcode) is never an immediate bit
    input  wire [31:0] instr,
    /* verilator lint_on UNUSEDSIGNAL */
    input  wire [2:0]  fmt,
    output reg  [63:0] imm
);
    wire s = instr[31];
    always @* begin
        case (fmt)
        3'd0: imm = {{52{s}}, instr[31:20]};                                      // I
        3'd1: imm = {{52{s}}, instr[31:25], instr[11:7]};                         // S
        3'd2: imm = {{51{s}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};  // B
        3'd3: imm = {{32{s}}, instr[31:12], 12'b0};                               // U
        3'd4: imm = {{43{s}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J
        3'd5: imm = {58'b0, instr[25:20]};                                        // 6-bit shamt
        3'd6: imm = {59'b0, instr[24:20]};                                        // 5-bit shamt
        default: imm = 64'd0;
        endcase
    end
endmodule
