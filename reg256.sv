module reg256(
    input var logic RST,
    input var logic CLK,
    input var logic CLK_DC,
    input var logic CLK_WB,
    input var logic [4:0]A1,
    input var logic [4:0]A2,
    input var logic [4:0]A3,
    input var logic [255:0]WB,
    input var logic WE,
    output var logic [255:0]RD1,
    output var logic [255:0]RD2
);
logic [255:0] generalRegisters [5:0];

always_ff @(posedge CLK_DC) begin
    RD1 <= generalRegisters[A1[2:0]];
    RD2 <= generalRegisters[A2[2:0]];
end

always_ff @(posedge CLK_WB or negedge RST) begin
    if (!RST) begin
        generalRegisters <= '{256'h0, 256'h10, 256'h0, 256'h0, 256'h0, 256'h0};
        //R31 <= 0;
    end else if (WE==1'b1) begin
        generalRegisters[A3[2:0]] <= WB;
    end
end

endmodule
