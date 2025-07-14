// SPDX-License-Identifier: MIT

// Synchronous FIFO for AXI Stream interface
module axis_sync_fifo #(
    parameter DEPTH = 4
) (
    input logic clk,
    input logic rst,

    axis_if.m axis_mif,  // Manager
    axis_if.s axis_sif,  // Subordinate

    input logic invalidate
);

  // Define local parameters
  localparam TDATA_WIDTH = axis_mif.TDATA_WIDTH;

  // Assert conditions
  initial begin
    assert (TDATA_WIDTH > 0)
    else $fatal("TDATA_WIDTH must be greater than 0");
    assert (TDATA_WIDTH == axis_sif.TDATA_WIDTH)
    else $fatal("TDATA_WIDTH must match between manager and subordinate interfaces");
  end

  // Depth dependent logic
  generate
    if (DEPTH == 1) begin
      axis_slice axis_slice (.*);
    end else if (DEPTH == 2) begin
      axis_skid_buffer axis_skid_buffer (.*);
    end else begin
      axis_sync_fifo_core #(.DEPTH(DEPTH)) axis_sync_fifo_core (.*);
    end
  endgenerate

endmodule

module axis_sync_fifo_core #(
    parameter DEPTH = 5  // 2**n + 1
) (
    input logic clk,
    input logic rst,

    axis_if.m axis_mif,  // Manager
    axis_if.s axis_sif,  // Subordinate

    input logic invalidate  // TODO
);

  // Define local parameters
  localparam TDATA_WIDTH = axis_mif.TDATA_WIDTH;
  localparam ADDR_WIDTH = $clog2(DEPTH - 1);

  // Assert conditions
  initial begin
    assert (DEPTH >= 3)
    else $fatal("DEPTH must be greater than or equal to 3");
    assert (DEPTH == 2 ** $clog2(DEPTH - 1) + 1)
    else $fatal("DEPTH must be a power of 2 plus 1");
    assert (TDATA_WIDTH == axis_sif.TDATA_WIDTH)
    else $fatal("TDATA_WIDTH must match between manager and subordinate interfaces");
  end

  // Declare registers and their next states
  logic tvalid_q, tvalid_d;
  logic [TDATA_WIDTH-1:0] tdata_q, tdata_d;
  logic tready_q, tready_d;
  logic [ADDR_WIDTH:0] wptr_q, wptr_d;
  logic [ADDR_WIDTH:0] rptr_q, rptr_d;
  logic empty_q, empty_d;

  // Declare wires
  logic full, next_full;
  logic empty, next_empty;
  logic mif_tready;
  logic s_handshake;

  logic [TDATA_WIDTH-1:0] wdata_ram;
  logic [ADDR_WIDTH-1:0] waddr_ram;
  logic wvalid_ram;
  logic [TDATA_WIDTH-1:0] rdata_ram;
  logic [ADDR_WIDTH-1:0] raddr_ram;

  // Wire assignments
  assign next_full = (wptr_d[ADDR_WIDTH] ^ rptr_d[ADDR_WIDTH]) && (wptr_d[ADDR_WIDTH-1:0] == rptr_d[ADDR_WIDTH-1:0]);
  assign empty_d = (wptr_d == rptr_d);

  assign tready_d = !next_full;
  assign s_handshake = axis_sif.tvalid && tready_q;

  assign wdata_ram = axis_sif.tdata;
  assign waddr_ram = wptr_q[ADDR_WIDTH-1:0];
  assign raddr_ram = rptr_q[ADDR_WIDTH-1:0];

  assign axis_mif.tvalid = tvalid_q;
  assign axis_mif.tdata = tdata_q;
  assign mif_tready = axis_mif.tready;
  assign axis_sif.tready = tready_q;

  always_comb begin
    tvalid_d = tvalid_q;
    tdata_d = tdata_q;
    wptr_d = wptr_q;
    rptr_d = rptr_q;
    wvalid_ram = 1'b0;

    if (tvalid_q) begin
      if (mif_tready) begin
        if (empty_q) begin
          tvalid_d = axis_sif.tvalid;
          tdata_d  = axis_sif.tdata;
        end else begin
          tvalid_d = 1'b1;
          tdata_d  = rdata_ram;
          rptr_d   = rptr_q + ADDR_WIDTH'(1);
        end
      end
      if ((!mif_tready || !empty_q) && s_handshake) begin // If empty, incoming data will be stored in tvalid_q
        wvalid_ram = 1'b1;
        wptr_d = wptr_q + ADDR_WIDTH'(1);
      end
    end else begin
      if (s_handshake) begin
        tvalid_d = 1'b1;
        tdata_d  = axis_sif.tdata;
      end
    end
  end

  // Update registers
  always_ff @(posedge clk) begin
    if (rst) begin
      wptr_q   <= '0;
      rptr_q   <= '0;
      tvalid_q <= '0;
      tdata_q  <= '0;
      tready_q <= '1;
      empty_q  <= '0;
    end else if (invalidate) begin
      wptr_q   <= '0;
      rptr_q   <= '0;
      tvalid_q <= '0;
      tready_q <= '1;
    end else begin
      wptr_q   <= wptr_d;
      rptr_q   <= rptr_d;
      tvalid_q <= tvalid_d;
      tdata_q  <= tdata_d;
      tready_q <= tready_d;
      empty_q  <= empty_d;
    end
  end

  ram_async #(
      .DATA_WIDTH(TDATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) ram_async_inst (
      .clk(clk),
      .rst(rst),
      .wdata(wdata_ram),
      .waddr(waddr_ram),
      .wvalid(wvalid_ram),
      .rdata(rdata_ram),
      .raddr(raddr_ram)
  );

endmodule
