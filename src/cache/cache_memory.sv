// SPDX-License-Identifier: MIT

// Dual-port cache memory
module cache_memory
  import cache_pkg::*;
(
    input logic clk,
    input logic rst,

    cache_mem_if.rsp cache_mem_rsp_if_0,
    cache_mem_if.rsp cache_mem_rsp_if_1
);

  // Define local parameters
  localparam BLOCK_SIZE = cache_mem_rsp_if_0.BLOCK_SIZE;
  localparam INDEX_WIDTH = cache_mem_rsp_if_0.INDEX_WIDTH;
  localparam STRB_WIDTH = cache_mem_rsp_if_0.STRB_WIDTH;

  // Assert conditions
  initial begin
    assert (BLOCK_SIZE == cache_mem_rsp_if_1.BLOCK_SIZE)
    else $fatal("BLOCK_SIZE must match between interfaces");
    assert (INDEX_WIDTH == cache_mem_rsp_if_1.INDEX_WIDTH)
    else $fatal("INDEX_WIDTH must match between interfaces");
    assert (STRB_WIDTH == cache_mem_rsp_if_1.STRB_WIDTH)
    else $fatal("STRB_WIDTH must match between interfaces");
    assert (INDEX_WIDTH > 0)
    else $fatal("INDEX_WIDTH must be greater than 0 for now");  // TODO: Support 1 entry cache
    assert (STRB_WIDTH == BLOCK_SIZE / 8)
    else $fatal("STRB_WIDTH must be equal to BLOCK_SIZE / 8");
  end

  // Declare memory array
  logic [BLOCK_SIZE-1:0] memory[2**INDEX_WIDTH];
  initial begin
    for (int i = 0; i < 2 ** INDEX_WIDTH; ++i) begin
      memory[i] = '0;
    end
  end

  // Declare wires
  logic [INDEX_WIDTH-1:0] if0_index;
  logic [INDEX_WIDTH-1:0] if1_index;
  logic [ BLOCK_SIZE-1:0] if0_wdata;
  logic [ BLOCK_SIZE-1:0] if1_wdata;
  logic [ STRB_WIDTH-1:0] if0_wstrb;
  logic [ STRB_WIDTH-1:0] if1_wstrb;

  always_comb begin
    // if0
    if0_index = cache_mem_rsp_if_0.index;
    if0_wdata = cache_mem_rsp_if_0.wdata;
    if0_wstrb = cache_mem_rsp_if_0.wstrb;

    cache_mem_rsp_if_0.rdata = memory[if0_index];

    // if1
    if1_index = cache_mem_rsp_if_1.index;
    if1_wdata = cache_mem_rsp_if_1.wdata;
    if1_wstrb = cache_mem_rsp_if_1.wstrb;

    cache_mem_rsp_if_1.rdata = memory[if1_index];
  end

  always_ff @(posedge clk) begin
    for (int i = 0; i < STRB_WIDTH; ++i) begin
      if (if0_wstrb[i]) memory[if0_index][i*8+:8] <= if0_wdata[i*8+:8];
      if (if1_wstrb[i]) memory[if1_index][i*8+:8] <= if1_wdata[i*8+:8];
    end
  end

endmodule
