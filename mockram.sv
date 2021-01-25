/* verilator lint_off WIDTH */
module mockram(
    input var clock,
    input var [31:0]address,
    input var [3:0]byteena,
    input var [31:0]data,
    input var wren,
    output var [31:0]q
);
logic [31:0]ramdata[255:0];
always_ff @(posedge clock) begin
    if(wren==1'b1) begin
        ramdata[address] <= {(byteena>>3)&1==1 ? ((data>>24)&8'hff) : ((ramdata[address]>>24)&8'hff),
                             (byteena>>2)&1==1 ? ((data>>16)&8'hff) : ((ramdata[address]>>16)&8'hff),
                             (byteena>>1)&1==1 ? ((data>>8) &8'hff) : ((ramdata[address]>>8)&8'hff),
                             (byteena>>0)&1==1 ? ((data>>0) &8'hff) : ramdata[address]&8'hff};
    end
    q[7:0]   <= (byteena>>0)&1==1 ? ramdata[address]&8'hff : 0;
    q[15:8] <= (byteena>>1)&1==1 ? (ramdata[address]>>8)&8'hff : 0;
    q[23:16] <= (byteena>>2)&1==1 ? (ramdata[address]>>16)&8'hff : 0;
    q[31:24] <= (byteena>>3)&1==1 ? (ramdata[address]>>24)&8'hff : 0;
end
endmodule
