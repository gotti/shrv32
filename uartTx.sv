module uartTx(
    input var logic clock,
    input var logic reset,
    input var logic [7:0]buffer,
    input var logic we,
    output var logic uartTxPin,
    output var logic busy2
);
logic clk;
logic [10:0]divCounter = 11'b0;
logic lwe;
logic busy;
always_ff @(posedge clock) begin
    if (we==1'b1 && busy==1'b0) begin
        lwe <= 1'b1;
        txBuffer <= {1'b1, buffer, 1'b0};
    end else if(we==1'b0 && busy==1'b0) begin
        lwe <= 1'b0;
    end
    if (divCounter==11'd104-1) begin //57600 bps
        divCounter <= 11'd0;
        clk <= ~clk;
    end else begin
        divCounter <= divCounter+1;
    end
end
logic [1:0] state, nextState;
// idle
// transmit
logic [3:0] transmissionCounter, nextTransmissionCounter;
logic [1:0] timingCounter, nextTimingCounter;
logic [9:0] txBuffer, register, nextRegister;
/*
logic lwe;
always_ff @(posedge we or negedge busy) begin
    if(we==1'b1) begin
        lwe <= 1;
        txBuffer = {1'b1, buffer, 1'b0};
    end else if(busy==1'b0) begin
        lwe <= 0;
    end
end
*/
always_comb begin
    busy2 = 1'b0;
    uartTxPin = 1'b1;
    nextRegister = register;
    nextState = state;
    nextTransmissionCounter = transmissionCounter;
    case (state)
        2'd0: begin //idle
            if(lwe==1'b1) begin
                busy = 1'b1;
                busy2 = 1'b1;
                nextRegister = txBuffer;
                nextState = 2'd1; //startbit
            end else begin
                busy = 1'b0;
                busy2 = 1'b0;
            end
        end
        2'd1: begin
                busy2 = 1'b1;
                busy = 1'b1;
                nextState = 2'd2; //transmit
        end
        2'd2: begin //
            busy = 1'b1;
            busy2 = 1'b1;
            if (transmissionCounter == 4'd9) begin
                nextState = 2'd3; //fin
                nextTransmissionCounter = 4'd0;
            end else begin
                uartTxPin = register[0];
                nextRegister = {1'b1,register[9:1]};
                nextTransmissionCounter = transmissionCounter+1;
            end
        end
        2'd3: begin
            busy2 = 1'b1;
            busy = 1'b0;
            nextState = 2'd0;
            nextTransmissionCounter = 0;
        end
        default: begin
        end
    endcase
end

always_ff @(posedge clk or negedge reset) begin
    if(!reset) begin
        state <= 2'b0;
        transmissionCounter <= 4'b0;
    end else begin
        state <= nextState;
        register <= nextRegister;
        transmissionCounter <= nextTransmissionCounter;
    end
end
endmodule
