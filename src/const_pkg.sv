`default_nettype none

/* Global design constants. */

package const_pkg;

  // -----------------------------
  // CPU parameters (RV64: every register and address is 64 bits, instructions stay 32 bits)
  // -----------------------------
  localparam int XLEN           = 64;
  localparam int CPU_ADDR_BITS  = 64;
  localparam int CPU_INST_BITS  = 32;
  localparam int CPU_DATA_BITS  = 64;

  // -----------------------------
  // Main memory (behind the instruction and data caches in the performance build)
  // -----------------------------
  localparam int MEMORY_BYTES      = 65536;                    // 64 KiB unified instruction + data memory
  localparam logic [63:0] MMIO_PUTCHAR = 64'h0000_0000_1000_0000; // A store here prints one character

  // -----------------------------
  // PC address on reset
  // -----------------------------
  localparam logic [63:0] PC_RESET = 64'h0000_0000_0000_2000;

  // -----------------------------
  // NOP instruction
  // Depends on opcode_pkg definitions
  // -----------------------------
  localparam logic [31:0] INSTR_NOP =
      {12'd0, 5'd0, opcode_pkg::FNC_ADD_SUB, 5'd0, opcode_pkg::OPC_ARI_ITYPE};

  // -----------------------------
  // CSR addresses
  // -----------------------------
  localparam logic [11:0] CSR_TOHOST  = 12'h51E; // Write 1 = PASS, (n << 1) | 1 = FAIL test n (riscv-tests convention)
  localparam logic [11:0] CSR_HARTID  = 12'h50B;
  localparam logic [11:0] CSR_STATUS  = 12'h50A;
  // ===============================================
  // Standard read-only performance counters (programs can measure their own CPI):
  localparam logic [11:0] CSR_CYCLE   = 12'hC00; // rdcycle   : clock cycles since reset
  localparam logic [11:0] CSR_INSTRET = 12'hC02; // rdinstret : instructions retired since reset
  localparam logic [11:0] CSR_MHARTID = 12'hF14; // Machine Hardware Thread ID (always 0 on this single core)
  // ===============================================
  // Machine-mode trap CSRs (RISC-V privileged specification):
  localparam logic [11:0] CSR_MSTATUS  = 12'h300; // bit 3 MIE (interrupts enabled), bit 7 MPIE (MIE before the trap)
  localparam logic [11:0] CSR_MTVEC    = 12'h305; // trap handler address (direct mode: low 2 bits ignored)
  localparam logic [11:0] CSR_MSCRATCH = 12'h340; // free register for the handler
  localparam logic [11:0] CSR_MEPC     = 12'h341; // address of the instruction that trapped
  localparam logic [11:0] CSR_MCAUSE   = 12'h342; // why: 3 = breakpoint (ebreak), 11 = environment call (ecall)
  localparam logic [63:0] CAUSE_BREAKPOINT = 64'd3;
  localparam logic [63:0] CAUSE_ENVIRONMENT_CALL = 64'd11;
  // ===============================================

endpackage : const_pkg

`default_nettype wire
