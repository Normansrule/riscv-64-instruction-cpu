`default_nettype none

import const_pkg::*;
import opcode_pkg::*;
import immediate_op_pkg::*;
import alu_op_pkg::*;
import writeback_op_pkg::*;

module Riscv151 (
  input  logic        clk,
  input  logic        reset,

  // Memory system ports
  output logic [31:0] dcache_addr,
  output logic [31:0] icache_addr,
  output logic [3:0]  dcache_we, 
  output logic        dcache_re, 
  output logic        icache_re, 
  output logic [31:0] dcache_din,
  input  logic [31:0] dcache_dout, 
  input  logic [31:0] icache_dout, 
  input  logic        stall,
  output logic [31:0] csr
);

  // 6 Stage Datapath: 
  // Fetch1 (GSharePredictor) -> 
  // Fetch2 () -> 
  // Decode (RegisterFile, ControlUnit, ImmediateGenerator) -> 
  // Execute (ALU, BranchComparator, BranchControl, StoreControl, CSRFile) -> 
  // Memory (LoadControl) -> 
  // Writeback ()

  logic LOAD_STALL; // Load Hazard: Instead of a full stall only hold the Fetch and Decode, send a NOP to Execute, and advance the load logic for the Memory and Writeback
  logic CONTINUE_PIPELINE; // If a stall is taking place hold the pipeline (0 is do not advance pipeline, 1 is safe to advance pipeline)
  logic FLUSH_FETCH1_FETCH2_DECODE; // Control Hazard: Fetch1 & Fetch2 & Decode FLUSH for mispredicted branching

  // ========== Fetch 1 Stage Signals: ==========
  logic [31:0] FETCH1_PC; // The Current Program Counter to send to Instruction Cache
  logic [31:0] FETCH1_PC_ADD_4; // Next Current Program Counter determined by next determined target
  assign FETCH1_PC_ADD_4 = FETCH1_PC + 32'd4; // Program Counter + 4
  assign icache_addr = FETCH1_PC; // Provide Instruction Cache with Program Counter Address
  
  logic [31:0] FETCH1_PC_CYCLE_DELAY;
  logic POST_FLUSH; // Mark Cycle that occurs after Flush
  logic POST_BRANCHING; // Mark Cycle that occurs after Branching  
  logic DCACHE_SENT_DATA; // Mark when Dcache has given the data
  logic SAVE_PREVIOUS_FETCH2_BRANCHING;

  logic DCACHE_STALL;
  assign DCACHE_STALL = ((|dcache_we) || dcache_re) && !DCACHE_SENT_DATA; // If Dcache is being accessed and the data has not yet been sent back then stall the pipeline to wait for the data to be sent back (This is for loads and stores to work correctly)
  assign CONTINUE_PIPELINE = !(stall || LOAD_STALL || DCACHE_STALL); // Pipeline is safe is no stall is requested
  assign icache_re = !LOAD_STALL && !DCACHE_STALL; // Read Instruction Cache when there is not a load stall occuring otherwise errors will occur

  // Global Share Branch Prediction Scheme:
  localparam int GSHARE_HISTORY_BITS = 4; // 16 entry branch history table
  logic FETCH1_PREDICTED_BRANCH_TAKEN; // Fetch 1 Stage Prediction from the Almighty Branch Predictor (0 is saying it predicts not taken, 1 is saying it will be taken)
  logic [GSHARE_HISTORY_BITS-1:0] FETCH1_GSHARE_INDEX; // Fetch 1 Branch History Table Index (for 2^n entries with n history bits to index from)

  // Execute Stage Signals Relevant to Gshare predictor: 
  logic EXECUTE_VALID;
  logic EXECUTE_UPDATE_BRANCH_PREDICTOR; // We have the actual Results from the branching scheme tally it at the Branch Predictor History Table
  logic EXECUTE_BRANCH_WAS_ACTUALLY_TAKEN; // Since Branch Comparator is going to be in the Execute Stage this is when it will be known whether the branch was really taken or not
  logic EXECUTE_PREDICTION_WAS_WRONG; // Branch Control looks at Predicted Value and determines if the prediction was right or wrong
  logic [GSHARE_HISTORY_BITS-1:0] EXECUTE_GSHARE_INDEX; // Save the Branch History Table Index that was used for solid book keeping

  // Optimization Place Branch Predictor in Fetch 1
  GSharePredictor #(
    .HISTORY_BITS (GSHARE_HISTORY_BITS)
  ) gshare_branch_predictor (
    .clk (clk),
    .reset (reset),
    .FETCH_PC (FETCH1_PC_CYCLE_DELAY),
    .FETCH_IS_A_BRANCH_INSTRUCTION (1'b1), // Since instruction is not yet known at Fetch 1, just assume it is a branch
    .FETCH_PREDICTED_TAKEN (FETCH1_PREDICTED_BRANCH_TAKEN),
    .FETCH_PREDICTION_INDEX (FETCH1_GSHARE_INDEX),
    .UPDATE_PREDICTION (EXECUTE_VALID && EXECUTE_UPDATE_BRANCH_PREDICTOR),
    .UPDATE_PREDICTION_INDEX (EXECUTE_GSHARE_INDEX),
    .ACTUAL_BRANCH_TAKEN (EXECUTE_BRANCH_WAS_ACTUALLY_TAKEN),
    .UPDATE_MISPREDICTION (EXECUTE_VALID && EXECUTE_PREDICTION_WAS_WRONG) // Main idea here is to make sure the Global History Register stores only what actually happens (corrects any mispredictions)
  );

  // ========== Fetch 2 Stage Signals: ==========
  logic [31:0] FETCH2_PC; // The Program Counter from data provided by Instruction Cache
  logic FETCH2_VALID; // Verify Fetch 2 stage has a real instruction not a flush or redirection from branching or jumping
  logic [31:0] FETCH2_INSTRUCTION; // Full Instruction from icache
  logic [6:0] FETCH2_OPCODE; // Instruction Operation Code
  logic FETCH2_IS_A_BRANCH_INSTRUCTION; // Is the FETCH Instruction a Branch type? (0 no, 1 yes)
  logic FETCH2_IS_A_JAL_INSTRUCTION; // Is the FETCH Instruction a JAL? If so just always take no need to guess this is redudant at this point
  logic [31:0] FETCH2_PC_ADD_4;
  
  //assign FETCH2_INSTRUCTION = icache_dout; // Set the Instruction provided by the Instruction Cache
  assign FETCH2_OPCODE = FETCH2_INSTRUCTION[6:0]; // Assign FETCH Instruction's opcode                    
  assign FETCH2_IS_A_BRANCH_INSTRUCTION = (FETCH2_OPCODE == OPC_BRANCH); // If opcode is the same as B-type then its a branch
  assign FETCH2_IS_A_JAL_INSTRUCTION = (FETCH2_OPCODE == OPC_JAL); // If opcode is the same as JAL then its a JAL
  
  // Precompute Branch and JAL Immediates for Branch Prediction Addressing (presumably reduces critical path if branch predictor is the issue):
  logic [31:0] FETCH2_BRANCH_IMMEDIATE; // Full sign extended Branch Immediate
  logic [31:0] FETCH2_JAL_IMMEDIATE; // Full sign extended Jump Immediate
  logic [31:0] FETCH2_IMMEDIATE; // Select Immediate based on whether a Branch or Jump occurs
  logic [31:0] FETCH2_PC_TARGET; // Target Address = ICache's Response Program Counter + Associated Immediate
  assign FETCH2_BRANCH_IMMEDIATE = {{19{FETCH2_INSTRUCTION[31]}}, FETCH2_INSTRUCTION[31], FETCH2_INSTRUCTION[7], FETCH2_INSTRUCTION[30:25], FETCH2_INSTRUCTION[11:8], 1'b0}; // B-type uses Immediate bits 31, 7, 30-25, 11-8 and the 0th bit: Format as Sign Extended 19 bits then associated 13 bits (31, 7, 30-25, 11-8 bits and the 0 bit being set to 0)
  assign FETCH2_JAL_IMMEDIATE = {{11{FETCH2_INSTRUCTION[31]}}, FETCH2_INSTRUCTION[31], FETCH2_INSTRUCTION[19:12], FETCH2_INSTRUCTION[20], FETCH2_INSTRUCTION[30:21], 1'b0}; // J-type uses Immediate bits 31, 19-12, 20, 30-21, and the 0th bit: Format as Sign Extended 11 bits then associated 21 bits (31, 19-12, 20, 30-21 bits and the 0th bit being set to 0)

  // always_comb begin
  //   if (FETCH2_IS_A_BRANCH_INSTRUCTION) begin     
  //     FETCH2_IMMEDIATE = FETCH2_BRANCH_IMMEDIATE; // Branch uses precomputed branch immediate
  //   end else if (FETCH2_IS_A_JAL_INSTRUCTION) begin
  //     FETCH2_IMMEDIATE = FETCH2_JAL_IMMEDIATE; // Jump uses precomputed branch immediate
  //   end else begin
  //     FETCH2_IMMEDIATE = 32'd0; // the target address will be left alone for the branch prediction part
  //   end                                    
  // end

  assign FETCH2_IMMEDIATE = FETCH2_IS_A_JAL_INSTRUCTION ? FETCH2_JAL_IMMEDIATE : FETCH2_BRANCH_IMMEDIATE;
  assign FETCH2_PC_TARGET = FETCH2_PC + FETCH2_IMMEDIATE; // Compute the Target Address to use

  // Global Branch Predictor Signals in Fetch 2 Stage:
  logic FETCH2_PREDICTED_BRANCH_TAKEN; // Store the Magical Almighty Branch Predictor's prediction
  logic FETCH2_BRANCH_OFF_OR_CONTINUE; // If a branch or jump actually occurs use the calculated new address otherwise continue cycles at current address like normal
  logic [GSHARE_HISTORY_BITS-1:0] FETCH2_GSHARE_INDEX; // Index for the Branch History Table
  logic [31:0] FETCH2_PREDICTED_NEXT_PC; // The next updated Program Counter will either be the targeted address or continue as expected with each cycle being Program Counter + 4
  
  always_ff @(posedge clk) begin
    if (reset) begin
      FETCH1_PC_CYCLE_DELAY <= PC_RESET;
      POST_FLUSH <= 1'b0;
      POST_BRANCHING <= 1'b0;
      DCACHE_SENT_DATA <= 1'b0;
      SAVE_PREVIOUS_FETCH2_BRANCHING <= 1'b0;
    end else begin
      if (!DCACHE_STALL) begin
        FETCH1_PC_CYCLE_DELAY <= FETCH1_PC;
      end
      POST_FLUSH <= FLUSH_FETCH1_FETCH2_DECODE;
      DCACHE_SENT_DATA <= ((|dcache_we) || dcache_re) && !DCACHE_SENT_DATA;
      SAVE_PREVIOUS_FETCH2_BRANCHING <= FETCH2_BRANCH_OFF_OR_CONTINUE;
      POST_BRANCHING <= FETCH2_BRANCH_OFF_OR_CONTINUE && !SAVE_PREVIOUS_FETCH2_BRANCHING;
    end
  end

  // Target will either become the address that will get branched or jumped to, or will continue like normal adding 4 each time
  logic FETCH2_BRANCHED;
  assign FETCH2_BRANCHED = FETCH2_IS_A_BRANCH_INSTRUCTION && FETCH2_PREDICTED_BRANCH_TAKEN;
  assign FETCH2_BRANCH_OFF_OR_CONTINUE = FETCH2_VALID && (FETCH2_BRANCHED || FETCH2_IS_A_JAL_INSTRUCTION);
  assign FETCH2_PREDICTED_NEXT_PC = FETCH2_BRANCH_OFF_OR_CONTINUE ? FETCH2_PC_TARGET : FETCH1_PC_ADD_4;

  // ========== Decode Stage Signals: ==========
  logic [31:0] DECODE_PC; // Program Counter at Decode
  logic [31:0] DECODE_INSTRUCTION; // Instruction at Decode
  logic DECODE_VALID; 
  logic DECODE_PREDICTED_BRANCH_TAKEN; 
  logic [GSHARE_HISTORY_BITS-1:0] DECODE_GSHARE_INDEX;  
  logic [4:0] DECODE_REGISTER1_ADDRESS; // register file read port 1 (rs1)
  logic [4:0] DECODE_REGISTER2_ADDRESS; // register file read port 2 (rs2)
  logic [4:0] DECODE_DESTINATION_REGISTER_ADDRESS; // destination register (rd)
  logic [2:0] DECODE_FUNCT3; // funct3
  logic [11:0] DECODE_CSR_ADDRESS; // Control Status Register Target
  logic [31:0] DECODE_REGISTER_FILE_REGISTER1_DATA; // Regfile's Register 1 information
  logic [31:0] DECODE_REGISTER_FILE_REGISTER2_DATA; // Regfile's Register 2 information
  logic [31:0] DECODE_FORWARDED_REGISTER1_DATA; // Regfile's Register 1 information after fowarding (Data Hazard: Decode to Execute Fowarding)
  logic [31:0] DECODE_FORWARDED_REGISTER2_DATA; // Regfile's Register 2 information after fowarding (Data Hazard: Decode to Execute Forwarding)
  logic [31:0] DECODE_IMMEDIATE; // Decode's Immediate Value
  logic DECODE_REGISTER_WRITE_ENABLE; // Does the instruction write to destination register? (0 is read, 1 is write)
  logic DECODE_MEMORY_READ_ENABLE; // Does memory need to be read? (Basically is this a load, 0 is no, 1 is yes)
  logic DECODE_MEMORY_WRITE_ENABLE; // Does memory need to be written to? (Basically is this a store, 0 is no, 1 is yes)
  logic DECODE_CSR_WRITE_ENABLE; // Does Control Status Register need to be written to? (0 is no, 1 is yes)
  logic DECODE_CSR_WRITE_USING_IMMEDIATE; // Does Control Status Register need to be written to with immediate? (0 is no, 1 is yes)
  logic DECODE_ALU_INPUT_A_IS_PC; // ALU Input A is 0: Register 1 or 1: Program Counter
  logic DECODE_ALU_INPUT_B_IS_IMMEDIATE; // ALU Input B is 0: Register 2 or 1: Immediate Value
  logic DECODE_IS_A_BRANCH_INSTRUCTION; // Continue preserving whether or not the instruction is a B type
  logic DECODE_IS_A_JAL_INSTRUCTION; // Continue preserving whether or not the instruction is a JAL
  logic DECODE_IS_A_JALR_INSTRUCTION; // Determine whether or not the instruction is a JALR
  immediate_type_select_t DECODE_IMMEDIATE_TYPE_SELECT; // Immediate Type will consist of these: | I | S | B | U | J | Z |
  writeback_select_t DECODE_WRITEBACK_SELECT; // 4 Possibilities to Writeback: | ALU Result | Load Information | PC ADD 4 | CSR |
  alu_op_t DECODE_ALU_OPERATION; // Determine which ALU operation is required
  logic [31:0] DECODE_PC_TARGET;
  logic [31:0] DECODE_PC_ADD_4;

  assign DECODE_REGISTER1_ADDRESS = DECODE_INSTRUCTION[19:15]; // Register 1 Address (rs1) is always the 5 bits at 19-15
  assign DECODE_REGISTER2_ADDRESS = DECODE_INSTRUCTION[24:20]; // Register 2 Address (rs2) is always the 5 bits at 24-20 
  assign DECODE_DESTINATION_REGISTER_ADDRESS = DECODE_INSTRUCTION[11:7]; // Destination Register's Address (rd) is always the 5 bits at 11-7
  assign DECODE_FUNCT3 = DECODE_INSTRUCTION[14:12]; // Funct3 is always the 3 bits at 14-12
  assign DECODE_CSR_ADDRESS = DECODE_INSTRUCTION[31:20]; // Control Status Register Address (CSR) is always the top 12 bits at 31-20

  // Forwarding Signals from Execute: 
  logic [4:0] EXECUTE_DESTINATION_REGISTER_ADDRESS; // Execute Stage Instruction's destination register address (rd) 
  logic EXECUTE_REGISTER_WRITE_ENABLE; // Execute Stage's Read or Write Signal
  logic EXECUTE_MEMORY_READ_ENABLE; // Execute Stage's Memory Read or not (Is a load occuring in Execute? if so load stall is necessary)
  logic [31:0] EXECUTE_FORWARD_DATA; // Execute Stage's Data to Forward | ALU Result | PC ADD 4 | CSR | 
  
  // Forwarding Signals from Memory:
  logic [4:0] MEMORY_DESTINATION_REGISTER_ADDRESS; // Memory's destination register address (rd)
  logic MEMORY_REGISTER_WRITE_ENABLE; // Memory's Read or Write Signal
  logic MEMORY_VALID; // Memory's instruction is valid right?
  logic [31:0] MEMORY_FORWARD_DATA; // Memory's 4 Possibilities to Forward back: | ALU Result | Load Information | PC ADD 4 | CSR |

  // Forwarding Signals from Writeback:
  logic [4:0] WRITEBACK_DESTINATION_REGISTER_ADDRESS; // Writeback Stage's destination register address (rd)
  logic WRITEBACK_REGISTER_WRITE_ENABLE; // Writeback Stage's Read or Write Signal
  logic WRITEBACK_VALID; // Writeback Stage's instruction is valid right?
  logic [31:0] WRITEBACK_DATA; // Final writeback data driving Register File's write data this cycle

  RegisterFile register_file ( // Synchrous Writes, Asynchronous Reads
    .clk (clk),
    .reset (reset),
    .REGISTER_WRITE_ENABLE (WRITEBACK_VALID && WRITEBACK_REGISTER_WRITE_ENABLE),
    .READ_ADDRESS1 (DECODE_REGISTER1_ADDRESS),
    .READ_ADDRESS2 (DECODE_REGISTER2_ADDRESS),
    .WRITE_ADDRESS (WRITEBACK_DESTINATION_REGISTER_ADDRESS),
    .WRITE_DATA (WRITEBACK_DATA),
    .READ_DATA1 (DECODE_REGISTER_FILE_REGISTER1_DATA),
    .READ_DATA2 (DECODE_REGISTER_FILE_REGISTER2_DATA)
  );

  // Decode Stage Register 1 Data Hazard Forwarding (Data Hazard Priority Logic: x0 Address > Execute (no loading occuring) > Memory > Writeback > Register File):
  always_comb begin
    if (DECODE_REGISTER1_ADDRESS == 5'd0) begin // If the Address is x0 then all the data is just zero
      DECODE_FORWARDED_REGISTER1_DATA = 32'd0; // x0 reads as all 0s
    end else if (EXECUTE_VALID && EXECUTE_REGISTER_WRITE_ENABLE && !EXECUTE_MEMORY_READ_ENABLE && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0) && (EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS)) begin // Execute Stage is Valid and Register Writing is Enabled and No Loading is happening, and RS1 is the same as Destination Address 
      DECODE_FORWARDED_REGISTER1_DATA = EXECUTE_FORWARD_DATA; // Data Hazard: Forward Execute Data to Decode Stage (Loads are not considered will use a load stall)
    end else if (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE && (MEMORY_DESTINATION_REGISTER_ADDRESS != 5'd0) && (MEMORY_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS)) begin // Memory Stage is Valid and Register Writing is Enabled and RS1 is the same as Destination Address 
      DECODE_FORWARDED_REGISTER1_DATA = MEMORY_FORWARD_DATA; // Data Hazard: Forward Memory Data
    end else if (WRITEBACK_VALID && WRITEBACK_REGISTER_WRITE_ENABLE && (WRITEBACK_DESTINATION_REGISTER_ADDRESS != 5'd0) && (WRITEBACK_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS)) begin // Writeback Stage is Valid and Register Writing is Enabled and No Loading is happening, and RS1 is the same as Destination Address 
      DECODE_FORWARDED_REGISTER1_DATA = WRITEBACK_DATA; // Data Hazard: Forward Writeback Data 
    end else begin
      DECODE_FORWARDED_REGISTER1_DATA = DECODE_REGISTER_FILE_REGISTER1_DATA; // No hazard is present, the register file data is okay to use
    end
  end

  // Decode Stage Register 2 Data Hazard Forwarding (Data Hazard Priority Logic: x0 Address > Execute (no loading occuring) > Memory > Writeback > Register File):
  always_comb begin
    if (DECODE_REGISTER2_ADDRESS == 5'd0) begin // If the Address is x0 then all the data is just zero
      DECODE_FORWARDED_REGISTER2_DATA = 32'd0; // x0 reads as all 0s
    end else if (EXECUTE_VALID && EXECUTE_REGISTER_WRITE_ENABLE && !EXECUTE_MEMORY_READ_ENABLE && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0) && (EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS)) begin // Execute Stage is Valid and Register Writing is Enabled and No Loading is happening, and RS2 is the same as Destination Address 
      DECODE_FORWARDED_REGISTER2_DATA = EXECUTE_FORWARD_DATA; // Data Hazard: Forward Execute Data to Decode Stage (Loads are not considered will use a load stall)
    end else if (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE && (MEMORY_DESTINATION_REGISTER_ADDRESS != 5'd0) && (MEMORY_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS)) begin // Memory Stage is Valid and Register Writing is Enabled and RS1 is the same as Destination Address 
      DECODE_FORWARDED_REGISTER2_DATA = MEMORY_FORWARD_DATA; // Data Hazard: Forward Memory Data 
    end else if (WRITEBACK_VALID && WRITEBACK_REGISTER_WRITE_ENABLE && (WRITEBACK_DESTINATION_REGISTER_ADDRESS != 5'd0) && (WRITEBACK_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS)) begin // Writeback Stage is Valid and Register Writing is Enabled and No Loading is happening, and RS1 is the same as Destination Address 
      DECODE_FORWARDED_REGISTER2_DATA = WRITEBACK_DATA; // Data Hazard: Forward Writeback Data
    end else begin
      DECODE_FORWARDED_REGISTER2_DATA = DECODE_REGISTER_FILE_REGISTER2_DATA; // No hazard is present, the register file data is okay to use
    end
  end

  logic LOAD_HAZARD_REGISTER1; // Determine if Fetch Decode is reading register1 as Execute Load is writing to same place
  logic LOAD_HAZARD_REGISTER2; // Determine if Fetch Decode is reading register2 as Execute Load is writing to same place

  // If the Execute Desintation Address during a Load is the same as the Fetch Decode's register 1 that is being read a load hazard exists
  assign LOAD_HAZARD_REGISTER1 = EXECUTE_VALID && EXECUTE_MEMORY_READ_ENABLE && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0) && (EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS);
  // If the Execute Desintation Address during a Load is the same as the Fetch Decode's register 2 that is being read a load hazard exists
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
  logic [31:0] EXECUTE_PC; // Program Counter at the Execute Stage
  logic [31:0] EXECUTE_INSTRUCTION; // Instruction at the Execute Stage
  logic [4:0] EXECUTE_REGISTER1_ADDRESS; // Register 1 Address at the Execute Stage
  logic [4:0] EXECUTE_REGISTER2_ADDRESS; // Register 2 Address at the Execute Stage
  logic [31:0] EXECUTE_REGISTER1_DATA; // Register1 Data at the Execute Stage (Forwarding already resolved)
  logic [31:0] EXECUTE_REGISTER2_DATA; // Register2 Data at the Execute Stage (Forwarding already resolved)
  logic [31:0] EXECUTE_IMMEDIATE; // Immediate at the Execute Stage
  logic [2:0] EXECUTE_FUNCT3; // Funct3 at the Execute Stage used for the Branch Comparator and Loading/Storing Control
  logic [11:0] EXECUTE_CSR_ADDRESS; // Control Status Register at the Execute Stage
  logic EXECUTE_MEMORY_WRITE_ENABLE; // Determine if this is a store at the Execute Stage
  logic EXECUTE_CSR_WRITE_ENABLE; // Determine if the Control Status Register needs to be written to at the Execute Stage
  logic EXECUTE_CSR_WRITE_USING_IMMEDIATE; // Determine fi the Control Status Register needs to be written to (with immediate) at the Execute Stage
  logic EXECUTE_ALU_INPUT_A_IS_PC; // ALU A Input at the Execute Stage
  logic EXECUTE_ALU_INPUT_B_IS_IMMEDIATE; // ALU B Input at the Execute Stage select
  logic EXECUTE_IS_A_BRANCH_INSTRUCTION; // Is Branch Instruction? at the Execute Stage
  logic EXECUTE_IS_A_JAL_INSTRUCTION; // Is JAL Instruction? at the Execute Stage
  logic EXECUTE_IS_A_JALR_INSTRUCTION; // Is JALR Instruction? at the Execute Stage
  logic EXECUTE_PREDICTED_BRANCH_TAKEN; // Store Fetch Decode prediction at the Execute Stage
  writeback_select_t EXECUTE_WRITEBACK_SELECT; // Writeback logic in Execute Stage
  alu_op_t EXECUTE_ALU_OPERATION; // ALU operation in the Execute Stage 

  logic [31:0] EXECUTE_PC_ADD_4; // Hold Next Program Counter at the Execute Stage
  logic [31:0] EXECUTE_ALU_INPUT_A; // ALU input A is either Register 1 Data or the Program Counter at Execute Stage
  logic [31:0] EXECUTE_ALU_INPUT_B; // ALU input B is either Register 2 or the Immediate value at the Execute Stage
  logic [31:0] EXECUTE_ALU_RESULT; // ALU Result at the Execute Stage
  logic [31:0] EXECUTE_BRANCH_TARGET; // Target Address of Branch is whatever the Address is aka Program Counter + the Branch Type Immediate Value
  logic [31:0] EXECUTE_JALR_TARGET; // JALR Target Address is Register1 + Immediate and half word aligned by flipping LSB
  logic EXECUTE_BRANCH_TAKEN; // Branch Comparator Result at Execute Stage
  logic EXECUTE_FLUSH; // Control Hazard: Flush when Branch Prediction is wrong (Flush the Fetch Decode and Execute)
  logic [31:0] EXECUTE_ADJUST_NEXT_PC; // Have the good and valid Program Counter in case Flush occurs
  logic [31:0] EXECUTE_CSR_READ_DATA; // Hold Control Status Register Read Value at Execute Stage
  logic [31:0] EXECUTE_CSR_WRITE_DATA; // Write Value to write to Control Status Register 
  logic [3:0] EXECUTE_STORE_MASK; // Hold Store Byte Mask at the Execute Stage
  logic [31:0] EXECUTE_STORE_DATA; // Hold Stored Data at the Execute Stage (forced alignment in Store Control)
  logic [31:0] EXECUTE_PC_TARGET;

  // assign EXECUTE_PC_ADD_4 = EXECUTE_PC + 32'd4; // Look at Next PC from Execute Stage perspective
  assign EXECUTE_ALU_INPUT_A = EXECUTE_ALU_INPUT_A_IS_PC ? EXECUTE_PC : EXECUTE_REGISTER1_DATA; // Determine input A to ALU
  assign EXECUTE_ALU_INPUT_B = EXECUTE_ALU_INPUT_B_IS_IMMEDIATE ? EXECUTE_IMMEDIATE : EXECUTE_REGISTER2_DATA; // Determine input B to ALU
  // assign EXECUTE_BRANCH_TARGET = EXECUTE_PC + EXECUTE_IMMEDIATE; // Determine Branch Target Address
  assign EXECUTE_BRANCH_TARGET = EXECUTE_PC_TARGET;

  ALU alu (
    .A (EXECUTE_ALU_INPUT_A),
    .B (EXECUTE_ALU_INPUT_B),
    .ALUop (EXECUTE_ALU_OPERATION),
    .ALUOut (EXECUTE_ALU_RESULT)
  );

  assign EXECUTE_JALR_TARGET = {EXECUTE_ALU_RESULT[31:1], 1'b0}; // JALR requires even addresses (Least Significant Bit forced to 0 to maintain halfword alignment)

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
    .BRANCH_TARGET (EXECUTE_BRANCH_TARGET),
    .JALR_TARGET (EXECUTE_JALR_TARGET),
    .BRANCH_WAS_ACTUALLY_TAKEN (EXECUTE_BRANCH_WAS_ACTUALLY_TAKEN),
    .PREDICTION_WAS_WRONG (EXECUTE_PREDICTION_WAS_WRONG),
    .FLUSH (EXECUTE_FLUSH),
    .UPDATE_BRANCH_PREDICTOR (EXECUTE_UPDATE_BRANCH_PREDICTOR),
    .ADJUST_NEXT_PC (EXECUTE_ADJUST_NEXT_PC)
  );

  // Optimization: Parallelize Possible Targets Taken:
  logic [31:0] EXECUTE_BRANCH_TARGET_ADD_4;
  logic [31:0] EXECUTE_JALR_TARGET_ADD_4;
  logic [31:0] EXECUTE_PC_ADD_8;
  logic [31:0] EXECUTE_ADJUST_NEXT_PC_ADD_4;
  assign EXECUTE_BRANCH_TARGET_ADD_4 = EXECUTE_BRANCH_TARGET + 32'd4; 
  assign EXECUTE_JALR_TARGET_ADD_4 = EXECUTE_JALR_TARGET + 32'd4;   
  assign EXECUTE_PC_ADD_8 = EXECUTE_PC_ADD_4 + 32'd4; 

  always_comb begin
    if (EXECUTE_IS_A_JALR_INSTRUCTION) begin
      EXECUTE_ADJUST_NEXT_PC_ADD_4 = EXECUTE_JALR_TARGET_ADD_4; // If JALR then next PC is precomputed JALR Target + 4 Address
    end else if ((EXECUTE_IS_A_BRANCH_INSTRUCTION && EXECUTE_BRANCH_TAKEN) || EXECUTE_IS_A_JAL_INSTRUCTION) begin
      EXECUTE_ADJUST_NEXT_PC_ADD_4 = EXECUTE_BRANCH_TARGET_ADD_4; // If Taken Branch or JAL then next PC is precomputed Branch Target + 4 Address
    end else begin
      EXECUTE_ADJUST_NEXT_PC_ADD_4 = EXECUTE_PC_ADD_8; // If no branch or jump is taken then next PC is just PC + 4 + 4 (since its the next next sequence)
    end
  end

  assign FLUSH_FETCH1_FETCH2_DECODE = EXECUTE_VALID && EXECUTE_FLUSH; // Control Hazard: Branch Control Required Flush from Misprediction

  StoreControl store_control (
    .STORE_FUNCT3 (EXECUTE_FUNCT3),
    .MEMORY_ADDRESS (EXECUTE_ALU_RESULT),
    .MEMORY_INFO (EXECUTE_REGISTER2_DATA),
    .WRITE_MASK_FOR_STORE (EXECUTE_STORE_MASK),
    .DATA_TO_STORE (EXECUTE_STORE_DATA)
  );

  // Collect Control Status Register Data at the Execute Stage for Memory and Writeback Stage
  assign EXECUTE_CSR_WRITE_DATA = EXECUTE_CSR_WRITE_USING_IMMEDIATE ? {27'd0, EXECUTE_INSTRUCTION[19:15]} : EXECUTE_REGISTER1_DATA; 

  CSRFile control_status_register_file (
    .clk (clk),
    .reset (reset),
    .CSR_WRITE_ENABLE (EXECUTE_CSR_WRITE_ENABLE && EXECUTE_VALID && CONTINUE_PIPELINE),
    .CSR_ADDRESS (EXECUTE_CSR_ADDRESS),
    .CSR_WRITE_DATA (EXECUTE_CSR_WRITE_DATA),
    .CSR_READ_DATA (EXECUTE_CSR_READ_DATA),
    .TOHOST (csr)
  );

  // Execute Writeback to Fetch Decode Stage MUX
  always_comb begin
    unique case (EXECUTE_WRITEBACK_SELECT)
      WRITEBACK_ALU: EXECUTE_FORWARD_DATA = EXECUTE_ALU_RESULT; // ALU Result
      WRITEBACK_PC_ADD_4: EXECUTE_FORWARD_DATA = EXECUTE_PC_ADD_4; // Program Counter + 4
      WRITEBACK_CSR: EXECUTE_FORWARD_DATA = EXECUTE_CSR_READ_DATA; // Control Status Register Data
      WRITEBACK_MEMORY: EXECUTE_FORWARD_DATA = 32'd0; // Load is not covered instead a load stall is used
      default: EXECUTE_FORWARD_DATA = EXECUTE_ALU_RESULT; // In general the writeback would use the result from the ALU
    endcase
  end

  assign dcache_addr = EXECUTE_ALU_RESULT; // Feed Data Cache the calculated Target Address
  assign dcache_din = EXECUTE_STORE_DATA; // Feed Data Cache Data from Store Instruction
  assign dcache_we = (EXECUTE_VALID && EXECUTE_MEMORY_WRITE_ENABLE) ? EXECUTE_STORE_MASK : 4'b0000; // Place Write Mask If the Execute Stage is Valid and a Write and the Pipeline is not currently stalling
  assign dcache_re = EXECUTE_VALID && EXECUTE_MEMORY_READ_ENABLE; // Data Cache must read so the loaded value is ready when the lw advances to MEMORY (otherwise the dependent instruction in DECODE forwards stale data)

  // ========== Memory Stage Signals: ==========
  logic [31:0] MEMORY_PC; // Keep track of Program Counter at the Memory Writeback Stage
  logic [31:0] MEMORY_INSTRUCTION; // Keep track of the Instruction at the Memory Writeback Stage
  logic [2:0] MEMORY_FUNCT3; // Keep track of the funct3 at the Memory Writeback Stage (For Load Alignments)
  logic [31:0] MEMORY_ALU_RESULT; // Keep track of the ALU Result at the Memory Writeback Stage
  logic [31:0] MEMORY_PC_ADD_4; // Keep track of the next program counter address at the Memory Writeback Stage
  logic [31:0] MEMORY_CSR_READ_DATA; // Read the Control Status Register at the Writeback Stage
  writeback_select_t MEMORY_WRITEBACK_SELECT; // Determine what value from writeback mux to give
  logic MEMORY_MEMORY_READ_ENABLE; // Determine if a load is going to occur
  logic [31:0] MEMORY_LOAD_DATA; // Aligned Load Result that will be given by Load Control Unit
  logic [31:0] MEMORY_DCACHE_DATA; // Pipeline Data Cache Data during transition from Execute to Memory

  LoadControl load_control (
    .LOAD_FUNCT3 (MEMORY_FUNCT3), // Determines Load Alignment
    .MEMORY_ADDRESS (MEMORY_ALU_RESULT), // Address to Determine byte, halfword, full word lane
    .MEMORY_INFO (MEMORY_DCACHE_DATA), // Load the 32 data bits from the Data Cache
    .DATA_TO_LOAD (MEMORY_LOAD_DATA)
  );

  // Memory Forwarding MUX
  always_comb begin
    unique case (MEMORY_WRITEBACK_SELECT)
      WRITEBACK_ALU: MEMORY_FORWARD_DATA = MEMORY_ALU_RESULT; // ALU Result
      WRITEBACK_MEMORY: MEMORY_FORWARD_DATA = MEMORY_LOAD_DATA; // Load Data
      WRITEBACK_PC_ADD_4: MEMORY_FORWARD_DATA = MEMORY_PC_ADD_4; // Program Counter + 4
      WRITEBACK_CSR: MEMORY_FORWARD_DATA = MEMORY_CSR_READ_DATA; // Control Status Register Data
      default: MEMORY_FORWARD_DATA = MEMORY_ALU_RESULT;
    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) begin
       // ========== Fetch 1 ==========
      FETCH1_PC <= PC_RESET;
    
      // ========== Fetch 2 ==========
      FETCH2_PC <= PC_RESET;
      FETCH2_INSTRUCTION <= INSTR_NOP;
      FETCH2_VALID <= 1'b0;
      FETCH2_PREDICTED_BRANCH_TAKEN <= 1'b0;        
      FETCH2_GSHARE_INDEX <= '0;
      FETCH2_PC_ADD_4 <= 32'd0; 

       // ========== Decode ==========
      DECODE_PC <= 32'd0;
      DECODE_INSTRUCTION <= INSTR_NOP;
      DECODE_VALID <= 1'b0;
      DECODE_PREDICTED_BRANCH_TAKEN <= 1'b0;
      DECODE_GSHARE_INDEX <= '0;
      DECODE_PC_TARGET <= 32'd0;
      DECODE_PC_ADD_4 <= 32'd0;

       // ========== Execute ==========
      EXECUTE_VALID <= 1'b0;
      EXECUTE_PC <= 32'd0;
      EXECUTE_INSTRUCTION <= INSTR_NOP;
      EXECUTE_REGISTER1_ADDRESS <= 5'd0;
      EXECUTE_REGISTER2_ADDRESS <= 5'd0;
      EXECUTE_REGISTER1_DATA <= 32'd0;
      EXECUTE_REGISTER2_DATA <= 32'd0;
      EXECUTE_IMMEDIATE <= 32'd0;
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
      EXECUTE_IS_A_BRANCH_INSTRUCTION <= 1'b0;
      EXECUTE_IS_A_JAL_INSTRUCTION <= 1'b0;
      EXECUTE_IS_A_JALR_INSTRUCTION <= 1'b0;
      EXECUTE_PREDICTED_BRANCH_TAKEN <= 1'b0;
      EXECUTE_GSHARE_INDEX <= '0;
      EXECUTE_WRITEBACK_SELECT <= WRITEBACK_ALU;
      EXECUTE_ALU_OPERATION <= ALU_XXX;
      EXECUTE_PC_TARGET <= 32'd0;
      EXECUTE_PC_ADD_4 <= 32'd0;

      // ========== Memory ==========
      MEMORY_VALID <= 1'b0;
      MEMORY_PC <= 32'd0;
      MEMORY_INSTRUCTION <= INSTR_NOP;
      MEMORY_DESTINATION_REGISTER_ADDRESS <= 5'd0;
      MEMORY_FUNCT3 <= 3'd0;
      MEMORY_ALU_RESULT <= 32'd0;
      MEMORY_PC_ADD_4 <= 32'd0;
      MEMORY_CSR_READ_DATA <= 32'd0;
      MEMORY_REGISTER_WRITE_ENABLE <= 1'b0;
      MEMORY_MEMORY_READ_ENABLE <= 1'b0;
      MEMORY_WRITEBACK_SELECT <= WRITEBACK_ALU;
      MEMORY_DCACHE_DATA <= 32'd0;

       // ========== Writeback ==========
      WRITEBACK_VALID <= 1'b0;
      WRITEBACK_DESTINATION_REGISTER_ADDRESS <= 5'd0;
      WRITEBACK_REGISTER_WRITE_ENABLE <= 1'b0;
      WRITEBACK_DATA <= 32'd0;
    end
    else if (CONTINUE_PIPELINE) begin // No Stall Occuring continue normally
      DECODE_PC_TARGET <= FETCH2_PC_TARGET;
      DECODE_PC_ADD_4  <= FETCH2_PC_ADD_4;
      EXECUTE_PC_TARGET <= DECODE_PC_TARGET;
      EXECUTE_PC_ADD_4  <= DECODE_PC_ADD_4;
      
      // Advance Execute to Memory
      MEMORY_VALID <= EXECUTE_VALID; // Even on flush, the Execute Stage instruction is the cause and must still complete its writeback only DECODE and FETCH get flushed
      MEMORY_PC <= EXECUTE_PC; // Update Memory Program Counter
      MEMORY_INSTRUCTION <= EXECUTE_INSTRUCTION; // Update Memory Instruction
      MEMORY_DESTINATION_REGISTER_ADDRESS <= EXECUTE_DESTINATION_REGISTER_ADDRESS; // Update Memory Destination Register Address
      MEMORY_FUNCT3 <= EXECUTE_FUNCT3; // Update Memory Funct3
      MEMORY_ALU_RESULT <= EXECUTE_ALU_RESULT; // Update Memory ALU Result
      MEMORY_PC_ADD_4 <= EXECUTE_PC_ADD_4; // Update Memory Program Counter + 4
      MEMORY_CSR_READ_DATA <= EXECUTE_CSR_READ_DATA; // Update Control Status Register Read Data
      MEMORY_REGISTER_WRITE_ENABLE <= EXECUTE_REGISTER_WRITE_ENABLE; // Update Register Write Enable Signal
      MEMORY_MEMORY_READ_ENABLE <= EXECUTE_MEMORY_READ_ENABLE; // Update Memory Read Enable Signal
      MEMORY_WRITEBACK_SELECT <= EXECUTE_WRITEBACK_SELECT; // Update Memory Writeback Select MUX Output Selection
      MEMORY_DCACHE_DATA <= dcache_dout; // Forward Data Cache's response data for Load Control
      
      // Advance Memory to Writeback
      WRITEBACK_VALID <= MEMORY_VALID;
      WRITEBACK_DESTINATION_REGISTER_ADDRESS <= MEMORY_DESTINATION_REGISTER_ADDRESS;
      WRITEBACK_REGISTER_WRITE_ENABLE <= MEMORY_REGISTER_WRITE_ENABLE;
      WRITEBACK_DATA <= MEMORY_FORWARD_DATA; // Determined by Memory Stage Writeback MUX

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
        EXECUTE_DESTINATION_REGISTER_ADDRESS <= 5'd0;
        EXECUTE_REGISTER1_ADDRESS <= 5'd0;
        EXECUTE_REGISTER2_ADDRESS <= 5'd0;
        EXECUTE_WRITEBACK_SELECT <= WRITEBACK_ALU;
        EXECUTE_ALU_OPERATION <= ALU_XXX;
        EXECUTE_PREDICTED_BRANCH_TAKEN <= 1'b0;
        EXECUTE_GSHARE_INDEX <= '0;
        EXECUTE_PC <= EXECUTE_ADJUST_NEXT_PC;           
        EXECUTE_PC_ADD_4 <= EXECUTE_ADJUST_NEXT_PC_ADD_4;
        EXECUTE_PC_TARGET <= EXECUTE_ADJUST_NEXT_PC;  
      end else begin // Continue updated Execute like Normal
        EXECUTE_VALID <= DECODE_VALID;
        EXECUTE_PC <= DECODE_PC;
        EXECUTE_INSTRUCTION <= DECODE_INSTRUCTION;
        EXECUTE_REGISTER1_ADDRESS <= DECODE_REGISTER1_ADDRESS;
        EXECUTE_REGISTER2_ADDRESS <= DECODE_REGISTER2_ADDRESS;
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
        EXECUTE_IS_A_BRANCH_INSTRUCTION <= DECODE_IS_A_BRANCH_INSTRUCTION;
        EXECUTE_IS_A_JAL_INSTRUCTION <= DECODE_IS_A_JAL_INSTRUCTION;
        EXECUTE_IS_A_JALR_INSTRUCTION <= DECODE_IS_A_JALR_INSTRUCTION;
        EXECUTE_PREDICTED_BRANCH_TAKEN <= DECODE_PREDICTED_BRANCH_TAKEN;
        EXECUTE_GSHARE_INDEX <= DECODE_GSHARE_INDEX;
        EXECUTE_WRITEBACK_SELECT <= DECODE_WRITEBACK_SELECT;
        EXECUTE_ALU_OPERATION <= DECODE_ALU_OPERATION;
      end
      if (FLUSH_FETCH1_FETCH2_DECODE) begin // Fetch 2 transition to Decode
        DECODE_VALID <= 1'b0;
        DECODE_INSTRUCTION <= INSTR_NOP;
        DECODE_PREDICTED_BRANCH_TAKEN <= 1'b0;
        DECODE_GSHARE_INDEX <= '0;
        FETCH2_PC_ADD_4 <= EXECUTE_ADJUST_NEXT_PC_ADD_4;
        DECODE_PC <= EXECUTE_ADJUST_NEXT_PC;           
        DECODE_PC_ADD_4 <= EXECUTE_ADJUST_NEXT_PC_ADD_4;
        DECODE_PC_TARGET <= EXECUTE_ADJUST_NEXT_PC;     
      end else begin
        DECODE_PC <= FETCH2_PC;
        DECODE_INSTRUCTION <= FETCH2_INSTRUCTION;
        DECODE_VALID <= FETCH2_VALID;
        DECODE_PREDICTED_BRANCH_TAKEN <= FETCH2_PREDICTED_BRANCH_TAKEN;
        DECODE_GSHARE_INDEX <= FETCH2_GSHARE_INDEX;
        FETCH2_PC_ADD_4 <= FETCH1_PC_CYCLE_DELAY + 32'd4; 
      end

      if (FLUSH_FETCH1_FETCH2_DECODE) begin // Fetch 1 Transition to Fetch 2 with Program Counter Update for Fetch 1 and Fetch 2 and Decode Flush
        FETCH1_PC <= EXECUTE_ADJUST_NEXT_PC; 
        FETCH2_PC <= EXECUTE_ADJUST_NEXT_PC;
        FETCH2_INSTRUCTION <= INSTR_NOP;
        FETCH2_VALID <= 1'b0; 
        FETCH2_PREDICTED_BRANCH_TAKEN <= 1'b0;                            
        FETCH2_GSHARE_INDEX <= '0; 
      end else begin
        FETCH1_PC <= FETCH2_PREDICTED_NEXT_PC; 
        FETCH2_PC <= FETCH1_PC_CYCLE_DELAY;
        FETCH2_INSTRUCTION <= icache_dout;
        FETCH2_VALID <= !FETCH2_BRANCH_OFF_OR_CONTINUE && !POST_FLUSH && !POST_BRANCHING;  
        FETCH2_PREDICTED_BRANCH_TAKEN <= FETCH1_PREDICTED_BRANCH_TAKEN;   
        FETCH2_GSHARE_INDEX <= FETCH1_GSHARE_INDEX;
      end
    end
    else if (LOAD_STALL && !stall && !DCACHE_STALL) begin // Load Stall:
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
      EXECUTE_DESTINATION_REGISTER_ADDRESS <= 5'd0;
      EXECUTE_REGISTER1_ADDRESS <= 5'd0;
      EXECUTE_REGISTER2_ADDRESS <= 5'd0;
      EXECUTE_WRITEBACK_SELECT <= WRITEBACK_ALU;
      EXECUTE_ALU_OPERATION <= ALU_XXX;
      EXECUTE_PREDICTED_BRANCH_TAKEN <= 1'b0;
      EXECUTE_GSHARE_INDEX <= '0;
       // Advance Execute to Memory
      MEMORY_VALID <= EXECUTE_VALID;
      MEMORY_PC <= EXECUTE_PC;
      MEMORY_INSTRUCTION <= EXECUTE_INSTRUCTION;
      MEMORY_DESTINATION_REGISTER_ADDRESS <= EXECUTE_DESTINATION_REGISTER_ADDRESS;
      MEMORY_FUNCT3 <= EXECUTE_FUNCT3;
      MEMORY_ALU_RESULT <= EXECUTE_ALU_RESULT;
      MEMORY_PC_ADD_4 <= EXECUTE_PC_ADD_4;
      MEMORY_CSR_READ_DATA <= EXECUTE_CSR_READ_DATA;
      MEMORY_REGISTER_WRITE_ENABLE <= EXECUTE_REGISTER_WRITE_ENABLE;
      MEMORY_MEMORY_READ_ENABLE <= EXECUTE_MEMORY_READ_ENABLE;
      MEMORY_WRITEBACK_SELECT <= EXECUTE_WRITEBACK_SELECT;
      MEMORY_DCACHE_DATA <= dcache_dout; 
      // Advance Memory to Writeback 
      WRITEBACK_VALID <= MEMORY_VALID;
      WRITEBACK_DESTINATION_REGISTER_ADDRESS <= MEMORY_DESTINATION_REGISTER_ADDRESS;
      WRITEBACK_REGISTER_WRITE_ENABLE <= MEMORY_REGISTER_WRITE_ENABLE;
      WRITEBACK_DATA <= MEMORY_FORWARD_DATA;
    end
    // end else begin
    //   FETCH_RESPONSE_PC <= FETCH_PC; // Track Held PC for Cache
    //   FETCH_PIPELINE_VALID <= 1'b1;
    // end

    // Normal Stall: Do not update anything until stall ends 
    
  end
endmodule

`default_nettype wire

