// SPDX-License-Identifier: MIT

module pcgen_wrap
  import offnariscv_pkg::*;
(
  input clk,
  input rst,

  output logic [XLEN-1:0] next_pc_tdata,
  output logic next_pc_tvalid,
  input logic next_pc_tready,

  input logic [XLEN-1:0] current_pc_tdata,
  input logic current_pc_tvalid,
  output logic current_pc_tready,

  input logic [XLEN-1:0] bru_tdata,
  input logic bru_tvalid,
  output logic bru_tready
);

  axis_if #(.TDATA_WIDTH(XLEN)) next_pc_axis_if ();
  axis_if #(.TDATA_WIDTH(XLEN)) current_pc_axis_if ();
  axis_if #(.TDATA_WIDTH(XLEN)) bru_axis_if ();

  assign next_pc_tdata = next_pc_axis_if.tdata;
  assign next_pc_tvalid = next_pc_axis_if.tvalid;
  assign next_pc_axis_if.tready = next_pc_tready;

  assign current_pc_axis_if.tdata = current_pc_tdata;
  assign current_pc_axis_if.tvalid = current_pc_tvalid;
  assign current_pc_tready = current_pc_axis_if.tready;

  assign bru_axis_if.tdata = bru_tdata;
  assign bru_axis_if.tvalid = bru_tvalid;
  assign bru_tready = bru_axis_if.tready;

  pcgen pcgen_inst (.*);

endmodule
