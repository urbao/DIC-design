module keyExpansion (
    input [127:0] key_in,
    input [3:0] round_i, // used to check which round_const array used in rCon function
    output [127:0] key_out
);

wire [31:0] afterSW; // save result after subWords
wire [31:0] afterRW; // save result after rotWords
wire [31:0] afterRC; // save result after rConv


assign afterRW = rotWord(key_in[31:0]);
assign afterSW = subWord(afterRW);
assign afterRC = rCon(afterSW, round_i);
assign key_out[127:96] = key_in[127:96] ^ afterRC;
assign key_out[95:64] = key_in[95:64] ^ key_out[127:96];
assign key_out[63:32] = key_in[63:32] ^ key_out[95:64];
assign key_out[31:0] = key_in[31:0] ^ key_out[63:32];

// match the sBox table for the subWord function
function [7:0] sb(input [7:0] in);
    begin
        case (in)
            8'h00: sb=8'h63; 8'h01: sb=8'h7c; 8'h02: sb=8'h77; 8'h03: sb=8'h7b; 8'h04: sb=8'hf2; 8'h05: sb=8'h6b; 8'h06: sb=8'h6f; 8'h07: sb=8'hc5;
            8'h08: sb=8'h30; 8'h09: sb=8'h01; 8'h0a: sb=8'h67; 8'h0b: sb=8'h2b; 8'h0c: sb=8'hfe; 8'h0d: sb=8'hd7; 8'h0e: sb=8'hab; 8'h0f: sb=8'h76;
            8'h10: sb=8'hca; 8'h11: sb=8'h82; 8'h12: sb=8'hc9; 8'h13: sb=8'h7d; 8'h14: sb=8'hfa; 8'h15: sb=8'h59; 8'h16: sb=8'h47; 8'h17: sb=8'hf0;
            8'h18: sb=8'had; 8'h19: sb=8'hd4; 8'h1a: sb=8'ha2; 8'h1b: sb=8'haf; 8'h1c: sb=8'h9c; 8'h1d: sb=8'ha4; 8'h1e: sb=8'h72; 8'h1f: sb=8'hc0;
            8'h20: sb=8'hb7; 8'h21: sb=8'hfd; 8'h22: sb=8'h93; 8'h23: sb=8'h26; 8'h24: sb=8'h36; 8'h25: sb=8'h3f; 8'h26: sb=8'hf7; 8'h27: sb=8'hcc;
            8'h28: sb=8'h34; 8'h29: sb=8'ha5; 8'h2a: sb=8'he5; 8'h2b: sb=8'hf1; 8'h2c: sb=8'h71; 8'h2d: sb=8'hd8; 8'h2e: sb=8'h31; 8'h2f: sb=8'h15;
            8'h30: sb=8'h04; 8'h31: sb=8'hc7; 8'h32: sb=8'h23; 8'h33: sb=8'hc3; 8'h34: sb=8'h18; 8'h35: sb=8'h96; 8'h36: sb=8'h05; 8'h37: sb=8'h9a;
            8'h38: sb=8'h07; 8'h39: sb=8'h12; 8'h3a: sb=8'h80; 8'h3b: sb=8'he2; 8'h3c: sb=8'heb; 8'h3d: sb=8'h27; 8'h3e: sb=8'hb2; 8'h3f: sb=8'h75;
            8'h40: sb=8'h09; 8'h41: sb=8'h83; 8'h42: sb=8'h2c; 8'h43: sb=8'h1a; 8'h44: sb=8'h1b; 8'h45: sb=8'h6e; 8'h46: sb=8'h5a; 8'h47: sb=8'ha0;
            8'h48: sb=8'h52; 8'h49: sb=8'h3b; 8'h4a: sb=8'hd6; 8'h4b: sb=8'hb3; 8'h4c: sb=8'h29; 8'h4d: sb=8'he3; 8'h4e: sb=8'h2f; 8'h4f: sb=8'h84;
            8'h50: sb=8'h53; 8'h51: sb=8'hd1; 8'h52: sb=8'h00; 8'h53: sb=8'hed; 8'h54: sb=8'h20; 8'h55: sb=8'hfc; 8'h56: sb=8'hb1; 8'h57: sb=8'h5b;
            8'h58: sb=8'h6a; 8'h59: sb=8'hcb; 8'h5a: sb=8'hbe; 8'h5b: sb=8'h39; 8'h5c: sb=8'h4a; 8'h5d: sb=8'h4c; 8'h5e: sb=8'h58; 8'h5f: sb=8'hcf;
            8'h60: sb=8'hd0; 8'h61: sb=8'hef; 8'h62: sb=8'haa; 8'h63: sb=8'hfb; 8'h64: sb=8'h43; 8'h65: sb=8'h4d; 8'h66: sb=8'h33; 8'h67: sb=8'h85;
            8'h68: sb=8'h45; 8'h69: sb=8'hf9; 8'h6a: sb=8'h02; 8'h6b: sb=8'h7f; 8'h6c: sb=8'h50; 8'h6d: sb=8'h3c; 8'h6e: sb=8'h9f; 8'h6f: sb=8'ha8;
            8'h70: sb=8'h51; 8'h71: sb=8'ha3; 8'h72: sb=8'h40; 8'h73: sb=8'h8f; 8'h74: sb=8'h92; 8'h75: sb=8'h9d; 8'h76: sb=8'h38; 8'h77: sb=8'hf5;
            8'h78: sb=8'hbc; 8'h79: sb=8'hb6; 8'h7a: sb=8'hda; 8'h7b: sb=8'h21; 8'h7c: sb=8'h10; 8'h7d: sb=8'hff; 8'h7e: sb=8'hf3; 8'h7f: sb=8'hd2;
            8'h80: sb=8'hcd; 8'h81: sb=8'h0c; 8'h82: sb=8'h13; 8'h83: sb=8'hec; 8'h84: sb=8'h5f; 8'h85: sb=8'h97; 8'h86: sb=8'h44; 8'h87: sb=8'h17;
            8'h88: sb=8'hc4; 8'h89: sb=8'ha7; 8'h8a: sb=8'h7e; 8'h8b: sb=8'h3d; 8'h8c: sb=8'h64; 8'h8d: sb=8'h5d; 8'h8e: sb=8'h19; 8'h8f: sb=8'h73;
            8'h90: sb=8'h60; 8'h91: sb=8'h81; 8'h92: sb=8'h4f; 8'h93: sb=8'hdc; 8'h94: sb=8'h22; 8'h95: sb=8'h2a; 8'h96: sb=8'h90; 8'h97: sb=8'h88;
            8'h98: sb=8'h46; 8'h99: sb=8'hee; 8'h9a: sb=8'hb8; 8'h9b: sb=8'h14; 8'h9c: sb=8'hde; 8'h9d: sb=8'h5e; 8'h9e: sb=8'h0b; 8'h9f: sb=8'hdb;
            8'ha0: sb=8'he0; 8'ha1: sb=8'h32; 8'ha2: sb=8'h3a; 8'ha3: sb=8'h0a; 8'ha4: sb=8'h49; 8'ha5: sb=8'h06; 8'ha6: sb=8'h24; 8'ha7: sb=8'h5c;
            8'ha8: sb=8'hc2; 8'ha9: sb=8'hd3; 8'haa: sb=8'hac; 8'hab: sb=8'h62; 8'hac: sb=8'h91; 8'had: sb=8'h95; 8'hae: sb=8'he4; 8'haf: sb=8'h79;
            8'hb0: sb=8'he7; 8'hb1: sb=8'hc8; 8'hb2: sb=8'h37; 8'hb3: sb=8'h6d; 8'hb4: sb=8'h8d; 8'hb5: sb=8'hd5; 8'hb6: sb=8'h4e; 8'hb7: sb=8'ha9;
            8'hb8: sb=8'h6c; 8'hb9: sb=8'h56; 8'hba: sb=8'hf4; 8'hbb: sb=8'hea; 8'hbc: sb=8'h65; 8'hbd: sb=8'h7a; 8'hbe: sb=8'hae; 8'hbf: sb=8'h08;
            8'hc0: sb=8'hba; 8'hc1: sb=8'h78; 8'hc2: sb=8'h25; 8'hc3: sb=8'h2e; 8'hc4: sb=8'h1c; 8'hc5: sb=8'ha6; 8'hc6: sb=8'hb4; 8'hc7: sb=8'hc6;
            8'hc8: sb=8'he8; 8'hc9: sb=8'hdd; 8'hca: sb=8'h74; 8'hcb: sb=8'h1f; 8'hcc: sb=8'h4b; 8'hcd: sb=8'hbd; 8'hce: sb=8'h8b; 8'hcf: sb=8'h8a;
            8'hd0: sb=8'h70; 8'hd1: sb=8'h3e; 8'hd2: sb=8'hb5; 8'hd3: sb=8'h66; 8'hd4: sb=8'h48; 8'hd5: sb=8'h03; 8'hd6: sb=8'hf6; 8'hd7: sb=8'h0e;
            8'hd8: sb=8'h61; 8'hd9: sb=8'h35; 8'hda: sb=8'h57; 8'hdb: sb=8'hb9; 8'hdc: sb=8'h86; 8'hdd: sb=8'hc1; 8'hde: sb=8'h1d; 8'hdf: sb=8'h9e;
            8'he0: sb=8'he1; 8'he1: sb=8'hf8; 8'he2: sb=8'h98; 8'he3: sb=8'h11; 8'he4: sb=8'h69; 8'he5: sb=8'hd9; 8'he6: sb=8'h8e; 8'he7: sb=8'h94;
            8'he8: sb=8'h9b; 8'he9: sb=8'h1e; 8'hea: sb=8'h87; 8'heb: sb=8'he9; 8'hec: sb=8'hce; 8'hed: sb=8'h55; 8'hee: sb=8'h28; 8'hef: sb=8'hdf;
            8'hf0: sb=8'h8c; 8'hf1: sb=8'ha1; 8'hf2: sb=8'h89; 8'hf3: sb=8'h0d; 8'hf4: sb=8'hbf; 8'hf5: sb=8'he6; 8'hf6: sb=8'h42; 8'hf7: sb=8'h68;
            8'hf8: sb=8'h41; 8'hf9: sb=8'h99; 8'hfa: sb=8'h2d; 8'hfb: sb=8'h0f; 8'hfc: sb=8'hb0; 8'hfd: sb=8'h54; 8'hfe: sb=8'hbb; 8'hff: sb=8'h16;
	endcase
    end
