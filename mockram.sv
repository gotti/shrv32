/* verilator lint_off WIDTH */
module mockram(
    input var clock,
    input var [31:0]address,
    input var [3:0]byteena,
    input var [31:0]data,
    input var wren,
    output var [31:0]q
);
logic [31:0]romdata[7:0];
always_ff @(posedge clock) begin
    if(wren==1'b1) begin
        romdata[address] <= byteena&1==1 ? data&8'hff : romdata[address];
        romdata[address+1] <= (byteena>>1)&1==1 ? (data>>8)&8'hff : romdata[address+1];
        romdata[address+2] <= (byteena>>2)&1==1 ? (data>>16)&8'hff : romdata[address+2];
        romdata[address+3] <= (byteena>>3)&1==1 ? (data>>24)&8'hff : romdata[address+3];
    end
    q[7:0]   <= (byteena>>0)&1==1 ? (data>>0)&8'hff : romdata[address];
    q[15:8] <= (byteena>>1)&1==1 ? (data>>8)&8'hff : romdata[address+1];
    q[23:16] <= (byteena>>2)&1==1 ? (data>>16)&8'hff : romdata[address+2];
    q[31:24] <= (byteena>>3)&1==1 ? (data>>24)&8'hff : romdata[address+3];
end
endmodule
