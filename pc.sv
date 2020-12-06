module pc(
    input var logic RST,
    input var logic CLK_WB,
    input var logic WE,
    input var logic [31:0]WPC,
    output var logic [31:0]RPC );
logic [31:0]pc_v;
assign RPC = pc_v;
always_ff @(posedge CLK_WB) begin
    if(RST==1'b0) begin
        pc_v <= 32'b0;
    end else if(WE==1'b1) begin
        pc_v <= WPC;
    end
end
endmodule
