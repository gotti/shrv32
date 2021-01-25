
module rom(
    input var logic CLK,
    input var logic [31:0]A,
    output var logic [31:0]RD );

logic [4:0]counter=5'b0;
logic [31:0]insts[255:0];
initial $readmemh("./bin",insts);
always_ff @(posedge CLK) begin
    RD <= insts[A>>2];
    /*case (A>>2)
            /*
        32'h0: RD<=32'h04300193;
        32'h1: RD<=32'h00200113;
        32'h2: RD<=32'h20000083;
        32'h3: RD<=32'h0020f093;
        32'h4: RD<=32'hfe208ce3;
        32'h5: RD<=32'h203000a3;
        32'h6: RD<=32'h00000067;*/
        /*32'h0: RD<=32'h04300193;
        32'h1: RD<=32'h203000a3;
        32'h2: RD<=32'h20000083;
        32'h3: RD<=32'h0010f093;
        32'h4: RD<=32'h00100113;
        32'h5: RD<=32'hfe209ae3;
        32'h6: RD<=32'h20200183;
        32'h7: RD<=32'h20000083;
        32'h8: RD<=32'h0020f093;
        32'h9: RD<=32'hfe208ae3;
        32'ha: RD<=32'h203000a3;
        32'hb: RD<=32'h00800067;
/*        32'h0: RD<=32'h00100f93;
        32'h1: RD<=32'h0000408b;
        32'h2: RD<=32'h01ffcfb3;
        32'h3: RD<=32'h0000410b;
        32'h4: RD<=32'h4020900b;
        32'h5: RD<=32'h4020218b;
        32'h6: RD<=32'h00003f8b;
        32'h7: RD<=32'h04400b13;
        32'h8: RD<=32'h216000a3;
//        32'h9: RD<=32'hff5ff06f;
//        32'h9: RD<=32'h00000a93;
        default: RD<=32'h0;
    endcase*/
    //32'b 1000 0101 | 0000 | 0111
    //todo
end
endmodule
