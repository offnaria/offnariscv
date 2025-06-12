// SPDX-License-Identifier: MIT

module ifu_wrap
  import offnariscv_pkg::*;
# (
  localparam ACE_XDATA_WIDTH = 256,
  localparam ACE_AXADDR_WIDTH = 32
) (
  input clk,
  input rst,

  // AR channel signals
  output [ACE_XID_WIDTH-1:0] ifu_ace_arid,
  output [ACE_AXADDR_WIDTH-1:0] ifu_ace_araddr,
  output [ACE_AXLEN_WIDTH-1:0] ifu_ace_arlen,
  output [ACE_AXSIZE_WIDTH-1:0] ifu_ace_arsize,
  output [ACE_AXBURST_WIDTH-1:0] ifu_ace_arburst,
  output ifu_ace_arlock,
  output [ACE_AXCACHE_WIDTH-1:0] ifu_ace_arcache,
  output [ACE_AXPROT_WIDTH-1:0] ifu_ace_arprot,
  output [ACE_AXQOS_WIDTH-1:0] ifu_ace_arqos,
  output [ACE_AXREGION_WIDTH-1:0] ifu_ace_arregion,
  output [ACE_XUSER_WIDTH-1:0] ifu_ace_aruser,
  output ifu_ace_arvalid,
  input  ifu_ace_arready,
  output [ACE_ARSNOOP_WIDTH-1:0] ifu_ace_arsnoop,
  output [ACE_DOMAIN_WIDTH-1:0] ifu_ace_ardomain,
  output [ACE_BAR_WIDTH-1:0] ifu_ace_arbar,

  // R channel signals
  input  [ACE_XID_WIDTH-1:0] ifu_ace_rid,
  input  [ACE_XDATA_WIDTH-1:0] ifu_ace_rdata,
  input  [ACE_RRESP_WIDTH-1:0] ifu_ace_rresp,
  input  ifu_ace_rlast,
  input  [ACE_XUSER_WIDTH-1:0] ifu_ace_ruser,
  input  ifu_ace_rvalid,
  output ifu_ace_rready,

  // AC channel signals
  input  ifu_ace_acvalid,
  output ifu_ace_acready,
  input  [ACE_AXADDR_WIDTH-1:0] ifu_ace_acaddr,
  input  [ACE_ACSNOOP_WIDTH-1:0] ifu_ace_acsnoop,
  input  [ACE_ACPROT_WIDTH-1:0] ifu_ace_acprot,

  // CR channel signals
  output ifu_ace_crvalid,
  input  ifu_ace_crready,
  output [ACE_CRRESP_WIDTH-1:0] ifu_ace_crresp,

  // CD channel signals
  output ifu_ace_cdvalid,
  input  ifu_ace_cdready,
  output [ACE_XDATA_WIDTH-1:0] ifu_ace_cddata,
  output ifu_ace_cdlast,

  // Additional signals
  output ifu_ace_rack,

  // From/To Program Counter Generator
  input logic [XLEN-1:0] next_pc_tdata,
  input logic next_pc_tvalid,
  output logic next_pc_tready,

  output logic [XLEN-1:0] current_pc_tdata,
  output logic current_pc_tvalid,
  input logic current_pc_tready,

  // To Decoder
  output logic [63:0] ifid_tdata_id,
  output logic [XLEN-1:0] ifid_tdata_pc,
  output logic [XLEN-1:0] ifid_tdata_untaken_pc,
  output logic [XLEN-1:0] ifid_tdata_inst,
  output logic inst_tvalid,
  input logic inst_tready,

  input logic invalidate
);

  ace_if #(.ACE_XDATA_WIDTH(ACE_XDATA_WIDTH)) ifu_ace_if ();

  axis_if #(.TDATA_WIDTH(XLEN)) next_pc_axis_if ();
  axis_if #(.TDATA_WIDTH(XLEN)) current_pc_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(ifid_tdata_t))) inst_axis_if ();

  ifid_tdata_t ifid_tdata;

  // AR channel signals
  assign ifu_ace_arid = ifu_ace_if.arid;
  assign ifu_ace_araddr = ifu_ace_if.araddr;
  assign ifu_ace_arlen = ifu_ace_if.arlen;
  assign ifu_ace_arsize = ifu_ace_if.arsize;
  assign ifu_ace_arburst = ifu_ace_if.arburst;
  assign ifu_ace_arlock = ifu_ace_if.arlock;
  assign ifu_ace_arcache = ifu_ace_if.arcache;
  assign ifu_ace_arprot = ifu_ace_if.arprot;
  assign ifu_ace_arqos = ifu_ace_if.arqos;
  assign ifu_ace_arregion = ifu_ace_if.arregion;
  assign ifu_ace_aruser = ifu_ace_if.aruser;
  assign ifu_ace_arvalid = ifu_ace_if.arvalid;
  assign ifu_ace_if.arready = ifu_ace_arready;
  assign ifu_ace_arsnoop = ifu_ace_if.arsnoop;
  assign ifu_ace_ardomain = ifu_ace_if.ardomain;
  assign ifu_ace_arbar = ifu_ace_if.arbar;

  // R channel signals
  assign ifu_ace_if.rid = ifu_ace_rid;
  assign ifu_ace_if.rdata = ifu_ace_rdata;
  assign ifu_ace_if.rresp = ifu_ace_rresp;
  assign ifu_ace_if.rlast = ifu_ace_rlast;
  assign ifu_ace_if.ruser = ifu_ace_ruser;
  assign ifu_ace_if.rvalid = ifu_ace_rvalid;
  assign ifu_ace_rready = ifu_ace_if.rready;

  // AC channel signals
  assign ifu_ace_if.acvalid = ifu_ace_acvalid;
  assign ifu_ace_acready = ifu_ace_if.acready;
  assign ifu_ace_if.acaddr = ifu_ace_acaddr;
  assign ifu_ace_if.acsnoop = ifu_ace_acsnoop;
  assign ifu_ace_if.acprot = ifu_ace_acprot;

  // CR channel signals
  assign ifu_ace_crvalid = ifu_ace_if.crvalid;
  assign ifu_ace_if.crready = ifu_ace_crready;
  assign ifu_ace_crresp = ifu_ace_if.crresp;

  // CD channel signals
  assign ifu_ace_cdvalid = ifu_ace_if.cdvalid;
  assign ifu_ace_if.cdready = ifu_ace_cdready;
  assign ifu_ace_cddata = ifu_ace_if.cddata;
  assign ifu_ace_cdlast = ifu_ace_if.cdlast;

  // Additional signals
  assign ifu_ace_rack = ifu_ace_if.rack;

  // From/To Program Counter Generator
  assign next_pc_axis_if.tdata = next_pc_tdata;
  assign next_pc_axis_if.tvalid = next_pc_tvalid;
  assign next_pc_tready = next_pc_axis_if.tready;

  assign current_pc_tdata = current_pc_axis_if.tdata;
  assign current_pc_tvalid = current_pc_axis_if.tvalid;
  assign current_pc_axis_if.tready = current_pc_tready;

  assign ifid_tdata = inst_axis_if.tdata;
  assign inst_tvalid = inst_axis_if.tvalid;
  assign inst_axis_if.tready = inst_tready;

  ifu ifu_inst (.*);

endmodule
