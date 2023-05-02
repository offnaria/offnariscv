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