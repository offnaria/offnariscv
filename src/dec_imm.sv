`include "defs.v"

// Immediate decoder

module dec_imm (
    input  logic[31:0] inst,
    input  logic[2:0]  inst_format,
    output logic[31:0] imm
);

always_comb begin
    case (inst_format)
        `I_TYPE: imm = {21{inst[31]}, inst[30:25], inst[24:21], inst[20]};
        `S_TYPE: imm = {21{inst[31]}, inst[30:25], inst[11:8],  inst[7]};
        `B_TYPE: imm = {20{inst[31]}, inst[7],     inst[30:25], inst[11:8], 1'b0};
        `U_TYPE: imm = {inst[31],     inst[30:20], inst[19:12], 12{1'b0}};
        `J_TYPE: imm = {12{inst[31]}, inst[19:12], inst[20],    inst[30:25], inst[24:21], 1'b0};
        default: imm = 32{1'b0};
    endcase
end

endmodule