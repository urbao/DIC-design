module CIPU(
input       clk, 
input       rst,
input       [7:0]people_thing_in,
input       ready_fifo,
input       ready_lifo,
input       [7:0]thing_in,
input       [3:0]thing_num,
output reg valid_fifo,
output reg valid_lifo,
output reg valid_fifo2,
output reg [7:0]people_thing_out,
output reg [7:0]thing_out,
output reg done_thing,
output reg done_fifo,
output reg done_lifo,
output reg done_fifo2);

// length parameter that defines the max length of the data sequence
parameter LENGTH=16;

/*
Since the FIFO and LIFO data come in at the same time, and the data processing 
technique between them are a slightly different from each other. So, I tried to 
break the FIFO and LIFO state control into 2 seperated FSMs.
*/


/* -----------------PARAMETERD INITIALIZATION-------------------*/
// people FIFO FSM and related parameters
parameter [1:0] INIT_1=2'b00,
                READY_1=2'b01,
                VALID_1=2'b10,
                DONE_1=2'b11;
reg [1:0] currState1, nextState1;
reg [7:0] Passenger[0:LENGTH-1]; // ONLY save the People data as output result
integer passenger_count=0; // records how many passengers in the FIFO sequence
integer passenger_index=0; // records index of passenger when outputing the result

// luggage LIFO/FIFO FSM and related parameters
parameter [2:0] INIT_2=3'b000,
                READY_2=3'b001,
                VALID_LIFO_2=3'b010,
                DONE_THING_2=3'b011,
                DONE_LIFO_2=3'b100,
                VALID_FIFO_2=3'b101,
                DONE_FIFO_2=3'b110;
reg [2:0] currState2, nextState2;
reg [7:0] Luggage[0:LENGTH-1]; // records the Luggages 
reg [7:0] Remain_Luggage[0:LENGTH-1]; // records the remaining Luggages after popping out
integer luggage_count=0; // record total count of luggages in the sequence
integer luggage_index=0; // record index of luggages when outputing the LIFO result
integer remain_luggage_count=0; // record count of remain luggages when save to Remain_Luggage
integer remain_luggage_index=0; // record index of remain luggages when outputing the FIFO result


