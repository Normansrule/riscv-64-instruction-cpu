`timescale 1ns/1ps
// =============================================================================
// branch_unit.v — EX stage: decide taken/not-taken and compute the target.
//
// The core predicts every branch NOT taken and keeps fetching pc+4. If this
// unit says "redirect", the 3 younger instructions (in IF, ID, RR) are wrong
// and get flushed: a taken branch or any jump costs 3 bubble cycles.
// =============================================================================
module branch_unit (
    input  wire        is_branch, is_jal, is_jalr,
    input  wire [2:0]  funct3,
    input  wire [63:0] pc, a, b, imm,
    output reg         taken,
    output wire        redirect,
    output wire [63:0] target
);
    always @* begin
        case (funct3)
        3'b000:  taken = (a == b);                      // beq
        3'b001:  taken = (a != b);                      // bne
        3'b100:  taken = ($signed(a) <  $signed(b));    // blt
        3'b101:  taken = ($signed(a) >= $signed(b));    // bge
        3'b110:  taken = (a <  b);                      // bltu
        3'b111:  taken = (a >= b);                      // bgeu
        default: taken = 1'b0;
        endcase
    end
    wire [63:0] jalr_t = (a + imm) & ~64'd1;
    assign redirect = is_jal | is_jalr | (is_branch & taken);
    assign target   = is_jalr ? jalr_t : (pc + imm);
endmodule
