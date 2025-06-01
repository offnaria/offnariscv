// SPDX-License-Identifier: MIT

// Cache interface
interface cache_if
# (
  parameter ADDR_WIDTH = 32, // Address width
  parameter BLOCK_SIZE = 128 // Block size
);
  logic [ADDR_WIDTH-1:0] addr;
  logic [BLOCK_SIZE-1:0] data;
  logic hit;
  logic [BLOCK_SIZE/8-1:0] we; // Byte write enable

  // Read request and response modports
  modport r_req (output addr, input data, hit);
  modport r_rsp (input addr, output data, hit);

  // Write request and response modports
  modport w_req (output addr, data, we);
  modport w_rsp (input addr, data, we);

endinterface;
