


module Typhoon #(parameter NUM_sHADER_CORES = 8)(
	
	
	inout wire[15:0] SRAM_DQ,
	output logic[19:0] SRAM_ADDR,
	output logic SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
	output logic[7:0] LEDG,
	output logic[17:0] LEDR,
	output logic[7:0] VGA_R, VGA_G, VGA_B,
	
	input logic[3:0] KEY,
	input logic[17:0] SW,
	input logic BOARD_CLK
	
	
	
);


	logic SRAM_CLK;
	logic[15:0] DataToSRAM[NUM_sHADER_CORES];
	logic[19:0] AddressToSRAM[NUM_sHADER_CORES];
	logic [NUM_sHADER_CORES-1:0] QueueReadReq, QueueWriteReq;
	logic [9:0] dummyCounter = 0;
	logic [NUM_sHADER_CORES-1:0] DataReady;
	
	logic isDoubleBuffering;
	
	logic[15:0] DataFromSRAM[NUM_sHADER_CORES];

	enum logic [7:0] {
		init = 8'd0,
		store = 8'd1,
		fetch = 8'd2,
		memFetchWait = 8'd3,
		check = 8'd4,
		bigwait = 8'd5
	} debugState = init, nextState = init;
	
	assign LEDG = debugState;
	
	
	always_ff @(posedge BOARD_CLK) begin
		debugState <= nextState;
		if(debugState == check)
			LEDR <= DataFromSRAM[0];
		//LEDR <= KEY;
		dummyCounter <= dummyCounter + 1;
	end
	
	always_comb begin
		QueueReadReq[0] = 0;
		QueueWriteReq[0] = 0;
		
		QueueWriteReq[1] = 0;
		QueueReadReq[1] = 0;
		
		unique case(debugState)
			init: begin
				DataToSRAM[0] = 0;
				AddressToSRAM[0] = 0;
				QueueReadReq[0] = 0;
				QueueWriteReq[0] = 0;
				nextState = store;
			end
			
			store: begin
				DataToSRAM[0] = SW;
				AddressToSRAM[0] = 20'h000f;
				QueueWriteReq[0] = 1;
				QueueReadReq[0] = 0;
				
				DataToSRAM[1] = 16'hbaba;
				AddressToSRAM[1] = 20'h0f0f;
				QueueWriteReq[1] = 0;
				QueueReadReq[1] = 0;
				
				
				nextState = bigwait;
			end
			
			bigwait: begin
				DataToSRAM[0] = 16'ha0a0;
				AddressToSRAM[0] = 20'h00f0;
				QueueWriteReq[0] = 0;
				QueueReadReq[0] = 0;
				
				QueueWriteReq[1] = 0;
				QueueReadReq[1] = 0;
				
				if(dummyCounter % 2 == 0)
					nextState = fetch;
				else
					nextState = bigwait;
			
			end
			
			
			
			fetch: begin
				DataToSRAM[0] = 16'h0101;
				AddressToSRAM[0] = KEY[0] ? 20'h000f : 20'hffff;
				QueueWriteReq[0] = 0;
				QueueReadReq[0] = 1;
				
				DataToSRAM[1] = 16'hffff;
				AddressToSRAM[1] = 20'h000f;
				QueueWriteReq[1] = 0;
				QueueReadReq[1] = 1;
				
				nextState = memFetchWait;
			
			end
			
			memFetchWait: begin
				
				DataToSRAM[0] = 16'heeee;
				AddressToSRAM[0] = 20'h00f0;
				QueueReadReq[0] = 0;
				QueueWriteReq[0] = 0;
				
				DataToSRAM[1] = 16'hfefe;
				AddressToSRAM[1] = 20'h000f;
				QueueWriteReq[1] = 0;
				QueueReadReq[1] = 0;
				
				if(DataReady[0] == 1'b1) begin
					nextState = check;
				end else begin
					nextState = memFetchWait;
				end
			end
			
			check: begin
				DataToSRAM[0] = 16'hafaf;
				AddressToSRAM[0] = 20'h00f0;
				QueueReadReq[0] = 0;
				QueueWriteReq[0] = 0;
				
				QueueWriteReq[1] = 0;
				QueueReadReq[1] = 0;
				
				if(KEY[0] == 0)
					nextState = init;
				else
					nextState = init;

			end
			
			default: begin
				DataToSRAM[0] = 0;
				AddressToSRAM[0] = 0;
				QueueReadReq[0] = 0;
				QueueWriteReq[0] = 0;
				QueueWriteReq[1] = 0;
				QueueReadReq[1] = 0;
				nextState = init;
			end
		
		endcase
	end


	// Various specced system clocks

	logic VGA_CLK, SDRAM_CLK;

	// VGA timing signals
	
	logic VGA_reset, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	
	// VGA x-y scan coords, used for framebuffer polling
	
	logic[9:0] VGA_SCAN_X, VGA_SCAN_Y;

	//SRAMCLK pll(.inclk0(BOARD_CLK), .c0(SRAM_CLK), .c1(VGA_CLK));
	
	mem_clk myTest(.inclk0(BOARD_CLK), .c0(SRAM_CLK), .c1(VGA_CLK));
	
	VGA_controller VGAtiming(.Clk(BOARD_CLK), .Reset(VGA_reset), .DrawX(VGA_SCAN_X), .DrawY(VGA_SCAN_Y), .*);
	/*
	VGA_port colorOutput(.BOARD_CLK(BOARD_CLK),
								.vga_clk(VGA_CLK), 
								.VGA_SCAN_X(VGA_SCAN_X),
								.VGA_SCAN_Y(VGA_SCAN_Y),
								.doubleBuffer(isDoubleBuffering),
								.framebufferData(DataFromSRAM[1]),
								.dataReady(DataReady[1]),
								.framebufferAddress(AddressToSRAM[1]),
								.queueRead(QueueReadReq[1]),
								.R(VGA_R),
								.G(VGA_G),
								.B(VGA_B));
								
	*/
	SRAM_controller #(NUM_sHADER_CORES) SRAM(.SRAM_DQ(SRAM_DQ), .*);

endmodule