// 6-Stage Pipeline Reference: https://csg.csail.mit.edu/6.175/labs/lab6-riscv-pipeline.html

// `default_nettype none

// import const_pkg::*;
// import opcode_pkg::*;
// import immediate_op_pkg::*;
// import alu_op_pkg::*;
// import writeback_op_pkg::*;

// module Riscv151 (
//   input  logic        clk,
//   input  logic        reset,

//   // Memory system ports
//   output logic [31:0] dcache_addr,
//   output logic [31:0] icache_addr,
//   output logic [3:0]  dcache_we, 
//   output logic        dcache_re, 
//   output logic        icache_re, 
//   output logic [31:0] dcache_din,
//   input  logic [31:0] dcache_dout, 
//   input  logic [31:0] icache_dout, 
//   input  logic        stall,
//   output logic [31:0] csr
// );

//   logic LOAD_STALL; // Load Hazard: Instead of a full stall only hold the Fetch and Decode, send a NOP to Execute, and advance the load logic for the Memory and Writeback
//   logic CONTINUE_PIPELINE; // If a stall is taking place hold the pipeline (0 is do not advance pipeline, 1 is safe to advance pipeline)
//   assign CONTINUE_PIPELINE = !(stall || LOAD_STALL); // Pipeline is safe is no stall is requested
//   logic FLUSH_FETCH_DECODE_EXECUTE; // Control Hazard: Fetch & Decode FLUSH wrong Instruction and send NOP to the Execute Stage

