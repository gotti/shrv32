module alu(
    input var logic [9:0]alucontrol,
    input var logic aluneg,
    input var logic [31:0]D1,
    input var logic [31:0]D2,
    output var logic [31:0]aluout );

always_comb begin
    case (alucontrol[2:0])
        3'h0: case (aluneg)
                   1'b0: aluout = D1+D2;
                   1'b1: aluout = D1-D2;
               endcase
        3'h1: aluout = D1 << D2[4:0];
        3'h2: aluout = D1<D2 ? 32'b1:32'b0; //TODO this is SIGNED cmp
        3'h3: aluout = D1<D2 ? 32'b1:32'b0;
        3'h4: aluout = D1^D2;
        3'h5: case (aluneg)
                   1'b0: aluout = D1>>D2[4:0];
                   1'b1: aluout = D1>>>D2[4:0];
               endcase
        3'h6: aluout = D1|D2;
        3'h7: aluout = D1&D2;
        default:;
    endcase
end

endmodule
