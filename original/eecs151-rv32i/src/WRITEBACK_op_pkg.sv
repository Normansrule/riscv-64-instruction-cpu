`default_nettype none

package writeback_op_pkg;

  typedef enum logic [1:0] {
    WRITEBACK_ALU = 2'd0, // 00: Write back the result from ALU 
    WRITEBACK_MEMORY = 2'd1, // 01: Write back the loaded data
    WRITEBACK_PC_ADD_4 = 2'd2, // 10: Write back the Program Counter + 4
    WRITEBACK_CSR = 2'd3  // 11: Write back the data read from Control Status Register 
  } writeback_select_t;

endpackage : writeback_op_pkg

`default_nettype wire