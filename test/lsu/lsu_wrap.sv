// SPDX-License-Identifier: MIT

`include "../../src/offnariscv_pkg.sv"

module lsu_ace_wrap
  import offnariscv_pkg::*;
(
  input clk,
  input rst_n,

  // AW channel signals
  output [ACE_XID_WIDTH-1:0] awid,
  output [ACE_AXADDR_WIDTH-1:0] awaddr,
  output [ACE_AXLEN_WIDTH-1:0] awlen,
  output [ACE_AXSIZE_WIDTH-1:0] awsize,
  output [ACE_AXBURST_WIDTH-1:0] awburst,
  output awlock,
  output [ACE_AXCACHE_WIDTH-1:0] awcache,
  output [ACE_AXPROT_WIDTH-1:0] awprot,
  output [ACE_AXQOS_WIDTH-1:0] awqos,
  output [ACE_AXREGION_WIDTH-1:0] awregion,
  output [ACE_XUSER_WIDTH-1:0] awuser,
  output awvalid,
  input  awready,
  output [ACE_AWSNOOP_WIDTH-1:0] awsnoop, // ACE
  output [ACE_DOMAIN_WIDTH-1:0] awdomain, // ACE
  output [ACE_BAR_WIDTH-1:0] awbar,       // ACE

  // W channel signals
  output [ACE_XDATA_WIDTH-1:0] wdata,
  output [ACE_XDATA_WIDTH/8-1:0] wstrb,
  output wlast,
  output [ACE_XUSER_WIDTH-1:0] wuser,
  output wvalid,
  input  wready,

  // B channel signals
  input  [ACE_XID_WIDTH-1:0] bid,
  input  [ACE_BRESP_WIDTH-1:0] bresp,
  input  [ACE_XUSER_WIDTH-1:0] buser,
  input  bvalid,
  output bready,

  // AR channel signals
  output [ACE_XID_WIDTH-1:0] arid,
  output [ACE_AXADDR_WIDTH-1:0] araddr,
  output [ACE_AXLEN_WIDTH-1:0] arlen,
  output [ACE_AXSIZE_WIDTH-1:0] arsize,
  output [ACE_AXBURST_WIDTH-1:0] arburst,
  output arlock,
  output [ACE_AXCACHE_WIDTH-1:0] arcache,
  output [ACE_AXPROT_WIDTH-1:0] arprot,
  output [ACE_AXQOS_WIDTH-1:0] arqos,
  output [ACE_AXREGION_WIDTH-1:0] arregion,
  output [ACE_XUSER_WIDTH-1:0] aruser,
  output arvalid,
  input  arready,
  output [ACE_ARSNOOP_WIDTH-1:0] arsnoop,  // ACE
  output [ACE_DOMAIN_WIDTH-1:0] ardomain, // ACE
  output [ACE_BAR_WIDTH-1:0] arbar,       // ACE

  // R channel signals
  input  [ACE_XID_WIDTH-1:0] rid,
  input  [ACE_XDATA_WIDTH-1:0] rdata,
  input  [ACE_RRESP_WIDTH-1:0] rresp, // ACE
  input  rlast,
  input  [ACE_XUSER_WIDTH-1:0] ruser,
  input  rvalid,
  output rready,

  // AC channel signals
  input  acvalid,
  output acready,
  input  [ACE_ACADDR_WIDTH-1:0] acaddr,
  input  [ACE_ACSNOOP_WIDTH-1:0] acsnoop,
  input  [ACE_ACPROT_WIDTH-1:0] acprot,

  // CR channel signals
  output crvalid,
  input  crready,
  output [ACE_CRRESP_WIDTH-1:0] crresp,

  // CD channel signals
  output cdvalid,
  input  cdready,
  output [ACE_CDDATA_WIDTH-1:0] cddata,
  output cdlast,

  // Additional signals
  output rack,
  output wack
);

  ace_if lsu_ace_if ();

  // AW channel signals
  assign awid = lsu_ace_if.awid;
  assign awaddr = lsu_ace_if.awaddr;
  assign awlen = lsu_ace_if.awlen;
  assign awsize = lsu_ace_if.awsize;
  assign awburst = lsu_ace_if.awburst;
  assign awlock = lsu_ace_if.awlock;
  assign awcache = lsu_ace_if.awcache;
  assign awprot = lsu_ace_if.awprot;
  assign awqos = lsu_ace_if.awqos;
  assign awregion = lsu_ace_if.awregion;
  assign awuser = lsu_ace_if.awuser;
  assign awvalid = lsu_ace_if.awvalid;
  assign lsu_ace_if.awready = awready;
  assign awsnoop = lsu_ace_if.awsnoop;
  assign awdomain = lsu_ace_if.awdomain;
  assign awbar = lsu_ace_if.awbar;

  // W channel signals
  assign wdata = lsu_ace_if.wdata;
  assign wstrb = lsu_ace_if.wstrb;
  assign wlast = lsu_ace_if.wlast;
  assign wuser = lsu_ace_if.wuser;
  assign wvalid = lsu_ace_if.wvalid;
  assign lsu_ace_if.wready = wready;

  // B channel signals
  assign lsu_ace_if.bid = bid;
  assign lsu_ace_if.bresp = bresp;
  assign lsu_ace_if.buser = buser;
  assign lsu_ace_if.bvalid = bvalid;
  assign bready = lsu_ace_if.bready;

  // AR channel signals
  assign arid = lsu_ace_if.arid;
  assign araddr = lsu_ace_if.araddr;
  assign arlen = lsu_ace_if.arlen;
  assign arsize = lsu_ace_if.arsize;
  assign arburst = lsu_ace_if.arburst;
  assign arlock = lsu_ace_if.arlock;
  assign arcache = lsu_ace_if.arcache;
  assign arprot = lsu_ace_if.arprot;
  assign arqos = lsu_ace_if.arqos;
  assign arregion = lsu_ace_if.arregion;
  assign aruser = lsu_ace_if.aruser;
  assign arvalid = lsu_ace_if.arvalid;
  assign lsu_ace_if.arready = arready;
  assign arsnoop = lsu_ace_if.arsnoop;
  assign ardomain = lsu_ace_if.ardomain;
  assign arbar = lsu_ace_if.arbar;

  // R channel signals
  assign lsu_ace_if.rid = rid;
  assign lsu_ace_if.rdata = rdata;
  assign lsu_ace_if.rresp = rresp;
  assign lsu_ace_if.rlast = rlast;
  assign lsu_ace_if.ruser = ruser;
  assign lsu_ace_if.rvalid = rvalid;
  assign rready = lsu_ace_if.rready;

  // AC channel signals
  assign lsu_ace_if.acvalid = acvalid;
  assign acready = lsu_ace_if.acready;
  assign lsu_ace_if.acaddr = acaddr;
  assign lsu_ace_if.acsnoop = acsnoop;
  assign lsu_ace_if.acprot = acprot;

  // CR channel signals
  assign crvalid = lsu_ace_if.crvalid;
  assign lsu_ace_if.crready = crready;
  assign crresp = lsu_ace_if.crresp;

  // CD channel signals
  assign cdvalid = lsu_ace_if.cdvalid;
  assign lsu_ace_if.cdready = cdready;
  assign cddata = lsu_ace_if.cddata;
  assign cdlast = lsu_ace_if.cdlast;

  // Additional signals
  assign rack = lsu_ace_if.rack;
  assign wack = lsu_ace_if.wack;

  lsu lsu_inst (
    .clk(clk),
    .rst_n(rst_n),
    .lsu_ace_if(lsu_ace_if)
  );

endmodule
