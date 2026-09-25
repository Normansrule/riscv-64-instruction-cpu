`default_nettype none

import const_pkg::*;

module cache #(
  parameter int unsigned CACHE_TYPE = 0, // Default Cache Type is Direct Mapped (0), Other type to set is 2 way associative (1)
  parameter int unsigned LINES = 64, // Total Cache Lines (64 bytes x 64 bytes = 4096 bytes)
  parameter int unsigned CPU_WIDTH = CPU_INST_BITS, // CPU word width is 32 bits
  parameter int unsigned WORD_ADDR_BITS = CPU_ADDR_BITS - $clog2(CPU_INST_BITS/8) // 30 bit word Addresses
) (
  input logic clk, // clock 
  input logic reset, // reset
  input logic cpu_req_valid, // The CPU is requesting a memory transaction
  output logic cpu_req_ready, // The cache is ready for a CPU memory transaction
  input logic [WORD_ADDR_BITS-1:0] cpu_req_addr, // The address of the CPU memory transaction
  input logic [CPU_WIDTH-1:0] cpu_req_data, // The write data for a CPU memory write (ignored on reads)
  input logic [3:0] cpu_req_write, // The 4-bit write mask for a CPU memory transaction (each bit corresponds to the byte address within the word). 4’b0000 indicates a read.
  output logic cpu_resp_valid, // The cache has output valid data to the CPU after a memory read
  output logic [CPU_WIDTH-1:0] cpu_resp_data, // The data requested by the CPU
  output logic mem_req_valid, // 	The cache is requesting a memory transaction to main memory
  input logic mem_req_ready, // Main memory is ready for the cache to provide a memory address
  output logic [WORD_ADDR_BITS-1:$clog2(MEM_DATA_BITS/CPU_WIDTH)] mem_req_addr, // 	The address of the main memory transaction from the cache. Note that this address is narrower than the CPU byte address since main memory has wider data
  output logic mem_req_rw, // 1 if the main memory transaction is a write; 0 for a read.
  output logic mem_req_data_valid, // The cache is providing write data to main memory.
  input logic mem_req_data_ready, // Main memory is ready for the cache to provide write data.
  output logic [MEM_DATA_BITS-1:0] mem_req_data_bits, // Data to write to main memory from the cache (128 bits/4 words).
  output logic [(MEM_DATA_BITS/8)-1:0] mem_req_data_mask, // 	Byte-level write mask to main memory. May be 16’hFFFF for a full write.
  input logic mem_resp_valid, // The main memory response data is valid
  input logic [MEM_DATA_BITS-1:0] mem_resp_data // Main memory response data to the cache (128 bits/4 words).
);
// Cache Word Address Logic: | Tag (20 bits or 21 bits) | Line (6 or 5 bits) | Word (2 bits) | xx (2 bits) |
// Referenced Article: https://www.sciencedirect.com/topics/computer-science/set-associative-cache
// 4 sram22_256x32m4w8 for data array
// 1 sram22_64x32m4w8 for metadata

// Cache Specifications:
localparam int unsigned TOTAL_CACHE_WAYS = (CACHE_TYPE == 0) ? 1 : 2; // Direct Mapped has 1 Way, Associative has 2 Ways
localparam int CACHE_LINE_WORD_SIZE = 16; // 64 bytes per line / 4 bytes per word = 16 words per line
localparam int LINE_INDEX_BITS = $clog2(LINES / TOTAL_CACHE_WAYS); // Direct Mapped has 6 line bits, 2-way Associative has 5 line bits
localparam int WORD_OFFSET_BITS = $clog2(CACHE_LINE_WORD_SIZE); // 4 bits to index the word within a line
localparam int TAG_OFFSET_BITS = WORD_ADDR_BITS - LINE_INDEX_BITS - WORD_OFFSET_BITS; // Direct Mapped has 20 tag bits, 2-way Associative has 21 tag bits
localparam int WAY_INDEX_BITS = (TOTAL_CACHE_WAYS == 1) ? 1 : $clog2(TOTAL_CACHE_WAYS); // 1 bit to index the way within the cache (0 for direct mapped, 1 for 2 way associative)
localparam int DATA_ADDRESS_BITS = LINE_INDEX_BITS + 2; // 128-bit-wide data to SRAM Address: Direct Mapped 8 bits, 2-way Associative 7 bits 

localparam int WORDS_PER_MEMORY_TRANSACTION = MEM_DATA_BITS / CPU_WIDTH; // memory interface/length of word = 4 words in this case 128 bits (128 bits on the bus / 32 bit words = 4 words per bus)
localparam int MEMORY_TRANSACTION_CYCLES = CACHE_LINE_WORD_SIZE / WORDS_PER_MEMORY_TRANSACTION; // 16/4 = 4 cycles needed to transfer a line of memory in this case (16 words / 4 words per transaction = 4 transactions per line)
localparam int MEMORY_TRANSACTION_CYCLES_BITS = $clog2(MEMORY_TRANSACTION_CYCLES); // Store the amount of bits required to index amount of cycles used

function automatic logic [TAG_OFFSET_BITS-1:0] tag_address (input logic [WORD_ADDR_BITS-1:0] address);
  tag_address = address[WORD_ADDR_BITS-1 -: TAG_OFFSET_BITS]; // Set up reusable TAG address space
endfunction

function automatic logic [LINE_INDEX_BITS-1:0] line_address (input logic [WORD_ADDR_BITS-1:0] address);
  line_address = address[WORD_OFFSET_BITS +: LINE_INDEX_BITS]; // Set up reusable Line address space
endfunction

function automatic logic [31:0] metadata (input logic [TAG_OFFSET_BITS-1:0] tag_bits, input logic dirty_bit, input logic valid_bit);
  metadata = {{(32-TAG_OFFSET_BITS-2){1'b0}}, tag_bits, dirty_bit, valid_bit}; // | 32 bit alignment padding | TAG | DIRTY |VALID| packing for SRAM metadata structure
endfunction

// TAG SRAM:
logic [TOTAL_CACHE_WAYS-1:0] TAG_CHIP_ENABLE; // 0 means SRAM is IDLE, 1 means SRAM is active for reads and writes
logic [TOTAL_CACHE_WAYS-1:0] TAG_WRITE_ENABLE; // 0 means SRAM is being read, 1 means SRAM is being written to  
logic [TOTAL_CACHE_WAYS-1:0][3:0] TAG_WRITE_MASK; // First Index is which way the SRAM is being used, Second Index is which byte of 32 bits is being written to (1111 would be write all 32 bits)
logic [TOTAL_CACHE_WAYS-1:0][LINE_INDEX_BITS-1:0] TAG_ADDRESS; // First Index is which way the SRAM is being used, Second Index is the full TAG address which will determine which rows of SRAM Cache will be used
  
logic [TOTAL_CACHE_WAYS-1:0][31:0] TAG_DATA_IN; // First Index is which way the SRAM is being written to, Second Index is the full 32-bit word being written to the TAG SRAM
// Data In Logic:
// [0] = Valid Bit
// [1] = Dirty Bit
// [TAG_OFFSET_BITS+1:2] = TAG Bits (This is the Primary information being stored here)
// [31:TAG_OFFSET_BITS+2] = Unused (will just be filled with 0s)

logic [TOTAL_CACHE_WAYS-1:0][31:0] TAG_DATA_OUT; // First Index is which way the SRAM is being read from, Second Index is the full 32-bit word being read from the TAG SRAM
// Data Out Logic:
// [31:0] = Full 32-bit word read from TAG SRAM
// [0] = Valid Bit
// [1] = Dirty Bit
// [TAG_OFFSET_BITS+1:2] = TAG Bits 
// [31:TAG_OFFSET_BITS+2] = Unused

// Data SRAM:
// Data Address Components:
// LINE: Which row of Cache Lines to choose from (5 bits for Direct Mapped, 6 bits for 2 Way Associative)
// WORD: Which word of the Cache Line to choose from (2 bits since each line has 4 words)
logic [TOTAL_CACHE_WAYS-1:0] DATA_CHIP_ENABLE; // 0 means SRAM is IDLE, 1 means SRAM is active for reads and writes
logic [TOTAL_CACHE_WAYS-1:0] DATA_WRITE_ENABLE; // 0 means SRAM is being read, 1 means SRAM is being written to
logic [TOTAL_CACHE_WAYS-1:0][(MEM_DATA_BITS/8)-1:0] DATA_WRITE_MASK; // First Index is which way the SRAM is being used, Second Index is which byte of 128 bits is being written to (1111 1111 1111 1111 would be write all 128 bits)
logic [TOTAL_CACHE_WAYS-1:0][DATA_ADDRESS_BITS-1:0] DATA_ADDRESS; // First Index is which way the SRAM is being used, Second Index is the full Data address which will determine which rows of SRAM Cache will be used

logic [TOTAL_CACHE_WAYS-1:0][MEM_DATA_BITS-1:0] DATA_DATA_IN; // First Index is which way the SRAM is being written to, Second Index is the full 128-bit row being written to the Data SRAM
// Data In Logic:
// [31:0] = Word 0
// [63:32] = Word 1
// [95:64] = Word 2
// [127:96] = Word 3
  
logic [TOTAL_CACHE_WAYS-1:0][MEM_DATA_BITS-1:0] DATA_DATA_OUT; // First Index is which way the SRAM is being read from, Second Index is the full 128-bit row being read from the Data SRAM
// Data Out Logic:
// [31:0] = Word 0
// [63:32] = Word 1
// [95:64] = Word 2
// [127:96] = Word 3
  
logic [TOTAL_CACHE_WAYS-1:0] CACHE_VALID_BIT; // 0 means the cache block is empty or is free to use after a reset or an eviction of older data, 1 means the cache block is occupied
logic [TOTAL_CACHE_WAYS-1:0] CACHE_DIRTY_BIT; // 0 means the cache block is clean and can be evicted without writing back to main memory, 1 means the cache block is dirty and must be written back to main memory before eviction
logic [TOTAL_CACHE_WAYS-1:0][TAG_OFFSET_BITS-1:0] CACHE_TAG; // The stored TAG value for each way of the cache which will be compared against the incoming address TAG to determine if there is a hit or not
// Hit Will be defined as: CACHE_VALID_BIT[cache way] && (CACHE_TAG[cache way] == tag_address(cpu_req_addr))
// Cache Block is valid and the TAG address is the same as the Cache's TAG address

logic [LINES/TOTAL_CACHE_WAYS-1:0] LEAST_RECENTLY_USED_WAY; // Which way contains the entry to evict (not necessary for Direct Mapped)
logic [WAY_INDEX_BITS-1:0] SELECT_BROKEN_WAY_LINE; // When a miss occurs pick which way line to evict
logic WRITE_COMMITTED_THIS_HIT;


logic LOOKUP_CACHE_VALID; // At this point is SRAM holding a request 
logic [WORD_ADDR_BITS-1:0] LOOKUP_CACHE_ADDRESS; // At this point what address is being used
logic [CPU_WIDTH-1:0] LOOKUP_CACHE_DATA; // At this point what data is being used
logic [3:0] LOOKUP_CACHE_WRITE; // At this point what is the write mask looking like

logic [TOTAL_CACHE_WAYS-1:0] CACHE_HIT_PER_WAY; // 2 bits each representing whether a hit occured on that way
logic CACHE_HIT; // Generalized Cache Hit for all directions/ways
logic CACHE_INTENDS_TO_WRITE; // Determines whether or not the request will be to write into Cache
logic [WAY_INDEX_BITS-1:0] WHICH_WAY_CACHE_HIT; // Which way did Hit Occur?

// Combinational next-state values for the pipeline register (driven by the FSM section later)
logic LOOKUP_CACHE_VALID_NEXT; // Store next state whether or not SRAM is holding a request
logic [WORD_ADDR_BITS-1:0] LOOKUP_CACHE_ADDRESS_NEXT; // Store next state of the address being used
logic [CPU_WIDTH-1:0] LOOKUP_CACHE_DATA_NEXT; // Store next state of the data being used
logic [3:0] LOOKUP_CACHE_WRITE_NEXT; // Store next state of the write mask is looking like

genvar generate_cache_ways;
generate
  // Instantiate SRAMS and setup Cache Metadata Logic:
  for (generate_cache_ways = 0; generate_cache_ways < TOTAL_CACHE_WAYS; generate_cache_ways++) begin : gen_ways // (gen_ways referenced in par.yml)
    // Save Cache Metadata in Flip Flops instead of Cache to improve critical path
    logic [(LINES/TOTAL_CACHE_WAYS)-1:0] CACHE_TAG_VALID_Flip_Flops;
    logic [(LINES/TOTAL_CACHE_WAYS)-1:0] CACHE_TAG_DIRTY_Flip_Flops;
    logic [(LINES/TOTAL_CACHE_WAYS)-1:0][TAG_OFFSET_BITS-1:0] CACHE_TAG_BITS_Flip_Flops;

    always_ff @(posedge clk) begin
      if (reset) begin
        CACHE_TAG_VALID_Flip_Flops <= '0;
        CACHE_TAG_DIRTY_Flip_Flops <= '0;
      end else if (TAG_WRITE_ENABLE[generate_cache_ways]) begin
        CACHE_TAG_VALID_Flip_Flops[TAG_ADDRESS[generate_cache_ways]] <= TAG_DATA_IN[generate_cache_ways][0];
        CACHE_TAG_DIRTY_Flip_Flops[TAG_ADDRESS[generate_cache_ways]] <= TAG_DATA_IN[generate_cache_ways][1];
        CACHE_TAG_BITS_Flip_Flops [TAG_ADDRESS[generate_cache_ways]] <= TAG_DATA_IN[generate_cache_ways][2 +: TAG_OFFSET_BITS];
      end
    end
    
    // SRAM Metadata
    assign CACHE_VALID_BIT[generate_cache_ways] = CACHE_TAG_VALID_Flip_Flops[line_address(LOOKUP_CACHE_ADDRESS)]; // Valid Bit
    assign CACHE_DIRTY_BIT[generate_cache_ways] = CACHE_TAG_DIRTY_Flip_Flops[line_address(LOOKUP_CACHE_ADDRESS)]; // Dirty Bit
    assign CACHE_TAG[generate_cache_ways] = CACHE_TAG_BITS_Flip_Flops[line_address(LOOKUP_CACHE_ADDRESS)]; // TAG Bits
    // assign CACHE_VALID_BIT[generate_cache_ways] = TAG_DATA_OUT[generate_cache_ways][0]; // Valid Bit
    // assign CACHE_DIRTY_BIT[generate_cache_ways] = TAG_DATA_OUT[generate_cache_ways][1]; // Dirty Bit
    // assign CACHE_TAG[generate_cache_ways] = TAG_DATA_OUT[generate_cache_ways][2 +: TAG_OFFSET_BITS]; // TAG Bits

    // logic [5:0] FULL_TAG_ADDRESS; // 6 bits for 64 Cache lines
    logic [7:0] FULL_DATA_ADDRESS; // 8 Bits for 256 Cache Lines
    // assign FULL_TAG_ADDRESS = {{(6-LINE_INDEX_BITS){1'b0}}, TAG_ADDRESS[generate_cache_ways]};
    assign FULL_DATA_ADDRESS = {{(8-DATA_ADDRESS_BITS){1'b0}}, DATA_ADDRESS[generate_cache_ways]};

    // SRAM Logic from: sram22_64x32m4w8.v file on github
    // Direct Mapped Cache has 64 Cache Lines (all lines used for 1 way), 2 Way Associative Cache has 32 lines per way (half of the lines used for each way)
    // TAG Address stored technically only needs 1 Valid Bit + 1 Dirty Bit + 20 or 21 TAG Bits = 23 maximum bits to store per entry, closest to store is 32 bits
    // sram22_64x32m4w8 Cache_Tag ( // 64 Cache Lines x 32 Bits per line (Cache Defined in Par)
    //   .clk(clk), 
    //   .rstb(~reset), 
    //   .ce(TAG_CHIP_ENABLE[generate_cache_ways]), 
    //   .we(TAG_WRITE_ENABLE[generate_cache_ways]),
    //   .wmask(TAG_WRITE_MASK[generate_cache_ways]),
    //   .addr(FULL_TAG_ADDRESS),
    //   .din(TAG_DATA_IN[generate_cache_ways]), 
    //   .dout(TAG_DATA_OUT[generate_cache_ways])
    // );
    
    // 64 Cache Lines with 4 rows per line makes 256 Lines so that is how many rows needed
    // 128 bits of data stored per line 
    
    // Make sure that this is intantiated 4 times 
    genvar generate_data_lanes;
    for (generate_data_lanes = 0; generate_data_lanes < 4; generate_data_lanes++) begin : generate_cache_data_lanes
      sram22_256x32m4w8 Cache_Data_Lane ( // 256 Cache Lines x 128 Bits per line (Cache Defined in Par)
        .clk (clk),
        .rstb (~reset),
        .ce (DATA_CHIP_ENABLE[generate_cache_ways]),
        .we (DATA_WRITE_ENABLE[generate_cache_ways]),
        .wmask (DATA_WRITE_MASK[generate_cache_ways][generate_data_lanes*4 +: 4]),
        .addr (FULL_DATA_ADDRESS),
        .din (DATA_DATA_IN[generate_cache_ways][generate_data_lanes*32 +: 32]),
        .dout (DATA_DATA_OUT[generate_cache_ways][generate_data_lanes*32 +: 32])
      );
    end
  end
endgenerate

// Cache Hit Logic:
always_comb begin
  // Initialize Hit Logic to all zeros for each cycle
  CACHE_HIT_PER_WAY = '0;
  WHICH_WAY_CACHE_HIT = '0;

  // Check Hits for every possible way in this case there are 2 ways maximum
  for (int CURRENT_WAY = 0; CURRENT_WAY < TOTAL_CACHE_WAYS; CURRENT_WAY++) begin
    // A hit occurs when request is valid and the TAG address matches the actual TAG address stored in Cache SRAM
    CACHE_HIT_PER_WAY[CURRENT_WAY] = CACHE_VALID_BIT[CURRENT_WAY] && (CACHE_TAG[CURRENT_WAY] == tag_address(LOOKUP_CACHE_ADDRESS));

    // Only allow for 1 hit for 1 way per cycle:
    if (CACHE_HIT_PER_WAY[CURRENT_WAY]) begin 
      WHICH_WAY_CACHE_HIT = CURRENT_WAY[WAY_INDEX_BITS-1:0];
    end
  end
end

assign CACHE_HIT = LOOKUP_CACHE_VALID && (CACHE_HIT_PER_WAY != '0);
assign CACHE_INTENDS_TO_WRITE = (LOOKUP_CACHE_WRITE != 4'b0000);

logic [MEM_DATA_BITS-1:0] LOOKUP_CACHE_LINE; // At this point get data from 128-bit line row from specified way of data SRAM
logic [CPU_WIDTH-1:0] LOOKUP_CACHE_WORD; // At this point get data from 32-bit word based off of multiplexer output
logic [1:0] LOOKUP_CACHE_WORD_LANE; // Shows which of the 32 bit lanes to use
// Bottom 2 word bits determine which lane to write to or read from:
// 2'b00 = word 0 (bytes 0-3)
// 2'b01 = word 1 (bytes 4-7)
// 2'b10 = word 2 (bytes 8-11)
// 2'b11 = word 3 (bytes 12-15)

assign LOOKUP_CACHE_LINE = DATA_DATA_OUT[WHICH_WAY_CACHE_HIT]; // Get Data from Hit Position
assign LOOKUP_CACHE_WORD_LANE = LOOKUP_CACHE_ADDRESS[1:0]; // Select Word Lane 

// Read Word Lane Multiplexer:
always_comb begin
  unique case (LOOKUP_CACHE_WORD_LANE)
    2'b00: LOOKUP_CACHE_WORD = LOOKUP_CACHE_LINE[31:0]; // word 0
    2'b01: LOOKUP_CACHE_WORD = LOOKUP_CACHE_LINE[63:32]; // word 1
    2'b10: LOOKUP_CACHE_WORD = LOOKUP_CACHE_LINE[95:64]; // word 2
    2'b11: LOOKUP_CACHE_WORD = LOOKUP_CACHE_LINE[127:96]; // word 3
    default: LOOKUP_CACHE_WORD = LOOKUP_CACHE_LINE[31:0];
  endcase
end

logic [MEM_DATA_BITS-1:0] WRITE_DATA_BUFFER; // Data will go to all 4 lanes of SRAM, only 1 will actually be written
logic [(MEM_DATA_BITS/8)-1:0] FULL_WRITE_MASK; // Mask will determine which lane is actually written to

assign WRITE_DATA_BUFFER = {WORDS_PER_MEMORY_TRANSACTION{LOOKUP_CACHE_DATA}}; // copy the data to write 4 times

// Write Word Lane Multiplexer: 
always_comb begin
  unique case (LOOKUP_CACHE_WORD_LANE)
    2'b00: FULL_WRITE_MASK = {12'b0, LOOKUP_CACHE_WRITE}; // 0000 0000 0000 DATA (bytes 0-3)
    2'b01: FULL_WRITE_MASK = { 8'b0, LOOKUP_CACHE_WRITE, 4'b0}; // 0000 0000 DATA 0000 (bytes 4-7)
    2'b10: FULL_WRITE_MASK = { 4'b0, LOOKUP_CACHE_WRITE, 8'b0}; // 0000 DATA 0000 0000 (bytes 8-11)
    2'b11: FULL_WRITE_MASK = {LOOKUP_CACHE_WRITE, 12'b0}; // DATA 0000 0000 0000 (bytes 12-15)
    default: FULL_WRITE_MASK = '0;
  endcase
end

// Finite State Machine States:
typedef enum logic [3:0] {
  INITIALIZE_STATE, // Default State to prevent any unexpected behavior
  IDLE_STATE, // Idle State is ready for requests and drives the SRAM lookup logic when one comes in 
  SEARCH_HIT_MISS_STATE, // Combine Search, Hit, and Miss Decision in same state: SRAM result is valid determine if its a cache hit or miss, If its a hit either do a write or read, // If its a miss determine whether to go to writeback or main memory 
  SEND_TO_MEMORY_STATE, // Dirty Miss occurs and the data needs to go to main memory unfortunately
  FETCH_FROM_MEMORY_WRITE_TO_CACHE_STATE, // Combine Fetch from Memory and Write to Cache: From Memory the goal is to now find the new address for the new cache line since it was a miss, Write all relevant cache information to data SRAM
  REREAD_CONTINUE_STATE // Reread Info and Continue: After getting data from main memory set an SRAM read for the previous missed request and wait a single cycle, SRAM should not be set up correctly with the appropriate information and is now a hit
} state_t;

state_t current_state;
state_t next_state;

// Initalization State Signals:
logic [LINE_INDEX_BITS-1:0] RESET_LINE_COUNTER;
logic [LINE_INDEX_BITS-1:0] RESET_LINE_COUNTER_NEXT;

// Important Information to Save on a Miss (Generalized Miss State Signals):
logic [WORD_ADDR_BITS-1:0] CACHE_MISS_ADDRESS; // Save associated address of the request that was classified as a miss
logic [CPU_WIDTH-1:0] CACHE_MISS_DATA; // Save associated Write Data for later
logic [3:0] CACHE_MISS_WRITE_MASK; // Save associated Write Mask for later
logic [TAG_OFFSET_BITS-1:0] BROKEN_TAG_LINE; // Since its a miss the address will be evicted save the TAG of this line
logic [WAY_INDEX_BITS-1:0] BROKEN_WAY_LINE; // Since its a miss the way will be evicted save the specific way of this line

// Important information regarding how many moves were taken over the memory bus
logic [MEMORY_TRANSACTION_CYCLES_BITS-1:0] TRANSACTION_COUNT;
logic [MEMORY_TRANSACTION_CYCLES_BITS-1:0] TRANSACTION_COUNT_NEXT;

always_comb begin
  // Hold Current State Values Before Making any Transactions
  next_state = current_state;
  RESET_LINE_COUNTER_NEXT = RESET_LINE_COUNTER;
  TRANSACTION_COUNT_NEXT = TRANSACTION_COUNT;

  unique case (current_state)
    INITIALIZE_STATE: begin
      if (RESET_LINE_COUNTER == ((LINES/TOTAL_CACHE_WAYS) - 1)) begin 
        next_state = IDLE_STATE; // If the Last Entry has been Reset Move onto Idle State
      end else begin
        RESET_LINE_COUNTER_NEXT = RESET_LINE_COUNTER + 1'b1; // Continue to next entry to reset
      end
    end

    IDLE_STATE: begin
      if (cpu_req_valid) begin
        next_state = SEARCH_HIT_MISS_STATE; // If the Request was Valid continue to determine if its a hit or miss
      end
    end

    SEARCH_HIT_MISS_STATE: begin
      if (CACHE_HIT || WRITE_COMMITTED_THIS_HIT) begin
        if (cpu_req_valid && (cpu_req_addr != LOOKUP_CACHE_ADDRESS || cpu_req_write != LOOKUP_CACHE_WRITE)) begin
          next_state = IDLE_STATE; // If Cache hit occurs we celebrate! (Yippee!) Go back to Idle for next request, If the Request was no longer valid then go back to idle state, If the address changed or the write mask changed then go back to idle state since the hit information is no longer useful 
        end
      end else if (CACHE_VALID_BIT[SELECT_BROKEN_WAY_LINE] && CACHE_DIRTY_BIT[SELECT_BROKEN_WAY_LINE]) begin
          next_state = SEND_TO_MEMORY_STATE; // If the cache block is valid and dirty then we need to write back to main memory before data can be evicted and then new data can be fetched
      end else begin
          next_state = FETCH_FROM_MEMORY_WRITE_TO_CACHE_STATE; // If the cache block is not dirty then the data can be fetched from memory and written to the cache without writing back to main memory first
      end
    end

    SEND_TO_MEMORY_STATE: begin
      if (mem_req_ready && mem_req_data_ready) begin // memory request is ready and the data is ready then memory can be set
        if (TRANSACTION_COUNT == MEMORY_TRANSACTION_CYCLES-1) begin // For this design 4 transaction are needed to write the whole line
          TRANSACTION_COUNT_NEXT = '0; // reset for next part for fetching from memory
          next_state = FETCH_FROM_MEMORY_WRITE_TO_CACHE_STATE; // move onto the fetching from memory state 
        end else begin
          TRANSACTION_COUNT_NEXT = TRANSACTION_COUNT + 1'b1; // move along to next transaction sending to memory isn't fully completed yet need 4 full transactions
        end
      end
    end

    FETCH_FROM_MEMORY_WRITE_TO_CACHE_STATE: begin
      if (mem_resp_valid) begin
        if (TRANSACTION_COUNT == MEMORY_TRANSACTION_CYCLES-1) begin
          TRANSACTION_COUNT_NEXT = '0; // reset for fetching from memory
          next_state = REREAD_CONTINUE_STATE; // If data from memory was ready to be read it is time to move onto writing to cache 
        end else begin
          TRANSACTION_COUNT_NEXT = TRANSACTION_COUNT + 1'b1; // move along to next transaction writing to memory it is not complete yet
        end
      end
    end

    REREAD_CONTINUE_STATE: begin
      next_state = SEARCH_HIT_MISS_STATE; // After waiting a cycle to have SRAM update with with the correct information to resolve the miss turning it into a hit
    end

    default: begin
      next_state = IDLE_STATE; // For whatever reason if there is some unexpected behavior in the states just go start back at the IDLE state
    end
  endcase
end

always_comb begin
  // Hold Transaction Data and Changed Based on Current State
  LOOKUP_CACHE_VALID_NEXT = LOOKUP_CACHE_VALID;
  LOOKUP_CACHE_ADDRESS_NEXT = LOOKUP_CACHE_ADDRESS;
  LOOKUP_CACHE_DATA_NEXT = LOOKUP_CACHE_DATA;
  LOOKUP_CACHE_WRITE_NEXT = LOOKUP_CACHE_WRITE;

  unique case (current_state)
    IDLE_STATE: begin
      if (cpu_req_valid) begin // Make sure the CPU Request is valid before changing values
        LOOKUP_CACHE_VALID_NEXT = 1'b1; // Set next cache request to be true
        LOOKUP_CACHE_ADDRESS_NEXT = cpu_req_addr; // Save address of the CPU request
        LOOKUP_CACHE_DATA_NEXT = cpu_req_data; // Save write data of the CPU request 
        LOOKUP_CACHE_WRITE_NEXT = cpu_req_write; // Save byte mask of the CPU request 
      end else begin
        LOOKUP_CACHE_VALID_NEXT = 1'b0; // There is no request thus do not update anything
      end
    end

    SEARCH_HIT_MISS_STATE: begin
      if (next_state != SEARCH_HIT_MISS_STATE) begin
        LOOKUP_CACHE_VALID_NEXT = 1'b0;
      end
    end

    REREAD_CONTINUE_STATE: begin
      LOOKUP_CACHE_VALID_NEXT = 1'b1; // For dealing with the Miss Need to Look back at the Previous Missed Data
      LOOKUP_CACHE_ADDRESS_NEXT = CACHE_MISS_ADDRESS; // Go back to original address when miss occurred 
      LOOKUP_CACHE_DATA_NEXT = CACHE_MISS_DATA; // Place the correct data during write
      LOOKUP_CACHE_WRITE_NEXT = CACHE_MISS_WRITE_MASK; // Follow same requested write mask
    end

    default: begin
      LOOKUP_CACHE_VALID_NEXT = 1'b0; // No data look ups are needed for any of the other states
    end
  endcase
end

always_ff @(posedge clk) begin
  if (reset) begin
    current_state <= INITIALIZE_STATE; 
    LOOKUP_CACHE_VALID <= 1'b0; 
    RESET_LINE_COUNTER <= '0; 
    TRANSACTION_COUNT <= '0; 
    LEAST_RECENTLY_USED_WAY <= '0;
    WRITE_COMMITTED_THIS_HIT <= 1'b0;
  end else begin
    // Hold Transaction Data and Changed Based on Current State
    // Update State to what was defined by Finite State Machine
    current_state <= next_state; 
    // Update Pipeline Registered defined by Finite State Machine
    RESET_LINE_COUNTER <= RESET_LINE_COUNTER_NEXT; 
    TRANSACTION_COUNT <= TRANSACTION_COUNT_NEXT; 
    LOOKUP_CACHE_VALID <= LOOKUP_CACHE_VALID_NEXT;
    LOOKUP_CACHE_ADDRESS <= LOOKUP_CACHE_ADDRESS_NEXT; 
    LOOKUP_CACHE_DATA <= LOOKUP_CACHE_DATA_NEXT; 
    LOOKUP_CACHE_WRITE <= LOOKUP_CACHE_WRITE_NEXT; 

    if (current_state != SEARCH_HIT_MISS_STATE) begin
      WRITE_COMMITTED_THIS_HIT <= 1'b0;
    end else if (CACHE_INTENDS_TO_WRITE && CACHE_HIT && !WRITE_COMMITTED_THIS_HIT) begin
      WRITE_COMMITTED_THIS_HIT <= 1'b1;
    end

    if (current_state == SEARCH_HIT_MISS_STATE && !CACHE_HIT && LOOKUP_CACHE_VALID) begin 
      CACHE_MISS_ADDRESS <= LOOKUP_CACHE_ADDRESS; // if its currently the search state and a miss occurs remember the address for resolving the miss
      CACHE_MISS_DATA <= LOOKUP_CACHE_DATA; // if its currently the search state and a miss occurs remember the write data
      CACHE_MISS_WRITE_MASK <= LOOKUP_CACHE_WRITE; // if its currently the search state and a miss occurs remember the write mask
      BROKEN_WAY_LINE <= SELECT_BROKEN_WAY_LINE; // if its currently the search state and a miss occurs remember which way will need to be evicted
      BROKEN_TAG_LINE <= CACHE_TAG[SELECT_BROKEN_WAY_LINE]; // In the case where its a miss with a writeback remember the TAG
    end

    if (TOTAL_CACHE_WAYS > 1) begin
      // Cache Hits, but is not a Write
      if (current_state == SEARCH_HIT_MISS_STATE && CACHE_HIT) begin // Read hit only need to update Least Recently Used Way
        LEAST_RECENTLY_USED_WAY[line_address(LOOKUP_CACHE_ADDRESS)] <= ~WHICH_WAY_CACHE_HIT[0]; // This is a binary transaction read way is a hit and is used thus the other way must be the least recently used part of cache line
      end else if (current_state == REREAD_CONTINUE_STATE) begin // Resolved Miss
        LEAST_RECENTLY_USED_WAY[line_address(CACHE_MISS_ADDRESS)] <= ~BROKEN_WAY_LINE[0]; // After miss is resolved and acts as a hit update the least recently used entry accordingly
      end
    end
  end
end

generate
  if (TOTAL_CACHE_WAYS == 1) begin : generate_direct_mapped_eviction
    assign SELECT_BROKEN_WAY_LINE = '0; 
  end else begin : generate_two_way_eviction_least_recently_used
    always_comb begin
      SELECT_BROKEN_WAY_LINE = 1'b0; // default value for synthesis purposes
      if (LOOKUP_CACHE_VALID) begin
        if (CACHE_VALID_BIT[0] === 1'b0) begin
          SELECT_BROKEN_WAY_LINE = 1'b0; // way 0 is empty can use it (no eviction necessary)
        end else if (CACHE_VALID_BIT[1] === 1'b0) begin
          SELECT_BROKEN_WAY_LINE = 1'b1; // way 1 is empty can use it (no eviction necessary)
        end else begin
          SELECT_BROKEN_WAY_LINE = LEAST_RECENTLY_USED_WAY[line_address(LOOKUP_CACHE_ADDRESS)]; // Both ways are being used meaning evict the least recently used way at the specific address
        end
      end
    end
  end
endgenerate

always_comb begin
  for (int CURRENT_WAY = 0; CURRENT_WAY < TOTAL_CACHE_WAYS; CURRENT_WAY++) begin
    TAG_CHIP_ENABLE [CURRENT_WAY] = 1'b0;
    TAG_WRITE_ENABLE[CURRENT_WAY] = 1'b0;
    TAG_WRITE_MASK [CURRENT_WAY] = '0;
    TAG_ADDRESS [CURRENT_WAY] = '0;
    TAG_DATA_IN [CURRENT_WAY] = '0;
    DATA_CHIP_ENABLE [CURRENT_WAY] = 1'b0;
    DATA_WRITE_ENABLE [CURRENT_WAY] = 1'b0;
    DATA_WRITE_MASK [CURRENT_WAY] = '0;
    DATA_ADDRESS [CURRENT_WAY] = '0;
    DATA_DATA_IN [CURRENT_WAY] = '0;
  end

  unique case (current_state)
    INITIALIZE_STATE: begin
      for (int CURRENT_WAY = 0; CURRENT_WAY < TOTAL_CACHE_WAYS; CURRENT_WAY++) begin
        TAG_CHIP_ENABLE [CURRENT_WAY] = 1'b1; // Enable the TAG SRAM for said way
        TAG_WRITE_ENABLE [CURRENT_WAY] = 1'b1; // Enable Write for said way
        TAG_WRITE_MASK [CURRENT_WAY] = 4'hF; // Entire TAG will be written to
        TAG_ADDRESS [CURRENT_WAY] = RESET_LINE_COUNTER; // Set up address to reset every line of the TAG SRAM Cache
        TAG_DATA_IN [CURRENT_WAY] = '0; // SRAM Metadata becomes VALID = 0, DIRTY = 0, TAG = 0
      end
    end

    IDLE_STATE: begin
      if (cpu_req_valid) begin // If CPU Request is Valid setup for SRAM lookup to determine metadata
        for (int CURRENT_WAY = 0; CURRENT_WAY < TOTAL_CACHE_WAYS; CURRENT_WAY++) begin
          TAG_CHIP_ENABLE [CURRENT_WAY] = 1'b1; // Read SRAM TAG at said way
          TAG_ADDRESS [CURRENT_WAY] = line_address(cpu_req_addr); // Tag Address from line bits of CPU_REQUEST_ADDRESS
          DATA_CHIP_ENABLE[CURRENT_WAY] = 1'b1; // Read SRAM Data at said way
          DATA_ADDRESS [CURRENT_WAY] = {line_address(cpu_req_addr), cpu_req_addr[3:2]}; // Data Address from line bits + top 2 word bits of CPU_REQUEST_ADDRESS
        end
      end
    end

    SEARCH_HIT_MISS_STATE: begin
      if (CACHE_INTENDS_TO_WRITE && CACHE_HIT && !WRITE_COMMITTED_THIS_HIT) begin // Hit Logic: write data and update the SRAM metadata accordingly
        // TAG SRAM metadata should now show Valid = 1 and Dirty = 1 with the current TAG value
        TAG_CHIP_ENABLE [WHICH_WAY_CACHE_HIT] = 1'b1;
        TAG_WRITE_ENABLE [WHICH_WAY_CACHE_HIT] = 1'b1;
        TAG_WRITE_MASK [WHICH_WAY_CACHE_HIT] = 4'hF;
        TAG_ADDRESS [WHICH_WAY_CACHE_HIT] = line_address(LOOKUP_CACHE_ADDRESS); // Tag Address from line bits of Cache Address from Lookup
        TAG_DATA_IN [WHICH_WAY_CACHE_HIT] = metadata(tag_address(LOOKUP_CACHE_ADDRESS), 1'b1, 1'b1); // Metadata: | TAG | Dirty Bit | Valid Bit |

        // DATA SRAM should now have data written to specified lane
        DATA_CHIP_ENABLE [WHICH_WAY_CACHE_HIT] = 1'b1;
        DATA_WRITE_ENABLE [WHICH_WAY_CACHE_HIT] = 1'b1;
        DATA_WRITE_MASK [WHICH_WAY_CACHE_HIT] = FULL_WRITE_MASK; // Mask will be aligned to write to specific word lane
        DATA_ADDRESS [WHICH_WAY_CACHE_HIT] = {line_address(LOOKUP_CACHE_ADDRESS), LOOKUP_CACHE_ADDRESS[3:2]}; // Line bits of Cache Address + top 2 word bits from Lookup 
        DATA_DATA_IN [WHICH_WAY_CACHE_HIT] = WRITE_DATA_BUFFER; // Copy Data across all 4 of the lanes
      end
    end

    SEND_TO_MEMORY_STATE: begin
      DATA_CHIP_ENABLE [BROKEN_WAY_LINE] = 1'b1; // Read which way is broken for eviction 
      DATA_ADDRESS [BROKEN_WAY_LINE] = {line_address(CACHE_MISS_ADDRESS), TRANSACTION_COUNT}; // Look through all 4 rows of the missed line data
    end

    FETCH_FROM_MEMORY_WRITE_TO_CACHE_STATE: begin
      if (mem_resp_valid) begin // Eviction can Occur
        DATA_CHIP_ENABLE [BROKEN_WAY_LINE] = 1'b1;
        DATA_WRITE_ENABLE [BROKEN_WAY_LINE] = 1'b1;
        DATA_WRITE_MASK [BROKEN_WAY_LINE] = '1; // Overwrite all the words since its an eviction
        DATA_ADDRESS [BROKEN_WAY_LINE] = {line_address(CACHE_MISS_ADDRESS), TRANSACTION_COUNT}; // Address of the Cache Miss with transaction count for all 16 words being evicted for the line 4 words per transaction
        DATA_DATA_IN [BROKEN_WAY_LINE] = mem_resp_data; // Write in the 128 bit data from memory per transaction to the data SRAM 

        // Once the full line has been replaced update the SRAM TAG Metdata new TAG is Valid and not Dirty
        if (TRANSACTION_COUNT == (MEMORY_TRANSACTION_CYCLES-1)) begin
          TAG_CHIP_ENABLE [BROKEN_WAY_LINE] = 1'b1;
          TAG_WRITE_ENABLE [BROKEN_WAY_LINE] = 1'b1;
          TAG_WRITE_MASK [BROKEN_WAY_LINE] = 4'hF;
          TAG_ADDRESS [BROKEN_WAY_LINE] = line_address(CACHE_MISS_ADDRESS);
          TAG_DATA_IN [BROKEN_WAY_LINE] = metadata(tag_address(CACHE_MISS_ADDRESS), 1'b0, 1'b1); // | New TAG | Not Dirty | is Valid |
        end
      end
    end

    REREAD_CONTINUE_STATE: begin
      for (int CURRENT_WAY = 0; CURRENT_WAY < TOTAL_CACHE_WAYS; CURRENT_WAY++) begin
        TAG_CHIP_ENABLE [CURRENT_WAY] = 1'b1; // Reread TAG for the missed Cache Line for specified way
        TAG_ADDRESS [CURRENT_WAY] = line_address(CACHE_MISS_ADDRESS);
        DATA_CHIP_ENABLE [CURRENT_WAY] = 1'b1; // Reread Data for the missed Cache Line for specified way
        DATA_ADDRESS [CURRENT_WAY] = {line_address(CACHE_MISS_ADDRESS), CACHE_MISS_ADDRESS[3:2]}; // Line bits of Missed Cache Address + top 2 word bits from Missed Cache Address 
      end
    end
    default: ; // No default logic needed just for syntax
  endcase
end

always_comb begin
  mem_req_valid = 1'b0;
  mem_req_rw = 1'b0;
  mem_req_addr = '0;
  mem_req_data_valid = 1'b0;
  mem_req_data_bits = '0;
  mem_req_data_mask = '0;

  unique case (current_state)
    SEND_TO_MEMORY_STATE: begin
      mem_req_valid = 1'b1; // Request Memory Transaction
      mem_req_rw = 1'b1; // Write to Memory Enabled
      mem_req_addr = {BROKEN_TAG_LINE, line_address(CACHE_MISS_ADDRESS), TRANSACTION_COUNT}; // Memory Request Address is | Previous TAG | Line Bits | Specific Transaction Words |
      mem_req_data_valid = 1'b1; // Request Data is ready to go to Memory
      mem_req_data_bits = DATA_DATA_OUT[BROKEN_WAY_LINE]; // Set up which row is being used for said eviction way
      mem_req_data_mask = '1; // Write all 4 words
  end

    FETCH_FROM_MEMORY_WRITE_TO_CACHE_STATE: begin
      if (TRANSACTION_COUNT == '0) begin // Only want to send memory request once for entire data line
        mem_req_valid = 1'b1; // Request Memory Transaction
        mem_req_rw = 1'b0; // Read from Memory Enabled
        mem_req_addr = {tag_address(CACHE_MISS_ADDRESS), line_address(CACHE_MISS_ADDRESS), {MEMORY_TRANSACTION_CYCLES_BITS{1'b0}}}; // Get Data based on Missed Address and default transaction 
      end
    end
    default: ; // No default logic needed just for syntax
  endcase
end

logic QUEUED_CACHE_HELD_REQUEST; // Determine if current request is being used for hit or miss
assign QUEUED_CACHE_HELD_REQUEST = cpu_req_valid && (cpu_req_addr == LOOKUP_CACHE_ADDRESS) && (cpu_req_write == LOOKUP_CACHE_WRITE); 
assign cpu_req_ready  = (current_state == IDLE_STATE && !cpu_req_valid) || (current_state == SEARCH_HIT_MISS_STATE && (CACHE_HIT || WRITE_COMMITTED_THIS_HIT) && (QUEUED_CACHE_HELD_REQUEST || !cpu_req_valid)); // Request is Ready when in IDLE State or if its information that is going to be written to Cache and was the same held cache request
assign cpu_resp_valid = (current_state == SEARCH_HIT_MISS_STATE) && CACHE_HIT && !CACHE_INTENDS_TO_WRITE && (QUEUED_CACHE_HELD_REQUEST || !cpu_req_valid); // Response is Valid when Hit and is Read or is resolved Miss and is Read and there is a current request being held and no write to cache is occuring
assign cpu_resp_data = LOOKUP_CACHE_WORD; // Response Data is always from the look up info from the Data SRAM

endmodule

`default_nettype wire

