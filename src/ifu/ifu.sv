// SPDX-License-Identifier: MIT

// Instruction Fetch Unit
module ifu
  import offnariscv_pkg::*, cache_pkg::*;
#(
    parameter RESET_VECTOR = 0,
    parameter CACHE_SIZE   = 4096  // 4 KiB
) (
    input clk,
    input rst,

    // To lower level memory
    ace_if.m ifu_ace_if,

    // From Program Counter Generator
    axis_if.s pcgif_axis_if,

    // To Decoder
    axis_if.m inst_axis_if,

    // To L1 I-Cache
    cache_dir_if.req l1i_dir_if,
    cache_mem_if.req l1i_mem_if,

    input logic invalidate
);

  // Define local parameters
  localparam ADDR_WIDTH = ifu_ace_if.ACE_AXADDR_WIDTH;
  localparam BLOCK_SIZE = ifu_ace_if.ACE_XDATA_WIDTH;
  localparam BLOCK_OFFSET_WIDTH = $clog2(BLOCK_SIZE / 8);
  localparam BLOCK_SEL_WIDTH = $clog2(BLOCK_SIZE / XLEN);
  localparam INDEX_WIDTH = l1i_dir_if.INDEX_WIDTH;
  localparam TAG_WIDTH = l1i_dir_if.TAG_WIDTH;

  // Assert conditions
  initial begin
    assert (ADDR_WIDTH == XLEN)
    else $fatal("ifu_ace_if.ADDR_WIDTH must be equal to XLEN for now");
    assert (inst_axis_if.TDATA_WIDTH == $bits(ifid_tdata_t))
    else $fatal("inst_axis_if.TDATA_WIDTH must match ifid_tdata_t");
    assert (TAG_WIDTH + INDEX_WIDTH + BLOCK_OFFSET_WIDTH == ADDR_WIDTH)
    else $fatal("TAG_WIDTH + INDEX_WIDTH + BLOCK_OFFSET_WIDTH must equal ADDR_WIDTH");
    assert (l1i_mem_if.BLOCK_SIZE == BLOCK_SIZE)
    else $fatal("l1i_mem_if.BLOCK_SIZE must match BLOCK_SIZE");
    assert (l1i_mem_if.INDEX_WIDTH == INDEX_WIDTH)
    else $fatal("l1i_mem_if.INDEX_WIDTH must match INDEX_WIDTH");
  end

  // Define types
  typedef enum logic [1:0] {
    IDLE,
    PTW,
    LOAD,
    WAIT
  } state_e;

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(pcgif_tdata_t))) pcgif_pipe_reg_if ();
  axis_if #(.TDATA_WIDTH($bits(ifid_tdata_t))) ifid_pipe_reg_if ();

  // Declare registers and their next states
  state_e state_q, state_d;
  logic arvalid_q, arvalid_d;
  logic rready_q, rready_d;
  logic [BLOCK_SIZE-1:0] rdata_q, rdata_d;
  logic [$bits(ifu_ace_if.rresp)-1:0] rresp_q, rresp_d;
  logic l1ic_hit_q, l1ic_hit_d;
  logic invalidate_q, invalidate_d;

  logic [INDEX_WIDTH-1:0] l1ic_dir_index_q, l1ic_dir_index_d;
  logic [INDEX_WIDTH-1:0] l1ic_mem_index_q, l1ic_mem_index_d;

  // Declare wires
  pcgif_tdata_t pcgif_tdata;
  pcgif_tdata_t pcgif_pipe_tdata;
  logic pcgif_ack;
  logic l1itlb_hit;
  logic [TAG_WIDTH-1:0] tag;
  logic [((BLOCK_SEL_WIDTH>0)?BLOCK_SEL_WIDTH : 1)-1:0] block_sel;

  ifid_tdata_t ifid_tdata;

  // Wire assignments
  assign pcgif_tdata = pcgif_axis_if.tdata;
  assign pcgif_pipe_tdata = pcgif_pipe_reg_if.tdata;
  assign pcgif_ack = pcgif_axis_if.tvalid && pcgif_axis_if.tready;
  assign l1itlb_hit = 1'b1;  // TODO

  assign l1i_dir_if.index = l1ic_dir_index_q;
  assign l1i_mem_if.index = l1ic_mem_index_q;

  // State machine logic
  always_comb begin
    state_d = state_q;
    arvalid_d = arvalid_q;
    rready_d = rready_q;
    l1ic_hit_d = l1ic_hit_q;
    rdata_d = rdata_q;
    rresp_d = rresp_q;
    invalidate_d = invalidate_q;

    pcgif_pipe_reg_if.tready = '0;
    ifid_pipe_reg_if.tvalid = '0;

    tag = pcgif_pipe_tdata.pc[ADDR_WIDTH-1 -: TAG_WIDTH]; // TODO: The tag will be obtained from TLB when implemented
    block_sel = (BLOCK_SEL_WIDTH==0) ? '0 : pcgif_pipe_tdata.pc[BLOCK_OFFSET_WIDTH-1 -: BLOCK_SEL_WIDTH];

    ifid_tdata.inst = l1i_mem_if.rdata[block_sel*XLEN+:XLEN];
    ifid_tdata.trap_cause = '0;  // TODO
    ifid_tdata.pcg_data = pcgif_pipe_tdata;

    l1i_dir_if.next_tag = tag;
    l1i_dir_if.next_state = '{default: '0, v: 1'b1};
    l1i_dir_if.write = '0;

    l1i_mem_if.wstrb = '0;

    unique case (state_q)
      IDLE: begin
        if (pcgif_pipe_reg_if.tvalid && !invalidate) begin
          if (l1itlb_hit) begin
            if (l1i_dir_if.current_state.v && (l1i_dir_if.current_tag == tag)) begin
              l1ic_hit_d = 1'b1;
              ifid_pipe_reg_if.tvalid = 1'b1;
              if (ifid_pipe_reg_if.tready) begin
                pcgif_pipe_reg_if.tready = 1'b1;
              end
            end else begin
              l1ic_hit_d = 1'b0;
              arvalid_d = 1'b1;
              rready_d = 1'b1;
              state_d = LOAD;
            end
          end else begin
            state_d = PTW;
          end
        end
      end
      PTW: begin
        // TODO
      end
      LOAD: begin
        if (ifu_ace_if.arready) begin
          arvalid_d = '0;
        end
        if (ifu_ace_if.rvalid) begin
          rready_d = '0;
          rresp_d  = ifu_ace_if.rresp;
          rdata_d  = ifu_ace_if.rdata;
        end
        if (!rready_d) begin
          ifid_tdata.inst = rdata_d[block_sel*XLEN+:XLEN];
          if (!invalidate_q) begin
            ifid_pipe_reg_if.tvalid = 1'b1;
            l1i_dir_if.write = 1'b1;  // TODO: Update the cache with appropriate index
            l1i_mem_if.wstrb = '1;
          end
          if (ifid_pipe_reg_if.tready) begin
            if (!invalidate_q) begin
              pcgif_pipe_reg_if.tready = 1'b1;
            end
            state_d = IDLE;
          end
        end
      end
      WAIT: begin
      end
      default: begin
      end
    endcase

    ifid_pipe_reg_if.tdata = ifid_tdata;

    l1i_mem_if.wdata = rdata_d;

    if (invalidate && (state_q != IDLE)) begin
      if (!ifid_pipe_reg_if.tvalid) begin
        invalidate_d = 1'b1;
      end
    end

    if (invalidate_q && !rready_d) begin
      invalidate_d = '0;
    end
  end

  // Update registers
  always_ff @(posedge clk) begin
    if (rst) begin
      state_q <= IDLE;
      arvalid_q <= '0;
      rready_q <= '0;
      rdata_q <= '0;
      rresp_q <= '0;
      l1ic_hit_q <= '0;
      invalidate_q <= '0;
    end else begin
      state_q <= state_d;
      arvalid_q <= arvalid_d;
      rready_q <= rready_d;
      rdata_q <= rdata_d;
      rresp_q <= rresp_d;
      l1ic_hit_q <= l1ic_hit_d;
      invalidate_q <= invalidate_d;
    end
  end

  always_ff @(posedge clk) begin  // Expecting to be synthesized to dedicated RAM elements
    if (pcgif_ack) begin
      l1ic_dir_index_q <= pcgif_tdata.pc[BLOCK_OFFSET_WIDTH+:INDEX_WIDTH];
      l1ic_mem_index_q <= pcgif_tdata.pc[BLOCK_OFFSET_WIDTH+:INDEX_WIDTH];
    end
  end

  axis_slice pcgif_slice (
      .clk(clk),
      .rst(rst),
      .axis_mif(pcgif_pipe_reg_if),
      .axis_sif(pcgif_axis_if),
      .invalidate(invalidate)
  );

  axis_skid_buffer ifid_pipe_reg (
      .clk(clk),
      .rst(rst),
      .axis_mif(inst_axis_if),
      .axis_sif(ifid_pipe_reg_if),
      .invalidate(invalidate)
  );

  // External wire assignments
  //// AW channel signals
  assign ifu_ace_if.awvalid = 1'b0;  // Don't activate AW channel
  assign {ifu_ace_if.awid,
          ifu_ace_if.awaddr,
          ifu_ace_if.awlen,
          ifu_ace_if.awsize,
          ifu_ace_if.awburst,
          ifu_ace_if.awlock,
          ifu_ace_if.awcache,
          ifu_ace_if.awprot,
          ifu_ace_if.awqos,
          ifu_ace_if.awregion,
          ifu_ace_if.awuser,
          ifu_ace_if.awsnoop,
          ifu_ace_if.awdomain,
          ifu_ace_if.awbar} = '0; // Unused

  //// W channel signals
  assign ifu_ace_if.wvalid = '0;  // Don't activate W channel
  assign {ifu_ace_if.wdata, ifu_ace_if.wstrb, ifu_ace_if.wlast, ifu_ace_if.wuser} = '0;  // Unused

  //// B channel signals
  assign ifu_ace_if.bready = '0;  // Don't allow B channel

  //// AR channel signals
  assign ifu_ace_if.arid = '0;  // TODO
  assign ifu_ace_if.araddr = pcgif_pipe_tdata.pc;
  assign ifu_ace_if.arlen = '0;  // TODO
  assign ifu_ace_if.arsize = '0;  // TODO
  assign ifu_ace_if.arburst = '0;  // TODO
  assign ifu_ace_if.arlock = '0;  // TODO
  assign ifu_ace_if.arcache = '0;  // TODO
  assign ifu_ace_if.arprot = '0;  // TODO
  assign ifu_ace_if.arqos = '0;  // TODO
  assign ifu_ace_if.arregion = '0;  // TODO
  assign ifu_ace_if.aruser = '0;  // TODO
  assign ifu_ace_if.arvalid = arvalid_q;
  assign ifu_ace_if.arsnoop = '0;  // TODO
  assign ifu_ace_if.ardomain = '0;  // TODO
  assign ifu_ace_if.arbar = '0;  // TODO

  //// R channel signals
  assign ifu_ace_if.rready = rready_q;

  //// AC channel signals
  assign ifu_ace_if.acready = '0;  // TODO

  //// CR channel signals
  assign ifu_ace_if.crvalid = '0;  // TODO
  assign ifu_ace_if.crresp = '0;  // TODO

  //// CD channel signals
  assign ifu_ace_if.cdvalid = '0;  // TODO
  assign ifu_ace_if.cddata = '0;  // TODO
  assign ifu_ace_if.cdlast = '0;  // TODO

  //// Acknowledgment signals
  assign ifu_ace_if.rack = rready_q && ifu_ace_if.rvalid; // NOTE: This might have to be delayed until the cache state is successfully updated
  assign ifu_ace_if.wack = '0;  // Unused

endmodule
