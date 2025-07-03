// SPDX-License-Identifier: MIT

module lsu
  import offnariscv_pkg::*;
(
  input clk,
  input rst,

  // To lower level memory
  ace_if.m lsu_ace_if,

  axis_if.s rflsu_axis_if, // From Dispatcher
  axis_if.m lsuwb_axis_if, // To Write Back

  input logic invalidate
);

  // Define local parameters
  localparam ADDR_WIDTH = lsu_ace_if.ACE_AXADDR_WIDTH;
  localparam BLOCK_SIZE = lsu_ace_if.ACE_XDATA_WIDTH;
  localparam BLOCK_OFFSET_WIDTH = $clog2(BLOCK_SIZE / 8);

  // Assert conditions
  initial begin
    assert (ADDR_WIDTH == XLEN) else $fatal("lsu_ace_if.ADDR_WIDTH must be equal to XLEN for now");
  end

  // Define types
  typedef enum logic [2:0] {
    IDLE,
    PTW,
    LOAD,
    STORE,
    WAIT
  } state_e; // TODO: There might be more states for AMO in the future

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(lsuwb_tdata_t))) lsuwb_slice_if ();

  // Declare registers and their next states
  state_e state_q, state_d;
  logic arvalid_q, arvalid_d;
  logic rready_q, rready_d;
  logic awvalid_q, awvalid_d;
  logic wvalid_q, wvalid_d;
  logic [BLOCK_SIZE-1:0] wdata_q, wdata_d;
  logic [BLOCK_SIZE/8-1:0] wstrb_q, wstrb_d;
  logic bready_q, bready_d;
  logic [ADDR_WIDTH-1:0] addr_q, addr_d;

  always_comb begin
    state_d = state_q;
    arvalid_d = arvalid_q;
    rready_d = rready_q;
    awvalid_d = awvalid_q;
    wvalid_d = wvalid_q;
    wdata_d = wdata_q;
    wstrb_d = wstrb_q;
    bready_d = bready_q;
    addr_d = addr_q;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      state_q <= IDLE;
      arvalid_q <= 0;
      rready_q <= 0;
      awvalid_q <= 0;
      wvalid_q <= 0;
      wdata_q <= '0;
      wstrb_q <= '0;
      bready_q <= 0;
      addr_q <= '0;
    end else begin
      state_q <= state_d;
      arvalid_q <= arvalid_d;
      rready_q <= rready_d;
      awvalid_q <= awvalid_d;
      wvalid_q <= wvalid_d;
      wdata_q <= wdata_d;
      wstrb_q <= wstrb_d;
      bready_q <= bready_d;
      addr_q <= addr_d;
    end
  end

  // External wire assignments
  //// AW channel signals
  assign lsu_ace_if.awvalid = awvalid_q;
  assign lsu_ace_if.awid = '0; // TODO
  assign lsu_ace_if.awaddr = addr_q;
  assign lsu_ace_if.awlen = '0; // TODO
  assign lsu_ace_if.awsize = '0; // TODO
  assign lsu_ace_if.awburst = '0; // TODO
  assign lsu_ace_if.awlock = '0; // TODO
  assign lsu_ace_if.awcache = '0; // TODO
  assign lsu_ace_if.awprot = '0; // TODO
  assign lsu_ace_if.awqos = '0; // TODO
  assign lsu_ace_if.awregion = '0; // TODO
  assign lsu_ace_if.awuser = '0; // TODO
  assign lsu_ace_if.awsnoop = '0; // TODO
  assign lsu_ace_if.awdomain = '0; // TODO
  assign lsu_ace_if.awbar = '0; // TODO

  //// W channel signals
  assign lsu_ace_if.wvalid = wvalid_q;
  assign lsu_ace_if.wdata = wdata_q;
  assign lsu_ace_if.wstrb = wstrb_q;
  assign lsu_ace_if.wlast = '0; // TODO
  assign lsu_ace_if.wuser = '0; // TODO

  //// B channel signals
  assign lsu_ace_if.bready = bready_q;

  //// AR channel signals
  assign lsu_ace_if.arid = '0; // TODO
  assign lsu_ace_if.araddr = addr_q;
  assign lsu_ace_if.arlen = '0; // TODO
  assign lsu_ace_if.arsize = '0; // TODO
  assign lsu_ace_if.arburst = '0; // TODO
  assign lsu_ace_if.arlock = '0; // TODO
  assign lsu_ace_if.arcache = '0; // TODO
  assign lsu_ace_if.arprot = '0; // TODO
  assign lsu_ace_if.arqos = '0; // TODO
  assign lsu_ace_if.arregion = '0; // TODO
  assign lsu_ace_if.aruser = '0; // TODO
  assign lsu_ace_if.arvalid = arvalid_q;
  assign lsu_ace_if.arsnoop = '0; // TODO
  assign lsu_ace_if.ardomain = '0; // TODO
  assign lsu_ace_if.arbar = '0; // TODO

  //// R channel signals
  assign lsu_ace_if.rready = rready_q;

  //// AC channel signals
  assign lsu_ace_if.acready = '0; // TODO

  //// CR channel signals
  assign lsu_ace_if.crvalid = '0; // TODO
  assign lsu_ace_if.crresp = '0; // TODO

  //// CD channel signals
  assign lsu_ace_if.cdvalid = '0; // TODO
  assign lsu_ace_if.cddata = '0; // TODO
  assign lsu_ace_if.cdlast = '0; // TODO

  //// Acknowledgment signals
  assign lsu_ace_if.rack = '0; // TODO
  assign lsu_ace_if.wack = '0; // TODO

endmodule
