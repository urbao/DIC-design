module mixColumns (
    input [127:0] mix_in,
    output [127:0] mix_out
);

// do the matrix multiplication
genvar i;
generate
    for(i=0;i<4;i=i+1)begin:mix_columns
        assign mix_out[(i*32 + 24)+:8]= mult_2(mix_in[(i*32 + 24)+:8]) ^ mult_3(mix_in[(i*32 + 16)+:8]) ^ mix_in[(i*32 + 8)+:8] ^ mix_in[i*32+:8];
        assign mix_out[(i*32 + 16)+:8]= mix_in[(i*32 + 24)+:8] ^ mult_2(mix_in[(i*32 + 16)+:8]) ^ mult_3(mix_in[(i*32 + 8)+:8]) ^ mix_in[i*32+:8];
        assign mix_out[(i*32 + 8)+:8]= mix_in[(i*32 + 24)+:8] ^ mix_in[(i*32 + 16)+:8] ^ mult_2(mix_in[(i*32 + 8)+:8]) ^ mult_3(mix_in[i*32+:8]);
        assign mix_out[i*32+:8]= mult_3(mix_in[(i*32 + 24)+:8]) ^ mix_in[(i*32 + 16)+:8] ^ mix_in[(i*32 + 8)+:8] ^ mult_2(mix_in[i*32+:8]);
    end
endgenerate

// multiply in by 2
// if the MSB is 1, then do XOR with 0x1b
function [7:0] mult_2(input [7:0] in);
    begin
        mult_2 = in[7]?((in << 1) ^ 8'h1b) : (in << 1);
    end
endfunction

// multiply in by 3
// use the result of mult_2 and XOR with in itself, XOR means addition in finite field 
function [7:0] mult_3(input[7:0] in);
    begin
        mult_3 = mult_2(in) ^ in;
    end     
endfunction

endmodule