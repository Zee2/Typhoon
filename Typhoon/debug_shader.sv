module debug_shader(
	output logic[15:0] pixel0, pixel1,
	input logic[9:0] x,
	input logic BOARD_CLK,
	input logic rasterTile
);

always_ff @(posedge BOARD_CLK) begin
	
	if(rasterTile == 0)
		pixel0 <= x;
	else
		pixel1 <= 0;
end

endmodule