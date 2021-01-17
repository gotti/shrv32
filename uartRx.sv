module uartRx(
    input var logic clock,
    input var logic reset,
    input var logic uartRxPin,
    output var logic [7:0]buffer,
    output var logic fin
);
logic busy;
logic clk;
logic receptionEnable;
logic [10:0]divCounter = 11'b0;
always_ff @(negedge uartRxPin or negedge busy) begin
    if (uartRxPin==1'b0) begin
        if(receptionEnable==1'b0) begin
            receptionEnable <= 1'b1;
        end
    end
    if (busy==1'b0) begin
        if(receptionEnable==1'b1) begin
            receptionEnable <= 1'b0;
        end
    end
end
always_ff @(posedge clock) begin
    if (receptionEnable==1'b1) begin
        if (divCounter==11'd52-1) begin //CYC1000は12MHzなはずなのになんで？これで115200
            divCounter <= 11'd0;
            clk <= ~clk;
        end else begin
            divCounter <= divCounter+1;
        end
    end else begin
        divCounter <= 0;
    end
end
logic [1:0] state, nextState;
logic [3:0] receptionCounter, nextReceptionCounter;
logic [1:0] timingCounter, nextTimingCounter;
logic [9:0] register, nextRegister;
assign buffer = register[8:1];
always_comb begin
    busy = 1'b0;
    fin = 1'b0;
    nextRegister = register;
    nextState = state;
    nextReceptionCounter = receptionCounter;
    case (state)
        2'd0: begin //idle
            if(uartRxPin==1'b0) begin //start bit
                busy = 1'b1;
                nextReceptionCounter = 4'd0;
                nextRegister = {uartRxPin,register[9:1]};
                nextState = 2'd2; //startbit
            end
        end
        2'd2: begin
            busy = 1'b1;
            nextRegister = {uartRxPin,register[9:1]};
            if (receptionCounter == 4'd8) begin
                nextState = 2'd3; //fin
                nextReceptionCounter = 4'd0;
            end else begin
                nextReceptionCounter = receptionCounter+1;
            end
        end
        2'd3: begin
            fin = 1'b1;
            busy = 1'b1;
            nextState = 2'd0;
            nextReceptionCounter = 0;
        end
        default: begin
        end
    endcase
end

always_ff @(posedge clk or negedge reset) begin
    if(!reset) begin
        state <= 2'b0;
        receptionCounter <= 4'b0;
    end else begin
        state <= nextState;
        register <= nextRegister;
        receptionCounter <= nextReceptionCounter;
    end
end
endmodule