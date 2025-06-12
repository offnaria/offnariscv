// SPDX-License-Identifier: MIT

// Program Counter Generator
module pcgen
  import offnariscv_pkg::*;
(
  input clk,
  input rst,

  // From/To Instruction Fetch Unit
  axis_if.m next_pc_axis_if,
  axis_if.s current_pc_axis_if,

  // From Branch Resolution Unit
  axis_if.s bru_axis_if
);

  // Assert conditions
  initial begin
    assert (next_pc_axis_if.TDATA_WIDTH == XLEN) else $fatal("next_pc_axis_if.TDATA_WIDTH must be equal to XLEN");
    assert (current_pc_axis_if.TDATA_WIDTH == XLEN) else $fatal("current_pc_axis_if.TDATA_WIDTH must be equal to XLEN");
    assert (bru_axis_if.TDATA_WIDTH == XLEN) else $fatal("bru_axis_if.TDATA_WIDTH must be equal to XLEN");
  end

  // Wire assignments
  assign next_pc_axis_if.tdata = (bru_axis_if.tvalid) ? bru_axis_if.tdata : (current_pc_axis_if.tdata + XLEN'(4));
  assign next_pc_axis_if.tvalid = 1'b1;
  assign current_pc_axis_if.tready = 1'b1;
  assign bru_axis_if.tready = next_pc_axis_if.tready;

endmodule
