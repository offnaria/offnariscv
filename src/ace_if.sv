// SPDX-License-Identifier: MIT

interface ace_if
  import offnariscv_pkg::*;
#(
    parameter ACE_XDATA_WIDTH  = 256,
    parameter ACE_AXADDR_WIDTH = 32
);
  // AW channel signals
  logic [     ACE_XID_WIDTH-1:0] awid;
  logic [  ACE_AXADDR_WIDTH-1:0] awaddr;
  logic [   ACE_AXLEN_WIDTH-1:0] awlen;
  logic [  ACE_AXSIZE_WIDTH-1:0] awsize;
  logic [ ACE_AXBURST_WIDTH-1:0] awburst;
  logic                          awlock;
  logic [ ACE_AXCACHE_WIDTH-1:0] awcache;
  logic [  ACE_AXPROT_WIDTH-1:0] awprot;
  logic [   ACE_AXQOS_WIDTH-1:0] awqos;
  logic [ACE_AXREGION_WIDTH-1:0] awregion;
  logic [   ACE_XUSER_WIDTH-1:0] awuser;
  logic                          awvalid;
  logic                          awready;
  logic [ ACE_AWSNOOP_WIDTH-1:0] awsnoop;  // ACE
  logic [  ACE_DOMAIN_WIDTH-1:0] awdomain;  // ACE
  logic [     ACE_BAR_WIDTH-1:0] awbar;  // ACE

  // W channel signals
  logic [   ACE_XDATA_WIDTH-1:0] wdata;
  logic [ ACE_XDATA_WIDTH/8-1:0] wstrb;
  logic                          wlast;
  logic [   ACE_XUSER_WIDTH-1:0] wuser;
  logic                          wvalid;
  logic                          wready;

  // B channel signals
  logic [     ACE_XID_WIDTH-1:0] bid;
  logic [   ACE_BRESP_WIDTH-1:0] bresp;
  logic [   ACE_XUSER_WIDTH-1:0] buser;
  logic                          bvalid;
  logic                          bready;

  // AR channel signals
  logic [     ACE_XID_WIDTH-1:0] arid;
  logic [  ACE_AXADDR_WIDTH-1:0] araddr;
  logic [   ACE_AXLEN_WIDTH-1:0] arlen;
  logic [  ACE_AXSIZE_WIDTH-1:0] arsize;
  logic [ ACE_AXBURST_WIDTH-1:0] arburst;
  logic                          arlock;
  logic [ ACE_AXCACHE_WIDTH-1:0] arcache;
  logic [  ACE_AXPROT_WIDTH-1:0] arprot;
  logic [   ACE_AXQOS_WIDTH-1:0] arqos;
  logic [ACE_AXREGION_WIDTH-1:0] arregion;
  logic [   ACE_XUSER_WIDTH-1:0] aruser;
  logic                          arvalid;
  logic                          arready;
  logic [ ACE_ARSNOOP_WIDTH-1:0] arsnoop;  // ACE
  logic [  ACE_DOMAIN_WIDTH-1:0] ardomain;  // ACE
  logic [     ACE_BAR_WIDTH-1:0] arbar;  // ACE

  // R channel signals
  logic [     ACE_XID_WIDTH-1:0] rid;
  logic [   ACE_XDATA_WIDTH-1:0] rdata;
  logic [   ACE_RRESP_WIDTH-1:0] rresp;  // ACE
  logic                          rlast;
  logic [   ACE_XUSER_WIDTH-1:0] ruser;
  logic                          rvalid;
  logic                          rready;

  // AC channel signals
  logic                          acvalid;
  logic                          acready;
  logic [  ACE_AXADDR_WIDTH-1:0] acaddr;
  logic [ ACE_ACSNOOP_WIDTH-1:0] acsnoop;
  logic [  ACE_ACPROT_WIDTH-1:0] acprot;

  // CR channel signals
  logic                          crvalid;
  logic                          crready;
  logic [  ACE_CRRESP_WIDTH-1:0] crresp;

  // CD channel signals
  logic                          cdvalid;
  logic                          cdready;
  logic [   ACE_XDATA_WIDTH-1:0] cddata;
  logic                          cdlast;

  // Additional signals
  logic                          rack;
  logic                          wack;

  modport m(
      output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awvalid,
      input awready,
      output awsnoop, awdomain, awbar,
      output wdata, wstrb, wlast, wuser, wvalid,
      input wready,
      input bid, bresp, buser, bvalid,
      output bready,
      output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, arvalid,
      input arready,
      output arsnoop, ardomain, arbar,
      input rid, rdata, rresp, rlast, ruser, rvalid,
      output rready,
      input acvalid,
      output acready,
      input acaddr, acsnoop, acprot,
      output crvalid,
      input crready,
      output crresp,
      output cdvalid,
      input cdready,
      output cddata, cdlast,
      output rack, wack
  );

  modport s(
      input awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awvalid,
      output awready,
      input awsnoop, awdomain, awbar,
      input wdata, wstrb, wlast, wuser, wvalid,
      output wready,
      output bid, bresp, buser, bvalid,
      input bready,
      input arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, arvalid,
      output arready,
      input arsnoop, ardomain, arbar,
      output rid, rdata, rresp, rlast, ruser, rvalid,
      input rready,
      output acvalid,
      input acready,
      output acaddr, acsnoop, acprot,
      input crvalid,
      output crready,
      input crresp,
      input cdvalid,
      output cdready,
      input cddata, cdlast,
      input rack, wack
  );

endinterface
