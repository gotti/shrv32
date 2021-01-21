module exalu(
    input var logic we,
    input var logic clock,
    input var logic [2:0]alucontrol,
    input var logic [255:0]D1,
    input var logic [255:0]D2,
    output var logic [255:0]exaluOut,
    output var logic busy
);
logic aesBusy;
logic invAesBusy;
logic [127:0]aesCipherOut;
logic [127:0]invAesPlaintextOut;
logic aesWE;
logic invAesWE;
logic b;
logic usingInvAes, nextUsingInvAes;
typedef enum{
    stateCalc,
    stateWait,
    stateFin
} stateType;
stateType aesState, nextAesState;
stateType invAesState, nextInvAesState;
logic [127:0] aesNextRoundKey, aesCurrentRoundKey, invAesCurrentRoundKey;
logic [3:0] aesKeyCounter, invAesKeyCounter;
aes aes(
    .clock(clock),
    .plaintext(D1[127:0]),
    .secret(D2[127:0]),
    .we(aesWE),
    .nextRoundKey(aesNextRoundKey),
    .keyCounter(aesKeyCounter),
    .currentRoundKey(aesCurrentRoundKey),
    .cipher(aesCipherOut),
    .busy(aesBusy)
);

invAes invAes(
    .clock(clock),
    .cipher(D1[127:0]),
    .secret(D2[127:0]),
    .we(invAesWE),
    .nextRoundKeyIn(aesNextRoundKey),
    .keyCounter(invAesKeyCounter),
    .currentRoundKeyOut(invAesCurrentRoundKey),
    .plaintext(invAesPlaintextOut),
    .busy(invAesBusy)
);

keyExpand keyExpand(
    .roundKey(usingInvAes==1'b1 ? invAesCurrentRoundKey : aesCurrentRoundKey),
    .counter(usingInvAes==1'b1 ? invAesKeyCounter : aesKeyCounter),
    .nextRoundKey(aesNextRoundKey)
);

assign busy = aesBusy|invAesBusy;
always_comb begin
    aesWE = 0;
    invAesWE = 0;
    nextAesState = aesState;
    nextInvAesState = invAesState;
    if(we==1'b1) begin
        case (alucontrol[2:0])
            3'h1: begin
                if(aesState == stateCalc) begin
                    nextAesState = stateWait;
                    aesWE = 1;
                end else if(aesState == stateWait) begin
                    if(aesBusy) begin
                    end else begin
                        nextAesState = stateFin;
                    end
                end else begin
                    nextAesState = stateCalc;
                end
            end
            3'h2: begin
                if(invAesState == stateCalc) begin
                    nextInvAesState = stateWait;
                    invAesWE = 1;
                end else if(invAesState == stateWait) begin
                    if(invAesBusy) begin
                    end else begin
                        nextInvAesState = stateFin;
                    end
                end else if(invAesState == stateFin) begin
                    nextInvAesState = stateCalc;
                end
            end
            default: begin
            end
        endcase
    end
end

//assign exaluout = {128'h0, alucontrol==3'h1 ? aesCipherOut :
//                alucontrol==3'h2 ? invAesPlaintextOut : 128'h0};

logic [255:0]shiftedD1;
assign usingInvAes = invAesBusy;
always_comb begin
    exaluOut = 0;
    case(alucontrol)
        3'h0: begin//add D1, D2 for use of AES-CBC IV or other general use
            exaluOut = D1 + D2;
        end
        3'h1: begin//aes128encrypt rd, rs1, rs2 // rd=aes128enc(plaintext=rs1,secret=rs2)
            exaluOut = {128'b0,aesCipherOut};
        end
        3'h2: begin//aes128decrypt rd, rs1, rs2 // rd=aes128dec(cipher=rs1, secret=rs2)
            exaluOut = {128'b0,invAesPlaintextOut};
        end
        3'h3: begin//256bit register to 32bit register, with shift
            exaluOut = (D1>>D2)&256'hffffffff;
        end
        3'h5: begin//load 1 byte from memory to register
            exaluOut = (D1<<8)+(D2&256'hff);
        end
        3'h6: begin//256bit register to 32bit register, with shift
            exaluOut = (D1>>D2)&256'hffffffff;
        end
        3'h7: begin//xor D1 and D2, for use of AES-CBC IV
            exaluOut = D1 ^ D2;
        end
        default: begin
        end
    endcase
end
always_ff @(posedge clock) begin
    aesState <= nextAesState;
    invAesState <= nextInvAesState;
end
endmodule