//   // Fetch Signals:
//   logic [31:0] FETCH_PC; // The Current Program Counter: sets up icache_addr
//   logic [31:0] FETCH_PC_ADD_4; // The Next Program Counter: sets up the supposed next value for program counter
//   logic [31:0] FETCH_RESPONSE_PC; // Program Counter set to valid icache_dout instruction
//   logic FETCH_PIPELINE_VALID; // 0 means Pipeline is being Flushed, 1 means Pipeline has real instruction
//   logic [31:0] FETCH_INSTRUCTION; // Full Instruction from icache
//   logic [6:0] FETCH_OPCODE; // Instruction Operation Code
//   logic FETCH_IS_A_BRANCH_INSTRUCTION; // Is the FETCH Instruction a Branch type? (0 no, 1 yes)
//   logic FETCH_IS_A_JAL_INSTRUCTION; // Is the FETCH Instruction a JAL? If so just always take no need to guess this is redudant at this point

//   assign FETCH_PC_ADD_4 = FETCH_PC + 32'd4; // PC + 4 (Advance Program Counter)
//   assign icache_addr = FETCH_PC; // Set the New Address for Instruction Cache
//   assign FETCH_INSTRUCTION = icache_dout; // Set the Instruction provided by the Instruction Cache
//   assign FETCH_OPCODE = FETCH_INSTRUCTION[6:0]; // Assign FETCH Instruction's opcode
//   assign FETCH_IS_A_BRANCH_INSTRUCTION = (FETCH_OPCODE == OPC_BRANCH); // If opcode is the same as B-type then its a branch
//   assign FETCH_IS_A_JAL_INSTRUCTION = (FETCH_OPCODE == OPC_JAL); // If opcode is the same as JAL then its a JAL