// `default_nettype none

// import const_pkg::*;

// module cache #(
//   parameter int unsigned LINES = 64,
//   parameter int unsigned CPU_WIDTH = CPU_INST_BITS,
//   parameter int unsigned WORD_ADDR_BITS = CPU_ADDR_BITS - $clog2(CPU_INST_BITS/8)
// ) (
//   input  logic                         clk,
//   input  logic                         reset,

//   input  logic                         cpu_req_valid,
//   output logic                         cpu_req_ready,
//   input  logic [WORD_ADDR_BITS-1:0]    cpu_req_addr,
//   input  logic [CPU_WIDTH-1:0]         cpu_req_data,
//   input  logic [3:0]                   cpu_req_write,

//   output logic                         cpu_resp_valid,
//   output logic [CPU_WIDTH-1:0]         cpu_resp_data,

//   output logic                         mem_req_valid,
//   input  logic                         mem_req_ready,
//   output logic [WORD_ADDR_BITS-1:$clog2(MEM_DATA_BITS/CPU_WIDTH)] mem_req_addr,
//   output logic                         mem_req_rw,
//   output logic                         mem_req_data_valid,
//   input  logic                         mem_req_data_ready,
//   output logic [MEM_DATA_BITS-1:0]     mem_req_data_bits,
//   output logic [(MEM_DATA_BITS/8)-1:0] mem_req_data_mask,

