// SPDX-License-Identifier: MIT

// Branch Resolution Unit
module bru
  import offnariscv_pkg::*;
(
  input logic clk,
  input logic rst,

  axis_if.s rfbru_axis_if, // From Dispatcher
  axis_if.m bruwb_axis_if, // To Write Back

  input logic invalidate
);

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(bruwb_tdata_t))) bruwb_slice_if ();

  // Declare wires
  rfbru_tdata_t rfbru_tdata;
  bruwb_tdata_t bruwb_tdata;

  always_comb begin
    rfbru_tdata = rfbru_axis_if.tdata;

    bruwb_tdata.result = rfbru_tdata.this_pc + XLEN'(4);
    bruwb_tdata.new_pc = rfbru_tdata.this_pc + rfbru_tdata.offset;
    bruwb_tdata.taken = 1'b0;

    unique case (rfbru_tdata.cmd)
      BRU_JAL: begin
        bruwb_tdata.taken = 1'b1;
      end
      BRU_JALR: begin
        bruwb_tdata.new_pc = rfbru_tdata.operands.op1 + rfbru_tdata.offset;
        bruwb_tdata.taken = 1'b1;
      end
      BRU_BEQ: begin

      end
      BRU_BNE: begin

      end
      BRU_BLT: begin

      end
      BRU_BGE: begin

      end
      BRU_BLTU: begin

      end
      BRU_BGEU: begin

      end
    endcase

    // Slice connection
    bruwb_slice_if.tdata = bruwb_tdata;
    bruwb_slice_if.tvalid = rfbru_axis_if.tvalid;
    rfbru_axis_if.tready = bruwb_slice_if.tready;
  end

  always_ff @(posedge clk) if (rfbru_axis_if.tvalid && bruwb_tdata.taken) $write("BRU: New PC = %08h, cmd=%s\n", bruwb_tdata.new_pc, rfbru_tdata.cmd.name());

  // Instantiate slice
  axis_slice bruwb_slice (
    .clk(clk),
    .rst(rst),
    .axis_mif(bruwb_axis_if),
    .axis_sif(bruwb_slice_if),
    .invalidate(invalidate)
  );

endmodule
