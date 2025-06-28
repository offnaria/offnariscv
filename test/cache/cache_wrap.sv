// SPDX-License-Identifier: MIT

module cache_wrap
  import cache_pkg::*;
# (
  localparam ADDR_WIDTH = 32
) (
  input logic clk,
  input logic rst,

  input logic [ADDR_WIDTH-1:0] if0_addr,
  input logic [$bits(line_state_t)-1:0] if0_next_state,
  input logic if0_write,
  output logic [$bits(line_state_t)-1:0] if0_current_state,
  output logic if0_hit,

  input logic [ADDR_WIDTH-1:0] if1_addr,
  input logic [$bits(line_state_t)-1:0] if1_next_state,
  input logic if1_write,
  output logic [$bits(line_state_t)-1:0] if1_current_state,
  output logic if1_hit
);

  cache_dir_if # (.ADDR_WIDTH(ADDR_WIDTH)) if0 ();
  cache_dir_if # (.ADDR_WIDTH(ADDR_WIDTH)) if1 ();

  always_comb begin
    // if0
    if0.addr = if0_addr;
    if0.next_state = if0_next_state;
    if0.write = if0_write;

    if0_current_state = if0.current_state;
    if0_hit = if0.hit;

    // if1
    if1.addr = if1_addr;
    if1.next_state = if1_next_state;
    if1.write = if1_write;

    if1_current_state = if1.current_state;
    if1_hit = if1.hit;
  end

  cache_directory # (
    .INDEX_WIDTH(7),
    .BLOCK_OFFSET(5)
  ) directory_inst (
    .clk(clk),
    .rst(rst),
    .cache_dir_rsp_if_0(if0),
    .cache_dir_rsp_if_1(if1)
  );

endmodule
