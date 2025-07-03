// SPDX-License-Identifier: MIT

// Instruction decoder module for RV32I
module decoder
  import riscv_pkg::*, offnariscv_pkg::*;
# (
  parameter FIFO_DEPTH = 9 // Greater than the block size should be better, because IFU can continue fetching instructions
) (
  input logic clk,
  input logic rst,

  axis_if.s ifid_axis_if, // From IFU
  axis_if.m idrf_axis_if, // To Register File

  input logic invalidate
);

  // Define types
  typedef struct packed {
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;
  } r_type_t;

  typedef struct packed {
    logic [11:0] imm_11_0;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;
  } i_type_t;

  typedef struct packed {
    logic [6:0] imm_11_5;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] imm_4_0;
    logic [6:0] opcode;
  } s_type_t;

  typedef struct packed {
    logic imm_12;
    logic [5:0] imm_10_5;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [3:0] imm_4_1;
    logic imm_11;
    logic [6:0] opcode;
  } b_type_t;

  typedef struct packed {
    logic [19:0] imm_31_12;
    logic [4:0] rd;
    logic [6:0] opcode;
  } u_type_t;

  typedef struct packed {
    logic imm_20;
    logic [9:0] imm_10_1;
    logic imm_11;
    logic [7:0] imm_19_12;
    logic [4:0] rd;
    logic [6:0] opcode;
  } j_type_t;

  typedef union packed {
    r_type_t r;
    i_type_t i;
    s_type_t s;
    b_type_t b;
    u_type_t u;
    j_type_t j;
  } inst_u;

  // Declare interfaces
  axis_if #(.TDATA_WIDTH($bits(idrf_tdata_t))) idrf_fifo_if ();
  axis_if #(.TDATA_WIDTH(5)) prev_rd_sif ();
  axis_if #(.TDATA_WIDTH(5)) prev_rd_mif ();

  // Declare wires
  ifid_tdata_t ifid_tdata;
  idrf_tdata_t idrf_tdata;
  inst_u inst;
  opcode_e opcode;
  logic rtype, itype, stype, btype, utype, jtype;

  always_comb begin
    ifid_tdata = ifid_axis_if.tdata;

    inst = ifid_tdata.inst;
    opcode = opcode_e'(inst[6:2]); // TODO: Check if inst[1:0]==2'b11
    rtype = opcode inside {AMO, OP};
    itype = opcode inside {LOAD, OP_IMM, JALR};
    stype = opcode inside {STORE};
    btype = opcode inside {BRANCH};
    utype = opcode inside {AUIPC, LUI};
    jtype = opcode inside {JAL};

    // Prepare operands
    idrf_tdata.rs1 = '0;
    idrf_tdata.rs2 = '0;
    idrf_tdata.rd = '0;
    idrf_tdata.immediate = '0;
    idrf_tdata.auipc = (opcode == AUIPC) ? ifid_tdata.pcg_data.pc : '0;
    unique case (1'b1)
      rtype: begin
        idrf_tdata.rs1 = inst.r.rs1;
        idrf_tdata.rs2 = inst.r.rs2;
        idrf_tdata.rd = inst.r.rd;
      end
      itype: begin
        idrf_tdata.rs1 = inst.i.rs1;
        idrf_tdata.rd = inst.i.rd;
        idrf_tdata.immediate = {{20{inst[31]}}, inst.i.imm_11_0};
      end
      stype: begin
        idrf_tdata.rs1 = inst.s.rs1;
        idrf_tdata.rs2 = inst.s.rs2;
        idrf_tdata.immediate = {{20{inst[31]}}, inst.s.imm_11_5, inst.s.imm_4_0};
      end
      btype: begin
        idrf_tdata.rs1 = inst.b.rs1;
        idrf_tdata.rs2 = inst.b.rs2;
        idrf_tdata.immediate = {{20{inst.b.imm_12}}, inst.b.imm_11, inst.b.imm_10_5, inst.b.imm_4_1, 1'b0};
      end
      utype: begin
        idrf_tdata.rd = inst.u.rd;
        idrf_tdata.immediate = {inst.u.imm_31_12, 12'b0};
      end
      jtype: begin
        idrf_tdata.rd = inst.j.rd;
        idrf_tdata.immediate = {{12{inst.j.imm_20}}, inst.j.imm_19_12, inst.j.imm_11, inst.j.imm_10_1, 1'b0};
      end
    endcase

    // Prepare commands
    idrf_tdata.alu_cmd_vld = opcode inside {OP_IMM, AUIPC, OP, LUI};
    idrf_tdata.bru_cmd_vld = opcode inside {BRANCH, JAL, JALR};
    idrf_tdata.sys_cmd_vld = opcode inside {SYSTEM};
    idrf_tdata.alu_cmd = ADD; // TODO
    idrf_tdata.bru_cmd = BRU_JAL; // TODO
    idrf_tdata.sys_cmd = CSRRW; // TODO
    unique case (1'b1)
      idrf_tdata.alu_cmd_vld: begin
        if (opcode inside {AUIPC, LUI}) begin
          idrf_tdata.alu_cmd = ADD;
        end else begin
          unique case (inst.r.funct3)
            3'b000: idrf_tdata.alu_cmd = (inst[30] && (opcode == OP)) ? SUB : ADD;
            3'b001: idrf_tdata.alu_cmd = SLL;
            3'b010: idrf_tdata.alu_cmd = SLT;
            3'b011: idrf_tdata.alu_cmd = SLTU;
            3'b100: idrf_tdata.alu_cmd = XOR;
            3'b101: idrf_tdata.alu_cmd = (inst[30]) ? SRA : SRL;
            3'b110: idrf_tdata.alu_cmd = OR;
            3'b111: idrf_tdata.alu_cmd = AND;
            default: begin
              // Invalid instruction, raise an exception
            end
          endcase
        end
      end
      idrf_tdata.bru_cmd_vld: begin
        unique case (opcode)
          BRANCH: unique case (inst.b.funct3)
            3'b000: idrf_tdata.bru_cmd = BRU_BEQ;
            3'b001: idrf_tdata.bru_cmd = BRU_BNE;
            3'b100: idrf_tdata.bru_cmd = BRU_BLT;
            3'b101: idrf_tdata.bru_cmd = BRU_BGE;
            3'b110: idrf_tdata.bru_cmd = BRU_BLTU;
            3'b111: idrf_tdata.bru_cmd = BRU_BGEU;
            default: begin
              // Invalid instruction, raise an exception
            end
          endcase
          JAL: idrf_tdata.bru_cmd = BRU_JAL;
          JALR: idrf_tdata.bru_cmd = BRU_JALR;
          default: begin
            // Invalid instruction, raise an exception
          end
        endcase
      end
      idrf_tdata.sys_cmd_vld: begin
        unique case (inst.r.funct3)
          3'b000: begin
            unique case (inst.r.funct7)
              7'b0000000: idrf_tdata.sys_cmd = (inst.r.rs2 == '0) ? ECALL : EBREAK;
              7'b0001000: idrf_tdata.sys_cmd = (inst.r.rs2 == 5'b00010) ? SRET : WFI;
              7'b0011000: idrf_tdata.sys_cmd = MRET;
              7'b0001001: begin
                idrf_tdata.sys_cmd = SFENCE_VMA;
                idrf_tdata.rs1 = inst.r.rs1;
                idrf_tdata.rs2 = inst.r.rs2;
              end
              default: begin
                // Invalid instruction, raise an exception
              end
            endcase
          end
          3'b001: begin
            idrf_tdata.sys_cmd = CSRRW;
            idrf_tdata.rs1 = inst.r.rs1;
            idrf_tdata.rd = inst.r.rd;
          end
          3'b010: begin
            idrf_tdata.sys_cmd = CSRRS;
            idrf_tdata.rs1 = inst.r.rs1;
            idrf_tdata.rd = inst.r.rd;
          end
          3'b011: begin
            idrf_tdata.sys_cmd = CSRRC;
            idrf_tdata.rs1 = inst.r.rs1;
            idrf_tdata.rd = inst.r.rd;
          end
          3'b101: begin
            idrf_tdata.sys_cmd = CSRRWI;
            idrf_tdata.immediate[4:0] = inst.r.rs1;
            idrf_tdata.rd = inst.r.rd;
          end
          3'b110: begin
            idrf_tdata.sys_cmd = CSRRSI;
            idrf_tdata.immediate[4:0] = inst.r.rs1;
            idrf_tdata.rd = inst.r.rd;
          end
          3'b111: begin
            idrf_tdata.sys_cmd = CSRRCI;
            idrf_tdata.immediate[4:0] = inst.r.rs1;
            idrf_tdata.rd = inst.r.rd;
          end
          default: begin
            // Invalid instruction, raise an exception
          end
        endcase
      end
    endcase
    idrf_tdata.csr_addr = inst[31:20];

    // Forwarding information
    idrf_tdata.fwd_rs1.rf = (idrf_tdata.rs1 != '0);
    idrf_tdata.fwd_rs1.ex = (idrf_tdata.rs1 != '0) && (prev_rd_mif.tvalid && (idrf_tdata.rs1 == prev_rd_mif.tdata));
    idrf_tdata.fwd_rs2.rf = (idrf_tdata.rs2 != '0);
    idrf_tdata.fwd_rs2.ex = (idrf_tdata.rs2 != '0) && (prev_rd_mif.tvalid && (idrf_tdata.rs2 == prev_rd_mif.tdata));

    idrf_tdata.if_data = ifid_tdata;

    // FIFO connection
    idrf_fifo_if.tdata = idrf_tdata;
    idrf_fifo_if.tvalid = ifid_axis_if.tvalid;
    ifid_axis_if.tready = idrf_fifo_if.tready;

    prev_rd_sif.tdata = idrf_tdata.rd;
    prev_rd_sif.tvalid = idrf_fifo_if.tvalid && idrf_fifo_if.tready && (idrf_tdata.rd != '0);
    prev_rd_mif.tready = ifid_axis_if.tvalid && ifid_axis_if.tready;
  end

  // Instantiate FIFO
  axis_sync_fifo # (
    .DEPTH(FIFO_DEPTH)
  ) idrf_fifo (
    .clk(clk),
    .rst(rst),
    .axis_mif(idrf_axis_if),
    .axis_sif(idrf_fifo_if),
    .invalidate(invalidate)
  );

  axis_slice prev_rd_slice (
    .clk(clk),
    .rst(rst),
    .axis_mif(prev_rd_mif),
    .axis_sif(prev_rd_sif),
    .invalidate(invalidate)
  );

endmodule
