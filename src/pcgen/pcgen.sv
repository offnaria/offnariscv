// SPDX-License-Identifier: MIT

// Program Counter Generator
module pcgen
  import offnariscv_pkg::*;
# (
  parameter RESET_VECTOR = 0
) (
  input clk,
  input rst,

  // From/To Instruction Fetch Unit
  axis_if.m pcgif_axis_if,

  // From Branch Resolution Unit
  axis_if.s wbpcg_axis_if
);

  // Assert conditions
  initial begin
    assert (pcgif_axis_if.TDATA_WIDTH == XLEN) else $fatal("pcgif_axis_if.TDATA_WIDTH must be equal to XLEN");
    assert (wbpcg_axis_if.TDATA_WIDTH == XLEN) else $fatal("wbpcg_axis_if.TDATA_WIDTH must be equal to XLEN");
  end

  // Declare registers and their next states
  logic [XLEN-1:0] pc_q, pc_d;

`ifndef SYNTHESIS
  logic [INST_ID_WIDTH-1:0] inst_id_q, inst_id_d;
`endif

  // Declare wires
  pcgif_tdata_t pcgif_tdata;

  // Wire assignments
  assign wbpcg_axis_if.tready = 1'b1;
  assign pcgif_axis_if.tvalid = 1'b1;

  always_comb begin
    pc_d = pc_q;

    pcgif_tdata.pc = pc_q;
    pcgif_tdata.untaken_pc = '0; // TODO

    if (wbpcg_axis_if.tvalid) begin
      pc_d = wbpcg_axis_if.tdata;
    end else if (pcgif_axis_if.tready) begin
      pc_d = pc_q + XLEN'(4);
    end

`ifndef SYNTHESIS
    inst_id_d = inst_id_q;
    if (wbpcg_axis_if.tvalid || pcgif_axis_if.tready) begin
      inst_id_d = inst_id_q + INST_ID_WIDTH'(1);
    end

    pcgif_tdata.id = inst_id_q;
`endif

    pcgif_axis_if.tdata = pcgif_tdata;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      pc_q <= RESET_VECTOR;
`ifndef SYNTHESIS
      inst_id_q <= '0;
`endif
    end else begin
      pc_q <= pc_d;
`ifndef SYNTHESIS
      inst_id_q <= inst_id_d;
`endif
    end
  end

endmodule
