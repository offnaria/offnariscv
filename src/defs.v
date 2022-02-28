`define XLEN   32 // the width of an integer register
`define IALIGN 32 // the instruction-address alignment constraint
`define ILEN   32 // the maximum instruction length

`define R_TYPE 0
`define I_TYPE 1 // imm = {21{inst[31]}, inst[30:25], inst[24:21], inst[20]}
`define S_TYPE 2 // imm = {21{inst[31]}, inst[30:25], inst[11:8],  inst[7]}
`define B_TYPE 3 // imm = {20{inst[31]}, inst[7],     inst[30:25], inst[11:8], 1'b0}
`define U_TYPE 4 // imm = {inst[31],     inst[30:20], inst[19:12], 12{1'b0}}
`define J_TYPE 5 // imm = {12{inst[31]}, inst[19:12], inst[20],    inst[30:25], inst[24:21], 1'b0}