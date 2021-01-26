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
always_ff @(posedge clock) begin
    if (uartRxPin==1'b0) begin
        if(receptionEnable==1'b0) begin
            receptionEnable <= 1'b1;
        end
    end else if (busy==1'b0) begin
        if(receptionEnable==1'b1) begin
            receptionEnable <= 1'b0;
        end
    end
end
always_ff @(posedge clock) begin
    if (receptionEnable==1'b1) begin
        if (divCounter==11'd104-1) begin //これで57600bps
            divCounter <= 11'd0;
            clk <= ~clk;
        end else begin
            divCounter <= divCounter+1;
        end
    end else begin
        divCounter <= 0;
        clk <= 0;
    end
end
logic [1:0] state, nextState;
logic [3:0] receptionCounter, nextReceptionCounter;
logic [1:0] timingCounter, nextTimingCounter;
logic [9:0] register, nextRegister;
logic [7:0] nextBuffer;
always_comb begin
    busy = 1'b0;
    fin = 1'b0;
    nextRegister = register;
    nextState = state;
    nextBuffer = buffer;
    nextReceptionCounter = receptionCounter;
    case (state)
        2'd0: begin //idle
            if(uartRxPin==1'b0) begin //start bit
                busy = 1'b1;
                nextReceptionCounter = 4'd0;
                nextRegister = {uartRxPin,register[9:1]};
                nextState = 2'd2;
            end
        end
        2'd2: begin
            busy = 1'b1;
            if (receptionCounter == 4'd9) begin
                nextState = 2'd3; //fin
                nextReceptionCounter = 4'd0;
                nextBuffer = register[8:1];
            end else begin
                nextRegister = {uartRxPin,register[9:1]};
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
        buffer <= nextBuffer;
        receptionCounter <= nextReceptionCounter;
    end
end
endmodule
