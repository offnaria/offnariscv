// SPDX-License-Identifier: MIT

// Instruction Fetch Unit
module ifu
  import offnariscv_pkg::*;
# (
  parameter RESET_VECTOR = 0
) (
  input clk,
  input rst_n,

  // To lower level memory
  ace_if.m ifu_ace_if,

  // From/To Program Counter Generator
  axis_if.s next_pc_axis_if,
  axis_if.m current_pc_axis_if,

  // To Decoder
  axis_if.m inst_axis_if,

  input logic invalidate
);

  // Define local parameters
  localparam BLOCK_SIZE = ACE_XDATA_WIDTH;

  // Assert conditions
  initial begin
    assert (ACE_AXADDR_WIDTH == XLEN) else $fatal("ifu_ace_if.ACE_AXADDR_WIDTH must be equal to XLEN for now");
    assert (next_pc_axis_if.TDATA_WIDTH == XLEN) else $fatal("next_pc_axis_if.TDATA_WIDTH must be equal to XLEN");
    assert (current_pc_axis_if.TDATA_WIDTH == XLEN) else $fatal("current_pc_axis_if.TDATA_WIDTH must be equal to XLEN");
    assert (inst_axis_if.TDATA_WIDTH == $bits(ifid_tdata_t)) else $fatal("inst_axis_if.TDATA_WIDTH must match ifid_tdata_t");
  end

  // Define types
  typedef enum logic [2:0] {
    INIT,
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
  logic [XLEN-1:0] inst_q, inst_d;
  logic [ACE_RRESP_WIDTH-1:0] rresp_q, rresp_d;
`ifndef SYNTHESIS
  logic [INST_ID_WIDTH-1:0] inst_id_q, inst_id_d;
`endif

  // Declare wires
  ifid_tdata_t ifid_tdata;
  logic icache_hit;
  logic [XLEN-1:0] icache_data;
  logic itlb_hit;

  // Wire assignments
  assign pc_d = (next_pc_axis_if.tvalid && next_pc_axis_if.tready) ? next_pc_axis_if.tdata : pc_q;

  assign next_pc_axis_if.tready = (state_d == IDLE);
  assign current_pc_axis_if.tdata = pc_q;
  assign current_pc_axis_if.tvalid = 1'b1;

  assign ifid_tdata.pc = pc_q;
  assign ifid_tdata.untaken_pc = '0; // TODO
  assign ifid_tdata.inst = inst_d;
  assign ifid_pipe_reg_if.tdata = ifid_tdata;

  assign icache_hit = 1'b0; // TODO
  assign icache_data = '0; // TODO
  assign itlb_hit = 1'b1; // TODO

`ifndef SYNTHESIS
  assign ifid_tdata.id = inst_id_q;
  assign inst_id_d = (ifid_pipe_reg_if.tvalid && ifid_pipe_reg_if.tready) ? inst_id_q + INST_ID_WIDTH'(1) : inst_id_q;
`endif

  // State machine logic
  always_comb begin
    state_d = state_q;
    arvalid_d = arvalid_q;
    rready_d = rready_q;
    inst_d = inst_q;
    rresp_d = rresp_q;

    ifid_pipe_reg_if.tvalid = 1'b0;

    case (state_q)
      INIT: begin
        // Load the first instruction
        arvalid_d = 1'b1;
        rready_d = 1'b1;
        state_d = LOAD;
      end
      IDLE: begin
        if (itlb_hit) begin
          if (icache_hit) begin
            ifid_pipe_reg_if.tvalid = 1'b1;
            inst_d = icache_data;
            if (ifid_pipe_reg_if.tready) begin
              state_d = IDLE;
            end else begin
              state_d = WAIT;
            end
          end else begin
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
          inst_d = ifu_ace_if.rdata;
          rresp_d = ifu_ace_if.rresp;
        end
        if (!rready_d) begin // rvalid must be asserted after arready
          ifid_pipe_reg_if.tvalid = 1'b1;
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
    if (!rst_n) begin
      pc_q <= XLEN'(RESET_VECTOR);
      state_q <= INIT;
      arvalid_q <= '0;
      rready_q <= '0;
      inst_q <= '0;
      rresp_q <= '0;
`ifndef SYNTHESIS
      inst_id_q <= '0;
`endif
    end else begin
      pc_q <= pc_d;
      state_q <= state_d;
      arvalid_q <= arvalid_d;
      rready_q <= rready_d;
      inst_q <= inst_d;
      rresp_q <= rresp_d;
`ifndef SYNTHESIS
      inst_id_q <= inst_id_d;
`endif
    end
  end

  axis_skid_buffer ifid_pipe_reg (
    .clk(clk),
    .rst_n(rst_n),
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
