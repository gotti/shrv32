module pointAddition(
    input var logic [255:0] x1,
    input var logic [255:0] y1,
    input var logic [255:0] z1,
    input var logic [255:0] x2,
    input var logic [255:0] y2,
    input var logic [255:0] z2,
    output var logic [255:0] x3,
    output var logic [255:0] y3,
    output var logic [255:0] z3
);
parameter dd = 256'd7237005577332262213973186563042994240857116359379907606001950938285454250989;
wire b;
assign b = montgomeryModularMultiplication(z2,z2);
wire c;
assign x = montgomeryModularMultiplication(x1,x2);
wire d;
assign d = montgomeryModularMultiplication(y1,y2);
wire e;
assign e = montgomeryModularMultiplication(dd,montgomeryModularMultiplication(c,d));
wire f;
assign f = modularSubtraction(b,e);
wire g;
assign g = modularAddition(b,e);
wire h;
assign h = (x1+y1)*(x2+y2);
wire i;
assign i = h-(c+d);
wire j;
assign j = f*z2;
wire k;
assign k = g*z2;
assign x3 = f*z2;
assign y3 = k*(c+d);
assign z3=f*g;
endmodule
