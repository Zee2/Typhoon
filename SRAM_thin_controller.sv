/*

	SRAM_thin_controller.sv
	Finn Sinclair 2018

	Basic two-port memory controller, dedicated read and write ports.
	
	Separately clocked from main clock.

	Customer modules should watch the appropriate active-high DataReady signal.

*/

module SRAM_thin_controller #(parameter tileDim = 8'd8)(
	inout wire[15:0] SRAM_DQ,
	output logic[19:0] SRAM_ADDR,
	output logic SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N = 1,

	input logic[9:0] xOffset, yOffset,
	input logic VGA_VS,
	input logic streamTile, // Trigger to begin streaming tile at (xOffset, yOffset)
	
	input logic [17:0] SW,
	
	input logic[19:0] ReadAddress,
	input logic QueueReadReq,
	
	input logic[15:0] tileA [tileDim][tileDim],
	input logic[15:0] tileB [tileDim][tileDim],
	
	output logic[17:0] LEDR,
	output logic DataReady = 1,
	output logic [15:0] DataFromSRAM,

	input logic SRAM_CLK, //100 MHz SRAM clock, allow for "double data rate"
	input logic BOARD_CLK //50 MHz FPGA clock, for incoming requests
	
);

logic[15:0] DataToSRAM;
logic[15:0] funDemo = 0;
//assign DataToSRAM = SW;
logic[19:0] WriteAddress = 0;
logic[7:0] tilePointerX = 0, tilePointerY = 0, nextTilePointerX = 0, nextTilePointerY = 0;

logic[19:0] tileOffsetX, tileOffsetY;

assign tileOffsetX = xOffset;
assign tileOffsetY = yOffset;


enum logic {
	A = 1'b0,
	B = 1'b1
} currentStreamingTile, nextStreamingTile;

enum logic [1:0]{
	feedingVGA,
	streaming,
	idle
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

assign DataToSRAM = SW;
assign WriteAddress = 0;
//assign WriteAddress = (tileOffsetX+tilePointerX) + (tileOffsetY+tilePointerY)*800;

//assign SRAM_ADDR = (state == feedingVGA) ? ReadAddress : WriteAddress;
//assign SRAM_ADDR = ReadAddress;
//assign SRAM_WE_N = (state == streaming);
//assign SRAM_WE_N = -1;
assign LEDR = tilePointerX;

always_ff @(posedge SRAM_CLK) begin: mainblock
	
	
	readSync <= QueueReadReq;
	lastReadSync <= readSync;
	ReadQueued <= (readSync && (lastReadSync == 0));
	
	if(QueueReadReq && DataReady == 1)
		DataReady <= 0;
	
	

	//At clock edge, read data from SRAM if last operation was a read
	if(lastOpRead && state != idle) begin
		DataReady <= 1;
		ReadQueued <= 0;
		DataFromSRAM <= SRAM_DQ; // Latch in output
	end
	if(state == feedingVGA) begin
	
		lastOpRead <= 1; // So we fetch data next clock
		SRAM_ADDR <= ReadAddress;
		SRAM_WE_N <= 1;
	end
	else if(state == streaming) begin
		lastOpRead <= 0;
		SRAM_WE_N <= 0;
		SRAM_ADDR <= WriteAddress;
	end
	
	state <= nextState;
	tilePointerX <= nextTilePointerX;
	tilePointerY <= nextTilePointerY;
	
	
end


// Intelligent round-robin queueing. Cascades to the next non-empty FIFO
// if the immediately adjacent FIFO is empty. 

always_comb begin

	nextStreamingTile = currentStreamingTile; // by default, usually the case

	unique case(state)
		feedingVGA: begin
				nextState = streaming;
				nextTilePointerX = tilePointerX;
				nextTilePointerY = tilePointerY;
		end
		
		
		streaming, idle: begin
			if(ReadQueued) begin
				nextState = feedingVGA;
				
				if(nextTilePointerX == 8'd7) begin
					nextTilePointerX = 0;
					nextTilePointerY = tilePointerY+1;
				end
				else begin
					nextTilePointerX = tilePointerX + 1;
					nextTilePointerY = tilePointerY;
				end
				
			end
			else if(tilePointerY == 8'd7 && tilePointerX == 8'd7) begin
				nextStreamingTile = currentStreamingTile == A ? B : A; // Switch tiles
				nextState = idle;
				nextTilePointerX = 0;
				nextTilePointerY = 0;
			end
			else begin
				nextState = streaming;
				
				if(nextTilePointerX == 8'd7) begin
					nextTilePointerX = 0;
					nextTilePointerY = tilePointerY+1;
				end
				else begin
					nextTilePointerX = tilePointerX + 1;
					nextTilePointerY = tilePointerY;
				end
				
			end
		
		end
		default: begin
			nextTilePointerX = tilePointerX;
			nextTilePointerY = tilePointerY;
		end
		
		
	endcase
	
end
endmodule