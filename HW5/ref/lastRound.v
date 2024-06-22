module lastRound (
    input [127:0] in,
    input [127:0] key,
    input [3:0] round_i,
    output [127:0] out
);

wire [127:0] afterSubBytes;
wire [127:0] afterShiftRows;
wire [127:0] key_after;
wire [127:0] afterAddRoundKey;

subBytes sb(.sub_in(in), .sub_out(afterSubBytes));
shiftRows sr(.shift_in(afterSubBytes), .shift_out(afterShiftRows));
keyExpansion ke(.key_in(key), .round_i(round_i), .key_out(key_after));
addRoundKey ar(.state(afterShiftRows), .key(key_after), .out(out));
    
endmodule