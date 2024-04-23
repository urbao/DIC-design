`timescale 1ns/10ps
module MM( in_data, col_end, row_end, is_legal, out_data, rst, clk , change_row,valid,busy);
input       clk;
input       rst;
input       col_end;
input       row_end;
input [7:0] in_data;

output reg signed [19:0] out_data;
output is_legal;
output reg change_row,valid,busy;

endmodule
