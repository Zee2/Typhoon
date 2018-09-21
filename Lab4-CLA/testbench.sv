module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;
//Controls
logic Clk = 0;
logic Reset, LoadB, Run;
logic[15:0] SW;


//Outputs from adders
logic CO;
logic[15:0] Sum;

logic[6:0]      Ahex0;      // Hex drivers display both inputs to the adder.
logic[6:0]      Ahex1;
logic[6:0]      Ahex2;
logic[6:0]      Ahex3;
logic[6:0]      Bhex0;
logic[6:0]      Bhex1;
logic[6:0]      Bhex2;
logic[6:0]      Bhex3;

logic[15:0] valA = $urandom_range(0,255);
logic[15:0] valB = $urandom_range(0,255);

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

lab4_adders_toplevel testing(.*);

initial begin : testLoop
	for(int i = 0; i < 100; i = i+1) begin: testloop
	
		valA = $urandom_range(0,255);
		valB = $urandom_range(0,255);

		#4
		Reset = 0;
		LoadB = 1;
		Run = 1;
		SW = valA;
		
		#4 Reset = 1;
		
		#2 LoadB = 0;
		#2 LoadB = 1;
		SW = valB;
		
		#4 Run = 0;
		#2 Run = 1;
		
		
		#10 if(Sum != valA + valB) begin
					$display("Failure");
					$display(valA);
					$display(valB);
		end
		else
			$display("Awesome!");
	end
end

endmodule