//   // Precompute Branch and JAL Immediates for Branch Prediction Addressing (presumably reduces critical path if branch predictor is the issue):
//   logic [31:0] FETCH_BRANCH_IMMEDIATE; // Full sign extended Branch Immediate
//   logic [31:0] FETCH_JAL_IMMEDIATE; // Full sign extended Jump Immediate
//   logic [31:0] FETCH_IMMEDIATE; // Select Immediate based on whether a Branch or Jump occurs
//   logic [31:0] FETCH_PC_TARGET; // Target Address = ICache's Response Program Counter + Associated Immediate
//   assign FETCH_BRANCH_IMMEDIATE = {{19{FETCH_INSTRUCTION[31]}}, FETCH_INSTRUCTION[31], FETCH_INSTRUCTION[7], FETCH_INSTRUCTION[30:25], FETCH_INSTRUCTION[11:8], 1'b0}; // B-type uses Immediate bits 31, 7, 30-25, 11-8 and the 0th bit: Format as Sign Extended 19 bits then associated 13 bits (31, 7, 30-25, 11-8 bits and the 0 bit being set to 0)
//   assign FETCH_JAL_IMMEDIATE = {{11{FETCH_INSTRUCTION[31]}}, FETCH_INSTRUCTION[31], FETCH_INSTRUCTION[19:12], FETCH_INSTRUCTION[20], FETCH_INSTRUCTION[30:21], 1'b0}; // J-type uses Immediate bits 31, 19-12, 20, 30-21, and the 0th bit: Format as Sign Extended 11 bits then associated 21 bits (31, 19-12, 20, 30-21 bits and the 0th bit being set to 0)

