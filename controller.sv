module controller(
    input var logic [4:0]opcode,
    input var logic [2:0]funct3,
    input var logic [6:0]funct7,
    output var logic regWE,
    output var logic outmem,
    output var logic aluneg,
    output var logic isImm,
    output var logic [1:0]immtype,
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
    output var logic [2:0]extensionModuleSelect );

always_comb begin
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
        //I-Type
        5'b11001: begin
            regWE = 1'b0;
            outmem = 1'b0;
            aluneg = 1'b0;
            isImm = 1'b1;
            immtype = 2'b0;
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
        5'b00000: begin
            regWE = 1'b1;
            outmem = 1'b1;
            aluneg = 1'b0;
            isImm = 1'b0;
            immtype = 2'b0;
            pcsr = 1'b1;
            isoutr1 = 1'b0;
            isbr = 1'b0;
            isjal = 1'b1;
            iswb = 1'b0;
            pcWE = 1'b1;
            memWE = 1'b0;
            rwmem = 1'b1;
            //byteena = funct3==3'b000 ? 4'b0001 : funct3==3'b001 ? 4'b0011 : funct3==3'b010 ? 4'b1111 : 4'b0000;
            byteena = 4'b0;
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
        //extension
        5'b00010: begin
            regWE = 1'b0;
            outmem = 1'b0;
            aluneg = 1'b0;
            isImm = 1'b1;
            immtype = 2'b0;
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
            extensionModuleSelect = funct3+3'b1;
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
