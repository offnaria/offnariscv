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
  axis_if.s syswb_axis_if, // From System Unit
  axis_if.m wbrf_axis_if, // To Register File
  axis_if.m wbpcg_axis_if, // To Program Counter Generator

  csr_wif.req wbcsr_wif // For CSR write interface
);

  exwb_tdata_t exwb_tdata;
  aluwb_tdata_t aluwb_tdata;
  bruwb_tdata_t bruwb_tdata;
  syswb_tdata_t syswb_tdata;
  wbrf_tdata_t wbrf_tdata;

  always_comb begin
    exwb_tdata = exwb_axis_if.tdata;
    aluwb_tdata = aluwb_axis_if.tdata;
    bruwb_tdata = bruwb_axis_if.tdata;
    syswb_tdata = syswb_axis_if.tdata;

    // wbrf_tdata.wdata = aluwb_tdata.result;
    unique case (1'b1)
      exwb_tdata.rf_data.id_data.alu_cmd_vld: begin
        wbrf_tdata.wdata = aluwb_tdata.result;
      end
      exwb_tdata.rf_data.id_data.bru_cmd_vld: begin
        wbrf_tdata.wdata = bruwb_tdata.result;
      end
      exwb_tdata.rf_data.id_data.sys_cmd_vld: begin
        wbrf_tdata.wdata = exwb_tdata.rf_data.csr_rdata;
      end
    endcase
    wbrf_tdata.ex_data = exwb_tdata;

    exwb_axis_if.tready = wbrf_axis_if.tready && ((!exwb_tdata.rf_data.id_data.alu_cmd_vld || aluwb_axis_if.tvalid) && 
                                                  (!exwb_tdata.rf_data.id_data.bru_cmd_vld || (bruwb_axis_if.tvalid && (!bruwb_tdata.taken || wbpcg_axis_if.tready))) && 
                                                  (!exwb_tdata.rf_data.id_data.sys_cmd_vld || (syswb_axis_if.tvalid && (!syswb_tdata.csr_update || wbpcg_axis_if.tready))) &&
                                                  (!exwb_tdata.rf_data.id_data.if_data.int_exc_valid || wbpcg_axis_if.tready));
    aluwb_axis_if.tready = wbrf_axis_if.tready;
    bruwb_axis_if.tready = wbrf_axis_if.tready && (!bruwb_tdata.taken || wbpcg_axis_if.tready);
    syswb_axis_if.tready = wbrf_axis_if.tready && (!syswb_tdata.csr_update || wbpcg_axis_if.tready);

    wbrf_axis_if.tdata = wbrf_tdata;
    wbrf_axis_if.tvalid = exwb_axis_if.tvalid && exwb_axis_if.tready;

    // CSR
    wbcsr_wif.addr = exwb_tdata.rf_data.id_data.csr_addr;
    wbcsr_wif.data = syswb_tdata.csr_wdata;
    wbcsr_wif.pc = exwb_tdata.rf_data.id_data.if_data.pc;
    wbcsr_wif.cause = XLEN'(exwb_tdata.rf_data.id_data.if_data.int_exc_code); // TODO
    wbcsr_wif.trap = '0; // TODO
    wbcsr_wif.valid = syswb_axis_if.tvalid && syswb_axis_if.tready && syswb_tdata.csr_update; // TODO

    // Program Counter Generator
    wbpcg_axis_if.tdata = '0;
    case (1'b1)
      exwb_tdata.rf_data.id_data.if_data.int_exc_valid: wbpcg_axis_if.tdata = exwb_tdata.rf_data.mtvec;
      bruwb_tdata.taken: wbpcg_axis_if.tdata = bruwb_tdata.new_pc;
      syswb_tdata.csr_update: wbpcg_axis_if.tdata = exwb_tdata.rf_data.id_data.if_data.pc + 'd4; // Re-fetch next instruction
      default: begin
      end
    endcase
    wbpcg_axis_if.tvalid = (exwb_axis_if.tvalid && exwb_axis_if.tready) && ((exwb_tdata.rf_data.id_data.bru_cmd_vld && bruwb_tdata.taken) || 
                                                                            (exwb_tdata.rf_data.id_data.sys_cmd_vld && syswb_tdata.csr_update) ||
                                                                            exwb_tdata.rf_data.id_data.if_data.int_exc_valid);
  end

endmodule