/*---------------------FIFO CASE----------------------*/
// currState register
always @(posedge clk)begin
    // sync reset operation, reset state to INIT_1
    // and reset valid and done signal to 0
    if(rst)begin
        valid_fifo <= 1'b0;
        done_fifo <= 1'b0;
        currState1 <= INIT_1;
    end
    // start consider different state operations
    else begin
        // INIT_1 state: wait for the ready_fifo set to high, move to READY_1 state
        if(currState1==INIT_1)begin
            done_fifo <= 0; // after 1 clock cycle from the DONE_1 state, pull down the signal
            if(ready_fifo)begin
                passenger_count <= 0; // reset passenger_count value
                passenger_index <= 0; // reset passenger_index value
                currState1 <= nextState1;
            end
        end
        // READY_1 state: start reading until encounter end symbol. then move to VALID_1 state
        else if(currState1==READY_1)begin
            // save only People info(A~Z)
            // ASCII code: `A` -> 8'h41, `Z` -> 8'h5A
            if(people_thing_in>=8'h41 && people_thing_in<=8'h5A)begin
                Passenger[passenger_count] <= people_thing_in;
                passenger_count <= passenger_count+1;
            end
            // encounter end symbol
            // ASCII code: `$` -> 8'h24
            if(people_thing_in==8'h24)begin
                currState1 <= nextState1;
            end
        end
        // VALID_1 state: enable valid_fifo signal and start output result
        else if(currState1==VALID_1)begin
            valid_fifo <= 1'b1; // notify the testbench the valid result is outputed
            // output all passengers one by one
            if(passenger_index<passenger_count)begin
                people_thing_out <= Passenger[passenger_index];
                passenger_index <= passenger_index+1;
            end
            // when all results are outputed, move to DONE_1 state
            else begin
                valid_fifo <= 1'b0; // pull down the valid_fifo signal
                currState1 <= nextState1;
            end
        end
        // DONE_1 state: enable done_fifo signal, and move to INIT_1 state waiting for next sequence
        else begin
            done_fifo <= 1'b1; // enable done_fifo signal
            currState1 <= nextState1;
        end
    end
end

// nextState logic
always @(currState1)begin
    case(currState1)
        INIT_1:nextState1 = READY_1;
        READY_1: nextState1 = VALID_1;
        VALID_1: nextState1 = DONE_1;
        DONE_1: nextState1 = INIT_1;
        default: nextState1 = INIT_1;
    endcase
end

/*---------------------LIFO CASE----------------------*/
// currState register
always @(posedge clk)begin
    // sync reset operation, reset state to INIT_2
    // and reset valid and done signal to 0
    if(rst)begin
        valid_lifo <= 1'b0;
        valid_fifo2 <= 1'b0;
        done_thing <= 1'b0;
        done_lifo <= 1'b0;
        done_fifo2 <= 1'b0;
        currState2 <= INIT_2;
    end
    // consider the state change
    else begin
        // INIT_2 state: wait for the ready_lifo set to high
        if(currState2==INIT_2)begin
            if(ready_lifo)begin
                // reset some value before reading data
                luggage_count <= 0;
                luggage_index <= 0;
                remain_luggage_index <= 0;
                currState2 <= nextState2;
            end
        end
        // READY_2 state: start reading data until encounter end symbol or seperate symbol
        else if(currState2==READY_2)begin
            // save Luggage only(1~9)
            // ASCII code: `1` -> 8'h31, `9` -> 8'h39
            if(thing_in>=8'h31 && thing_in<=8'h39)begin
                Luggage[luggage_count] <= thing_in;
                luggage_count <= luggage_count+1;
            end
            // when encounter the other symbol, move to nextState(based on the nextState logic)
            if(thing_in==8'h3B || thing_in==8'h24)begin
                currState2 <= nextState2;
            end
        end
        // VALID_LIFO_2 state: start output the result of popped luggages
        else if(currState2==VALID_LIFO_2)begin
            valid_lifo <= 1'b1;
            // output the popped-luggages result based on the thing_num
            // thing_num==0 case: just output 0
            if(thing_num==0)begin
                thing_out <= 8'h30;
                done_thing <= 1'b1;
                currState2 <= nextState2;
            end
            else begin
                if(luggage_index<thing_num)begin
                    thing_out <= Luggage[luggage_count-luggage_index-1];
                    luggage_index <= luggage_index+1;
                end
                else begin
                    valid_lifo <= 1'b0;
                    done_thing <= 1'b1;
                    currState2 <= nextState2;
                end
            end
        end
        // DONE_THING_2 state: control the done_thing signal
        else if(currState2==DONE_THING_2)begin
            // save the remaining luggages to Remain_Luggage and reset the parameters value
            // if(remain_luggage_count<luggage_count-thing_num)begin
            //     Remain_Luggage[remain_luggage_count] <= Luggage[remain_luggage_count];
            //     remain_luggage_count <= remain_luggage_count+1;
            // end
            luggage_count <= 1'b0;
            luggage_index <= 1'b0;
            valid_lifo <= 1'b0;
            done_thing <= 1'b0;
            currState2 <= nextState2;
        end
        // DONE_LIFO_2 state: enable the done_lifo and move to the nextState
        else if(currState2==DONE_LIFO_2)begin
            done_lifo <= 1'b1;
            currState2 <= nextState2;
        end
        // VALID_FIFO_2 state: start output FIFO_2 result
        else if(currState2==VALID_FIFO_2)begin
            
        end
    end
end

// nextState logic
always @(currState2 or thing_in)begin
    case (currState2)
        INIT_2: nextState2 = READY_2;
        READY_2:begin
            // if the data is end symbol, then jump to DONE_LIFO_2 state
            // else jump to VALID_LIFO_2 state for data validation
            case (thing_in)
                8'h24: nextState2 = DONE_LIFO_2;
                8'h3B: nextState2 = VALID_LIFO_2;
                default: nextState2 = VALID_LIFO_2;
            endcase
        end
        VALID_LIFO_2: nextState2 = DONE_THING_2;
        DONE_THING_2: nextState2 = READY_2;
        DONE_LIFO_2: nextState2 = VALID_FIFO_2;
        VALID_FIFO_2: nextState2 = DONE_FIFO_2;
        DONE_FIFO_2: nextState2 = INIT_2;
        default: nextState2 = INIT_2;
    endcase
end

endmodule