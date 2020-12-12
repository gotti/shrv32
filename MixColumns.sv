module MixColumns(
    input var logic [127:0] i,
    output var logic [127:0] o );
assign o[31:0] = mixColumn(i[31:0]);
assign o[63:32] = mixColumn(i[63:32]);
assign o[95:64] = mixColumn(i[95:64]);
assign o[127:96] = mixColumn(i[127:96]);

function automatic [31:0] mixColumn(
    input var logic [31:0]i);
/*logic [31:0]o;
assign o[7:0] = m02(i[7:0]) ^ m03(i[15:8]) ^ i[23:16] ^ i[31:24];
assign o[15:8] = i[7:0] ^ m02(i[15:8]) ^ m03(i[23:16]) ^ i[31:24];
assign o[23:16] = i[7:0] ^ i[15:8] ^ m02(i[23:16]) ^ m03(i[31:24]);
assign o[32:24] = m03(i[7:0]) ^ i[15:8] ^ i[23:16] ^ m02(i[31:24]);*/
return {m03(i[7:0]) ^ i[15:8] ^ i[23:16] ^ m02(i[31:24]),
        i[7:0] ^ i[15:8] ^ m02(i[23:16]) ^ m03(i[31:24]),
        i[7:0] ^ m02(i[15:8]) ^ m03(i[23:16]) ^ i[31:24],
        m02(i[7:0]) ^ m03(i[15:8]) ^ i[23:16] ^ i[31:24]};
endfunction

function automatic [7:0] m02(
    input var logic [7:0] in);
/*logic [7:0] m02out;
assign m02out[7:5] = in[6:4];
assign m02out[4] = in[3] ^ in[7];
assign m02out[3] = in[2] ^ in[7];
assign m02out[2] = in[1];
assign m02out[1] = in[0] ^ in[7];
assign m02out[0] = in[7];*/
return {in[6:4], in[3] ^ in[7], in[2] ^ in[7], in[1], in[0] ^ in[7], in[7]};
endfunction

function automatic [7:0] m03(
    input var logic [7:0] in);
/*logic [7:0] m03out;
assign m03out[7] = in[6] ^ in[7];
assign m03out[6] = in[5] ^ in[6];
assign m03out[5] = in[4] ^ in[5];
assign m03out[4] = in[3] ^ in[4] ^ in[7];
assign m03out[3] = in[2] ^ in[3] ^ in[7];
assign m03out[2] = in[1] ^ in[2];
assign m03out[1] = in[0] ^ in[1] ^ in[7];
assign m03out[0] = in[0] ^ in[7];*/
return {in[6] ^ in[7], in[5] ^ in[6], in[4] ^ in[5], in[3] ^ in[4] ^ in[7], in[2] ^ in[3] ^ in[7], in[1] ^ in[2], in[0] ^ in[1] ^ in[7], in[0] ^ in[7]};
endfunction

endmodule
