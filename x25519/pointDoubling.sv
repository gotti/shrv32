module pointDoubling(
    input var logic [255:0] x1,
    input var logic [255:0] y1,
    input var logic [255:0] z1,
    output var logic [255:0] x2,
    output var logic [255:0] y2,
    output var logic [255:0] z2
);
wire [255:0]b;
assign b = modularAddition(x1,x2);
wire [255:0]c;
assign c = montgomeryModularMultiplication(x1,x1);
wire [255:0]d;
assign d = montgomeryModularMultiplication(y1,y1);
wire [255:0]e;
assign e = modularSubtraction(256'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed,modularAddition(c,d));
wire [255:0]f;
assign f = modularSubtraction(c,d);
wire [255:0]j;
assign j = modularSubtraction(f,b);//b is a
wire [255:0]k;
assign k = modularAddition(montgomeryModularMultiplication(b,b),e);
assign x2 = montgomeryModularMultiplication(j,k);
assign y2 = montgomeryModularMultiplication(f,e);
assign z2 = montgomeryModularMultiplication(f,j);

endmodule
