module mmu(
    input var logic clock,
    input var logic [31:0]vaddr,
    input var logic [31:0]data,
    input var logic [3:0]byteena,
    input var logic memWE,
    output var logic memWait,
    output var logic [31:0]q );
logic [31:0]SPTBR=32'h10;
logic [2:0]counter=3'b0;
logic [31:0]memaddr;
logic [31:0]memout;
logic [11:0]ppn1;
always_ff @(posedge clock) begin
    case (counter)
        //calculate vpn1
        3'd0: begin
            memaddr <= {20'b0,vaddr[31:22],2'b0} + SPTBR;
            counter <= counter+1;
            memWait <= 1'b1;
        end
        3'd1: begin
            if (memout[0]==1'b0 || (memout[1]==0 && memout[2]==1)) begin
                //TODO stop and raise a page-fault exception
                memWait <= 1'b0;
            end else if(memout[1]==1 && memout[2]==1) begin
                //TODO valid, however, in my implementation, this is a bug.
                memWait <= 1'b0;
            end else begin
                ppn1 <= memout[31:20];
                memaddr <= {8'b0,memout[31:10],2'b0} + {20'b0,vaddr[21:12],2'b0};
            end
        end
        3'd2: begin
            if (memout[0]==1'b0 || (memout[1]==0 && memout[2]==1)) begin
                //TODO stop and raise a page-fault exception
                memWait <= 1'b0;
            end else if(memout[1]==1 && memout[2]==1) begin
                //TODO check permisson
                memaddr[31:22] <= ppn1[9:0];//TODO physical memory width is 34bit, however, I remove 2bit
                memaddr[21:12] <= memout[19:10];
                memaddr[11:0] <= vaddr[11:0];
            end else begin
                memWait <= 1'b0;
                //TODO bug?
                //memaddr <= {8'b0,memout[31:10],2'b0} + {20'b0,vaddr[21:12],2'b0};
            end
            memWait <= 1'b0;
        end
        default : begin
                memWait <= 1'b0;
                end
        endcase
end
mockram ram(
    .clock(clock),
    .address(memaddr),
    .byteena(byteena),
    .data(data),
    .wren(memWE),
    .q(memout)
);
endmodule
