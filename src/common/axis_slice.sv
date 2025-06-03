// SPDX-License-Identifier: MIT

// Register slice for AXI Stream interface
module axis_slice #(
  parameter TDATA_WIDTH = 32
) (
  input logic clk,
  input logic rst_n,
  
  axis_if.m axis_mif, // Manager
  axis_if.s axis_sif, // Subordinate

  input logic invalidate // TODO
);

  // Declare registers
  logic tvalid;
  logic [TDATA_WIDTH-1:0] tdata;

  // Wire assignments
  assign axis_mif.tvalid = tvalid;
  assign axis_mif.tdata = tdata;
  assign axis_sif.tready = !tvalid || axis_mif.tready;

  // Update registers
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tvalid <= '0;
      tdata <= '0;
    end else begin
      if (axis_sif.tready) begin
        tvalid <= axis_sif.tvalid;
        if (axis_sif.tvalid) begin // TODO: Remove this condition if not needed
          tdata <= axis_sif.tdata;
        end
      end
    end
  end

endmodule