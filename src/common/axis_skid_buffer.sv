// SPDX-License-Identifier: MIT

// Skid buffer for AXI Stream interface
module axis_skid_buffer #(
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
  logic tready;
  logic skid_tvalid;
  logic [TDATA_WIDTH-1:0] skid_tdata;

  // Declare wires
  logic s_handshake;
  logic m_waiting;

  // Wire assignments
  assign s_handshake = axis_sif.tvalid && tready;

  assign axis_mif.tvalid = tvalid;
  assign axis_mif.tdata = tdata;
  assign axis_sif.tready = tready;

  // Update registers
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tvalid <= '0;
      tready <= '0;
      tdata <= '0;
      skid_tvalid <= '0;
      skid_tdata <= '0;
    end else begin
      if (!tvalid || axis_mif.tready) begin
        tvalid <= skid_tvalid || s_handshake;
        if ((skid_tvalid || s_handshake) && (!tvalid || axis_mif.tready)) begin // Remove the former condition if not needed
          tdata <= skid_tvalid ? skid_tdata : axis_sif.tdata;
        end
      end

      if (skid_tvalid) begin
        if (axis_mif.tready) begin
          skid_tvalid <= 1'b0;
        end
      end else begin
        if (tvalid && !axis_mif.tready && s_handshake) begin
          skid_tvalid <= 1'b1;
          skid_tdata <= axis_sif.tdata;
        end
      end

      if (tready) begin
        if (tvalid && !axis_mif.tready && s_handshake) begin
          tready <= 1'b0;
        end
      end else begin
        if (axis_mif.tready || !skid_tvalid) begin // The latter condition is to recover from reset
          tready <= 1'b1;
        end
      end
    end
  end

endmodule