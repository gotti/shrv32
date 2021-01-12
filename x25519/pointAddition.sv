module pointAddition(
    input var logic clock,
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
/*
logic [3:0]counter;
logic [3:0]incCounter;
assign incCounter = counter + 4'd1;

logic [255:0]mmmaInX;
logic [255:0]mmmaInY;
logic [255:0]mmmaOut;
montgomeryModularMultiplication mmma(
    .x(mmmaInX),
    .y(mmmaInY),
    .o(mmmaOut)
);
always_ff @(posedge clock) begin
    
end*/

wire [255:0]b;
assign b = montgomeryModularMultiplication(z2,z2);
wire [255:0]c;
assign x = montgomeryModularMultiplication(x1,x2);
wire [255:0]d;
assign d = montgomeryModularMultiplication(y1,y2);
wire [255:0]e;
assign e = montgomeryModularMultiplication(dd,montgomeryModularMultiplication(c,d));
wire [255:0]f;
assign f = modularSubtraction(b,e);
wire [255:0]g;
assign g = modularAddition(b,e);
wire [255:0]h;
assign h = montgomeryModularMultiplication(modularAddition(x1,y1),modularAddition(x2,y2));
wire [255:0]i;
assign i = modularSubtraction(h,modularAddition(c,d));
wire [255:0]j;
assign j = montgomeryModularMultiplication(f,z2);
wire [255:0]k;
assign k = montgomeryModularMultiplication(g,z2);
assign x3 = montgomeryModularMultiplication(f,z2);
assign y3 = montgomeryModularMultiplication(k,modularAddition(c,d));
assign z3 = montgomeryModularMultiplication(f,g);
endmodule
