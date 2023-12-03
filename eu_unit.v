`timescale 1ns / 1ps
//RT-level model of Seq Implementation of RISC- RV32I Execution Unit including Memory 
//The Memory is byte addressable, size = 1024 words, word size = 32 bits,byte size =16 bits 
//Memory should be initialized to define its contents
//Execution Unit contains ALU which can perform AND , ADD ,OR ,SUB ,SHIFT and EXOR operations
//RISC-R32I instructions ignores carry flag for R-type and I-type alu operations

module eu_unit(clk,eucntl,opcntl,ifd,cc,imm);

input clk;
input [20:0]eucntl;
input [3:0] opcntl;
input [31:0] imm;

output reg [4:0]cc;
output [31:0] ifd;

reg signed [31 : 0] regfile [0: 31], pc, t1,t2, npc, di, irf, ire; 
reg signed [7:0] mem[0:4096];

// pc, irf, ire are declared as signed 
reg signed [31 : 0] a, b;	//data on bus-a and bus-b
reg [2 : 0] alucntl;		//alu function control field in eucntl
reg signed [ 15 : 0 ] aluout;	//output of alu
reg carry;	//carry out from alu
reg ccset;	//signal derived from alucntl, used for updating of condition code register
reg ldt1;
reg [1:0]pcup;
reg [4 : 0] ccreg;	//condition code register
reg[4 : 0] rs1, rs2,rd;	//rx and ry fields of the instruction present in ire register

reg [2 : 0] asrccntl, bsrccntl, bdestcntl, memcntl;	//control fields in eucntl specifying:
//bus-a source register, bus-b source register, bus-b destination register and memory transfer //type. 
reg [1 : 0] adestcntl;	//control field in eucntl specifying bus-a destination register
reg [1:0] pcalu;
integer i = 152; // Data Memory Starting Address

//update ird output whenever register irf changes:  ird is input to the instruction decoder
assign ifd = irf;	

always@(*) begin
rs1 = ire[19:15]; //Source 1 Register
rs2 = ire[24:20]; //Source 2 Register
rd = ire[11:7]; //Desitnation Register
end

always@(*)
begin	
pcup = eucntl[20:19];  //PC Update register control field
pcalu = eucntl [18:17]; //PC ALU register control field
asrccntl = eucntl [ 16 : 14 ];	//a-bus source register control field
bsrccntl = eucntl [ 11 : 9 ]; 	//b-bus source register control field
alucntl = eucntl [ 6 : 4 ]; 	//alu control field
adestcntl = eucntl [ 13 : 12];	//a-bus destination register control field 
bdestcntl = eucntl [ 8 : 7 ];	//b-bus destination register control field
memcntl = eucntl [ 3 : 1 ];	//memory transfer control field
$strobe ( $time, "%m : eucntl =  %b", eucntl);
end

always@(*)
begin
    case(asrccntl)
        3'b001 : a <= (rs1!==0)? regfile[rs1]:0;
        3'b101 : a <= (rs2!==0)? regfile[rs2]:0;
        3'b010 : a <= t1;
        3'b011 : a <= rd;
        3'b100 : a <= di;
        3'b110 : a <= pc;
        default: $display($time,"No valid source for a bus to select");
    
    endcase
    
    case(bsrccntl)
        3'b010 : b <= (rs2!==0) ? regfile[rs2]: 0;
        3'b001 : b <= imm;
        3'b100 : b <= t1;
        default: $display($time,"No valid source for b bus to select");
    endcase
    
    $strobe ($time, "%m : a = %b, b = %b", a, b);

end


always@(*)
begin   
    
    case(alucntl)
        3'b100 : begin 
                aluout = a + b; 
                ldt1=1;
                 end
        3'b110: begin
                aluout = a + 4;
                ldt1 =1;
                end
        //B-Type ALU Operations
        3'b101 : begin 
                    case(opcntl[2:0])
                        3'b000 : aluout = (a == b) ? 1 :0;
                        3'b001 : aluout = (a!=b)? 1 :0;
                        3'b100 : aluout = (a < b)? 1: 0;
                        3'b101 : aluout = (a >= b)? 1:0;
                        3'b110 : aluout = (a < $unsigned(b))? 1:0;
                        3'b111 : aluout = (a >= $unsigned(b))? 1:0;
                    endcase
                 end              
        //I-Type Instruction ALU Operations                  
        3'b010:begin
               ldt1 =1;
               casex(opcntl)
                4'bx000 : aluout = a + b;
                4'bx010 : aluout = (a < b)? 1 :0;
                4'bx011 : aluout = ($unsigned(a) < $unsigned(b))? 1 : 0;
                4'bx100 : aluout = a ^ b;
                4'bx001 : aluout = a << b[4:0];
                4'bx101 : if(opcntl[3] == 0)
                            aluout = a >> b[4:0];
                          else
                            aluout = a >>> b[4:0];
               endcase
               end
         //R-Type Instruction ALU Operation      
        3'b001: begin
                ccset =1 ; ldt1 = 1;
                case(opcntl)
                    4'b0000: aluout = a + b;
                    4'b1000: aluout = a - b;
                    4'b0011: aluout = a << b[4:0];
                    4'b0010: aluout = ($signed(a) < $signed(b))? 1'b1 : 1'b0;
                    4'b0011: aluout = ($unsigned(a)<$unsigned(b))? 1:0;
                    4'b0100: aluout = a ^ b;
                    4'b0101: aluout = a >> b[4:0];
                    4'b1101: aluout = a >>> b[4:0];
                    4'b0110: aluout = a | b;
                    4'b0111:aluout = a & b;                   
                endcase                               
                end
        
    endcase
    

    $strobe ($time, "%m : aluout = %b, ldt1 = %b", aluout, ldt1);
    
end

always@(*)
begin
    case(pcalu)
        2'b01 : npc <= pc + 4;
        2'b10 : npc <= pc + imm*4;
    endcase    
end

always@(aluout)
begin
    cc[0] = aluout;
end

always@(posedge clk)
begin
    if (ldt1) t1 <= aluout;
    
    case(memcntl)
        3'b010 : begin
                    case(opcntl[2:0])
                        3'b000 : di <= {{24{mem[i+a][7]}},(mem[i+a])}; //lb
                        3'b001 : di <= {{16{mem[i+a][15]}},mem[i+a+1],mem[i+a]}; //lh
                        3'b010 : di <= {mem[i+a+3],mem[i+a+2],mem[i+a+1],mem[i+a]}; //lw
                        3'b100 : di <= {{16{1'b0}},mem[i+a+1],mem[i+a]}; //lhu
                        3'b101 : di <= {{24{1'b0}},(mem[i+a])}; //lbu
                        default: di<=20;
                    endcase
                 end
         3'b011 :begin
                    case(opcntl[2:0])
                        3'b000:{mem[i+b+3],mem[i+b+2],mem[i+b+1], mem[i+b]} = a[7:0];
                        3'b001:{mem[i+b+3],mem[i+b+2],mem[i+b+1], mem[i+b]} = a[15:0];
                        3'b010:{mem[i+b+3],mem[i+b+2],mem[i+b+1], mem[i+b]} = a;
                    endcase 
                 end
    endcase
    case(adestcntl)
        2'b10 : regfile[rd] <= (rd!=0)?a:0;
        default: $display($time,"No valid dest for a bus to select");
    endcase
    
    case(pcup)
        2'b01 :begin // PC normal Update
                 pc <= npc;
                 irf <= {mem[pc+3],mem[pc+2],mem[pc+1],mem[pc+0]};
               end
        2'b10 : begin //PC Update for Branch
                 pc <= npc+4;
                 irf <= {mem[npc+3],mem[npc+2],mem[npc+1],mem[npc+0]};
               end
    endcase
    
    case(bdestcntl)
        2'b10 : regfile[rd] <= (rd!=0)? b : 0;
        default: $display($time,"No valid dest for b bus to select");
    endcase
    
    $strobe ($time, "%m : t1, t2, di, irf, ire :  %d, %d, %d, %h, %h", t1, t2, di, irf, ire );  
    $strobe ($time, "%m : rs1 , rs2, rd , [rs1], [rs2], [rd] :  %d, %d, %d, %d, %d, %d", rs1, rs2,rd, regfile[rs1], regfile[rs2],regfile[rd]);
    $strobe ($time, "%m : r[%d] = %d, r[%d] = %d, pc = %d", rs1, regfile[rs1], rs2, regfile[rs2], pc); 
end


always@(posedge clk)begin
if(eucntl[0]) ire <= irf;
end

//………………………………..I N I T I A L I Z A T I O N S………………………………………………….
/* In the Execution Unit certain registers and memory locations need to be initialized for functional test purposes
These initializations alone are not sufficient. They need to be complemented by the appropriate initializations required in other modules
It is assumed here that in the "controlstore" module  the "controlword" register that provides synchronous output from the module "controlstore" is initialized to have all its bits as "0"
Consequently, no register transfers take place in the Execution Unit at the first
positive edge of the clock. However, at the first positive edge of the clock
the "controword" register is updated with the control word value stored at 
ROM address 0 (state st0)
This control word is the first control word of the two control word long start-up sequence.  It operates during the next clock cycle and achieves the following  
at the next positive edge of the clock:
(1) stores into "irf" register the instruction fetched from the memory using 
initialized value of the "PC" as address for the memory access.
(2) stores the incremented value of the "PC" in "t1"register. 
(3) "controlword" register value is updated  with the control word value stored at  
ROM address 11 (state st11, the second and last state of the start-up sequence)
This control word operates during the next clock cycle and achieves the following 
at the next positive edge of the clock:
(1)	Contents of "irf" are copied into "ire"
(2)	Contents of "t1" register are transferred to "PC"
(3)	"controlword" register value is updated with the control word stored at ROM address provided by the "ib" port of the instruction decoder
Hereafter, normal execution of the instructions begins with the execution of the first instruction (that was fetched by the start-up sequence */ 


//Data initialization:
initial
begin
regfile[0]=0;regfile[2]=23;regfile[4] = 25;regfile[5]=22;regfile [7] = 16;regfile[8]=0;regfile[9]=92;
regfile[13]=0;regfile[17] = 1;regfile[18]=2;
{mem[255],mem[254],mem[253],mem[252]}= 32'h0000fd48;
end

//program initialization:
//TEST PROGRAM
/*
     ASSEMBLY CODE              MEM             32-bit BINARY INSTRUCTION CODE
      ADD X1,X2,X7                  0           32 'b0000000_00111_00010_000_00001_0110011   
      ADD X3,X1,X7                  4           32 'b0000000_00111_00001_000_00011_0110011
      ADDI X15,X4,#-50              8           32 'b1111110_01110_00100_000_01111_0010011
      SLLI X6,X5,#2                 12          32 'b0000000_00010_00101_001_00110_0010011
      LW x14,8(X9)                  16          32 'b0000000_01000_01001_010_01110_0000011
      SWB X14,8(X8)                 20          32 'b0000000_01110_01000_000_01000_0100011
      LUI X10,0x87654               24          32 'b1000011_10110_01010_100_01010_0110111
      ADDI X15,X4,#-50              28          32 'b1111110_01110_00100_000_01111_0010011
      AUIPC X11,#2                  32          32 'b0000000_00000_00000_010_01011_0010111
      BEQ X17,X18,B1                36          32 'b0000000_10010_10001_000_00010_1100011
      SLTI X13,X13,#2               40          32 'b0000000_00010_01101_010_01101_0010011
  B1: 
      SLT X20,X2,X1                 48          32 'b0000000_00001_00010_010_10100_0110011   
      JAL X21, J1                   52          32 'b0000000_00010_00000_000_10101_1101111   
  J1:
      NOP                           64            
  

*/
initial
begin
pc = 0;
{mem[3],mem[2],mem[1],mem [0]}   = 32 'b0000000_00111_00010_000_00001_0110011; // add x1,x2,x7
{mem[7],mem[6],mem[5],mem [4]}   = 32 'b0000000_00111_00001_000_00011_0110011; // add x3,x1,x7
{mem[11],mem[10],mem[9],mem[8]}  = 32 'b1111110_01110_00100_000_01111_0010011; //addi x15,x4,#-50
{mem[15],mem[14],mem[13],mem[12]}= 32 'b0000000_00010_00101_001_00110_0010011; //slli x6,x5,#2
{mem[19],mem[18],mem[17],mem[16]}= 32 'b0000000_01000_01001_010_01110_0000011; //lw x14,8(x9)
{mem[23],mem[22],mem[21],mem[20]}= 32 'b0000000_01110_01000_000_01000_0100011; //swb x14,8(x8)
{mem[27],mem[26],mem[25],mem[24]}= 32 'b1000011_10110_01010_100_01010_0110111; //lui x10,0x87654
{mem[31],mem[30],mem[29],mem[28]}= 32 'b1111110_01110_00100_000_01111_0010011; //addi x15,x4,#-50
{mem[35],mem[34],mem[33],mem[32]}= 32 'b0000000_00000_00000_010_01011_0010111; //auipc x11, #2 
{mem[39],mem[38],mem[37],mem[36]}= 32 'b0000000_10010_10001_000_00010_1100011; //beq x17,x18,#2 
{mem[43],mem[42],mem[41],mem[40]}= 32 'b0000000_00010_01101_010_01101_0010011; //slti x13,x13,#2
{mem[51],mem[50],mem[49],mem[48]}= 32 'b0000000_00001_00010_010_10100_0110011; //slt x20,x2,x1
{mem[55],mem[54],mem[53],mem[52]}= 32 'b0000000_00010_00000_000_10101_1101111; //jal X21,#2
{mem[67],mem[66],mem[65],mem[64]}= 32 'b0000000_00000_00000_000_00000_0001011; //nop

end

endmodule
