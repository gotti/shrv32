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
    .busy(uartTxBusy)
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
always_ff @(posedge uartRxRead or posedge uartRxFin) begin
    if (uartRxRead==1'b1) begin
        uartRxReady <= 1'b0;
    end else if (uartRxFin==1'b1) begin
        uartRxReady <= 1'b1;
    end
end

assign uartTxIn = data[7:0];
always_ff @(posedge clock) begin
    memaddr <= vaddr;
    ramWE <= 0;
    ramByteEnable <= 0;
    uartWE <= 0;
    q <= 32'b0;
    uartRxRead <= 1'b0;
    //0x200 status register
    //0x201 Rx buffer
    //0x202 Tx buffer
    // 0x200 status register mapping
    // |7          2|1     |0      |
    // |--not used--|Txbusy|RxReady|
    //
    //TxBusy is high when transmitting data, do not write to buffer
    //RxReady is high when there is received and unread data
    //Before transmit data, check TxBusy is low
    //Before read received data, check RxReady is high
    if (32'h200<=vaddr && vaddr<=32'h202) begin
        if (32'h200==vaddr) begin
            q <= {30'b0,uartTxBusy,uartRxReady};
        end else if (32'h201==vaddr) begin
            uartWE <= 1'b1;
        end else if (32'h202==vaddr) begin
            uartRxRead <= 1'b1;
            q <= {24'h0,uartRxOut};
        end
    end else begin //TODO: たぶんクロックの関係でバグる
        q <= memout;
        ramWE <= memWE;
        ramByteEnable <= byteena;
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
