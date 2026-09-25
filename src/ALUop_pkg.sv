`default_nettype none

package alu_op_pkg;
  typedef enum logic [4:0] {
    ALU_ADD    = 5'd0,
    ALU_SUB    = 5'd1,
    ALU_AND    = 5'd2,
    ALU_OR     = 5'd3,
    ALU_XOR    = 5'd4,
    ALU_SLT    = 5'd5,
    ALU_SLTU   = 5'd6,
    ALU_SLL    = 5'd7,
    ALU_SRA    = 5'd8,
    ALU_SRL    = 5'd9,
    ALU_COPY_B = 5'd10,
    ALU_CSR    = 5'd11, // Added for CSR instructions
    ALU_JALR   = 5'd12, // Added for JALR instruction
    // ===============================================
    // M extension: handled by the Multiply Divide Unit next to the ALU
    ALU_MUL    = 5'd16,
    ALU_MULH   = 5'd17,
    ALU_MULHSU = 5'd18,
    ALU_MULHU  = 5'd19,
    ALU_DIV    = 5'd20,
    ALU_DIVU   = 5'd21,
    ALU_REM    = 5'd22,
    ALU_REMU   = 5'd23,
    // ===============================================
    ALU_XXX    = 5'd31
  } alu_op_t;
endpackage : alu_op_pkg

`default_nettype wire
