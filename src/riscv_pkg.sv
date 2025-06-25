// SPDX-License-Identifier: MIT

`ifndef RISCV_PKG
`define RISCV_PKG

package riscv_pkg;
  localparam INT_CODES_WIDTH = 5;
  typedef enum logic [INT_CODES_WIDTH-1:0] {
    INT_SSI = 1, // Supervisor software interrupt
    INT_MSI = 3, // Machine software interrupt
    INT_STI = 5, // Supervisor timer interrupt
    INT_MTI = 7, // Machine timer interrupt
    INT_SEI = 9, // Supervisor external interrupt
    INT_MEI = 11, // Machine external interrupt
    INT_COI = 13 // Counter overflow interrupt
  } interrupt_codes_e;

  localparam EXC_CODES_WIDTH = INT_CODES_WIDTH;
  typedef enum logic [EXC_CODES_WIDTH-1:0] {
    EXC_IAM = 0, // Instruction address misaligned
    EXC_IAF = 1, // Instruction access fault
    EXC_II = 2, // Illegal instruction
    EXC_BP = 3, // Breakpoint
    EXC_LAM = 4, // Load address misaligned
    EXC_LAF = 5, // Load access fault
    EXC_SAM = 6, // Store/AMO address misaligned
    EXC_SAF = 7, // Store/AMO access fault
    EXC_ECU = 8, // Environment call from U-mode
    EXC_ECS = 9, // Environment call from S-mode
    EXC_ECM = 11, // Environment call from M-mode
    EXC_IPF = 12, // Instruction page fault
    EXC_LPF = 13, // Load page fault
    EXC_SPF = 15, // Store/AMO page fault
    EXC_DT = 16, // Double trap
    EXC_SC = 18, // Software check
    EXC_HE = 19 // Hardware error
  } exception_codes_e;

  typedef enum logic [4:0] {
    LOAD = 5'b00000,
    // LOAD_FP = 5'b00001,
    // CUSTOM_0 = 5'b00010,
    MISC_MEM = 5'b00011,
    OP_IMM = 5'b00100,
    AUIPC = 5'b00101,
    // OP_IMM_32 = 5'b00110,
    STORE = 5'b01000,
    // STORE_FP = 5'b01001,
    // CUSTOM_1 = 5'b01010,
    AMO = 5'b01011,
    OP = 5'b01100,
    LUI = 5'b01101,
    // OP_32 = 5'b01110,
    // MADD = 5'b10000,
    // MSUB = 5'b10001,
    // NMSUB = 5'b10010,
    // NMADD = 5'b10011,
    // OP_FP = 5'b10100,
    // OP_V = 5'b10101,
    // CUSTOM_2 = 5'b10110,
    BRANCH = 5'b11000,
    JALR = 5'b11001,
    JAL = 5'b11011,
    SYSTEM = 5'b11100,
    // OP_VE = 5'b11101,
    // CUSTOM_3 = 5'b11110,
    UNKNOWN
  } opcode_e;

  typedef struct packed {
    logic sd;
    logic [5:0] wpri0;
    logic sdt;
    logic spelp;
    logic tsr;
    logic tw;
    logic tvm;
    logic mxr;
    logic sum;
    logic mprv;
    logic [1:0] xs;
    logic [1:0] fs;
    logic [1:0] mpp;
    logic [1:0] vs;
    logic spp;
    logic mpie;logic ube;
    logic spie;
    logic wpri1;
    logic mie;
    logic wpri2;
    logic sie;
    logic wpri3;
  } mstatus_t;

  typedef struct packed {
    logic [20:0] wpri0;
    logic mdt;
    logic mpelp;
    logic mpri1;
    logic mpv;
    logic gva;
    logic mbe;
    logic sbe;
    logic [3:0] wpri1;
  } mstatush_t;

endpackage

`endif
