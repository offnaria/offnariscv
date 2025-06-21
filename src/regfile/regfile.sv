// SPDX-License-Identifier: MIT

// Register file
module regfile
  import offnariscv_pkg::*;
(
  input logic clk,
  input logic rst,

  axis_if.s idrf_axis_if, // From Decoder
  axis_if.m rfex_axis_if, // To Execution Units

  axis_if.s wbrf_axis_if, // From Write Back

  input logic invalidate
);

  // Declare parameters
  parameter RF_DEPTH = 32;

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(rfex_tdata_t))) rfex_slice_if ();

  // Declare memory array
  logic [XLEN-1:0] rf_mem [0:RF_DEPTH-1];

  initial begin
    for (int i = 0; i < RF_DEPTH; i++) begin
      rf_mem[i] = '0;
    end
  end

  // Declare wires
  idrf_tdata_t idrf_tdata;
  rfex_tdata_t rfex_tdata;
  wbrf_tdata_t wbrf_tdata;
  logic [XLEN-1:0] rs1_data, rs2_data;

  always_comb begin
    idrf_tdata = idrf_axis_if.tdata;
    wbrf_tdata = wbrf_axis_if.tdata;

    rs1_data = (idrf_tdata.fwd_rs1.rf && wbrf_axis_if.tvalid) ? wbrf_tdata.wdata : rf_mem[idrf_tdata.rs1];
    rs2_data = (idrf_tdata.fwd_rs2.rf && wbrf_axis_if.tvalid) ? wbrf_tdata.wdata : rf_mem[idrf_tdata.rs2];

    rfex_tdata.operands.op1 = rs1_data | idrf_tdata.auipc; // Assuming rs1 and auipc are exclusive
    rfex_tdata.operands.op2 = rs2_data | idrf_tdata.immediate; // Assuming rs2 and immediate are exclusive
    rfex_tdata.rs2_data = rs2_data; // For store

    rfex_tdata.id_data = idrf_tdata;

    // Slice connection
    rfex_slice_if.tdata = rfex_tdata;
    rfex_slice_if.tvalid = idrf_axis_if.tvalid;
    idrf_axis_if.tready = rfex_slice_if.tready;

    // Write Back
    wbrf_axis_if.tready = 1'b1;
  end

  always_ff @(posedge clk) begin
    if (!rst) begin
      if (wbrf_axis_if.tvalid && wbrf_axis_if.tready && (wbrf_tdata.ex_data.rf_data.id_data.rd != 0) /* && !invalidate */) begin // Is `invalidate` useful?
        rf_mem[wbrf_tdata.ex_data.rf_data.id_data.rd] <= wbrf_tdata.wdata;
      end
    end
  end

  axis_slice rfex_slice (
    .clk(clk),
    .rst(rst),
    .axis_mif(rfex_axis_if),
    .axis_sif(rfex_slice_if),
    .invalidate(invalidate)
  );

endmodule
