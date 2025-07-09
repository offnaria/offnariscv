// SPDX-License-Identifier: MIT

module axis_sync_fifo_wrap # (
  localparam TDATA_WIDTH = 32,
  localparam DEPTH = 5 // 2**n + 1
) (
  input logic clk,
  input logic rst,

  input logic sif_tvalid,
  input logic [TDATA_WIDTH-1:0] sif_tdata,
  output logic sif_tready,

  output logic mif_tvalid,
  output logic [TDATA_WIDTH-1:0] mif_tdata,
  input logic mif_tready,

  input logic invalidate
);

  axis_if #(.TDATA_WIDTH(TDATA_WIDTH)) axis_mif ();
  axis_if #(.TDATA_WIDTH(TDATA_WIDTH)) axis_sif ();

  assign axis_sif.tvalid = sif_tvalid;
  assign axis_sif.tdata = sif_tdata;
  assign sif_tready = axis_sif.tready;

  assign mif_tvalid = axis_mif.tvalid;
  assign mif_tdata = axis_mif.tdata;
  assign axis_mif.tready = mif_tready;

  axis_sync_fifo # (.DEPTH(DEPTH)) axis_sync_fifo (.*);

endmodule
