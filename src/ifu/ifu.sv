// SPDX-License-Identifier: MIT

// Instruction Fetch Unit
module ifu
  import offnariscv_pkg::*, cache_pkg::*;
# (
  parameter RESET_VECTOR = 0,
  parameter CACHE_SIZE = 4096 // 4 KiB
) (
  input clk,
  input rst,

  // To lower level memory
  ace_if.m ifu_ace_if,

  // From/To Program Counter Generator
  axis_if.s pcgif_axis_if,
  axis_if.m current_pc_axis_if,

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
    assert (ADDR_WIDTH == XLEN) else $fatal("ifu_ace_if.ADDR_WIDTH must be equal to XLEN for now");
    assert (pcgif_axis_if.TDATA_WIDTH == XLEN) else $fatal("pcgif_axis_if.TDATA_WIDTH must be equal to XLEN");
    assert (current_pc_axis_if.TDATA_WIDTH == XLEN) else $fatal("current_pc_axis_if.TDATA_WIDTH must be equal to XLEN");
    assert (inst_axis_if.TDATA_WIDTH == $bits(ifid_tdata_t)) else $fatal("inst_axis_if.TDATA_WIDTH must match ifid_tdata_t");
    assert (TAG_WIDTH + INDEX_WIDTH + $clog2(BLOCK_SIZE) == ADDR_WIDTH) else $fatal("TAG_WIDTH + INDEX_WIDTH + $clog2(BLOCK_SIZE) must equal ADDR_WIDTH");
    assert (l1i_mem_if.BLOCK_SIZE == BLOCK_SIZE) else $fatal("l1i_mem_if.BLOCK_SIZE must match BLOCK_SIZE");
    assert (l1i_mem_if.INDEX_WIDTH == INDEX_WIDTH) else $fatal("l1i_mem_if.INDEX_WIDTH must match INDEX_WIDTH");
  end

  // Define types
  typedef enum logic [1:0] {
    IDLE,
    PTW,
    LOAD,
    WAIT
  } state_e;

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(ifid_tdata_t))) ifid_pipe_reg_if ();

  // Declare registers and their next states
  logic [XLEN-1:0] pc_q, pc_d;
  state_e state_q, state_d;
  logic arvalid_q, arvalid_d;
  logic rready_q, rready_d;
  logic [BLOCK_SIZE-1:0] block_q, block_d;
  logic [ACE_RRESP_WIDTH-1:0] rresp_q, rresp_d;

  logic [TAG_WIDTH-1:0] l1i_current_tag_q;
  line_state_t l1i_current_state_q;
  logic [BLOCK_SIZE-1:0] l1i_rdata_q, l1i_rdata_pipe_q;
  logic l1i_hit_q, l1i_hit_d;

