// SPDX-License-Identifier: MIT

`ifndef OFFNARISCV_PKG
`define OFFNARISCV_PKG

package offnariscv_pkg;
  localparam XLEN = 32;

  localparam ACE_XID_WIDTH = 1;
  localparam ACE_AXLEN_WIDTH = 8;
  localparam ACE_AXSIZE_WIDTH = 3;
  localparam ACE_AXBURST_WIDTH = 2;
  localparam ACE_AXCACHE_WIDTH = 4;
  localparam ACE_AXPROT_WIDTH = 3;
  localparam ACE_AXQOS_WIDTH = 4;
  localparam ACE_AXREGION_WIDTH = 4;
  localparam ACE_XUSER_WIDTH = 1;
  localparam ACE_BRESP_WIDTH = 2;
  localparam ACE_RRESP_WIDTH = 4; // ACE_BRESP_WIDTH + 2 (IsShared, PassDirty)
  localparam ACE_ARSNOOP_WIDTH = 4;
  localparam ACE_AWSNOOP_WIDTH = 3;
  localparam ACE_DOMAIN_WIDTH = 2;
  localparam ACE_BAR_WIDTH = 4;
  localparam ACE_ACSNOOP_WIDTH = ACE_ARSNOOP_WIDTH;
  localparam ACE_ACPROT_WIDTH = ACE_AXPROT_WIDTH;
  localparam ACE_CRRESP_WIDTH = 5;

  typedef enum logic [ACE_BRESP_WIDTH-1:0] {
    ACE_RESP_OKAY = 2'b00,
    ACE_RESP_EXOKAY = 2'b01,
    ACE_RESP_SLVERR = 2'b10,
    ACE_RESP_DECERR = 2'b11
  } ace_resp_e;
endpackage

`endif
