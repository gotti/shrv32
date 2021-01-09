function automatic [255:0] modularAddition(
        input var logic [255:0]a,
        input var logic [255:0]b
);
parameter p = 7237005577332262213973186563042994240857116359379907606001950938285454250989;
logic [256:0]c;
c = {1'b0,a}+{1'b0,b}-{1'b0,p};
return c[256]==1'b1 ? c[255:0] : a+b;
endfunction

function automatic [255:0] modularSubtraction(
        input var logic [255:0]a,
        input var logic [255:0]b
);
parameter p = 7237005577332262213973186563042994240857116359379907606001950938285454250989;
logic [256:0] c;
c = {1'b0,a}-{1'b0,b};
return c[256]==1'b1 ? a-b+p : c;
endfunction

function automatic [255:0] montgomeryReduction(
        input var logic [511:0]x
);
parameter N = 512'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed;
parameter INVN = 512'd21330121701610878104342023554231983025602365596302209165163239159352418617883;
parameter R = {256'd0,1'b1,255'b0};
parameter RU = 512'd255;
logic [511:0]out;
out = x+(x*INVN&(R-1))*N >> RU;
return out[255:0];
endfunction
function automatic [255:0] montgomeryModularMultiplication(
        input var logic [255:0]x,
        input var logic [255:0]y
);
parameter R2 = 512'd361;
return montgomeryReduction({256'b0,montgomeryReduction({256'b0,montgomeryReduction({256'b0,x}*R2)}*{256'b0,montgomeryReduction({256'b0,y}*R2)})});
endfunction
