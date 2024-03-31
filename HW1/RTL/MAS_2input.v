// 
// Designer: E24094198 Eason Chen
//
module MAS_2input(Din1, Din2, Sel, Q, Tcmp, TDout, Dout);
input signed [4:0]Din1;
input signed [4:0]Din2;
input [1:0]Sel;
input signed[4:0]Q;
output [1:0]Tcmp;
output signed [4:0]TDout;
output signed [3:0]Dout;

// store the 5-bit result temporarily
wire signed [4:0] tmpResult;

/*Write your design here*/
ALU alu_1(.In1(Din1), .In2(Din2), .Sel(Sel), .Out(TDout));
QComp q_comparator(.Din(TDout), .Q(Q), .Out(Tcmp));
ALU alu_2(.In1(TDout), .In2(Q), .Sel(Tcmp), .Out(tmpResult));

// discard the MSB bit and assign final-result to Dout
assign Dout=tmpResult[3:0];

endmodule

/*======= Below is some sub-modules =======*/

/* ALU module */
module ALU(In1, In2, Sel, Out);
input signed[4:0] In1;
input signed[4:0] In2;
input[1:0] Sel;
output signed[4:0] Out;

/* assign method to update Out value */
assign Out=(Sel==2'b00)?(In1+In2):
           (Sel==2'b11)?(In1-In2):
           In1;
endmodule

/* Q Comparator module */
module QComp(Din, Q, Out);
input signed[4:0] Din;
input signed[4:0] Q;
output [1:0] Out;

// zero-comparison for LSB
assign Out[0]=(Din>=0);
// Q-comparison for MSB
assign Out[1]=(Din>=Q);
endmodule