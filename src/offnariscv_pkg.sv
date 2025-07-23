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
  localparam ACE_RRESP_WIDTH = 4;  // ACE_BRESP_WIDTH + 2 (IsShared, PassDirty)
  localparam ACE_ARSNOOP_WIDTH = 4;
  localparam ACE_AWSNOOP_WIDTH = 3;
  localparam ACE_DOMAIN_WIDTH = 2;
  localparam ACE_BAR_WIDTH = 4;
  localparam ACE_ACSNOOP_WIDTH = ACE_ARSNOOP_WIDTH;
  localparam ACE_ACPROT_WIDTH = ACE_AXPROT_WIDTH;
  localparam ACE_CRRESP_WIDTH = 5;

  typedef enum logic [ACE_BRESP_WIDTH-1:0] {
    ACE_RESP_OKAY   = 2'b00,
    ACE_RESP_EXOKAY = 2'b01,
    ACE_RESP_SLVERR = 2'b10,
    ACE_RESP_DECERR = 2'b11
  } ace_resp_e;

  // typedef union packed {
  //   interrupt_codes_e int_code;
  //   exception_codes_e exc_code;
  // } int_exc_code_u;

  localparam INST_ID_WIDTH = 64;

  typedef struct packed {
    logic [XLEN-1:0] pc;
    logic [XLEN-1:0] untaken_pc;  // For branch prediction
`ifndef SYNTHESIS
    logic [INST_ID_WIDTH-1:0] id;
`endif
  } pcgif_tdata_t;

  typedef struct packed {
    logic [XLEN-1:0] inst;
    // logic int_exc_valid; // TODO
    // int_exc_code_u int_exc_code; // TODO
    trap_cause_t trap_cause;
    pcgif_tdata_t pcg_data;
  } ifid_tdata_t;

  typedef enum logic [3:0] {
    ADD,
    SUB,
    SLL,
    SLT,
    SLTU,
    XOR,
    SRL,
    SRA,
    OR,
    AND
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

  typedef enum logic [3:0] {
    CSRRW,
    CSRRS,
    CSRRC,
    CSRRWI,
    CSRRSI,
    CSRRCI,
    ECALL,
    EBREAK,
    MRET,
    SRET,
    WFI,
    SFENCE_VMA
  } system_cmd_e;

  typedef enum logic [2:0] {
    LSU_LW,
    LSU_LH,
    LSU_LB,
    LSU_LHU,
    LSU_LBU,
    LSU_SW,
    LSU_SH,
    LSU_SB
  } lsu_cmd_e;  // TODO: AMO and LR/SC

  typedef struct packed {
    logic rf;  // Forwarding is needed at RF stage
    logic ex;  // Forwarding is needed at EX stage
  } fwd_t;

  typedef struct packed {
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [XLEN-1:0] immediate;
    logic [XLEN-1:0] auipc;  // PC value used by AUIPC instruction
    logic [11:0] csr_addr;
    fwd_t fwd_rs1;
    fwd_t fwd_rs2;
    alu_cmd_e alu_cmd;
    logic alu_cmd_vld;
    bru_cmd_e bru_cmd;
    logic bru_cmd_vld;
    system_cmd_e sys_cmd;
    logic sys_cmd_vld;
    lsu_cmd_e lsu_cmd;
    logic lsu_cmd_vld;
    ifid_tdata_t if_data;
    logic fence_i;
  } idrf_tdata_t;

  typedef struct packed {
    logic [XLEN-1:0] op1;
    logic [XLEN-1:0] op2;
  } operands_t;

  typedef struct packed {
    operands_t operands;
    logic [XLEN-1:0] rs2_data;  // For store
    logic [XLEN-1:0] csr_rdata;
    logic [XLEN-1:0] mtvec;
    logic [XLEN-1:0] mepc;
    idrf_tdata_t id_data;
  } rfex_tdata_t;

  typedef struct packed {
    operands_t operands;
    alu_cmd_e  cmd;
  } rfalu_tdata_t;

  typedef struct packed {
    operands_t operands;
    logic [XLEN-1:0] offset;
    logic [XLEN-1:0] this_pc;
    bru_cmd_e cmd;
  } rfbru_tdata_t;

  typedef struct packed {
    operands_t operands;
    logic [XLEN-1:0] csr_rdata;
    system_cmd_e cmd;
    trap_cause_t trap_cause;
    logic [XLEN-1:0] this_pc;
    logic [XLEN-1:0] mtvec;
    logic [XLEN-1:0] mepc;
  } rfsys_tdata_t;

  typedef struct packed {
    operands_t operands;
    logic [XLEN-1:0] offset;
    lsu_cmd_e cmd;
  } rflsu_tdata_t;

  typedef struct packed {rfex_tdata_t rf_data;} exwb_tdata_t;

  typedef struct packed {
    logic [XLEN-1:0] wdata;
    exwb_tdata_t ex_data;
  } wbrf_tdata_t;

  typedef struct packed {logic [XLEN-1:0] result;} aluwb_tdata_t;

  typedef struct packed {
    logic [XLEN-1:0] result;
    logic [XLEN-1:0] new_pc;
    logic taken;
  } bruwb_tdata_t;

  typedef struct packed {
    logic [XLEN-1:0] csr_wdata;
    // logic [XLEN-1:0] csr_wmask;
    logic csr_update;
    trap_cause_t trap_cause;
    logic [XLEN-1:0] new_pc;
    logic use_new_pc;
    logic trap;
  } syswb_tdata_t;

  typedef struct packed {
    logic [XLEN-1:0] result;
    trap_cause_t trap_cause;
    logic trap;
`ifndef SYNTHESIS
    logic [XLEN-1:0] addr;
    logic [XLEN-1:0] wdata;
    logic store;
`endif
  } lsuwb_tdata_t;

endpackage

`endif
