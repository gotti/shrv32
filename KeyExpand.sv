module KeyExpand(
    input var logic [127:0] roundKey,
    input var logic [3:0] counter,
    output var logic[127:0] nextRoundKey );
logic [31:0] s;
logic [31:0] rcon[3:0] = '{32'h1000000, 32'h2000000, 32'h4000000, 32'h8000000, 32'h10000000, 32'h20000000, 32'h40000000, 32'h80000000, 32'h1b000000, 32'h36000000};
assign s[7:0] = invSbox(roundKey[31:24]);
assign s[15:8] = invSbox(roundKey[7:0]);
assign s[23:16] = invSbox(roundKey[15:8]);
assign s[32:24] = invSbox(roundKey[23:16]);

assign nextRoundKey[31:0] = roundKey[31:0] ^ s ^ rcon[counter];
assign nextRoundKey[63:32] = roundKey[31:0] ^ s ^ rcon[counter] ^ roundKey[95:64];
assign nextRoundKey[95:64] = roundKey[31:0] ^ s ^ rcon[counter] ^ roundKey[95:64] ^ roundKey[63:32];
assign nextRoundKey[127:96] = roundKey[31:0] ^ s ^ rcon[counter] ^ roundKey[95:64] ^ roundKey[63:32] ^ roundKey[31:0];
endmodule
