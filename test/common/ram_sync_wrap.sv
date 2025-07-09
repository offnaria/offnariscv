// SPDX-License-Identifier: MIT

module ram_sync_wrap # (
  localparam DATA_WIDTH = 32,
  localparam ADDR_WIDTH = 8,
  localparam OUTPUT_REG = 0
) (
  input logic clk,
  input logic rst,
  
  input logic [DATA_WIDTH-1:0] wdata,
  input logic [ADDR_WIDTH-1:0] waddr,
  input logic wvalid,
  input logic [DATA_WIDTH/8-1:0] wstrb,

  output logic [DATA_WIDTH-1:0] rdata,
  input logic [ADDR_WIDTH-1:0] raddr,
  input logic rvalid,
  input logic oreg_cen
);

  ram_sync #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .OUTPUT_REG(OUTPUT_REG)
  ) ram_sync_inst (
    .*
  );

endmodule
