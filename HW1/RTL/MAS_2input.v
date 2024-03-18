// 
// Designer: E24094198 Eason Chen
//
module MAS_2input(
    input signed [4:0]Din1,
    input signed [4:0]Din2,
    input [1:0]Sel,
    input signed[4:0]Q,
    output [1:0]Tcmp,
    output signed [4:0]TDout,
    output signed [3:0]Dout
);

// store the 5-bit result temporarily
wire signed [4:0] tmpResult;

/*Write your design here*/
ALU alu_1(
    .In1(Din1),
    .In2(Din2),
    .Sel(Sel),
    .Out(TDout)
);

QComp q_comparator(
    .Din(TDout),
    .Q(Q),
    .Out(Tcmp)
);

ALU alu_2(
    .In1(TDout),
    .In2(Q),
    .Sel(Tcmp),
    .Out(tmpResult)
);

// discard the MSB bit and assign final-result to Dout
assign Dout=tmpResult[3:0];

endmodule