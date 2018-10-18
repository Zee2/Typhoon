module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

logic Clk = 0;

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

logic [15:0] S;
logic Reset, Run, Continue;
logic [11:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
logic CE, UB, LB, OE, WE;
logic [19:0] ADDR;
logic[15:0] test;
logic[18:0] test2;
wire [15:0] Data;

lab6_toplevel tested(.*);

logic[15:0] argA;
logic[15:0] argB;

initial begin : testLoop
	for(int i = 0; i < 20; i = i+1) begin: xorloop
		
	
		argA = $random;
		argB = $random;
		
		S = 20; //XOR test
		Continue = 0;
		#20 Reset = 1;
		#2 Reset = 0;
		#2 Reset = 1;
		#20 Run = 1;
		#2 Run = 0;
		#2 Run = 1;
		
		
		#150 S = argA;
		#10 Continue = 1;
		#10 Continue = 0;
		#150 S = argB;
		#10 Continue = 1;
		
		#2000 if(tested.my_slc.d0.registers.Q[3] == (argA ^ argB)) begin
			$display("XOR Passes ");
			$display(argA);
			$display(argB);
			$display(tested.my_slc.d0.registers.Q[3]);
			$display(argA ^ argB);
		end
		else begin
			$display("XOR Fails ");
			$display(argA);
			$display(argB);
			$display(tested.my_slc.d0.registers.Q[3]);
			$display(argA ^ argB);
		end
	
	end
	
	for(int i = 0; i < 20; i = i+1) begin: multiplyloop
		
	
		argA = ($signed($urandom_range(0,256)))-128;
		argB = ($signed($urandom_range(0,256)))-128;
		S = 49; //multiply test
		Continue = 0;
		#20 Reset = 1;
		#2 Reset = 0;
		#2 Reset = 1;
		#20 Run = 1;
		#2 Run = 0;
		#2 Run = 1;
		
		
		#150 S = argA;
		#10 Continue = 1;
		#10 Continue = 0;
		#150 S = argB;
		#10 Continue = 1;
		
		#2000 if($signed(tested.my_slc.d0.registers.Q[5]) == ($signed(argA) * $signed(argB))) begin
			$display("Multiply Passes ");
			$display($signed(argA));
			$display($signed(argB));
			$display($signed(tested.my_slc.d0.registers.Q[5]));
		end
		else begin
			$display("Multiply Fails ");
			$display($signed(argA));
			$display($signed(argB));
			$display($signed(tested.my_slc.d0.registers.Q[5]));
		end
	
	end
	
end

endmodule