//   input  logic                         mem_resp_valid,
//   input  logic [MEM_DATA_BITS-1:0]     mem_resp_data
// );
// localparam int CACHE_LINE_WORD_SIZE = 16;
// localparam int OFFSET_BITS = $clog2(CACHE_LINE_WORD_SIZE);
// localparam int INDEX_BITS = $clog2(LINES);
// localparam int TAG_BITS = WORD_ADDR_BITS - INDEX_BITS - OFFSET_BITS;
// localparam int WORDS_PER_MEMORY_TRANSACTION = MEM_DATA_BITS / CPU_WIDTH;
// localparam int MEMORY_TRANSACTION_CYCLES = CACHE_LINE_WORD_SIZE / WORDS_PER_MEMORY_TRANSACTION;

// //meta data signals
// logic metadata_ce;
// logic metadata_we;
// logic [3:0] metadata_wmask;
// logic [5:0] metadata_addr;
// logic [31:0] metadata_din;
// logic [31:0] metadata_dout;

// //meta data instantiation
// sram22_64x32m4w8 Cache_Tag (
//   .clk(clk), 
//   .rstb(~reset), 
//   .ce(metadata_ce), 
//   .we(metadata_we),
//   .wmask(metadata_wmask), 
//   .addr(metadata_addr), 
//   .din(metadata_din), 
//   .dout(metadata_dout)
// );

