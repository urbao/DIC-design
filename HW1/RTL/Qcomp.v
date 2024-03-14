module QComp(
    input signed [4:0]Din,
    input signed [4:0]Q,
    output [1:0]Out
);
// zero-comparison for LSB
assign Out[0]=(Din>5'b00000);

// Q-comparison for MSB
assign Out[1]=(Din>Q);

endmodule