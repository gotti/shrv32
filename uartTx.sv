module uartTx(
    input var logic clock,
    input var logic reset,
    input var logic [7:0]buffer,
    input var logic we,
    output var logic uartTxPin
);

logic clk;
logic [10:0]divCounter = 11'b0;
always_ff @(posedge clock) begin
    if (divCounter==11'd1250) begin
        divCounter <= 11'd0;
        clk <= ~clk;
    end else begin
        divCounter <= divCounter+1;
    end
end
logic clkCounter =1'b0;
// idle
// transmit
logic [3:0] transmissionCounter = 4'b0;
logic [1:0] timingCounter = 2'b0;
logic [9:0] shiftRegister = 10'b0;

always_ff @(posedge clk or negedge reset) begin
    if(!reset) begin
        clkCounter <= 1'b0;
        transmissionCounter <= 4'b0;
    end else begin
        case (clkCounter)
            1'b0: begin //idle
                if(we==1'b1) begin
                    uartTxPin <= 1'b0;
                    shiftRegister <= {1'b1, buffer, 1'b0};
                    clkCounter <= 1'b1; //transmit
                end
            end
            1'b1: begin //
                if (transmissionCounter == 4'd8) begin
                    clkCounter <= 1'b0; //idle
                    transmissionCounter <= 4'd0;
                end else begin
                    uartTxPin <= shiftRegister[transmissionCounter];
                    transmissionCounter <= transmissionCounter+1;
                end
            end
        endcase
    end
end
endmodule
