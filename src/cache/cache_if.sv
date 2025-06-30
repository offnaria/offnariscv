// SPDX-License-Identifier: MIT

// Cache directory interface
interface cache_dir_if
  import cache_pkg::*;
# (
  parameter INDEX_WIDTH = 7,
  parameter TAG_WIDTH = 20
);
  logic [INDEX_WIDTH-1:0] index;
  logic [TAG_WIDTH-1:0] next_tag;
  line_state_t next_state;
  logic write;
  logic [TAG_WIDTH-1:0] current_tag;
  line_state_t current_state;

  // Request modport (controller side)
  modport req (output index, next_tag, next_state, write, input current_tag, current_state);

  // Response modport (directory side)
  modport rsp (input index, next_tag, next_state, write, output current_tag, current_state);

endinterface

// Cache memory interface
interface cache_mem_if
# (
  parameter BLOCK_SIZE = 256,
  parameter INDEX_WIDTH = 7,
  localparam STRB_WIDTH = BLOCK_SIZE / 8
);
  logic [INDEX_WIDTH-1:0] index;
  logic [BLOCK_SIZE-1:0] wdata;
  logic [STRB_WIDTH-1:0] wstrb;
  logic [BLOCK_SIZE-1:0] rdata;

  // Request modport (controller side)
  modport req (output index, wdata, wstrb, input rdata);

  // Response modport (memory side)
  modport rsp (input index, wdata, wstrb, output rdata);

endinterface
