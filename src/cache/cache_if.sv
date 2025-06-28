// SPDX-License-Identifier: MIT

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
