// SPDX-License-Identifier: MIT

// Cache with Shared and Invalid states
module cache_si #(
  parameter ENTRIES = 16, // Number of cache entries
  parameter WORD_SIZE = 32 // Word size
) (
  input logic clk,
  input logic rst_n,

  cache_if.r_rsp rif, // Read response interface
  cache_if.w_rsp wif // Write response interface
);

  /* Address structure 
  MSB                                                        LSB
  +---------------+---------------+--------------+-------------+
  |      Tag      |     Index     | Block Offset | Word Offset |
  +---------------+---------------+--------------+-------------+
  */

  // Define local parameters
  localparam ADDR_WIDTH = rif.ADDR_WIDTH;
  localparam BLOCK_SIZE = rif.BLOCK_SIZE;
  localparam WORD_OFFSET_WIDTH = $clog2(WORD_SIZE / 8);
  localparam BLOCK_OFFSET_WIDTH = $clog2(BLOCK_SIZE / WORD_SIZE);
  localparam INDEX_WIDTH = $clog2(ENTRIES);
  localparam TAG_WIDTH = ADDR_WIDTH - (INDEX_WIDTH + BLOCK_OFFSET_WIDTH + WORD_OFFSET_WIDTH);

  // Assert conditions
  initial begin
    assert (ENTRIES == 2**$clog2(ENTRIES)) else $fatal("ENTRIES must be a power of 2 for now");
    assert (WORD_SIZE == 32) else $fatal("WORD_SIZE must be 32 bits for now");
    assert ((BLOCK_SIZE > 0) && (BLOCK_SIZE % WORD_SIZE == 0)) else $fatal("BLOCK_SIZE must be a multiple of WORD_SIZE");
    assert (ADDR_WIDTH == wif.ADDR_WIDTH) else $fatal("ADDR_WIDTH mismatch between read and write interfaces");
    assert (BLOCK_SIZE == wif.BLOCK_SIZE) else $fatal("BLOCK_SIZE mismatch between read and write interfaces");
  end

  // Define types
  typedef struct packed {
    logic v;
  } state_t;  // v == 0: Invalid, 1: Shared

  typedef struct packed {
    state_t state; // State of the cache entry
    logic [TAG_WIDTH-1:0] tag; // Tag for the cache entry
  } directory_t;

  // Declare registers
  directory_t directory_q [ENTRIES]; // Cache directory
  logic [BLOCK_SIZE-1:0] data_q [ENTRIES]; // Cache data
  logic [BLOCK_SIZE-1:0] rif_data_q; // Read data register

  // Declare wires
  logic [TAG_WIDTH-1:0] rif_tag, wif_tag;
  logic [INDEX_WIDTH-1:0] rif_index, wif_index;

  // Wire assignments
  assign rif_tag = rif.addr[ADDR_WIDTH-1 -: TAG_WIDTH];
  assign wif_tag = wif.addr[ADDR_WIDTH-1 -: TAG_WIDTH];
  assign rif_index = rif.addr[BLOCK_OFFSET_WIDTH+WORD_OFFSET_WIDTH +: INDEX_WIDTH];
  assign wif_index = wif.addr[BLOCK_OFFSET_WIDTH+WORD_OFFSET_WIDTH +: INDEX_WIDTH];
  assign rif.hit = directory_q[rif_index].state.v && (directory_q[rif_index].tag == rif_tag);
  assign rif.data = rif_data_q;

  // Update directory
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i=0; i<ENTRIES; ++i) begin
        directory_q[i].state.v <= '0; // Initialize all entries to Invalid state
        directory_q[i].tag <= '0; // Initialize tags to zero (unnecessary but good practice)
      end
    end else begin
      if (|wif.we) begin
        directory_q[wif_index].state <= 1;
        directory_q[wif_index].tag <= wif_tag;
      end
    end
  end

  // Update and read data
  always_ff @(posedge clk) begin
    for (int i=0; i<BLOCK_SIZE/8; ++i) begin
      if (wif.we[i]) begin
        data_q[wif_index][i*8 +: 8] <= wif.data[i*8 +: 8];
      end
    end
    rif_data_q <= data_q[rif_index];
  end

endmodule
