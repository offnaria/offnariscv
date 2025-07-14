// SPDX-License-Identifier: MIT

// CSR Read Interface
interface csr_rif;
  import offnariscv_pkg::*;

  logic [11:0] addr;
  logic [XLEN-1:0] rdata;
  logic [XLEN-1:0] mtvec;
  logic [XLEN-1:0] mepc;
  logic ro;  // Read-only flag
  logic exception;

  // Request modport
  modport req(output addr, input rdata, mtvec, mepc, ro, exception);

  // Response modport
  modport rsp(input addr, output rdata, mtvec, mepc, ro, exception);

endinterface

// CSR Write Interface
interface csr_wif;
  import offnariscv_pkg::*;

  logic [11:0] addr;
  logic [XLEN-1:0] data;
  logic [XLEN-1:0] pc;
  logic [XLEN-1:0] cause;
  logic trap;
  logic valid;

  // Request modport
  modport req(output addr, data, pc, cause, trap, valid);

  // Response modport
  modport rsp(input addr, data, pc, cause, trap, valid);

endinterface

// TODO: Add interface for IFU that reads privilege-related CSRs
