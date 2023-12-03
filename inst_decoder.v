`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2023 11:53:01
// Design Name: 
// Module Name: inst_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module inst_decoder(instcode,ib,sb,op_s,imm);
input [31:0] instcode;
output reg [31:0] imm;
output reg [4:0] ib,sb;
output reg [3:0] op_s;

always@(*)
begin

casex(instcode)
32'bxxxxxxx_xxxxx_xxxxx_xxx_xxxxx_01100xx: //R-instr
begin
ib=5;sb=0;
op_s={instcode[30],instcode[14:12]};
imm=0;
end

32'bxxxxxxx_xxxxx_xxxxx_xxx_xxxxx_00100xx: //I-type Arithmetic
begin
ib = 7; sb=0;
op_s={instcode[30],instcode[14:12]};
imm = {{21{instcode[31]}},instcode[30:25],instcode[24:21],instcode[20]};
end

32'bxxxxxxx_xxxxx_xxxxx_xxx_xxxxx_00000xx: //I-Type Load
begin
ib = 1; sb=9;
op_s={instcode[30],instcode[14:12]};
imm = {{21{instcode[31]}},instcode[30:25],instcode[24:21],instcode[20]};
end

32'bxxxxxxx_xxxxx_xxxxx_xxx_xxxxx_01000xx: // S-Type
begin
ib = 1; sb=3;
op_s={instcode[30],instcode[14:12]};
imm = {{21{instcode[31]}},instcode[30:25],instcode[11:8],instcode[7]};
end

32'bxxxxxxx_xxxxx_xxxxx_xxx_xxxxx_01101xx: // lui-Type(U)
begin
ib = 2; sb=0;
op_s={instcode[30],instcode[14:12]};
imm = {instcode[31:12],{12{1'b0}}};
end

32'bxxxxxxx_xxxxx_xxxxx_xxx_xxxxx_00101xx: // auipc-Type(U)
begin
ib = 4; sb=0;
op_s={instcode[30],instcode[14:12]};
imm = {instcode[31:12],{12{1'b0}}};
end

32'bxxxxxxx_xxxxx_xxxxx_xxx_xxxxx_11000xx: // B-Type
begin
ib = 12; sb=0;
op_s={instcode[30],instcode[14:12]};
imm = {{21{instcode[31]}},instcode[7],instcode[30:25],instcode[11:8],1'b0};
end

32'bxxxxxxx_xxxxx_xxxxx_xxx_xxxxx_11011xx: // J-Type
begin
ib = 16; sb=0;
op_s={instcode[30],instcode[14:12]};
imm = {{12{instcode[31]}},instcode[19:12],instcode[20],instcode[30:25],instcode[24:21],1'b0};
end


endcase

end
endmodule
