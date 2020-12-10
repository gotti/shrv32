module clk_gen(
    input var CLK,
    input var memWait,
    input var rwmem,
    output var CLK_FT,
    output var CLK_DC,
    output var CLK_EX,
    output var CLK_MA,
    output var CLK_WB );
logic [3:0]counter = 4'b0;
logic [22:0]tien = 23'b0;
logic CLK_honto;
always_ff @(posedge CLK) begin
    if (tien==23'd1) begin //100000
        CLK_honto <= ~CLK_honto;
        tien <= 0;
    end else begin
        tien <= tien + 1;
    end
end

assign CLK_FT = counter==4'h2 ? CLK_honto: 1'b0;
assign CLK_DC = counter==4'h4 ? CLK_honto: 1'b0;
assign CLK_EX = counter==4'h6 ? CLK_honto: 1'b0;
assign CLK_MA = counter==4'h8 ? CLK_honto: 1'b0;
assign CLK_WB = counter==4'ha ? CLK_honto: 1'b0;

always_ff @(negedge CLK_honto) begin
    if (memWait==1'b0) begin
      counter=counter+1;
    end
end
endmodule
