module register(
    input var logic RST,
    input var logic CLK,
    input var logic CLK_DC,
    input var logic CLK_WB,
    input var logic [4:0]A1,
    input var logic [4:0]A2,
    input var logic [4:0]A3,
    input var logic [31:0]WB,
    input var logic WE,
    output var logic [31:0]RD1,
    output var logic [31:0]RD2,
    output var logic [7:0]LED,
    output var logic [255:0]RXD
);

logic [31:0] generalRegisters [31:0];
assign LED[7:2] = generalRegisters[31][7:2];

logic [31:0]d1;
logic [31:0]d2;
assign RD1 = d1;
assign RD2 = d2;
assign RXD = {generalRegisters[24],generalRegisters[25],generalRegisters[26],generalRegisters[27],generalRegisters[28],generalRegisters[29],generalRegisters[30],generalRegisters[31]};

logic [127:0]aes_plaintext;
logic [127:0]aes_secret;
logic [127:0]aes_cipher;
logic [127:0]aes_invplaintext;

always_ff @(posedge CLK_DC) begin
    d1 <= generalRegisters[A1];
    d2 <= generalRegisters[A2];
end

always_ff @(posedge CLK_WB or negedge RST) begin
    if (!RST) begin
        generalRegisters <= '{32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0};
        //R31 <= 0;
    end else if (WE==1'b1) begin
        if (A3==0) begin
            generalRegisters[0] <= 32'h0;
        end else begin
            generalRegisters[A3] <= WB;
        end
    end
end

endmodule
