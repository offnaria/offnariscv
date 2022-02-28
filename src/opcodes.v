//`define LOAD      5'b00000
//`define LOAD-FP   5'b00001
//`define custom-0  5'b00010
//`define MISC-MEM  5'b00011
`define OP-IMM    5'b00100
//`define AUIPC     5'b00101
//`define OP-IMM-32 5'b00110

//`define STORE     5'b01000
//`define STORE-FP  5'b01001
//`define custom-1  5'b01010
//`define AMO       5'b01011
`define OP        5'b01100
//`define LUI       5'b01101
//`define OP-32     5'b01110

//`define MADD      5'b10000
//`define MSUB      5'b10001
//`define NMSUB     5'b10010
//`define NMADD     5'b10011
//`define OP-FP     5'b10100
//`define reserved  5'b10101
//`define custom-2  5'b10110

//`define BRANCH    5'b11000
//`define JALR      5'b11001
//`define reserved  5'b11010
//`define JAL       5'b11011
//`define SYSTEM    5'b11100
//`define reserved  5'b11101
//`define custom-3  5'b11110