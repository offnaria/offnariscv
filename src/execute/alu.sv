// SPDX-License-Identifier: MIT

// Arithmetic Logic Unit
module alu
  import offnariscv_pkg::*;
(
  input logic clk,
  input logic rst,

  axis_if.s rfalu_axis_if, // From Dispatcher
  axis_if.m aluwb_axis_if, // To Write Back

  input logic invalidate
);

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(aluwb_tdata_t))) aluwb_slice_if ();

  // Declare wires
  rfalu_tdata_t rfalu_tdata;
  aluwb_tdata_t aluwb_tdata;

  always_comb begin
    rfalu_tdata = rfalu_axis_if.tdata;

    aluwb_tdata.result = rfalu_tdata.operands.op1 + rfalu_tdata.operands.op2; // TODO

    // Slice connection
    aluwb_slice_if.tdata = aluwb_tdata;
    aluwb_slice_if.tvalid = rfalu_axis_if.tvalid;
    rfalu_axis_if.tready = aluwb_slice_if.tready;
  end

  // Instantiate slice
  axis_slice aluwb_slice (
    .clk(clk),
    .rst(rst),
    .axis_mif(aluwb_axis_if),
    .axis_sif(aluwb_slice_if),
    .invalidate(invalidate)
  );

endmodule
