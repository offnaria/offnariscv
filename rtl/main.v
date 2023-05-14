`define ILEN         32
`define XLEN         32

`define IMEM_ENTRY 4096

/* Instruction format                              */
/* {funct7, rs2, rs1, funct3, rd, opcode} (R-Type) */
`define FUNCT7_WIDTH  7
`define RS2_WIDTH     5
`define RS1_WIDTH     5
`define FUNCT3_WIDTH  3
`define RD_WIDTH      5
`define OPCODE_WIDTH  7
`define IMMSRC_WIDTH  (`FUNCT7_WIDTH+`RS2_WIDTH+`RS1_WIDTH+`FUNCT3_WIDTH+`RD_WIDTH)

module m_proc (
    input wire w_clk,
    input wire w_rstn,
    output wire [31:0] w_rslt
);

    reg [`XLEN-1:0] r_pc = 0;

    always @(posedge w_clk) begin
        if (!w_rstn) begin
            r_pc <= 0;
        end else begin
            r_pc <= r_pc + 4;
        end
    end

endmodule

module m_immgen (
    input wire [`IMMSRC_WIDTH-1:0] w_immsrc,

    output wire [`XLEN-1:0]        w_I_imm,
    output wire [`XLEN-1:0]        w_S_imm,
    output wire [`XLEN-1:0]        w_B_imm,
    output wire [`XLEN-1:0]        w_U_imm,
    output wire [`XLEN-1:0]        w_J_imm 
);

    wire                                w_inst_31    = w_immsrc[(31-`OPCODE_WIDTH)];
    wire [`FUNCT7_WIDTH-2:0]            w_inst_30_25 = w_immsrc[(30-`OPCODE_WIDTH):(25-`OPCODE_WIDTH)];
    wire [`RS2_WIDTH-2:0]               w_inst_24_21 = w_immsrc[(24-`OPCODE_WIDTH):(21-`OPCODE_WIDTH)];
    wire                                w_inst_20    = w_immsrc[(20-`OPCODE_WIDTH)];
    wire [`RS1_WIDTH+`FUNCT3_WIDTH-1:0] w_inst_19_12 = w_immsrc[(19-`OPCODE_WIDTH):(12-`OPCODE_WIDTH)];
    wire [`RD_WIDTH-2:0]                w_inst_11__8 = w_immsrc[(11-`OPCODE_WIDTH):( 8-`OPCODE_WIDTH)];
    wire                                w_inst__7    = w_immsrc[( 7-`OPCODE_WIDTH)];

    assign w_I_imm = {{(`XLEN-11){w_inst_31}}, w_inst_30_25, w_inst_24_21, w_inst_20};
    assign w_S_imm = {{(`XLEN-11){w_inst_31}}, w_inst_30_25, w_inst_11__8, w_inst__7};
    assign w_B_imm = {{(`XLEN-12){w_inst_31}}, w_inst__7,    w_inst_30_25, w_inst_11__8, 1'b0};
    assign w_U_imm = {{(`XLEN-31){w_inst_31}}, w_inst_30_25, w_inst_24_21, w_inst_20,    w_inst_19_12, 12'h000};
    assign w_J_imm = {{(`XLEN-20){w_inst_31}}, w_inst_19_12, w_inst_20,    w_inst_30_25, w_inst_24_21, 1'b0};

endmodule

module m_instparse (
    input wire [`ILEN-1:0] w_inst,

    output wire [`FUNCT7_WIDTH-1:0] w_funct7,
    output wire [`RS2_WIDTH-1:0]    w_rs2,
    output wire [`RS1_WIDTH-1:0]    w_rs1,
    output wire [`FUNCT3_WIDTH-1:0] w_funct3,
    output wire [`RD_WIDTH-1:0]     w_rd,
    output wire [`OPCODE_WIDTH-1:0] w_opcode
);

    assign w_funct7 = w_inst[25+:`FUNCT7_WIDTH];
    assign w_rs2    = w_inst[20+:`RS2_WIDTH];
    assign w_rs1    = w_inst[15+:`RS1_WIDTH];
    assign w_funct3 = w_inst[12+:`FUNCT3_WIDTH];
    assign w_rd     = w_inst[ 7+:`RD_WIDTH];
    assign w_opcode = w_inst[ 0+:`OPCODE_WIDTH];

endmodule

module m_asyncrom #(
    parameter DATA_WIDTH =   32,
    parameter ENTRIES    = 4096
) (
    input wire [$clog2(ENTRIES)-1:0] w_addr,
    
    output wire [DATA_WIDTH-1:0] w_dout
);

    reg [DATA_WIDTH-1:0] cm_ram [0:ENTRIES-1];
    assign w_dout = cm_ram[w_addr];

    initial begin
        cm_ram[0]={7'd0, 5'd0, 5'd0, 3'd0, 5'd0, 7'b0110011}; // add  x0, x0, x0
        cm_ram[1]={12'h008,    5'd0, 3'd7, 5'd4, 7'b0010011}; // addi x4, x0,  8
        cm_ram[2]={12'hffe,    5'd0, 3'd7, 5'd5, 7'b0010011}; // addi x5, x0, -2
        cm_ram[3]={7'd0, 5'd5, 5'd4, 3'd0, 5'd6, 7'b0110011}; // add  x6, x4, x5
        cm_ram[4]={7'd0, 5'd0, 5'd0, 3'd0, 5'd0, 7'b0110011}; // add  x0, x0, x0
    end

endmodule

module m_regfile #(
    parameter ENTRIES    = 32
) (
    input wire w_clk,
    input wire [`RS1_WIDTH-1:0] w_rs1,
    input wire [`RS2_WIDTH-1:0] w_rs2,
    input wire [`RD_WIDTH-1:0]  w_rd,
    input wire                  w_we,
    input wire [`XLEN-1:0]      w_din,

    output wire [`XLEN-1:0]     w_rrs1,
    output wire [`XLEN-1:0]     w_rrs2
);

    reg [`XLEN-1:0] r_rf [0:ENTRIES-1];
    assign w_rrs1 = r_rf[w_rs1]; // Note: x0 == 0 must be guaranteed outside of this module.
    assign w_rrs2 = r_rf[w_rs2];

    always @(posedge w_clk) begin
        if (w_we) begin
            r_rf[w_rd] <= w_din;
        end
    end

endmodule

module m_alu (
    input wire [`XLEN-1:0] w_in1,
    input wire [`XLEN-1:0] w_in2,
    
    output wire [`XLEN-1:0] w_ADD_rslt,
    output wire [`XLEN-1:0] w_SUB_rslt,
    output wire [`XLEN-1:0] w_SLL_rslt,
    output wire [`XLEN-1:0] w_SLT_rslt,
    output wire [`XLEN-1:0] w_SLTU_rslt,
    output wire [`XLEN-1:0] w_XOR_rslt,
    output wire [`XLEN-1:0] w_SRL_rslt,
    output wire [`XLEN-1:0] w_SRA_rslt,
    output wire [`XLEN-1:0] w_OR_rslt,
    output wire [`XLEN-1:0] w_AND_rslt
);

    assign w_ADD_rslt  = w_in1 + w_in2;
    assign w_SUB_rslt  = w_in1 - w_in2;
    assign w_SLL_rslt  = w_in1 << w_in2;
    assign w_SLT_rslt  = {31'b0, $signed(w_in1) < $signed(w_in2)};
    assign w_SLTU_rslt = {31'b0, w_in1 < w_in2};
    assign w_XOR_rslt  = w_in1 ^ w_in2;
    assign w_SRL_rslt  = w_in1 >> w_in2;
    assign w_SRA_rslt  = $signed(w_in1) >>> w_in2;
    assign w_OR_rslt   = w_in1 | w_in2;
    assign w_AND_rslt  = w_in1 & w_in2;

endmodule

module m_typegen (
    input wire [`OPCODE_WIDTH-3:0] w_opcode5,

    output wire w_is_Itype,
    output wire w_is_Stype,
    output wire w_is_Btype,
    output wire w_is_Utype,
    output wire w_is_Jtype
);

    localparam LOAD      = 5'b00000;
    localparam LOAD_FP   = 5'b00001;
    localparam custom_0  = 5'b00010;
    localparam MISC_MEM  = 5'b00011;
    localparam OP_IMM    = 5'b00100;
    localparam AUIPC     = 5'b00101;
    localparam OP_IMM_32 = 5'b00110;
    localparam STORE     = 5'b01000;
    localparam STORE_FP  = 5'b01001;
    localparam custom_1  = 5'b01010;
    localparam AMO       = 5'b01011;
    localparam OP        = 5'b01100;
    localparam LUI       = 5'b01101;
    localparam OP_32     = 5'b01110;
    localparam MADD      = 5'b10000;
    localparam MSUB      = 5'b10001;
    localparam NMSUB     = 5'b10010;
    localparam NMADD     = 5'b10011;
    localparam OP_FP     = 5'b10100;
//    localparam reserved  = 5'b10101;
    localparam custom_2  = 5'b10110;
    localparam BRANCH    = 5'b11000;
    localparam JALR      = 5'b11001;
//    localparam reserved  = 5'b11010;
    localparam JAL       = 5'b11011;
    localparam SYSTEM    = 5'b11100;
//    localparam reserved  = 5'b11101;
    localparam custom_3  = 5'b11110;

    assign w_is_Itype = (w_opcode5==LOAD) | (w_opcode5==MISC_MEM) | (w_opcode5==OP_IMM) | (w_opcode5==JALR) | (w_opcode5==SYSTEM);
    assign w_is_Stype = (w_opcode5==STORE);
    assign w_is_Btype = (w_opcode5==BRANCH);
    assign w_is_Utype = (w_opcode5==AUIPC) | (w_opcode5==LUI);
    assign w_is_Jtype = (w_opcode5==JAL);

endmodule