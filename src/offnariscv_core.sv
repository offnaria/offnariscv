// SPDX-License-Identifier: MIT

module offnariscv_core
  import offnariscv_pkg::*;
# (
  parameter RESET_VECTOR = 0
) (
  input clk,
  input rst,

  ace_if.m core_ace_if
);

  // Declare interfaces
  axis_if #(.TDATA_WIDTH(XLEN)) next_pc_axis_if ();
  axis_if #(.TDATA_WIDTH(XLEN)) current_pc_axis_if ();
  axis_if #(.TDATA_WIDTH(XLEN)) wbpcg_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(ifid_tdata_t))) ifid_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(idrf_tdata_t))) idrf_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(rfex_tdata_t))) rfex_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(rfalu_tdata_t))) rfalu_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(rfbru_tdata_t))) rfbru_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(rfsys_tdata_t))) rfsys_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(exwb_tdata_t))) exwb_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(aluwb_tdata_t))) aluwb_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(bruwb_tdata_t))) bruwb_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(syswb_tdata_t))) syswb_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(wbrf_tdata_t))) wbrf_axis_if ();

  logic invalidate;

  // Wire assignments
  assign invalidate = wbpcg_axis_if.ack();

  pcgen pcgen_inst (
    .clk(clk),
    .rst(rst),
    .next_pc_axis_if(next_pc_axis_if),
    .current_pc_axis_if(current_pc_axis_if),
    .bru_axis_if(wbpcg_axis_if)
  );

  ifu # (
    .RESET_VECTOR(RESET_VECTOR)
  ) ifu_inst (
    .clk(clk),
    .rst(rst),
    .ifu_ace_if(core_ace_if),
    .next_pc_axis_if(next_pc_axis_if),
    .current_pc_axis_if(current_pc_axis_if),
    .inst_axis_if(ifid_axis_if),
    .invalidate(invalidate)
  );

  decoder # (
    .FIFO_DEPTH(9)
  ) decoder_inst (
    .clk(clk),
    .rst(rst),
    .ifid_axis_if(ifid_axis_if),
    .idrf_axis_if(idrf_axis_if),
    .invalidate(invalidate)
  );

  regfile regfile_inst (
    .clk(clk),
    .rst(rst),
    .idrf_axis_if(idrf_axis_if),
    .rfex_axis_if(rfex_axis_if),
    .wbrf_axis_if(wbrf_axis_if),
    .invalidate(invalidate)
  );

  dispatcher dispatcher_inst (
    .clk(clk),
    .rst(rst),
    .rfex_axis_if(rfex_axis_if),
    .rfalu_axis_if(rfalu_axis_if),
    .rfbru_axis_if(rfbru_axis_if),
    .rfsys_axis_if(rfsys_axis_if),
    .exwb_axis_if(exwb_axis_if),
    .wbrf_axis_if(wbrf_axis_if), // For forwarding
    .invalidate(invalidate)
  );

  alu alu_inst (
    .clk(clk),
    .rst(rst),
    .rfalu_axis_if(rfalu_axis_if),
    .aluwb_axis_if(aluwb_axis_if),
    .invalidate(invalidate)
  );

  bru bru_inst (
    .clk(clk),
    .rst(rst),
    .rfbru_axis_if(rfbru_axis_if),
    .bruwb_axis_if(bruwb_axis_if),
    .invalidate(invalidate)
  );

  system sys_inst (
    .clk(clk),
    .rst(rst),
    .rfsys_axis_if(rfsys_axis_if),
    .syswb_axis_if(syswb_axis_if),
    .invalidate(invalidate)
  );

  committer committer_inst (
    .clk(clk),
    .rst(rst),
    .exwb_axis_if(exwb_axis_if),
    .aluwb_axis_if(aluwb_axis_if),
    .bruwb_axis_if(bruwb_axis_if),
    .syswb_axis_if(syswb_axis_if),
    .wbrf_axis_if(wbrf_axis_if),
    .wbpcg_axis_if(wbpcg_axis_if)
  );

  // lsu lsu_inst (
  //   .clk(clk),
  //   .rst(rst),
  //   .lsu_ace_if(lsu_ace_if)
  // );

endmodule
