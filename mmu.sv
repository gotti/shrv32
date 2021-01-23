/* verilator lint_off UNOPTFLAT */
module mmu(
    input var logic rawClock,
    input var logic clock,
    input var logic RST,
    input var logic [31:0]vaddr,
    input var logic [31:0]data,
    input var logic [3:0]byteena,
    input var logic memWE,
    output var logic memWait,
    output var logic [31:0]q,
    input var logic uartRxPin,
    output var logic uartTxPin
);
logic [31:0]SPTBR=32'h10;
logic [2:0]counter=3'b0;
logic [31:0]memaddr;
logic [31:0]memout;
logic [11:0]ppn1;
logic ramWE;
logic [3:0]ramByteEnable;
mockram ram(
    .clock(clock),
    .address(memaddr),
    .byteena(ramByteEnable),
    .data(data),
    .wren(ramWE),
    .q(memout)
);

logic [7:0] uartTxIn;
logic uartWE, uartTxBusy;
uartTx uartTx(
    .clock(rawClock),
    .reset(RST),
    .buffer(uartTxIn),
    //.buffer(generalRegisters[31][7:0])
    .we(uartWE),
    //.we(generalRegisters[31][8])
    .uartTxPin(uartTxPin),
    .busy2(uartTxBusy)
);

logic [7:0] uartRxOut, uartRxBuffer;
logic uartRxFin;
uartRx uartRx(
    .clock(rawClock),
    .reset(RST),
    .buffer(uartRxOut),
    .uartRxPin(uartRxPin),
    .fin(uartRxFin)
);

logic en, roclkq;
assign en = 1;
ro roclk(
    .en(en),
    .q(roclkq)
);

logic [9:0] rocounter;
logic roclock;
always_ff @(posedge roclkq) begin
    if (rocounter==10'd50) begin
        rocounter <= 0;
        roclock <= ~roclock;
    end else begin
        rocounter <= rocounter +1;
    end
end

parameter RONUMBER=120;
logic [31:0]randomRegister;
always_ff @(posedge roclock) begin
    randomRegister <= {xroq[RONUMBER],randomRegister[31:1]};
end

logic [RONUMBER-1:0]roq;
logic [RONUMBER:0]xroq;

genvar i;
generate
for(i=0; i<RONUMBER; i=i+1) begin: generateRO
    rod rod(
        .clock(roclock),
        .en(en),
        .q(roq[i])
    );
    assign xroq[i+1]=xroq[i]^roq[i];
end
endgenerate

logic randomRead;
logic randomBusy;
logic [199:0]randomCoolDown;
always_ff @(posedge rawClock) begin
    if(randomRead==1'b1) begin
        randomBusy <= 1'b1;
        randomCoolDown <= 50*32+100;
    end
    if(randomCoolDown!=0) begin
        randomCoolDown <= randomCoolDown -1;
        randomBusy <= 1'b1;
    end else begin
        randomBusy <= 1'b0;
    end
end
/*
always_comb begin
    memaddr = vaddr;
    ramWE = 0;
    ramByteEnable = 0;
    uartWE = 0;
    uartTxIn = 8'hff;
    //0x200 status register
    //0x201 Rx buffer
    //0x202 Tx buffer
    // 0x200 status register mapping
    // |7          2|1     |0      |
    // |--not used--|Txbusy|RxReady|
    if (32'h200<=vaddr && vaddr<=32'h202) begin
        uartWE = 1;
        uartTxIn = data[7:0];
    end else begin
        ramWE = memWE;
        ramByteEnable = byteena;
    end
end
*/
logic uartRxReady, uartRxRead;
always_ff @(posedge uartRxRead or posedge uartRxFin) begin //この記述は許されるのか？
    if (uartRxRead==1'b1) begin
        uartRxReady <= 1'b0;
    end else if (uartRxFin==1'b1) begin
        uartRxReady <= 1'b1;
    end
end

assign uartTxIn = data[7:0];
always_comb begin
    memaddr = vaddr;
    uartWE = 0;
    uartRxRead = 1'b0;
    q = memout;
    ramByteEnable = byteena;
    ramWE = 1'b0;
    randomRead = 1'b0;
    //0x200 status register
    //0x201 Rx buffer
    //0x202 Tx buffer
    // 0x200 status register mapping
    // |31        |30         2|1     |0      |
    // |randomBusy|--not used--|Txbusy|RxReady|
    //
    //TxBusy is high when transmitting data, do not write to buffer
    //RxReady is high when there is received and unread data
    //Before transmit data, check TxBusy is low
    //Before read received data, check RxReady is high
    if (32'h200<=vaddr && vaddr<=32'h203) begin
        if (32'h200==vaddr) begin
            q = {27'b0,randomBusy,2'b0,uartTxBusy,uartRxReady};
        end else if (32'h201==vaddr) begin
            uartWE = 1'b1&clock;
        end else if (32'h202==vaddr) begin
            uartRxRead = 1'b1;
            q = {24'h0,uartRxOut};
        end else if (32'h203==vaddr) begin
            q = randomRegister;
            randomRead = 1'b1;
        end
    end else begin
        q = memout;
        ramWE = memWE;
        ramByteEnable = byteena;
    end
end
//address convertion
/*always_ff @(posedge clock) begin
    if (memWE==1'b1) begin
        case (counter)
            //calculate vpn1
            3'd0: begin
                memaddr <= {20'b0,vaddr[31:22],2'b0} + SPTBR;
                counter <= counter+1;
                memWait <= 1'b1;
            end
            3'd1: begin
                if (memout[0]==1'b0 || (memout[1]==0 && memout[2]==1)) begin
                    //TODO stop and raise a page-fault exception
                    memWait <= 1'b0;
                end else if(memout[1]==1 && memout[2]==1) begin
                    //TODO valid, however, in my implementation, this is a bug.
                    memWait <= 1'b0;
                end else begin
                    ppn1 <= memout[31:20];
                    memaddr <= {8'b0,memout[31:10],2'b0} + {20'b0,vaddr[21:12],2'b0};
                end
            end
            3'd2: begin
                if (memout[0]==1'b0 || (memout[1]==0 && memout[2]==1)) begin
                    //TODO stop and raise a page-fault exception
                    memWait <= 1'b0;
                end else if(memout[1]==1 && memout[2]==1) begin
                    //TODO check permisson
                    memaddr[31:22] <= ppn1[9:0];//TODO physical memory width is 34bit, however, I remove 2bit
                    memaddr[21:12] <= memout[19:10];
                    memaddr[11:0] <= vaddr[11:0];
                end else begin
                    memWait <= 1'b0;
                    //TODO bug?
                    //memaddr <= {8'b0,memout[31:10],2'b0} + {20'b0,vaddr[21:12],2'b0};
                end
                memWait <= 1'b0;
            end
            default : begin
                    memWait <= 1'b0;
                    end
        endcase
    end else begin
        counter <= 0;
    end
end
mockram ram(
    .clock(clock),
    .address(memaddr),
    .byteena(byteena),
    .data(data),
    .wren(memWE),
    .q(memout)
);
*/
endmodule

module rod(
    input var logic clock,
    input var logic en,
    output var logic q
);
(* keep=1 *) logic a, b, c;
assign a = ~(en & c);
assign b = ~a;
assign c = ~b;
always_ff @(posedge clock) begin
    q <= a;
end
endmodule

module ro(
    input var logic en,
    output var logic q
);
(* keep=1 *) logic a, b, c;
assign a = ~(en & c);
assign b = ~a;
assign c = ~b;
assign q = a;
endmodule
