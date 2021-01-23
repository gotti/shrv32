module cpu(
    input var CLK,
    input var RST,
    output var logic [7:0]LED,
    input var logic uartRxPin,
    output var logic uartTxPin
);

logic pcWE = 1'b1;
logic [31:0]RPC;
logic [31:0]WPC;
logic CLK_FT;
logic CLK_DC;
logic CLK_EX;
logic CLK_MA;
logic CLK_WB;
logic memWait;
logic rwmem;
clk_gen clk_gen(
    .CLK(CLK),
    .memWait(memWait),
    .rwmem(rwmem),
    .exBusy(exBusy),
    .CLK_FT(CLK_FT),
    .CLK_DC(CLK_DC),
    .CLK_EX(CLK_EX),
    .CLK_MA(CLK_MA),
    .CLK_WB(CLK_WB)
    );

pc pc(
    .RST(RST),
    .CLK_WB(CLK_WB),
    .WE(pcWE),
    .WPC(WPC),
    .RPC(RPC)
);
logic [31:0]incPC;
assign incPC = RPC + 32'h4;
logic pcsr = 1'b1;
logic isbr = 1'b0;
logic [31:0]brcontout = 32'b0;
logic [31:0]aluormemor1;
logic [31:0]jal;
logic isjal;
assign jal = INST[31]==1'b1 ? RPC+ {~11'b0,INST[31],INST[19:12],INST[20],INST[30:21],1'b0} : RPC+{11'b0,INST[31],INST[19:12],INST[20],INST[30:21],1'b0};
assign WPC = pcsr==1'b1 ? incPC : isbr==1'b1 ? isjal==1'b1 ? jal : brcontout : aluormemor1 ;
logic [31:0]INST = 32'b0;
/*
mockrom rom(
    .clock(CLK_FT),
    .address(RPC>>2),
    .q(INST)
);*/
rom rom(
    .CLK(CLK_FT),
    .A(RPC),
    .RD(INST)
);
/*
onchiprom rom(
    .clock(CLK_FT),
    .address(10'(shiftedPC>>2)),
    .q(INST)
);*/
logic isEnableXD2R;
logic [31:0]regWB;
logic [31:0]D1;
logic [31:0]D2;
logic regWE = 1'b0;
logic iswb = 1'b0;
assign  regWB = isEnableXD2R==1'b1 ? XD3[31:0] : (pcsr==1'b1) ? ((iswb==1'b1) ? brcontout : aluormemor1) : incPC ;
logic [255:0]R2XD;
register register(
    .RST(RST),
    .CLK(CLK),
    .CLK_DC(CLK_DC),
    .CLK_WB(CLK_WB),
    .A1(INST[19:15]),
    .A2(INST[24:20]),
    .A3(INST[11:7]),
    .WE(regWE),
    .WB(regWB),
    .RD1(D1),
    .RD2(D2),
    .LED(LED),
    .RXD(R2XD)
);

logic isEnableR2XD;
logic reg256WE;
logic [255:0] XD1, XD2, XD3, reg256WB;
assign reg256WB = isEnableR2XD==1'b1 ? R2XD : XD3;
reg256 reg256(
    .RST(RST),
    .CLK(CLK),
    .CLK_DC(CLK_DC),
    .CLK_WB(CLK_WB),
    .A1(INST[19:15]),
    .A2(INST[24:20]),
    .A3(INST[11:7]),
    .WE(reg256WE),
    .WB(reg256WB),
    .RD1(XD1),
    .RD2(XD2)
);

logic [9:0]alucontrol;
logic aluneg;
logic isImm = 1'b0;
logic [1:0]immtype = 2'b0;
logic brImmType = 1'b0;
logic outmem = 1'b0;
logic isoutr1 = 1'b0;
logic memWE = 1'b0;
logic [3:0]byteena;
logic exaluEnable;
logic [2:0] extensionModuleSelect;
logic exaluImm, exaluInsert, exaluD2Insert, usingDirectImmIn, directmmuInsert;
controller controller(
    .opcode(INST[6:2]),
    .funct3(INST[14:12]),
    .funct7(INST[31:25]),
    .regWE(regWE),
    .outmem(outmem),
    .aluneg(aluneg),
    .isImm(isImm),
    .immtype(immtype),
    .brImmType(brImmType),
    .pcsr(pcsr),
    .isoutr1(isoutr1),
    .isbr(isbr),
    .isjal(isjal),
    .iswb(iswb),
    .pcWE(pcWE),
    .rwmem(rwmem),
    .memWE(memWE),
    .byteena(byteena),
    .alucontrol(alucontrol),
    .exaluEnable(exaluEnable),
    .exaluImm(exaluImm),
    .exaluInsert(exaluInsert),
    .exaluD2Insert(exaluD2Insert),
    .extensionModuleSelect(extensionModuleSelect),
    .isEnableR2XD(isEnableR2XD),
    .isEnableXD2R(isEnableXD2R),
    .directmmuInsert(directmmuInsert),
    .usingDirectImmIn(usingDirectImmIn),
    .reg256WE(reg256WE)
);
logic [31:0]aluout;
logic [31:0]aluin;
assign aluin = isImm==0 ? D2 :
                    immtype==2'h0 ? INST[31]==1'b1 ? {~20'b0,INST[31:20]} : {20'b0,INST[31:20]} :
                    immtype==2'h1 ? INST[31]==1'b1 ? {~20'b0,INST[31:25],INST[11:7]} : {20'b0,INST[31:25],INST[11:7]} :
                    immtype==2'h2 ? INST[31]==1'b1 ? {~19'b0,INST[31],INST[7],INST[30:25],INST[11:8],1'b0} :
 {19'b0,INST[31],INST[7],INST[30:25],INST[11:8],1'b0} :
                    immtype==2'h3 ? {INST[31:12],12'b0} :
                    32'b0;
alu alu(
    .alucontrol(alucontrol),
    .aluneg(aluneg),
    .D1(D1),
    .D2(aluin),
    .aluout(aluout)
);

logic exBusy;
logic exaluWE;
assign exaluWE = CLK_EX&exaluEnable;
logic [255:0]exImmIn;
assign exImmIn = exaluInsert==1'b0 ? XD2 : exaluImm==1'b0 ? {224'b0, exaluD2Insert==1'b1 ? D2 : aluormem} : INST[31]==1'b1 ? {~244'b0, INST[31:20]} : {244'b0, INST[31:20]};
exalu exalu(
    .we(exaluWE),
    .clock(CLK),
    .alucontrol(INST[14:12]),
    .D1(XD1),
    .D2(exImmIn),
    .exaluOut(XD3),
    .busy(exBusy)
);


logic [31:0]MREAD;
logic [31:0]memout;
mmu mmu(
    .rawClock(CLK),
    .clock(CLK_MA),
    .RST(RST),
    .vaddr(directmmuInsert==1'b1 ? D2 : usingDirectImmIn==1'b1 ? {20'b0,INST[31:20]} : aluout),
    .data(D2),
    .byteena(byteena),
    .memWE(memWE),
    .memWait(memWait),
    .q(memout),
    .uartTxPin(uartTxPin),
    .uartRxPin(uartRxPin)
);

logic mem2reg;
logic [31:0]aluormem;
assign aluormem = outmem==1'b1 ? memout : aluout ;
assign aluormemor1 = isoutr1==1'b1 ? D1 : aluormem;
brcontroller brcontroller(
    .cond(aluormem),
    .funct3(INST[14:12]),
    .pc(RPC),
    .offset(((INST[31]==1'b1) ? {~19'b0,INST[31],INST[7],INST[30:25],INST[11:8],1'b0} : {19'b0,INST[31],INST[7],INST[30:25],INST[11:8],1'b0})),
    .out(brcontout)
);

endmodule
