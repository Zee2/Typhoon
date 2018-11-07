module testbench();
	timeunit 1ns;	// Half clock cycle at 100 MHz
			// This is the amount of time represented by #1 
	timeprecision 1ns;
	
	logic BOARD_CLK = 0;
	logic SRAM_CLK = 0;
	
	wire[15:0] SRAM_DQ;
	logic[19:0] SRAM_ADDR;
	logic SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N;
	
	
	Typhoon GPU(.*);
	
	always begin : BOARD_CLOCK_GENERATION
		#10 BOARD_CLK = ~BOARD_CLK;
		
		
	end
	
	always begin : SRAM_CLOCK_GENERATION
		#5 SRAM_CLK = ~SRAM_CLK;
	end
		

	initial begin: CLOCK_INITIALIZATION
		BOARD_CLK = 0;
		SRAM_CLK = 1;
	end
	
	initial begin : test
		#30 GPU.DataToSRAM[0] = 16'hf0f0;
		GPU.AddressToSRAM[0] = -(20'd1);
		GPU.QueueWriteReq[0] = 0;
		GPU.QueueReadReq[0] = 1;
		#20
		GPU.QueueWriteReq[0] = 0;
		GPU.QueueReadReq[0] = 0;
	end
	
	

endmodule