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


// FSM variable
reg [2:0] currState, nextState;
parameter [2:0] READ_DATA=3'b000,
                WAIT_CMD=3'b001,
                BUILD_QUEUE=3'b010,
                EXTRACT_MAX=3'b011,
                INCREASE_VAL=3'b100,
                INSERT_DATA=3'b101,
                WRITE=3'b110;

// sequential circuit
always @(posedge clk or posedge rst)begin
    if(rst)begin
        LENGTH <= 0;
        currState <= READ_DATA;
    end
    else begin
        // READ_DATA state
        if(currState==READ_DATA)begin
            if(data_valid)begin
                Q[LENGTH+1'b1] <= data;
                LENGTH <= LENGTH+1'b1;
            end
            else begin
                currState <= WAIT_CMD;
            end
        end
        // WAIT_CMD state
        else if(currState==WAIT_CMD)begin
            if(nextState==BUILD_QUEUE)begin
                idx1 <= (LENGTH>>1);
                idx2 <= (LENGTH>>1);
            end
            if(nextState==INCREASE_VAL)begin
                idx1 <= index;
                idx2 <= (index>>1);
                Q[index] <= value;
            end
            if(nextState==INSERT_DATA)begin
                LENGTH <= LENGTH+1'b1;
                idx1 <= LENGTH+1'b1;
                idx2 <= ((LENGTH+1'b1)>>1);
                Q[LENGTH+1'b1] <= value;
            end
            if(nextState==WRITE)begin
                idx1 <= 1;
            end
            currState <= nextState;
        end
        // BUILD_QUEUE state
        else if(currState==BUILD_QUEUE)begin
            if(idx1==0)begin
                currState <= WAIT_CMD;
            end
            else begin
                if((idx2<<1)<=LENGTH && Q[idx2<<1]>Q[idx2])begin
                    largest = (idx2<<1);
                end
                else begin
                    largest = idx2;
                end
                if((idx2<<1)+1'b1<=LENGTH && Q[(idx2<<1)+1'b1]>Q[largest])begin
                    largest = (idx2<<1)+1'b1;
                end
                if(largest!=idx2)begin
                    Q[idx2] <= Q[largest];
                    Q[largest] <= Q[idx2];
                    idx2 <= largest;
                end
                else begin
                    idx1 <= idx1-1'b1;
                    idx2 <= idx1-1'b1;
                end
            end
        end
        // EXTRACT_MAX state
        else if(currState==EXTRACT_MAX)begin
            Q[1] <= Q[LENGTH];
            LENGTH <= LENGTH-1'b1;
            idx1 <= 1;
            idx2 <= 1;
            currState <= BUILD_QUEUE;
        end
        // INCREASE_VAL state
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
        else if(currState==INSERT_DATA)begin
            currState <= INCREASE_VAL;
        end
        // WRITE state
        else begin
            if(idx1>LENGTH)begin
                done <= 1;
                RAM_valid <= 0;
                currState <= WAIT_CMD;
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

always @(currState)begin
    if(currState==WAIT_CMD)begin
        busy = 0;
    end
    else begin
        busy = 1;
    end
end


// nextState logic
always @(*)begin
    if(cmd_valid==1)begin
        case (cmd)
            3'b000: nextState = BUILD_QUEUE;
            3'b001: nextState = EXTRACT_MAX;
            3'b010: nextState = INCREASE_VAL;
            3'b011: nextState = INSERT_DATA;
            3'b100: nextState = WRITE;
            default: nextState = BUILD_QUEUE;
        endcase
    end
    else nextState = BUILD_QUEUE;
end

endmodule