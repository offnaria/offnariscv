// SPDX-License-Identifier: MIT

interface cache_dir_if
  import cache_pkg::*;
# (
  parameter ADDR_WIDTH = 32
);
  logic [ADDR_WIDTH-1:0] addr;
  line_state_t current_state;
  logic hit;
  line_state_t next_state;
  logic write;

  // Request modport
  modport req (output addr, next_state, write, input current_state, hit);

  // Response modport
  modport rsp (input addr, next_state, write, output current_state, hit);

endinterface
