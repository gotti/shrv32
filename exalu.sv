module exalu(
    input var logic clock,
    input var logic [2:0]alucontrol,
    input var logic [255:0]D1,
    input var logic [255:0]D2,
    output var logic [255:0]aluout,
    output var logic busy
);
logic aesBusy;
logic invAesBusy;
logic [127:0]aesPlaintextIn;
logic [127:0]aesSecretIn;
logic [127:0]aesCipherOut;
logic [127:0]invAesCipherIn;
logic [127:0]invAesSecretIn;
logic [127:0]invAesPlaintextOut;
logic [127:0]aesWE;
logic [127:0]invAesWE;
typedef enum{
    stateCalc,
    stateWait,
    stateFin
} stateType;
stateType aesState, nextAesState;
stateType invAesState, nextInvAesState;

aes aes(
    .clock(CLK),
    .plaintext(aesPlaintextIn),
    .secret(aesSecretIn),
    .we(aesWE),
    .cipher(aesCipherOut),
    .busy(aesBusy)
);

invAes invAes(
    .clock(CLK),
    .cipher(invAesCipherIn),
    .secret(invAesSecretIn),
    .we(invAesWE),
    .plaintext(invAesPlaintextOut),
    .busy(invAesBusy)
);

always_comb begin
    aesWE = 0;
    aesBusy = 0;
    invAesBusy = 0;
    aesPlaintextIn = 0;
    aesSecretIn = 0;
    aesCipherOut = 0;
    invAesCipherIn = 0;
    invAesSecretIn = 0;
    invAesPlaintextOut = 0;
    aesWE = 0;
    invAesWE = 0;
    aluout = 0;
    busy = 0;
    case (alucontrol[2:0])
        3'h1: begin
            if(aesState == stateCalc) begin
                nextAesState = stateWait;
                aesPlaintextIn = D1[127:0];
                aesSecretIn = D2[127:0];
                aesWE = 1;
            end else if(aesState == stateWait) begin
                if(aesBusy) begin
                    busy = 1;
                end else begin
                    busy = 0;
                    nextAesState = stateCalc;
                    aluout = aesCipherOut;
                end
            end
        end
        3'h2: begin
            if(invAesState == stateCalc) begin
                nextInvAesState = stateWait;
                invAesPlaintextOut = D1[127:0];
                invAesSecretIn = D2[127:0];
                invAesWE = 1;
            end else if(invAesState == stateWait) begin
                if(invAesBusy) begin
                    busy = 1;
                end else begin
                    busy = 0;
                    nextInvAesState = stateCalc;
                    aluout = aesCipherOut;
                end
            end
        end
        default: begin
        end
    endcase
end
endmodule
