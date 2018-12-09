module pixel_shader (
	input logic[17:0] SW,
	input logic rasterTileID,
	output reg[15:0] nanoTile0 [nanoTileDim][nanoTileDim],
	output reg[15:0] nanoTile1 [nanoTileDim][nanoTileDim],
	//input reg[15:0] zBufferTile [nanoTileDim][nanoTileDim],
	input logic[9:0] box [4], // x,y,w,h
	input logic signed [10:0] x0_sx,y0_sx,x1_sx,y1_sx,x2_sx,y2_sx, 
	input logic[15:0] z0,z1,z2,
	input logic BOARD_CLK,
	input logic[9:0] tileOffsetX, tileOffsetY, // offset of tile we are rasterizing
	input [9:0] start_x, start_y,
	input logic signed [31:0] debug,
	input logic startRasterizing,
	input logic clearZ,
	output logic doneRasterizing = 0
);

parameter tileDim = 8'd8;
parameter nanoTileDim = 8'd8;

logic[15:0] zBuffer[nanoTileDim][nanoTileDim];

logic nextDoneRasterizing;

logic[15:0] basicTestColor;

logic[9:0] x_temp;
logic[9:0] y_temp;

logic signed [31:0] line01;
logic signed [31:0] line12;
logic signed [31:0] line20;

logic signed [16:0] z0_sx;
logic signed [16:0] z1_sx;
logic signed [16:0] z2_sx;
assign z0_sx = $signed({1'b0, z0});
assign z1_sx = $signed({1'b0, z1});
assign z2_sx = $signed({1'b0, z2});

logic signed [63:0] curZ;


logic signed [15:0] trueX, trueY;

logic [9:0] x = 0, y = 0, nextX = 0, nextY = 0;


generate
	genvar xZ;
	genvar yZ;
	for(yZ = 0; yZ < nanoTileDim; yZ++) begin: zBufClearY
		for(xZ = 0; xZ < nanoTileDim; xZ++) begin: zBufClearY
			always_ff @(posedge BOARD_CLK) begin
			if(clearZ)
				zBuffer[xZ][yZ] <= 0;
			end

		end


	end

endgenerate



enum logic [4:0]{

	start,
	zcheck,
	rasterPixel,
	rasterDebug,
	chooseNextPixel,
	done

} state, nextState;

logic[9:0] myTileX, myTileY;

always_ff @(posedge BOARD_CLK) begin
/*
	if(x >= rasterxOffset && x < rasterxOffset+tileDim && y >= rasteryOffset && y < rasteryOffset+tileDim) begin
		if(rasterTileID == 0)
			nanoTile0[x-rasterxOffset][y-rasteryOffset] <= SW;
		else
			nanoTile0[x-rasterxOffset][y-rasteryOffset] <= SW;
	end
	
	*/
	if(state == rasterDebug) begin
		if(rasterTileID == 0)
			nanoTile0[x-start_x][y-start_y] <= basicTestColor;
		else
			nanoTile1[x-start_x][y-start_y] <= basicTestColor;
	end
	/*
	if(rasterTileID == 0)
		nanoTile0[x][y] <= 0;
	else
		nanoTile0[x][y] <= -1;
	*/
	state <= nextState;
	x <= nextX;
	y <= nextY;
	doneRasterizing <= nextDoneRasterizing;
	
	
	if(state==start)begin
		myTileX <= tileOffsetX;
		myTileY <= tileOffsetY;
	end
end

always_comb begin

	x_temp = x+1;
	y_temp = (x_temp >= (start_x + nanoTileDim)) ? y + 1 : y; 
	
	trueX = {1'b0, x + myTileX};
	trueY = {1'b0, y + myTileY};
	
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
	
	line01 = (trueX - x0_sx)*(y1_sx - y0_sx) - (trueY - y0_sx)*(x1_sx - x0_sx);
	line12 = (trueX - x1_sx)*(y2_sx - y1_sx) - (trueY - y1_sx)*(x2_sx - x1_sx);
	line20 = (trueX - x2_sx)*(y0_sx - y2_sx) - (trueY - y2_sx)*(x0_sx - x2_sx);
	
	//curZ = (z0 + (line20 * debug)*(z1-z0) + (line01 * debug)*(z2-z0))>>SW;
	curZ = (z0 + (line20 * debug)*(z1-z0) + (line01 * debug)*(z2-z0))>>SW;
	//curZ = (line20*debug)>>SW;
	basicTestColor = 0;
	unique case(state)
	
		start: begin
			nextState = startRasterizing ? zcheck : start;
			//nextState = chooseNextPixel;
			nextX = start_x;
			nextY = start_y;
			nextDoneRasterizing = 1;
		end
		
		
		zcheck: begin
			basicTestColor = 16'b0 | (trueX[5:0] << 5) | (trueY[4:0] << 11);
			nextDoneRasterizing = 0;
			nextX = x;
			nextY = y;
			//nextState = chooseNextPixel;
			if(trueX >= box[0] && trueX < box[2] &&
				trueY >= box[1] && trueY < box[3] &&
				line01[15] == 0 && line12[15] == 0 && line20[15] == 0) begin
					nextState = rasterDebug;
					//basicTestColor = 16'h0000 | ((curZ[23:18])<<5);
					basicTestColor = 0;
					//basicTestColor = 16'h0000 | line20[8:4];
			end
			else begin
				//basicTestColor = nanoTile0[x-start_x][y-start_y];
				nextState = rasterPixel;
			end
			
			/*
			if(trueX >= box[0] && trueX < box[0] + box[2] &&
				trueY >= box[1] && trueY < box[1] + box[3] &&
				trueX >= x1) begin
				
				basicTestColor = SW;
			end
			*/
			
		
		end
		
		rasterDebug: begin
			nextDoneRasterizing = 0;
			nextX = x;
			nextY = y;
			//basicTestColor = 16'h0000 | ((curZ[31:27])<<5);
			basicTestColor = 16'hffff;
			nextState = chooseNextPixel;
		end
		rasterPixel: begin
			nextDoneRasterizing = 0;
			nextX = x;
			nextY = y;
			//basicTestColor = 16'h0000 | ((curZ[31:27])<<5);
			basicTestColor = SW;
			nextState = chooseNextPixel;
		
		end
		
		chooseNextPixel: begin
			nextDoneRasterizing = 0;
			if(x_temp >= (start_x + nanoTileDim) && y_temp >= (start_y + nanoTileDim)) begin // Done with bounding box
				nextX = start_x;
				
				nextY = start_y;
				nextState = done;
			end	
			else if(x_temp >= (start_x + nanoTileDim)) begin
				nextX = x_temp - (start_x + nanoTileDim);
				
				nextY = y+1;
				nextState = zcheck;
			end
			else begin
				nextX = x_temp;
				nextY = y_temp;
				nextState = zcheck;
	
			end
		end
		
		done: begin
			nextDoneRasterizing = 1;
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
	
	
	/*
	if(x_temp >= (start_x + nanoTileDim) && y_temp >= (start_y + nanoTileDim)) begin
		
		nextDoneRasterizing = 1;
	end
	else if(x_temp >= tileDim) begin
		
		nextDoneRasterizing = 0;
	end
	else begin
		
		nextDoneRasterizing = 0;
	
	end
	*/

end

endmodule