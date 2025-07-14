// SPDX-License-Identifier: MIT

module offnariscv_core
  import offnariscv_pkg::*;
#(
    parameter RESET_VECTOR = 0
) (
    input clk,
    input rst,

    ace_if.m ifu_ace_if,
    ace_if.m lsu_ace_if
);

  localparam BLOCK_SIZE = ifu_ace_if.ACE_XDATA_WIDTH;
  localparam INDEX_WIDTH = 12 - $clog2(BLOCK_SIZE / 8);
  localparam TAG_WIDTH = ifu_ace_if.ACE_AXADDR_WIDTH - INDEX_WIDTH - $clog2(BLOCK_SIZE / 8);

  // Assert conditions
  initial begin
    assert (BLOCK_SIZE == lsu_ace_if.ACE_XDATA_WIDTH)
    else $fatal("BLOCK_SIZE must match lsu_ace_if.ACE_XDATA_WIDTH for now");
  end

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(pcgif_tdata_t))) pcgif_axis_if ();
  axis_if #(.TDATA_WIDTH(XLEN)) wbpcg_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(ifid_tdata_t))) ifid_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(idrf_tdata_t))) idrf_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(rfex_tdata_t))) rfex_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(rfalu_tdata_t))) rfalu_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(rfbru_tdata_t))) rfbru_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(rfsys_tdata_t))) rfsys_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(rflsu_tdata_t))) rflsu_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(exwb_tdata_t))) exwb_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(aluwb_tdata_t))) aluwb_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(bruwb_tdata_t))) bruwb_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(syswb_tdata_t))) syswb_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(lsuwb_tdata_t))) lsuwb_axis_if ();
  axis_if #(.TDATA_WIDTH($bits(wbrf_tdata_t))) wbrf_axis_if ();

  csr_rif rfcsr_rif ();
  csr_wif wbcsr_wif ();

  cache_dir_if #(
      .INDEX_WIDTH(INDEX_WIDTH),
      .TAG_WIDTH  (TAG_WIDTH)
  ) l1i_dir_if_0 ();
  cache_dir_if #(
      .INDEX_WIDTH(INDEX_WIDTH),
      .TAG_WIDTH  (TAG_WIDTH)
  ) l1i_dir_if_1 ();
  cache_mem_if #(
      .BLOCK_SIZE (BLOCK_SIZE),
      .INDEX_WIDTH(INDEX_WIDTH)
  ) l1i_mem_if_0 ();
  cache_mem_if #(
      .BLOCK_SIZE (BLOCK_SIZE),
      .INDEX_WIDTH(INDEX_WIDTH)
  ) l1i_mem_if_1 ();

  logic invalidate;
  logic flush;

  // Wire assignments
  assign invalidate = wbpcg_axis_if.ack();
  assign flush = wbpcg_axis_if.tvalid && committer_inst.exwb_tdata.rf_data.id_data.fence_i;

  pcgen pcgen_inst (
      .clk(clk),
      .rst(rst),
      .pcgif_axis_if(pcgif_axis_if),
      .wbpcg_axis_if(wbpcg_axis_if)
  );

  ifu #(
      .RESET_VECTOR(RESET_VECTOR)
  ) ifu_inst (
      .clk(clk),
      .rst(rst),
      .ifu_ace_if(ifu_ace_if),
      .pcgif_axis_if(pcgif_axis_if),
      .inst_axis_if(ifid_axis_if),
      .l1i_dir_if(l1i_dir_if_0),
      .l1i_mem_if(l1i_mem_if_0),
      .invalidate(invalidate)
  );

  cache_directory l1i_dir_inst (
      .clk(clk),
      .rst(rst),
      .cache_dir_rsp_if_0(l1i_dir_if_0),
      .cache_dir_rsp_if_1(l1i_dir_if_1),
      .flush(flush)  // TODO
  );

  cache_memory l1i_mem_inst (
      .clk(clk),
      .rst(rst),
      .cache_mem_rsp_if_0(l1i_mem_if_0),
      .cache_mem_rsp_if_1(l1i_mem_if_1)
  );

  decoder #(
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
      .rfcsr_rif(rfcsr_rif),
      .invalidate(invalidate)
  );

  csr csr_inst (
      .clk(clk),
      .rst(rst),
      .csr_rif_rsp(rfcsr_rif),
      .csr_wif_rsp(wbcsr_wif)
  );

  dispatcher dispatcher_inst (
      .clk(clk),
      .rst(rst),
      .rfex_axis_if(rfex_axis_if),
      .rfalu_axis_if(rfalu_axis_if),
      .rfbru_axis_if(rfbru_axis_if),
      .rfsys_axis_if(rfsys_axis_if),
      .rflsu_axis_if(rflsu_axis_if),
      .exwb_axis_if(exwb_axis_if),
      .wbrf_axis_if(wbrf_axis_if),  // For forwarding
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
      .lsuwb_axis_if(lsuwb_axis_if),
      .wbrf_axis_if(wbrf_axis_if),
      .wbpcg_axis_if(wbpcg_axis_if),
      .wbcsr_wif(wbcsr_wif)
  );

  lsu lsu_inst (
      .clk(clk),
      .rst(rst),
      .lsu_ace_if(lsu_ace_if),
      .rflsu_axis_if(rflsu_axis_if),
      .lsuwb_axis_if(lsuwb_axis_if),
      .invalidate(invalidate)
  );

endmodule
