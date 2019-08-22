module debug_shader(
	output logic[15:0] pixel0, pixel1,
	input logic[17:0] SW,
	input logic[9:0] screenx,
	input logic BOARD_CLK,
	input logic rasterTile
);

parameter logic[9:0] x = 0;
parameter logic[9:0] y = 0;

always_ff @(posedge BOARD_CLK) begin
	
	if(rasterTile == 0)
		pixel0 <= x+y+SW+screenx;
	else
		pixel1 <= x-y-SW-screenx;
end

endmodule