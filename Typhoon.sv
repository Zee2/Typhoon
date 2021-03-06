


module Typhoon #(tileDim = 8'd16, binFactor = 7)(
	
	
	inout wire[15:0] SRAM_DQ,
	output logic[19:0] SRAM_ADDR,
	output logic SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
	output logic[7:0] LEDG,
	output logic[17:0] LEDR,
	output logic[7:0] VGA_R, VGA_G, VGA_B,
	output logic VGA_CLK, VGA_BLANK_N, VGA_SYNC_N, VGA_HS, VGA_VS,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
	input logic[3:0] KEY,
	input logic[17:0] SW,
	input logic BOARD_CLK
	
	
);

	parameter binBits = 11-binFactor;
	parameter numBinsSideX = 2**(binBits-1);
	parameter numBinsSideY = 2**(binBits-1);
	

	logic SRAM_CLK;
	logic QueueReadReq;
	logic [15:0] dummyCounter = 0;
	logic DataReady;
	logic doneStreaming;
	logic doneRasterizing = 1;
	//assign doneRasterizing = 1;
	logic VGA_reset;
	
	reg [15:0] tileAinput [tileDim][tileDim];
	reg [15:0] tileBinput [tileDim][tileDim];
	
	logic rasterTrigger = 0;
	logic nextRasterTrigger = 0;
	
	logic startTransformTrigger;
	logic nextStartTransformTrigger;
	logic doneBinning;
	
	
	// Interconnect signals between the rasterizer core and the vertex transform core
	logic[143:0] binMemoryQ;
	logic[11:0] binMemoryReadAddress;
	logic[11:0] linkedListHeadPointers[numBinsSideX][numBinsSideY];
	
	vertex_transform_new #(binFactor) transform_core(
		.startTrigger(startTransformTrigger),
		.doneBinning(doneBinning),
		.listRegisters(linkedListHeadPointers),
		.*
	);
	
	rasterizer #(tileDim, binFactor) tiledRasterizer(.cBufferTile0(tileAinput),
													  .cBufferTile1(tileBinput),
													  .doneRasterizing(doneRasterizing),
													  .startRasterizing(rasterTrigger),
													  .linkedListHeadPointers(linkedListHeadPointers),
													  .*);
	
	
	
	logic[19:0] WriteAddress;
	logic[19:0] ReadAddress;
	
	logic[9:0] streamingxOffset = 0, streamingyOffset = 0;
	logic[9:0] nextStreamingxOffset = 0, nextStreamingyOffset = 0;
	logic[9:0] rasterxOffset = 0, rasteryOffset = 0;
	logic[9:0] nextRasterxOffset, nextRasteryOffset;
	
	//debug
	logic lastDoneStreaming = 0;
	
	logic streamTileTrigger = 0;
	logic nextStreamTileTrigger = 0;
	
	logic doubleBuffer = 0;
	logic nextDoubleBuffer = 0;
	
	logic rasterTileID = 0;
	logic nextRasterTileID = 0;
	
	logic streamingTileID = 0;
	logic nextStreamingTileID = 0;
	
	logic[15:0] DataFromSRAM;

	enum logic [7:0] {
		initState,
		startBinTiles,
		binTiles,
		rasterTile,
		moveTile,
		endState,
		endState2
	} state = initState, nextState = initState, lastState = initState;
	
	//assign LEDR = state;
	/*
	genvar x;
		genvar y;
		generate
		for(x = 0; x < tileDim; x++) begin: fillX
			for(y = 0; y < tileDim; y++) begin: fillY
				debug_shader #(x,y) shader(.screenx(rasterxOffset), .pixel0(tileAinput[x][y]),.pixel1(tileBinput[x][y]), .rasterTile(rasterTileID), .*);
			end
			
		end
		
		
		endgenerate
	*/
	
	always_ff @(posedge BOARD_CLK) begin
	
		
		doubleBuffer <= nextDoubleBuffer;
		
	
		dummyCounter <= dummyCounter + 1;
		state <= nextState;
		lastState <= state;
		streamingxOffset <= nextStreamingxOffset;
		streamingyOffset <= nextStreamingyOffset;
		streamTileTrigger <= nextStreamTileTrigger;
		rasterTileID <= nextRasterTileID;
		rasterxOffset <= nextRasterxOffset;
		rasteryOffset <= nextRasteryOffset;
		
		streamingTileID <= nextStreamingTileID;
		rasterTrigger <= nextRasterTrigger;
		
		lastDoneStreaming <= doneStreaming;
	end
	
	
	always_comb begin
		nextRasterTileID = rasterTileID;
		nextRasterxOffset = rasterxOffset;
		nextRasteryOffset = rasteryOffset;
		nextStreamingxOffset = streamingxOffset;
		nextStreamingyOffset = streamingyOffset;
		nextStreamTileTrigger = 0;
		nextRasterTrigger = 0;
		nextState = initState;
		nextStreamingTileID = streamingTileID;
		startTransformTrigger = 0;
		nextDoubleBuffer = doubleBuffer;
		unique case(state)
			initState: begin
				nextRasterTileID = 0;
				nextState = startBinTiles;
			end
			
			startBinTiles: begin
				startTransformTrigger = 1;
				nextState = binTiles;
			end
			
			binTiles: begin
				if(doneBinning)begin
					nextState = rasterTile;
				end
				else begin
					nextState = binTiles;
				end
			end
			
			rasterTile: begin
				//nextState = initState;
				nextRasterTrigger = 1;
				//if(doneStreaming == 1 && lastDoneStreaming != 1 && doneRasterizing == 1)
				if(doneStreaming == 1 && doneRasterizing == 1 && lastState != moveTile)
					nextState = moveTile;
				else
					nextState = rasterTile;
				
			end
			
			moveTile: begin
				nextRasterTrigger = 0;
				nextStreamingxOffset = rasterxOffset; // Set streaming offset to last rasterized tile offset
				nextStreamingyOffset = rasteryOffset;
				nextStreamTileTrigger = 1;
				nextStreamingTileID = rasterTileID;
				nextRasterTileID = ~rasterTileID;
				if((10'd640-rasterxOffset + tileDim) < 2*tileDim && (10'd480 - rasteryOffset) < tileDim) begin // at bottom right corner
					nextRasterxOffset = 0;
					nextRasteryOffset = 0;
					nextState = endState;
				end
				else
				if((10'd640 - rasterxOffset + tileDim) < 2*tileDim) begin // at right edge
					nextRasterxOffset = 0;
					nextRasteryOffset = rasteryOffset + tileDim;
					nextState = rasterTile;
				end
				else begin
				
					nextRasterxOffset = rasterxOffset + tileDim; // in middle of screen somewhere
					nextRasteryOffset = rasteryOffset;
					nextState = rasterTile;
				end
			end
			
			
			endState: begin
				nextDoubleBuffer = ~doubleBuffer;
				nextState = initState;
				//nextState = endState;
			end
			
			endState2: begin
				nextState = KEY[0] ? initState : endState2;
			end
			
			default: begin
			
			end
		
		endcase
	end
	

	// Various specced system clocks

	logic SDRAM_CLK;

	// VGA timing signals
	
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
								.framebufferData(DataFromSRAM),
								.dataReady(DataReady),
								.framebufferAddress(ReadAddress),
								.queueRead(QueueReadReq),
								.R(VGA_R),
								.G(VGA_G),
								.B(VGA_B));
	*/
	//assign VGA_R = -1;
	//assign VGA_G = -1;
	//assign VGA_B = -1;
	
	framebuffer #(tileDim) SRAM(.streamingTileID(streamingTileID), .xOffset(streamingxOffset), .yOffset(streamingyOffset), .SRAM_DQ(SRAM_DQ), .*);
	
	//HexDriver hex_driver3 (DataFromSRAM[1][15:12], HEX3);
	//HexDriver hex_driver2 (DataFromSRAM[1][11:8], HEX2);
	//HexDriver hex_driver1 (DataFromSRAM[1][7:4], HEX1);
	//HexDriver hex_driver0 (DataFromSRAM[1][3:0], HEX0);

endmodule