`timescale 1ns/10ps
module MM( in_data, col_end, row_end, is_legal, out_data, rst, clk , change_row,valid,busy);
input clk;
input rst;
input col_end;
input row_end;
input [7:0]in_data;

output reg signed [19:0]out_data;
output reg is_legal;
output reg change_row,valid,busy;

/* ======= variables initialization ======= */
// record the row and col size of mat1 and mat2
// if mat1 can be multiplied with mat2, the result matrix shape is row_1 x col_2
/*
========== Potential Problems for INVALID MAtrix Multiplication ============
Case 1: If the col_1 is NOT EQUAL TO row_2
Case 2: Column data count not the same in either mat1 or mat2
        e.g. if size of col_1 is 3, and the 1st row of mat1 has received 3 inputs, however, the 2nd row of mat1 only receieved 2 inputs or 4 inputs

========== Solutions for the Potential Problems ===========
Case 1: Just directly checked if the col_1 is EQUAL TO row_2
Case 2: Use another reg to RECORD the col_size in the first row for both mat1 and mat2
        Then for the rest of row in the mat1 and mat2, whenever change_row signal is triggered, go check if col_size matchs the col_1 or col_2
BUT, for Case 2, if the matrix'row is only 1, then there's no possibility that the column components count in different rows is different
SO, if row_1==0 or row_2==0, then in the last row check before jumping to nextState, no need to check the MAT_COL_SIZE 
*/
reg [1:0] MAT_COL_SIZE; // used to check if the components' count is the same in each row for mat1 and mat2
reg VALID_MATRIX; // used to record if the matrix multiplication is valid, 1 means valid, 0 means NO valid
reg [1:0] row_1, col_1, row_2, col_2;
/*
When computing the element at the ii-th row and jj-th column of the resulting matrix,
you take the dot product of the ii-th row of the first matrix and the jj-th column of the second matrix.
So, the following ROW and COL is just the ROW-th element of mat1 and COL-th element of mat2, respectively.
And IDX is the index of column of mat1, and index of the row of mat2
*/
// current calculated cell's row and col index corresponding to result matrix of mat1 x mat2
reg [1:0] ROW, COL, IDX;

/*
Since when a new set of matrix data is input, somehow the last in_data will input for another extra cycle
so the wait_one_cycle signal is used to delay a cycle for reading in_data in MAT1_READ state
But initially the extra cycle problem is not existed, so wait_one_cycle is set to 0 at first.
And when the MAT2_READ state occurs, the wait_one_cycle is set back to 1, so the next set of matrix input will need
to wait for another extra cycle before reading mat1 data
*/
reg wait_one_cycle=0;
// matrix definition(the in_data is 8-bit signed)
reg signed [7:0] mat1[0:3][0:3];
reg signed [7:0] mat2[0:3][0:3];
reg signed [19:0] mat_result; // store the multiplication result of mat1 x mat2

/* ======= finite state machine definition ======= */
parameter [1:0] MAT1_READ=2'b00, // read matrix 1 values
                MAT2_READ=2'b01, // read matrix 2 values
                MULTIPLY=2'b10,  // calculate multiplication reuslt
                OUTPUT=2'b11;    // output result matrix and related signals
reg [1:0] currState, nextState;

/*------------------Main Code---------------------*/
// currState register
always @(posedge clk or posedge rst)begin
    // active-high async reset operation
    if(rst)begin
        // reset variables' value
        MAT_COL_SIZE <= 0;
        VALID_MATRIX <= 1; // default to valid operation
        row_1 <= 0;
        row_2 <= 0;
        col_1 <= 0;
        col_2 <= 0;
        mat_result <= 0;
        ROW <= 0;
        COL <= 0;
        IDX <= 0;
        // assign accurate currState, so currState signal will not be random
        currState <= MAT1_READ;
    end
    else begin
        // MAT1_READ state: start reading mat1 data
        if(currState==MAT1_READ)begin
            valid <= 0; // disable valid signal, no data will be checked by testbench accidentally
            // wait for another cycle, so no wrong in_data is read
            if(wait_one_cycle==1)begin
                wait_one_cycle <= 0;
                // reset variables for another new matrix multiplication
                MAT_COL_SIZE <= 0;
                VALID_MATRIX <= 1; // default to valid operation
                row_1 <= 0;
                row_2 <= 0;
                col_1 <= 0;
                col_2 <= 0;
                mat_result <= 0;
                ROW <= 0;
                COL <= 0;
                IDX <= 0;
            end
            else begin
                // first, save in_data to mat1
                mat1[row_1][col_1] <= in_data;
                // secondly, consider update row_1 or col_1
                // Case 1: input finished for mat1 data, move to nextState
                if(row_end && col_end)begin
                    // check if the matrix column count match for the last line
                    // if there's only 1 row in the mat1, no need to check MAT_COL_SIZE
                    if(col_1!=MAT_COL_SIZE && row_1!=0)begin
                        VALID_MATRIX <= 0;
                    end
                    currState <= nextState;
                end
                // Case 2: move to next row
                else if(col_end)begin
                    // save the matrix column size of 1st row
                    if(row_1==0)begin
                        MAT_COL_SIZE <= col_1;
                    end
                    // check if matrix column count match for other rows
                    else begin
                        if(col_1!=MAT_COL_SIZE)begin
                            VALID_MATRIX <= 0; // mark as invalid since column components count not matched
                        end
                    end
                    row_1 <= row_1+2'b01;
                    col_1 <= 0;
                end
                // Case 3: move to next col
                else begin
                    col_1 <= col_1+2'b01;
                end
            end
        end
        // MAT2_READ state: start reading mat2 data
        else if(currState==MAT2_READ)begin
            wait_one_cycle <= 1;
            // similar operations like MAT1_READ
            mat2[row_2][col_2] <= in_data;
            if(row_end && col_end)begin
                // check if the matrix column count match for the last line
                if(col_2!=MAT_COL_SIZE && row_2!=0)begin
                    VALID_MATRIX <= 0;
                end
                currState <= nextState;
            end
            else if(col_end)begin
                // save the matrix column size of 1st row
                if(row_2==0)begin
                    MAT_COL_SIZE <= col_2;
                end
                // check if matrix column count match for other rows
                else begin
                    if(col_2!=MAT_COL_SIZE)begin
                        VALID_MATRIX <= 0; // mark as invalid since column components count not matched
                    end
                end
                row_2 <= row_2+2'b01;
                col_2 <= 0;
            end
            else begin
                col_2 <= col_2+2'b01;
            end
        end
        // MULTIPLY state: calculate the value of (ROW, COL) in result of mat1 x mat2
        else if(currState==MULTIPLY)begin
            valid <= 0; // disable valid signal
            // check if the mat1 and mat2 can be multiplied together
            // consider 2 different case listed in line 17~25
            if(col_1!=row_2 || VALID_MATRIX==0)begin
                currState <= nextState;
            end
            else begin
                mat_result <= mat_result+(mat1[ROW][IDX]*mat2[IDX][COL]);
                // Case 1: if the IDX reaches the limit of matrix, meaning multiplication process is done
                if(IDX==col_1)begin
                    currState <= nextState;
                end
                // Case 2: otherwise, move to next IDX 
                else begin
                    IDX <= IDX+2'b01;
                end
            end
        end
        // OUTPUT state: output the value of (ROW, COL) in mat1 x mat2 as out_data
        else begin
            // enable valid signal(testbench will check out_data, is_legal, and change_row signal)
            valid <= 1;
            // check if the mat1 and mat2 can be multiplied together
            if(col_1!=row_2 || VALID_MATRIX==0)begin
                is_legal <= 0; // not legal since col_1 is not equal to row_2
            end
            else begin
                is_legal <= 1;
                out_data <= mat_result;
                // check if the change_row signal is needed to be enable
                if(COL==col_2)begin
                    change_row <= 1;
                    ROW <= ROW+2'b01; // move to next row
                    COL <= 0; // reset column index
                end
                else begin
                    change_row <= 0;
                    COL <= COL+2'b01; // move to next column
                end
            end
            // reset variables for multiplication-related variables
            mat_result = 0;
            IDX = 0;
            currState <= nextState; // move to nextState based on nextState logic
        end
    end
end

// nextState logic
always @(*)begin
    case (currState)
        MAT1_READ: nextState = MAT2_READ;
        MAT2_READ: nextState = MULTIPLY;
        MULTIPLY: nextState = OUTPUT;
        OUTPUT: begin
            // Case 1: if the matrices are not multiplicable, then continue reading next mat1 input
            // Case 2: if the matrix is completed output, then start reading next mat1 input
            // Case 3: if the matrix is not done with output, then go back MULTIPLY and continue calculating
            if(col_1!=row_2 || VALID_MATRIX==0)nextState = MAT1_READ;
            else if(ROW==row_1 && COL==col_2)nextState = MAT1_READ;
            else nextState = MULTIPLY; 
        end
        default: nextState = MAT2_READ;
    endcase
end

// output logic
always @(currState)begin
    case (currState)
        MULTIPLY: busy = 1;
        OUTPUT: busy = 1;
        default: busy = 0;
    endcase
end

endmodule
