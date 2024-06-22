// 
// Designer: E24094198 陳育政 
//
module AES(
    input clk,
    input rst,
    input [127:0] P,
    input [127:0] K,
    output reg [127:0] C,
    output reg valid
    );

// used to save each round result
reg [127:0] state[0:10];
reg [127:0] key[0:8];

// used to record the count of cycle
// when the cycle_count >= 10, enable the valid signal
reg [3:0] cycle_count;

assign C = state[10];

// main code
addRoundKey ar0(.state(P), .key(K), .out(state[0]));
lastRound r10(.in(state[9]), .key(key[8]), .round_i(4'b1010), .out(state[10]));
nineRound  r9(.in(state[8]), .key(key[7]), .round_i(4'b1001), .out(state[9]), .key_out(key[8]));
nineRound  r8(.in(state[7]), .key(key[6]), .round_i(4'b1000), .out(state[8]), .key_out(key[7]));
nineRound  r7(.in(state[6]), .key(key[5]), .round_i(4'b0111), .out(state[7]), .key_out(key[6]));
nineRound  r6(.in(state[5]), .key(key[4]), .round_i(4'b0110), .out(state[6]), .key_out(key[5]));
nineRound  r5(.in(state[4]), .key(key[3]), .round_i(4'b0101), .out(state[5]), .key_out(key[4]));
nineRound  r4(.in(state[3]), .key(key[2]), .round_i(4'b0100), .out(state[4]), .key_out(key[3]));
nineRound  r3(.in(state[2]), .key(key[1]), .round_i(4'b0011), .out(state[3]), .key_out(key[2]));
nineRound  r2(.in(state[1]), .key(key[0]), .round_i(4'b0010), .out(state[2]), .key_out(key[1]));
nineRound  r1(.in(state[0]), .key(K),      .round_i(4'b0001), .out(state[1]), .key_out(key[0]));


// Sequential Logic
always @(posedge clk)begin
    if(rst)begin
        valid <= 0;
        cycle_count <= 0;
    end
    else begin
        // enable the valid signal or update the cycle_count
        if(cycle_count == 0)valid <= 1;
        else cycle_count <= cycle_count+1'b1;
    end
end



endmodule