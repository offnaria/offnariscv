// SPDX-License-Identifier: MIT

// System Module
module system
  import offnariscv_pkg::*;
(
  input logic clk,
  input logic rst,

  axis_if.s rfsys_axis_if, // From Dispatcher
  axis_if.m syswb_axis_if, // To Write Back

  input logic invalidate
);

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(syswb_tdata_t))) syswb_slice_if ();

  // Declare wires
  rfsys_tdata_t rfsys_tdata;
  syswb_tdata_t syswb_tdata;
  logic [XLEN-1:0] operand;

  always_comb begin
    rfsys_tdata = rfsys_axis_if.tdata;

    operand = rfsys_tdata.operands.op1 | rfsys_tdata.operands.op2; // NOTE: SFENCE.VMA uses both operands, but we assume they are exclusive for other commands
    syswb_tdata = '0;
    unique case (rfsys_tdata.cmd) inside
      CSRRW, CSRRWI: syswb_tdata.csr_wdata = operand;
      CSRRS, CSRRSI: syswb_tdata.csr_wdata = (rfsys_tdata.csr_rdata | operand);
      CSRRC, CSRRCI: syswb_tdata.csr_wdata = (rfsys_tdata.csr_rdata & ~operand);
      default: begin
        // TODO: Handle other system commands
      end
    endcase
    syswb_tdata.csr_update = (rfsys_tdata.csr_rdata != syswb_tdata.csr_wdata);

    // Slice connection
    syswb_slice_if.tdata = syswb_tdata;
    syswb_slice_if.tvalid = rfsys_axis_if.tvalid;
    rfsys_axis_if.tready = syswb_slice_if.tready;
  end

  // Instantiate slice
  axis_slice syswb_slice (
    .clk(clk),
    .rst(rst),
    .axis_mif(syswb_axis_if),
    .axis_sif(syswb_slice_if),
    .invalidate(invalidate)
  );

endmodule
