// SPDX-License-Identifier: MIT

// RAM with synchronous write and read
module ram_sync # (
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8,
  parameter OUTPUT_REG = 0 // 0: no output register, 1: output register
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
  input logic oreg_cen // Output register clock enable (only used if OUTPUT_REG == 1)
);

  // Assert conditions
  initial begin
    assert (DATA_WIDTH > 0) else $fatal("DATA_WIDTH must be greater than 0");
    assert (DATA_WIDTH % 8 == 0) else $fatal("DATA_WIDTH must be a multiple of 8");
    assert (ADDR_WIDTH > 0) else $fatal("ADDR_WIDTH must be greater than 0");
    assert (OUTPUT_REG == 0 || OUTPUT_REG == 1) else $fatal("OUTPUT_REG must be 0 or 1");
  end

  // Memory array
  logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];

  // Memory initialization
  initial begin
    for (int i = 0; i < 2**ADDR_WIDTH; ++i) begin
      mem[i] = '0;
    end
  end

  generate
    if (OUTPUT_REG == 0) begin
      always_ff @(posedge clk) begin
        if (wvalid) begin
          for (int i = 0; i < DATA_WIDTH/8; ++i) begin
            if (wstrb[i]) begin
              mem[waddr][i*8 +: 8] <= wdata[i*8 +: 8]; // Synchronous write with byte enable
            end
          end
        end
        if (rvalid) begin
          rdata <= mem[raddr]; // Synchronous read
        end
      end
    end else begin
      // Memory output register
      logic [DATA_WIDTH-1:0] rdata_reg;

      always_ff @(posedge clk) begin
        if (rst) begin
          rdata_reg <= '0;
        end else if (oreg_cen) begin
          rdata <= rdata_reg; // Registered output
        end
        if (wvalid) begin
          for (int i = 0; i < DATA_WIDTH/8; ++i) begin
            if (wstrb[i]) begin
              mem[waddr][i*8 +: 8] <= wdata[i*8 +: 8]; // Synchronous write with byte enable
            end
          end
        end
        if (rvalid) begin
          rdata_reg <= mem[raddr]; // Synchronous read
        end
      end
    end
  endgenerate

endmodule