//   always_comb begin
//     if (FETCH_IS_A_BRANCH_INSTRUCTION) begin     
//       FETCH_IMMEDIATE = FETCH_BRANCH_IMMEDIATE; // Branch uses precomputed branch immediate
//     end else if (FETCH_IS_A_JAL_INSTRUCTION) begin
//       FETCH_IMMEDIATE = FETCH_JAL_IMMEDIATE; // Jump uses precomputed branch immediate
//     end else begin
//       FETCH_IMMEDIATE = 32'd0; // the target address will be left alone for the branch prediction part
//     end                                    
//   end

//   assign FETCH_PC_TARGET = FETCH_RESPONSE_PC + FETCH_IMMEDIATE; // Compute the Target Address to use

//   // Global Share Branch Prediction Scheme:
//   localparam int GSHARE_HISTORY_BITS = 6; // 64 entry branch history table
//   logic FETCH_PREDICTED_BRANCH_TAKEN; // Store the Magical Almighty Branch Predictor's prediction
//   logic FETCH_BRANCH_OFF_OR_CONTINUE; // If a branch or jump actually occurs use the calculated new address otherwise continue cycles at current address like normal
//   logic [GSHARE_HISTORY_BITS-1:0] FETCH_GSHARE_INDEX; // Index for the Branch History Table
//   logic [31:0] FETCH_PREDICTED_NEXT_PC; // The next updated Program Counter will either be the targeted address or continue as expected with each cycle being Program Counter + 4

//   // Execute Stage Signals Relevant to Gshare predictor: 
//   logic EXECUTE_VALID;
//   logic EXECUTE_UPDATE_BRANCH_PREDICTOR; // We have the actual Results from the branching scheme tally it at the Branch Predictor History Table
//   logic EXECUTE_BRANCH_WAS_ACTUALLY_TAKEN; // Since Branch Comparator is going to be in the Execute Stage this is when it will be known whether the branch was really taken or not
//   logic EXECUTE_PREDICTION_WAS_WRONG; // Branch Control looks at Predicted Value and determines if the prediction was right or wrong
//   logic [GSHARE_HISTORY_BITS-1:0] EXECUTE_GSHARE_INDEX; // Save the Branch History Table Index that was used for solid book keeping

//   GSharePredictor #(
//     .HISTORY_BITS (GSHARE_HISTORY_BITS)
//   ) gshare_branch_predictor (
//     .clk (clk),
//     .reset (reset),
//     .FETCH_PC (FETCH_RESPONSE_PC),
//     .FETCH_IS_A_BRANCH_INSTRUCTION (FETCH_PIPELINE_VALID && FETCH_IS_A_BRANCH_INSTRUCTION),
//     .FETCH_PREDICTED_TAKEN (FETCH_PREDICTED_BRANCH_TAKEN),
//     .FETCH_PREDICTION_INDEX (FETCH_GSHARE_INDEX),
//     .UPDATE_PREDICTION (EXECUTE_VALID && EXECUTE_UPDATE_BRANCH_PREDICTOR),
//     .UPDATE_PREDICTION_INDEX (EXECUTE_GSHARE_INDEX),
//     .ACTUAL_BRANCH_TAKEN (EXECUTE_BRANCH_WAS_ACTUALLY_TAKEN),
//     .UPDATE_MISPREDICTION (EXECUTE_VALID && EXECUTE_PREDICTION_WAS_WRONG) // Main idea here is to make sure the Global History Register stores only what actually happens (corrects any mispredictions)
//   );

//   // Target will either become the address that will get branched or jumped to, or will continue like normal adding 4 each time
//   logic FETCH_BRANCHED;
//   assign FETCH_BRANCHED = FETCH_IS_A_BRANCH_INSTRUCTION && FETCH_PREDICTED_BRANCH_TAKEN;
//   assign FETCH_BRANCH_OFF_OR_CONTINUE = FETCH_PIPELINE_VALID && (FETCH_BRANCHED || FETCH_IS_A_JAL_INSTRUCTION);
//   assign FETCH_PREDICTED_NEXT_PC = FETCH_BRANCH_OFF_OR_CONTINUE ? FETCH_PC_TARGET : FETCH_PC_ADD_4;

//   // Decode Signals:
//   logic [4:0] DECODE_REGISTER1_ADDRESS; // register file read port 1 (rs1)
//   logic [4:0] DECODE_REGISTER2_ADDRESS; // register file read port 2 (rs2)
//   logic [4:0] DECODE_DESTINATION_REGISTER_ADDRESS; // destination register (rd)
//   logic [2:0] DECODE_FUNCT3; // funct3
//   logic [11:0] DECODE_CSR_ADDRESS; // Control Status Register Target
//   logic [31:0] DECODE_REGISTER_FILE_REGISTER1_DATA; // Regfile's Register 1 information
//   logic [31:0] DECODE_REGISTER_FILE_REGISTER2_DATA; // Regfile's Register 2 information
//   logic [31:0] DECODE_FORWARDED_REGISTER1_DATA; // Regfile's Register 1 information after fowarding (Data Hazard: Decode to Execute Fowarding)
//   logic [31:0] DECODE_FORWARDED_REGISTER2_DATA; // Regfile's Register 2 information after fowarding (Data Hazard: Decode to Execute Forwarding)
//   logic [31:0] DECODE_IMMEDIATE; // Decode's Immediate Value
//   logic DECODE_REGISTER_WRITE_ENABLE; // Does the instruction write to destination register? (0 is read, 1 is write)
//   logic DECODE_MEMORY_READ_ENABLE; // Does memory need to be read? (Basically is this a load, 0 is no, 1 is yes)
//   logic DECODE_MEMORY_WRITE_ENABLE; // Does memory need to be written to? (Basically is this a store, 0 is no, 1 is yes)
//   logic DECODE_CSR_WRITE_ENABLE; // Does Control Status Register need to be written to? (0 is no, 1 is yes)
//   logic DECODE_CSR_WRITE_USING_IMMEDIATE; // Does Control Status Register need to be written to with immediate? (0 is no, 1 is yes)
//   logic DECODE_ALU_INPUT_A_IS_PC; // ALU Input A is 0: Register 1 or 1: Program Counter
//   logic DECODE_ALU_INPUT_B_IS_IMMEDIATE; // ALU Input B is 0: Register 2 or 1: Immediate Value
//   logic DECODE_IS_A_BRANCH_INSTRUCTION; // Continue preserving whether or not the instruction is a B type
//   logic DECODE_IS_A_JAL_INSTRUCTION; // Continue preserving whether or not the instruction is a JAL
//   logic DECODE_IS_A_JALR_INSTRUCTION; // Determine whether or not the instruction is a JALR
//   immediate_type_select_t DECODE_IMMEDIATE_TYPE_SELECT; // Immediate Type will consist of these: | I | S | B | U | J | Z |
//   writeback_select_t DECODE_WRITEBACK_SELECT; // 4 Possibilities to Writeback: | ALU Result | Load Information | PC ADD 4 | CSR |
//   alu_op_t DECODE_ALU_OPERATION; // Determine which ALU operation is required

//   assign DECODE_REGISTER1_ADDRESS = FETCH_INSTRUCTION[19:15]; // Register 1 Address (rs1) is always the 5 bits at 19-15
//   assign DECODE_REGISTER2_ADDRESS = FETCH_INSTRUCTION[24:20]; // Register 2 Address (rs2) is always the 5 bits at 24-20 
//   assign DECODE_DESTINATION_REGISTER_ADDRESS = FETCH_INSTRUCTION[11:7]; // Destination Register's Address (rd) is always the 5 bits at 11-7
//   assign DECODE_FUNCT3 = FETCH_INSTRUCTION[14:12]; // Funct3 is always the 3 bits at 14-12
//   assign DECODE_CSR_ADDRESS = FETCH_INSTRUCTION[31:20]; // Control Status Register Address (CSR) is always the top 12 bits at 31-20

