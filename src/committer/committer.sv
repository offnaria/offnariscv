// SPDX-License-Identifier: MIT

// Instruction Committer
module committer
  import riscv_pkg::*, offnariscv_pkg::*;
(
  input logic clk,
  input logic rst,

  axis_if.s exwb_axis_if, // From EX FIFO (Dispatcher)
  axis_if.s aluwb_axis_if, // From ALU
  axis_if.s bruwb_axis_if, // From BRU
  axis_if.s syswb_axis_if, // From System Unit
  axis_if.s lsuwb_axis_if, // From LSU
  axis_if.m wbrf_axis_if, // To Register File
  axis_if.m wbpcg_axis_if, // To Program Counter Generator

  csr_wif.req wbcsr_wif // For CSR write interface
);

  exwb_tdata_t exwb_tdata;
  aluwb_tdata_t aluwb_tdata;
  bruwb_tdata_t bruwb_tdata;
  syswb_tdata_t syswb_tdata;
  lsuwb_tdata_t lsuwb_tdata;
  wbrf_tdata_t wbrf_tdata;

  trap_cause_t trap_cause;
  logic trap;

  always_comb begin
    exwb_tdata = exwb_axis_if.tdata;
    aluwb_tdata = aluwb_axis_if.tdata;
    bruwb_tdata = bruwb_axis_if.tdata;
    syswb_tdata = syswb_axis_if.tdata;
    lsuwb_tdata = lsuwb_axis_if.tdata;

    // NOTE: Handling traps and interrupts in the system unit may not be enough,
    //       because an execution unit, such as LSU, can generate an exception.
    //       Therefore, handle them in this module.
    trap_cause = syswb_tdata.trap_cause; // TODO: Check the result of LSU
    trap = syswb_tdata.trap; // TODO

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
                                                  (!exwb_tdata.rf_data.id_data.sys_cmd_vld || (syswb_axis_if.tvalid && (!syswb_tdata.use_new_pc || wbpcg_axis_if.tready))) &&
                                                  (!exwb_tdata.rf_data.id_data.lsu_cmd_vld || (lsuwb_axis_if.tvalid && (!lsuwb_tdata.trap || wbpcg_axis_if.tready)))); // TODO
    aluwb_axis_if.tready = wbrf_axis_if.tready;
    bruwb_axis_if.tready = wbrf_axis_if.tready && (!bruwb_tdata.taken || wbpcg_axis_if.tready);
    syswb_axis_if.tready = wbrf_axis_if.tready && (!syswb_tdata.use_new_pc || wbpcg_axis_if.tready);
    lsuwb_axis_if.tready = wbrf_axis_if.tready && (!lsuwb_tdata.trap || wbpcg_axis_if.tready);

    if (exwb_tdata.rf_data.id_data.sys_cmd_vld && trap) wbrf_tdata.ex_data.rf_data.id_data.rd = '0; // If a trap occurs, the destination register is not written
    wbrf_axis_if.tdata = wbrf_tdata;
    wbrf_axis_if.tvalid = exwb_axis_if.tvalid && exwb_axis_if.tready;

    // CSR
    wbcsr_wif.addr = exwb_tdata.rf_data.id_data.csr_addr;
    wbcsr_wif.data = syswb_tdata.csr_wdata;
    wbcsr_wif.pc = exwb_tdata.rf_data.id_data.if_data.pcg_data.pc;
    wbcsr_wif.cause = XLEN'(transform_cause(trap_cause)); // TODO: Support interrupts
    wbcsr_wif.trap = trap;
    wbcsr_wif.valid = syswb_axis_if.tvalid && (syswb_tdata.csr_update || trap); // TODO

    // Program Counter Generator
    wbpcg_axis_if.tdata = '0;
    case (1'b1)
      syswb_axis_if.tvalid && syswb_tdata.use_new_pc: wbpcg_axis_if.tdata = syswb_tdata.new_pc;
      bruwb_tdata.taken: wbpcg_axis_if.tdata = bruwb_tdata.new_pc;
      default: begin
      end
    endcase
    wbpcg_axis_if.tvalid = (exwb_axis_if.tvalid && exwb_axis_if.tready) && ((exwb_tdata.rf_data.id_data.bru_cmd_vld && bruwb_tdata.taken) || 
                                                                            (exwb_tdata.rf_data.id_data.sys_cmd_vld && syswb_tdata.use_new_pc)); // TODO
  end

endmodule
