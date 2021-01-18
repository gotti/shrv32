/* verilator lint_off UNOPTFLAT */
module aes(
    input var logic clock,
    input var logic [127:0] plaintext,
    input var logic [127:0] secret,
    input var logic we,
    input var logic [127:0] nextRoundKey,
    output var logic [3:0] keyCounter,
    output var logic [127:0] currentRoundKey,
    output var logic [127:0] cipher,
    output var logic busy
);

logic [3:0]counter, nextCounter;
//function [255:0] sbox(input [255:0] sboxinput);
//endfunction
logic [127:0]secretReg;
logic [127:0]dataReg, nextDataReg;

logic [127:0]subBytesIn;
logic [127:0]subBytesOut;
subBytes subBytes(
    .i(subBytesIn),
    .o(subBytesOut) );

logic [127:0]shiftRowsIn;
logic [127:0]shiftRowsOut;
shiftRows shiftRows(
    .i(shiftRowsIn),
    .o(shiftRowsOut) );

logic [127:0]mixColumnsIn;
logic [127:0]mixColumnsOut;
MixColumns mixColumns(
    .i(mixColumnsIn),
    .o(mixColumnsOut) );

logic [127:0]roundOut;
logic [127:0]out;
assign subBytesIn = dataReg;
assign shiftRowsIn = subBytesOut;
assign mixColumnsIn = shiftRowsOut;
assign out = counter==4'ha ? shiftRowsOut : mixColumnsOut;
assign roundOut = out ^ roundKey; //TODO
//TODO
logic [127:0]roundKey;
assign currentRoundKey = counter==4'd0 ? secret : roundKey;

typedef enum{
    stateIdle,
    stateCalc
} stateType;
stateType state, nextState;
assign cipher = dataReg;
assign keyCounter = counter;
always_comb begin
    busy = 0;
    nextCounter = 0;
    nextState = state;
    nextDataReg = dataReg;
    if(state == stateIdle && we) begin
        nextState = stateCalc;
        busy = 1;
        nextCounter = 0;
    end else if (state == stateCalc) begin
        busy = 1;
        if(counter > 10) begin
            nextCounter = 0;
            nextState = stateIdle;
        end else begin
            nextCounter = counter +1;
            nextDataReg = counter==4'b0 ? plaintext^secret : roundOut;
        end
    end else begin
    end
end

always_ff @(posedge clock) begin
    state <= nextState;
    counter <= nextCounter;
    roundKey <= nextRoundKey;
    dataReg <= nextDataReg;
end

function automatic [3:0][3:0][7:0] bytes2matrix(
    input var logic [127:0]i );
    return '{'{i[31:24], i[63:56], i[95:88], i[127:120]},
             '{i[23:16], i[55:48], i[87:80], i[119:112]},
             '{i[15:8],  i[47:40], i[79:72], i[111:104]},
             '{i[7:0],   i[39:32], i[71:64], i[103:96]}
            };
endfunction

endmodule

function automatic [7:0] sbox(
    input var logic [7:0]i );
logic [7:0] sboxTable [255:0] = '{8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5, 8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76, 8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0, 8'had, 8'hd4, 8'ha2, 8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0, 8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc, 8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15, 8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a, 8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75, 8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0, 8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84, 8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b, 8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58, 8'hcf, 8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85, 8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8, 8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d, 8'h38, 8'hf5, 8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2, 8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17, 8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64, 8'h5d, 8'h19, 8'h73, 8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88, 8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb, 8'he0, 8'h32, 8'h3a, 8'h0a, 8'h49, 8'h06, 8'h24, 8'h5c, 8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79, 8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9, 8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08, 8'hba, 8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4, 8'hc6, 8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a, 8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6, 8'h0e, 8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e, 8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94, 8'h9b, 8'h1e, 8'h87, 8'he9, 8'hce, 8'h55, 8'h28, 8'hdf, 8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf, 8'he6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16 };
return sboxTable[8'hff - i];
endfunction

module keyExpand( input var logic [127:0] roundKey, input var logic [3:0] counter,
    output var logic[127:0] nextRoundKey );
logic [7:0] s [3:0];
logic [7:0] rcon [10:0] = '{8'h0, 8'h1, 8'h2, 8'h4, 8'h8, 8'h10, 8'h20, 8'h40, 8'h80, 8'h1b, 8'h36 };
assign s[0] = sbox(roundKey[111:104]);
assign s[1] = sbox(roundKey[119:112]);
assign s[2] = sbox(roundKey[127:120]);
assign s[3] = sbox(roundKey[103:96]);

