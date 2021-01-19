/* verilator lint_off UNOPTFLAT */
module invAes(
    input var logic clock,
    output var logic [127:0] plaintext,
    input var logic [127:0] secret,
    input var logic [127:0] cipher,
    input var logic we,
    input var logic [127:0] nextRoundKeyIn,
    output var logic [3:0] keyCounter,
    output var logic [127:0] currentRoundKeyOut,
    output var logic busy
    );

logic [3:0]counter, nextCounter;
//function [255:0] sbox(input [255:0] sboxinput);
//endfunction
logic [127:0]secretReg;
logic [127:0]dataReg, nextDataReg;
logic [127:0]currentRoundKey, nextRoundKey;

logic [127:0]subBytesIn;
logic [127:0]subBytesOut;
invSubBytes subBytes(
    .i(subBytesIn),
    .o(subBytesOut) );

logic [127:0]shiftRowsIn;
logic [127:0]shiftRowsOut;
invShiftRows shiftRows(
    .i(shiftRowsIn),
    .o(shiftRowsOut) );

logic [127:0]mixColumnsIn;
logic [127:0]mixColumnsOut;
InvMixColumns mixColumns(
    .i(mixColumnsIn),
    .o(mixColumnsOut) );

logic [127:0]roundOut;
logic [127:0]out;
assign mixColumnsIn = dataReg ^ roundKey[10-counter];
assign shiftRowsIn = counter==4'h1 ? mixColumnsIn : mixColumnsOut;//TODO
assign subBytesIn = shiftRowsOut;
assign roundOut = subBytesOut; //TODO
//TODO
//
logic [127:0] roundKey [10:0];
assign keyCounter = counter-1;

typedef enum{
    stateIdle,
    statePreCalc,
    stateCalc
} stateType;
stateType state, nextState;
assign plaintext = dataReg;
always_comb begin
    busy = 0;
    nextCounter = 0;
    nextState = state;
    nextDataReg = dataReg;
    nextRoundKey = roundKey[counter];
    currentRoundKeyOut = 0;
    if(state == stateIdle && we) begin
        nextState = statePreCalc;
        busy = 1;
        nextCounter = 0;
    end else if(state==statePreCalc) begin
        busy = 1;
        if(counter == 11) begin
            nextState = stateCalc;
            nextCounter = 0;
        end else begin
            currentRoundKeyOut = currentRoundKey;
            nextRoundKey = nextRoundKeyIn;
            nextCounter = counter +1;
        end
    end else if (state == stateCalc) begin
        busy = 1;
        if(counter == 11) begin
            nextCounter = 0;
            nextState = stateIdle;
        end else begin
            nextCounter = counter +1;
            nextDataReg = roundOut;
        end
    end else begin
        busy = 0;
    end
end

always_ff @(posedge clock) begin
    state <= nextState;
    counter <= nextCounter;
    if(state == statePreCalc) begin
        roundKey[nextCounter-2] <= nextRoundKey;
        currentRoundKey <= counter==4'b0 ? secret : nextRoundKey;
        roundKey[10] <= secret;
    end else if(state == stateCalc) begin
        dataReg <= counter==4'd0 ? cipher : counter==4'd11 ? nextDataReg^secret : nextDataReg;
    end
end
/*
always_ff @(posedge clock) begin
    dataReg <= counter==4'b0 ? cipher : roundOut;
    plaintext <= counter==4'hb ? dataReg^secret : 128'h0;
end
always_ff @(negedge clock) begin
    counter <= counter+1;
end
*/
function automatic [3:0][3:0][7:0] bytes2matrix(
    input var logic [127:0]i );
    return '{'{i[31:24], i[63:56], i[95:88], i[127:120]},
             '{i[23:16], i[55:48], i[87:80], i[119:112]},
             '{i[15:8],  i[47:40], i[79:72], i[111:104]},
             '{i[7:0],   i[39:32], i[71:64], i[103:96]}
            };
endfunction
endmodule

function automatic [7:0] invSbox(
    input var logic [7:0]i );
