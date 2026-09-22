// =============================================================================
// rv64_defines.vh — shared constants for the 6-stage RV64IM core
// =============================================================================
`ifndef RV64_DEFINES_VH
`define RV64_DEFINES_VH

// ---- major opcodes: instr[6:0] ---------------------------------------------
`define OP_LOAD      7'b0000011
`define OP_MISC_MEM  7'b0001111
`define OP_OP_IMM    7'b0010011
`define OP_AUIPC     7'b0010111
`define OP_OP_IMM_32 7'b0011011
`define OP_STORE     7'b0100011
`define OP_OP        7'b0110011
`define OP_LUI       7'b0110111
`define OP_OP_32     7'b0111011
`define OP_BRANCH    7'b1100011
`define OP_JALR      7'b1100111
`define OP_JAL       7'b1101111
`define OP_SYSTEM    7'b1110011

// ---- ALU operations (5 bits) ------------------------------------------------
`define ALU_ADD    5'd0
`define ALU_SUB    5'd1
`define ALU_SLL    5'd2
`define ALU_SLT    5'd3
`define ALU_SLTU   5'd4
`define ALU_XOR    5'd5
`define ALU_SRL    5'd6
`define ALU_SRA    5'd7
`define ALU_OR     5'd8
`define ALU_AND    5'd9
`define ALU_MUL    5'd10
`define ALU_MULH   5'd11
`define ALU_MULHSU 5'd12
`define ALU_MULHU  5'd13
`define ALU_DIV    5'd14
`define ALU_DIVU   5'd15
`define ALU_REM    5'd16
`define ALU_REMU   5'd17

// ---- ALU operand-A select --------------------------------------------------
`define A_RS1  2'd0
`define A_PC   2'd1
`define A_ZERO 2'd2

// ---- memory access size ------------------------------------------------------
`define SZ_B 2'd0   // byte        (8)
`define SZ_H 2'd1   // halfword   (16)
`define SZ_W 2'd2   // word       (32)
`define SZ_D 2'd3   // doubleword (64)

// ---- memory-mapped I/O -------------------------------------------------------
`define MMIO_PUTCHAR 64'h0000_0000_1000_0000  // sb here prints a character

`endif
