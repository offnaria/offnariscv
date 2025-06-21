// SPDX-License-Identifier: MIT

// Instruction Committer
module committer
  import offnariscv_pkg::*;
(
  input logic clk,
  input logic rst,

  axis_if.s exwb_axis_if, // From EX FIFO (Dispatcher)
  axis_if.s aluwb_axis_if, // From ALU
  axis_if.s bruwb_axis_if, // From BRU
  axis_if.m wbrf_axis_if, // To Register File
  axis_if.m wbpcg_axis_if // To Program Counter Generator
);

  exwb_tdata_t exwb_tdata;
  aluwb_tdata_t aluwb_tdata;
  bruwb_tdata_t bruwb_tdata;
  wbrf_tdata_t wbrf_tdata;

  always_comb begin
    exwb_tdata = exwb_axis_if.tdata;
    aluwb_tdata = aluwb_axis_if.tdata;
    bruwb_tdata = bruwb_axis_if.tdata;

    // wbrf_tdata.wdata = aluwb_tdata.result;
    unique case (1'b1)
      exwb_tdata.rf_data.id_data.alu_cmd_vld: begin
        wbrf_tdata.wdata = aluwb_tdata.result;
      end
      exwb_tdata.rf_data.id_data.bru_cmd_vld: begin
        wbrf_tdata.wdata = bruwb_tdata.result;
      end
    endcase
    wbrf_tdata.ex_data = exwb_tdata;

    exwb_axis_if.tready = wbrf_axis_if.tready && wbpcg_axis_if.tready
                                              && ((aluwb_axis_if.tvalid && exwb_tdata.rf_data.id_data.alu_cmd_vld) || 
                                                  (bruwb_axis_if.tvalid && exwb_tdata.rf_data.id_data.bru_cmd_vld));
    aluwb_axis_if.tready = wbrf_axis_if.tready;
    bruwb_axis_if.tready = wbrf_axis_if.tready;

    wbrf_axis_if.tdata = wbrf_tdata;
    wbrf_axis_if.tvalid = exwb_axis_if.tvalid && exwb_axis_if.tready;
    wbpcg_axis_if.tdata = bruwb_tdata.new_pc;
    wbpcg_axis_if.tvalid = exwb_axis_if.tvalid && exwb_axis_if.tready && bruwb_axis_if.tvalid && exwb_tdata.rf_data.id_data.bru_cmd_vld && bruwb_tdata.taken;
  end

endmodule