//   // Forwarding Signals from Execute: 
//   logic [4:0] EXECUTE_DESTINATION_REGISTER_ADDRESS; // Execute Stage Instruction's destination register address (rd) 
//   logic EXECUTE_REGISTER_WRITE_ENABLE; // Execute Stage's Read or Write Signal
//   logic EXECUTE_MEMORY_READ_ENABLE; // Execute Stage's Memory Read or not (Is a load occuring in Execute? if so load stall is necessary)
//   logic [31:0] EXECUTE_FORWARD_DATA; // Execute Stage's Data to Forward | ALU Result | PC ADD 4 | CSR | 
  
//   // Forwarding Signals from Memory and Writeback:
//   logic [4:0] MEMORY_DESTINATION_REGISTER_ADDRESS; // Memory & Writeback's destination register address (rd)
//   logic MEMORY_REGISTER_WRITE_ENABLE; // Memory & Writeback's Read or Write Signal
//   logic MEMORY_VALID; // Memory & Writeback's instruction is valid right?
//   logic [31:0] MEMORY_WRITEBACK_DATA; // Memory & Writeback's 4 Possibilities to Writeback: | ALU Result | Load Information | PC ADD 4 | CSR |

//   RegisterFile register_file ( // Synchrous Writes, Asynchronous Reads
//     .clk (clk),
//     .reset (reset),
//     .REGISTER_WRITE_ENABLE (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE),
//     .READ_ADDRESS1 (DECODE_REGISTER1_ADDRESS),
//     .READ_ADDRESS2 (DECODE_REGISTER2_ADDRESS),
//     .WRITE_ADDRESS (MEMORY_DESTINATION_REGISTER_ADDRESS),
//     .WRITE_DATA (MEMORY_WRITEBACK_DATA),
//     .READ_DATA1 (DECODE_REGISTER_FILE_REGISTER1_DATA),
//     .READ_DATA2 (DECODE_REGISTER_FILE_REGISTER2_DATA)
//   );

//   // Fetch/Decode Stage Register 1 Data Hazard Forwarding:
//   always_comb begin
//     if (DECODE_REGISTER1_ADDRESS == 5'd0) begin // If the Address is x0 then all the data is just zero
//       DECODE_FORWARDED_REGISTER1_DATA = 32'd0; // x0 reads as all 0s
//     end else if (EXECUTE_VALID && EXECUTE_REGISTER_WRITE_ENABLE) begin // Execute Stage is Valid and Register Writing is Enabled
//       if (!EXECUTE_MEMORY_READ_ENABLE) begin // This is not a load operation
//         if ((EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS) && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0)) begin // The Destination Address is not the same as the Register 1 Address and the address is not x0
//           DECODE_FORWARDED_REGISTER1_DATA = EXECUTE_FORWARD_DATA; // Data Hazard: Forward Execute Data to Fetch & Decode Stage
//         end else if (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE && (MEMORY_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS) && (MEMORY_DESTINATION_REGISTER_ADDRESS != 5'd0)) begin // Memory and Writeback Stage is Valid and Register Writing is Enabled
//           DECODE_FORWARDED_REGISTER1_DATA = MEMORY_WRITEBACK_DATA; // Data Hazard: Forward Memory and Writeback Data to Fetch & Decode Stage (Can work for loads)
//         end else begin
//           DECODE_FORWARDED_REGISTER1_DATA = DECODE_REGISTER_FILE_REGISTER1_DATA; // no hazard is present the register file data is okay to use 
//         end
//       end else if (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE && (MEMORY_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS) && (MEMORY_DESTINATION_REGISTER_ADDRESS != 5'd0)) begin // Memory and Writeback Stage is Valid and Register Writing is Enabled
//         DECODE_FORWARDED_REGISTER1_DATA = MEMORY_WRITEBACK_DATA; // Data Hazard: Forward Memory and Writeback Data to Fetch & Decode Stage (Can work for loads)
//       end else begin
//         DECODE_FORWARDED_REGISTER1_DATA = DECODE_REGISTER_FILE_REGISTER1_DATA; // no hazard is present the register file data is okay to use 
//       end
//     end else if (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE) begin // Memory and Writeback Stage is Valid and Register Writing is Enabled
//       if ((MEMORY_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS) && (MEMORY_DESTINATION_REGISTER_ADDRESS != 5'd0)) begin // The Destination Address is not the same as the Register 1 Address and the address is not x
//         DECODE_FORWARDED_REGISTER1_DATA = MEMORY_WRITEBACK_DATA; // Data Hazard: Forward Memory and Writeback Data to Fetch & Decode Stage (Can work for loads)
//       end else begin
//         DECODE_FORWARDED_REGISTER1_DATA = DECODE_REGISTER_FILE_REGISTER1_DATA; // no hazard is present the register file data is okay to use 
//       end
//     end else begin
//       DECODE_FORWARDED_REGISTER1_DATA = DECODE_REGISTER_FILE_REGISTER1_DATA; // no hazard is present the register file data is okay to use 
//     end
//   end

//   // Fetch/Decode Stage Register 2 Data Hazard Forwarding:
//   always_comb begin
//     if (DECODE_REGISTER2_ADDRESS == 5'd0) begin // If the Address is x0 then all the data is just zero
//       DECODE_FORWARDED_REGISTER2_DATA = 32'd0; // x0 reads as all 0s
//     end else if (EXECUTE_VALID && EXECUTE_REGISTER_WRITE_ENABLE) begin // Execute Stage is Valid and Register Writing is Enabled
//       if (!EXECUTE_MEMORY_READ_ENABLE) begin // This is not a load operation
//         if ((EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS) && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0)) begin // The Destination Address is not the same as the Register 2 Address and the address is not x0
//           DECODE_FORWARDED_REGISTER2_DATA = EXECUTE_FORWARD_DATA; // Data Hazard: Forward Execute Data to Fetch & Decode Stage
//         end else if (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE && (MEMORY_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS) && (MEMORY_DESTINATION_REGISTER_ADDRESS != 5'd0)) begin // Memory and Writeback Stage is Valid and Register Writing is Enabled
//           DECODE_FORWARDED_REGISTER2_DATA = MEMORY_WRITEBACK_DATA; // Data Hazard: Forward Memory and Writeback Data to Fetch & Decode Stage (Can work for loads)
//         end else begin
//           DECODE_FORWARDED_REGISTER2_DATA = DECODE_REGISTER_FILE_REGISTER2_DATA; // no hazard is present the register file data is okay to use 
//         end
//       end else if (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE && (MEMORY_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS) && (MEMORY_DESTINATION_REGISTER_ADDRESS != 5'd0)) begin // Memory and Writeback Stage is Valid and Register Writing is Enabled
//         DECODE_FORWARDED_REGISTER2_DATA = MEMORY_WRITEBACK_DATA; // Data Hazard: Forward Memory and Writeback Data to Fetch & Decode Stage (Can work for loads)
//       end else begin
//         DECODE_FORWARDED_REGISTER2_DATA = DECODE_REGISTER_FILE_REGISTER2_DATA; // no hazard is present the register file data is okay to use 
//       end
//     end else if (MEMORY_VALID && MEMORY_REGISTER_WRITE_ENABLE) begin // Memory and Writeback Stage is Valid and Register Writing is Enabled
//       if ((MEMORY_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS) && (MEMORY_DESTINATION_REGISTER_ADDRESS != 5'd0)) begin // The Destination Address is not the same as the Register 2 Address and the address is not x
//         DECODE_FORWARDED_REGISTER2_DATA = MEMORY_WRITEBACK_DATA; // Data Hazard: Forward Memory and Writeback Data to Fetch & Decode Stage (Can work for loads)
//       end else begin
//         DECODE_FORWARDED_REGISTER2_DATA = DECODE_REGISTER_FILE_REGISTER2_DATA; // no hazard is present the register file data is okay to use 
//       end
//     end else begin
//       DECODE_FORWARDED_REGISTER2_DATA = DECODE_REGISTER_FILE_REGISTER2_DATA; // no hazard is present the register file data is okay to use 
//     end
//   end

//   logic LOAD_HAZARD_REGISTER1; // Determine if Fetch Decode is reading register1 as Execute Load is writing to same place
//   logic LOAD_HAZARD_REGISTER2; // Determine if Fetch Decode is reading register2 as Execute Load is writing to same place

//   // If the Execute Desintation Address during a Load is the same as the Fetch Decode's register 1 that is being read a load hazard exists
//   assign LOAD_HAZARD_REGISTER1 = EXECUTE_VALID && EXECUTE_MEMORY_READ_ENABLE && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0) && (EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER1_ADDRESS);
//   // If the Execute Desintation Address during a Load is the same as the Fetch Decode's register 2 that is being read a load hazard exists
//   assign LOAD_HAZARD_REGISTER2 = EXECUTE_VALID && EXECUTE_MEMORY_READ_ENABLE && (EXECUTE_DESTINATION_REGISTER_ADDRESS != 5'd0) && (EXECUTE_DESTINATION_REGISTER_ADDRESS == DECODE_REGISTER2_ADDRESS);
//   assign LOAD_STALL = FETCH_PIPELINE_VALID && (LOAD_HAZARD_REGISTER1 || LOAD_HAZARD_REGISTER2); // Load Hazard Exists and thus enable the load stall

//   ControlUnit control_unit (
//     .INSTRUCTION (FETCH_INSTRUCTION),
//     .REGISTER_WRITE_ENABLE (DECODE_REGISTER_WRITE_ENABLE),
//     .MEMORY_READ_ENABLE (DECODE_MEMORY_READ_ENABLE),
//     .MEMORY_WRITE_ENABLE (DECODE_MEMORY_WRITE_ENABLE),
//     .CSR_WRITE_USING_IMMEDIATE (DECODE_CSR_WRITE_USING_IMMEDIATE),
//     .CSR_WRITE_ENABLE (DECODE_CSR_WRITE_ENABLE),
//     .ALU_INPUT_A_IS_PC (DECODE_ALU_INPUT_A_IS_PC),
//     .ALU_INPUT_B_IS_IMMEDIATE (DECODE_ALU_INPUT_B_IS_IMMEDIATE),
//     .IS_A_BRANCH_INSTRUCTION (DECODE_IS_A_BRANCH_INSTRUCTION),
//     .IS_A_JAL_INSTRUCTION (DECODE_IS_A_JAL_INSTRUCTION),
//     .IS_A_JALR_INSTRUCTION (DECODE_IS_A_JALR_INSTRUCTION),
//     .IMMEDIATE_TYPE_SELECT (DECODE_IMMEDIATE_TYPE_SELECT),
//     .WRITEBACK_SELECT (DECODE_WRITEBACK_SELECT),
//     .ALU_OPERATION (DECODE_ALU_OPERATION)
//   );

//   ImmediateGenerator immediate_generator (
//     .INSTRUCTION (FETCH_INSTRUCTION),
//     .IMMEDIATE_TYPE_SELECT (DECODE_IMMEDIATE_TYPE_SELECT),
//     .IMMEDIATE (DECODE_IMMEDIATE)
//   );

