module pixel_shader (
	input logic[17:0] SW,
	input logic rasterTileID,
	output reg[15:0] cBufferTile0 [tileDim][tileDim],
	output reg[15:0] cBufferTile1 [tileDim][tileDim],
	input reg[15:0] zBufferTile [tileDim][tileDim],
	input logic[9:0] box [4], // x,y,w,h
	input logic BOARD_CLK,
	input [3:0] start_x, start_y,
	
	input logic startRasterizing,
	output logic doneRasterizing
);

parameter tileDim = 8'd8;
parameter numPixelShaders = 8'd4;

logic nextDoneRasterizing;

logic[9:0] x_temp;
logic[9:0] y_temp;

logic [15:0] x = 0, y = 0, nextX = 0, nextY = 0;

always_ff @(posedge BOARD_CLK) begin
	if(rasterTileID == 0)
		cBufferTile0[x][y] <= x*3;
	else
		cBufferTile1[x][y] <= y*3;
	x <= nextX;
	y <= nextY;
	doneRasterizing <= nextDoneRasterizing;
end

always_comb begin
	/*
	if(x+1 >= tileDim) begin
		nextDoneRasterizing = 1;
		nextX = 0;
	end else begin
		nextDoneRasterizing = 0;
		nextX = x+1;
	end
	*/
	
	x_temp = x+numPixelShaders;
	y_temp = x_temp >= tileDim ? y + 1 : y;
	
	if(x_temp >= tileDim && y_temp >= tileDim) begin
		nextX = 0;
		nextY = 0;
		nextDoneRasterizing = 1;
	end
	else if(x_temp >= tileDim) begin
		nextX = x_temp - tileDim;
		nextY = y+1;
		nextDoneRasterizing = 0;
	end
	else begin
		nextX = x_temp;
		nextY = y_temp;
		nextDoneRasterizing = 0;
	
	end
	

end

endmodule