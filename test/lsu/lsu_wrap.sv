// SPDX-License-Identifier: MIT

module lsu_wrap
  import offnariscv_pkg::*;
# (
  parameter ACE_XDATA_WIDTH = 256,
  parameter ACE_AXADDR_WIDTH = 32
) (
  input clk,
  input rst_n,

  // AW channel signals
  output [ACE_XID_WIDTH-1:0] lsu_ace_awid,
  output [ACE_AXADDR_WIDTH-1:0] lsu_ace_awaddr,
  output [ACE_AXLEN_WIDTH-1:0] lsu_ace_awlen,
  output [ACE_AXSIZE_WIDTH-1:0] lsu_ace_awsize,
  output [ACE_AXBURST_WIDTH-1:0] lsu_ace_awburst,
  output lsu_ace_awlock,
  output [ACE_AXCACHE_WIDTH-1:0] lsu_ace_awcache,
  output [ACE_AXPROT_WIDTH-1:0] lsu_ace_awprot,
  output [ACE_AXQOS_WIDTH-1:0] lsu_ace_awqos,
  output [ACE_AXREGION_WIDTH-1:0] lsu_ace_awregion,
  output [ACE_XUSER_WIDTH-1:0] lsu_ace_awuser,
  output lsu_ace_awvalid,
  input  lsu_ace_awready,
  output [ACE_AWSNOOP_WIDTH-1:0] lsu_ace_awsnoop,
  output [ACE_DOMAIN_WIDTH-1:0] lsu_ace_awdomain,
  output [ACE_BAR_WIDTH-1:0] lsu_ace_awbar,

  // W channel signals
  output [ACE_XDATA_WIDTH-1:0] lsu_ace_wdata,
  output [ACE_XDATA_WIDTH/8-1:0] lsu_ace_wstrb,
  output lsu_ace_wlast,
  output [ACE_XUSER_WIDTH-1:0] lsu_ace_wuser,
  output lsu_ace_wvalid,
  input  lsu_ace_wready,

  // B channel signals
  input  [ACE_XID_WIDTH-1:0] lsu_ace_bid,
  input  [ACE_BRESP_WIDTH-1:0] lsu_ace_bresp,
  input  [ACE_XUSER_WIDTH-1:0] lsu_ace_buser,
  input  lsu_ace_bvalid,
  output lsu_ace_bready,

  // AR channel signals
  output [ACE_XID_WIDTH-1:0] lsu_ace_arid,
  output [ACE_AXADDR_WIDTH-1:0] lsu_ace_araddr,
  output [ACE_AXLEN_WIDTH-1:0] lsu_ace_arlen,
  output [ACE_AXSIZE_WIDTH-1:0] lsu_ace_arsize,
  output [ACE_AXBURST_WIDTH-1:0] lsu_ace_arburst,
  output lsu_ace_arlock,
  output [ACE_AXCACHE_WIDTH-1:0] lsu_ace_arcache,
  output [ACE_AXPROT_WIDTH-1:0] lsu_ace_arprot,
  output [ACE_AXQOS_WIDTH-1:0] lsu_ace_arqos,
  output [ACE_AXREGION_WIDTH-1:0] lsu_ace_arregion,
  output [ACE_XUSER_WIDTH-1:0] lsu_ace_aruser,
  output lsu_ace_arvalid,
  input  lsu_ace_arready,
  output [ACE_ARSNOOP_WIDTH-1:0] lsu_ace_arsnoop,
  output [ACE_DOMAIN_WIDTH-1:0] lsu_ace_ardomain,
  output [ACE_BAR_WIDTH-1:0] lsu_ace_arbar,

  // R channel signals
  input  [ACE_XID_WIDTH-1:0] lsu_ace_rid,
  input  [ACE_XDATA_WIDTH-1:0] lsu_ace_rdata,
  input  [ACE_RRESP_WIDTH-1:0] lsu_ace_rresp,
  input  lsu_ace_rlast,
  input  [ACE_XUSER_WIDTH-1:0] lsu_ace_ruser,
  input  lsu_ace_rvalid,
  output lsu_ace_rready,

  // AC channel signals
  input  lsu_ace_acvalid,
  output lsu_ace_acready,
  input  [ACE_AXADDR_WIDTH-1:0] lsu_ace_acaddr,
  input  [ACE_ACSNOOP_WIDTH-1:0] lsu_ace_acsnoop,
  input  [ACE_ACPROT_WIDTH-1:0] lsu_ace_acprot,

  // CR channel signals
  output lsu_ace_crvalid,
  input  lsu_ace_crready,
  output [ACE_CRRESP_WIDTH-1:0] lsu_ace_crresp,

  // CD channel signals
  output lsu_ace_cdvalid,
  input  lsu_ace_cdready,
  output [ACE_XDATA_WIDTH-1:0] lsu_ace_cddata,
  output lsu_ace_cdlast,

  // Additional signals
  output lsu_ace_rack,
  output lsu_ace_wack
);

  ace_if lsu_ace_if ();

  // AW channel signals
  assign lsu_ace_awid = lsu_ace_if.awid;
  assign lsu_ace_awaddr = lsu_ace_if.awaddr;
  assign lsu_ace_awlen = lsu_ace_if.awlen;
  assign lsu_ace_awsize = lsu_ace_if.awsize;
  assign lsu_ace_awburst = lsu_ace_if.awburst;
  assign lsu_ace_awlock = lsu_ace_if.awlock;
  assign lsu_ace_awcache = lsu_ace_if.awcache;
  assign lsu_ace_awprot = lsu_ace_if.awprot;
  assign lsu_ace_awqos = lsu_ace_if.awqos;
  assign lsu_ace_awregion = lsu_ace_if.awregion;
  assign lsu_ace_awuser = lsu_ace_if.awuser;
  assign lsu_ace_awvalid = lsu_ace_if.awvalid;
  assign lsu_ace_if.awready = lsu_ace_awready;
  assign lsu_ace_awsnoop = lsu_ace_if.awsnoop;
  assign lsu_ace_awdomain = lsu_ace_if.awdomain;
  assign lsu_ace_awbar = lsu_ace_if.awbar;

  // W channel signals
  assign lsu_ace_wdata = lsu_ace_if.wdata;
  assign lsu_ace_wstrb = lsu_ace_if.wstrb;
  assign lsu_ace_wlast = lsu_ace_if.wlast;
  assign lsu_ace_wuser = lsu_ace_if.wuser;
  assign lsu_ace_wvalid = lsu_ace_if.wvalid;
  assign lsu_ace_if.wready = lsu_ace_wready;

  // B channel signals
  assign lsu_ace_if.bid = lsu_ace_bid;
  assign lsu_ace_if.bresp = lsu_ace_bresp;
  assign lsu_ace_if.buser = lsu_ace_buser;
  assign lsu_ace_if.bvalid = lsu_ace_bvalid;
  assign lsu_ace_bready = lsu_ace_if.bready;

  // AR channel signals
  assign lsu_ace_arid = lsu_ace_if.arid;
  assign lsu_ace_araddr = lsu_ace_if.araddr;
  assign lsu_ace_arlen = lsu_ace_if.arlen;
  assign lsu_ace_arsize = lsu_ace_if.arsize;
  assign lsu_ace_arburst = lsu_ace_if.arburst;
  assign lsu_ace_arlock = lsu_ace_if.arlock;
  assign lsu_ace_arcache = lsu_ace_if.arcache;
  assign lsu_ace_arprot = lsu_ace_if.arprot;
  assign lsu_ace_arqos = lsu_ace_if.arqos;
  assign lsu_ace_arregion = lsu_ace_if.arregion;
  assign lsu_ace_aruser = lsu_ace_if.aruser;
  assign lsu_ace_arvalid = lsu_ace_if.arvalid;
  assign lsu_ace_if.arready = lsu_ace_arready;
  assign lsu_ace_arsnoop = lsu_ace_if.arsnoop;
  assign lsu_ace_ardomain = lsu_ace_if.ardomain;
  assign lsu_ace_arbar = lsu_ace_if.arbar;

  // R channel signals
  assign lsu_ace_if.rid = lsu_ace_rid;
  assign lsu_ace_if.rdata = lsu_ace_rdata;
  assign lsu_ace_if.rresp = lsu_ace_rresp;
  assign lsu_ace_if.rlast = lsu_ace_rlast;
  assign lsu_ace_if.ruser = lsu_ace_ruser;
  assign lsu_ace_if.rvalid = lsu_ace_rvalid;
  assign lsu_ace_rready = lsu_ace_if.rready;

  // AC channel signals
  assign lsu_ace_if.acvalid = lsu_ace_acvalid;
  assign lsu_ace_acready = lsu_ace_if.acready;
  assign lsu_ace_if.acaddr = lsu_ace_acaddr;
  assign lsu_ace_if.acsnoop = lsu_ace_acsnoop;
  assign lsu_ace_if.acprot = lsu_ace_acprot;

  // CR channel signals
  assign lsu_ace_crvalid = lsu_ace_if.crvalid;
  assign lsu_ace_if.crready = lsu_ace_crready;
  assign lsu_ace_crresp = lsu_ace_if.crresp;

  // CD channel signals
  assign lsu_ace_cdvalid = lsu_ace_if.cdvalid;
  assign lsu_ace_if.cdready = lsu_ace_cdready;
  assign lsu_ace_cddata = lsu_ace_if.cddata;
  assign lsu_ace_cdlast = lsu_ace_if.cdlast;

  // Additional signals
  assign lsu_ace_rack = lsu_ace_if.rack;
  assign lsu_ace_wack = lsu_ace_if.wack;

  lsu lsu_inst (
    .clk(clk),
    .rst_n(rst_n),
    .lsu_ace_if(lsu_ace_if)
  );

endmodule
