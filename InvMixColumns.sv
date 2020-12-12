module InvMixColumns(
    input var logic [127:0],
    output var logic [127:0] o );
assign o[31:0] = invMixColumn(i[31:0]);
assign o[63:32] = invMixColumn(i[63:32]);
assign o[95:64] = invMixColumn(i[95:64]);
assign o[127:96] = invMixColumn(i[127:96]);

function automatic [31:0] invMixColumn(
    input var logic [31:0]i);
/*logic [31:0]o;
assign o[7:0] = m02(i[7:0]) ^ m03(i[15:8]) ^ i[23:16] ^ i[31:24];
assign o[15:8] = i[7:0] ^ m02(i[15:8]) ^ m03(i[23:16]) ^ i[31:24];
assign o[23:16] = i[7:0] ^ i[15:8] ^ m02(i[23:16]) ^ m03(i[31:24]);
assign o[32:24] = m03(i[7:0]) ^ i[15:8] ^ i[23:16] ^ m02(i[31:24]);*/
return {m0b(i[7:0]) ^ m0d(i[15:8]) ^ m09(i[23:16]) ^ m0e(i[31:24]),
        m0d(i[7:0]) ^ m09(i[15:8]) ^ m0e(i[23:16]) ^ m0b(i[31:24]),
        m09(i[7:0]) ^ m0e(i[15:8]) ^ m0b(i[23:16]) ^ m0d(i[31:24]),
        m0e(i[7:0]) ^ m0b(i[15:8]) ^ m0d(i[23:16]) ^ m09(i[31:24])};
endfunction

function automatic [7:0] m09(
    input var logic [7:0] in);
return {in[4] ^ in[7],
        in[3] ^ in[6] ^ in[7],
        in[2] ^ in[5] ^ in[6] ^ in[7],
        in[1] ^ in[4] ^ in[5] ^ in[6],
        in[0] ^ in[3] ^ in[5] ^ in[7],
        in[2] ^ in[6] ^ in[7],
        in[1] ^ in[5] ^ in[6],
        in[0] ^ in[5]};
endfunction

function automatic [7:0] m0b(
    input var logic [7:0] in);
return {in[4] ^ in[6] ^ in[7],
        in[3] ^ in[5] ^ in[6] ^ in[7],
        in[2] ^ in[4] ^ in[5] ^ in[6] ^ in[7],
        in[1] ^ in[3] ^ in[4] ^ in[5] ^ in[6] ^ in[7],
        in[0] ^ in[2] ^ in[3] ^ in[5],
        in[1] ^ in[2] ^ in[6] ^ in[7],
        in[0] ^ in[1] ^ in[5] ^ in[6] ^ in[7],
        in[0] ^ in[5] ^ in[7]};
endfunction

function automatic [7:0] m0d(
    input var logic [7:0] in);
return {in[4] ^ in[5] ^ in[7],
        in[3] ^ in[4] ^ in[6] ^ in[7],
        in[2] ^ in[3] ^ in[5] ^ in[6],
        in[1] ^ in[2] ^ in[4] ^ in[5],
        in[0] ^ in[1] ^ in[3] ^ in[5] ^ in[6] ^ in[7],
        in[0] ^ in[2] ^ in[6],
        in[1] ^ in[5] ^ in[7],
        in[0] ^ in[5] ^ in[6]};
endfunction

function automatic [7:0] m0e(
    input var logic [7:0] in);
return {in[4] ^ in[5] ^ in[6],
        in[3] ^ in[4] ^ in[5] ^ in[7],
        in[2] ^ in[3] ^ in[4] ^ in[6],
        in[1] ^ in[2] ^ in[3],
        in[0] ^ in[1] ^ in[2],
        in[0] ^ in[1] ^ in[6],
        in[0] ^ in[5],
        in[5] ^ in[6] ^ in[7]};
endfunction

function automatic [7:0] m0d(
    input var logic [7:0] in);
return {
};
endfunction

function automatic [7:0] m03(
    input var logic [7:0] m02in);
/*logic [7:0] m03out;
assign m03out[7] = m02in[6] ^ m02in[7];
assign m03out[6] = m02in[5] ^ m02in[6];
assign m03out[5] = m02in[4] ^ m02in[5];
assign m03out[4] = m02in[3] ^ m02in[4] ^ m02in[7];
assign m03out[3] = m02in[2] ^ m02in[3] ^ m02in[7];
assign m03out[2] = m02in[1] ^ m02in[2];
assign m03out[1] = m02in[0] ^ m02in[1] ^ m02in[7];
assign m03out[0] = m02in[0] ^ m02in[7];*/
return {m02in[6] ^ m02in[7], m02in[5] ^ m02in[6], m02in[4] ^ m02in[5], m02in[3] ^ m02in[4] ^ m02in[7], m02in[2] ^ m02in[3] ^ m02in[7], m02in[1] ^ m02in[2], m02in[0] ^ m02in[1] ^ m02in[7], m02in[0] ^ m02in[7]};
endfunction

endmodule
