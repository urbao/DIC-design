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
reg [1:0] row_1, col_1, row_2, col_2;
/*
When computing the element at the ii-th row and jj-th column of the resulting matrix,
you take the dot product of the ii-th row of the first matrix and the jj-th column of the second matrix.
So, the following ROW and COL is just the ROW-th element of mat1 and COL-th element of mat2, respectively.
And IDX is the index of column of mat1, and index of the row of mat2
*/
// current calculated cell's row and col index corresponding to result matrix of mat1 x mat2
reg [1:0] ROW, COL, IDX;
// matrix definition
reg [7:0] mat1[0:3][0:3];
reg [7:0] mat2[0:3][0:3];
reg signed [19:0] mat_result; // store the multiplication result of mat1 x mat2

/* ======= finite state machine definition ======= */
parameter [1:0] MAT1_READ=2'b00, // read matrix 1 values
                MAT2_READ=2'b01, // read matrix 2 values
                MULTIPLY=2'b10,  // calculate multiplication reuslt
                OUTPUT=2'b11;    // output result matrix and related signals
reg [1:0] currState, nextState;

/*------------------Main Code---------------------*/
// currState register
always @(posedge clk)begin
    // async reset operation
    if(rst)begin
        // reset variables' value
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
        busy <= 0; // notify testbench to send in_data
    end
    else begin
        // MAT1_READ state: start reading mat1 data
        if(currState==MAT1_READ)begin
            $display("MAT1:", in_data);
            // first, save in_data to mat1
            mat1[row_1][col_1] <= in_data;
            // secondly, consider update row_1 or col_1
            // Case 1: input finished for mat1 data
            if(row_end && col_end)begin
                currState <= nextState;
            end
            // Case 2: move to next row
            else if(col_end)begin
                row_1 <= row_1+2'b01;
                col_1 <= 0;
            end
            // Case 3: move to next col
            else begin
                col_1 <= col_1+2'b01;
            end
        end
        // MAT2_READ state: start reading mat2 data
        else if(currState==MAT2_READ)begin
            $display("MAT2:", in_data);
            // similar operations like MAT1_READ
            mat2[row_2][col_2] <= in_data;
            if(row_end && col_end)begin
                currState <= nextState;
            end
            else if(col_end)begin
                row_2 <= row_2+2'b01;
                col_2 <= 0;
            end
            else begin
                col_2 <= col_2+2'b01;
            end
        end
        // MULTIPLY state: calculate the value of (ROW, COL) in result of mat1 x mat2
        else if(currState==MULTIPLY)begin
            $display("MULTIPLY:", in_data);
            // check if the mat1 and mat2 can be multiplied together
            if(col_1!=row_2)begin
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
            $display("OUTPUT:", in_data);
            // enable valid signal(testbench will check out_data, is_legal, and change_row signal)
            valid <= 1;
            // check if the mat1 and mat2 can be multiplied together
            if(col_1!=row_2)begin
                is_legal <= 1;
            end
            else begin
                is_legal <= 0;
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
            if(col_1!=row_2)nextState = MAT1_READ;
            else if(ROW==row_1 && COL==col_2)nextState = MAT1_READ;
            else nextState = MULTIPLY; 
        end
        default: nextState = MAT2_READ;
    endcase
end

// output logic
always @(currState)begin
    case (currState)
        MAT1_READ:begin
            busy = 0;
            valid = 0;
            // reset variables for another new matrix multiplication
            row_1 = 0;
            row_2 = 0;
            col_1 = 0;
            col_2 = 0;
            mat_result = 0;
            ROW = 0;
            COL = 0;
            IDX = 0;
        end
        MAT2_READ:begin
            busy = 0;
            valid = 0;
        end
        MULTIPLY:begin
            busy = 1;
            valid = 0;
            // reset variables for next cells of multiplication
            mat_result = 0;
            IDX = 0;
        end
        OUTPUT: begin
            busy = 1;
        end
        default: begin
            busy = 0;
            valid = 0;
            // reset variables for another new matrix multiplication
            row_1 = 0;
            row_2 = 0;
            col_1 = 0;
            col_2 = 0;
            mat_result = 0;
            ROW = 0;
            COL = 0;
            IDX = 0;
        end 
    endcase
end

endmodule
