module csr(
    input var logic RST,
    input var logic CLK_DC,
    input var logic CLK_WB,
    input var logic WE,
    input var logic [31:0]W,
    output var logic [31:0]R);
logic [31:0]csr;
always_ff @(posedge CLK_DC) begin
    R <= csr;
end
always_ff @(posedge CLK_WB) begin
    if (WE==1'b1) begin
        csr <= W;
    end
end
endmodule
