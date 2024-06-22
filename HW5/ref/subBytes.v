module subBytes (
    input [127:0] sub_in,
    output [127:0] sub_out
);

genvar idx;
generate
    for(idx=0;idx<128;idx=idx+8)begin
        sBox sb(.in(sub_in[idx +: 8]), .out(sub_out[idx +: 8]));
    end
endgenerate

endmodule