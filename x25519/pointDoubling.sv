module pointDouble(
    input var logic [255:0] x1,
    input var logic [255:0] y1,
    input var logic [255:0] z1,
    output var logic [255:0] x2,
    output var logic [255:0] y2,
    output var logic [255:0] z2
);
wire b;
assign b = x1 + x2;
wire c;
assign c = x1*x1;
wire d;
assign d = y1*y1;
wire e;
assign e = 256'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed - (c + d);
wire f;
assign f = c - d;
wire j;
assign j = f - b;//b is a
wire k;
assign k = b*b + e;
assign x2 = j*k;
assign y2 = f*e;
assign z2 = f*j;

endmodule
