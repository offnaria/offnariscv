// SPDX-License-Identifier: MIT

package offnariscv_pkg;
  localparam XLEN = 32;
  localparam ACE_ADDR_WIDTH = 32;
  localparam ACE_DATA_WIDTH = 32;
  localparam ACE_BRESP_WIDTH = 2;
  localparam ACE_RRESP_WIDTH = 4; // ACE_BRESP_WIDTH + 2 (IsShared, PassDirty)
  localparam ACE_ARSNOOP_WIDTH = 4;
  localparam ACE_AWSNOOP_WIDTH = 3;
  localparam ACE_DOMAIN_WIDTH = 2;
  localparam ACE_BAR_WIDTH = 4;
  localparam ACE_ACADDR_WIDTH = ACE_ADDR_WIDTH;
  localparam ACE_ACSNOOP_WIDTH = ACE_ARSNOOP_WIDTH;
  localparam ACE_ACPROT_WIDTH = 3;
  localparam ACE_CRRESP_WIDTH = 5;
  localparam ACE_CDDATA_WIDTH = ACE_DATA_WIDTH;

  typedef enum logic [1:0] {
    ACE_RESP_OKAY = 2'b00,
    ACE_RESP_EXOKAY = 2'b01,
    ACE_RESP_SLVERR = 2'b10,
    ACE_RESP_DECERR = 2'b11
  } ace_resp_e;
endpackage