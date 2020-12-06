module rom(
    input var logic CLK,
    input var logic [31:0]A,
    output var logic [31:0]RD );

logic [4:0]counter=5'b0;
logic [31:0]insts[31:0];
always_ff @(posedge CLK) begin
    case (A>>2)
        32'h0: RD<=32'h00100093;
        32'h1: RD<=32'h00100113;
        32'h2: RD<=32'h002081b3;
        32'h3: RD<=32'h00008133;
        32'h4: RD<=32'h000180b3;
        32'h5: RD<=32'hff5ff06f;
        default: RD<=32'h0;
    endcase
    //32'b 1000 0101 | 0000 | 0111
    //todo
end
endmodule