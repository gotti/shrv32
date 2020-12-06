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
always_ff @(posedge CLK_honto) begin
  case (counter)
    4'h0: begin
      CLK_FT=~CLK_FT;
      CLK_DC=1'b0;
      CLK_EX=1'b0;
      CLK_MA=1'b0;
      CLK_WB=1'b0;
    end
    4'h3: begin
      CLK_FT=1'b0;
      CLK_DC=~CLK_DC;
      CLK_EX=1'b0;
      CLK_MA=1'b0;
      CLK_WB=1'b0;
    end
    4'h6: begin
      CLK_FT=1'b0;
      CLK_DC=1'b0;
      CLK_EX=~CLK_EX;
      CLK_MA=1'b0;
      CLK_WB=1'b0;
    end
    4'h9: begin
      if (rwmem==1'b1) begin
          CLK_FT=1'b0;
          CLK_DC=1'b0;
          CLK_EX=1'b0;
          CLK_MA=~CLK_MA;
          CLK_WB=1'b0;
      end else begin
          CLK_FT=1'b0;
          CLK_DC=1'b0;
          CLK_EX=1'b0;
          CLK_MA=1'b0;
          CLK_WB=1'b0;
      end
    end
    4'hc: begin
      CLK_FT=1'b0;
      CLK_DC=1'b0;
      CLK_EX=1'b0;
      CLK_MA=1'b0;
      CLK_WB=~CLK_WB;
    end
    default : begin
      CLK_FT=1'b0;
      CLK_DC=1'b0;
      CLK_EX=1'b0;
      CLK_MA=1'b0;
      CLK_WB=1'b0;
    end
  endcase
end
always_ff @(negedge CLK_honto) begin
    if (memWait==1'b0) begin
      counter=counter+1;
    end
end
endmodule
