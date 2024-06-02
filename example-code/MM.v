`timescale 1ns/10ps
module MM( in_data, col_end, row_end, is_legal, out_data, rst, clk , change_row,valid,busy);
input       clk;
input       rst;
input       col_end;
input       row_end;
input [7:0] in_data;

output reg signed [19:0] out_data;
output is_legal;
output reg change_row,valid,busy;

// matrix initialization (Use 1D array)
reg signed [7:0] mx1[15:0],mx2[15:0];
/*
mx1_row, mx2_row, mx1_col, mx2_col: save the counts of row and col of mx1 and mx2, respectively
cnt: indicate the current saved index of in_data when load_mx1 and load_mx2
mx1_col_cnt, mx1_row_cnt, mx2_col_cnt, mx2_row_cnt: count of current index of row and col when calculating matrix multiplication
*/
reg [3:0] mx1_row,mx2_row,mx1_col,mx2_col,cnt,mx1_col_cnt,mx1_row_cnt,mx2_col_cnt,mx2_row_cnt;

// Finite State Machine state control registers
reg [2:0] cur,nxt;

// only when the mx1_col==mx2_row condition is meet, meaning the matrix multiplication is valid
assign is_legal = (mx1_col == mx2_row);

// when all the index of row and col in mx1 and mx2 reaches the limit, meaning the matrix multiplication is done, and move to finish state
assign done = ((mx1_col_cnt == mx1_col - 1 && mx1_row_cnt == mx1_row - 1) &&(mx2_col_cnt == mx2_col - 1 && mx2_row_cnt == mx2_row - 1));

// 16-bit is cuz the values in mx1 and mx2 are both 8-bit signed, and multiplication result should be contained with 16-bit
wire signed [15:0] temp_sum = mx1[mx1_row_cnt * mx1_col + mx1_col_cnt] * mx2[mx2_row_cnt * mx2_col + mx2_col_cnt];

// Finite State Machine
parameter 
load_mx1 = 0,
load_mx2 = 1,
calculate = 2,
hold = 3,
not_legal = 4,
finish = 5;

// Next State Logic
always @(*) begin
    case(cur)
        load_mx1:nxt = (row_end)?load_mx2:load_mx1;
        // 因為row_end signal triggered的這個cycle才會把mx2_row加上1，但是這是sequential block，所以實際是要等到下一個cycle時
        // mx2_row才會真的加上1，因此這邊要額外加1，才能確保判斷的正確性
        load_mx2:nxt = (row_end)?(mx1_col == mx2_row + 1)?calculate:not_legal:load_mx2;
        calculate:nxt = ((mx1_col_cnt == mx1_col-1 && mx1_row_cnt == mx1_row-1) &&(mx2_col_cnt == mx2_col-1 && mx2_row_cnt == mx2_row-1))?finish:(mx1_col_cnt == mx1_col - 1)?hold:calculate;
        hold:nxt = calculate;
        not_legal:nxt = finish;
        finish:nxt = load_mx1;
    endcase
end

// Current State Logic
always @(posedge clk or posedge rst) begin
    // async reset operation
    if(rst)begin
        cur <= load_mx1;
        mx1_row <= 0;
        mx2_row <= 0;
        mx1_col <= 0;
        mx2_col <= 0;
        cnt <= 0;
        mx1_row_cnt <= 0;
        mx1_col_cnt <= 0;
        mx2_row_cnt <= 0;
        mx2_col_cnt <= 0;
        out_data <= 0;
        valid <= 0;
        busy <= 0;
    end
    else begin
        // move to Next State first
        cur <= nxt;
        case (cur)
            // read the data into mx1
            load_mx1:begin
                // save in_data into index `cnt` of mx1, cnt starts by 0
                cnt <= cnt + 1;
                mx1[cnt] <= in_data;
                if(col_end)begin
                    // when the first line of the mx1 ends, save the `cnt+1` to mx1_col (used to check if the matrix multiplication is valid)
                    // remember the signal is sequential block, meaning all code execute the same time
                    // and this means mx1_col save the counts of columns in the first line of mx1
                    if(mx1_col == 0)mx1_col <= cnt + 1;
                    mx1_row <= mx1_row + 1;
                end
                // when row_end signal is triggered, reset cnt, and the state will move to load_mx2
                if(row_end)cnt <= 0;
            end
            load_mx2:begin
                cnt <= cnt + 1;
                mx2[cnt] <= in_data;
                if(col_end)begin
                    if(mx2_col == 0)mx2_col <= cnt + 1;
                    mx2_row <= mx2_row + 1;
                end
                // when row_end signal is triggered, set busy to 1, and the state will move to calculate or not_legal based on NExtState logic 
                if(row_end)busy <= 1;
            end 
            calculate:begin
                out_data <= out_data + temp_sum;
                // when a row of matrix multiplication result is done, change to next row
                if(mx2_col_cnt == mx2_col-1 && mx2_row_cnt == mx2_row-1)change_row <= 1;
                else change_row <= 0;
                // update the count index when the row is changed, and output the result
                if(mx2_row_cnt == mx2_row-1 && mx2_col_cnt == mx2_col -1)begin
                    mx2_row_cnt <= 0;
                    mx2_col_cnt <= 0;
                    mx1_row_cnt <= mx1_row_cnt + 1;
                    valid = 1;
                end
                // when a column is done computed, move to next column in mx2
                else if(mx2_row_cnt == mx2_row -1)begin
                    mx2_col_cnt <= mx2_col_cnt + 1;
                    mx2_row_cnt <= 0;
                    valid = 1;
                end
                else begin
                    mx2_row_cnt <= mx2_row_cnt + 1;
                end

                if(mx1_col_cnt == mx1_col -1)begin
                    mx1_col_cnt <= 0;
                end
                else mx1_col_cnt <= mx1_col_cnt + 1;
            end
            // reset the out_data, since the matrix multiplication is finished in that round
            hold:begin
                out_data <= 0;
                valid <= 0;
            end
            // enable the valid signal, so the is_legal signal is checked by testbench
            not_legal:begin
                valid <= 1;
            end
            // reset all paramters
            finish:begin
                valid <= 0;
                mx1_row <= 0;
                mx2_row <= 0;
                mx1_col <= 0;
                mx2_col <= 0;
                cnt <= 0;
                mx1_row_cnt <= 0;
                mx1_col_cnt <= 0;
                mx2_row_cnt <= 0;
                mx2_col_cnt <= 0;
                out_data <= 0;
                busy <= 0;
            end
        endcase
    end
end
endmodule