//   // Execute Signals:
//   logic [31:0] EXECUTE_PC; // Program Counter at the Execute Stage
//   logic [31:0] EXECUTE_INSTRUCTION; // Instruction at the Execute Stage
//   logic [4:0] EXECUTE_REGISTER1_ADDRESS; // Register 1 Address at the Execute Stage
//   logic [4:0] EXECUTE_REGISTER2_ADDRESS; // Register 2 Address at the Execute Stage
//   logic [31:0] EXECUTE_REGISTER1_DATA; // Register1 Data at the Execute Stage (Forwarding already resolved)
//   logic [31:0] EXECUTE_REGISTER2_DATA; // Register2 Data at the Execute Stage (Forwarding already resolved)
//   logic [31:0] EXECUTE_IMMEDIATE; // Immediate at the Execute Stage
//   logic [2:0] EXECUTE_FUNCT3; // Funct3 at the Execute Stage used for the Branch Comparator and Loading/Storing Control
//   logic [11:0] EXECUTE_CSR_ADDRESS; // Control Status Register at the Execute Stage
//   logic EXECUTE_MEMORY_WRITE_ENABLE; // Determine if this is a store at the Execute Stage
//   logic EXECUTE_CSR_WRITE_ENABLE; // Determine if the Control Status Register needs to be written to at the Execute Stage
//   logic EXECUTE_CSR_WRITE_USING_IMMEDIATE; // Determine fi the Control Status Register needs to be written to (with immediate) at the Execute Stage
//   logic EXECUTE_ALU_INPUT_A_IS_PC; // ALU A Input at the Execute Stage
//   logic EXECUTE_ALU_INPUT_B_IS_IMMEDIATE; // ALU B Input at the Execute Stage select
//   logic EXECUTE_IS_A_BRANCH_INSTRUCTION; // Is Branch Instruction? at the Execute Stage
//   logic EXECUTE_IS_A_JAL_INSTRUCTION; // Is JAL Instruction? at the Execute Stage
//   logic EXECUTE_IS_A_JALR_INSTRUCTION; // Is JALR Instruction? at the Execute Stage
//   logic EXECUTE_PREDICTED_BRANCH_TAKEN; // Store Fetch Decode prediction at the Execute Stage
//   writeback_select_t EXECUTE_WRITEBACK_SELECT; // Writeback logic in Execute Stage
//   alu_op_t EXECUTE_ALU_OPERATION; // ALU operation in the Execute Stage 

//   logic [31:0] EXECUTE_PC_ADD_4; // Hold Next Program Counter at the Execute Stage
//   logic [31:0] EXECUTE_ALU_INPUT_A; // ALU input A is either Register 1 Data or the Program Counter at Execute Stage
//   logic [31:0] EXECUTE_ALU_INPUT_B; // ALU input B is either Register 2 or the Immediate value at the Execute Stage
//   logic [31:0] EXECUTE_ALU_RESULT; // ALU Result at the Execute Stage
//   logic [31:0] EXECUTE_BRANCH_TARGET; // Target Address of Branch is whatever the Address is aka Program Counter + the Branch Type Immediate Value
//   logic [31:0] EXECUTE_JALR_TARGET; // JALR Target Address is Register1 + Immediate and half word aligned by flipping LSB
//   logic EXECUTE_BRANCH_TAKEN; // Branch Comparator Result at Execute Stage
//   logic EXECUTE_FLUSH; // Control Hazard: Flush when Branch Prediction is wrong (Flush the Fetch Decode and Execute)
//   logic [31:0] EXECUTE_ADJUST_NEXT_PC; // Have the good and valid Program Counter in case Flush occurs
//   logic [31:0] EXECUTE_CSR_READ_DATA; // Hold Control Status Register Read Value at Execute Stage
//   logic [31:0] EXECUTE_CSR_WRITE_DATA; // Write Value to write to Control Status Register 
//   logic [3:0] EXECUTE_STORE_MASK; // Hold Store Byte Mask at the Execute Stage
//   logic [31:0] EXECUTE_STORE_DATA; // Hold Stored Data at the Execute Stage (forced alignment in Store Control)

//   assign EXECUTE_PC_ADD_4 = EXECUTE_PC + 32'd4; // Look at Next PC from Execute Stage perspective
//   assign EXECUTE_ALU_INPUT_A = EXECUTE_ALU_INPUT_A_IS_PC ? EXECUTE_PC : EXECUTE_REGISTER1_DATA; // Determine input A to ALU
//   assign EXECUTE_ALU_INPUT_B = EXECUTE_ALU_INPUT_B_IS_IMMEDIATE ? EXECUTE_IMMEDIATE : EXECUTE_REGISTER2_DATA; // Determine input B to ALU
//   assign EXECUTE_BRANCH_TARGET = EXECUTE_PC + EXECUTE_IMMEDIATE; // Determine Branch Target Address

//   ALU alu (
//     .A (EXECUTE_ALU_INPUT_A),
//     .B (EXECUTE_ALU_INPUT_B),
//     .ALUop (EXECUTE_ALU_OPERATION),
//     .ALUOut (EXECUTE_ALU_RESULT)
//   );

//   assign EXECUTE_JALR_TARGET = {EXECUTE_ALU_RESULT[31:1], 1'b0}; // JALR requires even addresses (Least Significant Bit forced to 0 to maintain halfword alignment)

//   BranchComparator branch_comparator (
//     .A (EXECUTE_REGISTER1_DATA),
//     .B (EXECUTE_REGISTER2_DATA),
//     .BRANCH_FUNCT3 (EXECUTE_FUNCT3),
//     .BRANCH_TAKEN (EXECUTE_BRANCH_TAKEN)
//   );

//   BranchControl branch_control (
//     .IS_A_BRANCH_INSTRUCTION (EXECUTE_IS_A_BRANCH_INSTRUCTION),
//     .IS_A_JAL_INSTRUCTION (EXECUTE_IS_A_JAL_INSTRUCTION),
//     .IS_A_JALR_INSTRUCTION (EXECUTE_IS_A_JALR_INSTRUCTION),
//     .ACTUALLY_TAKEN_BRANCH (EXECUTE_BRANCH_TAKEN),
//     .PREDICTED_BRANCH_TAKEN (EXECUTE_PREDICTED_BRANCH_TAKEN),
//     .PC_ADD_4 (EXECUTE_PC_ADD_4),
//     .BRANCH_TARGET (EXECUTE_BRANCH_TARGET),
//     .JALR_TARGET (EXECUTE_JALR_TARGET),
//     .BRANCH_WAS_ACTUALLY_TAKEN (EXECUTE_BRANCH_WAS_ACTUALLY_TAKEN),
//     .PREDICTION_WAS_WRONG (EXECUTE_PREDICTION_WAS_WRONG),
//     .FLUSH (EXECUTE_FLUSH),
//     .UPDATE_BRANCH_PREDICTOR (EXECUTE_UPDATE_BRANCH_PREDICTOR),
//     .ADJUST_NEXT_PC (EXECUTE_ADJUST_NEXT_PC)
//   );

//   assign FLUSH_FETCH_DECODE_EXECUTE = EXECUTE_VALID && EXECUTE_FLUSH; // Control Hazard: Branch Control Required Flush from Misprediction

//   StoreControl store_control (
//     .STORE_FUNCT3 (EXECUTE_FUNCT3),
//     .MEMORY_ADDRESS (EXECUTE_ALU_RESULT),
//     .MEMORY_INFO (EXECUTE_REGISTER2_DATA),
//     .WRITE_MASK_FOR_STORE (EXECUTE_STORE_MASK),
//     .DATA_TO_STORE (EXECUTE_STORE_DATA)
//   );

//   // Collect Control Status Register Data at the Execute Stage for Memory and Writeback Stage
//   assign EXECUTE_CSR_WRITE_DATA = EXECUTE_CSR_WRITE_USING_IMMEDIATE ? {27'd0, EXECUTE_INSTRUCTION[19:15]} : EXECUTE_REGISTER1_DATA; 

//   CSRFile control_status_register_file (
//     .clk (clk),
//     .reset (reset),
//     .CSR_WRITE_ENABLE (EXECUTE_CSR_WRITE_ENABLE && EXECUTE_VALID && CONTINUE_PIPELINE),
//     .CSR_ADDRESS (EXECUTE_CSR_ADDRESS),
//     .CSR_WRITE_DATA (EXECUTE_CSR_WRITE_DATA),
//     .CSR_READ_DATA (EXECUTE_CSR_READ_DATA),
//     .TOHOST (csr)
//   );

//   // Execute Writeback to Fetch Decode Stage MUX
//   always_comb begin
//     unique case (EXECUTE_WRITEBACK_SELECT)
//       WRITEBACK_ALU: EXECUTE_FORWARD_DATA = EXECUTE_ALU_RESULT; // ALU Result
//       WRITEBACK_PC_ADD_4: EXECUTE_FORWARD_DATA = EXECUTE_PC_ADD_4; // Program Counter + 4
//       WRITEBACK_CSR: EXECUTE_FORWARD_DATA = EXECUTE_CSR_READ_DATA; // Control Status Register Data
//       WRITEBACK_MEMORY: EXECUTE_FORWARD_DATA = 32'd0; // Load is not covered instead a load stall is used
//       default: EXECUTE_FORWARD_DATA = EXECUTE_ALU_RESULT; // In general the writeback would use the result from the ALU
//     endcase
//   end

//   assign dcache_addr = EXECUTE_ALU_RESULT; // Feed Data Cache the calculated Target Address
//   assign dcache_din = EXECUTE_STORE_DATA; // Feed Data Cache Data from Store Instruction
//   assign dcache_we = (EXECUTE_VALID && EXECUTE_MEMORY_WRITE_ENABLE) ? EXECUTE_STORE_MASK : 4'b0000; // Place Write Mask If the Execute Stage is Valid and a Write and the Pipeline is not currently stalling
//   assign dcache_re = EXECUTE_VALID && EXECUTE_MEMORY_READ_ENABLE; // Data Cache must read so the loaded value is ready when the lw advances to MEMORY (otherwise the dependent instruction in DECODE forwards stale data)
//   assign icache_re = !LOAD_STALL; // Gate icache during LOAD_STALL: otherwise the cache fetches the instruction after the dependent one, overwriting cpu_resp_data and erasing the held Decode Stage instruction 

//   // Memory and Writeback Signals:
//   logic [31:0] MEMORY_PC; // Keep track of Program Counter at the Memory Writeback Stage
//   logic [31:0] MEMORY_INSTRUCTION; // Keep track of the Instruction at the Memory Writeback Stage
//   logic [2:0] MEMORY_FUNCT3; // Keep track of the funct3 at the Memory Writeback Stage (For Load Alignments)
//   logic [31:0] MEMORY_ALU_RESULT; // Keep track of the ALU Result at the Memory Writeback Stage
//   logic [31:0] MEMORY_PC_ADD_4; // Keep track of the next program counter address at the Memory Writeback Stage
//   logic [31:0] MEMORY_CSR_READ_DATA; // Read the Control Status Register at the Writeback Stage
//   writeback_select_t MEMORY_WRITEBACK_SELECT; // Determine what value from writeback mux to give
//   logic MEMORY_MEMORY_READ_ENABLE; // Determine if a load is going to occur
//   logic [31:0] MEMORY_LOAD_DATA; // Aligned Load Result that will be given by Load Control Unit

//   logic [31:0] MEMORY_DCACHE_DATA_OUT;
//   always_ff @(posedge clk) begin
//       if (reset) begin
//           MEMORY_DCACHE_DATA_OUT <= 32'd0;
//       end else if (!stall) begin // Just a make sure its not a normal stall, load stalls are likely not the issue
//           MEMORY_DCACHE_DATA_OUT <= dcache_dout;
//       end
//   end

//   LoadControl load_control (
//     .LOAD_FUNCT3 (MEMORY_FUNCT3), // Determines Load Alignment
//     .MEMORY_ADDRESS (MEMORY_ALU_RESULT), // Address to Determine byte, halfword, full word lane
//     .MEMORY_INFO (MEMORY_DCACHE_DATA_OUT), // Load the 32 data bits from the Data Cache
//     .DATA_TO_LOAD (MEMORY_LOAD_DATA)
//   );

//   // Writeback to Register File MUX or Feed back into Fetch Decode Stage for Forwarding
//   always_comb begin
//     unique case (MEMORY_WRITEBACK_SELECT)
//       WRITEBACK_ALU: MEMORY_WRITEBACK_DATA = MEMORY_ALU_RESULT;
//       WRITEBACK_MEMORY: MEMORY_WRITEBACK_DATA = MEMORY_LOAD_DATA;
//       WRITEBACK_PC_ADD_4: MEMORY_WRITEBACK_DATA = MEMORY_PC_ADD_4;
//       WRITEBACK_CSR: MEMORY_WRITEBACK_DATA = MEMORY_CSR_READ_DATA;
//       default: MEMORY_WRITEBACK_DATA = MEMORY_ALU_RESULT;
//     endcase
//   end

