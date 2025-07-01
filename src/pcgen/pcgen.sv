// SPDX-License-Identifier: MIT

// Program Counter Generator
module pcgen
  import offnariscv_pkg::*;
(
  input clk,
  input rst,

  // From/To Instruction Fetch Unit
  axis_if.m pcgif_axis_if,
  axis_if.s current_pc_axis_if,

  // From Branch Resolution Unit
  axis_if.s wbpcg_axis_if
);

  // Assert conditions
  initial begin
    assert (pcgif_axis_if.TDATA_WIDTH == XLEN) else $fatal("pcgif_axis_if.TDATA_WIDTH must be equal to XLEN");
    assert (current_pc_axis_if.TDATA_WIDTH == XLEN) else $fatal("current_pc_axis_if.TDATA_WIDTH must be equal to XLEN");
    assert (wbpcg_axis_if.TDATA_WIDTH == XLEN) else $fatal("wbpcg_axis_if.TDATA_WIDTH must be equal to XLEN");
  end

  // Wire assignments
  assign pcgif_axis_if.tdata = (wbpcg_axis_if.tvalid) ? wbpcg_axis_if.tdata : (current_pc_axis_if.tdata + XLEN'(4));
  assign pcgif_axis_if.tvalid = 1'b1;
  assign current_pc_axis_if.tready = 1'b1;
  assign wbpcg_axis_if.tready = pcgif_axis_if.tready;

endmodule
