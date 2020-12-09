module cpu(
    input var CLK,
    input var RST,
    output var logic [7:0]LED );

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

rom rom(
    .CLK(CLK_FT),
    .A(RPC),
    .RD(INST)
);

logic [31:0]regWB;
logic [31:0]D1;
logic [31:0]D2;
logic regWE = 1'b0;
logic iswb = 1'b0;
assign  regWB = (pcsr==1'b1) ? ((iswb==1'b1) ? brcontout : aluormemor1) : incPC ;
register register(
    .RST(RST),
    .CLK_DC(CLK_DC),
    .CLK_WB(CLK_WB),
    .CLK_AES(CLK),
    .A1(INST[19:15]),
    .A2(INST[24:20]),
    .A3(INST[11:7]),
    .WE(regWE),
    .WB(regWB),
    .RD1(D1),
    .RD2(D2),
    .LED(LED)
);
logic [9:0]alucontrol;
logic aluneg;
logic isImm = 1'b0;
logic [1:0]immtype = 2'b0;
logic outmem = 1'b0;
logic isoutr1 = 1'b0;
logic memWE = 1'b0;
logic [3:0]byteena;
controller controller(
    .opcode(INST[6:2]),
    .funct3(INST[14:12]),
    .funct7(INST[31:25]),
    .regWE(regWE),
    .outmem(outmem),
    .aluneg(aluneg),
    .isImm(isImm),
    .immtype(immtype),
    .pcsr(pcsr),
    .isoutr1(isoutr1),
    .isbr(isbr),
    .isjal(isjal),
    .iswb(iswb),
    .pcWE(pcWE),
    .rwmem(rwmem),
    .memWE(memWE),
    .byteena(byteena),
    .alucontrol(alucontrol)
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

logic [31:0]MREAD;
logic [31:0]memout;
mmu mmu(
    .clock(CLK_MA),
    .vaddr(aluout),
    .data(D2),
    .byteena(byteena),
    .memWE(memWE),
    .memWait(memWait),
    .q(memout)
);

logic mem2reg;
logic [31:0]aluormem;
assign aluormem = outmem==1'b1 ? memout : aluout ;
assign aluormemor1 = isoutr1==1'b1 ? D1 : aluormem;
brcontroller brcontroller(
    .cond(aluormem),
    .address(RPC+ ((INST[31]==1'b1) ? {~19'b0,INST[31],INST[7],INST[30:25],INST[11:8],1'b0} : {19'b0,INST[31],INST[7],INST[30:25],INST[11:8],1'b0})),
    .out(brcontout)
);

endmodule