// //data signals
// logic [3:0] data_ce;
// logic [3:0] data_we;
// logic [3:0][3:0] data_wmask;
// logic [3:0][7:0] data_addr;
// logic [3:0][31:0] data_din;
// logic [3:0][31:0] data_dout;


// // data instantiation
// sram22_256x32m4w8 Cache_Data0 (
//   .clk(clk), 
//   .rstb(~reset), 
//   .ce(data_ce[0]), 
//   .we(data_we[0]),
//   .wmask(data_wmask[0]), 
//   .addr(data_addr[0]), 
//   .din(data_din[0]), 
//   .dout(data_dout[0])
// );

// sram22_256x32m4w8 Cache_Data1 (
//   .clk(clk), 
//   .rstb(~reset), 
//   .ce(data_ce[1]), 
//   .we(data_we[1]),
//   .wmask(data_wmask[1]), 
//   .addr(data_addr[1]), 
//   .din(data_din[1]), 
//   .dout(data_dout[1])
// );

// sram22_256x32m4w8 Cache_Data2 (
//   .clk(clk), 
//   .rstb(~reset), 
//   .ce(data_ce[2]), 
//   .we(data_we[2]),
//   .wmask(data_wmask[2]), 
//   .addr(data_addr[2]), 
//   .din(data_din[2]), 
//   .dout(data_dout[2])
// );

