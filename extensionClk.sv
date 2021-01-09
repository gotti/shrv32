module extensionClk(
    input var logic CLK,
    input var logic [2:0] extensionModuleSelect,
    output var logic clockAESEncrypt,
    output var logic clockAESDecrypt );
assign clockAESEncrypt = extensionModuleSelect==3'd1 ? CLK : 1'b0;
assign clockAESDecrypt = extensionModuleSelect==3'd2 ? CLK : 1'b0;
endmodule
