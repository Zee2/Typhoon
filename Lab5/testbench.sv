module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;


logic[7:0] Switches;
logic Reset_USH, Run_USH, ClearA_LoadB_USH, X;
logic Clk = 0;

logic[6:0] AhexU;
logic[6:0] AhexL;
logic[6:0] BhexU;
logic[6:0] BhexL;
logic[7:0] Aval;
logic[7:0] Bval;

multiplier_toplevel testee(.S_USH(Switches), .*);

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin: CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

initial begin: testing
	Reset_USH = 0;
	Run_USH = 1;
	ClearA_LoadB_USH = 1;
	
	#2
	Reset_USH = 1;
	#2
	Switches = 8'b11111110;
	ClearA_LoadB_USH = 0;
	#2
	ClearA_LoadB_USH = 1;
	#4
	Switches = 8'b11111111;
	#2
	Run_USH = 0;
	#40
	Run_USH = 1;
	#10
	Run_USH = 0;
	#3
	Run_USH = 1;
end

endmodule