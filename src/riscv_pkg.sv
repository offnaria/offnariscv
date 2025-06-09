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

endpackage

`endif
