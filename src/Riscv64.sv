`default_nettype none

import const_pkg::*;
import opcode_pkg::*;
import immediate_op_pkg::*;
import alu_op_pkg::*;
import writeback_op_pkg::*;

// =====================================================================================================
// Riscv64: the RISC-V 64 Instruction CPU. A 6 stage, in-order, single issue RV64IM + Zicsr core,
// grown from the EECS 151 Riscv151 design (original/eecs151-rv32i/src/Riscv151.sv).
//
// 6 Stage Datapath:
//   Fetch1 (GSharePredictor)                                                    ->
//   Fetch2 (predecode: redirect predicted-taken branches and every JAL)         ->
//   Decode (RegisterFile, ControlUnit, ImmediateGenerator, forwarding muxes)    ->
//   Execute (ALU, MultiplyDivideUnit, BranchComparator, BranchControl, StoreControl, CSRFile) ->
//   Memory (LoadControl, WriteControl)                                          ->
//   Writeback (RegisterFile write port)
//
// Hazards:
//   Data Hazard    : forwarded INTO DECODE from Execute, Memory and Writeback (priority: nearest first)
//   Load Hazard    : a load in Execute has no data yet -> hold Fetch1/Fetch2/Decode one cycle, NOP into Execute
//   Control Hazard : Fetch2 redirects predicted-taken branches and JALs (1 bubble); Execute flushes
//                    Fetch1, Fetch2 and Decode on a wrong prediction or any JALR (3 bubbles)
//
// model/core.js is a cycle-exact software twin of this file; `make test` compares them every cycle.
// =====================================================================================================
module Riscv64 #(
  parameter int GSHARE_HISTORY_BITS = 4 // 16 entry branch history table, as in the EECS 151 tape-out
) (
  input  logic        clk,
  input  logic        reset,
  input  logic        BRANCH_PREDICTION_ENABLE, // 1 = GShare predictor, 0 = always predict not taken

  // Memory system ports
  output logic [63:0] dcache_addr,
  output logic [63:0] icache_addr,
  output logic [7:0]  dcache_we,
  output logic [63:0] dcache_din,
  input  logic [63:0] dcache_dout,
  input  logic [31:0] icache_dout,
  output logic [63:0] csr, // TOHOST: 1 = PASS, anything else odd = FAIL test (csr >> 1)

  // Status and debug ports (testbench only)
  output logic        HALTED, // The instruction that wrote TOHOST has reached Writeback: the program is done
  input  logic [4:0]  DEBUG_REGISTER_ADDRESS,
  output logic [63:0] DEBUG_REGISTER_DATA,
  output logic [5:0]  TRACE_VALID, // {WRITEBACK, MEMORY, EXECUTE, DECODE, FETCH2, FETCH1}
  output logic [63:0] TRACE_FETCH1_PC, TRACE_FETCH2_PC, TRACE_DECODE_PC, TRACE_EXECUTE_PC, TRACE_MEMORY_PC, TRACE_WRITEBACK_PC,
  output logic        TRACE_LOAD_STALL, TRACE_FLUSH, TRACE_REDIRECT
);

  logic LOAD_STALL; // Load Hazard: Instead of a full stall only hold the Fetch and Decode, send a NOP to Execute, and advance the load logic for the Memory and Writeback
  logic FLUSH_FETCH1_FETCH2_DECODE; // Control Hazard: Fetch1 & Fetch2 & Decode FLUSH for mispredicted branching
  logic ADVANCE_FRONT_END; // Fetch1, Fetch2 and Decode move forward this cycle (no flush and no load stall)
  logic HALT_NOW; // The TOHOST writing instruction is in Writeback this cycle: it finishes, everything else freezes
  logic FREEZE; // No side effects this cycle (halting now, or already halted)

  // ========== Fetch 1 Stage Signals: ==========
  logic [63:0] FETCH1_PC; // The Current Program Counter to send to Instruction Memory
  logic [63:0] FETCH1_PC_ADD_4; // Next sequential Program Counter
  assign FETCH1_PC_ADD_4 = FETCH1_PC + 64'd4; // Program Counter + 4
  assign icache_addr = FETCH1_PC; // Provide Instruction Memory with Program Counter Address

  // Global Share Branch Prediction Scheme:
  logic FETCH1_PREDICTED_BRANCH_TAKEN; // Fetch 1 Stage Prediction from the Almighty Branch Predictor (0 is saying it predicts not taken, 1 is saying it will be taken)
  logic [GSHARE_HISTORY_BITS-1:0] FETCH1_GSHARE_INDEX; // Fetch 1 Branch History Table Index (for 2^n entries with n history bits to index from)
  logic [GSHARE_HISTORY_BITS-1:0] GLOBAL_HISTORY; // Current Global History Register value (saved as a checkpoint in Fetch 2)

  // Execute Stage Signals Relevant to Gshare predictor:
  logic EXECUTE_VALID;
  logic EXECUTE_UPDATE_BRANCH_PREDICTOR; // We have the actual Results from the branching scheme tally it at the Branch Predictor History Table
  logic EXECUTE_BRANCH_WAS_ACTUALLY_TAKEN; // Since Branch Comparator is in the Execute Stage this is when it will be known whether the branch was really taken or not
  logic EXECUTE_PREDICTION_WAS_WRONG; // Branch Control looks at Predicted Value and determines if the prediction was right or wrong
  logic [GSHARE_HISTORY_BITS-1:0] EXECUTE_GSHARE_INDEX; // Save the Branch History Table Index that was used for solid book keeping
  logic [GSHARE_HISTORY_BITS-1:0] EXECUTE_GLOBAL_HISTORY_CHECKPOINT; // Global History as it was before this instruction's own speculative update
  logic [GSHARE_HISTORY_BITS-1:0] EXECUTE_RESTORED_GLOBAL_HISTORY; // Correct history to rewind to on a flush
  logic EXECUTE_IS_A_BRANCH_INSTRUCTION; // Is Branch Instruction? at the Execute Stage

  // ========== Fetch 2 Stage Signals: ==========
  logic [63:0] FETCH2_PC; // The Program Counter of the instruction that just arrived from Instruction Memory
  logic FETCH2_VALID; // Verify Fetch 2 stage has a real instruction not a flush or redirection from branching or jumping
  logic [31:0] FETCH2_INSTRUCTION; // Full Instruction from Instruction Memory
  logic [6:0] FETCH2_OPCODE; // Instruction Operation Code
  logic FETCH2_IS_A_BRANCH_INSTRUCTION; // Is the FETCH Instruction a Branch type? (0 no, 1 yes)
  logic FETCH2_IS_A_JAL_INSTRUCTION; // Is the FETCH Instruction a JAL? If so just always take no need to guess
  logic FETCH2_PREDICTED_BRANCH_TAKEN; // Store the Magical Almighty Branch Predictor's prediction
  logic [GSHARE_HISTORY_BITS-1:0] FETCH2_GSHARE_INDEX; // Index for the Branch History Table

  assign FETCH2_OPCODE = FETCH2_INSTRUCTION[6:0]; // Assign FETCH Instruction's opcode
  assign FETCH2_IS_A_BRANCH_INSTRUCTION = (FETCH2_OPCODE == OPC_BRANCH); // If opcode is the same as B-type then its a branch
  assign FETCH2_IS_A_JAL_INSTRUCTION = (FETCH2_OPCODE == OPC_JAL); // If opcode is the same as JAL then its a JAL

  // Precompute Branch and JAL Immediates for Branch Prediction Addressing (reduces the critical path, the target is ready before Decode):
  logic [63:0] FETCH2_BRANCH_IMMEDIATE; // Full sign extended Branch Immediate
  logic [63:0] FETCH2_JAL_IMMEDIATE; // Full sign extended Jump Immediate
  logic [63:0] FETCH2_IMMEDIATE; // Select Immediate based on whether a Branch or Jump occurs
  logic [63:0] FETCH2_PC_TARGET; // Target Address = Instruction Memory's Response Program Counter + Associated Immediate
  assign FETCH2_BRANCH_IMMEDIATE = {{51{FETCH2_INSTRUCTION[31]}}, FETCH2_INSTRUCTION[31], FETCH2_INSTRUCTION[7], FETCH2_INSTRUCTION[30:25], FETCH2_INSTRUCTION[11:8], 1'b0}; // B-type uses Immediate bits 31, 7, 30-25, 11-8 and the 0th bit
  assign FETCH2_JAL_IMMEDIATE = {{43{FETCH2_INSTRUCTION[31]}}, FETCH2_INSTRUCTION[31], FETCH2_INSTRUCTION[19:12], FETCH2_INSTRUCTION[20], FETCH2_INSTRUCTION[30:21], 1'b0}; // J-type uses Immediate bits 31, 19-12, 20, 30-21, and the 0th bit
  assign FETCH2_IMMEDIATE = FETCH2_IS_A_JAL_INSTRUCTION ? FETCH2_JAL_IMMEDIATE : FETCH2_BRANCH_IMMEDIATE;
  assign FETCH2_PC_TARGET = FETCH2_PC + FETCH2_IMMEDIATE; // Compute the Target Address to use

  // Target will either become the address that will get branched or jumped to, or will continue like normal adding 4 each time
  logic FETCH2_BRANCHED; // A branch the predictor says is taken
  logic FETCH2_BRANCH_OFF_OR_CONTINUE; // If a branch or jump is predicted use the calculated new address (and squash the instruction fetched behind it)
  logic [63:0] FETCH2_PREDICTED_NEXT_PC; // The next Program Counter: either the targeted address or Program Counter + 4
  assign FETCH2_BRANCHED = FETCH2_IS_A_BRANCH_INSTRUCTION && FETCH2_PREDICTED_BRANCH_TAKEN;
  assign FETCH2_BRANCH_OFF_OR_CONTINUE = FETCH2_VALID && (FETCH2_BRANCHED || FETCH2_IS_A_JAL_INSTRUCTION);
  assign FETCH2_PREDICTED_NEXT_PC = FETCH2_BRANCH_OFF_OR_CONTINUE ? FETCH2_PC_TARGET : FETCH1_PC_ADD_4;

  GSharePredictor #(
    .HISTORY_BITS (GSHARE_HISTORY_BITS)
  ) gshare_branch_predictor (
    .clk (clk),
    .reset (reset),
    .ENABLE (BRANCH_PREDICTION_ENABLE),
    .FETCH_PC (FETCH1_PC),
    .FETCH_PREDICTED_TAKEN (FETCH1_PREDICTED_BRANCH_TAKEN),
    .FETCH_PREDICTION_INDEX (FETCH1_GSHARE_INDEX),
    .GLOBAL_HISTORY (GLOBAL_HISTORY),
    .SPECULATIVE_UPDATE (!FREEZE && ADVANCE_FRONT_END && FETCH2_VALID && FETCH2_IS_A_BRANCH_INSTRUCTION), // Fetch 2 branch moving to Decode
    .SPECULATIVE_TAKEN (FETCH2_PREDICTED_BRANCH_TAKEN),
    .UPDATE_PREDICTION (!FREEZE && EXECUTE_VALID && EXECUTE_UPDATE_BRANCH_PREDICTOR),
    .UPDATE_PREDICTION_INDEX (EXECUTE_GSHARE_INDEX),
    .ACTUAL_BRANCH_TAKEN (EXECUTE_BRANCH_WAS_ACTUALLY_TAKEN),
    .RESTORE_HISTORY (!FREEZE && FLUSH_FETCH1_FETCH2_DECODE), // Main idea here is to make sure the Global History Register stores only what actually happens
    .RESTORE_HISTORY_VALUE (EXECUTE_RESTORED_GLOBAL_HISTORY)
  );

  // ========== Decode Stage Signals: ==========
  logic [63:0] DECODE_PC; // Program Counter at Decode
  logic [31:0] DECODE_INSTRUCTION; // Instruction at Decode
  logic DECODE_VALID;
  logic DECODE_PREDICTED_BRANCH_TAKEN;
  logic [GSHARE_HISTORY_BITS-1:0] DECODE_GSHARE_INDEX;
  logic [GSHARE_HISTORY_BITS-1:0] DECODE_GLOBAL_HISTORY_CHECKPOINT;
  logic [63:0] DECODE_PC_TARGET; // Branch / JAL target precomputed in Fetch 2
  logic [4:0] DECODE_REGISTER1_ADDRESS; // register file read port 1 (rs1)
  logic [4:0] DECODE_REGISTER2_ADDRESS; // register file read port 2 (rs2)
  logic [4:0] DECODE_DESTINATION_REGISTER_ADDRESS; // destination register (rd)
  logic [2:0] DECODE_FUNCT3; // funct3
  logic [11:0] DECODE_CSR_ADDRESS; // Control Status Register Target
  logic [63:0] DECODE_REGISTER_FILE_REGISTER1_DATA; // Regfile's Register 1 information
  logic [63:0] DECODE_REGISTER_FILE_REGISTER2_DATA; // Regfile's Register 2 information
  logic [63:0] DECODE_FORWARDED_REGISTER1_DATA; // Regfile's Register 1 information after forwarding (Data Hazard: Decode to Execute Forwarding)
  logic [63:0] DECODE_FORWARDED_REGISTER2_DATA; // Regfile's Register 2 information after forwarding (Data Hazard: Decode to Execute Forwarding)
  logic [63:0] DECODE_IMMEDIATE; // Decode's Immediate Value
  logic DECODE_REGISTER_WRITE_ENABLE; // Does the instruction write to destination register? (0 is read, 1 is write)
  logic DECODE_MEMORY_READ_ENABLE; // Does memory need to be read? (Basically is this a load, 0 is no, 1 is yes)
  logic DECODE_MEMORY_WRITE_ENABLE; // Does memory need to be written to? (Basically is this a store, 0 is no, 1 is yes)
  logic DECODE_CSR_WRITE_ENABLE; // Does Control Status Register need to be written to? (0 is no, 1 is yes)
  logic DECODE_CSR_WRITE_USING_IMMEDIATE; // Does Control Status Register need to be written to with immediate? (0 is no, 1 is yes)
  logic DECODE_ALU_INPUT_A_IS_PC; // ALU Input A is 0: Register 1 or 1: Program Counter
  logic DECODE_ALU_INPUT_B_IS_IMMEDIATE; // ALU Input B is 0: Register 2 or 1: Immediate Value
  logic DECODE_ALU_IS_WORD_OPERATION; // RV64 32-bit Word operation
  logic DECODE_IS_A_MULTIPLY_DIVIDE_INSTRUCTION; // RV64M instruction (result from the Multiply Divide Unit)
  logic DECODE_IS_A_BRANCH_INSTRUCTION; // Continue preserving whether or not the instruction is a B type
  logic DECODE_IS_A_JAL_INSTRUCTION; // Continue preserving whether or not the instruction is a JAL
  logic DECODE_IS_A_JALR_INSTRUCTION; // Determine whether or not the instruction is a JALR
  immediate_type_select_t DECODE_IMMEDIATE_TYPE_SELECT; // Immediate Type will consist of these: | I | S | B | U | J | Z |
  writeback_select_t DECODE_WRITEBACK_SELECT; // 4 Possibilities to Writeback: | ALU Result | Load Information | PC ADD 4 | CSR |
  alu_op_t DECODE_ALU_OPERATION; // Determine which ALU operation is required

  assign DECODE_REGISTER1_ADDRESS = DECODE_INSTRUCTION[19:15]; // Register 1 Address (rs1) is always the 5 bits at 19-15
  assign DECODE_REGISTER2_ADDRESS = DECODE_INSTRUCTION[24:20]; // Register 2 Address (rs2) is always the 5 bits at 24-20
  assign DECODE_DESTINATION_REGISTER_ADDRESS = DECODE_INSTRUCTION[11:7]; // Destination Register's Address (rd) is always the 5 bits at 11-7
  assign DECODE_FUNCT3 = DECODE_INSTRUCTION[14:12]; // Funct3 is always the 3 bits at 14-12
  assign DECODE_CSR_ADDRESS = DECODE_INSTRUCTION[31:20]; // Control Status Register Address (CSR) is always the top 12 bits at 31-20

  // Forwarding Signals from Execute:
  logic [4:0] EXECUTE_DESTINATION_REGISTER_ADDRESS; // Execute Stage Instruction's destination register address (rd)
  logic EXECUTE_REGISTER_WRITE_ENABLE; // Execute Stage's Read or Write Signal
  logic EXECUTE_MEMORY_READ_ENABLE; // Execute Stage's Memory Read or not (Is a load occurring in Execute? if so load stall is necessary)
  logic [63:0] EXECUTE_FORWARD_DATA; // Execute Stage's Data to Forward | ALU Result | PC ADD 4 | CSR |

  // Forwarding Signals from Memory:
  logic [4:0] MEMORY_DESTINATION_REGISTER_ADDRESS; // Memory's destination register address (rd)
  logic MEMORY_REGISTER_WRITE_ENABLE; // Memory's Read or Write Signal
  logic MEMORY_VALID; // Memory's instruction is valid right?
  logic [63:0] MEMORY_FORWARD_DATA; // Memory's 4 Possibilities to Forward back: | ALU Result | Load Information | PC ADD 4 | CSR |

  // Forwarding Signals from Writeback:
  logic [4:0] WRITEBACK_DESTINATION_REGISTER_ADDRESS; // Writeback Stage's destination register address (rd)
  logic WRITEBACK_REGISTER_WRITE_ENABLE; // Writeback Stage's Read or Write Signal
  logic WRITEBACK_VALID; // Writeback Stage's instruction is valid right?
  logic [63:0] WRITEBACK_DATA; // Final writeback data driving Register File's write data this cycle

  RegisterFile register_file ( // Synchronous Writes, Asynchronous Reads
    .clk (clk),
    .reset (reset),
    .REGISTER_WRITE_ENABLE (!HALTED && WRITEBACK_VALID && WRITEBACK_REGISTER_WRITE_ENABLE),
    .READ_ADDRESS1 (DECODE_REGISTER1_ADDRESS),
    .READ_ADDRESS2 (DECODE_REGISTER2_ADDRESS),
    .WRITE_ADDRESS (WRITEBACK_DESTINATION_REGISTER_ADDRESS),
    .WRITE_DATA (WRITEBACK_DATA),
    .READ_DATA1 (DECODE_REGISTER_FILE_REGISTER1_DATA),
    .READ_DATA2 (DECODE_REGISTER_FILE_REGISTER2_DATA),
    .DEBUG_READ_ADDRESS (DEBUG_REGISTER_ADDRESS),
    .DEBUG_READ_DATA (DEBUG_REGISTER_DATA)
  );

  // Decode Stage Register 1 Data Hazard Forwarding (Data Hazard Priority Logic: x0 Address > Execute (no loading occurring) > Memory > Writeback > Register File):
  always_comb begin
    if (DECODE_REGISTER1_ADDRESS == 5'd0) begin // If the Address is x0 then all the data is just zero
      DECODE_FORWARDED_REGISTER1_DATA = 64'd0; // x0 reads as all 0s
    end else if (EXECUTE_VALID && EXECUTE_REGISTER_WRITE_ENABLE && !EXECUTE_MEMORY_READ_ENABLE && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0) && (EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS)) begin // Execute Stage is Valid and Register Writing is Enabled and No Loading is happening, and RS1 is the same as Destination Address
      DECODE_FORWARDED_REGISTER1_DATA = EXECUTE_FORWARD_DATA; // Data Hazard: Forward Execute Data to Decode Stage (Loads are not considered will use a load stall)
    end else if (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE && (MEMORY_DESTINATION_REGISTER_ADDRESS != 5'd0) && (MEMORY_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS)) begin // Memory Stage is Valid and Register Writing is Enabled and RS1 is the same as Destination Address
      DECODE_FORWARDED_REGISTER1_DATA = MEMORY_FORWARD_DATA; // Data Hazard: Forward Memory Data
    end else if (WRITEBACK_VALID && WRITEBACK_REGISTER_WRITE_ENABLE && (WRITEBACK_DESTINATION_REGISTER_ADDRESS != 5'd0) && (WRITEBACK_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS)) begin // Writeback Stage is Valid and Register Writing is Enabled, and RS1 is the same as Destination Address
      DECODE_FORWARDED_REGISTER1_DATA = WRITEBACK_DATA; // Data Hazard: Forward Writeback Data
    end else begin
      DECODE_FORWARDED_REGISTER1_DATA = DECODE_REGISTER_FILE_REGISTER1_DATA; // No hazard is present, the register file data is okay to use
    end
  end

  // Decode Stage Register 2 Data Hazard Forwarding (Data Hazard Priority Logic: x0 Address > Execute (no loading occurring) > Memory > Writeback > Register File):
  always_comb begin
    if (DECODE_REGISTER2_ADDRESS == 5'd0) begin // If the Address is x0 then all the data is just zero
      DECODE_FORWARDED_REGISTER2_DATA = 64'd0; // x0 reads as all 0s
    end else if (EXECUTE_VALID && EXECUTE_REGISTER_WRITE_ENABLE && !EXECUTE_MEMORY_READ_ENABLE && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0) && (EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS)) begin // Execute Stage is Valid and Register Writing is Enabled and No Loading is happening, and RS2 is the same as Destination Address
      DECODE_FORWARDED_REGISTER2_DATA = EXECUTE_FORWARD_DATA; // Data Hazard: Forward Execute Data to Decode Stage (Loads are not considered will use a load stall)
    end else if (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE && (MEMORY_DESTINATION_REGISTER_ADDRESS != 5'd0) && (MEMORY_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS)) begin // Memory Stage is Valid and Register Writing is Enabled and RS2 is the same as Destination Address
      DECODE_FORWARDED_REGISTER2_DATA = MEMORY_FORWARD_DATA; // Data Hazard: Forward Memory Data
    end else if (WRITEBACK_VALID && WRITEBACK_REGISTER_WRITE_ENABLE && (WRITEBACK_DESTINATION_REGISTER_ADDRESS != 5'd0) && (WRITEBACK_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS)) begin // Writeback Stage is Valid and Register Writing is Enabled, and RS2 is the same as Destination Address
      DECODE_FORWARDED_REGISTER2_DATA = WRITEBACK_DATA; // Data Hazard: Forward Writeback Data
    end else begin
      DECODE_FORWARDED_REGISTER2_DATA = DECODE_REGISTER_FILE_REGISTER2_DATA; // No hazard is present, the register file data is okay to use
    end
  end

  logic LOAD_HAZARD_REGISTER1; // Determine if Decode is reading register1 as Execute Load is writing to same place
  logic LOAD_HAZARD_REGISTER2; // Determine if Decode is reading register2 as Execute Load is writing to same place

  // If the Execute Destination Address during a Load is the same as the Decode's register 1 that is being read a load hazard exists
  // (the rs1/rs2 FIELDS are compared even when an instruction does not use them: simple and safe, sometimes stalls for nothing, see Lab 5)
  assign LOAD_HAZARD_REGISTER1 = EXECUTE_VALID && EXECUTE_MEMORY_READ_ENABLE && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0) && (EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS);
  // If the Execute Destination Address during a Load is the same as the Decode's register 2 that is being read a load hazard exists
  assign LOAD_HAZARD_REGISTER2 = EXECUTE_VALID && EXECUTE_MEMORY_READ_ENABLE && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0) && (EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS);
  assign LOAD_STALL = DECODE_VALID && (LOAD_HAZARD_REGISTER1 || LOAD_HAZARD_REGISTER2); // Load Hazard Exists and thus enable the load stall

  ControlUnit control_unit (
    .INSTRUCTION (DECODE_INSTRUCTION),
    .REGISTER_WRITE_ENABLE (DECODE_REGISTER_WRITE_ENABLE),
    .MEMORY_READ_ENABLE (DECODE_MEMORY_READ_ENABLE),
    .MEMORY_WRITE_ENABLE (DECODE_MEMORY_WRITE_ENABLE),
    .CSR_WRITE_USING_IMMEDIATE (DECODE_CSR_WRITE_USING_IMMEDIATE),
    .CSR_WRITE_ENABLE (DECODE_CSR_WRITE_ENABLE),
    .ALU_INPUT_A_IS_PC (DECODE_ALU_INPUT_A_IS_PC),
    .ALU_INPUT_B_IS_IMMEDIATE (DECODE_ALU_INPUT_B_IS_IMMEDIATE),
    .ALU_IS_WORD_OPERATION (DECODE_ALU_IS_WORD_OPERATION),
    .IS_A_MULTIPLY_DIVIDE_INSTRUCTION (DECODE_IS_A_MULTIPLY_DIVIDE_INSTRUCTION),
    .IS_A_BRANCH_INSTRUCTION (DECODE_IS_A_BRANCH_INSTRUCTION),
    .IS_A_JAL_INSTRUCTION (DECODE_IS_A_JAL_INSTRUCTION),
    .IS_A_JALR_INSTRUCTION (DECODE_IS_A_JALR_INSTRUCTION),
    .IMMEDIATE_TYPE_SELECT (DECODE_IMMEDIATE_TYPE_SELECT),
    .WRITEBACK_SELECT (DECODE_WRITEBACK_SELECT),
    .ALU_OPERATION (DECODE_ALU_OPERATION)
  );

  ImmediateGenerator immediate_generator (
    .INSTRUCTION (DECODE_INSTRUCTION),
    .IMMEDIATE_TYPE_SELECT (DECODE_IMMEDIATE_TYPE_SELECT),
    .IMMEDIATE (DECODE_IMMEDIATE)
  );

  // ========== Execute Stage Signals: ==========
  logic [63:0] EXECUTE_PC; // Program Counter at the Execute Stage
  logic [31:0] EXECUTE_INSTRUCTION; // Instruction at the Execute Stage
  logic [63:0] EXECUTE_REGISTER1_DATA; // Register1 Data at the Execute Stage (Forwarding already resolved)
  logic [63:0] EXECUTE_REGISTER2_DATA; // Register2 Data at the Execute Stage (Forwarding already resolved)
  logic [63:0] EXECUTE_IMMEDIATE; // Immediate at the Execute Stage
  logic [2:0] EXECUTE_FUNCT3; // Funct3 at the Execute Stage used for the Branch Comparator and Loading/Storing Control
  logic [11:0] EXECUTE_CSR_ADDRESS; // Control Status Register at the Execute Stage
  logic EXECUTE_MEMORY_WRITE_ENABLE; // Determine if this is a store at the Execute Stage
  logic EXECUTE_CSR_WRITE_ENABLE; // Determine if the Control Status Register needs to be written to at the Execute Stage
  logic EXECUTE_CSR_WRITE_USING_IMMEDIATE; // Determine if the Control Status Register needs to be written to (with immediate) at the Execute Stage
  logic EXECUTE_ALU_INPUT_A_IS_PC; // ALU A Input at the Execute Stage
  logic EXECUTE_ALU_INPUT_B_IS_IMMEDIATE; // ALU B Input at the Execute Stage select
  logic EXECUTE_ALU_IS_WORD_OPERATION; // RV64 Word operation at the Execute Stage
  logic EXECUTE_IS_A_MULTIPLY_DIVIDE_INSTRUCTION; // RV64M instruction at the Execute Stage
  logic EXECUTE_IS_A_JAL_INSTRUCTION; // Is JAL Instruction? at the Execute Stage
  logic EXECUTE_IS_A_JALR_INSTRUCTION; // Is JALR Instruction? at the Execute Stage
  logic EXECUTE_PREDICTED_BRANCH_TAKEN; // Store Fetch prediction at the Execute Stage
  logic [63:0] EXECUTE_PC_TARGET; // Branch / JAL target precomputed in Fetch 2
  writeback_select_t EXECUTE_WRITEBACK_SELECT; // Writeback logic in Execute Stage
  alu_op_t EXECUTE_ALU_OPERATION; // ALU operation in the Execute Stage

  logic [63:0] EXECUTE_PC_ADD_4; // Hold Next Program Counter at the Execute Stage
  logic [63:0] EXECUTE_ALU_INPUT_A; // ALU input A is either Register 1 Data or the Program Counter at Execute Stage
  logic [63:0] EXECUTE_ALU_INPUT_B; // ALU input B is either Register 2 or the Immediate value at the Execute Stage
  logic [63:0] EXECUTE_ALU_OUTPUT; // Raw ALU Output
  logic [63:0] EXECUTE_MULTIPLY_DIVIDE_OUTPUT; // Raw Multiply Divide Unit Output
  logic [63:0] EXECUTE_ALU_RESULT; // Result at the Execute Stage (ALU or Multiply Divide Unit)
  logic [63:0] EXECUTE_JALR_TARGET; // JALR Target Address is Register1 + Immediate and half word aligned by clearing the LSB
  logic EXECUTE_BRANCH_TAKEN; // Branch Comparator Result at Execute Stage
  logic EXECUTE_FLUSH; // Control Hazard: Flush when Branch Prediction is wrong (Flush Fetch 1, Fetch 2 and Decode)
  logic [63:0] EXECUTE_ADJUST_NEXT_PC; // Have the good and valid Program Counter in case Flush occurs
  logic [63:0] EXECUTE_CSR_READ_DATA; // Hold Control Status Register Read Value at Execute Stage
  logic [63:0] EXECUTE_CSR_WRITE_DATA; // Write Value to write to Control Status Register
  logic [7:0] EXECUTE_STORE_MASK; // Hold Store Byte Mask at the Execute Stage
  logic [63:0] EXECUTE_STORE_DATA; // Hold Stored Data at the Execute Stage (forced alignment in Store Control)
  logic EXECUTE_WRITES_TOHOST; // This instruction writes the TOHOST CSR (the program is finishing)

  assign EXECUTE_PC_ADD_4 = EXECUTE_PC + 64'd4; // Look at Next PC from Execute Stage perspective
  assign EXECUTE_ALU_INPUT_A = EXECUTE_ALU_INPUT_A_IS_PC ? EXECUTE_PC : EXECUTE_REGISTER1_DATA; // Determine input A to ALU
  assign EXECUTE_ALU_INPUT_B = EXECUTE_ALU_INPUT_B_IS_IMMEDIATE ? EXECUTE_IMMEDIATE : EXECUTE_REGISTER2_DATA; // Determine input B to ALU

  ALU alu (
    .A (EXECUTE_ALU_INPUT_A),
    .B (EXECUTE_ALU_INPUT_B),
    .ALUop (EXECUTE_ALU_OPERATION),
    .ALU_IS_WORD_OPERATION (EXECUTE_ALU_IS_WORD_OPERATION),
    .ALUOut (EXECUTE_ALU_OUTPUT)
  );

  MultiplyDivideUnit multiply_divide_unit (
    .A (EXECUTE_REGISTER1_DATA),
    .B (EXECUTE_REGISTER2_DATA),
    .MULTIPLY_DIVIDE_OPERATION (EXECUTE_ALU_OPERATION),
    .IS_WORD_OPERATION (EXECUTE_ALU_IS_WORD_OPERATION),
    .MULTIPLY_DIVIDE_RESULT (EXECUTE_MULTIPLY_DIVIDE_OUTPUT)
  );

  assign EXECUTE_ALU_RESULT = EXECUTE_IS_A_MULTIPLY_DIVIDE_INSTRUCTION ? EXECUTE_MULTIPLY_DIVIDE_OUTPUT : EXECUTE_ALU_OUTPUT;
  assign EXECUTE_JALR_TARGET = {EXECUTE_ALU_OUTPUT[63:1], 1'b0}; // JALR requires even addresses (Least Significant Bit forced to 0 to maintain halfword alignment)

  BranchComparator branch_comparator (
    .A (EXECUTE_REGISTER1_DATA),
    .B (EXECUTE_REGISTER2_DATA),
    .BRANCH_FUNCT3 (EXECUTE_FUNCT3),
    .BRANCH_TAKEN (EXECUTE_BRANCH_TAKEN)
  );

  BranchControl branch_control (
    .IS_A_BRANCH_INSTRUCTION (EXECUTE_IS_A_BRANCH_INSTRUCTION),
    .IS_A_JAL_INSTRUCTION (EXECUTE_IS_A_JAL_INSTRUCTION),
    .IS_A_JALR_INSTRUCTION (EXECUTE_IS_A_JALR_INSTRUCTION),
    .ACTUALLY_TAKEN_BRANCH (EXECUTE_BRANCH_TAKEN),
    .PREDICTED_BRANCH_TAKEN (EXECUTE_PREDICTED_BRANCH_TAKEN),
    .PC_ADD_4 (EXECUTE_PC_ADD_4),
    .BRANCH_TARGET (EXECUTE_PC_TARGET),
    .JALR_TARGET (EXECUTE_JALR_TARGET),
    .BRANCH_WAS_ACTUALLY_TAKEN (EXECUTE_BRANCH_WAS_ACTUALLY_TAKEN),
    .PREDICTION_WAS_WRONG (EXECUTE_PREDICTION_WAS_WRONG),
    .FLUSH (EXECUTE_FLUSH),
    .UPDATE_BRANCH_PREDICTOR (EXECUTE_UPDATE_BRANCH_PREDICTOR),
    .ADJUST_NEXT_PC (EXECUTE_ADJUST_NEXT_PC)
  );

  assign FLUSH_FETCH1_FETCH2_DECODE = EXECUTE_VALID && EXECUTE_FLUSH; // Control Hazard: Branch Control Required Flush from Misprediction
  assign ADVANCE_FRONT_END = !FLUSH_FETCH1_FETCH2_DECODE && !LOAD_STALL; // The front of the pipeline moves only when nothing is being flushed or stalled

  // Rewind the Global History on a flush: the checkpoint, plus the real direction if the flushing instruction is itself a branch
  assign EXECUTE_RESTORED_GLOBAL_HISTORY = EXECUTE_IS_A_BRANCH_INSTRUCTION ?
      {EXECUTE_GLOBAL_HISTORY_CHECKPOINT[GSHARE_HISTORY_BITS-2:0], EXECUTE_BRANCH_WAS_ACTUALLY_TAKEN} : EXECUTE_GLOBAL_HISTORY_CHECKPOINT;

  StoreControl store_control (
    .STORE_FUNCT3 (EXECUTE_FUNCT3),
    .MEMORY_ADDRESS (EXECUTE_ALU_RESULT),
    .MEMORY_INFO (EXECUTE_REGISTER2_DATA),
    .WRITE_MASK_FOR_STORE (EXECUTE_STORE_MASK),
    .DATA_TO_STORE (EXECUTE_STORE_DATA)
  );

  // Collect Control Status Register Data at the Execute Stage for Memory and Writeback Stage
  assign EXECUTE_CSR_WRITE_DATA = EXECUTE_CSR_WRITE_USING_IMMEDIATE ? {59'd0, EXECUTE_INSTRUCTION[19:15]} : EXECUTE_REGISTER1_DATA;
  assign EXECUTE_WRITES_TOHOST = EXECUTE_CSR_WRITE_ENABLE && (EXECUTE_CSR_ADDRESS == CSR_TOHOST);

  CSRFile control_status_register_file (
    .clk (clk),
    .reset (reset),
    .CSR_WRITE_ENABLE (!FREEZE && EXECUTE_CSR_WRITE_ENABLE && EXECUTE_VALID),
    .CSR_ADDRESS (EXECUTE_CSR_ADDRESS),
    .CSR_OPERATION (EXECUTE_FUNCT3),
    .CSR_WRITE_DATA (EXECUTE_CSR_WRITE_DATA),
    .INSTRUCTION_RETIRED (WRITEBACK_VALID),
    .CSR_READ_DATA (EXECUTE_CSR_READ_DATA),
    .TOHOST (csr)
  );

  // Execute Writeback to Decode Stage MUX
  always_comb begin
    unique case (EXECUTE_WRITEBACK_SELECT)
      WRITEBACK_ALU: EXECUTE_FORWARD_DATA = EXECUTE_ALU_RESULT; // ALU Result
      WRITEBACK_PC_ADD_4: EXECUTE_FORWARD_DATA = EXECUTE_PC_ADD_4; // Program Counter + 4
      WRITEBACK_CSR: EXECUTE_FORWARD_DATA = EXECUTE_CSR_READ_DATA; // Control Status Register Data
      WRITEBACK_MEMORY: EXECUTE_FORWARD_DATA = 64'd0; // Load is not covered instead a load stall is used
      default: EXECUTE_FORWARD_DATA = EXECUTE_ALU_RESULT; // In general the writeback would use the result from the ALU
    endcase
  end

  assign dcache_addr = EXECUTE_ALU_RESULT; // Feed Data Memory the calculated Target Address
  assign dcache_din = EXECUTE_STORE_DATA; // Feed Data Memory Data from Store Instruction
  assign dcache_we = (!FREEZE && EXECUTE_VALID && EXECUTE_MEMORY_WRITE_ENABLE) ? EXECUTE_STORE_MASK : 8'b0000_0000; // Place Write Mask If the Execute Stage is Valid and a Write

  // ========== Memory Stage Signals: ==========
  logic [63:0] MEMORY_PC; // Keep track of Program Counter at the Memory Stage
  logic [2:0] MEMORY_FUNCT3; // Keep track of the funct3 at the Memory Stage (For Load Alignments)
  logic [63:0] MEMORY_ALU_RESULT; // Keep track of the ALU Result at the Memory Stage
  logic [63:0] MEMORY_PC_ADD_4; // Keep track of the next program counter address at the Memory Stage
  logic [63:0] MEMORY_CSR_READ_DATA; // Control Status Register value read in Execute
  writeback_select_t MEMORY_WRITEBACK_SELECT; // Determine what value from writeback mux to give
  logic [63:0] MEMORY_LOAD_DATA; // Aligned Load Result that will be given by Load Control Unit
  logic [63:0] MEMORY_DATA_CACHE_DATA; // Data Memory's doubleword, captured at the end of Execute (like an SRAM output register)
  logic MEMORY_WRITES_TOHOST; // Program finishing instruction in the Memory Stage
  logic MEMORY_REGISTER_WRITE_ENABLE_OUT; // Write enable after the Writeback MUX (same value, kept for the WriteControl interface)

  LoadControl load_control (
    .LOAD_FUNCT3 (MEMORY_FUNCT3), // Determines Load Alignment
    .MEMORY_ADDRESS (MEMORY_ALU_RESULT), // Address to Determine byte, halfword, word, doubleword lane
    .MEMORY_INFO (MEMORY_DATA_CACHE_DATA), // The 64 data bits from the Data Memory
    .DATA_TO_LOAD (MEMORY_LOAD_DATA)
  );

  // Memory Forwarding MUX (the same value is written back one stage later)
  WriteControl write_control (
    .REGISTER_WRITE_ENABLE_INPUT (MEMORY_REGISTER_WRITE_ENABLE),
    .WRITEBACK_SELECT (MEMORY_WRITEBACK_SELECT),
    .ALU_RESULT (MEMORY_ALU_RESULT),
    .MEMORY_DATA (MEMORY_LOAD_DATA),
    .PC_ADD_4 (MEMORY_PC_ADD_4),
    .CSR_DATA (MEMORY_CSR_READ_DATA),
    .REGISTER_WRITE_ENABLE_OUTPUT (MEMORY_REGISTER_WRITE_ENABLE_OUT),
    .WRITEBACK_DATA (MEMORY_FORWARD_DATA)
  );

  // ========== Writeback Stage Signals: ==========
  logic [63:0] WRITEBACK_PC; // Program Counter of the instruction finishing (trace only)
  logic WRITEBACK_WRITES_TOHOST; // The program finishing instruction reached Writeback
  assign HALT_NOW = !HALTED && WRITEBACK_VALID && WRITEBACK_WRITES_TOHOST && (csr != 64'd0);
  assign FREEZE = HALTED || HALT_NOW;

  // ========== The Clock Edge: every pipeline register captures its stage's result at once ==========
  always_ff @(posedge clk) begin
    if (reset) begin
       // ========== Fetch 1 ==========
      FETCH1_PC <= PC_RESET;
      HALTED <= 1'b0;
      // ========== Fetch 2 ==========
      FETCH2_VALID <= 1'b0;
      FETCH2_PC <= 64'd0;
      FETCH2_INSTRUCTION <= INSTR_NOP;
      FETCH2_PREDICTED_BRANCH_TAKEN <= 1'b0;
      FETCH2_GSHARE_INDEX <= '0;
       // ========== Decode ==========
      DECODE_VALID <= 1'b0;
      DECODE_PC <= 64'd0;
      DECODE_INSTRUCTION <= INSTR_NOP;
      DECODE_PREDICTED_BRANCH_TAKEN <= 1'b0;
      DECODE_GSHARE_INDEX <= '0;
      DECODE_GLOBAL_HISTORY_CHECKPOINT <= '0;
      DECODE_PC_TARGET <= 64'd0;
       // ========== Execute ==========
      EXECUTE_VALID <= 1'b0;
      EXECUTE_PC <= 64'd0;
      EXECUTE_INSTRUCTION <= INSTR_NOP;
      EXECUTE_REGISTER1_DATA <= 64'd0;
      EXECUTE_REGISTER2_DATA <= 64'd0;
      EXECUTE_IMMEDIATE <= 64'd0;
      EXECUTE_DESTINATION_REGISTER_ADDRESS <= 5'd0;
      EXECUTE_FUNCT3 <= 3'd0;
      EXECUTE_CSR_ADDRESS <= 12'd0;
      EXECUTE_REGISTER_WRITE_ENABLE <= 1'b0;
      EXECUTE_MEMORY_READ_ENABLE <= 1'b0;
      EXECUTE_MEMORY_WRITE_ENABLE <= 1'b0;
      EXECUTE_CSR_WRITE_ENABLE <= 1'b0;
      EXECUTE_CSR_WRITE_USING_IMMEDIATE <= 1'b0;
      EXECUTE_ALU_INPUT_A_IS_PC <= 1'b0;
      EXECUTE_ALU_INPUT_B_IS_IMMEDIATE <= 1'b0;
      EXECUTE_ALU_IS_WORD_OPERATION <= 1'b0;
      EXECUTE_IS_A_MULTIPLY_DIVIDE_INSTRUCTION <= 1'b0;
      EXECUTE_IS_A_BRANCH_INSTRUCTION <= 1'b0;
      EXECUTE_IS_A_JAL_INSTRUCTION <= 1'b0;
      EXECUTE_IS_A_JALR_INSTRUCTION <= 1'b0;
      EXECUTE_PREDICTED_BRANCH_TAKEN <= 1'b0;
      EXECUTE_GSHARE_INDEX <= '0;
      EXECUTE_GLOBAL_HISTORY_CHECKPOINT <= '0;
      EXECUTE_WRITEBACK_SELECT <= WRITEBACK_ALU;
      EXECUTE_ALU_OPERATION <= ALU_XXX;
      EXECUTE_PC_TARGET <= 64'd0;
      // ========== Memory ==========
      MEMORY_VALID <= 1'b0;
      MEMORY_PC <= 64'd0;
      MEMORY_DESTINATION_REGISTER_ADDRESS <= 5'd0;
      MEMORY_FUNCT3 <= 3'd0;
      MEMORY_ALU_RESULT <= 64'd0;
      MEMORY_PC_ADD_4 <= 64'd0;
      MEMORY_CSR_READ_DATA <= 64'd0;
      MEMORY_REGISTER_WRITE_ENABLE <= 1'b0;
      MEMORY_WRITEBACK_SELECT <= WRITEBACK_ALU;
      MEMORY_DATA_CACHE_DATA <= 64'd0;
      MEMORY_WRITES_TOHOST <= 1'b0;
       // ========== Writeback ==========
      WRITEBACK_VALID <= 1'b0;
      WRITEBACK_PC <= 64'd0;
      WRITEBACK_DESTINATION_REGISTER_ADDRESS <= 5'd0;
      WRITEBACK_REGISTER_WRITE_ENABLE <= 1'b0;
      WRITEBACK_DATA <= 64'd0;
      WRITEBACK_WRITES_TOHOST <= 1'b0;
    end
    else if (HALTED) begin
      // Program finished: freeze the whole pipeline so the testbench can read the final registers
    end
    else if (HALT_NOW) begin
      HALTED <= 1'b1; // The TOHOST write has retired: every older instruction has written back too
    end
    else begin
      // Advance Execute to Memory (always: the Execute instruction is never flushed, even when it causes a flush)
      MEMORY_VALID <= EXECUTE_VALID;
      MEMORY_PC <= EXECUTE_PC; // Update Memory Program Counter
      MEMORY_DESTINATION_REGISTER_ADDRESS <= EXECUTE_DESTINATION_REGISTER_ADDRESS; // Update Memory Destination Register Address
      MEMORY_FUNCT3 <= EXECUTE_FUNCT3; // Update Memory Funct3
      MEMORY_ALU_RESULT <= EXECUTE_ALU_RESULT; // Update Memory ALU Result
      MEMORY_PC_ADD_4 <= EXECUTE_PC_ADD_4; // Update Memory Program Counter + 4
      MEMORY_CSR_READ_DATA <= EXECUTE_CSR_READ_DATA; // Update Control Status Register Read Data
      MEMORY_REGISTER_WRITE_ENABLE <= EXECUTE_REGISTER_WRITE_ENABLE; // Update Register Write Enable Signal
      MEMORY_WRITEBACK_SELECT <= EXECUTE_WRITEBACK_SELECT; // Update Memory Writeback Select MUX Output Selection
      MEMORY_DATA_CACHE_DATA <= dcache_dout; // Capture Data Memory's response data for Load Control
      MEMORY_WRITES_TOHOST <= EXECUTE_VALID && EXECUTE_WRITES_TOHOST;

      // Advance Memory to Writeback
      WRITEBACK_VALID <= MEMORY_VALID;
      WRITEBACK_PC <= MEMORY_PC;
      WRITEBACK_DESTINATION_REGISTER_ADDRESS <= MEMORY_DESTINATION_REGISTER_ADDRESS;
      WRITEBACK_REGISTER_WRITE_ENABLE <= MEMORY_REGISTER_WRITE_ENABLE_OUT;
      WRITEBACK_DATA <= MEMORY_FORWARD_DATA; // Determined by Memory Stage Writeback MUX
      WRITEBACK_WRITES_TOHOST <= MEMORY_WRITES_TOHOST;

      if (FLUSH_FETCH1_FETCH2_DECODE) begin // Control Hazard: Flush Taken (Misprediction occurred, inject NOP into Execute)
        EXECUTE_VALID <= 1'b0;
        EXECUTE_INSTRUCTION <= INSTR_NOP;
        EXECUTE_REGISTER_WRITE_ENABLE <= 1'b0;
        EXECUTE_MEMORY_READ_ENABLE <= 1'b0;
        EXECUTE_MEMORY_WRITE_ENABLE <= 1'b0;
        EXECUTE_CSR_WRITE_ENABLE <= 1'b0;
        EXECUTE_IS_A_BRANCH_INSTRUCTION <= 1'b0;
        EXECUTE_IS_A_JAL_INSTRUCTION <= 1'b0;
        EXECUTE_IS_A_JALR_INSTRUCTION <= 1'b0;
        // Fetch 2 transition to Decode: the Decode instruction was on the wrong path
        DECODE_VALID <= 1'b0;
        DECODE_INSTRUCTION <= INSTR_NOP;
        // Fetch 1 Transition to Fetch 2 with Program Counter Update for Fetch 1 and Fetch 2 and Decode Flush
        FETCH1_PC <= EXECUTE_ADJUST_NEXT_PC;
        FETCH2_VALID <= 1'b0;
        FETCH2_INSTRUCTION <= INSTR_NOP;
      end
      else if (LOAD_STALL) begin // Load Stall:
        // Fetch 1, Fetch 2, Decode do not update for load hazard stall
        // Advance Execute to No Operation (Decode cannot proceed yet so do not do anything in Execute in the meantime)
        EXECUTE_VALID <= 1'b0;
        EXECUTE_INSTRUCTION <= INSTR_NOP;
        EXECUTE_REGISTER_WRITE_ENABLE <= 1'b0;
        EXECUTE_MEMORY_READ_ENABLE <= 1'b0;
        EXECUTE_MEMORY_WRITE_ENABLE <= 1'b0;
        EXECUTE_CSR_WRITE_ENABLE <= 1'b0;
        EXECUTE_IS_A_BRANCH_INSTRUCTION <= 1'b0;
        EXECUTE_IS_A_JAL_INSTRUCTION <= 1'b0;
        EXECUTE_IS_A_JALR_INSTRUCTION <= 1'b0;
      end
      else begin // No Stall Occurring continue normally
        // Continue updated Execute like Normal
        EXECUTE_VALID <= DECODE_VALID;
        EXECUTE_PC <= DECODE_PC;
        EXECUTE_INSTRUCTION <= DECODE_INSTRUCTION;
        EXECUTE_REGISTER1_DATA <= DECODE_FORWARDED_REGISTER1_DATA;
        EXECUTE_REGISTER2_DATA <= DECODE_FORWARDED_REGISTER2_DATA;
        EXECUTE_IMMEDIATE <= DECODE_IMMEDIATE;
        EXECUTE_DESTINATION_REGISTER_ADDRESS <= DECODE_DESTINATION_REGISTER_ADDRESS;
        EXECUTE_FUNCT3 <= DECODE_FUNCT3;
        EXECUTE_CSR_ADDRESS <= DECODE_CSR_ADDRESS;
        EXECUTE_REGISTER_WRITE_ENABLE <= DECODE_REGISTER_WRITE_ENABLE;
        EXECUTE_MEMORY_READ_ENABLE <= DECODE_MEMORY_READ_ENABLE;
        EXECUTE_MEMORY_WRITE_ENABLE <= DECODE_MEMORY_WRITE_ENABLE;
        EXECUTE_CSR_WRITE_ENABLE <= DECODE_CSR_WRITE_ENABLE;
        EXECUTE_CSR_WRITE_USING_IMMEDIATE <= DECODE_CSR_WRITE_USING_IMMEDIATE;
        EXECUTE_ALU_INPUT_A_IS_PC <= DECODE_ALU_INPUT_A_IS_PC;
        EXECUTE_ALU_INPUT_B_IS_IMMEDIATE <= DECODE_ALU_INPUT_B_IS_IMMEDIATE;
        EXECUTE_ALU_IS_WORD_OPERATION <= DECODE_ALU_IS_WORD_OPERATION;
        EXECUTE_IS_A_MULTIPLY_DIVIDE_INSTRUCTION <= DECODE_IS_A_MULTIPLY_DIVIDE_INSTRUCTION;
        EXECUTE_IS_A_BRANCH_INSTRUCTION <= DECODE_IS_A_BRANCH_INSTRUCTION;
        EXECUTE_IS_A_JAL_INSTRUCTION <= DECODE_IS_A_JAL_INSTRUCTION;
        EXECUTE_IS_A_JALR_INSTRUCTION <= DECODE_IS_A_JALR_INSTRUCTION;
        EXECUTE_PREDICTED_BRANCH_TAKEN <= DECODE_PREDICTED_BRANCH_TAKEN;
        EXECUTE_GSHARE_INDEX <= DECODE_GSHARE_INDEX;
        EXECUTE_GLOBAL_HISTORY_CHECKPOINT <= DECODE_GLOBAL_HISTORY_CHECKPOINT;
        EXECUTE_WRITEBACK_SELECT <= DECODE_WRITEBACK_SELECT;
        EXECUTE_ALU_OPERATION <= DECODE_ALU_OPERATION;
        EXECUTE_PC_TARGET <= DECODE_PC_TARGET;

        // Fetch 2 to Decode
        DECODE_VALID <= FETCH2_VALID;
        DECODE_PC <= FETCH2_PC;
        DECODE_INSTRUCTION <= FETCH2_INSTRUCTION;
        DECODE_PREDICTED_BRANCH_TAKEN <= FETCH2_PREDICTED_BRANCH_TAKEN;
        DECODE_GSHARE_INDEX <= FETCH2_GSHARE_INDEX;
        DECODE_GLOBAL_HISTORY_CHECKPOINT <= GLOBAL_HISTORY; // History BEFORE this instruction's own speculative update
        DECODE_PC_TARGET <= FETCH2_PC_TARGET;

        // Fetch 1 to Fetch 2 (the instruction fetched behind a predicted-taken branch or a JAL is on the wrong path)
        FETCH2_VALID <= !FETCH2_BRANCH_OFF_OR_CONTINUE;
        FETCH2_PC <= FETCH1_PC;
        FETCH2_INSTRUCTION <= icache_dout;
        FETCH2_PREDICTED_BRANCH_TAKEN <= FETCH1_PREDICTED_BRANCH_TAKEN;
        FETCH2_GSHARE_INDEX <= FETCH1_GSHARE_INDEX;
        FETCH1_PC <= FETCH2_PREDICTED_NEXT_PC;
      end
    end
  end

  // ========== Trace (what is in every stage this cycle) ==========
  assign TRACE_VALID = {WRITEBACK_VALID, MEMORY_VALID, EXECUTE_VALID, DECODE_VALID, FETCH2_VALID, 1'b1};
  assign TRACE_FETCH1_PC = FETCH1_PC;
  assign TRACE_FETCH2_PC = FETCH2_PC;
  assign TRACE_DECODE_PC = DECODE_PC;
  assign TRACE_EXECUTE_PC = EXECUTE_PC;
  assign TRACE_MEMORY_PC = MEMORY_PC;
  assign TRACE_WRITEBACK_PC = WRITEBACK_PC;
  assign TRACE_LOAD_STALL = LOAD_STALL && !FLUSH_FETCH1_FETCH2_DECODE;
  assign TRACE_FLUSH = FLUSH_FETCH1_FETCH2_DECODE;
  assign TRACE_REDIRECT = FETCH2_BRANCH_OFF_OR_CONTINUE && ADVANCE_FRONT_END;

  /* verilator lint_off UNUSEDSIGNAL */
  logic UNUSED_SIGNALS; // Kept for waveforms and for symmetry with the original design
  assign UNUSED_SIGNALS = ^{EXECUTE_PREDICTION_WAS_WRONG, EXECUTE_IMMEDIATE[0], MEMORY_PC[0], MEMORY_REGISTER_WRITE_ENABLE_OUT};
  /* verilator lint_on UNUSEDSIGNAL */

endmodule

`default_nettype wire
