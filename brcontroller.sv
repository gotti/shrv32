module brcontroller(
    input logic [31:0]cond,
    input logic [31:0]address,
    output logic [31:0]out );

always_comb begin
    out = address;
end

endmodule
