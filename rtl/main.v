`define INSTR_WIDTH_ 32
`define FUNCT7_WIDTH  7
`define RS2_WIDTH___  5
`define RS1_WIDTH___  5
`define FUNCT3_WIDTH  3
`define RD_WIDTH____  5
`define OPCODE_WIDTH  7
`define XLEN________ 32

module m_proc (
    input wire w_clk,
    input wire w_rstn,
    output wire [31:0] w_rslt
);

    reg [31:0] r_pc = 0;

    always @(posedge w_clk) begin
        if (!w_rstn) begin
            r_pc <= 0;
        end else begin
            r_pc <= r_pc + 4;
        end
    end
    
endmodule