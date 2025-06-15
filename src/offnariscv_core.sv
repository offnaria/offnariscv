// SPDX-License-Identifier: MIT

module offnariscv_core
  import offnariscv_pkg::*;
# (
  parameter RESET_VECTOR = 0
) (
  input clk,
  input rst,

  ace_if.m core_ace_if
);

  // Declare interfaces
  axis_if #(.TDATA_WIDTH(XLEN)) next_pc_axis_if ();
  axis_if #(.TDATA_WIDTH(XLEN)) current_pc_axis_if ();
  axis_if #(.TDATA_WIDTH(XLEN)) bru_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(ifid_tdata_t))) ifid_axis_if ();

  // Wire assignments
  assign bru_axis_if.tdata = '0; // TODO
  assign bru_axis_if.tvalid = '0; // TODO
  assign ifid_axis_if.tready = 1'b1; // TODO

  pcgen pcgen_inst (
    .clk(clk),
    .rst(rst),
    .next_pc_axis_if(next_pc_axis_if),
    .current_pc_axis_if(current_pc_axis_if),
    .bru_axis_if(bru_axis_if)
  );

  ifu # (
    .RESET_VECTOR(RESET_VECTOR)
  ) ifu_inst (
    .clk(clk),
    .rst(rst),
    .ifu_ace_if(core_ace_if),
    .next_pc_axis_if(next_pc_axis_if),
    .current_pc_axis_if(current_pc_axis_if),
    .inst_axis_if(ifid_axis_if),
    .invalidate(1'b0) // TODO
  );

  // lsu lsu_inst (
  //   .clk(clk),
  //   .rst(rst),
  //   .lsu_ace_if(lsu_ace_if)
  // );

endmodule
