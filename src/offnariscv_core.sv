// SPDX-License-Identifier: MIT

module offnariscv_core
  import offnariscv_pkg::*;
#(
  parameters
) (
  input clk,
  input rst_n,

  ace_if.m ifu_if,
  ace_if.m lsu_if
);

  ifu ifu_inst (
    .clk(clk),
    .rst_n(rst_n),
    .ifu_if(ifu_if)
  );

  lsu lsu_inst (
    .clk(clk),
    .rst_n(rst_n),
    .lsu_if(lsu_if)
  );

endmodule