// sram22_256x32m4w8 Cache_Data3 (
//   .clk(clk), 
//   .rstb(~reset), 
//   .ce(data_ce[3]), 
//   .we(data_we[3]),
//   .wmask(data_wmask[3]), 
//   .addr(data_addr[3]), 
//   .din(data_din[3]), 
//   .dout(data_dout[3])
// );

// //states
// typedef enum logic [3:0] {
//   S_INITIALIZE, //set to zero
//   S_IDLE, //waiting for request
//   S_SEARCH, // request given, now searching
//   S_HIT,
//   S_SEND_TO_MEMORY,
//   S_FETCH_FROM_MEMORY,
//   S_WRITE_TO_CACHE,
//   S_REREAD
// } state_t;

// state_t state;
// state_t next_state;

// logic [TAG_BITS-1:0] cpu_requested_tag;
// logic [INDEX_BITS-1:0] cpu_requested_index;
// logic [OFFSET_BITS-1:0] cpu_requested_offset;

// assign cpu_requested_offset = cpu_req_addr[OFFSET_BITS-1:0];
// assign cpu_requested_index = cpu_req_addr[OFFSET_BITS +: INDEX_BITS];
// assign cpu_requested_tag = cpu_req_addr[WORD_ADDR_BITS-1 -: TAG_BITS];

