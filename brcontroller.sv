module brcontroller(
    input var logic [31:0]cond,
    input var logic [2:0]funct3,
    input var logic [31:0]pc,
    input var logic [31:0]offset,
    output var logic [31:0]out
);
logic [31:0] added;
always_comb begin
    out = pc+4;
    added = pc+offset;
    //TODO: 符号を無視してるのであとで直す
    case (funct3)
        3'b000: begin //beq, rs1==rs2
            if(cond==32'b0) begin
                out = added;
            end
        end
        3'b001: begin //bne, rs1!=rs2
            if(cond!=32'b0) begin
                out = added;
            end
        end
        3'b100: begin //blt, rs1 < rs2
            if(cond[31]==1'd1) begin
                out = added;
            end
        end
        3'b101: begin //bge, rs1>=rs2
            if(cond[31]==1'd0) begin
                out = added;
            end
        end
        3'b110: begin //bltu, rs1<rs2(unsigned)
            if(cond[31]==1'd1) begin
                out = added;
            end
        end
        3'b111: begin //bgeu, rs1>=rs2(unsigned)
            if(cond[31]==1'd0) begin
                out = added;
            end
        end
        default : begin
        end
    endcase
end

endmodule
