module NZPlogic(
	input logic Clk,
	input logic LD_BEN,
	input logic LD_CC,
	input logic[15:0] Bus,
	input logic[15:0] IR,
	input logic Reset,
	output logic BEN

);
	
	
	logic N, Z, P;
	logic[2:0] NZP;
	internal_register #(3) NZPregister(.D({N,Z,P}), .Q(NZP), .Load(LD_CC), .*);
	
	assign N = Bus[15]; // When bus sign bit is one, must be negative....
	assign Z = Bus == 0; 
	assign P = ~(N || Z);
	
	logic BEN_in;
	internal_register #(1) BENregister(.D(BEN_in), .Q(BEN), .Load(LD_BEN), .*);
	
	assign BEN_in = (NZP & IR[11:9]) != 0;
	
endmodule