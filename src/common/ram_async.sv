// SPDX-License-Identifier: MIT

// RAM with synchronous write and asynchronous read
module ram_async # (
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8
) (
  input logic clk,
  input logic rst_n, // Unused
  
  input logic [DATA_WIDTH-1:0] wdata,
  input logic [ADDR_WIDTH-1:0] waddr,
  input logic wvalid,

  output logic [DATA_WIDTH-1:0] rdata,
  input logic [ADDR_WIDTH-1:0] raddr
);

  // Memory array
  logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];

  // Memory initialization
  initial begin
    for (int i = 0; i < 2**ADDR_WIDTH; ++i) begin
      mem[i] = '0;
    end
  end

  // Asynchronous read
  assign rdata = mem[raddr];

  always_ff @(posedge clk) begin
    if (wvalid) begin
      mem[waddr] <= wdata; // Synchronous write
    end
  end

endmodule