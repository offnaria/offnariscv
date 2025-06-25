// SPDX-License-Identifier: MIT

// Control and Status Register
module csr
  import offnariscv_pkg::*;
# (
  parameter MHARTID = 0
) (
  input logic clk,
  input logic rst,

  csr_rif.rsp csr_rif_rsp,
  csr_wif.rsp csr_wif_rsp
);

  // Declare registers and their next states
  logic [XLEN-1:0] mvendorid_q, mvendorid_d;
  logic [XLEN-1:0] marchid_q, marchid_d;
  // logic [XLEN-1:0] mimpid_q; // TODO
  logic [XLEN-1:0] mhartid_q, mhartid_d;
  // mstatus_t mstatus_q, mstatus_d; // TODO
  logic [XLEN-1:0] misa_q, misa_d;
  // logic [XLEN-1:0] medeleg_q, medeleg_d; // TODO
  // logic [XLEN-1:0] mideleg_q, mideleg_d; // TODO
  // logic [XLEN-1:0] mie_q, mie_d; // TODO
  logic [XLEN-1:0] mtvec_q, mtvec_d;
  // mstatush_t mstatush_q, mstatush_d; // TODO
  // logic [XLEN-1:0] medelegh_q, medelegh_d; // TODO
  logic [XLEN-1:0] mepc_q, mepc_d;
  logic [XLEN-1:0] mcause_q, mcause_d;

  always_comb begin
    misa_d = misa_q;
    mvendorid_d = mvendorid_q;
    marchid_d = marchid_q;
    mhartid_d = mhartid_q;
    mtvec_d = mtvec_q;
    mepc_d = mepc_q;
    mcause_d = mcause_q;

    // Read CSR
    csr_rif_rsp.rdata = '0;
    csr_rif_rsp.mtvec = mtvec_q;
    csr_rif_rsp.mepc = mepc_q;
    csr_rif_rsp.ro = (csr_rif_rsp.addr[11:10] == 2'b11);
    csr_rif_rsp.exception = '0; // TODO: This would be used for illegal CSR access, such as privilege level violations
    unique case (csr_rif_rsp.addr)
      12'hf11: csr_rif_rsp.rdata = mvendorid_q;
      12'hf12: csr_rif_rsp.rdata = marchid_q;
      // 12'hf13: csr_rif_rsp.rdata = mimpid_q; // TODO
      12'hf14: csr_rif_rsp.rdata = mhartid_q;
      // 12'h300: csr_rif_rsp.rdata = mstatus_q; // TODO
      12'h301: csr_rif_rsp.rdata = misa_q;
      // 12'h302: csr_rif_rsp.rdata = medeleg_q; // TODO
      // 12'h303: csr_rif_rsp.rdata = mideleg_q; // TODO
      // 12'h304: csr_rif_rsp.rdata = mie_q; // TODO
      12'h305: csr_rif_rsp.rdata = mtvec_q;
      // 12'h310: csr_rif_rsp.rdata = mstatush_q; // TODO
      // 12'h312: csr_rif_rsp.rdata = medelegh_q; // TODO
      12'h341: csr_rif_rsp.rdata = {mepc_q[XLEN-1:2], 2'b00}; // IALIGN = 32
      12'h342: csr_rif_rsp.rdata = mcause_q;
      default: begin
      end
    endcase

    // Write CSR
    if (csr_wif_rsp.valid) begin
      unique case (csr_wif_rsp.addr)
        12'h305: mtvec_d[XLEN-1:2] = csr_wif_rsp.data[XLEN-1:2]; // Direct mode
        12'h341: mepc_d = csr_wif_rsp.data;
        12'h342: mcause_d = csr_wif_rsp.data;
        default: begin
          // TODO: Handle other CSRs
        end
      endcase
      // TODO: Handle traps
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      misa_q <= {2'd2, (XLEN-28)'(0), 26'(2**8)}; // RV32I
      mvendorid_q <= '0; // Non-commercial implementation
      marchid_q <= '0; // Not assigned yet
      mhartid_q <= MHARTID;
      // mstatus_q <= '0; // TODO
      // mstatush_q <= '0; // TODO
      mtvec_q <= '0; // Direct mode
      mepc_q <= '0;
      mcause_q <= '0;
    end else begin
      misa_q <= misa_d;
      mvendorid_q <= mvendorid_d;
      marchid_q <= marchid_d;
      mhartid_q <= mhartid_d;
      // mstatus_q <= mstatus_d;
      // mstatush_q <= mstatush_d;
      mtvec_q <= mtvec_d;
      mepc_q <= mepc_d;
      mcause_q <= mcause_d;
    end
  end

endmodule
