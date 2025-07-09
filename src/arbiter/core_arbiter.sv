// SPDX-License-Identifier: MIT

module core_arbiter
  import offnariscv_pkg::*;
(
  input logic clk,
  input logic rst,

  ace_if.s ifu_ace_if, // From IFU
  ace_if.s lsu_ace_if, // From LSU

  ace_if.m core_ace_if
);

  // Define local parameters
  localparam ACE_XDATA_WIDTH = core_ace_if.ACE_XDATA_WIDTH;
  localparam ACE_AXADDR_WIDTH = core_ace_if.ACE_AXADDR_WIDTH;

  // Assert conditions
  initial begin
    assert (ACE_XDATA_WIDTH == lsu_ace_if.ACE_XDATA_WIDTH) else $fatal("ACE_XDATA_WIDTH must match between core_ace_if and lsu_ace_if");
    assert (ACE_AXADDR_WIDTH == lsu_ace_if.ACE_AXADDR_WIDTH) else $fatal("ACE_AXADDR_WIDTH must match between core_ace_if and lsu_ace_if");
    assert (ACE_XDATA_WIDTH == ifu_ace_if.ACE_XDATA_WIDTH) else $fatal("ACE_XDATA_WIDTH must match between core_ace_if and ifu_ace_if");
    assert (ACE_AXADDR_WIDTH == ifu_ace_if.ACE_AXADDR_WIDTH) else $fatal("ACE_AXADDR_WIDTH must match between core_ace_if and ifu_ace_if");
  end

  // Define types
  typedef enum logic {
    IFU,
    LSU
  } initiator_e;

  typedef enum logic {
    R_IDLE,
    R_LOAD
  } r_state_e;

  // Declare registers and their next states
  initiator_e r_initiator_q, r_initiator_d;

  r_state_e r_state_q, r_state_d;

  logic [ACE_XID_WIDTH-1:0] arid_q, arid_d;
  logic [ACE_AXADDR_WIDTH-1:0] araddr_q, araddr_d;
  logic [ACE_AXLEN_WIDTH-1:0] arlen_q, arlen_d;
  logic [ACE_AXSIZE_WIDTH-1:0] arsize_q, arsize_d;
  logic [ACE_AXBURST_WIDTH-1:0] arburst_q, arburst_d;
  logic arlock_q, arlock_d;
  logic [ACE_AXCACHE_WIDTH-1:0] arcache_q, arcache_d;
  logic [ACE_AXPROT_WIDTH-1:0] arprot_q, arprot_d;
  logic [ACE_AXQOS_WIDTH-1:0] arqos_q, arqos_d;
  logic [ACE_AXREGION_WIDTH-1:0] arregion_q, arregion_d;
  logic [ACE_XUSER_WIDTH-1:0] aruser_q, aruser_d;
  logic arvalid_q, arvalid_d;
  logic [ACE_ARSNOOP_WIDTH-1:0] arsnoop_q, arsnoop_d;
  logic [ACE_DOMAIN_WIDTH-1:0] ardomain_q, ardomain_d;
  logic [ACE_BAR_WIDTH-1:0] arbar_q, arbar_d;
  
  logic [ACE_XID_WIDTH-1:0] rid_q, rid_d;
  logic [ACE_XDATA_WIDTH-1:0] rdata_q, rdata_d;
  logic [ACE_RRESP_WIDTH-1:0] rresp_q, rresp_d;
  logic rlast_q, rlast_d;
  logic [ACE_XUSER_WIDTH-1:0] ruser_q, ruser_d;
  logic rready_q, rready_d;

  logic ifu_rvalid_q, ifu_rvalid_d;
  logic lsu_rvalid_q, lsu_rvalid_d;

  always_comb begin
    // AR/R channel
    r_initiator_d = r_initiator_q;
    r_state_d = r_state_q;

    arid_d = arid_q;
    araddr_d = araddr_q;
    arlen_d = arlen_q;
    arsize_d = arsize_q;
    arburst_d = arburst_q;
    arlock_d = arlock_q;
    arcache_d = arcache_q;
    arprot_d = arprot_q;
    arqos_d = arqos_q;
    arregion_d = arregion_q;
    aruser_d = aruser_q;
    arvalid_d = arvalid_q;
    arsnoop_d = arsnoop_q;
    ardomain_d = ardomain_q;
    arbar_d = arbar_q;

    rid_d = rid_q;
    rdata_d = rdata_q;
    rresp_d = rresp_q;
    rlast_d = rlast_q;
    ruser_d = ruser_q;
    rready_d = rready_q;

    core_ace_if.arid = arid_q;
    core_ace_if.araddr = araddr_q;
    core_ace_if.arlen = arlen_q;
    core_ace_if.arsize = arsize_q;
    core_ace_if.arburst = arburst_q;
    core_ace_if.arlock = arlock_q;
    core_ace_if.arcache = arcache_q;
    core_ace_if.arprot = arprot_q;
    core_ace_if.arqos = arqos_q;
    core_ace_if.arregion = arregion_q;
    core_ace_if.aruser = aruser_q;
    core_ace_if.arvalid = arvalid_q;
    core_ace_if.arsnoop = arsnoop_q;
    core_ace_if.ardomain = ardomain_q;
    core_ace_if.arbar = arbar_q;
    core_ace_if.rready = rready_q;

    ifu_ace_if.arready = '0;
    ifu_ace_if.rid = rid_q;
    ifu_ace_if.rdata = rdata_q;
    ifu_ace_if.rresp = rresp_q;
    ifu_ace_if.rlast = rlast_q;
    ifu_ace_if.ruser = ruser_q;
    ifu_ace_if.rvalid = ifu_rvalid_q;

    lsu_ace_if.arready = '0;
    lsu_ace_if.rid = rid_q;
    lsu_ace_if.rdata = rdata_q;
    lsu_ace_if.rresp = rresp_q;
    lsu_ace_if.rlast = rlast_q;
    lsu_ace_if.ruser = ruser_q;
    lsu_ace_if.rvalid = lsu_rvalid_q;

    unique case (r_state_q)
      R_IDLE: begin
        // Priority: LSU > PW > IFU
        if (lsu_ace_if.arvalid) begin
          arid_d = lsu_ace_if.arid;
          araddr_d = lsu_ace_if.araddr;
          arlen_d = lsu_ace_if.arlen;
          arsize_d = lsu_ace_if.arsize;
          arburst_d = lsu_ace_if.arburst;
          arlock_d = lsu_ace_if.arlock;
          arcache_d = lsu_ace_if.arcache;
          arprot_d = lsu_ace_if.arprot;
          arqos_d = lsu_ace_if.arqos;
          arregion_d = lsu_ace_if.arregion;
          aruser_d = lsu_ace_if.aruser;
          arsnoop_d = lsu_ace_if.arsnoop;
          ardomain_d = lsu_ace_if.ardomain;
          arbar_d = lsu_ace_if.arbar;

          arvalid_d = 1'b1;
          rready_d = 1'b1;
          lsu_ace_if.arready = 1'b1;
          r_initiator_d = LSU;
          r_state_d = R_LOAD;
        end else if (ifu_ace_if.arvalid) begin
          arid_d = ifu_ace_if.arid;
          araddr_d = ifu_ace_if.araddr;
          arlen_d = ifu_ace_if.arlen;
          arsize_d = ifu_ace_if.arsize;
          arburst_d = ifu_ace_if.arburst;
          arlock_d = ifu_ace_if.arlock;
          arcache_d = ifu_ace_if.arcache;
          arprot_d = ifu_ace_if.arprot;
          arqos_d = ifu_ace_if.arqos;
          arregion_d = ifu_ace_if.arregion;
          aruser_d = ifu_ace_if.aruser;
          arsnoop_d = ifu_ace_if.arsnoop;
          ardomain_d = ifu_ace_if.ardomain;
          arbar_d = ifu_ace_if.arbar;

          arvalid_d = 1'b1;
          rready_d = 1'b1;
          ifu_ace_if.arready = 1'b1;
          r_initiator_d = IFU;
          r_state_d = R_LOAD;
        end
      end
      R_LOAD: begin
        if (core_ace_if.arready) begin
          arvalid_d = '0;
        end
        if (core_ace_if.rvalid) begin
          rready_d = '0;
          rid_d = core_ace_if.rid;
          rdata_d = core_ace_if.rdata;
          rresp_d = core_ace_if.rresp;
          rlast_d = core_ace_if.rlast;
          ruser_d = core_ace_if.ruser;
          unique case (r_initiator_q)
            IFU: begin
              ifu_rvalid_d = 1'b1;
            end
            LSU: begin
              lsu_rvalid_d = 1'b1;
            end
            default: begin
            end
          endcase
        end
        if (!rready_d) begin
          if (ifu_rvalid_q && ifu_ace_if.rready) begin
            ifu_rvalid_d = '0;
            r_state_d = R_IDLE;
          end
          if (lsu_rvalid_q && lsu_ace_if.rready) begin
            lsu_rvalid_d = '0;
            r_state_d = R_IDLE;
          end
        end
      end
      default: begin
      end
    endcase

    // AW/W/B channel
    core_ace_if.awid = lsu_ace_if.awid;
    core_ace_if.awaddr = lsu_ace_if.awaddr;
    core_ace_if.awlen = lsu_ace_if.awlen;
    core_ace_if.awsize = lsu_ace_if.awsize;
    core_ace_if.awburst = lsu_ace_if.awburst;
    core_ace_if.awlock = lsu_ace_if.awlock;
    core_ace_if.awcache = lsu_ace_if.awcache;
    core_ace_if.awprot = lsu_ace_if.awprot;
    core_ace_if.awqos = lsu_ace_if.awqos;
    core_ace_if.awregion = lsu_ace_if.awregion;
    core_ace_if.awuser = lsu_ace_if.awuser;
    core_ace_if.awvalid = lsu_ace_if.awvalid;
    lsu_ace_if.awready = core_ace_if.awready;
    core_ace_if.awsnoop = lsu_ace_if.awsnoop;
    core_ace_if.awdomain = lsu_ace_if.awdomain;
    core_ace_if.awbar = lsu_ace_if.awbar;
    core_ace_if.wdata = lsu_ace_if.wdata;
    core_ace_if.wstrb = lsu_ace_if.wstrb;
    core_ace_if.wlast = lsu_ace_if.wlast;
    core_ace_if.wuser = lsu_ace_if.wuser;
    core_ace_if.wvalid = lsu_ace_if.wvalid;
    lsu_ace_if.wready = core_ace_if.wready;
    lsu_ace_if.bid = core_ace_if.bid;
    lsu_ace_if.bresp = core_ace_if.bresp;
    lsu_ace_if.buser = core_ace_if.buser;
    lsu_ace_if.bvalid = core_ace_if.bvalid;
    core_ace_if.bready = lsu_ace_if.bready;

    core_ace_if.rack = ifu_ace_if.rack || lsu_ace_if.rack; // TODO
    core_ace_if.wack = lsu_ace_if.wack;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      r_initiator_q <= IFU;
      r_state_q <= R_IDLE;
      arid_q <= '0;
      araddr_q <= '0;
      arlen_q <= '0;
      arsize_q <= '0;
      arburst_q <= '0;
      arlock_q <= '0;
      arcache_q <= '0;
      arprot_q <= '0;
      arqos_q <= '0;
      arregion_q <= '0;
      aruser_q <= '0;
      arvalid_q <= '0;
      arsnoop_q <= '0;
      ardomain_q <= '0;
      arbar_q <= '0;
      rid_q <= '0;
      rdata_q <= '0;
      rresp_q <= '0;
      rlast_q <= '0;
      ruser_q <= '0;
      rready_q <= '0;
      ifu_rvalid_q <= '0;
      lsu_rvalid_q <= '0;
    end else begin
      r_initiator_q <= r_initiator_d;
      r_state_q <= r_state_d;
      arid_q <= arid_d;
      araddr_q <= araddr_d;
      arlen_q <= arlen_d;
      arsize_q <= arsize_d;
      arburst_q <= arburst_d;
      arlock_q <= arlock_d;
      arcache_q <= arcache_d;
      arprot_q <= arprot_d;
      arqos_q <= arqos_d;
      arregion_q <= arregion_d;
      aruser_q <= aruser_d;
      arvalid_q <= arvalid_d;
      arsnoop_q <= arsnoop_d;
      ardomain_q <= ardomain_d;
      arbar_q <= arbar_d;
      rid_q <= rid_d;
      rdata_q <= rdata_d;
      rresp_q <= rresp_d;
      rlast_q <= rlast_d;
      ruser_q <= ruser_d;
      rready_q <= rready_d;
      ifu_rvalid_q <= ifu_rvalid_d;
      lsu_rvalid_q <= lsu_rvalid_d;
    end
  end

endmodule