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


localparam
    reset    = 0,
    load     = 1, // load the queue data
    wait_cmd = 2,
    heapify  = 3, // used for `extract_max` and `build_queue`
    build    = 4,
    extract  = 5,
    insert   = 6, // use cmd[0] to identify is `insert_data` or `increase_value`
    while_0  = 7,
    write    = 8;

// ret_state: return state used to return when the heapify operation is done
reg[3:0] state, nxt_state, ret_state;
reg[7:0] A[0:255];
reg[7:0] num, build_i, left, right, largest;
reg[7:0] index_tmp;
reg[7:0] value_tmp;
reg is_insert;
wire [7:0] index_tmp_parent = index_tmp >> 1; // find the parent index of index_tmp for the increase_value while loop purpose
wire [7:0] RAM_A_plus2 = RAM_A + 2;
wire inc_continue = (index_tmp > 1) && (A[index_tmp_parent] < A[index_tmp]); // while loop termainated condition of `increase_value` function

// async reset operation for the state assignment
always @(posedge clk, posedge rst)
    if(rst) state <= reset;
    else    state <= nxt_state;

// Next State logic
always @(*) begin
    case(state)
        reset : nxt_state = load;
        load : begin
            // keep loading data until data_valid is 0
            if(!data_valid)
                nxt_state = wait_cmd;
            else
                nxt_state = load;
        end         
        wait_cmd : begin
            // update Next State based on the cmd and cmd_valid
            if(!cmd_valid)
                nxt_state = wait_cmd;
            else begin
                case(cmd)
                    0 : nxt_state = build;
                    1 : nxt_state = extract;
                    2 : nxt_state = insert;
                    3 : nxt_state = insert;
                    default : nxt_state = write;
                endcase
            end
        end
        heapify : begin
            if(index_tmp == largest)
                nxt_state = ret_state; // if index_tmp==largest, return basde on ret_state(defined in heapfiy operation down below)
            else
                nxt_state = heapify; // if index_tmp!=largest, keep heapify
        end
        build : begin
            nxt_state = heapify;
        end
        extract : begin
            nxt_state = heapify;
        end
        insert : begin
            nxt_state = while_0; // after the insert operation, must do the while loop
        end
        while_0 : begin
            if(!inc_continue)
                nxt_state = wait_cmd;
            else
                nxt_state = while_0;
        end
        default : begin
            if(RAM_A == num)
                nxt_state = reset;
            else
                nxt_state = write;
        end
    endcase
end

// find the largest for the heapify state
always @(*) begin // find max
    // shift the index_tmp left and conconcatenation with 0 and 1 to represent left_node and right_node index, respectively
    left = {index_tmp, 1'b0};
    right = {index_tmp, 1'b1};
    largest = index_tmp;
    if((left <= num) && (A[left] > A[index_tmp]))
        largest = left;
    if((right <= num) && (A[right] > A[largest]))
        largest = right;
end

// 
always @(posedge clk) begin
    case(state)
        reset : begin
            // start saving data from index 1
            A[1] <= data;
            num <= 1;
            RAM_valid <= 0;
            RAM_A     <= -1; // 8'hFF;
            done <= 0;
        end
        load : begin
            if(data_valid) begin
                num <= num + 1;
                A[num + 1] <= data;
            end
        end
        // when waiting for cmd, update the related values
        wait_cmd : begin
            build_i <= (num >> 1);
            index_tmp <= index; // for `increase_value`
            value_tmp <= value; // for `increase_value` or `insert_data`
            is_insert <= cmd[0]; // increase : 010 insert : 011
        end 
        heapify : begin
            // exchange A[i] with A[largest]
            if(largest != index_tmp) begin
                A[index_tmp] <= A[largest];
                A[largest] <= A[index_tmp];
                index_tmp <= largest; // need to keep maxify with the index_tmp updated to largest
            end
        end 
        build : begin
            // update index_tmp to build_i
            index_tmp <= build_i;
            build_i <= build_i - 1;
            if(build_i == 1)
                ret_state <= wait_cmd; // when build_i is 1, meaning the process is done, wait next cmd when the heapify is done
            else
                ret_state <= build; // else, keep build queue when the heapify is done
        end 
        extract : begin
            A[1] <= A[num];
            num <= num - 1;
            index_tmp <= 1;
            ret_state <= wait_cmd; // after the heapify operation, move to wait_cmd state
        end 
        insert : begin
            // identify if the operation is insert_value or increase_value based on the cmd[0]
            if(is_insert) begin
                // insert the value
                num <= num + 1;
                A[num + 1] <= value_tmp;
                index_tmp <= num + 1;
            end 
            else begin
                // increase the value
                A[index_tmp] <= value_tmp;
            end
        end 
        while_0 : begin
            if(inc_continue) begin
                // exchange A[index] with A[PARENT(index)]
                // and update index_tmp to index_tmp_parent, then the inc_continue wire will update automatically
                A[index_tmp_parent] <= A[index_tmp];
                A[index_tmp] <= A[index_tmp_parent];
                index_tmp <= index_tmp_parent;
            end
        end
        write : begin
            RAM_valid <= 1;
            // RAM_A starts from -1, so when accessing RAM_D using index, need to use RAM_A_plus2
            RAM_A <= RAM_A + 1;
            RAM_D <= A[RAM_A_plus2];
            if(RAM_A == num) done <= 1;
        end 
    endcase
end

// reset operation for busy signl control
// only enable busy to 0 when wait_cmd state
always @(posedge clk, posedge rst) begin
    if(rst) begin
        busy <= 0;
    end else begin
        if(nxt_state == wait_cmd)
            busy <= 0;
        else
            busy <= 1;
    end
end

endmodule

