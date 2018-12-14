module testbench();
	timeunit 1ns;	// Half clock cycle at 100 MHz
			// This is the amount of time represented by #1 
	timeprecision 1ns;
	
	logic BOARD_CLK = 0;
	logic SRAM_CLK = 0;
	logic [7:0] VGA_R, VGA_G, VGA_B;
	logic [7:0] LEDG;
	logic [17:0] LEDR;
	logic [3:0] KEY = -1;
	logic [17:0] SW = 16'h0;
	wire[15:0] SRAM_DQ;
	logic[19:0] SRAM_ADDR;
	logic SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	logic VGA_CLK, VGA_BLANK_N, VGA_SYNC_N, VGA_HS, VGA_VS;
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
	/*
	initial begin : test
		#30 GPU.DataToSRAM[0] = 16'hf0f0;
		GPU.AddressToSRAM[0] = -(20'd1);
		GPU.QueueWriteReq[0] = 0;
		GPU.QueueReadReq[0] = 1;
		
		GPU.DataToSRAM[1] = 16'h0f0f;
		GPU.AddressToSRAM[1] = (20'h0f0f);
		GPU.QueueWriteReq[1] = 0;
		GPU.QueueReadReq[1] = 1;
		
		GPU.DataToSRAM[2] = 16'h0f0f;
		GPU.AddressToSRAM[2] = (20'h0f0f);
		GPU.QueueWriteReq[2] = 0;
		GPU.QueueReadReq[2] = 1;
		
		GPU.DataToSRAM[3] = 16'h0f0f;
		GPU.AddressToSRAM[3] = (20'h0f0f);
		GPU.QueueWriteReq[3] = 0;
		GPU.QueueReadReq[3] = 1;
		#20
		GPU.QueueWriteReq[0] = 0;
		GPU.QueueReadReq[0] = 0;
		GPU.QueueWriteReq[1] = 0;
		GPU.QueueReadReq[1] = 0;
		GPU.QueueWriteReq[2] = 0;
		GPU.QueueReadReq[2] = 0;
		
		GPU.DataToSRAM[3] = 16'hf0f0;
		GPU.AddressToSRAM[3] = (20'hf0f0);
		GPU.QueueWriteReq[3] = 1;
		GPU.QueueReadReq[3] = 0;
		
		#20
		
		GPU.DataToSRAM[3] = 16'h0ff0;
		GPU.AddressToSRAM[3] = (20'h0ff0);
		GPU.QueueWriteReq[3] = 0;
		GPU.QueueReadReq[3] = 1;
		
		#20
		
		GPU.QueueWriteReq[3] = 0;
		GPU.QueueReadReq[3] = 0;
	end
	*/
	

endmodule