logic [7:0] invSboxTable [255:0] = '{ 8'h52, 8'h09, 8'h6a, 8'hd5, 8'h30, 8'h36, 8'ha5, 8'h38, 8'hbf, 8'h40, 8'ha3, 8'h9e, 8'h81, 8'hf3, 8'hd7, 8'hfb, 8'h7c, 8'he3, 8'h39, 8'h82, 8'h9b, 8'h2f, 8'hff, 8'h87, 8'h34, 8'h8e, 8'h43, 8'h44, 8'hc4, 8'hde, 8'he9, 8'hcb, 8'h54, 8'h7b, 8'h94, 8'h32, 8'ha6, 8'hc2, 8'h23, 8'h3d, 8'hee, 8'h4c, 8'h95, 8'h0b, 8'h42, 8'hfa, 8'hc3, 8'h4e, 8'h08, 8'h2e, 8'ha1, 8'h66, 8'h28, 8'hd9, 8'h24, 8'hb2, 8'h76, 8'h5b, 8'ha2, 8'h49, 8'h6d, 8'h8b, 8'hd1, 8'h25, 8'h72, 8'hf8, 8'hf6, 8'h64, 8'h86, 8'h68, 8'h98, 8'h16, 8'hd4, 8'ha4, 8'h5c, 8'hcc, 8'h5d, 8'h65, 8'hb6, 8'h92, 8'h6c, 8'h70, 8'h48, 8'h50, 8'hfd, 8'hed, 8'hb9, 8'hda, 8'h5e, 8'h15, 8'h46, 8'h57, 8'ha7, 8'h8d, 8'h9d, 8'h84, 8'h90, 8'hd8, 8'hab, 8'h00, 8'h8c, 8'hbc, 8'hd3, 8'h0a, 8'hf7, 8'he4, 8'h58, 8'h05, 8'hb8, 8'hb3, 8'h45, 8'h06, 8'hd0, 8'h2c, 8'h1e, 8'h8f, 8'hca, 8'h3f, 8'h0f, 8'h02, 8'hc1, 8'haf, 8'hbd, 8'h03, 8'h01, 8'h13, 8'h8a, 8'h6b, 8'h3a, 8'h91, 8'h11, 8'h41, 8'h4f, 8'h67, 8'hdc, 8'hea, 8'h97, 8'hf2, 8'hcf, 8'hce, 8'hf0, 8'hb4, 8'he6, 8'h73, 8'h96, 8'hac, 8'h74, 8'h22, 8'he7, 8'had, 8'h35, 8'h85, 8'he2, 8'hf9, 8'h37, 8'he8, 8'h1c, 8'h75, 8'hdf, 8'h6e, 8'h47, 8'hf1, 8'h1a, 8'h71, 8'h1d, 8'h29, 8'hc5, 8'h89, 8'h6f, 8'hb7, 8'h62, 8'h0e, 8'haa, 8'h18, 8'hbe, 8'h1b, 8'hfc, 8'h56, 8'h3e, 8'h4b, 8'hc6, 8'hd2, 8'h79, 8'h20, 8'h9a, 8'hdb, 8'hc0, 8'hfe, 8'h78, 8'hcd, 8'h5a, 8'hf4, 8'h1f, 8'hdd, 8'ha8, 8'h33, 8'h88, 8'h07, 8'hc7, 8'h31, 8'hb1, 8'h12, 8'h10, 8'h59, 8'h27, 8'h80, 8'hec, 8'h5f, 8'h60, 8'h51, 8'h7f, 8'ha9, 8'h19, 8'hb5, 8'h4a, 8'h0d, 8'h2d, 8'he5, 8'h7a, 8'h9f, 8'h93, 8'hc9, 8'h9c, 8'hef, 8'ha0, 8'he0, 8'h3b, 8'h4d, 8'hae, 8'h2a, 8'hf5, 8'hb0, 8'hc8, 8'heb, 8'hbb, 8'h3c, 8'h83, 8'h53, 8'h99, 8'h61, 8'h17, 8'h2b, 8'h04, 8'h7e, 8'hba, 8'h77, 8'hd6, 8'h26, 8'he1, 8'h69, 8'h14, 8'h63, 8'h55, 8'h21, 8'h0c, 8'h7d};
return invSboxTable[8'hff - i];
endfunction

module invSubBytes(
    input var logic [127:0] i,
    output var logic [127:0] o );
assign o[7:0] = invSbox(i[7:0]);
assign o[15:8] = invSbox(i[15:8]);
assign o[23:16] = invSbox(i[23:16]);
assign o[31:24] = invSbox(i[31:24]);

assign o[39:32] = invSbox(i[39:32]);
assign o[47:40] = invSbox(i[47:40]);
assign o[55:48] = invSbox(i[55:48]);
assign o[63:56] = invSbox(i[63:56]);

assign o[71:64] = invSbox(i[71:64]);
assign o[79:72] = invSbox(i[79:72]);
assign o[87:80] = invSbox(i[87:80]);
assign o[95:88] = invSbox(i[95:88]);

assign o[103:96] = invSbox(i[103:96]);
assign o[111:104] = invSbox(i[111:104]);
assign o[119:112] = invSbox(i[119:112]);
assign o[127:120] = invSbox(i[127:120]);
endmodule


module invShiftRows(
    input var logic [127:0] i,
    output var logic [127:0] o
);
assign o[7:0] = i[7:0];
assign o[15:8] = i[111:104];
assign o[23:16] = i[87:80];
assign o[31:24] = i[63:56];

assign o[39:32] = i[39:32];
assign o[47:40] = i[15:8];
assign o[55:48] = i[119:112];
assign o[63:56] = i[95:88];

assign o[71:64] = i[71:64];
assign o[79:72] = i[47:40];
assign o[87:80] = i[23:16];
assign o[95:88] = i[127:120];

assign o[103:96] = i[103:96];
assign o[111:104] = i[79:72];
assign o[119:112] = i[55:48];
assign o[127:120] = i[31:24];
endmodule


