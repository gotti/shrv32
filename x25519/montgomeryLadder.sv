module montgomeryLadder(
    input var logic clock,
    input var logic [255:0]k,
    output var logic [255:0]x,
    output var logic [255:0]y,
    output var logic [255:0]z
);
logic [255:0] x0, y0, z0, x1, y1, z1;
logic [7:0]counter = 8'hff;
logic [7:0]decCounter;
assign decCounter = counter - 8'd1;
always_ff @(posedge clock) begin
    if (k[counter]==1'b0) begin

    end else begin
    end
end
endmodule
