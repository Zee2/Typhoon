module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;


logic[7:0] switches;
logic Reset, Run, ClearA_LoadB, X;
logic Clk = 0;

logic[6:0] AhexU;
logic[6:0] AhexL;
logic[6:0] BhexU;
logic[6:0] BhexL;
logic[7:0] Aval;
logic[7:0] Bval;


multiplier_toplevel testee(.S(switches), .*);



// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

initial begin: testing
	Reset = 1;
	Run = 0;
	ClearA_LoadB = 0;
	
	#2
	Reset = 0;
	#2
	switches = 3;
	ClearA_LoadB = 1;
	#2
	ClearA_LoadB = 0;
	#4
	switches = 4;
	#2
	Run = 1;
	#2
	Run = 0;
	#50
	Run = 1;
	#3
	Run = 0;
	
	
end




endmodule