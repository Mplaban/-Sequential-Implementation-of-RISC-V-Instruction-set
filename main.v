`timescale 1ns / 1ps
////////////////////////////////////////////////
// Top-level module. Instantiates and wires the four lower-level module
// convention: wires that connect module instances have their names beginning with character "w"
module main; 
reg sysclock;
wire [27:0] wcontword;
wire [20:0] weucntl;
wire [4:0] wnextst, wib, wsb, wdb;
wire [31:0] wifd;
wire [3:0] wop_s;
wire [1:0] wnssel;
wire [4:0] wccz;
wire [31:0] wimm;
assign wdb = wcontword [4:0];
assign wnssel = wcontword [6:5];
assign weucntl = wcontword [27:7];
// 1. Instantiate module controlstore : provides positive edge registered controlword for a given state
controlword_str controlgen (.addr (wnextst), .clk (sysclock), .controlword (wcontword));
// 2. Instantiate module mineu : min execution unit extended to include synchronous main memory 
eu_unit exeunit (.eucntl (weucntl), .opcntl (wop_s), .clk (sysclock), .cc(wccz), .ifd (wifd),.imm(wimm));	
/* 3. Instantiate module  instdecoder : instruction decoder provides ib, sb and op-s for an instruction */
inst_decoder decoder (.instcode (wifd), .ib (wib), .sb (wsb), .op_s (wop_s),.imm(wimm));
// 4. Instantiate  module nslogic : the logic to generate next state (next control ROM address)
ns_logic nextstgen (.ibin (wib), .sbin (wsb), .dbin (wdb), .cbin (wccz), .nssel (wnssel), .nextst (wnextst));

// system clock generator
initial
sysclock = 0;
always
begin
# 10 sysclock = ~sysclock;
if ($time >= 800) $finish;
end
endmodule



