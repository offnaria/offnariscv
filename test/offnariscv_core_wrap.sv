// SPDX-License-Identifier: MIT

module offnariscv_core_wrap
  import offnariscv_pkg::*;
#(
    localparam ACE_XDATA_WIDTH  = 256,
    localparam ACE_AXADDR_WIDTH = 32
) (
    input clk,
    input rst,

    output [ACE_XID_WIDTH-1:0] core_ace_awid,
    output [ACE_AXADDR_WIDTH-1:0] core_ace_awaddr,
    output [ACE_AXLEN_WIDTH-1:0] core_ace_awlen,
    output [ACE_AXSIZE_WIDTH-1:0] core_ace_awsize,
    output [ACE_AXBURST_WIDTH-1:0] core_ace_awburst,
    output core_ace_awlock,
    output [ACE_AXCACHE_WIDTH-1:0] core_ace_awcache,
    output [ACE_AXPROT_WIDTH-1:0] core_ace_awprot,
    output [ACE_AXQOS_WIDTH-1:0] core_ace_awqos,
    output [ACE_AXREGION_WIDTH-1:0] core_ace_awregion,
    output [ACE_XUSER_WIDTH-1:0] core_ace_awuser,
    output core_ace_awvalid,
    input core_ace_awready,
    output [ACE_AWSNOOP_WIDTH-1:0] core_ace_awsnoop,
    output [ACE_DOMAIN_WIDTH-1:0] core_ace_awdomain,
    output [ACE_BAR_WIDTH-1:0] core_ace_awbar,
    output [ACE_XDATA_WIDTH-1:0] core_ace_wdata,
    output [ACE_XDATA_WIDTH/8-1:0] core_ace_wstrb,
    output core_ace_wlast,
    output [ACE_XUSER_WIDTH-1:0] core_ace_wuser,
    output core_ace_wvalid,
    input core_ace_wready,
    input [ACE_XID_WIDTH-1:0] core_ace_bid,
    input [ACE_BRESP_WIDTH-1:0] core_ace_bresp,
    input [ACE_XUSER_WIDTH-1:0] core_ace_buser,
    input core_ace_bvalid,
    output core_ace_bready,
    output [ACE_XID_WIDTH-1:0] core_ace_arid,
    output [ACE_AXADDR_WIDTH-1:0] core_ace_araddr,
    output [ACE_AXLEN_WIDTH-1:0] core_ace_arlen,
    output [ACE_AXSIZE_WIDTH-1:0] core_ace_arsize,
    output [ACE_AXBURST_WIDTH-1:0] core_ace_arburst,
    output core_ace_arlock,
    output [ACE_AXCACHE_WIDTH-1:0] core_ace_arcache,
    output [ACE_AXPROT_WIDTH-1:0] core_ace_arprot,
    output [ACE_AXQOS_WIDTH-1:0] core_ace_arqos,
    output [ACE_AXREGION_WIDTH-1:0] core_ace_arregion,
    output [ACE_XUSER_WIDTH-1:0] core_ace_aruser,
    output core_ace_arvalid,
    input core_ace_arready,
    output [ACE_ARSNOOP_WIDTH-1:0] core_ace_arsnoop,
    output [ACE_DOMAIN_WIDTH-1:0] core_ace_ardomain,
    output [ACE_BAR_WIDTH-1:0] core_ace_arbar,
    input [ACE_XID_WIDTH-1:0] core_ace_rid,
    input [ACE_XDATA_WIDTH-1:0] core_ace_rdata,
    input [ACE_RRESP_WIDTH-1:0] core_ace_rresp,
    input core_ace_rlast,
    input [ACE_XUSER_WIDTH-1:0] core_ace_ruser,
    input core_ace_rvalid,
    output core_ace_rready,
    input core_ace_acvalid,
    output core_ace_acready,
    input [ACE_AXADDR_WIDTH-1:0] core_ace_acaddr,
    input [ACE_ACSNOOP_WIDTH-1:0] core_ace_acsnoop,
    input [ACE_ACPROT_WIDTH-1:0] core_ace_acprot,
    output core_ace_crvalid,
    input core_ace_crready,
    output [ACE_CRRESP_WIDTH-1:0] core_ace_crresp,
    output core_ace_cdvalid,
    input core_ace_cdready,
    output [ACE_XDATA_WIDTH-1:0] core_ace_cddata,
    output core_ace_cdlast,
    output core_ace_rack,
    output core_ace_wack,

    output [XLEN-1:0] core_lsu_addr,
    output [XLEN-1:0] core_lsu_wdata,
    output core_lsu_store
);

  ace_if core_ace_if ();
  ace_if ifu_ace_if ();
  ace_if lsu_ace_if ();

  assign core_ace_awid = core_ace_if.awid;
  assign core_ace_awaddr = core_ace_if.awaddr;
  assign core_ace_awlen = core_ace_if.awlen;
  assign core_ace_awsize = core_ace_if.awsize;
  assign core_ace_awburst = core_ace_if.awburst;
  assign core_ace_awlock = core_ace_if.awlock;
  assign core_ace_awcache = core_ace_if.awcache;
  assign core_ace_awprot = core_ace_if.awprot;
  assign core_ace_awqos = core_ace_if.awqos;
  assign core_ace_awregion = core_ace_if.awregion;
  assign core_ace_awuser = core_ace_if.awuser;
  assign core_ace_awvalid = core_ace_if.awvalid;
  assign core_ace_if.awready = core_ace_awready;
  assign core_ace_awsnoop = core_ace_if.awsnoop;
  assign core_ace_awdomain = core_ace_if.awdomain;
  assign core_ace_awbar = core_ace_if.awbar;
  assign core_ace_wdata = core_ace_if.wdata;
  assign core_ace_wstrb = core_ace_if.wstrb;
  assign core_ace_wlast = core_ace_if.wlast;
  assign core_ace_wuser = core_ace_if.wuser;
  assign core_ace_wvalid = core_ace_if.wvalid;
  assign core_ace_if.wready = core_ace_wready;
  assign core_ace_if.bid = core_ace_bid;
  assign core_ace_if.bresp = core_ace_bresp;
  assign core_ace_if.buser = core_ace_buser;
  assign core_ace_if.bvalid = core_ace_bvalid;
  assign core_ace_bready = core_ace_if.bready;
  assign core_ace_arid = core_ace_if.arid;
  assign core_ace_araddr = core_ace_if.araddr;
  assign core_ace_arlen = core_ace_if.arlen;
  assign core_ace_arsize = core_ace_if.arsize;
  assign core_ace_arburst = core_ace_if.arburst;
  assign core_ace_arlock = core_ace_if.arlock;
  assign core_ace_arcache = core_ace_if.arcache;
  assign core_ace_arprot = core_ace_if.arprot;
  assign core_ace_arqos = core_ace_if.arqos;
  assign core_ace_arregion = core_ace_if.arregion;
  assign core_ace_aruser = core_ace_if.aruser;
  assign core_ace_arvalid = core_ace_if.arvalid;
  assign core_ace_if.arready = core_ace_arready;
  assign core_ace_arsnoop = core_ace_if.arsnoop;
  assign core_ace_ardomain = core_ace_if.ardomain;
  assign core_ace_arbar = core_ace_if.arbar;
  assign core_ace_if.rid = core_ace_rid;
  assign core_ace_if.rdata = core_ace_rdata;
  assign core_ace_if.rresp = core_ace_rresp;
  assign core_ace_if.rlast = core_ace_rlast;
  assign core_ace_if.ruser = core_ace_ruser;
  assign core_ace_if.rvalid = core_ace_rvalid;
  assign core_ace_rready = core_ace_if.rready;
  assign core_ace_if.acvalid = core_ace_acvalid;
  assign core_ace_acready = core_ace_if.acready;
  assign core_ace_if.acaddr = core_ace_acaddr;
  assign core_ace_if.acsnoop = core_ace_acsnoop;
  assign core_ace_if.acprot = core_ace_acprot;
  assign core_ace_crvalid = core_ace_if.crvalid;
  assign core_ace_if.crready = core_ace_crready;
  assign core_ace_crresp = core_ace_if.crresp;
  assign core_ace_cdvalid = core_ace_if.cdvalid;
  assign core_ace_if.cdready = core_ace_cdready;
  assign core_ace_cddata = core_ace_if.cddata;
  assign core_ace_cdlast = core_ace_if.cdlast;
  assign core_ace_rack = core_ace_if.rack;
  assign core_ace_wack = core_ace_if.wack;

  lsuwb_tdata_t lsuwb_tdata;
  assign lsuwb_tdata = offnariscv_core_inst.lsuwb_axis_if.tdata;
  assign core_lsu_addr = lsuwb_tdata.addr;
  assign core_lsu_wdata = lsuwb_tdata.wdata;
  assign core_lsu_store = lsuwb_tdata.store && offnariscv_core_inst.lsuwb_axis_if.tvalid;

  offnariscv_core #(
      .RESET_VECTOR(0)
  ) offnariscv_core_inst (
      .clk(clk),
      .rst(rst),
      .ifu_ace_if(ifu_ace_if),
      .lsu_ace_if(lsu_ace_if)
  );

  core_arbiter core_arbiter_inst (
      .clk(clk),
      .rst(rst),
      .ifu_ace_if(ifu_ace_if),
      .lsu_ace_if(lsu_ace_if),
      .core_ace_if(core_ace_if)
  );

  logic wbpcg_prev_ack;
  logic pcgif_prev_ack;
  logic ifid_prev_ack;
  logic idrf_prev_ack;
  logic rfex_prev_ack;
  logic exwb_prev_ack;
  logic wbrf_prev_ack;
  pcgif_tdata_t pcgif_prev_tdata;
  ifid_tdata_t ifid_prev_tdata;
  idrf_tdata_t idrf_prev_tdata;
  rfex_tdata_t rfex_prev_tdata;
  exwb_tdata_t exwb_prev_tdata;
  wbrf_tdata_t wbrf_prev_tdata;
  logic prev_invalidate;
  always_ff @(posedge clk) begin
    if (rst) begin
      wbpcg_prev_ack <= '0;
      pcgif_prev_ack <= '0;
      ifid_prev_ack <= '0;
      idrf_prev_ack <= '0;
      rfex_prev_ack <= '0;
      exwb_prev_ack <= '0;
      wbrf_prev_ack <= '0;
      pcgif_prev_tdata <= '0;
      pcgif_prev_tdata <= '0;
      ifid_prev_tdata <= '0;
      idrf_prev_tdata <= '0;
      rfex_prev_tdata <= '0;
      exwb_prev_tdata <= '0;
      wbrf_prev_tdata <= '0;
      prev_invalidate <= '0;
    end else begin
      wbpcg_prev_ack <= offnariscv_core_inst.wbpcg_axis_if.ack() || offnariscv_core_inst.pcgif_axis_if.ack();
      pcgif_prev_ack <= offnariscv_core_inst.pcgif_axis_if.ack();
      ifid_prev_ack <= offnariscv_core_inst.ifu_inst.ifid_pipe_reg_if.ack();
      idrf_prev_ack <= offnariscv_core_inst.decoder_inst.idrf_fifo_if.ack();
      rfex_prev_ack <= offnariscv_core_inst.regfile_inst.rfex_slice_if.ack();
      exwb_prev_ack <= offnariscv_core_inst.dispatcher_inst.exwb_slice_if.ack();
      wbrf_prev_ack <= offnariscv_core_inst.wbrf_axis_if.ack();
      pcgif_prev_tdata <= offnariscv_core_inst.pcgif_axis_if.tdata;
      ifid_prev_tdata <= offnariscv_core_inst.ifu_inst.ifid_pipe_reg_if.tdata;
      idrf_prev_tdata <= offnariscv_core_inst.decoder_inst.idrf_fifo_if.tdata;
      rfex_prev_tdata <= offnariscv_core_inst.regfile_inst.rfex_slice_if.tdata;
      exwb_prev_tdata <= offnariscv_core_inst.dispatcher_inst.exwb_slice_if.tdata;
      wbrf_prev_tdata <= offnariscv_core_inst.wbrf_axis_if.tdata;
      prev_invalidate <= offnariscv_core_inst.invalidate;
      $write("pcgif:\ttvalid=%0d, tready=%0d, ack=%0d, pc=%08h, id=%0d\n",
             offnariscv_core_inst.pcgif_axis_if.tvalid, offnariscv_core_inst.pcgif_axis_if.tready,
             offnariscv_core_inst.pcgif_axis_if.ack(),
             offnariscv_core_inst.pcgif_axis_if.tdata[127-:XLEN],
             offnariscv_core_inst.pcgif_axis_if.tdata[63:0]);
      $write("if1:\t\ttvalid=%0d, tready=%0d, ack=%0d, pc=%08h, id=%0d\n",
             offnariscv_core_inst.ifu_inst.pcgif_pipe_reg_if.tvalid,
             offnariscv_core_inst.ifu_inst.pcgif_pipe_reg_if.tready,
             offnariscv_core_inst.ifu_inst.pcgif_pipe_reg_if.ack(),
             offnariscv_core_inst.ifu_inst.pcgif_pipe_reg_if.tdata[127-:XLEN],
             offnariscv_core_inst.ifu_inst.pcgif_pipe_reg_if.tdata[63:0]);
      $write("ifid:\t\ttvalid=%0d, tready=%0d, ack=%0d, pc=%08h, id=%0d\n",
             offnariscv_core_inst.ifid_axis_if.tvalid, offnariscv_core_inst.ifid_axis_if.tready,
             offnariscv_core_inst.ifid_axis_if.ack(),
             offnariscv_core_inst.ifid_axis_if.tdata[127-:XLEN],
             offnariscv_core_inst.ifid_axis_if.tdata[63:0]);
      $write("idrf:\t\ttvalid=%0d, tready=%0d, ack=%0d, pc=%08h, id=%0d\n",
             offnariscv_core_inst.idrf_axis_if.tvalid, offnariscv_core_inst.idrf_axis_if.tready,
             offnariscv_core_inst.idrf_axis_if.ack(),
             offnariscv_core_inst.idrf_axis_if.tdata[127-:XLEN],
             offnariscv_core_inst.idrf_axis_if.tdata[63:0]);
      $write(
          "rfex:\t\ttvalid=%0d, tready=%0d, ack=%0d, pc=%08h, alu.op1=%016h, alu.op2=%016h, bru.op1=%016h, bru.op2=%016h, id=%0d\n",
          offnariscv_core_inst.rfex_axis_if.tvalid, offnariscv_core_inst.rfex_axis_if.tready,
          offnariscv_core_inst.rfex_axis_if.ack(),
          offnariscv_core_inst.rfex_axis_if.tdata[127-:XLEN],
          offnariscv_core_inst.rfalu_axis_if.tdata, offnariscv_core_inst.rfalu_axis_if.tdata,
          offnariscv_core_inst.rfbru_axis_if.tdata, offnariscv_core_inst.rfbru_axis_if.tdata,
          offnariscv_core_inst.rfex_axis_if.tdata[63:0]);
      $write("exwb:\t\ttvalid=%0d, tready=%0d, ack=%0d, pc=%08h, id=%0d\n",
             offnariscv_core_inst.exwb_axis_if.tvalid, offnariscv_core_inst.exwb_axis_if.tready,
             offnariscv_core_inst.exwb_axis_if.ack(),
             offnariscv_core_inst.exwb_axis_if.tdata[127-:XLEN],
             offnariscv_core_inst.exwb_axis_if.tdata[63:0]);
      if (0)
        $write(
            "wbrf:\t\ttvalid=%0d, tready=%0d, ack=%0d, pc=%08h, id=%0d\n",
            offnariscv_core_inst.wbrf_axis_if.tvalid,
            offnariscv_core_inst.wbrf_axis_if.tready,
            offnariscv_core_inst.wbrf_axis_if.ack(),
            offnariscv_core_inst.wbrf_axis_if.tdata[127-:XLEN],
            offnariscv_core_inst.wbrf_axis_if.tdata[63:0]
        );
      // for (int i = 0; i < 32; i++) begin
      //   $write("rf[%0d] = %08x\n", i, offnariscv_core_inst.regfile_inst.rf_mem[i]);
      // end
      if (offnariscv_core_inst.wbrf_axis_if.ack() || 1) begin
        wbrf_tdata_t tdata;
        assign tdata = offnariscv_core_inst.wbrf_axis_if.tdata;
        $write("wbrf:\t\tid=%0d, rd=%0d, wdata=%08x, pc=%08x, trap=%0d\n",
               tdata.ex_data.rf_data.id_data.if_data.pcg_data.id, tdata.ex_data.rf_data.id_data.rd,
               tdata.wdata, tdata.ex_data.rf_data.id_data.if_data.pcg_data.pc,
               offnariscv_core_inst.wbcsr_wif.trap);
        if (tdata.ex_data.rf_data.id_data.rd != 0)
          $write(
              "pc=%08x, rd=%0d, wdata=%08x\n",
              tdata.ex_data.rf_data.id_data.if_data.pcg_data.pc,
              tdata.ex_data.rf_data.id_data.rd,
              tdata.wdata
          );
        if (offnariscv_core_inst.wbcsr_wif.valid || offnariscv_core_inst.syswb_axis_if.tvalid)
          $write(
              "csr_addr=%08x, csr_rdata=%08x, csr_wdata=%08x, pc=%08x, cause=%0d\n",
              offnariscv_core_inst.wbcsr_wif.addr,
              tdata.ex_data.rf_data.csr_rdata,
              offnariscv_core_inst.wbcsr_wif.data,
              offnariscv_core_inst.wbcsr_wif.pc,
              offnariscv_core_inst.wbcsr_wif.cause
          );
        if (offnariscv_core_inst.wbcsr_wif.trap)
          $write("trap: %0d\n", offnariscv_core_inst.wbcsr_wif.cause);
      end
      if (offnariscv_core_inst.wbpcg_axis_if.ack()) begin
        $write("new_pc=%08x\n", offnariscv_core_inst.wbpcg_axis_if.tdata);
      end
      $write("\n");
    end
  end

  int ret_cnt = 0;
  export "DPI-C" task kanata_log_dut;
  task kanata_log_dut;
    output string log_file;
    string s0, s1, s2, s3, s4, s5, s6, s7;
    if (wbpcg_prev_ack) begin
      logic [INST_ID_WIDTH-1:0] id;
      logic [XLEN-1:0] pc;
      assign id = offnariscv_core_inst.pcgen_inst.inst_id_q;
      assign pc = offnariscv_core_inst.pcgen_inst.pc_q;
      $sformat(s0, "I\t%0d\t%0d\t0\nS\t%0d\t0\tPC\nL\t%0d\t0\t%08x\n", id, id, id, id, pc);
    end else $sformat(s0, "");
    if (pcgif_prev_ack) begin  // IDLE state
      $sformat(s1, "S\t%0d\t0\tIF\n", pcgif_prev_tdata.id);
    end else $sformat(s1, "");
    if (ifid_prev_ack) begin
      $sformat(s2, "S\t%0d\t0\tID\nL\t%0d\t0\t %08x\n", ifid_prev_tdata.pcg_data.id,
               ifid_prev_tdata.pcg_data.id, ifid_prev_tdata.inst);
    end else $sformat(s2, "");
    if (idrf_prev_ack) begin
      $sformat(s3, "S\t%0d\t0\tRF\n", idrf_prev_tdata.if_data.pcg_data.id);
    end else $sformat(s3, "");
    if (rfex_prev_ack) begin
      $sformat(s4, "S\t%0d\t0\tEX\n", rfex_prev_tdata.id_data.if_data.pcg_data.id);
    end else $sformat(s4, "");
    if (exwb_prev_ack) begin
      $sformat(s5, "S\t%0d\t0\tWB\n", exwb_prev_tdata.rf_data.id_data.if_data.pcg_data.id);
    end else $sformat(s5, "");
    if (wbrf_prev_ack) begin
      $sformat(s6, "R\t%0d\t%0d\t0\n", wbrf_prev_tdata.ex_data.rf_data.id_data.if_data.pcg_data.id,
               ret_cnt);
      ret_cnt++;
    end else $sformat(s6, "");
    if (prev_invalidate) begin
      pcgif_tdata_t tdata;
      assign tdata = offnariscv_core_inst.pcgif_axis_if.tdata;
      for (
          longint i = wbrf_prev_tdata.ex_data.rf_data.id_data.if_data.pcg_data.id + 1;
          i < tdata.id;
          ++i
      ) begin
        $sformat(s7, "%sR\t%0d\t-1\t1\n", s7, i);
      end
    end else $sformat(s7, "");
    $sformat(log_file, "%s%s%s%s%s%s%s%s", s0, s1, s2, s3, s4, s5, s6, s7);
  endtask

endmodule
