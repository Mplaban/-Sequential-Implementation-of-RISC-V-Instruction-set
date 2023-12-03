`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2023 14:39:09
// Design Name: 
// Module Name: controlword_str
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


module controlword_str(addr,clk,controlword);
input [4:0] addr;
input clk;
output [27:0] controlword;
reg [27:0] controlword;
reg [27:0] rom [0:31];

//pcup_pcalu_asrccntl_adestcntl_bsrccntl_bdestcntl_alucntl_memcntl_irecntl_nssel_dbin
initial begin
rom [0] = 28 'b01_01_000_00_000_00_000_000_0_00_10111; //start0
rom [1] = 28 'b00_00_001_00_001_00_100_000_0_10_00000; //ads1
rom [2] = 28 'b01_01_000_00_001_10_000_000_0_00_01011; //lui1
rom [3] = 28 'b01_01_101_00_100_00_000_011_0_00_01011; //str1
rom [4] = 28 'b01_01_110_00_001_00_100_000_0_00_00110; //auipc1
rom [5] = 28 'b01_01_001_00_010_00_001_000_0_00_00110; //oprr1 
rom [6] = 28 'b00_00_010_10_000_00_000_000_1_01_00000; //oprr2
rom [7] = 28 'b01_01_001_00_001_00_010_000_0_00_00110; //oprri1
//rom [8] = 28 'b00_00_000_00_000_00_000_000_0_00_00000; 
rom [9] = 28 'b00_00_010_00_000_00_000_010_0_00_01010; //ldi1
rom[10] = 28 'b01_01_100_10_000_00_000_000_0_00_01011; //ldi2
rom[11] = 28 'b00_00_000_00_000_00_000_000_1_01_00000; //ldi3
rom[12] = 28 'b00_10_001_00_010_00_101_000_0_11_01110; //bch1
rom[14] = 28 'b01_01_000_00_000_00_000_000_0_00_01011; //bch3
rom[15] = 28 'b10_00_000_00_000_00_000_000_0_00_01011; //bch2
rom[16] = 28 'b10_10_110_10_000_00_000_000_0_00_01011; //jas1
rom[23] = 28 'b00_00_000_00_000_00_000_000_1_01_00000; //start1

end

 initial begin
//initialize the value of control word register
controlword = 28 'b00_000_00_000_000_000_000_0_00_00000;
end 

always@(posedge clk)begin
controlword <=  rom [addr];
end



endmodule
