// SPDX-License-Identifier: MIT

module offnariscv_core
  import offnariscv_pkg::*;
(
  input clk,
  input rst_n,

  ace_if.m ifu_ace_if,
  ace_if.m lsu_ace_if
);

  ifu ifu_inst (
    .clk(clk),
    .rst_n(rst_n),
    .ifu_ace_if(ifu_ace_if)
  );

  lsu lsu_inst (
    .clk(clk),
    .rst_n(rst_n),
    .lsu_ace_if(lsu_ace_if)
  );

endmodule
