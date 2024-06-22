module mixColumns_tb;
reg [0:127] in;

wire [0:127] out;	


mixColumns m (in,out);


initial begin
$monitor("input= %H , output= %h",in,out);
in= 128'hd4bf5d30e0b452aeb84111f11e2798e5 ;
end
endmodule