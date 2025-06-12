// SPDX-License-Identifier: MIT

module offnariscv_core
  import offnariscv_pkg::*;
(
  input clk,
  input rst,

  ace_if.m ifu_ace_if,
  ace_if.m lsu_ace_if
);

  ifu ifu_inst (
    .clk(clk),
    .rst(rst),
    .ifu_ace_if(ifu_ace_if)
  );

  lsu lsu_inst (
    .clk(clk),
    .rst(rst),
    .lsu_ace_if(lsu_ace_if)
  );

endmodule
