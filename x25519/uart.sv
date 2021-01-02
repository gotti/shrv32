module uartRx(
        input var logic clock,
        input var logic reset,
        output var logic [7:0]buffer
);
logic [1:0] clockCounter = 2'b0;
// idle
// wait to receive
// receive
logic [3:0] receiveCounter = 4'b0;
logic [1:0] timingCounter = 2'b0;

always_ff @(posedge clock or negedge reset) begin
    if(!reset) begin
        clockCounter <= 2'b0;
        receiveCounter <= 4'b0;
    end else begin
        case ()
                'b0: begin
                        
                        end
                        default : begin
                                
                                end
                        endcase
    end
end

endmodule;

module uartTx(
        input var logic va
);
endmodule;
