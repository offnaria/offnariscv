// SPDX-License-Identifier: MIT

// Control and Status Register
module csr
  import riscv_pkg::*;
# (
  parameter MHARTID = 0
) (
  input logic clk,
  input logic rst,

  axis_if.s rfalu_axis_if, // From Dispatcher
  axis_if.m aluwb_axis_if, // To Write Back

  input logic invalidate
);

  // Declare registers and their next states
  logic [XLEN-1:0] misa_q;
  logic [XLEN-1:0] mvendorid_q;
  logic [XLEN-1:0] marchid_q;
  // logic [XLEN-1:0] mimpid_q; // TODO
  logic [XLEN-1:0] mhartid_q;
  mstatus_t mstatus_q;
  mstatush_t mstatush_q;
  logic [XLEN-1:0] mtved_q;

  always_ff @(posedge clk) begin
    if (rst) begin
      misa_q <= {2'd2, '0, 26'(2**8)} // RV32I
      mvendorid_q <= '0; // Non-commercial implementation
      marchid_q <= '0; // Not assigned yet
      mhartid_q <= MHARTID;
      mstatus_q <= '0; // TODO
      mstatush_q <= '0; // TODO
      mtved_q <= '0; // Direct mode
    end else begin

    end
  end

endmodule
