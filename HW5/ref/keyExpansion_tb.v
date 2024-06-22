module keyExpansion_tb;
reg [127:0] k1;
wire[127:0] out1;


keyExpansion ks(k1, 4'b0001, out1);

initial begin
$monitor("k1= %h , out= %h",k1, out1);
k1=128'h2b7e151628aed2a6abf7158809cf4f3c;
// $monitor("k192= %h , out192= %h",k2,out2);
// k2=192'h_00010203_04050607_08090a0b_0c0d0e0f_10111213_14151617;


end
endmodule