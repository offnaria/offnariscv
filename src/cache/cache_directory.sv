// SPDX-License-Identifier: MIT

// Dual-port cache directory
module cache_directory
  import cache_pkg::*;
#(
  parameter INDEX_WIDTH = 7, // 128 entries
  parameter BLOCK_OFFSET = 5 // 256 bits (32 bytes) per block
) (
  input logic clk,
  input logic rst,

  cache_dir_if.rsp cache_dir_rsp_if_0,
  cache_dir_if.rsp cache_dir_rsp_if_1
);

  // Define local parameters
  localparam ADDR_WIDTH = cache_dir_rsp_if_0.ADDR_WIDTH;
  localparam TAG_WIDTH = ADDR_WIDTH - INDEX_WIDTH - BLOCK_OFFSET; // TODO: Decrease the width if possible (e.g., if the cachable region is fixed to 0x80000000-0xFFFFFFFF)

  // Assert conditions
  initial begin
    assert (cache_dir_rsp_if_1.ADDR_WIDTH == ADDR_WIDTH) else $fatal("cache_dir_rsp_if_1.ADDR_WIDTH must match cache_dir_rsp_if_0.ADDR_WIDTH");
    assert (INDEX_WIDTH + BLOCK_OFFSET <= 12) else $fatal("Cache size must be less than 4 KiB for now");
    assert (INDEX_WIDTH > 0) else $fatal("INDEX_WIDTH must be greater than 0 for now"); // TODO: Support 1-entry cache
    assert (TAG_WIDTH >= 0) else $fatal("TAG_WIDTH must be greater than or equal to 0");
  end

  // Define types
  typedef struct packed {
    line_state_t state;
    logic [TAG_WIDTH-1:0] tag;
  } directory_t;

  // Declare memory array
  directory_t directory [2**INDEX_WIDTH];
  initial begin
    for (int i = 0; i < 2**INDEX_WIDTH; ++i) begin
      directory[i] = '0;
    end
  end

  // Declare wires
  logic [INDEX_WIDTH-1:0] if0_index;
  logic [INDEX_WIDTH-1:0] if1_index;
  logic [TAG_WIDTH-1:0] if0_tag;
  logic [TAG_WIDTH-1:0] if1_tag;

  always_comb begin
    // if0
    if0_index = cache_dir_rsp_if_0.addr[BLOCK_OFFSET +: INDEX_WIDTH];
    if0_tag = cache_dir_rsp_if_0.addr[ADDR_WIDTH-1 -: TAG_WIDTH];

    cache_dir_rsp_if_0.current_state = directory[if0_index].state;
    cache_dir_rsp_if_0.hit = (directory[if0_index].state.v && (directory[if0_index].tag == if0_tag));

    // if1
    if1_index = cache_dir_rsp_if_1.addr[BLOCK_OFFSET +: INDEX_WIDTH];
    if1_tag = cache_dir_rsp_if_1.addr[ADDR_WIDTH-1 -: TAG_WIDTH];

    cache_dir_rsp_if_1.current_state = directory[if1_index].state;
    cache_dir_rsp_if_1.hit = (directory[if1_index].state.v && (directory[if1_index].tag == if1_tag));
  end

  always_ff @(posedge clk) begin
    // For valid bit, reset is needed
    if (rst) begin
      for (int i = 0; i < 2**INDEX_WIDTH; ++i) begin
        directory[i].state.v <= '0;
      end
    end else begin
      if (cache_dir_rsp_if_0.write) directory[if0_index].state.v <= cache_dir_rsp_if_0.next_state.v;
      if (cache_dir_rsp_if_1.write) directory[if1_index].state.v <= cache_dir_rsp_if_1.next_state.v;
    end
  end

  always_ff @(posedge clk) begin
    // For other bits (expecting to be synthesized to dedicated RAM elements), don't reset
    if (cache_dir_rsp_if_0.write) begin
      directory[if0_index].state.d <= cache_dir_rsp_if_0.next_state.d;
      directory[if0_index].state.u <= cache_dir_rsp_if_0.next_state.u;
      directory[if0_index].tag <= if0_tag;
    end
    if (cache_dir_rsp_if_1.write) begin
      directory[if1_index].state.d <= cache_dir_rsp_if_1.next_state.d;
      directory[if1_index].state.u <= cache_dir_rsp_if_1.next_state.u;
      directory[if1_index].tag <= if1_tag;
    end
  end

endmodule