// logic [WORD_ADDR_BITS-1:0] requested_address;
// logic [CPU_WIDTH-1:0] requested_data;
// logic [3:0] requested_write_mask;

// logic [TAG_BITS-1:0] requested_tag;
// logic [INDEX_BITS-1:0] requested_index;
// logic [OFFSET_BITS-1:0] requested_offset;

// assign requested_offset = requested_address[OFFSET_BITS-1:0];
// assign requested_index = requested_address[OFFSET_BITS +: INDEX_BITS];
// assign requested_tag = requested_address[WORD_ADDR_BITS-1 -: TAG_BITS];

// logic request_is_write;
// assign request_is_write = (requested_write_mask != 4'b0000);

// logic metadata_is_valid;
// logic metadata_is_dirty;
// logic [TAG_BITS-1:0] metadata_tag;
// logic hit;

// assign metadata_is_valid = metadata_dout[31];
// assign metadata_is_dirty = metadata_dout[30];
// assign metadata_tag = metadata_dout[TAG_BITS-1:0];
// assign hit = metadata_is_valid && (metadata_tag == requested_tag);

// logic [1:0] which_SRAM;
// logic [1:0] SRAM_entry;
// assign which_SRAM = requested_offset[1:0];
// assign SRAM_entry = requested_offset[3:2];

