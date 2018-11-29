
	
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

	
	always_ff @(posedge vga_clk) begin
		//R <= ((VGA_SCAN_Y % 16 < 8) && (VGA_SCAN_X %16 < 8)) ? -1 : 0;
		//G <= 0;
		//B <= 0;
		R <= framebufferData[4:0] << 3;
		G <= framebufferData[10:5] << 2;
		B <= framebufferData[15:11] << 3;
		framebufferAddress <= VGA_SCAN_X + 800 * VGA_SCAN_Y;
		
	end
	
	always_ff @(posedge BOARD_CLK) begin
	
		queueRead <= ~queueRead;
	end
	
		


endmodule