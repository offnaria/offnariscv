// SPDX-License-Identifier: MIT

`include "../../src/offnariscv_pkg.sv"

module ifu_ace_wrap
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

  ace_if ifu_ace_if ();

  // AW channel signals
  assign awid = ifu_ace_if.awid;
  assign awaddr = ifu_ace_if.awaddr;
  assign awlen = ifu_ace_if.awlen;
  assign awsize = ifu_ace_if.awsize;
  assign awburst = ifu_ace_if.awburst;
  assign awlock = ifu_ace_if.awlock;
  assign awcache = ifu_ace_if.awcache;
  assign awprot = ifu_ace_if.awprot;
  assign awqos = ifu_ace_if.awqos;
  assign awregion = ifu_ace_if.awregion;
  assign awuser = ifu_ace_if.awuser;
  assign awvalid = ifu_ace_if.awvalid;
  assign ifu_ace_if.awready = awready;
  assign awsnoop = ifu_ace_if.awsnoop;
  assign awdomain = ifu_ace_if.awdomain;
  assign awbar = ifu_ace_if.awbar;

  // W channel signals
  assign wdata = ifu_ace_if.wdata;
  assign wstrb = ifu_ace_if.wstrb;
  assign wlast = ifu_ace_if.wlast;
  assign wuser = ifu_ace_if.wuser;
  assign wvalid = ifu_ace_if.wvalid;
  assign ifu_ace_if.wready = wready;

  // B channel signals
  assign ifu_ace_if.bid = bid;
  assign ifu_ace_if.bresp = bresp;
  assign ifu_ace_if.buser = buser;
  assign ifu_ace_if.bvalid = bvalid;
  assign bready = ifu_ace_if.bready;

  // AR channel signals
  assign arid = ifu_ace_if.arid;
  assign araddr = ifu_ace_if.araddr;
  assign arlen = ifu_ace_if.arlen;
  assign arsize = ifu_ace_if.arsize;
  assign arburst = ifu_ace_if.arburst;
  assign arlock = ifu_ace_if.arlock;
  assign arcache = ifu_ace_if.arcache;
  assign arprot = ifu_ace_if.arprot;
  assign arqos = ifu_ace_if.arqos;
  assign arregion = ifu_ace_if.arregion;
  assign aruser = ifu_ace_if.aruser;
  assign arvalid = ifu_ace_if.arvalid;
  assign ifu_ace_if.arready = arready;
  assign arsnoop = ifu_ace_if.arsnoop;
  assign ardomain = ifu_ace_if.ardomain;
  assign arbar = ifu_ace_if.arbar;

  // R channel signals
  assign ifu_ace_if.rid = rid;
  assign ifu_ace_if.rdata = rdata;
  assign ifu_ace_if.rresp = rresp;
  assign ifu_ace_if.rlast = rlast;
  assign ifu_ace_if.ruser = ruser;
  assign ifu_ace_if.rvalid = rvalid;
  assign rready = ifu_ace_if.rready;

  // AC channel signals
  assign ifu_ace_if.acvalid = acvalid;
  assign acready = ifu_ace_if.acready;
  assign ifu_ace_if.acaddr = acaddr;
  assign ifu_ace_if.acsnoop = acsnoop;
  assign ifu_ace_if.acprot = acprot;

  // CR channel signals
  assign crvalid = ifu_ace_if.crvalid;
  assign ifu_ace_if.crready = crready;
  assign crresp = ifu_ace_if.crresp;

  // CD channel signals
  assign cdvalid = ifu_ace_if.cdvalid;
  assign ifu_ace_if.cdready = cdready;
  assign cddata = ifu_ace_if.cddata;
  assign cdlast = ifu_ace_if.cdlast;

  // Additional signals
  assign rack = ifu_ace_if.rack;
  assign wack = ifu_ace_if.wack;

  ifu ifu_inst (
    .clk(clk),
    .rst_n(rst_n),
    .ifu_ace_if(ifu_ace_if)
  );

endmodule
