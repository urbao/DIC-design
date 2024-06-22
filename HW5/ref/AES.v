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
wire [127:0] state[0:10];
wire [127:0] key[0:8];

reg [127:0] ss[0:8];
reg [127:0] kk[0:8];

// used to record the count of cycle
// when the cycle_count >= 10, enable the valid signal
reg [3:0] cycle_count;

// main code
addRoundKey ar0(.state(P), .key(K), .out(state[0]));
lastRound r10(.in(ss[8]), .key(kk[8]), .round_i(4'b1010), .out(state[10]));
nineRound  r9(.in(ss[7]), .key(kk[7]), .round_i(4'b1001), .out(state[9]), .key_out(key[8]));
nineRound  r8(.in(ss[6]), .key(kk[6]), .round_i(4'b1000), .out(state[8]), .key_out(key[7]));
nineRound  r7(.in(ss[5]), .key(kk[5]), .round_i(4'b0111), .out(state[7]), .key_out(key[6]));
nineRound  r6(.in(ss[4]), .key(kk[4]), .round_i(4'b0110), .out(state[6]), .key_out(key[5]));
nineRound  r5(.in(ss[3]), .key(kk[3]), .round_i(4'b0101), .out(state[5]), .key_out(key[4]));
nineRound  r4(.in(ss[2]), .key(kk[2]), .round_i(4'b0100), .out(state[4]), .key_out(key[3]));
nineRound  r3(.in(ss[1]), .key(kk[1]), .round_i(4'b0011), .out(state[3]), .key_out(key[2]));
nineRound  r2(.in(ss[0]), .key(kk[0]), .round_i(4'b0010), .out(state[2]), .key_out(key[1]));
nineRound  r1(.in(state[0]), .key(K),  .round_i(4'b0001), .out(state[1]), .key_out(key[0]));


// Sequential Logic
always @(posedge clk)begin
    if(rst)begin
        valid <= 0;
        cycle_count <= 0;
        ss[0]  <= 0; ss[1] <= 0; ss[2] <= 0; ss[3] <= 0; ss[4] <= 0;
        ss[5]  <= 0; ss[6] <= 0; ss[7] <= 0; ss[8] <= 0;
        kk[0]  <= 0; kk[1] <= 0; kk[2] <= 0; kk[3] <= 0; kk[4] <= 0; 
        kk[5]  <= 0; kk[6] <= 0; kk[7] <= 0; kk[8] <= 0;
    end
    else begin
        // enable the valid signal or update the cycle_count
        if(cycle_count == 10)begin
            C <= state[10];
            valid <= 1;
        end
        else cycle_count <= cycle_count+1'b1;

         // Pipeline
        ss[0] <= state[1];
        ss[1] <= state[2];
        ss[2] <= state[3];
        ss[3] <= state[4];
        ss[4] <= state[5];
        ss[5] <= state[6];
        ss[6] <= state[7];
        ss[7] <= state[8];
        ss[8] <= state[9];

        kk[0] <= key[0];
        kk[1] <= key[1];
        kk[2] <= key[2];
        kk[3] <= key[3];
        kk[4] <= key[4];
        kk[5] <= key[5];
        kk[6] <= key[6];
        kk[7] <= key[7];
        kk[8] <= key[8];
    end
end



endmodule