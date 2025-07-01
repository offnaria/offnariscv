// SPDX-License-Identifier: MIT

// Instruction Dispatcher
module dispatcher
  import offnariscv_pkg::*;
# (
  parameter FIFO_DEPTH = 1
) (
  input logic clk,
  input logic rst,

  axis_if.s rfex_axis_if, // From Register File
  axis_if.m rfalu_axis_if, // To ALU
  axis_if.m rfbru_axis_if, // To Branch Resolution Unit
  axis_if.m rfsys_axis_if, // To System Unit
  axis_if.m exwb_axis_if, // To Write Back

  axis_if.s wbrf_axis_if, // For forwarding

  input logic invalidate
);

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(exwb_tdata_t))) exwb_slice_if ();

  // Declare wires
  rfex_tdata_t rfex_tdata;
  rfalu_tdata_t rfalu_tdata;
  rfbru_tdata_t rfbru_tdata;
  rfsys_tdata_t rfsys_tdata;
  exwb_tdata_t exwb_tdata;
  wbrf_tdata_t wbrf_tdata;

  logic [XLEN-1:0] fwd_data;

  always_comb begin
    rfex_tdata = rfex_axis_if.tdata;
    rfex_axis_if.tready = exwb_slice_if.tready;
    exwb_slice_if.tvalid = rfex_axis_if.tvalid;

    wbrf_tdata = wbrf_axis_if.tdata;
    fwd_data = wbrf_tdata.wdata;

    // ALU
    rfalu_tdata.operands.op1 = (rfex_tdata.id_data.fwd_rs1.ex) ? fwd_data : rfex_tdata.operands.op1;
    rfalu_tdata.operands.op2 = (rfex_tdata.id_data.fwd_rs2.ex) ? fwd_data : rfex_tdata.operands.op2;
    rfalu_tdata.cmd = rfex_tdata.id_data.alu_cmd;
    rfalu_axis_if.tdata = rfalu_tdata;
    rfalu_axis_if.tvalid = exwb_slice_if.tvalid && rfex_tdata.id_data.alu_cmd_vld && rfex_axis_if.tready;

    // BRU
    rfbru_tdata.operands.op1 = (rfex_tdata.id_data.fwd_rs1.ex) ? fwd_data : rfex_tdata.operands.op1;
    rfbru_tdata.operands.op2 = (rfex_tdata.id_data.fwd_rs2.ex) ? fwd_data : rfex_tdata.operands.op2;
    rfbru_tdata.offset = rfex_tdata.id_data.immediate;
    rfbru_tdata.this_pc = rfex_tdata.id_data.if_data.pcg_data.pc;
    rfbru_tdata.cmd = rfex_tdata.id_data.bru_cmd;
    rfbru_axis_if.tdata = rfbru_tdata;
    rfbru_axis_if.tvalid = exwb_slice_if.tvalid && rfex_tdata.id_data.bru_cmd_vld && rfex_axis_if.tready;

    // System
    rfsys_tdata.operands.op1 = (rfex_tdata.id_data.fwd_rs1.ex) ? fwd_data : rfex_tdata.operands.op1;
    rfsys_tdata.operands.op2 = (rfex_tdata.id_data.fwd_rs2.ex) ? fwd_data : rfex_tdata.operands.op2;
    rfsys_tdata.csr_rdata = rfex_tdata.csr_rdata;
    rfsys_tdata.cmd = rfex_tdata.id_data.sys_cmd;
    rfsys_tdata.trap_cause = rfex_tdata.id_data.if_data.trap_cause;
    rfsys_tdata.this_pc = rfex_tdata.id_data.if_data.pcg_data.pc;
    rfsys_tdata.mtvec = rfex_tdata.mtvec;
    rfsys_tdata.mepc = rfex_tdata.mepc;
    rfsys_axis_if.tdata = rfsys_tdata;
    rfsys_axis_if.tvalid = exwb_slice_if.tvalid && rfex_tdata.id_data.sys_cmd_vld && rfex_axis_if.tready;

    exwb_tdata.rf_data = rfex_tdata;
    exwb_slice_if.tdata = exwb_tdata;
  end

  axis_sync_fifo # (
    .DEPTH(FIFO_DEPTH)
  ) exwb_fifo (
    .clk(clk),
    .rst(rst),
    .axis_mif(exwb_axis_if),
    .axis_sif(exwb_slice_if),
    .invalidate(invalidate)
  );

endmodule