endfunction

// subWord function apply the s-box table to each byte in the word
function [31:0] subWord(input [31:0] word);
    begin
        subWord[7:0]   = sb(word[7:0]);
        subWord[15:8]  = sb(word[15:8]);
        subWord[23:16] = sb(word[23:16]);
        subWord[31:24] = sb(word[31:24]);
    end
endfunction

// rotWord function performs the cyclic permutation
function [31:0] rotWord(input [31:0] word);
    begin
        rotWord = {word[23:0], word[31:24]};
    end
endfunction

// rCon function XOR the constant word array
function [31:0] rCon(input [31:0] word, input [3:0] round_i);
    begin
        case (round_i)
            1: rCon  = word ^ 32'h01000000;
            2: rCon  = word ^ 32'h02000000;
            3: rCon  = word ^ 32'h04000000;
            4: rCon  = word ^ 32'h08000000;
            5: rCon  = word ^ 32'h10000000;
            6: rCon  = word ^ 32'h20000000;
            7: rCon  = word ^ 32'h40000000;
            8: rCon  = word ^ 32'h80000000;
            9: rCon  = word ^ 32'h1b000000;
            10: rCon = word ^ 32'h36000000;
            default: rCon = word ^ 32'h00000000;
        endcase
    end
endfunction

endmodule