// logic [7:0] SRAM_address;
// assign SRAM_address = {requested_index, SRAM_entry};

// // Set up 32-bit Write Mask: (Sign extend each 8 bit word based on original requested 4 bit byte mask)
// logic [31:0] write_byte_mask_32;
// assign write_byte_mask_32 = {{8{requested_write_mask[3]}}, {8{requested_write_mask[2]}}, {8{requested_write_mask[1]}}, {8{requested_write_mask[0]}}};

// logic [31:0] write_merged_data;
// assign write_merged_data = (data_dout[which_SRAM] & ~write_byte_mask_32) | (requested_data &  write_byte_mask_32);
// // SRAM Data and opposite write mask or Data to store and write mask (this is necessary in order to merge bytes and halfwords with the current data without having alignment issues)

// logic [$clog2(MEMORY_TRANSACTION_CYCLES)-1:0] transaction;

// logic [7:0] cache_line_entry;
// assign cache_line_entry = {requested_index, transaction};

// logic [WORD_ADDR_BITS-3:0] writeback_memory_address;
// logic [TAG_BITS-1:0] old_cache_tag;

// logic write_address_received;
// logic write_data_received;

// assign writeback_memory_address = {old_cache_tag, requested_index, transaction};

// logic [INDEX_BITS-1:0] resetting_index;

// logic [WORD_ADDR_BITS-3:0] actual_memory_base_address;
// assign actual_memory_base_address = {requested_tag, requested_index, {$clog2(MEMORY_TRANSACTION_CYCLES){1'b0}}};

// logic [CPU_WIDTH-1:0] cpu_data_flip_flop_d;
// logic [CPU_WIDTH-1:0] cpu_data_flip_flop_q;

// always_ff @(posedge clk) begin
//   if (reset) begin
//     cpu_data_flip_flop_q <= '0;
//   end else if (cpu_resp_valid) begin
//     cpu_data_flip_flop_q <= cpu_data_flip_flop_d;
//   end
// end

// assign cpu_resp_data = cpu_resp_valid ? cpu_data_flip_flop_d : cpu_data_flip_flop_q;

// always_ff @(posedge clk) begin

//   if (mem_req_valid) begin
//   $display("CACHE MEMREQ state=%0d rw=%b addr=%h reqaddr=%h reset=%b",
//            state, mem_req_rw, mem_req_addr, requested_address, reset);
// end

//   if (reset) begin
//     state <= S_INITIALIZE;
//     requested_address <= '0;
//     requested_data <= '0;
//     requested_write_mask <= '0;
//     transaction <= '0;
//     old_cache_tag <= '0;
//     resetting_index <= '0;
//     write_address_received <= 1'b0;
//     write_data_received <= 1'b0;
//   end else begin
//     state <= next_state;

//     //resets meta data cache
//     if (state == S_INITIALIZE) begin
//       if (resetting_index != LINES - 1) begin
//         resetting_index <= resetting_index + 1'b1;
//       end
//     end

//     //idling and cpu sends request
//     if (state == S_IDLE && cpu_req_valid) begin
//       requested_address <= cpu_req_addr;
//       requested_data <= cpu_req_data;
//       requested_write_mask <= cpu_req_write;
//     end

//     if (state == S_HIT && cpu_req_valid && cpu_req_addr != requested_address && !(|cpu_req_write) && cpu_req_addr[WORD_ADDR_BITS-1:OFFSET_BITS] == requested_address[WORD_ADDR_BITS-1:OFFSET_BITS]) begin
//     requested_address <= cpu_req_addr;
//     requested_write_mask <= 4'b0000;
//     end

//     //on miss, reset trascations to zero
//     if (state == S_SEARCH && !hit) begin
//       transaction <= '0;

//       //save old tag
//       if (metadata_is_valid && metadata_is_dirty) begin
//         old_cache_tag <= metadata_tag;
//       end
//     end

//     //writeback handshakes
//     if (state == S_SEND_TO_MEMORY) begin
      
//       // Address Good ANDDDD Valid Memory Request
//       if (mem_req_ready && mem_req_valid) begin
//         write_address_received <= 1'b1; //address accepted
//       end

//       // Data Good ANDDDD Valid Data Request
//       if (mem_req_data_ready && mem_req_data_valid) begin
//         write_data_received <= 1'b1; //data accepted
//       end

