`default_nettype none

package immediate_op_pkg;

  typedef enum logic [2:0] {
    IMMEDIATE_I = 3'd0, // I-type: General Immediate Instructions
    IMMEDIATE_S = 3'd1, // S-type: Store Instructions
    IMMEDIATE_B = 3'd2, // B-type: Branch Instructions
    IMMEDIATE_U = 3'd3, // U-type: Upper Immediate Instructions
    IMMEDIATE_J = 3'd4, // J-type: Jump Instructions
    IMMEDIATE_Z = 3'd5  // Z-type: CSR instructions
  } immediate_type_select_t;

endpackage : immediate_op_pkg
`default_nettype wire
