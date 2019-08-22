/*

	framebuffer.sv
	Finn Sinclair 2018

	Basic two-port memory controller, dedicated read and write ports.
	
	

*/

module framebuffer #(parameter tileDim = 8'd8)(
	inout wire[15:0] SRAM_DQ,
	output logic[19:0] SRAM_ADDR,
	output logic SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N = 1,
	
	
	input logic[9:0] VGA_SCAN_X, VGA_SCAN_Y,
	input logic[9:0] xOffset, yOffset,
	input logic VGA_VS,
	input logic VGA_BLANK_N,
	input logic streamTileTrigger, // Trigger to begin streaming tile at (xOffset, yOffset)
	
	input logic doubleBuffer,
	
	input logic streamingTileID,
	input logic nextStreamingTileID,
	input logic[15:0] tileAinput [tileDim][tileDim],
	input logic[15:0] tileBinput [tileDim][tileDim],
	
	//output logic[17:0] LEDR,
	
	output logic [7:0] VGA_R, VGA_G, VGA_B,
	
	output logic doneStreaming,
	input logic VGA_CLK, //25 MHz VGA clock
	input logic BOARD_CLK //50 MHz FPGA clock, for incoming requests
	
);

parameter doubleBufferOffset = 800*525;

logic lastTrigger = 0; // Single clock delayed trigger signal




logic nextDoneStreaming;
logic[15:0] DataToSRAM;
logic[15:0] funDemo = 0;
//assign DataToSRAM = SW;
logic[19:0] WriteAddress;
logic[7:0] tilePointerX = 0, tilePointerY = 0, nextTilePointerX = 0, nextTilePointerY = 0;

logic[19:0] tileOffsetX, tileOffsetY;
logic[19:0] newTileOffsetX, newTileOffsetY;

//assign tileOffsetX = xOffset;
//assign tileOffsetY = yOffset;

logic idle, nextIdle = 0;

enum logic [1:0]{
	feedingVGA,
	streaming
} state, nextState;

//logic[15:0] DQ_buffer; // tri-state buffer

logic lastOpRead = 0;

logic readSync = 0, lastReadSync;

logic ReadQueued, WriteQueued;

assign SRAM_CE_N = 0; // Always chip-enable
assign SRAM_UB_N = 0; // Always writing both bytes
assign SRAM_LB_N = 0;

assign SRAM_OE_N = 0; // Hmmm...


assign SRAM_DQ = ~SRAM_WE_N ? DataToSRAM : 16'bz;

//assign DataToSRAM = tileA[tilePointerX][tilePointerY];
//assign WriteAddress = 0;
assign WriteAddress = (tileOffsetX+tilePointerX) + (tileOffsetY+tilePointerY)*800 + (doubleBuffer == 1 ? doubleBufferOffset : 0);

//assign SRAM_ADDR = (state == feedingVGA) ? ReadAddress : WriteAddress;
//assign SRAM_ADDR = ReadAddress;
//assign SRAM_WE_N = (state == streaming);
//assign SRAM_WE_N = -1;
//assign LEDR = streamingTileID ? 2 : 1;

always_ff @(posedge BOARD_CLK) begin: mainblock
	lastTrigger <= streamTileTrigger;
	doneStreaming <= nextDoneStreaming;

	if(lastOpRead) begin
		VGA_R <= SRAM_DQ[4:0] << 3;
		VGA_G <= SRAM_DQ[10:5] << 2;
		VGA_B <= SRAM_DQ[15:11] << 3;
	end
	
	if(state == feedingVGA) begin
	
		lastOpRead <= 1; // So we fetch data next clock
		SRAM_ADDR <= VGA_SCAN_X + 800 * VGA_SCAN_Y  + (doubleBuffer == 1 ? 0 : doubleBufferOffset);
		
		SRAM_WE_N <= 1;
	end
	else if(state == streaming && idle == 0) begin
		lastOpRead <= 0;
		SRAM_WE_N <= 0;
		DataToSRAM <= nextStreamingTileID == 0 ? tileAinput[tilePointerX][tilePointerY] : tileBinput[tilePointerX][tilePointerY];
		//DataToSRAM <= streamingTileID == 0 ? 0 : tileBinput[tilePointerX][tilePointerY];
		SRAM_ADDR <= WriteAddress;
	end
	
	state <= nextState;
	idle <= nextIdle;
	tilePointerX <= nextTilePointerX;
	tilePointerY <= nextTilePointerY;
	
	
	tileOffsetX <= newTileOffsetX;
	tileOffsetY <= newTileOffsetY;
end


always_comb begin

	if(VGA_BLANK_N) begin // if we are pushing pixels to vga out
		if(state == streaming) // if currently streaming tile, switch to vga
			nextState = feedingVGA;
		else 
			nextState = streaming;
	end
	else begin // we are blanking
		nextState = streaming;
	end
	
	nextTilePointerX = tilePointerX;
	nextTilePointerY = tilePointerY;
	
	newTileOffsetX = tileOffsetX;
	newTileOffsetY = tileOffsetY;
	nextDoneStreaming = 0;
	nextIdle = idle;
	if(state == streaming) begin
		nextIdle = 0;
		if(idle == 1) begin //If we are idling...
			nextDoneStreaming = 1;
			nextIdle = 1;
			// If streamTileTrigger == 1, we stop idling
			if(streamTileTrigger || lastTrigger) begin
				nextIdle = 0;
				nextDoneStreaming = 0;
				newTileOffsetX = xOffset;
				newTileOffsetY = yOffset;
			end
			
			nextTilePointerX = 0;
			nextTilePointerY = 0;
		end
		else if(tilePointerY == tileDim-1 && tilePointerX == tileDim-1 && idle == 0) begin // end of tile
			nextDoneStreaming = 1;
			
			nextIdle = 1;
			//if(streamTileTrigger == 1)
				//nextIdle = 0;
			//else
				//nextIdle = 1;
			nextTilePointerX = 0;
			nextTilePointerY = 0;
		end
	
		else if(nextTilePointerX == tileDim-1) begin
			nextIdle = 0;
			nextTilePointerX = 0;
			nextTilePointerY = tilePointerY+1;
		end
		else begin
			nextIdle = 0;
			nextTilePointerX = tilePointerX + 1;
			nextTilePointerY = tilePointerY;
		end
	end

	

	
end
endmodule