assign nextRoundKey[7:0]  = roundKey[7:0]    ^ s[0] ^ rcon[9-counter];
assign nextRoundKey[15:8] = roundKey[15:8]   ^ s[1] ^ rcon[10];
assign nextRoundKey[23:16] = roundKey[23:16] ^ s[2] ^ rcon[10];
assign nextRoundKey[31:24] = roundKey[31:24] ^ s[3] ^ rcon[10];

assign nextRoundKey[39:32] = roundKey[39:32] ^ nextRoundKey[7:0];
assign nextRoundKey[47:40] = roundKey[47:40] ^ nextRoundKey[15:8];
assign nextRoundKey[55:48] = roundKey[55:48] ^ nextRoundKey[23:16];
assign nextRoundKey[63:56] = roundKey[63:56] ^ nextRoundKey[31:24];

assign nextRoundKey[71:64] = roundKey[71:64] ^ nextRoundKey[39:32];
assign nextRoundKey[79:72] = roundKey[79:72] ^ nextRoundKey[47:40];
assign nextRoundKey[87:80] = roundKey[87:80] ^ nextRoundKey[55:48];
assign nextRoundKey[95:88] = roundKey[95:88] ^ nextRoundKey[63:56];

assign nextRoundKey[103:96] = roundKey[103:96] ^ nextRoundKey[71:64];
assign nextRoundKey[111:104] = roundKey[111:104] ^ nextRoundKey[79:72];
assign nextRoundKey[119:112] = roundKey[119:112] ^ nextRoundKey[87:80];
assign nextRoundKey[127:120] = roundKey[127:120] ^ nextRoundKey[95:88];

endmodule

module subBytes(
    input var logic [127:0] i,
    output var logic [127:0] o );
assign o[7:0] = sbox(i[7:0]);
assign o[15:8] = sbox(i[15:8]);
assign o[23:16] = sbox(i[23:16]);
assign o[31:24] = sbox(i[31:24]);

assign o[39:32] = sbox(i[39:32]);
assign o[47:40] = sbox(i[47:40]);
assign o[55:48] = sbox(i[55:48]);
assign o[63:56] = sbox(i[63:56]);

assign o[71:64] = sbox(i[71:64]);
assign o[79:72] = sbox(i[79:72]);
assign o[87:80] = sbox(i[87:80]);
assign o[95:88] = sbox(i[95:88]);

assign o[103:96] = sbox(i[103:96]);
assign o[111:104] = sbox(i[111:104]);
assign o[119:112] = sbox(i[119:112]);
assign o[127:120] = sbox(i[127:120]);
endmodule


module shiftRows(
    input var logic [127:0] i,
    output var logic [127:0] o
);
assign o[7:0] = i[7:0];
assign o[15:8] = i[47:40];
assign o[23:16] = i[87:80];
assign o[31:24] = i[127:120];

assign o[39:32] = i[39:32];
assign o[47:40] = i[79:72];
assign o[55:48] = i[119:112];
assign o[63:56] = i[31:24];

assign o[71:64] = i[71:64];
assign o[79:72] = i[111:104];
assign o[87:80] = i[23:16];
assign o[95:88] = i[63:56];

assign o[103:96] = i[103:96];
assign o[111:104] = i[15:8];
assign o[119:112] = i[55:48];
assign o[127:120] = i[95:88];
endmodule


