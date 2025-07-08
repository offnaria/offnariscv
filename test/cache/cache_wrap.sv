// SPDX-License-Identifier: MIT

module cache_wrap
  import cache_pkg::*;
# (
  // localparam ADDR_WIDTH = 32,
  parameter INDEX_WIDTH = 7,
  parameter TAG_WIDTH = 20
) (
  input logic clk,
  input logic rst,

  input logic [INDEX_WIDTH-1:0] if0_index,
  input logic [TAG_WIDTH-1:0] if0_next_tag,
  input logic [$bits(line_state_t)-1:0] if0_next_state,
  input logic if0_write,
  output logic [TAG_WIDTH-1:0] if0_current_tag,
  output logic [$bits(line_state_t)-1:0] if0_current_state,

  input logic [INDEX_WIDTH-1:0] if1_index,
  input logic [TAG_WIDTH-1:0] if1_next_tag,
  input logic [$bits(line_state_t)-1:0] if1_next_state,
  input logic if1_write,
  output logic [TAG_WIDTH-1:0] if1_current_tag,
  output logic [$bits(line_state_t)-1:0] if1_current_state
);

  cache_dir_if # (.INDEX_WIDTH(INDEX_WIDTH), .TAG_WIDTH(TAG_WIDTH)) if0 ();
  cache_dir_if # (.INDEX_WIDTH(INDEX_WIDTH), .TAG_WIDTH(TAG_WIDTH)) if1 ();

  always_comb begin
    // if0
    if0.index = if0_index;
    if0.next_tag = if0_next_tag;
    if0.next_state = if0_next_state;
    if0.write = if0_write;
    if0_current_tag = if0.current_tag;
    if0_current_state = if0.current_state;

    // if1
    if1.index = if1_index;
    if1.next_tag = if1_next_tag;
    if1.next_state = if1_next_state;
    if1.write = if1_write;
    if1_current_tag = if1.current_tag;
    if1_current_state = if1.current_state;
  end

  cache_directory directory_inst (
    .clk(clk),
    .rst(rst),
    .cache_dir_rsp_if_0(if0),
    .cache_dir_rsp_if_1(if1),
    .flush('0) // TODO
  );

endmodule
