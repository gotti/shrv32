module aes_inv(
    input var logic clock,
    input var logic [127:0] cipher,
    input var logic [127:0] secret,
    output var logic [127:0] plaintext );
logic [3:0]counter = 4'b0;
logic [127:0]secretReg;
logic [127:0]dataReg;

endmodule
