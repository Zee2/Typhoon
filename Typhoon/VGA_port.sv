
	
module VGA_port #(

	parameter C_SIZE = 8,
	parameter DBUF_OFFSET = 'h4b000,
	parameter PWIDTH = 'd480


	)(
	input logic vga_clk,
	input logic BOARD_CLK,

	input logic[9:0] VGA_SCAN_X, VGA_SCAN_Y,
	input logic doubleBuffer,
	input logic[15:0] framebufferData,
	input logic dataReady,
	output logic[19:0] framebufferAddress,
	output logic queueRead,
	
	output logic [7:0] R, G, B

);


	// Circular look-ahead pixel cache implemented with modulus on linear array
	logic[15:0] pixelCache[C_SIZE];
	
	// Pointers to various parts of the array
	logic[7:0] currentPixel;
	logic[7:0] forwardEdge;
	
	logic[7:0] edgeOffsetSigned;
	logic[7:0] edgeOffsetAbs;
	
	logic[19:0] bufferOffset;
	
	assign bufferOffset = doubleBuffer ? DBUF_OFFSET : 0;
	
	assign edgeOffsetSigned = $signed(currentPixel) - $signed(forwardEdge);
	assign edgeOffsetAbs = edgeOffsetSigned[7] ? -edgeOffsetSigned : edgeOffsetSigned;
	
	always_ff @(posedge vga_clk) begin
	
		R <= pixelCache[currentPixel][4:0] << 3;
		G <= pixelCache[currentPixel][10:5] << 2;
		B <= pixelCache[currentPixel][15:11] << 3;
	
	
		currentPixel <= (currentPixel + 1) % C_SIZE;
	
	
	end
	
	always_ff @(posedge BOARD_CLK) begin
	
		// If we still have a way to go with filling our buffer, keep requesting from RAM.
		if((forwardEdge + 1) % C_SIZE != currentPixel) begin
			forwardEdge <= (forwardEdge + 1) % C_SIZE;
			
			
			queueRead <= 1; // Schedule a new read from the memory controller
			
			if(VGA_SCAN_X + edgeOffsetAbs > PWIDTH) begin // We're flowing off the edge, lookahead buffer is beyond horizontal scan
				framebufferAddress = bufferOffset + ((VGA_SCAN_X + edgeOffsetAbs)%PWIDTH) + (PWIDTH * (VGA_SCAN_Y + 1));
			end
			else begin
				framebufferAddress = bufferOffset + (VGA_SCAN_X + edgeOffsetAbs) + (PWIDTH * VGA_SCAN_Y);
			end
		end
		else begin //We've filled the buffer totally
			queueRead <= 0; // Halt reading from the memory controller, we're stalling on VGA delay
		end
		
		if(dataReady) begin
			pixelCache[forwardEdge] <= framebufferData;
			queueRead <= 1; // unnecessary but readable
			
			
			
			
			
		end
		else begin // Else, we are waiting on memory
		
		
		
		end
		
	end


endmodule