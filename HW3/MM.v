`timescale 1ns/10ps
module MM( in_data, col_end, row_end, is_legal, out_data, rst, clk , change_row,valid,busy);
input clk;
input rst;
input col_end;
input row_end;
input [7:0]in_data;

output reg signed [19:0]out_data;
output is_legal;
output reg change_row,valid,busy;

/* ======= variables initialization ======= */
// record the row and col count in mat1 and mat2
// purpose: used to check if the matrix multiplicable and understand the shape of matrix
reg [1:0] row_1, col_1, row_2, col_2;
// matrix definition
reg [7:0] mat1[0:3][0:3];
reg [7:0] mat2[0:3][0:3];

/* ======= finite state machine definition ======= */
parameter [1:0] IDLE=2'b00,
                MAT1_READ=2'b01,
                MAT2_READ=2'b10,
                OUTPUT=2'b11;
reg [1:0] currState, nextState;

/*------------------Main Code---------------------*/
// currState register
always @(posedge clk)begin
    
end

// nextState register
always @(currState)begin
    case (currState)
        IDLE: nextState = MAT1_READ;
        MAT1_READ: nextState = MAT2_READ;
        MAT2_READ: nextState = OUTPUT;
        OUTPUT: nextState = IDLE;
        default: nextState = MAT1_READ; // currState default to IDLE state, so nextState should be MAT1_READ state
    endcase
end

endmodule
