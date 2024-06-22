module nineRound(
    input [127:0] in,
    input [127:0] key,
    input [3:0] round_i,
    output [127:0] out,
    output [127:0] key_out
);

wire [127:0] afterSubBytes;
wire [127:0] afterShiftRows;
wire [127:0] afterMixColumns;
wire [127:0] afterAddRoundKey;

subBytes sb(.sub_in(in), .sub_out(afterSubBytes));
shiftRows sr(.shift_in(afterSubBytes), .shift_out(afterShiftRows));
mixColumns mc(.mix_in(afterShiftRows), .mix_out(afterMixColumns));
keyExpansion ke(.key_in(key), .round_i(round_i), .key_out(key_out));
addRoundKey ar(.state(afterMixColumns), .key(key_out), .out(out));

endmodule