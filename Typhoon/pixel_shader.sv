module pixel_shader (
	input logic[17:0] SW,
	input logic rasterTileID,
	output reg[15:0] cBufferTile0 [tileDim][tileDim],
	output reg[15:0] cBufferTile1 [tileDim][tileDim],
	input reg[15:0] zBufferTile [tileDim][tileDim],
	input logic[9:0] box [4], // x,y,w,h
	input logic[9:0] x0,y0,z0,x1,y1,z1,x2,y2,z2, 
	input logic BOARD_CLK,
	input logic[9:0] tileOffsetX, tileOffsetY, // offset of tile we are rasterizing
	input [9:0] start_x, start_y,
	
	input logic startRasterizing,
	output logic doneRasterizing = 0
);

parameter tileDim = 8'd8;
parameter numPixelShaders = 8'd4;

logic nextDoneRasterizing;

logic[15:0] basicTestColor;

logic[9:0] x_temp;
logic[9:0] y_temp;

logic[17:0] line01;
logic[17:0] line12;
logic[17:0] line20;


logic[17:0] trueX, trueY;

logic [9:0] x = 0, y = 0, nextX = 0, nextY = 0;


enum logic [4:0]{

	start,
	rasterPixel,
	chooseNextPixel,
	done

} state, nextState;

always_ff @(posedge BOARD_CLK) begin
/*
	if(x >= rasterxOffset && x < rasterxOffset+tileDim && y >= rasteryOffset && y < rasteryOffset+tileDim) begin
		if(rasterTileID == 0)
			cBufferTile0[x-rasterxOffset][y-rasteryOffset] <= SW;
		else
			cBufferTile1[x-rasterxOffset][y-rasteryOffset] <= SW;
	end
	
	*/
	if(state == rasterPixel) begin
		if(rasterTileID == 0)
			cBufferTile0[x][y] <= basicTestColor;
		else
			cBufferTile1[x][y] <= basicTestColor;
	end
	/*
	if(rasterTileID == 0)
		cBufferTile0[x][y] <= 0;
	else
		cBufferTile1[x][y] <= -1;
	*/
	state <= nextState;
	x <= nextX;
	y <= nextY;
	doneRasterizing <= nextDoneRasterizing;
end

always_comb begin

	x_temp = x+1;
	y_temp = x_temp >= tileDim ? y + 1 : y; 
	
	trueX = {8'b0, x + tileOffsetX};
	trueY = {8'b0, y + tileOffsetY};
	
	//nextX = x+1;
	/*
	if(x+1 >= tileDim) begin
		nextDoneRasterizing = 1;
		nextX = 0;
	end else begin
		nextDoneRasterizing = 0;
		nextX = x+1;
	end
	*/
	/*
	x_temp = x+numPixelShaders;
	if(x_temp >= box[2] || x_temp >= rasterxOffset + tileDim) begin
		y_temp = y+1;
	end
	else begin
		y_temp = y;
	end
	*/
	
	line01 = ((trueX - {8'b0, x0})*({8'b0, y1}-{8'b0, y0}) - (trueY - {8'b0, y0})*({8'b0, x1}-{8'b0, x0}));
	line12 = ((trueX - {8'b0, x1})*({8'b0, y2}-{8'b0, y1}) - (trueY - {8'b0, y1})*({8'b0, x2}-{8'b0, x1}));
	line20 = ((trueX - {8'b0, x2})*({8'b0, y0}-{8'b0, y2}) - (trueY - {8'b0, y2})*({8'b0, x0}-{8'b0, x2}));
	
	basicTestColor = 16'b0 | (trueX[5:0] << 5) | (trueY[4:0] << 11);
	unique case(state)
	
		start: begin
			nextState = startRasterizing ? rasterPixel : start;
			//nextState = chooseNextPixel;
			nextX = start_x;
			nextY = start_y;
			nextDoneRasterizing = 0;
		end
		
		rasterPixel: begin
			nextX = x;
			nextY = y;
			
			if(trueX >= box[0] && trueX < box[0] + box[2] &&
				trueY >= box[1] && trueY < box[1] + box[3] &&
				line01[17] == 1 && line12[17] == 1 && line20[17] == 1) begin
				
				basicTestColor = SW;
			end
			
			/*
			if(trueX >= box[0] && trueX < box[0] + box[2] &&
				trueY >= box[1] && trueY < box[1] + box[3] &&
				trueX >= x1) begin
				
				basicTestColor = SW;
			end
			*/
			nextState = chooseNextPixel;
		
		end
		
		chooseNextPixel: begin
			//nextDoneRasterizing = 0;
			if(x_temp >= tileDim && y_temp >= tileDim) begin // Done with bounding box
				nextX = start_x;
				
				nextY = start_y;
				nextState = done;
			end	
			else if(x_temp >= tileDim) begin
				nextX = x_temp - tileDim;
				
				nextY = y+1;
				nextState = rasterPixel;
			end
			else begin
				nextX = x_temp;
				nextY = y_temp;
				nextState = rasterPixel;
	
			end
		end
		
		done: begin
			//nextDoneRasterizing = 1;
			nextState = start;
			nextX = start_x;
			nextY = start_y;
		end
		
		default: begin
			//nextDoneRasterizing = 0;
			nextX = 5;
			nextY = 5;
			nextState = start;
		end
	
	endcase
	
	
	
	if(x_temp >= tileDim && y_temp >= tileDim) begin
		
		nextDoneRasterizing = 1;
	end
	else if(x_temp >= tileDim) begin
		
		nextDoneRasterizing = 0;
	end
	else begin
		
		nextDoneRasterizing = 0;
	
	end
	

end

endmodule