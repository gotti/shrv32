module extensionController(
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
    output var logic [2:0]extensionModuleSelect );

always_comb begin
    case (opcode)
        5'b11011: begin
            regWE <= 1'b0;
            outmem <= 1'b0;
            aluneg <= 1'b0;
            isImm <= 1'b1;
            immtype <= 2'b0;
            pcsr <= 1'b0;
            isoutr1 <= 1'b1;
            isbr <= 1'b1;
            isjal <= 1'b0;
            iswb <= 1'b0;
            pcWE <= 1'b1;
            rwmem <= 1'b0;
            memWE <= 1'b0;
            extensionModuleSelect <= funct3;
        end
        //extension
        //5'b00010: begin
        //end
        default: begin
            regWE <= 1'b0;
            outmem <= 1'b0;
            aluneg <= 1'b0;
            isImm <= 1'b0;
            immtype <= 2'b0;
            pcsr <= 1'b1;
            isoutr1 <= 1'b0;
            isbr <= 1'b0;
            isjal <= 1'b1;
            iswb <= 1'b0;
            pcWE <= 1'b1;
            rwmem <= 1'b0;
            memWE <= 1'b0;
            byteena <= 4'b0000;
            alucontrol <= 10'b0;
        end
        endcase
end
endmodule
