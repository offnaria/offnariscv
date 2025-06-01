// SPDX-License-Identifier: MIT

module cache_si_wrap
  import offnariscv_pkg::*;
# (
  localparam ENTRIES = 16,
  localparam ADDR_WIDTH = 32,
  localparam BLOCK_SIZE = 128
) (
  input logic clk,
  input logic rst_n,

  input logic [ADDR_WIDTH-1:0] rif_addr,
  output logic [BLOCK_SIZE-1:0] rif_data,
  output logic rif_hit,

  input logic [ADDR_WIDTH-1:0] wif_addr,
  input logic [BLOCK_SIZE-1:0] wif_data,
  input logic [BLOCK_SIZE/8-1:0] wif_we
);

  cache_if # (.ADDR_WIDTH(ADDR_WIDTH), .BLOCK_SIZE(BLOCK_SIZE)) rif ();
  cache_if # (.ADDR_WIDTH(ADDR_WIDTH), .BLOCK_SIZE(BLOCK_SIZE)) wif ();

  assign rif.addr = rif_addr;
  assign rif_data = rif.data;
  assign rif_hit = rif.hit;

  assign wif.addr = wif_addr;
  assign wif.data = wif_data;
  assign wif.we = wif_we;

  cache_si # (
    .ENTRIES(ENTRIES),
    .WORD_SIZE(32)
  ) cache_si_inst (
    .clk(clk),
    .rst_n(rst_n),
    .rif(rif),
    .wif(wif)
  );

endmodule
