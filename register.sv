module register(
    input var logic RST,
    input var logic CLK_DC,
    input var logic CLK_WB,
    input var logic CLK_AES,
    input var logic [4:0]A1,
    input var logic [4:0]A2,
    input var logic [4:0]A3,
    input var logic [31:0]WB,
    input var logic WE,
    output var logic [31:0]RD1,
    output var logic [31:0]RD2,
    output var logic [7:0]LED );

logic [31:0]R0;
logic [31:0]R1;
logic [31:0]R2;
logic [31:0]R3;
logic [31:0]R4;
logic [31:0]R5;
logic [31:0]R6;
logic [31:0]R7;
logic [31:0]R8;
logic [31:0]R9;
logic [31:0]R10;
logic [31:0]R11;
logic [31:0]R12;
logic [31:0]R13;
logic [31:0]R14;
logic [31:0]R15;
logic [31:0]R16;
logic [31:0]R17;
logic [31:0]R18;
logic [31:0]R19;
logic [31:0]R20;
logic [31:0]R21;
logic [31:0]R22;
logic [31:0]R23;
logic [31:0]R24;
logic [31:0]R25;
logic [31:0]R26;
logic [31:0]R27;
logic [31:0]R28;
logic [31:0]R29;
logic [31:0]R30;
logic [31:0]R31;
assign LED[7:0] = R2[7:0];
logic [31:0]d1;
logic [31:0]d2;
assign RD1 = d1;
assign RD2 = d2;

logic [127:0]aes_plaintext;
logic [127:0]aes_secret;
logic [127:0]aes_cipher;
assign R31 = aes_cipher[31:0];
aes aes(
    .clock(CLK_AES),
    .plaintext({96'b0,R1}),
    .secret({96'b0,R2}),
    .cipher(aes_cipher) );

always_ff @(posedge CLK_DC) begin
    case (A1)
        5'd0: d1 <= R0;
        5'd1: d1 <= R1;
        5'd2: d1 <= R2;
        5'd3: d1 <= R3;
        5'd4: d1 <= R4;
        5'd5: d1 <= R5;
        5'd6: d1 <= R6;
        5'd7: d1 <= R7;
        5'd8: d1 <= R8;
        5'd9: d1 <= R9;
        5'd10: d1 <= R10;
        5'd11: d1 <= R11;
        5'd12: d1 <= R12;
        5'd13: d1 <= R13;
        5'd14: d1 <= R14;
        5'd15: d1 <= R15;
        5'd16: d1 <= R16;
        5'd17: d1 <= R17;
        5'd18: d1 <= R18;
        5'd19: d1 <= R19;
        5'd20: d1 <= R20;
        5'd21: d1 <= R21;
        5'd22: d1 <= R22;
        5'd23: d1 <= R23;
        5'd24: d1 <= R24;
        5'd25: d1 <= R25;
        5'd26: d1 <= R26;
        5'd27: d1 <= R27;
        5'd28: d1 <= R28;
        5'd29: d1 <= R29;
        5'd30: d1 <= R30;
        5'd31: d1 <= R31;
    endcase
    case (A2)
        5'd0: d2 <= R0;
        5'd1: d2 <= R1;
        5'd2: d2 <= R2;
        5'd3: d2 <= R3;
        5'd4: d2 <= R4;
        5'd5: d2 <= R5;
        5'd6: d2 <= R6;
        5'd7: d2 <= R7;
        5'd8: d2 <= R8;
        5'd9: d2 <= R9;
        5'd10: d2 <= R10;
        5'd11: d2 <= R11;
        5'd12: d2 <= R12;
        5'd13: d2 <= R13;
        5'd14: d2 <= R14;
        5'd15: d2 <= R15;
        5'd16: d2 <= R16;
        5'd17: d2 <= R17;
        5'd18: d2 <= R18;
        5'd19: d2 <= R19;
        5'd20: d2 <= R20;
        5'd21: d2 <= R21;
        5'd22: d2 <= R22;
        5'd23: d2 <= R23;
        5'd24: d2 <= R24;
        5'd25: d2 <= R25;
        5'd26: d2 <= R26;
        5'd27: d2 <= R27;
        5'd28: d2 <= R28;
        5'd29: d2 <= R29;
        5'd30: d2 <= R30;
        5'd31: d2 <= R31;
    endcase
end

always_ff @(posedge CLK_WB or negedge RST) begin
    if (!RST) begin
        R0 <= 0;
        R1 <= 0;
        R2 <= 0;
        R3 <= 0;
        R4 <= 0;
        R5 <= 0;
        R6 <= 0;
        R7 <= 0;
        R8 <= 0;
        R9 <= 0;
        R10 <= 0;
        R11 <= 0;
        R12 <= 0;
        R13 <= 0;
        R14 <= 0;
        R15 <= 0;
        R16 <= 0;
        R17 <= 0;
        R18 <= 0;
        R19 <= 0;
        R20 <= 0;
        R21 <= 0;
        R22 <= 0;
        R23 <= 0;
        R24 <= 0;
        R25 <= 0;
        R26 <= 0;
        R27 <= 0;
        R28 <= 0;
        R29 <= 0;
        R30 <= 0;
        //R31 <= 0;
    end else if (WE==1'b1) begin
        case (A3)
            5'd0: R0 <= 0;
            5'd1: R1 <= WB;
            5'd2: R2 <= WB;
            5'd3: R3 <= WB;
            5'd4: R4 <= WB;
            5'd5: R5 <= WB;
            5'd6: R6 <= WB;
            5'd7: R7 <= WB;
            5'd8: R8 <= WB;
            5'd9: R9 <= WB;
            5'd10: R10 <= WB;
            5'd11: R11 <= WB;
            5'd12: R12 <= WB;
            5'd13: R13 <= WB;
            5'd14: R14 <= WB;
            5'd15: R15 <= WB;
            5'd16: R16 <= WB;
            5'd17: R17 <= WB;
            5'd18: R18 <= WB;
            5'd19: R19 <= WB;
            5'd20: R20 <= WB;
            5'd21: R21 <= WB;
            5'd22: R22 <= WB;
            5'd23: R23 <= WB;
            5'd24: R24 <= WB;
            5'd25: R25 <= WB;
            5'd26: R26 <= WB;
            5'd27: R27 <= WB;
            5'd28: R28 <= WB;
            5'd29: R29 <= WB;
            5'd30: R30 <= WB;
            5'd31: R0 <= WB;
        endcase
    end
end

endmodule
