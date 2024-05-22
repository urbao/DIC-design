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
reg [7:0] LENGTH; // length of Queue
reg [7:0] ii;  // ii is the idx from length//2 down to 1
reg [7:0] idx;
reg [7:0] largest;
reg [7:0] output_idx; // used at output state
reg [7:0] increase_idx; // used at increase_val state
reg [7:0] parent_idx; // used at increase_val state

// FSM variable
reg [2:0] currState, nextState;
parameter [2:0] READ_DATA=3'b000,
                BUILD_QUEUE=3'b001,
                EXTRACT_MAX=3'b010,
                INCREASE_VAL=3'b011,
                INSERT_DATA=3'b100,
                WRITE=3'b101;

// sequential circuit
always @(posedge clk or posedge rst)begin
    if(rst)begin
        LENGTH <= 0;
        output_idx <= 1;
        currState <= READ_DATA;
        nextState <= BUILD_QUEUE;
    end
    else begin
        // READ_DATA state
        if(currState==READ_DATA)begin
            if(data_valid)begin
                Queue[LENGTH+1] <= data;
                LENGTH <= LENGTH+1;
            end
            else begin
                busy <= 0;
                ii <= (LENGTH >> 1); // update ii before executing commands
                idx <= (LENGTH >> 1);
                currState <= nextState;
            end
        end
        // BUILD_QUEUE state
        else if(currState==BUILD_QUEUE)begin
            // end the build queue process
            if(ii==0)begin
                busy <= 0;
                currState <= nextState;
            end
            else begin
                if((idx << 1)<=LENGTH && Queue[idx << 1]>Queue[idx])begin
                    largest = (idx << 1);
                end
                else begin
                    largest = idx;
                end
                if((idx << 1)+1<=LENGTH && Queue[(idx << 1)+1]>Queue[largest])begin
                    largest = (idx << 1)+1;
                end
                if(largest!=idx)begin
                    Queue[idx] <= Queue[largest];
                    Queue[largest] <= Queue[idx];
                    idx <= largest;
                end
                else begin
                    ii <= ii-1;
                    idx <= ii-1;
                end 
            end
        end
        // EXTRACT_MAX state
        else if(currState==EXTRACT_MAX)begin
            // exchange the last node's data with root's data
            Queue[1] <= Queue[LENGTH];
            LENGTH <= LENGTH-1;
            // max-heapify again
            ii <= 1;
            idx <= 1;
            currState <= BUILD_QUEUE;
        end
        // INCREASE_VAL state
        else if(currState==INCREASE_VAL)begin
            if(increase_idx>1 && Queue[parent_idx]<Queue[increase_idx])begin
                Queue[parent_idx] <= Queue[increase_idx];
                Queue[increase_idx] <= Queue[parent_idx];
                increase_idx <= parent_idx;
                parent_idx <= (parent_idx >> 1);
            end
            else begin
                busy <= 0;
                currState <= nextState;
            end
        end
        //  INSERT_DATA state
        else if(currState==INSERT_DATA)begin
            

        end
        // WRITE state
        else begin
            if(output_idx>LENGTH)begin
                busy <= 0;
                done <= 1;
                RAM_valid <= 0;
                currState <= nextState;
            end
            else begin
                RAM_valid <= 1;
                RAM_A <= output_idx-1; // since testbench RAM address starts from 0
                RAM_D <= Queue[output_idx];
                output_idx <= output_idx+1; 
            end
        end
    end
end

// output logic
always @(currState)begin
    busy = 1;
    if(currState==READ_DATA)begin
        increase_idx = 1;
        parent_idx = 1;
        Queue[index] = Queue[index];
    end
    else if(currState==BUILD_QUEUE)begin
        increase_idx = 1;
        parent_idx = 1;
        Queue[index] = Queue[index];
    end
    else if(currState==EXTRACT_MAX)begin
        increase_idx = 1;
        parent_idx = 1;
        Queue[index] = Queue[index];
    end
    else if(currState==INCREASE_VAL)begin
        increase_idx = index;
        parent_idx = (index >> 1);
        Queue[index] = value;
    end
    else if(currState==INSERT_DATA)begin
        increase_idx = 1;
        parent_idx = 1;
        Queue[index] = Queue[index];
    end
    else begin
        increase_idx = 1;
        parent_idx = 1;
        Queue[index] = Queue[index];
    end
end

// nextState logic
always @(cmd)begin
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