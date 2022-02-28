`include "defs.v"
`include "opcodes.v"
`include "funct3s.v"

// Instruction decoder

module dec_inst (
    input  logic[31:0] inst,

    output logic[4:0]  rs1,
    output logic[4:0]  rs2,
    output logic[4:0]  rd,

    output logic[2:0]  inst_format,

    output logic[0:0]  is_addi
    output logic[0:0]  is_add,
);

wire[6:0] opcode = inst[6:0];
wire[2:0] funct3 = inst[14:12];

assign rs1 = inst[19:15];
assign rs2 = inst[24:20];
assign rd  = inst[11:7];

assign is_addi = (opcode=={`OP-IMM, 2'b11}) && (funct3==`ADDI);
assign is_add  = (opcode=={`OP, 2'b11}) && (funct3==`ADD);

always_comb begin
    if (is_add) begin
        inst_format = `R_TYPE;
    end else if (is_addi) begin
        inst_format = `I_TYPE;
    end /*else if () begin
        inst_format = `S_TYPE;
    end else if () begin
        inst_format = `B_TYPE;
    end else if () begin
        inst_format = `U_TYPE;
    end else if () begin
        inst_format = `J_TYPE;
    end 
    */
end

endmodule