`ifndef SYNTHESIS
  logic [INST_ID_WIDTH-1:0] inst_id_q, inst_id_d;
`endif

  // Declare wires
  logic [((BLOCK_SEL_WIDTH>0)?BLOCK_SEL_WIDTH-1:0):0] block_offset;
  ifid_tdata_t ifid_tdata;
  logic icache_hit;
  logic itlb_hit;

  // Wire assignments
  assign pc_d = (pcgif_axis_if.tvalid && pcgif_axis_if.tready) ? pcgif_axis_if.tdata : pc_q;

  assign pcgif_axis_if.tready = (state_d == IDLE);
  assign current_pc_axis_if.tdata = pc_q;
  assign current_pc_axis_if.tvalid = 1'b1;

  assign ifid_tdata.pc = pc_q;
  assign ifid_tdata.untaken_pc = '0; // TODO
  assign ifid_tdata.inst = (l1i_hit_q) ? l1i_rdata_pipe_q[block_offset*XLEN +: XLEN] : block_d[block_offset*XLEN +: XLEN];
  assign ifid_pipe_reg_if.tdata = ifid_tdata;

  assign block_offset = (BLOCK_SEL_WIDTH>0) ? pc_q[$clog2(XLEN/8)+BLOCK_SEL_WIDTH-32'(BLOCK_SEL_WIDTH>0):$clog2(XLEN/8)] : '0;
  assign icache_hit = l1i_current_state_q.v && (l1i_current_tag_q == pc_q[ADDR_WIDTH-1 -: TAG_WIDTH]);
  assign itlb_hit = 1'b1; // TODO

  assign l1i_dir_if.index = pc_d[BLOCK_OFFSET_WIDTH +: INDEX_WIDTH];
  assign l1i_dir_if.next_tag = pc_q[ADDR_WIDTH-1 -: TAG_WIDTH]; // TODO: Set physical tag when TLB is implemented
  assign l1i_dir_if.next_state = '{default: '0, v: 1'b1}; // SharedClean

  assign l1i_mem_if.index = pc_d[BLOCK_OFFSET_WIDTH +: INDEX_WIDTH];
  assign l1i_mem_if.wdata = block_d;

`ifndef SYNTHESIS
  assign ifid_tdata.id = inst_id_q;
  assign inst_id_d = (ifid_pipe_reg_if.tvalid && ifid_pipe_reg_if.tready) ? inst_id_q + INST_ID_WIDTH'(1) : inst_id_q;
`endif

  // State machine logic
  always_comb begin
    state_d = state_q;
    arvalid_d = arvalid_q;
    rready_d = rready_q;
    block_d = block_q;
    rresp_d = rresp_q;
    l1i_hit_d = l1i_hit_q;

    ifid_pipe_reg_if.tvalid = 1'b0;

    l1i_dir_if.write = 1'b0;
    l1i_mem_if.wstrb = '0;

    case (state_q) // NOTE: This FSM works regardless of pcgif_axis_if.tvalid
      IDLE: begin
        if (itlb_hit) begin
          if (icache_hit) begin
            ifid_pipe_reg_if.tvalid = 1'b1;
            l1i_hit_d = 1'b1;
            if (ifid_pipe_reg_if.tready) begin
              state_d = IDLE;
            end else begin
              state_d = WAIT;
            end
          end else begin
            l1i_hit_d = '0;
            arvalid_d = 1'b1;
            rready_d = 1'b1;
            state_d = LOAD;
          end
        end else begin
          state_d = PTW;
        end
      end
      PTW: begin
        // TODO
      end
      LOAD: begin
        if (ifu_ace_if.arready) begin
          arvalid_d = 1'b0;
        end
        if (ifu_ace_if.rvalid) begin
          rready_d = 1'b0;
          block_d = ifu_ace_if.rdata;
          rresp_d = ifu_ace_if.rresp;
        end
        if (!rready_d) begin // rvalid must be asserted after arready
          ifid_pipe_reg_if.tvalid = 1'b1;
          l1i_dir_if.write = 1'b1;
          l1i_mem_if.wstrb = '1; // All bits are 1
          if (ifid_pipe_reg_if.tready) begin
            state_d = IDLE;
          end else begin
            state_d = WAIT;
          end
        end
      end
      WAIT: begin
        ifid_pipe_reg_if.tvalid = 1'b1;
        if (ifid_pipe_reg_if.tready) begin
          state_d = IDLE;
        end
      end
      default: begin
      end
    endcase
  end

  // Update registers
  always_ff @(posedge clk) begin
    if (rst) begin
      pc_q <= XLEN'(RESET_VECTOR);
      state_q <= LOAD; // Start in LOAD state to fetch the first instruction
      arvalid_q <= 1'b1; // NOTE
      rready_q <= 1'b1; // NOTE
      block_q <= '0;
      rresp_q <= '0;
      l1i_hit_q <= '0;
`ifndef SYNTHESIS
      inst_id_q <= '0;
`endif
    end else begin
      pc_q <= pc_d;
      state_q <= state_d;
      arvalid_q <= arvalid_d;
      rready_q <= rready_d;
      block_q <= block_d;
      rresp_q <= rresp_d;
      l1i_hit_q <= l1i_hit_d;
`ifndef SYNTHESIS
      inst_id_q <= inst_id_d;
`endif
      $write("pc_q=%08h, pc_q.tag=%05h, l1i_current_tag_q=%05h, pc_q.index=%02h, l1i_dir_if.index=%02h, state_q=%s, icache_hit=%b\n", pc_q, pc_q[ADDR_WIDTH-1 -: TAG_WIDTH], l1i_current_tag_q, pc_q[BLOCK_OFFSET_WIDTH +: INDEX_WIDTH], l1i_dir_if.index, state_q.name(), icache_hit);
    end
  end

  always_ff @(posedge clk) begin // Expecting to be synthesized to dedicated RAM elements
    if (pcgif_axis_if.tvalid && pcgif_axis_if.tready) begin
      l1i_current_tag_q <= (l1i_dir_if.write && (l1i_dir_if.index == pc_q[BLOCK_OFFSET_WIDTH +: INDEX_WIDTH])) ? l1i_dir_if.next_tag : l1i_dir_if.current_tag;
      l1i_current_state_q <= (l1i_dir_if.write && (l1i_dir_if.index == pc_q[BLOCK_OFFSET_WIDTH +: INDEX_WIDTH])) ? l1i_dir_if.next_state : l1i_dir_if.current_state;
      l1i_rdata_q <= (l1i_dir_if.write && (l1i_mem_if.index == pc_q[BLOCK_OFFSET_WIDTH +: INDEX_WIDTH])) ? l1i_mem_if.wdata : l1i_mem_if.rdata;
    end
    l1i_rdata_pipe_q <= l1i_rdata_q;
  end

  axis_skid_buffer ifid_pipe_reg (
    .clk(clk),
    .rst(rst),
    .axis_mif(inst_axis_if),
    .axis_sif(ifid_pipe_reg_if),
    .invalidate(invalidate)
  );

  // External wire assignments
  //// AW channel signals
  assign ifu_ace_if.awvalid = 1'b0; // Don't activate AW channel
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
  assign ifu_ace_if.wvalid = '0; // Don't activate W channel
  assign {ifu_ace_if.wdata,
          ifu_ace_if.wstrb,
          ifu_ace_if.wlast,
          ifu_ace_if.wuser} = '0; // Unused

  //// B channel signals
  assign ifu_ace_if.bready = '0; // Don't allow B channel

  //// AR channel signals
  assign ifu_ace_if.arid = '0; // TODO
  assign ifu_ace_if.araddr = pc_q;
  assign ifu_ace_if.arlen = '0; // TODO
  assign ifu_ace_if.arsize = '0; // TODO
  assign ifu_ace_if.arburst = '0; // TODO
  assign ifu_ace_if.arlock = '0; // TODO
  assign ifu_ace_if.arcache = '0; // TODO
  assign ifu_ace_if.arprot = '0; // TODO
  assign ifu_ace_if.arqos = '0; // TODO
  assign ifu_ace_if.arregion = '0; // TODO
  assign ifu_ace_if.aruser = '0; // TODO
  assign ifu_ace_if.arvalid = arvalid_q;
  assign ifu_ace_if.arsnoop = '0; // TODO
  assign ifu_ace_if.ardomain = '0; // TODO
  assign ifu_ace_if.arbar = '0; // TODO

  //// R channel signals
  assign ifu_ace_if.rready = rready_q;

  //// AC channel signals
  assign ifu_ace_if.acready = '0; // TODO

  //// CR channel signals
  assign ifu_ace_if.crvalid = '0; // TODO
  assign ifu_ace_if.crresp = '0; // TODO

  //// CD channel signals
  assign ifu_ace_if.cdvalid = '0; // TODO
  assign ifu_ace_if.cddata = '0; // TODO
  assign ifu_ace_if.cdlast = '0; // TODO

  //// Acknowledgment signals
  assign ifu_ace_if.rack = rready_q && ifu_ace_if.rvalid; // NOTE: This might have to be delayed until the cache state is successfully updated
  assign ifu_ace_if.wack = '0; // Unused

endmodule
