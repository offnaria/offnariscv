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
  localparam INDEX_WIDTH = l1d_dir_if.INDEX_WIDTH;
  localparam TAG_WIDTH = l1d_dir_if.TAG_WIDTH;
  localparam STRB_WIDTH = l1d_mem_if.STRB_WIDTH;

  // Assert conditions
  initial begin
    assert (ADDR_WIDTH == XLEN)
    else $fatal("lsu_ace_if.ADDR_WIDTH must be equal to XLEN for now");
    assert (TAG_WIDTH + INDEX_WIDTH + BLOCK_OFFSET_WIDTH == ADDR_WIDTH)
    else $fatal("TAG_WIDTH + INDEX_WIDTH + BLOCK_OFFSET_WIDTH must equal ADDR_WIDTH");
    assert (l1d_mem_if.BLOCK_SIZE == BLOCK_SIZE)
    else $fatal("l1d_mem_if.BLOCK_SIZE must match BLOCK_SIZE");
    assert (l1d_mem_if.INDEX_WIDTH == INDEX_WIDTH)
    else $fatal("l1d_mem_if.INDEX_WIDTH must match INDEX_WIDTH");
  end

  // Define types
  typedef enum logic [1:0] {
    IDLE,
    COMPARE,
    WAIT
  } state_e;  // TODO: There might be more states for AMO in the future

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(lsuwb_tdata_t))) lsuwb_slice_if ();

  // Define functions
  function automatic logic [XLEN-1:0] slice_load(logic [BLOCK_SIZE-1:0] block, lsu_cmd_e cmd,
                                                 logic [BLOCK_OFFSET_WIDTH-1:0] offset);
    slice_load = '0;
    case (cmd)
      LSU_LW:  slice_load = block[XLEN*offset[2+:BLOCK_SEL_WIDTH]+:XLEN];
      LSU_LH:  slice_load = XLEN'(signed'(block[16*offset[1+:BLOCK_SEL_WIDTH+1]+:16]));
      LSU_LB:  slice_load = XLEN'(signed'(block[8*offset[0+:BLOCK_SEL_WIDTH+2]+:8]));
      LSU_LHU: slice_load = XLEN'(unsigned'(block[16*offset[1+:BLOCK_SEL_WIDTH+1]+:16]));
      LSU_LBU: slice_load = XLEN'(unsigned'(block[8*offset[0+:BLOCK_SEL_WIDTH+2]+:8]));
      default: begin
      end
    endcase
  endfunction

  function automatic logic [STRB_WIDTH-1:0] get_strb(lsu_cmd_e cmd,
                                                     logic [BLOCK_OFFSET_WIDTH-1:0] offset);
    get_strb = '0;
    case (cmd)
      LSU_SW: get_strb[4*offset[2+:BLOCK_SEL_WIDTH]+:4] = '1;
      LSU_SH: get_strb[2*offset[1+:BLOCK_SEL_WIDTH+1]+:2] = '1;
      LSU_SB: get_strb[offset[0+:BLOCK_SEL_WIDTH+2]] = '1;
      default: begin
      end
    endcase
  endfunction

  // Declare registers and their next states
  state_e state_q, state_d;
  logic rflsu_tready_q, rflsu_tready_d;
  logic arvalid_q, arvalid_d;
  logic [ADDR_WIDTH-1:0] araddr_q, araddr_d;
  logic rready_q, rready_d;
  logic [BLOCK_SIZE-1:0] rdata_q, rdata_d;
  logic [$bits(lsu_ace_if.rresp)-1:0] rresp_q, rresp_d;
  logic awvalid_q, awvalid_d;
  logic [ADDR_WIDTH-1:0] awaddr_q, awaddr_d;
  logic wvalid_q, wvalid_d;
  logic [BLOCK_SIZE-1:0] wdata_q, wdata_d;
  logic [BLOCK_SIZE/8-1:0] wstrb_q, wstrb_d;  // For cache update
  logic bready_q, bready_d;
  logic [$bits(lsu_ace_if.bresp)-1:0] bresp_q, bresp_d;
  logic [TAG_WIDTH-1:0] tag_q, tag_d;
  logic [INDEX_WIDTH-1:0] index_q, index_d;
  logic load_q, load_d;
  logic store_q, store_d;
  lsu_cmd_e cmd_q, cmd_d;
  logic [XLEN-1:0] op2_q, op2_d;

  logic [INDEX_WIDTH-1:0] l1dc_dir_index_q, l1dc_dir_index_d;
  logic [INDEX_WIDTH-1:0] l1dc_mem_index_q, l1dc_mem_index_d;

  // Declare wires
  rflsu_tdata_t rflsu_tdata;
  logic [XLEN-1:0] effective_addr;
  logic l1dtlb_hit;
  lsuwb_tdata_t lsuwb_tdata;
  logic [BLOCK_SIZE-1:0] store_data;

  assign rflsu_axis_if.tready = rflsu_tready_q;

  always_comb begin
    state_d = state_q;
    arvalid_d = arvalid_q;
    araddr_d = araddr_q;
    rready_d = rready_q;
    rdata_d = rdata_q;
    rresp_d = rresp_q;
    awvalid_d = awvalid_q;
    awaddr_d = awaddr_q;
    wvalid_d = wvalid_q;
    wdata_d = wdata_q;
    wstrb_d = wstrb_q;
    bready_d = bready_q;
    bresp_d = bresp_q;
    tag_d = tag_q;
    index_d = index_q;
    load_d = load_q;
    store_d = store_q;
    cmd_d = cmd_q;
    op2_d = op2_q;

    l1dc_dir_index_d = l1dc_dir_index_q;
    l1dc_mem_index_d = l1dc_mem_index_q;

    rflsu_tdata = rflsu_axis_if.tdata;
    effective_addr = rflsu_tdata.operands.op1 + rflsu_tdata.offset;
    l1dtlb_hit = 1'b1;  // TODO
    lsuwb_tdata = '0;
    lsuwb_tdata.result = slice_load(l1d_mem_if.rdata, cmd_q, araddr_q[BLOCK_OFFSET_WIDTH-1:0]);
    l1d_dir_if.index = l1dc_dir_index_q;
    l1d_dir_if.next_tag = tag_q;
    l1d_dir_if.next_state = '{default: '0, v: 1'b1};
    l1d_dir_if.write = '0;
    lsuwb_slice_if.tvalid = '0;

    if (lsu_ace_if.arready) begin  // AR channel
      arvalid_d = '0;
    end
    if (lsu_ace_if.rvalid) begin  // R channel
      rready_d = '0;
      rdata_d  = lsu_ace_if.rdata;
      rresp_d  = lsu_ace_if.rresp;
    end
    if (lsu_ace_if.awready) begin  // AW channel
      awvalid_d = '0;
    end
    if (lsu_ace_if.wready) begin  // W channel
      wvalid_d = '0;
    end
    if (lsu_ace_if.bvalid) begin  // B channel
      bready_d = '0;
      bresp_d  = lsu_ace_if.bresp;
    end

    store_data = '0;
    unique case (cmd_q)
      LSU_SW: store_data = {(BLOCK_SIZE / 32) {op2_q}};
      LSU_SH: store_data = {(BLOCK_SIZE / 16) {op2_q[15:0]}};
      LSU_SB: store_data = {(BLOCK_SIZE / 8) {op2_q[7:0]}};
      default: begin
      end
    endcase

    l1d_mem_if.index = l1dc_mem_index_q;
    l1d_mem_if.wstrb = '0;
    l1d_mem_if.wdata = rdata_d;
    if (store_q) begin
      l1d_dir_if.next_state.d = 1'b1;
      for (int i = 0; i < STRB_WIDTH; i++) begin
        if (wstrb_q[i]) begin
          l1d_mem_if.wdata[8*i+:8] = store_data[8*(i%4)+:8];
        end
      end
    end

    unique case (state_q)
      IDLE: begin
        araddr_d = effective_addr;
        tag_d = effective_addr[ADDR_WIDTH-1-:TAG_WIDTH];
        index_d = effective_addr[BLOCK_OFFSET_WIDTH+:INDEX_WIDTH];
        load_d = rflsu_tdata.cmd inside {LSU_LW, LSU_LH, LSU_LB, LSU_LHU, LSU_LBU};
        store_d = rflsu_tdata.cmd inside {LSU_SW, LSU_SH, LSU_SB};
        cmd_d = rflsu_tdata.cmd;
        op2_d = rflsu_tdata.operands.op2;
        l1dc_dir_index_d = effective_addr[BLOCK_OFFSET_WIDTH+:INDEX_WIDTH];
        l1dc_mem_index_d = effective_addr[BLOCK_OFFSET_WIDTH+:INDEX_WIDTH];
        if (store_d) begin
          wstrb_d = get_strb(cmd_d, effective_addr[BLOCK_OFFSET_WIDTH-1:0]);
        end
        if (rflsu_axis_if.tvalid && !invalidate) begin
          state_d = COMPARE;
        end
      end
      COMPARE: begin
        if (l1dtlb_hit) begin
          if (l1d_dir_if.current_state.v && (l1d_dir_if.current_tag == tag_q)) begin  // Hit
            lsuwb_slice_if.tvalid = 1'b1;
            if (lsuwb_slice_if.tready) begin
              if (store_q) begin
                l1d_dir_if.write = 1'b1;
                l1d_mem_if.wstrb = wstrb_q;
              end
              state_d = IDLE;
            end
          end else begin  // Miss
            arvalid_d = 1'b1;
            rready_d  = 1'b1;
            awaddr_d  = {l1d_dir_if.current_tag, index_q, BLOCK_OFFSET_WIDTH'(0)};
            wdata_d   = l1d_mem_if.rdata;
            if (l1d_dir_if.current_state.v && l1d_dir_if.current_state.d) begin  // Write back
              awvalid_d = 1'b1;
              wvalid_d  = 1'b1;
              bready_d  = 1'b1;
            end
            state_d = WAIT;
          end
        end
      end
      WAIT: begin
        if (!rready_d && !bready_d) begin
          lsuwb_slice_if.tvalid = 1'b1;
          lsuwb_tdata.result = slice_load(rdata_d, cmd_q, araddr_q[BLOCK_OFFSET_WIDTH-1:0]);
          if (lsuwb_slice_if.tready) begin
            l1d_dir_if.write = 1'b1;
            l1d_mem_if.wstrb = '1;
            state_d = IDLE;
          end
        end
      end
      default: begin
      end
    endcase

    rflsu_tready_d = (state_d == IDLE);

`ifndef SYNTHESIS
    lsuwb_tdata.addr  = araddr_q;
    lsuwb_tdata.wdata = op2_q;
    lsuwb_tdata.store = store_q;
`endif
    lsuwb_slice_if.tdata = lsuwb_tdata;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      state_q <= IDLE;
      rflsu_tready_q <= 0;
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
      araddr_q <= '0;
      awaddr_q <= '0;
      tag_q <= '0;
      index_q <= '0;
      load_q <= 0;
      store_q <= 0;
      cmd_q <= LSU_LW;
      op2_q <= '0;
    end else begin
      state_q <= state_d;
      rflsu_tready_q <= rflsu_tready_d;
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
      araddr_q <= araddr_d;
      awaddr_q <= awaddr_d;
      tag_q <= tag_d;
      index_q <= index_d;
      load_q <= load_d;
      store_q <= store_d;
      cmd_q <= cmd_d;
      op2_q <= op2_d;
      $write(
          "LSU: state=%s, arvalid=%b, rready=%b, awvalid=%b, wvalid=%b, wdata=0x%h, wstrb=0x%h, bready=%b, bresp=0x%h, addr=0x%h\n",
          state_q.name(), arvalid_q, rready_q, awvalid_q, wvalid_q, wdata_q, wstrb_q, bready_q,
          bresp_q, araddr_q);
      if ((state_q == COMPARE) && l1dtlb_hit && l1d_dir_if.current_state.v && (l1d_dir_if.current_tag == tag_q))
        $write(
            "LSU: Cache hit... araddr=0x%h, tag=0x%h, index=0x%h, rdata=0x%h\n",
            araddr_q,
            tag_q,
            index_q,
            l1d_mem_if.rdata
        );
      if (|l1d_mem_if.wstrb)
        $write(
            "LSU: Writing to memory... wstrb=%b, wdata=0x%h, wstrb_q=%b\n",
            l1d_mem_if.wstrb,
            l1d_mem_if.wdata,
            wstrb_q
        );
    end
  end

  always_ff @(posedge clk) begin
    l1dc_dir_index_q <= l1dc_dir_index_d;
    l1dc_mem_index_q <= l1dc_mem_index_d;
  end

  axis_skid_buffer lsuwb_slice_inst (
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
  assign lsu_ace_if.awaddr = awaddr_q;
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
  assign lsu_ace_if.wstrb = '1;  // For write back
  assign lsu_ace_if.wlast = 1'b1;  // TODO
  assign lsu_ace_if.wuser = '0;  // TODO

  //// B channel signals
  assign lsu_ace_if.bready = bready_q;

  //// AR channel signals
  assign lsu_ace_if.arid = '0;  // TODO
  assign lsu_ace_if.araddr = araddr_q;
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
