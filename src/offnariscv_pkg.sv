// SPDX-License-Identifier: MIT

`ifndef OFFNARISCV_PKG
`define OFFNARISCV_PKG

package offnariscv_pkg;
  import riscv_pkg::*;
  localparam XLEN = 32;

  localparam ACE_XID_WIDTH = 1;
  localparam ACE_AXLEN_WIDTH = 8;
  localparam ACE_AXSIZE_WIDTH = 3;
  localparam ACE_AXBURST_WIDTH = 2;
  localparam ACE_AXCACHE_WIDTH = 4;
  localparam ACE_AXPROT_WIDTH = 3;
  localparam ACE_AXQOS_WIDTH = 4;
  localparam ACE_AXREGION_WIDTH = 4;
  localparam ACE_XUSER_WIDTH = 1;
  localparam ACE_BRESP_WIDTH = 2;
  localparam ACE_RRESP_WIDTH = 4; // ACE_BRESP_WIDTH + 2 (IsShared, PassDirty)
  localparam ACE_ARSNOOP_WIDTH = 4;
  localparam ACE_AWSNOOP_WIDTH = 3;
  localparam ACE_DOMAIN_WIDTH = 2;
  localparam ACE_BAR_WIDTH = 4;
  localparam ACE_ACSNOOP_WIDTH = ACE_ARSNOOP_WIDTH;
  localparam ACE_ACPROT_WIDTH = ACE_AXPROT_WIDTH;
  localparam ACE_CRRESP_WIDTH = 5;

  typedef enum logic [ACE_BRESP_WIDTH-1:0] {
    ACE_RESP_OKAY = 2'b00,
    ACE_RESP_EXOKAY = 2'b01,
    ACE_RESP_SLVERR = 2'b10,
    ACE_RESP_DECERR = 2'b11
  } ace_resp_e;

  typedef union packed {
    interrupt_codes_e int_code;
    exception_codes_e exc_code;
  } int_exc_code_u;

  localparam INST_ID_WIDTH = 64;

  typedef struct packed {
`ifndef SYNTHESIS
    logic [INST_ID_WIDTH-1:0] id;
`endif
    logic [XLEN-1:0] pc;
    logic [XLEN-1:0] untaken_pc; // For branch prediction
    logic [XLEN-1:0] inst;
    logic int_exc_valid;
    int_exc_code_u int_exc_code;
  } ifid_tdata_t;

  typedef enum logic [2:0] {
    ADD
  } alu_cmd_e;

  typedef enum logic [2:0] {
    BRU_JAL,
    BRU_JALR,
    BRU_BEQ,
    BRU_BNE,
    BRU_BLT,
    BRU_BGE,
    BRU_BLTU,
    BRU_BGEU
  } bru_cmd_e;

  typedef struct packed {
    logic rf; // Forwarding is needed at RF stage
    logic ex; // Forwarding is needed at EX stage
  } fwd_t;

  typedef struct packed {
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [XLEN-1:0] immediate;
    logic [XLEN-1:0] auipc; // PC value used by AUIPC instruction
    fwd_t fwd_rs1;
    fwd_t fwd_rs2;
    alu_cmd_e alu_cmd;
    logic alu_cmd_vld;
    bru_cmd_e bru_cmd;
    logic bru_cmd_vld;
    ifid_tdata_t if_data;
  } idrf_tdata_t;

  typedef struct packed {
    logic [XLEN-1:0] op1;
    logic [XLEN-1:0] op2;
  } operands_t;

  typedef struct packed {
    operands_t operands;
    logic [XLEN-1:0] rs2_data; // For store
    idrf_tdata_t id_data;
  } rfex_tdata_t;

  typedef struct packed {
    operands_t operands;
    alu_cmd_e cmd;
  } rfalu_tdata_t;

  typedef struct packed {
    operands_t operands;
    logic [XLEN-1:0] offset;
    logic [XLEN-1:0] this_pc;
    bru_cmd_e cmd;
  } rfbru_tdata_t;

  typedef struct packed {
    rfex_tdata_t rf_data;
  } exwb_tdata_t;

  typedef struct packed {
    logic [XLEN-1:0] wdata;
    exwb_tdata_t ex_data;
  } wbrf_tdata_t;

  typedef struct packed {
    logic [XLEN-1:0] result;
  } aluwb_tdata_t;

  typedef struct packed {
    logic [XLEN-1:0] result;
    logic [XLEN-1:0] new_pc;
    logic taken;
  } bruwb_tdata_t;

endpackage

`endif
