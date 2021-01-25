module controller(
    input var logic [4:0]opcode,
    input var logic [2:0]funct3,
    input var logic [6:0]funct7,
    output var logic regWE,
    output var logic outmem,
    output var logic aluneg,
    output var logic isImm,
    output var logic [1:0]immtype,
    output var logic brImmType,
    output var logic pcsr,
    output var logic isoutr1,
    output var logic isbr,
    output var logic isjal,
    output var logic iswb,
    output var logic pcWE,
    output var logic rwmem,
    output var logic memWE,
    output var logic [3:0]byteena,
    output var logic [9:0]alucontrol,
    output var logic exaluEnable,
    output var logic exaluImm,
    output var logic exaluInsert,
    output var logic exaluD2Insert,
    output var logic [2:0]extensionModuleSelect,
    output var logic isEnableR2XD,
    output var logic isEnableXD2R,
    output var logic directmmuInsert,
    output var logic usingDirectImmIn,
    output var logic reg256WE
);

always_comb begin
        exaluEnable = 1'b0;
        exaluImm = 1'b0;
        exaluInsert = 1'b0;
        exaluD2Insert = 1'b0;
        isEnableR2XD = 1'b0;
        isEnableXD2R = 1'b0;
        reg256WE = 1'b0;
        brImmType = 1'b0;
        directmmuInsert = 1'b0;
        usingDirectImmIn = 1'b0;
    case (opcode)
        //R-Type https://inst.eecs.berkeley.edu/~cs61c/resources/su18_lec/Lecture7.pdf
        5'b01100: begin
            regWE = 1'b1;
            outmem = 1'b0;
            aluneg = funct7[6];
            isImm = 1'b0;
            immtype = 2'b0;
            pcsr = 1'b1;
            isoutr1 = 1'b0;
            isbr = 1'b0;
            isjal = 1'b0;
            iswb = 1'b0;
            pcWE = 1'b1;
            rwmem = 1'b0;
            memWE = 1'b0;
            byteena = 4'b0000;
            alucontrol = {7'b0,funct3};
            extensionModuleSelect = 3'b0;
            /*funct<={INST[31:25],INST[14:12]};
            rs1_num<=INST[19:15];
            rs2_num<=INST[24:20];
            rd_num<=INST[11:7];*/
        end
        //jalr
        5'b11001: begin
            regWE = 1'b0;
            outmem = 1'b0;
            aluneg = 1'b0;
            isImm = 1'b1;
            immtype = 2'b0;
            pcsr = 1'b0;
            isoutr1 = 1'b0;
            isbr = 1'b0;
            isjal = 1'b0;
            iswb = 1'b0;
            pcWE = 1'b1;
            rwmem = 1'b0;
            memWE = 1'b0;
            byteena = 4'b0000;
            alucontrol = 10'b0;
            extensionModuleSelect = 3'b0;
        end
        //Branch
        5'b11000: begin
            regWE = 1'b0;
            outmem = 1'b0;
            aluneg = 1'b1;
            isImm = 1'b0;
            immtype = 2'b0;
            brImmType = 1'b1;
            pcsr = 1'b0;
            isoutr1 = 1'b1;
            isbr = 1'b1;
            isjal = 1'b0;
            iswb = 1'b0;
            pcWE = 1'b1;
            rwmem = 1'b0;
            memWE = 1'b0;
            byteena = 4'b0000;
            alucontrol = 10'b0;
            extensionModuleSelect = 3'b0;
        end
        //Store
        5'b01000: begin
            regWE = 1'b0;
            outmem = 1'b1;
            aluneg = 1'b0;
            isImm = 1'b1;
            immtype = 2'b1;
            pcsr = 1'b1;
            isoutr1 = 1'b0;
            isbr = 1'b0;
            isjal = 1'b0;
            iswb = 1'b1;
            pcWE = 1'b1;
            rwmem = 1'b1;
            memWE = 1'b1;
            byteena = funct3==3'b000 ? 4'b0001 : funct3==3'b001 ? 4'b0011 : funct3==3'b010 ? 4'b1111 : 4'b0000;
            //byteena = 4'b0;
            alucontrol = 10'b0;
            extensionModuleSelect = 3'b0;
        end
        //load
        5'b00000: begin
            regWE = 1'b1;
            outmem = 1'b1;
            aluneg = 1'b0;
            isImm = 1'b1;
            immtype = 2'b0;
            pcsr = 1'b1;
            isoutr1 = 1'b0;
            isbr = 1'b0;
            isjal = 1'b1;
            iswb = 1'b0;
            pcWE = 1'b1;
            memWE = 1'b0;
            rwmem = 1'b1;
            byteena = funct3==3'b000 ? 4'b0001 : funct3==3'b001 ? 4'b0011 : funct3==3'b010 ? 4'b1111 : 4'b0000;
            alucontrol = 10'b0;
            extensionModuleSelect = 3'b0;
        end
        5'b00100: begin
            regWE = 1'b1;
            outmem = 1'b0;
            aluneg = 1'b0;
            isImm = 1'b1;
            immtype = 2'b0;
            pcsr = 1'b1;
            isoutr1 = 1'b0;
            isbr = 1'b0;
            isjal = 1'b0;
            iswb = 1'b0;
            pcWE = 1'b1;
            rwmem = 1'b0;
            memWE = 1'b0;
            byteena = 4'b0000;
            alucontrol = {7'b0, funct3};
            extensionModuleSelect = 3'b0;
        end
        //jal
        5'b11011: begin
            regWE = 1'b0;
            outmem = 1'b0;
            aluneg = 1'b0;
            isImm = 1'b0;
            immtype = 2'b0;
            pcsr = 1'b0;
            isoutr1 = 1'b0;
            isbr = 1'b1;
            isjal = 1'b1;
            iswb = 1'b0;
            pcWE = 1'b1;
            rwmem = 1'b0;
            memWE = 1'b0;
            byteena = 4'b0000;
            alucontrol = 10'b0;
            extensionModuleSelect = 3'b0;
        end
        //extension, rd, rs1, rs2
        5'b00010: begin
            regWE = funct3==3'd3;
            outmem = funct3==3'd5;
            aluneg = 1'b0;
            isImm = 1'b0;
            immtype = 2'b0;
            pcsr = 1'b1;
            isoutr1 = 1'b1;
            isbr = 1'b1;
            isjal = 1'b0;
            iswb = 1'b0;
            pcWE = 1'b1;
            rwmem = 1'b0;
            memWE = 1'b0;
            byteena = funct3==3'd5 ? 4'b0001 : 4'b0000;
            alucontrol = funct3==3'd5 ? 10'd0 : 10'd0 ;
            exaluEnable = 1'b1;
            exaluImm = 1'b0;
            exaluInsert = funct3==3'd5|funct3==3'd3;
            exaluD2Insert = funct3==3'd3;
            extensionModuleSelect = funct3;
            isEnableXD2R = funct3==3'd3;
            reg256WE = funct3==3'd4|funct3==3'd1|funct3==3'd2|funct3==3'd5|funct3==3'd7;
            directmmuInsert = funct3==3'd5;
            isEnableR2XD = funct3==3'd4;
        end
        //extension, rd, rs1, imm
        5'b01010: begin
            regWE = 1'b0;
            outmem = funct3==3'd5;
            aluneg = 1'b0;
            isImm = 1'b1;
            immtype = 2'b0;
            pcsr = 1'b1;
            isoutr1 = 1'b1;
            isbr = 1'b1;
            isjal = 1'b0;
            iswb = 1'b0;
            pcWE = 1'b1;
            rwmem = 1'b0;
            memWE = 1'b0;
            byteena = funct3==3'd5 ? 4'b0001 : 4'b0000;
            alucontrol = 10'b0;
            exaluEnable = 1'b1;
            exaluImm = funct3==3'd3|funct3==3'd0;
            exaluInsert = funct3==3'd5|funct3==3'd3|funct3==3'd0;
            extensionModuleSelect = funct3;
            isEnableXD2R = funct3==3'd3;
            reg256WE = funct3==3'd4|funct3==3'd1|funct3==3'd2|funct3==3'd5|funct3==3'd0;
            isEnableR2XD = funct3==3'd4;
            usingDirectImmIn = funct3==3'd5;
            //extensionModuleSelect
            // 0 -> disable
            // 1 -> aes-128 encrypt
            // 2 -> aes-128 decrypt
            // aes-128  instructions is below
            // immediate type: I-type
            // it will encrypt/decrypt imm[11:0] aes-words(1 aes-word = 128 bits) begenning [rs1] and store beginning [rd]
        end
        default: begin
            regWE = 1'b0;
            outmem = 1'b0;
            aluneg = 1'b0;
            isImm = 1'b0;
            immtype = 2'b0;
            pcsr = 1'b1;
            isoutr1 = 1'b0;
            isbr = 1'b0;
            isjal = 1'b1;
            iswb = 1'b0;
            pcWE = 1'b1;
            rwmem = 1'b0;
            memWE = 1'b0;
            byteena = 4'b0000;
            alucontrol = 10'b0;
            extensionModuleSelect = 3'b0;
        end
        endcase
end
endmodule