//   always_ff @(posedge clk) begin
//     if (reset) begin
//       FETCH_PC <= PC_RESET;
//       FETCH_RESPONSE_PC <= PC_RESET;
//      FETCH_PIPELINE_VALID <= 1'b0;
//       EXECUTE_VALID <= 1'b0;
//       EXECUTE_PC <= 32'd0;
//       EXECUTE_INSTRUCTION <= INSTR_NOP;
//       EXECUTE_REGISTER1_ADDRESS <= 5'd0;
//       EXECUTE_REGISTER2_ADDRESS <= 5'd0;
//       EXECUTE_REGISTER1_DATA <= 32'd0;
//       EXECUTE_REGISTER2_DATA <= 32'd0;
//       EXECUTE_IMMEDIATE <= 32'd0;
//       EXECUTE_DESTINATION_REGISTER_ADDRESS <= 5'd0;
//       EXECUTE_FUNCT3 <= 3'd0;
//       EXECUTE_CSR_ADDRESS <= 12'd0;
//       EXECUTE_REGISTER_WRITE_ENABLE <= 1'b0;
//       EXECUTE_MEMORY_READ_ENABLE <= 1'b0;
//       EXECUTE_MEMORY_WRITE_ENABLE <= 1'b0;
//       EXECUTE_CSR_WRITE_ENABLE <= 1'b0;
//       EXECUTE_CSR_WRITE_USING_IMMEDIATE <= 1'b0;
//       EXECUTE_ALU_INPUT_A_IS_PC <= 1'b0;
//       EXECUTE_ALU_INPUT_B_IS_IMMEDIATE <= 1'b0;
//       EXECUTE_IS_A_BRANCH_INSTRUCTION <= 1'b0;
//       EXECUTE_IS_A_JAL_INSTRUCTION <= 1'b0;
//       EXECUTE_IS_A_JALR_INSTRUCTION <= 1'b0;
//       EXECUTE_PREDICTED_BRANCH_TAKEN <= 1'b0;
//       EXECUTE_GSHARE_INDEX <= '0;
//       EXECUTE_WRITEBACK_SELECT <= WRITEBACK_ALU;
//       EXECUTE_ALU_OPERATION <= ALU_XXX;
//       MEMORY_VALID <= 1'b0;
//       MEMORY_PC <= 32'd0;
//       MEMORY_INSTRUCTION <= INSTR_NOP;
//       MEMORY_DESTINATION_REGISTER_ADDRESS <= 5'd0;
//       MEMORY_FUNCT3 <= 3'd0;
//       MEMORY_ALU_RESULT <= 32'd0;
//       MEMORY_PC_ADD_4 <= 32'd0;
//       MEMORY_CSR_READ_DATA <= 32'd0;
//       MEMORY_REGISTER_WRITE_ENABLE <= 1'b0;
//       MEMORY_MEMORY_READ_ENABLE <= 1'b0;
//       MEMORY_WRITEBACK_SELECT <= WRITEBACK_ALU;
//     end
//     else if (CONTINUE_PIPELINE) begin // No Stall Occuring
//       MEMORY_VALID <= EXECUTE_VALID; // Even on flush, the Execute Stage instruction is the cause and must still complete its writeback only DECODE and FETCH get flushed
//       MEMORY_PC <= EXECUTE_PC; // Update Memory Program Counter
//       MEMORY_INSTRUCTION <= EXECUTE_INSTRUCTION; // Update Memory Instruction
//       MEMORY_DESTINATION_REGISTER_ADDRESS <= EXECUTE_DESTINATION_REGISTER_ADDRESS; // Update Memory Destination Register Address
//       MEMORY_FUNCT3 <= EXECUTE_FUNCT3; // Update Memory Funct3
//       MEMORY_ALU_RESULT <= EXECUTE_ALU_RESULT; // Update Memory ALU Result
//       MEMORY_PC_ADD_4 <= EXECUTE_PC_ADD_4; // Update Memory Program Counter + 4
//       MEMORY_CSR_READ_DATA <= EXECUTE_CSR_READ_DATA; // Update Control Status Register Read Data
//       MEMORY_REGISTER_WRITE_ENABLE <= EXECUTE_REGISTER_WRITE_ENABLE; // Update Register Write Enable Signal
//       MEMORY_MEMORY_READ_ENABLE <= EXECUTE_MEMORY_READ_ENABLE; // Update Memory Read Enable Signal
//       MEMORY_WRITEBACK_SELECT <= EXECUTE_WRITEBACK_SELECT; // Update Memory Writeback Select MUX Output Selection

//       if (FLUSH_FETCH_DECODE_EXECUTE) begin // Control Hazard: Flush Taken (Misprediction occured inject NOP)
//         EXECUTE_VALID <= 1'b0;
//         EXECUTE_INSTRUCTION <= INSTR_NOP;
//         EXECUTE_REGISTER_WRITE_ENABLE <= 1'b0;
//         EXECUTE_MEMORY_READ_ENABLE <= 1'b0;
//         EXECUTE_MEMORY_WRITE_ENABLE <= 1'b0;
//         EXECUTE_CSR_WRITE_ENABLE <= 1'b0;
//         EXECUTE_IS_A_BRANCH_INSTRUCTION <= 1'b0;
//         EXECUTE_IS_A_JAL_INSTRUCTION <= 1'b0;
//         EXECUTE_IS_A_JALR_INSTRUCTION <= 1'b0;
//         EXECUTE_DESTINATION_REGISTER_ADDRESS <= 5'd0;
//         EXECUTE_REGISTER1_ADDRESS <= 5'd0;
//         EXECUTE_REGISTER2_ADDRESS <= 5'd0;
//         EXECUTE_WRITEBACK_SELECT <= WRITEBACK_ALU;
//         EXECUTE_ALU_OPERATION <= ALU_XXX;
//         EXECUTE_PREDICTED_BRANCH_TAKEN <= 1'b0;
//         EXECUTE_GSHARE_INDEX <= '0;
//       end else begin // Continue updated Execute like Normal
//         EXECUTE_VALID <= FETCH_PIPELINE_VALID;
//         EXECUTE_PC <= FETCH_RESPONSE_PC;
//         EXECUTE_INSTRUCTION <= FETCH_INSTRUCTION;
//         EXECUTE_REGISTER1_ADDRESS <= DECODE_REGISTER1_ADDRESS;
//         EXECUTE_REGISTER2_ADDRESS <= DECODE_REGISTER2_ADDRESS;
//         EXECUTE_REGISTER1_DATA <= DECODE_FORWARDED_REGISTER1_DATA;                                         
//         EXECUTE_REGISTER2_DATA <= DECODE_FORWARDED_REGISTER2_DATA;                                         
//         EXECUTE_IMMEDIATE <= DECODE_IMMEDIATE;
//         EXECUTE_DESTINATION_REGISTER_ADDRESS <= DECODE_DESTINATION_REGISTER_ADDRESS;
//         EXECUTE_FUNCT3 <= DECODE_FUNCT3;
//         EXECUTE_CSR_ADDRESS <= DECODE_CSR_ADDRESS;
//         EXECUTE_REGISTER_WRITE_ENABLE <= DECODE_REGISTER_WRITE_ENABLE;
//         EXECUTE_MEMORY_READ_ENABLE <= DECODE_MEMORY_READ_ENABLE;
//         EXECUTE_MEMORY_WRITE_ENABLE <= DECODE_MEMORY_WRITE_ENABLE;
//         EXECUTE_CSR_WRITE_ENABLE <= DECODE_CSR_WRITE_ENABLE;
//         EXECUTE_CSR_WRITE_USING_IMMEDIATE <= DECODE_CSR_WRITE_USING_IMMEDIATE;
//         EXECUTE_ALU_INPUT_A_IS_PC <= DECODE_ALU_INPUT_A_IS_PC;
//         EXECUTE_ALU_INPUT_B_IS_IMMEDIATE <= DECODE_ALU_INPUT_B_IS_IMMEDIATE;
//         EXECUTE_IS_A_BRANCH_INSTRUCTION <= DECODE_IS_A_BRANCH_INSTRUCTION;
//         EXECUTE_IS_A_JAL_INSTRUCTION <= DECODE_IS_A_JAL_INSTRUCTION;
//         EXECUTE_IS_A_JALR_INSTRUCTION <= DECODE_IS_A_JALR_INSTRUCTION;
//         EXECUTE_PREDICTED_BRANCH_TAKEN <= FETCH_PREDICTED_BRANCH_TAKEN;
//         EXECUTE_GSHARE_INDEX <= FETCH_GSHARE_INDEX;
//         EXECUTE_WRITEBACK_SELECT <= DECODE_WRITEBACK_SELECT;
//         EXECUTE_ALU_OPERATION <= DECODE_ALU_OPERATION;
//       end

//       if (FLUSH_FETCH_DECODE_EXECUTE) begin
//         FETCH_PC <= EXECUTE_ADJUST_NEXT_PC;
//         FETCH_RESPONSE_PC <= EXECUTE_ADJUST_NEXT_PC;
//         FETCH_PIPELINE_VALID <= 1'b0; 
//       end else begin
//         FETCH_PC <= FETCH_PREDICTED_NEXT_PC;
//         FETCH_RESPONSE_PC <= FETCH_PC;
//         FETCH_PIPELINE_VALID <= !FETCH_BRANCH_OFF_OR_CONTINUE;; // Fetch is a Branch Do not Use next Fetch until it gets resolved
//       end
//     end
//     else if (LOAD_STALL && !stall) begin // Load Stall Occurs:
//       // Memory Writeback Has Load Value Ready just update accordingly
//       MEMORY_VALID <= EXECUTE_VALID;
//       MEMORY_PC <= EXECUTE_PC;
//       MEMORY_INSTRUCTION <= EXECUTE_INSTRUCTION;
//       MEMORY_DESTINATION_REGISTER_ADDRESS <= EXECUTE_DESTINATION_REGISTER_ADDRESS;
//       MEMORY_FUNCT3 <= EXECUTE_FUNCT3;
//       MEMORY_ALU_RESULT <= EXECUTE_ALU_RESULT;
//       MEMORY_PC_ADD_4 <= EXECUTE_PC_ADD_4;
//       MEMORY_CSR_READ_DATA <= EXECUTE_CSR_READ_DATA;
//       MEMORY_REGISTER_WRITE_ENABLE <= EXECUTE_REGISTER_WRITE_ENABLE;
//       MEMORY_MEMORY_READ_ENABLE <= EXECUTE_MEMORY_READ_ENABLE;
//       MEMORY_WRITEBACK_SELECT <= EXECUTE_WRITEBACK_SELECT;

//       // Execute Has Load occuring so insert a NOP
//       EXECUTE_VALID <= 1'b0;
//       EXECUTE_INSTRUCTION <= INSTR_NOP;
//       EXECUTE_REGISTER_WRITE_ENABLE <= 1'b0;
//       EXECUTE_MEMORY_READ_ENABLE <= 1'b0;
//       EXECUTE_MEMORY_WRITE_ENABLE <= 1'b0;
//       EXECUTE_CSR_WRITE_ENABLE <= 1'b0;
//       EXECUTE_IS_A_BRANCH_INSTRUCTION <= 1'b0;
//       EXECUTE_IS_A_JAL_INSTRUCTION <= 1'b0;
//       EXECUTE_IS_A_JALR_INSTRUCTION <= 1'b0;
//       EXECUTE_DESTINATION_REGISTER_ADDRESS <= 5'd0;
//       EXECUTE_REGISTER1_ADDRESS <= 5'd0;
//       EXECUTE_REGISTER2_ADDRESS <= 5'd0;
//       EXECUTE_WRITEBACK_SELECT <= WRITEBACK_ALU;
//       EXECUTE_ALU_OPERATION <= ALU_XXX;
//       EXECUTE_PREDICTED_BRANCH_TAKEN <= 1'b0;
//       EXECUTE_GSHARE_INDEX <= '0;

//       // Do not update Fetch Decode Stage it shall be paused until load stall is not in place
//     end else begin
//       FETCH_RESPONSE_PC <= FETCH_PC; // Track Held PC for Cache
//       FETCH_PIPELINE_VALID <= 1'b1;
//     end

//     // Normal Stall: Do not update anything until stall ends 
//   end
// endmodule

// `default_nettype wire