// SPDX-License-Identifier: MIT

module offnariscv_core_wrap
  import offnariscv_pkg::*;
# (
  localparam ACE_XDATA_WIDTH = 256,
  localparam ACE_AXADDR_WIDTH = 32
) (
  input clk,
  input rst,

  output [ACE_XID_WIDTH-1:0] core_ace_awid,
  output [ACE_AXADDR_WIDTH-1:0] core_ace_awaddr,
  output [ACE_AXLEN_WIDTH-1:0] core_ace_awlen,
  output [ACE_AXSIZE_WIDTH-1:0] core_ace_awsize,
  output [ACE_AXBURST_WIDTH-1:0] core_ace_awburst,
  output core_ace_awlock,
  output [ACE_AXCACHE_WIDTH-1:0] core_ace_awcache,
  output [ACE_AXPROT_WIDTH-1:0] core_ace_awprot,
  output [ACE_AXQOS_WIDTH-1:0] core_ace_awqos,
  output [ACE_AXREGION_WIDTH-1:0] core_ace_awregion,
  output [ACE_XUSER_WIDTH-1:0] core_ace_awuser,
  output core_ace_awvalid,
  input  core_ace_awready,
  output [ACE_AWSNOOP_WIDTH-1:0] core_ace_awsnoop,
  output [ACE_DOMAIN_WIDTH-1:0] core_ace_awdomain,
  output [ACE_BAR_WIDTH-1:0] core_ace_awbar,
  output [ACE_XDATA_WIDTH-1:0] core_ace_wdata,
  output [ACE_XDATA_WIDTH/8-1:0] core_ace_wstrb,
  output core_ace_wlast,
  output [ACE_XUSER_WIDTH-1:0] core_ace_wuser,
  output core_ace_wvalid,
  input  core_ace_wready,
  input  [ACE_XID_WIDTH-1:0] core_ace_bid,
  input  [ACE_BRESP_WIDTH-1:0] core_ace_bresp,
  input  [ACE_XUSER_WIDTH-1:0] core_ace_buser,
  input  core_ace_bvalid,
  output core_ace_bready,
  output [ACE_XID_WIDTH-1:0] core_ace_arid,
  output [ACE_AXADDR_WIDTH-1:0] core_ace_araddr,
  output [ACE_AXLEN_WIDTH-1:0] core_ace_arlen,
  output [ACE_AXSIZE_WIDTH-1:0] core_ace_arsize,
  output [ACE_AXBURST_WIDTH-1:0] core_ace_arburst,
  output core_ace_arlock,
  output [ACE_AXCACHE_WIDTH-1:0] core_ace_arcache,
  output [ACE_AXPROT_WIDTH-1:0] core_ace_arprot,
  output [ACE_AXQOS_WIDTH-1:0] core_ace_arqos,
  output [ACE_AXREGION_WIDTH-1:0] core_ace_arregion,
  output [ACE_XUSER_WIDTH-1:0] core_ace_aruser,
  output core_ace_arvalid,
  input  core_ace_arready,
  output [ACE_ARSNOOP_WIDTH-1:0] core_ace_arsnoop,
  output [ACE_DOMAIN_WIDTH-1:0] core_ace_ardomain,
  output [ACE_BAR_WIDTH-1:0] core_ace_arbar,
  input  [ACE_XID_WIDTH-1:0] core_ace_rid,
  input  [ACE_XDATA_WIDTH-1:0] core_ace_rdata,
  input  [ACE_RRESP_WIDTH-1:0] core_ace_rresp,
  input  core_ace_rlast,
  input  [ACE_XUSER_WIDTH-1:0] core_ace_ruser,
  input  core_ace_rvalid,
  output core_ace_rready,
  input  core_ace_acvalid,
  output core_ace_acready,
  input  [ACE_AXADDR_WIDTH-1:0] core_ace_acaddr,
  input  [ACE_ACSNOOP_WIDTH-1:0] core_ace_acsnoop,
  input  [ACE_ACPROT_WIDTH-1:0] core_ace_acprot,
  output core_ace_crvalid,
  input  core_ace_crready,
  output [ACE_CRRESP_WIDTH-1:0] core_ace_crresp,
  output core_ace_cdvalid,
  input  core_ace_cdready,
  output [ACE_XDATA_WIDTH-1:0] core_ace_cddata,
  output core_ace_cdlast,
  output core_ace_rack,
  output core_ace_wack
);

  ace_if core_ace_if ();

  assign core_ace_awid = core_ace_if.awid;
  assign core_ace_awaddr = core_ace_if.awaddr;
  assign core_ace_awlen = core_ace_if.awlen;
  assign core_ace_awsize = core_ace_if.awsize;
  assign core_ace_awburst = core_ace_if.awburst;
  assign core_ace_awlock = core_ace_if.awlock;
  assign core_ace_awcache = core_ace_if.awcache;
  assign core_ace_awprot = core_ace_if.awprot;
  assign core_ace_awqos = core_ace_if.awqos;
  assign core_ace_awregion = core_ace_if.awregion;
  assign core_ace_awuser = core_ace_if.awuser;
  assign core_ace_awvalid = core_ace_if.awvalid;
  assign core_ace_if.awready = core_ace_awready;
  assign core_ace_awsnoop = core_ace_if.awsnoop;
  assign core_ace_awdomain = core_ace_if.awdomain;
  assign core_ace_awbar = core_ace_if.awbar;
  assign core_ace_wdata = core_ace_if.wdata;
  assign core_ace_wstrb = core_ace_if.wstrb;
  assign core_ace_wlast = core_ace_if.wlast;
  assign core_ace_wuser = core_ace_if.wuser;
  assign core_ace_wvalid = core_ace_if.wvalid;
  assign core_ace_if.wready = core_ace_wready;
  assign core_ace_if.bid = core_ace_bid;
  assign core_ace_if.bresp = core_ace_bresp;
  assign core_ace_if.buser = core_ace_buser;
  assign core_ace_if.bvalid = core_ace_bvalid;
  assign core_ace_bready = core_ace_if.bready;
  assign core_ace_arid = core_ace_if.arid;
  assign core_ace_araddr = core_ace_if.araddr;
  assign core_ace_arlen = core_ace_if.arlen;
  assign core_ace_arsize = core_ace_if.arsize;
  assign core_ace_arburst = core_ace_if.arburst;
  assign core_ace_arlock = core_ace_if.arlock;
  assign core_ace_arcache = core_ace_if.arcache;
  assign core_ace_arprot = core_ace_if.arprot;
  assign core_ace_arqos = core_ace_if.arqos;
  assign core_ace_arregion = core_ace_if.arregion;
  assign core_ace_aruser = core_ace_if.aruser;
  assign core_ace_arvalid = core_ace_if.arvalid;
  assign core_ace_if.arready = core_ace_arready;
  assign core_ace_arsnoop = core_ace_if.arsnoop;
  assign core_ace_ardomain = core_ace_if.ardomain;
  assign core_ace_arbar = core_ace_if.arbar;
  assign core_ace_if.rid = core_ace_rid;
  assign core_ace_if.rdata = core_ace_rdata;
  assign core_ace_if.rresp = core_ace_rresp;
  assign core_ace_if.rlast = core_ace_rlast;
  assign core_ace_if.ruser = core_ace_ruser;
  assign core_ace_if.rvalid = core_ace_rvalid;
  assign core_ace_rready = core_ace_if.rready;
  assign core_ace_if.acvalid = core_ace_acvalid;
  assign core_ace_acready = core_ace_if.acready;
  assign core_ace_if.acaddr = core_ace_acaddr;
  assign core_ace_if.acsnoop = core_ace_acsnoop;
  assign core_ace_if.acprot = core_ace_acprot;
  assign core_ace_crvalid = core_ace_if.crvalid;
  assign core_ace_if.crready = core_ace_crready;
  assign core_ace_crresp = core_ace_if.crresp;
  assign core_ace_cdvalid = core_ace_if.cdvalid;
  assign core_ace_if.cdready = core_ace_cdready;
  assign core_ace_cddata = core_ace_if.cddata;
  assign core_ace_cdlast = core_ace_if.cdlast;
  assign core_ace_rack = core_ace_if.rack;
  assign core_ace_wack = core_ace_if.wack;

  offnariscv_core #(
    .RESET_VECTOR(0)
  ) offnariscv_core_inst (
    .clk(clk),
    .rst(rst),
    .core_ace_if(core_ace_if)
  );

endmodule
