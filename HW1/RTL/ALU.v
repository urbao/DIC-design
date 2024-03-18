module ALU(
    input signed [4:0]In1,
    input signed [4:0]In2,
    input [1:0]Sel,
    output signed [4:0]Out
);

/* assign method to update Out value */
assign Out=(Sel==2'b00)?(In1+In2):
           (Sel==2'b11)?(In1-In2):
           In1;

endmodule