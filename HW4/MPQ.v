module MPQ(clk,rst,data_valid,data,cmd_valid,cmd,index,value,busy,RAM_valid,RAM_A,RAM_D,done);
input clk;
input rst;
input data_valid;
input [7:0] data;
input cmd_valid;
input [2:0] cmd;
input [7:0] index;
input [7:0] value;
output reg busy;
output reg RAM_valid;
output reg [7:0]RAM_A;
output reg [7:0]RAM_D;
output reg done;

/*------------ Max-Priority Queue related varaibles -------------*/
// Since the Queue of pseudo-code provided by TAs starts from index 1,
// the Queue[0] is left unused, and  Queue[1] to Queue[255] are used
reg [7:0] Queue[0:255]; // store input value
reg [7:0] LENGTH; // length of Queue(Queue[0] is ignored), maximum to 255

endmodule