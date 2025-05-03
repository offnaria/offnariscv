// SPDX-License-Identifier: MIT

`include "../src/offnariscv_pkg.sv"

module offnariscv_core_wrap
  import offnariscv_pkg::*;
(
  input clk,
  input rst_n,

  // ifu
  output [ACE_XID_WIDTH-1:0] ifu_awid,
  output [ACE_AXADDR_WIDTH-1:0] ifu_awaddr,
  output [ACE_AXLEN_WIDTH-1:0] ifu_awlen,
  output [ACE_AXSIZE_WIDTH-1:0] ifu_awsize,
  output [ACE_AXBURST_WIDTH-1:0] ifu_awburst,
  output ifu_awlock,
  output [ACE_AXCACHE_WIDTH-1:0] ifu_awcache,
  output [ACE_AXPROT_WIDTH-1:0] ifu_awprot,
  output [ACE_AXQOS_WIDTH-1:0] ifu_awqos,
  output [ACE_AXREGION_WIDTH-1:0] ifu_awregion,
  output [ACE_XUSER_WIDTH-1:0] ifu_awuser,
  output ifu_awvalid,
  input  ifu_awready,
  output [ACE_AWSNOOP_WIDTH-1:0] ifu_awsnoop,
  output [ACE_DOMAIN_WIDTH-1:0] ifu_awdomain,
  output [ACE_BAR_WIDTH-1:0] ifu_awbar,
  output [ACE_XDATA_WIDTH-1:0] ifu_wdata,
  output [ACE_XDATA_WIDTH/8-1:0] ifu_wstrb,
  output ifu_wlast,
  output [ACE_XUSER_WIDTH-1:0] ifu_wuser,
  output ifu_wvalid,
  input  ifu_wready,
  input  [ACE_XID_WIDTH-1:0] ifu_bid,
  input  [ACE_BRESP_WIDTH-1:0] ifu_bresp,
  input  [ACE_XUSER_WIDTH-1:0] ifu_buser,
  input  ifu_bvalid,
  output ifu_bready,
  output [ACE_XID_WIDTH-1:0] ifu_arid,
  output [ACE_AXADDR_WIDTH-1:0] ifu_araddr,
  output [ACE_AXLEN_WIDTH-1:0] ifu_arlen,
  output [ACE_AXSIZE_WIDTH-1:0] ifu_arsize,
  output [ACE_AXBURST_WIDTH-1:0] ifu_arburst,
  output ifu_arlock,
  output [ACE_AXCACHE_WIDTH-1:0] ifu_arcache,
  output [ACE_AXPROT_WIDTH-1:0] ifu_arprot,
  output [ACE_AXQOS_WIDTH-1:0] ifu_arqos,
  output [ACE_AXREGION_WIDTH-1:0] ifu_arregion,
  output [ACE_XUSER_WIDTH-1:0] ifu_aruser,
  output ifu_arvalid,
  input  ifu_arready,
  output [ACE_ARSNOOP_WIDTH-1:0] ifu_arsnoop,
  output [ACE_DOMAIN_WIDTH-1:0] ifu_ardomain,
  output [ACE_BAR_WIDTH-1:0] ifu_arbar,
  input  [ACE_XID_WIDTH-1:0] ifu_rid,
  input  [ACE_XDATA_WIDTH-1:0] ifu_rdata,
  input  [ACE_RRESP_WIDTH-1:0] ifu_rresp,
  input  ifu_rlast,
  input  [ACE_XUSER_WIDTH-1:0] ifu_ruser,
  input  ifu_rvalid,
  output ifu_rready,
  input  ifu_acvalid,
  output ifu_acready,
  input  [ACE_ACADDR_WIDTH-1:0] ifu_acaddr,
  input  [ACE_ACSNOOP_WIDTH-1:0] ifu_acsnoop,
  input  [ACE_ACPROT_WIDTH-1:0] ifu_acprot,
  output ifu_crvalid,
  input  ifu_crready,
  output [ACE_CRRESP_WIDTH-1:0] ifu_crresp,
  output ifu_cdvalid,
  input  ifu_cdready,
  output [ACE_CDDATA_WIDTH-1:0] ifu_cddata,
  output ifu_cdlast,
  output ifu_rack,
  output ifu_wack,

  // lsu
  output [ACE_XID_WIDTH-1:0] lsu_awid,
  output [ACE_AXADDR_WIDTH-1:0] lsu_awaddr,
  output [ACE_AXLEN_WIDTH-1:0] lsu_awlen,
  output [ACE_AXSIZE_WIDTH-1:0] lsu_awsize,
  output [ACE_AXBURST_WIDTH-1:0] lsu_awburst,
  output lsu_awlock,
  output [ACE_AXCACHE_WIDTH-1:0] lsu_awcache,
  output [ACE_AXPROT_WIDTH-1:0] lsu_awprot,
  output [ACE_AXQOS_WIDTH-1:0] lsu_awqos,
  output [ACE_AXREGION_WIDTH-1:0] lsu_awregion,
  output [ACE_XUSER_WIDTH-1:0] lsu_awuser,
  output lsu_awvalid,
  input  lsu_awready,
  output [ACE_AWSNOOP_WIDTH-1:0] lsu_awsnoop,
  output [ACE_DOMAIN_WIDTH-1:0] lsu_awdomain,
  output [ACE_BAR_WIDTH-1:0] lsu_awbar,
  output [ACE_XDATA_WIDTH-1:0] lsu_wdata,
  output [ACE_XDATA_WIDTH/8-1:0] lsu_wstrb,
  output lsu_wlast,
  output [ACE_XUSER_WIDTH-1:0] lsu_wuser,
  output lsu_wvalid,
  input  lsu_wready,
  input  [ACE_XID_WIDTH-1:0] lsu_bid,
  input  [ACE_BRESP_WIDTH-1:0] lsu_bresp,
  input  [ACE_XUSER_WIDTH-1:0] lsu_buser,
  input  lsu_bvalid,
  output lsu_bready,
  output [ACE_XID_WIDTH-1:0] lsu_arid,
  output [ACE_AXADDR_WIDTH-1:0] lsu_araddr,
  output [ACE_AXLEN_WIDTH-1:0] lsu_arlen,
  output [ACE_AXSIZE_WIDTH-1:0] lsu_arsize,
  output [ACE_AXBURST_WIDTH-1:0] lsu_arburst,
  output lsu_arlock,
  output [ACE_AXCACHE_WIDTH-1:0] lsu_arcache,
  output [ACE_AXPROT_WIDTH-1:0] lsu_arprot,
  output [ACE_AXQOS_WIDTH-1:0] lsu_arqos,
  output [ACE_AXREGION_WIDTH-1:0] lsu_arregion,
  output [ACE_XUSER_WIDTH-1:0] lsu_aruser,
  output lsu_arvalid,
  input  lsu_arready,
  output [ACE_ARSNOOP_WIDTH-1:0] lsu_arsnoop,
  output [ACE_DOMAIN_WIDTH-1:0] lsu_ardomain,
  output [ACE_BAR_WIDTH-1:0] lsu_arbar,
  input  [ACE_XID_WIDTH-1:0] lsu_rid,
  input  [ACE_XDATA_WIDTH-1:0] lsu_rdata,
  input  [ACE_RRESP_WIDTH-1:0] lsu_rresp,
  input  lsu_rlast,
  input  [ACE_XUSER_WIDTH-1:0] lsu_ruser,
  input  lsu_rvalid,
  output lsu_rready,
  input  lsu_acvalid,
  output lsu_acready,
  input  [ACE_ACADDR_WIDTH-1:0] lsu_acaddr,
  input  [ACE_ACSNOOP_WIDTH-1:0] lsu_acsnoop,
  input  [ACE_ACPROT_WIDTH-1:0] lsu_acprot,
  output lsu_crvalid,
  input  lsu_crready,
  output [ACE_CRRESP_WIDTH-1:0] lsu_crresp,
  output lsu_cdvalid,
  input  lsu_cdready,
  output [ACE_CDDATA_WIDTH-1:0] lsu_cddata,
  output lsu_cdlast,
  output lsu_rack,
  output lsu_wack
);

  ace_if ifu_if ();
  ace_if lsu_if ();

  assign ifu_awid = ifu_if.awid;
  assign ifu_awaddr = ifu_if.awaddr;
  assign ifu_awlen = ifu_if.awlen;
  assign ifu_awsize = ifu_if.awsize;
  assign ifu_awburst = ifu_if.awburst;
  assign ifu_awlock = ifu_if.awlock;
  assign ifu_awcache = ifu_if.awcache;
  assign ifu_awprot = ifu_if.awprot;
  assign ifu_awqos = ifu_if.awqos;
  assign ifu_awregion = ifu_if.awregion;
  assign ifu_awuser = ifu_if.awuser;
  assign ifu_awvalid = ifu_if.awvalid;
  assign ifu_if.awready = ifu_awready;
  assign ifu_awsnoop = ifu_if.awsnoop;
  assign ifu_awdomain = ifu_if.awdomain;
  assign ifu_awbar = ifu_if.awbar;
  assign ifu_wdata = ifu_if.wdata;
  assign ifu_wstrb = ifu_if.wstrb;
  assign ifu_wlast = ifu_if.wlast;
  assign ifu_wuser = ifu_if.wuser;
  assign ifu_wvalid = ifu_if.wvalid;
  assign ifu_if.wready = ifu_wready;
  assign ifu_if.bid = ifu_bid;
  assign ifu_if.bresp = ifu_bresp;
  assign ifu_if.buser = ifu_buser;
  assign ifu_if.bvalid = ifu_bvalid;
  assign ifu_bready = ifu_if.bready;
  assign ifu_arid = ifu_if.arid;
  assign ifu_araddr = ifu_if.araddr;
  assign ifu_arlen = ifu_if.arlen;
  assign ifu_arsize = ifu_if.arsize;
  assign ifu_arburst = ifu_if.arburst;
  assign ifu_arlock = ifu_if.arlock;
  assign ifu_arcache = ifu_if.arcache;
  assign ifu_arprot = ifu_if.arprot;
  assign ifu_arqos = ifu_if.arqos;
  assign ifu_arregion = ifu_if.arregion;
  assign ifu_aruser = ifu_if.aruser;
  assign ifu_arvalid = ifu_if.arvalid;
  assign ifu_if.arready = ifu_arready;
  assign ifu_arsnoop = ifu_if.arsnoop;
  assign ifu_ardomain = ifu_if.ardomain;
  assign ifu_arbar = ifu_if.arbar;
  assign ifu_if.rid = ifu_rid;
  assign ifu_if.rdata = ifu_rdata;
  assign ifu_if.rresp = ifu_rresp;
  assign ifu_if.rlast = ifu_rlast;
  assign ifu_if.ruser = ifu_ruser;
  assign ifu_if.rvalid = ifu_rvalid;
  assign ifu_rready = ifu_if.rready;
  assign ifu_if.acvalid = ifu_acvalid;
  assign ifu_acready = ifu_if.acready;
  assign ifu_if.acaddr = ifu_acaddr;
  assign ifu_if.acsnoop = ifu_acsnoop;
  assign ifu_if.acprot = ifu_acprot;
  assign ifu_crvalid = ifu_if.crvalid;
  assign ifu_if.crready = ifu_crready;
  assign ifu_crresp = ifu_if.crresp;
  assign ifu_cdvalid = ifu_if.cdvalid;
  assign ifu_if.cdready = ifu_cdready;
  assign ifu_cddata = ifu_if.cddata;
  assign ifu_cdlast = ifu_if.cdlast;
  assign ifu_rack = ifu_if.rack;
  assign ifu_wack = ifu_if.wack;

  assign lsu_awid = lsu_if.awid;
  assign lsu_awaddr = lsu_if.awaddr;
  assign lsu_awlen = lsu_if.awlen;
  assign lsu_awsize = lsu_if.awsize;
  assign lsu_awburst = lsu_if.awburst;
  assign lsu_awlock = lsu_if.awlock;
  assign lsu_awcache = lsu_if.awcache;
  assign lsu_awprot = lsu_if.awprot;
  assign lsu_awqos = lsu_if.awqos;
  assign lsu_awregion = lsu_if.awregion;
  assign lsu_awuser = lsu_if.awuser;
  assign lsu_awvalid = lsu_if.awvalid;
  assign lsu_if.awready = lsu_awready;
  assign lsu_awsnoop = lsu_if.awsnoop;
  assign lsu_awdomain = lsu_if.awdomain;
  assign lsu_awbar = lsu_if.awbar;
  assign lsu_wdata = lsu_if.wdata;
  assign lsu_wstrb = lsu_if.wstrb;
  assign lsu_wlast = lsu_if.wlast;
  assign lsu_wuser = lsu_if.wuser;
  assign lsu_wvalid = lsu_if.wvalid;
  assign lsu_if.wready = lsu_wready;
  assign lsu_if.bid = lsu_bid;
  assign lsu_if.bresp = lsu_bresp;
  assign lsu_if.buser = lsu_buser;
  assign lsu_if.bvalid = lsu_bvalid;
  assign lsu_bready = lsu_if.bready;
  assign lsu_arid = lsu_if.arid;
  assign lsu_araddr = lsu_if.araddr;
  assign lsu_arlen = lsu_if.arlen;
  assign lsu_arsize = lsu_if.arsize;
  assign lsu_arburst = lsu_if.arburst;
  assign lsu_arlock = lsu_if.arlock;
  assign lsu_arcache = lsu_if.arcache;
  assign lsu_arprot = lsu_if.arprot;
  assign lsu_arqos = lsu_if.arqos;
  assign lsu_arregion = lsu_if.arregion;
  assign lsu_aruser = lsu_if.aruser;
  assign lsu_arvalid = lsu_if.arvalid;
  assign lsu_if.arready = lsu_arready;
  assign lsu_arsnoop = lsu_if.arsnoop;
  assign lsu_ardomain = lsu_if.ardomain;
  assign lsu_arbar = lsu_if.arbar;
  assign lsu_if.rid = lsu_rid;
  assign lsu_if.rdata = lsu_rdata;
  assign lsu_if.rresp = lsu_rresp;
  assign lsu_if.rlast = lsu_rlast;
  assign lsu_if.ruser = lsu_ruser;
  assign lsu_if.rvalid = lsu_rvalid;
  assign lsu_rready = lsu_if.rready;
  assign lsu_if.acvalid = lsu_acvalid;
  assign lsu_acready = lsu_if.acready;
  assign lsu_if.acaddr = lsu_acaddr;
  assign lsu_if.acsnoop = lsu_acsnoop;
  assign lsu_if.acprot = lsu_acprot;
  assign lsu_crvalid = lsu_if.crvalid;
  assign lsu_if.crready = lsu_crready;
  assign lsu_crresp = lsu_if.crresp;
  assign lsu_cdvalid = lsu_if.cdvalid;
  assign lsu_if.cdready = lsu_cdready;
  assign lsu_cddata = lsu_if.cddata;
  assign lsu_cdlast = lsu_if.cdlast;
  assign lsu_rack = lsu_if.rack;
  assign lsu_wack = lsu_if.wack;

  offnariscv_core offnariscv_core_inst (
    .clk(clk),
    .rst_n(rst_n),
    .ifu_if(ifu_if),
    .lsu_if(lsu_if)
  );

endmodule
