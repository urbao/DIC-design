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
// the Q[0] is left unused, and  Q[1] to Q[255] are used
reg [7:0] Q[0:255]; // store input value
reg [7:0] LENGTH; // length of Q

/*
In order to reduce the usage of registers, I only create 3 registers, and idx1 and idx2 are shared with different states.
*/
reg [7:0] idx1;
reg [7:0] idx2;
reg [7:0] largest;

reg [7:0] right;
reg [7:0] left;

// FSM variable
reg [2:0] currState, nextState;
parameter [2:0] READ_DATA=3'b000,
                WAIT_CMD=3'b001,
                BUILD_QUEUE_1=3'b010,
                BUILD_QUEUE_2=3'b011,
                EXTRACT_MAX=3'b100,
                INCREASE_VAL=3'b101,
                INSERT_DATA=3'b110,
                WRITE=3'b111;

// sequential circuit
always @(posedge clk or posedge rst) begin
    if(rst)begin
        LENGTH <= 0;
        idx1 <= 1;
        done <= 0;
        RAM_A <= 0;
        RAM_D <= 0;
        currState <= READ_DATA;
    end
    else begin
        // READ_DATA
        if(currState==READ_DATA)begin
            if(data_valid)begin
                Q[idx1] <= data;
                LENGTH <= LENGTH+1'b1;
                idx1 <= idx1+1'b1;
            end
            else begin
                currState <= nextState;
            end
        end
        // WAIT_CMD
        else if(currState==WAIT_CMD)begin
            if(nextState==BUILD_QUEUE_1)begin
                idx1 <= (LENGTH>>1);
                idx2 <= (LENGTH>>1);
            end
            else if(nextState==EXTRACT_MAX)begin
                Q[1] <= Q[LENGTH];
                LENGTH <= LENGTH-1'b1;
                idx1 <= 1;
                idx2 <= 1;
            end
            else if(nextState==INCREASE_VAL)begin
                idx1 <= index;
                idx2 <= (index>>1);
                Q[index] <= value;
            end
            else if(nextState==INSERT_DATA)begin
                idx1 <= LENGTH+1'b1;
                idx2 <= (LENGTH+1'b1)>>1;
                LENGTH <= LENGTH+1'b1;
                Q[LENGTH+1'b1] <= value;
            end
            else if(nextState==WRITE)begin
                idx1 <= 1;
            end
            else begin
                done <= 0;
            end
            currState <= nextState;
        end
        else if(currState==BUILD_QUEUE_1)begin
            if(idx1==0)begin
                currState <= nextState;
            end
            else begin
                left = idx2<<1;
                right = (idx2<<1)+1'b1;
                largest = idx2;
                if(left<=LENGTH && Q[left]>Q[idx2])begin
                    largest = left;
                end
                if(right<=LENGTH && Q[right]>Q[largest])begin
                    largest = right;
                end
                currState <= BUILD_QUEUE_2;
            end
        end
        else if(currState==BUILD_QUEUE_2)begin
            if(largest!=idx2)begin
                Q[idx2] <= Q[largest];
                Q[largest] <= Q[idx2];
                idx2 <= largest;
            end
            else begin
                idx1 <= idx1-1'b1;
                idx2 <= idx1-1'b1;
            end
            currState <= BUILD_QUEUE_1;
        end
        // EXTRACT_MAX
        else if(currState==EXTRACT_MAX)begin
            currState <= BUILD_QUEUE_1;
        end
        // INCREASE_VAL
        else if(currState==INCREASE_VAL)begin
            if(idx1>1 && Q[idx2]<Q[idx1])begin
                Q[idx2] <= Q[idx1];
                Q[idx1] <= Q[idx2];
                idx1 <= idx2;
                idx2 <= (idx2>>1);
            end
            else begin
                currState <= nextState;
            end
        end
        // INSERT_DATA
        else if(currState==INSERT_DATA)begin
            currState <= INCREASE_VAL;  
        end
        // WRITE
        else begin
            // $display("write", Q[0], Q[1], Q[2], Q[3], Q[4], Q[5], Q[6], Q[7], Q[8], Q[9], Q[10], Q[11], Q[12]);
            if(idx1>LENGTH)begin
                done <= 1;
                RAM_valid <= 0;
                currState <= nextState;
            end
            else begin
                RAM_valid <= 1;
                RAM_A <= idx1-1'b1;
                RAM_D <= Q[idx1];
                idx1 <= idx1+1'b1;
            end
        end
    end
end

// output logic
always @(*)begin
    if(currState==WAIT_CMD)begin
        busy = 0;
    end
    else begin
        busy = 1;
    end
end

// nextState logic
always @(*)begin
    if(cmd_valid)begin
        if(cmd==3'b000)begin
            nextState = BUILD_QUEUE_1;
        end
        else if(cmd==3'b001)begin
            nextState = EXTRACT_MAX;
        end
        else if(cmd==3'b010)begin
            nextState = INCREASE_VAL;
        end
        else if(cmd==3'b011)begin
            nextState = INSERT_DATA;
        end
        else if(cmd==3'b100)begin
            nextState = WRITE;
        end
        else begin
            nextState = BUILD_QUEUE_1;
        end
    end
    else begin
        nextState = WAIT_CMD;
    end
end

endmodule