module shiftRows (
    input [0:127] shift_in,
    output [0:127] shift_out
);
// 1st row doesn't need to shift
assign shift_out[0+:8] = shift_in[0+:8];
assign shift_out[32+:8] = shift_in[32+:8];
assign shift_out[64+:8] = shift_in[64+:8];
assign shift_out[96+:8] = shift_in[96+:8];
	
// 2nd row shift to left for 1 cell
assign shift_out[8+:8] = shift_in[40+:8];
assign shift_out[40+:8] = shift_in[72+:8];
assign shift_out[72+:8] = shift_in[104+:8];
assign shift_out[104+:8] = shift_in[8+:8];
	
// 3rd row shift to left for 2 cell
assign shift_out[16+:8] = shift_in[80+:8];
assign shift_out[48+:8] = shift_in[112+:8];
assign shift_out[80+:8] = shift_in[16+:8];
assign shift_out[112+:8] = shift_in[48+:8];
	
// 4th row shift to left for 3 cell
assign shift_out[24+:8] = shift_in[120+:8];
assign shift_out[56+:8] = shift_in[24+:8];
assign shift_out[88+:8] = shift_in[56+:8];
assign shift_out[120+:8] = shift_in[88+:8];

endmodule