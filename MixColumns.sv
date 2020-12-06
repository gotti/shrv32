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
return {m03(i[7:0]) ^ i[15:8] ^ i[23:16] ^ m02(i[31:24]), i[7:0] ^ i[15:8] ^ m02(i[23:16]) ^ m03(i[31:24]), i[7:0] ^ m02(i[15:8]) ^ m03(i[23:16]) ^ i[31:24], m02(i[7:0]) ^ m03(i[15:8]) ^ i[23:16] ^ i[31:24]};
endfunction

function automatic [7:0] m02(
    input var logic [7:0] m02in);
/*logic [7:0] m02out;
assign m02out[7:5] = m02in[6:4];
assign m02out[4] = m02in[3] ^ m02in[7];
assign m02out[3] = m02in[2] ^ m02in[7];
assign m02out[2] = m02in[1];
assign m02out[1] = m02in[0] ^ m02in[7];
assign m02out[0] = m02in[7];*/
return {m02in[6:4], m02in[3] ^ m02in[7], m02in[2] ^ m02in[7], m02in[1], m02in[0] ^ m02in[7], m02in[7]};
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
