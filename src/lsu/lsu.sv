// SPDX-License-Identifier: MIT

module lsu
  import offnariscv_pkg::*;
(
    input clk,
    input rst,

    // To lower level memory
    ace_if.m lsu_ace_if,

    axis_if.s rflsu_axis_if,  // From Dispatcher
    axis_if.m lsuwb_axis_if,  // To Write Back

    // To L1 D-Cache
    cache_dir_if.req l1d_dir_if,
    cache_mem_if.req l1d_mem_if,

    input logic invalidate
);

  // Define local parameters
  localparam ADDR_WIDTH = lsu_ace_if.ACE_AXADDR_WIDTH;
  localparam BLOCK_SIZE = lsu_ace_if.ACE_XDATA_WIDTH;
  localparam BLOCK_OFFSET_WIDTH = $clog2(BLOCK_SIZE / 8);
  localparam BLOCK_SEL_WIDTH = $clog2(BLOCK_SIZE / XLEN);

  // Assert conditions
  initial begin
    assert (ADDR_WIDTH == XLEN)
    else $fatal("lsu_ace_if.ADDR_WIDTH must be equal to XLEN for now");
  end

  // Define types
  typedef enum logic [2:0] {
    IDLE,
    PTW,
    LOAD,
    STORE,
    WAIT
  } state_e;  // TODO: There might be more states for AMO in the future

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(rflsu_tdata_t))) rflsu_slice_if ();
  axis_if #(.TDATA_WIDTH($bits(lsuwb_tdata_t))) lsuwb_slice_if ();

  // Declare registers and their next states
  state_e state_q, state_d;
  logic arvalid_q, arvalid_d;
  logic rready_q, rready_d;
  logic [BLOCK_SIZE-1:0] rdata_q, rdata_d;
  logic [$bits(lsu_ace_if.rresp)-1:0] rresp_q, rresp_d;
  logic awvalid_q, awvalid_d;
  logic wvalid_q, wvalid_d;
  logic [BLOCK_SIZE-1:0] wdata_q, wdata_d;
  logic [BLOCK_SIZE/8-1:0] wstrb_q, wstrb_d;
  logic bready_q, bready_d;
  logic [$bits(lsu_ace_if.bresp)-1:0] bresp_q, bresp_d;
  logic [ADDR_WIDTH-1:0] addr_q, addr_d;

  // Declare wires
  logic rflsu_ack;
  rflsu_tdata_t rflsu_if_tdata, rflsu_slice_tdata;
  lsuwb_tdata_t lsuwb_tdata;
  logic [XLEN-1:0] effective_addr;
  logic l1dtlb_hit;
  logic l1dc_hit;
  // logic [TAG_WIDTH-1:0] tag;
  logic [((BLOCK_SEL_WIDTH>0)?BLOCK_SEL_WIDTH : 1)-1:0] block_sel;

  assign rflsu_ack = rflsu_axis_if.tvalid && rflsu_axis_if.tready;

  always_comb begin
    state_d = state_q;
    arvalid_d = arvalid_q;
    rready_d = rready_q;
    awvalid_d = awvalid_q;
    rdata_d = rdata_q;
    rresp_d = rresp_q;
    wvalid_d = wvalid_q;
    wdata_d = wdata_q;
    wstrb_d = wstrb_q;
    bready_d = bready_q;
    bresp_d = bresp_q;
    addr_d = addr_q;

    rflsu_if_tdata = rflsu_axis_if.tdata;
    rflsu_slice_tdata = rflsu_slice_if.tdata;
    lsuwb_tdata = '0;

    lsuwb_slice_if.tvalid = '0;
    rflsu_slice_if.tready = '0;

    effective_addr = rflsu_if_tdata.operands.op1 + rflsu_if_tdata.offset;
    l1dtlb_hit = 1'b1;  // TODO
    l1dc_hit = 1'b0;  // TODO

    if (rflsu_ack) begin
      addr_d = effective_addr;
    end

    block_sel = addr_q[BLOCK_OFFSET_WIDTH-1-:BLOCK_SEL_WIDTH];

    unique case (state_q)
      IDLE: begin
        if (rflsu_slice_if.tvalid && !invalidate) begin
          if (l1dtlb_hit) begin
            if (l1dc_hit) begin
              lsuwb_slice_if.tvalid = 1'b1;
              if (lsuwb_slice_if.tready) begin
                rflsu_slice_if.tready = 1'b1;
              end
            end else begin
              if (rflsu_slice_tdata.cmd inside {LSU_LW, LSU_LH, LSU_LB, LSU_LHU, LSU_LBU}) begin
                arvalid_d = 1'b1;
                rready_d  = 1'b1;
                state_d   = LOAD;
              end
              if (rflsu_slice_tdata.cmd inside {LSU_SW, LSU_SH, LSU_SB}) begin
                awvalid_d = 1'b1;
                wvalid_d  = 1'b1;
                unique case (rflsu_slice_tdata.cmd)
                  LSU_SW: wdata_d = {(BLOCK_SIZE / 32) {rflsu_slice_tdata.operands.op2}};
                  LSU_SH: wdata_d = {(BLOCK_SIZE / 16) {rflsu_slice_tdata.operands.op2[15:0]}};
                  LSU_SB: wdata_d = {(BLOCK_SIZE / 8) {rflsu_slice_tdata.operands.op2[7:0]}};
                  default: begin
                  end
                endcase
                wstrb_d = '0;
                for (int i = 0; i < BLOCK_SIZE / 8; ++i) begin
                  unique case (rflsu_slice_tdata.cmd)
                    LSU_SW: if (block_sel == BLOCK_SEL_WIDTH'(i / 4)) wstrb_d[i] = 1'b1;
                    LSU_SH:
                    if (addr_q[BLOCK_OFFSET_WIDTH-1:1] == (BLOCK_OFFSET_WIDTH - 1)'(i / 2))
                      wstrb_d[i] = 1'b1;
                    LSU_SB:
                    if (addr_q[BLOCK_OFFSET_WIDTH-1:0] == BLOCK_OFFSET_WIDTH'(i)) wstrb_d[i] = 1'b1;
                    default: begin
                    end
                  endcase
                end
                bready_d = 1'b1;
                state_d  = STORE;
              end
              // TODO: AMO
            end
          end
        end
      end
      PTW: begin
        // TODO
      end
      LOAD: begin
        if (lsu_ace_if.arready) begin
          arvalid_d = '0;
        end
        if (lsu_ace_if.rvalid) begin
          rready_d = '0;
          rresp_d  = lsu_ace_if.rresp;
          rdata_d  = lsu_ace_if.rdata;
        end
        if (!rready_d) begin
          unique case (rflsu_slice_tdata.cmd)
            LSU_LW: lsuwb_tdata.result = rdata_d[block_sel*XLEN+:XLEN];
            LSU_LH:
            lsuwb_tdata.result = XLEN'(signed'(rdata_d[16*addr_q[BLOCK_OFFSET_WIDTH-1:1]+:16]));
            LSU_LHU:
            lsuwb_tdata.result = XLEN'(unsigned'(rdata_d[16*addr_q[BLOCK_OFFSET_WIDTH-1:1]+:16]));
            LSU_LB:
            lsuwb_tdata.result = XLEN'(signed'(rdata_d[8*addr_q[BLOCK_OFFSET_WIDTH-1:0]+:8]));
            LSU_LBU:
            lsuwb_tdata.result = XLEN'(unsigned'(rdata_d[8*addr_q[BLOCK_OFFSET_WIDTH-1:0]+:8]));
            default: begin
            end
          endcase
          lsuwb_slice_if.tvalid = 1'b1;
          if (lsuwb_slice_if.tready) begin
            rflsu_slice_if.tready = 1'b1;
            state_d = IDLE;
          end
        end
      end
      STORE: begin
        if (lsu_ace_if.awready) begin
          awvalid_d = '0;
        end
        if (lsu_ace_if.wready) begin
          wvalid_d = '0;
        end
        if (lsu_ace_if.bvalid) begin
          bready_d = '0;
          bresp_d  = lsu_ace_if.bresp;
        end
        if (!bready_d) begin
          lsuwb_slice_if.tvalid = 1'b1;
          if (lsuwb_slice_if.tready) begin
            rflsu_slice_if.tready = 1'b1;
            state_d = IDLE;
          end
        end
      end
      default: begin
      end
    endcase

    lsuwb_slice_if.tdata = lsuwb_tdata;

  end

  always_ff @(posedge clk) begin
    if (rst) begin
      state_q <= IDLE;
      arvalid_q <= 0;
      rready_q <= 0;
      rdata_q <= '0;
      rresp_q <= '0;
      awvalid_q <= 0;
      wvalid_q <= 0;
      wdata_q <= '0;
      wstrb_q <= '0;
      bready_q <= 0;
      bresp_q <= '0;
      addr_q <= '0;
    end else begin
      state_q <= state_d;
      arvalid_q <= arvalid_d;
      rready_q <= rready_d;
      rdata_q <= rdata_d;
      rresp_q <= rresp_d;
      awvalid_q <= awvalid_d;
      wvalid_q <= wvalid_d;
      wdata_q <= wdata_d;
      wstrb_q <= wstrb_d;
      bready_q <= bready_d;
      bresp_q <= bresp_d;
      addr_q <= addr_d;
      $write(
          "LSU: state=%s, arvalid=%b, rready=%b, awvalid=%b, wvalid=%b, wdata=0x%h, wstrb=0x%h, bready=%b, bresp=0x%h, addr=0x%h\n",
          state_q.name(), arvalid_q, rready_q, awvalid_q, wvalid_q, wdata_q, wstrb_q, bready_q,
          bresp_q, addr_q);
    end
  end

  axis_slice rflsu_slice_inst (
      .clk(clk),
      .rst(rst),
      .axis_mif(rflsu_slice_if),
      .axis_sif(rflsu_axis_if),
      .invalidate(invalidate)
  );

  axis_slice lsuwb_slice_inst (
      .clk(clk),
      .rst(rst),
      .axis_mif(lsuwb_axis_if),
      .axis_sif(lsuwb_slice_if),
      .invalidate(invalidate)
  );

  // External wire assignments
  //// AW channel signals
  assign lsu_ace_if.awvalid = awvalid_q;
  assign lsu_ace_if.awid = '0;  // TODO
  assign lsu_ace_if.awaddr = addr_q;
  assign lsu_ace_if.awlen = '0;  // TODO
  assign lsu_ace_if.awsize = '0;  // TODO
  assign lsu_ace_if.awburst = '0;  // TODO
  assign lsu_ace_if.awlock = '0;  // TODO
  assign lsu_ace_if.awcache = '0;  // TODO
  assign lsu_ace_if.awprot = '0;  // TODO
  assign lsu_ace_if.awqos = '0;  // TODO
  assign lsu_ace_if.awregion = '0;  // TODO
  assign lsu_ace_if.awuser = '0;  // TODO
  assign lsu_ace_if.awsnoop = '0;  // TODO
  assign lsu_ace_if.awdomain = '0;  // TODO
  assign lsu_ace_if.awbar = '0;  // TODO

  //// W channel signals
  assign lsu_ace_if.wvalid = wvalid_q;
  assign lsu_ace_if.wdata = wdata_q;
  assign lsu_ace_if.wstrb = wstrb_q;
  assign lsu_ace_if.wlast = 1'b1;  // TODO
  assign lsu_ace_if.wuser = '0;  // TODO

  //// B channel signals
  assign lsu_ace_if.bready = bready_q;

  //// AR channel signals
  assign lsu_ace_if.arid = '0;  // TODO
  assign lsu_ace_if.araddr = addr_q;
  assign lsu_ace_if.arlen = '0;  // TODO
  assign lsu_ace_if.arsize = '0;  // TODO
  assign lsu_ace_if.arburst = '0;  // TODO
  assign lsu_ace_if.arlock = '0;  // TODO
  assign lsu_ace_if.arcache = '0;  // TODO
  assign lsu_ace_if.arprot = '0;  // TODO
  assign lsu_ace_if.arqos = '0;  // TODO
  assign lsu_ace_if.arregion = '0;  // TODO
  assign lsu_ace_if.aruser = '0;  // TODO
  assign lsu_ace_if.arvalid = arvalid_q;
  assign lsu_ace_if.arsnoop = '0;  // TODO
  assign lsu_ace_if.ardomain = '0;  // TODO
  assign lsu_ace_if.arbar = '0;  // TODO

  //// R channel signals
  assign lsu_ace_if.rready = rready_q;

  //// AC channel signals
  assign lsu_ace_if.acready = '0;  // TODO

  //// CR channel signals
  assign lsu_ace_if.crvalid = '0;  // TODO
  assign lsu_ace_if.crresp = '0;  // TODO

  //// CD channel signals
  assign lsu_ace_if.cdvalid = '0;  // TODO
  assign lsu_ace_if.cddata = '0;  // TODO
  assign lsu_ace_if.cdlast = '0;  // TODO

  //// Acknowledgment signals
  assign lsu_ace_if.rack = '0;  // TODO
  assign lsu_ace_if.wack = '0;  // TODO

endmodule