//     if ((write_address_received || (mem_req_valid && mem_req_ready)) && (write_data_received || (mem_req_data_valid && mem_req_data_ready))) begin
//       write_address_received <= 1'b0; // write address done -> reset for next time
//       write_data_received    <= 1'b0; // write data done -> reset for next time
//       // cache to memory transition (combined transition logic with addressing and data logic)
//       if (transaction == MEMORY_TRANSACTION_CYCLES - 1) begin
//         transaction <= '0; //no more transactions needed
//       end else begin
//         transaction <= transaction + 1'b1; // go to next transaction 
//       end
//     end
//   end
    
//   // memory to cache
//   if (state == S_WRITE_TO_CACHE && mem_resp_valid) begin
//       if (transaction == MEMORY_TRANSACTION_CYCLES - 1) begin
//         transaction <= '0;
//       end else begin
//         transaction <= transaction + 1'b1;
//       end
//     end
//   end
// end

// always_comb begin
//   //default values 
//   next_state = state;
//   mem_req_valid = 1'b0;
//   mem_req_rw = 1'b0;
//   mem_req_addr = '0;
//   mem_req_data_valid = 1'b0;
//   mem_req_data_bits = '0;
//   mem_req_data_mask = '0;
//   metadata_ce = 1'b0;
//   metadata_we = 1'b0;
//   metadata_wmask = 4'b0000;
//   metadata_addr = '0;
//   metadata_din = '0;
//   cpu_req_ready = 1'b0;
//   cpu_resp_valid = 1'b0;
//   cpu_data_flip_flop_d = '0;
//   for (int j = 0; j < 4; j++) begin
//     data_ce[j] = 1'b0;
//     data_we[j] = 1'b0;
//     data_wmask[j] = 4'b0000;
//     data_addr[j] = '0;
//     data_din[j] = '0;
//   end

//   case (state)
//     //reset eveyrthing to zero
//     S_INITIALIZE: begin
//       metadata_ce = 1'b1;
//       metadata_we = 1'b1;
//       metadata_wmask = 4'b1111;
//       metadata_addr = resetting_index;
//       metadata_din = 32'b0;
//       if (resetting_index == LINES - 1) begin
//         next_state = S_IDLE;
//       end
//     end

//     //waiting for cpu request
//     S_IDLE: begin
//       cpu_req_ready = !cpu_req_valid; // 0 means SRAM is being read, 1 means request is ready and no stall is occuring
//       if (cpu_req_valid) begin
//         metadata_ce = 1'b1;
//         metadata_we = 1'b0;
//         metadata_addr = cpu_requested_index;
//         for (int j = 0; j < 4; j++) begin
//           data_ce[j] = 1'b1;
//           data_we[j] = 1'b0;
//           data_addr[j] = {cpu_requested_index, cpu_requested_offset[3:2]};
//         end
//         next_state = S_SEARCH;
//       end
//     end

//     //check if hit dirty miss or clean miss
//     S_SEARCH: begin
//       if (hit) begin
//         next_state = S_HIT;
//       end else if (metadata_is_valid && metadata_is_dirty) begin
//         for (int j = 0; j < 4; j++) begin
//           data_ce[j] = 1'b1;
//           data_we[j] = 1'b0;
//           data_addr[j] = cache_line_entry;
//       end
//       next_state =  S_SEND_TO_MEMORY;
//       end else begin
//         next_state = S_FETCH_FROM_MEMORY;
//       end
//     end

//     //clean hit
//     S_HIT: begin
//       if (request_is_write) begin
//         data_ce[which_SRAM] = 1'b1;
//         data_we[which_SRAM] = 1'b1;
//         data_wmask[which_SRAM] = requested_write_mask;
//         data_addr[which_SRAM] = SRAM_address;
//         data_din[which_SRAM] = write_merged_data; // requested_data
//         metadata_ce = 1'b1;
//         metadata_we = 1'b1;
//         metadata_wmask = 4'b1111;
//         metadata_addr = requested_index;
//         metadata_din = {1'b1, 1'b1, {(30-TAG_BITS){1'b0}}, requested_tag};
//         cpu_req_ready = 1'b1;
//         next_state = S_IDLE;
//       end else begin
//         cpu_resp_valid = 1'b1;
//         cpu_data_flip_flop_d = data_dout[which_SRAM];
//         cpu_req_ready = 1'b1;

//         if (cpu_req_valid && (cpu_req_addr != requested_address|| (|cpu_req_write))) begin
//           if (!(|cpu_req_write) && cpu_req_addr[WORD_ADDR_BITS-1:OFFSET_BITS] == requested_address[WORD_ADDR_BITS-1:OFFSET_BITS]) begin
//             for (int i = 0; i < 4; i++) begin
//               data_ce[i] = 1'b1;
//               data_we[i] = 1'b0;
//               data_addr[i] = {cpu_req_addr[OFFSET_BITS +: INDEX_BITS], cpu_req_addr[OFFSET_BITS-1:2]};
//             end
//             cpu_req_ready = 1'b0;
//             cpu_resp_valid = 1'b0;
//             next_state = S_HIT;
//           end else begin
//              cpu_resp_valid = 1'b0;
//              cpu_req_ready = 1'b0;
//              next_state = S_IDLE;
//           end
//         end
//       end
//     end

//     //write back 128 bits at a time
//     S_SEND_TO_MEMORY: begin
//       mem_req_valid = !write_address_received;
//       mem_req_rw = 1'b1;
//       mem_req_addr = writeback_memory_address;
//       mem_req_data_mask = 16'hFFFF;

//       //write back 128 bits 
//       if (write_address_received || mem_req_ready) begin
//         mem_req_data_valid = !write_data_received;
//         mem_req_data_bits = {data_dout[3], data_dout[2], data_dout[1], data_dout[0]};
//       end

//       //check finished
//       if ((write_address_received || mem_req_ready) && (write_data_received || ((write_address_received || mem_req_ready) && mem_req_data_ready))) begin
//         //write back done
//         if (transaction == MEMORY_TRANSACTION_CYCLES - 1) begin
//           next_state = S_FETCH_FROM_MEMORY;
//         end else begin
//           //get next chunk
//           for (int j = 0; j < 4; j++) begin
//             data_ce[j] = 1'b1;
//             data_we[j] = 1'b0;
//             data_addr[j] = {requested_index, transaction + 1'b1};
//           end
//           next_state = S_SEND_TO_MEMORY;
//         end
//       end
//     end

//     //read request to memory for missed cache
//     S_FETCH_FROM_MEMORY: begin
//       mem_req_valid = 1'b1;
//       mem_req_rw = 1'b0;
//       mem_req_addr = actual_memory_base_address;
//       if (mem_req_ready) begin
//         next_state = S_WRITE_TO_CACHE;
//       end
//     end

//     //takes received data from memory to write into cache
//     S_WRITE_TO_CACHE: begin
//       if (mem_resp_valid) begin
//         //128 bits at a time rewrite to cache
//         for (int j = 0; j < 4; j++) begin
//           data_ce[j] = 1'b1;
//           data_we[j] = 1'b1;
//           data_wmask[j] = 4'b1111;
//           data_addr[j] = cache_line_entry;
//           data_din[j] = mem_resp_data[(j * 32) +: 32];
//         end

//         //mark cache line as clean and valid
//         if (transaction == MEMORY_TRANSACTION_CYCLES - 1) begin
//           metadata_ce = 1'b1;
//           metadata_we = 1'b1;
//           metadata_wmask = 4'b1111;
//           metadata_addr = requested_index;
//           metadata_din = {1'b1, 1'b0, {(30-TAG_BITS){1'b0}}, requested_tag};
//           next_state = S_REREAD;
//         end else begin
//           //keep reading
//           next_state = S_WRITE_TO_CACHE;
//         end
//       end
//     end

//     //read cache line again
//     S_REREAD: begin
//       metadata_ce = 1'b1;
//       metadata_we = 1'b0;
//       metadata_addr = requested_index;
//       for (int j = 0; j < 4; j++) begin
//         data_ce[j] = 1'b1;
//         data_we[j] = 1'b0;
//         data_addr[j] = SRAM_address;
//       end
//       next_state = S_HIT;
//     end

//     default: next_state = S_IDLE;
//   endcase
// end
// endmodule

// `default_nettype wire