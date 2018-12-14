module pixel_shader #(
	tileDim = 8'd8,
	nanoTileDim = 8'd8
	)(
	input logic[17:0] SW,
	input logic[3:0] KEY,
	input logic rasterTileID,
	output reg[15:0] nanoTile0 [nanoTileDim][nanoTileDim],
	output reg[15:0] nanoTile1 [nanoTileDim][nanoTileDim],
	//input reg[15:0] zBufferTile [nanoTileDim][nanoTileDim],
	input logic[9:0] box [4], // x,y,w,h
	input logic signed [10:0] x0_sx,y0_sx,x1_sx,y1_sx,x2_sx,y2_sx, 
	input logic [7:0] n0_sx,n1_sx,n2_sx,
	input logic[15:0] z0,z1,z2,
	input logic BOARD_CLK,
	input logic[9:0] tileOffsetX, tileOffsetY, // offset of tile we are rasterizing
	input [9:0] start_x, start_y,
	input logic signed [18:0] areaRecip,
	input logic startRasterizing,
	input logic clearZ,
	output logic doneRasterizing = 0
);

logic[15:0] zBuffer[nanoTileDim][nanoTileDim];

logic nextDoneRasterizing;
logic nextDoneSetup;
logic[15:0] basicTestColor;

logic[9:0] x_temp;
logic[9:0] y_temp;

logic signed [16:0] line01;
logic signed [16:0] line12;
logic signed [16:0] line20;

logic signed [31:0] line20div;
logic signed [31:0] line01div;

logic signed [16:0] z0_sx;
logic signed [16:0] z1_sx;
logic signed [16:0] z2_sx;
logic signed [16:0] z10_sx;
assign z10_sx = z1_sx-z0_sx;
logic signed [16:0] z20_sx;
assign z20_sx = z2_sx-z0_sx;
assign z0_sx = $signed({1'b0, z0});
assign z1_sx = $signed({1'b0, z1});
assign z2_sx = $signed({1'b0, z2});

logic signed [63:0] curZ;

logic signed [15:0] trueX, trueY;

logic [9:0] x = 0, y = 0, nextX = 0, nextY = 0;
/*
logic signed [48:0] line20zmultResult;
logic signed [48:0] line01zmultResult;

zmult_32 line20zmult(
	.dataa(line20div),
	.datab(z10_sx),
	.result(line20zmultResult)
);
zmult_32 line01zmult(
	.dataa(line01div),
	.datab(z20_sx),
	.result(line01zmultResult)
);
*/
/*
generate
	genvar xZ;
	genvar yZ;
	for(yZ = 0; yZ < nanoTileDim; yZ++) begin: zBufClearY
		for(xZ = 0; xZ < nanoTileDim; xZ++) begin: zBufClearY
			always_ff @(posedge BOARD_CLK) begin
			if(clearZ)
				zBuffer[xZ][yZ] <= 0;
			//if(clearP == 1'b1)
				//nanoTile0[xZ][yZ] <= 16'b1111100000011111;
			end
		end


	end
	

endgenerate
*/


enum logic [4:0]{

	start,
	interpolateState1,
	interpolateState2,
	interpolateState3,
	resetBuffers,
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
	/*
	if(clearP == 1'b1) begin
		for(int i = 0; i < nanoTileDim; i++) begin
			nanoTile0[i] <= '{nanoTileDim{16'h000f}};
			nanoTile1[i] <= '{nanoTileDim{16'h000f}};
		end
		
		
	end
	*//*
	if(isClearingTiles && state == zcheck) begin
		if(rasterTileID == 0)
			nanoTile0[x-start_x][y-start_y] <= 16'hF81F;
		else
			nanoTile1[x-start_x][y-start_y] <= 16'hF81F;
	
	end
	else
	*/
	/*
	
	*/
	
	if(state == resetBuffers && clearZ == 1'b1) begin
		zBuffer[x-start_x][y-start_y] <= 16'hffff;
		if(rasterTileID == 0)
			//nanoTile0[x-start_x][y-start_y] <= 16'b0 | (trueX[5:0] << 5) | (trueY[4:0] << 11);
			nanoTile0[x-start_x][y-start_y] <= 16'b0 | (trueY[9:5] << 11);
		else
			nanoTile1[x-start_x][y-start_y] <= 16'b0 | (trueY[9:5] << 11);
	end
	
	if(state == rasterPixel && clearZ == 1'b0) begin
		zBuffer[x-start_x][y-start_y] <= curZ[15:0];
		if(rasterTileID == 0)
			
			nanoTile0[x-start_x][y-start_y] <= basicTestColor;
		else
			nanoTile1[x-start_x][y-start_y] <= basicTestColor;
	end
	/*
	if(state == rasterDebug && clearZ == 1'b0) begin
		if(rasterTileID == 0) begin
			if(trueX == box[0] || trueX == box[2] || trueY == box[1] || trueY == box[3])
				nanoTile0[x-start_x][y-start_y] <= -1;
		end
		else begin
			if(trueX == box[0] || trueX == box[2] || trueY == box[1] || trueY == box[3])
				nanoTile1[x-start_x][y-start_y] <= -1;
		end
	end
	*/
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
	
	if(state == interpolateState1) begin
		line01 <= (trueX - x0_sx)*(y1_sx - y0_sx) - (trueY - y0_sx)*(x1_sx - x0_sx);
		line12 <= (trueX - x1_sx)*(y2_sx - y1_sx) - (trueY - y1_sx)*(x2_sx - x1_sx);
		line20 <= (trueX - x2_sx)*(y0_sx - y2_sx) - (trueY - y2_sx)*(x0_sx - x2_sx);
	end
	if(state == interpolateState2) begin
		//line20div <= line20 * areaRecip;
		//line01div <= line01 * areaRecip;
		curZ <= (z0_sx + (((line01 * areaRecip) * z20_sx) >>>18) + (((line20 * areaRecip) * z10_sx)>>>18));
	end
	if(state == interpolateState3) begin
		
		//curZ <= (z0_sx + (line01zmultResult>>>23) + (line20zmultResult>>>23));
		//curZ <= (z0_sx);
	end
	
	
end

always_comb begin
	nextDoneSetup = 0;
	

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
	
	//line01 = (trueX - x0_sx)*(y1_sx - y0_sx) - (trueY - y0_sx)*(x1_sx - x0_sx);
	//line12 = (trueX - x1_sx)*(y2_sx - y1_sx) - (trueY - y1_sx)*(x2_sx - x1_sx);
	//line20 = (trueX - x2_sx)*(y0_sx - y2_sx) - (trueY - y2_sx)*(x0_sx - x2_sx);
	
	//curZ = (z0 + (line20 * debug)*(z1-z0) + (line01 * debug)*(z2-z0))>>SW;
	
	//curZ = (line20*debug)>>SW;
	basicTestColor = 0;
	unique case(state)
	
		start: begin
			nextState = start;
			if(startRasterizing) begin
				if(clearZ) begin
					nextState = resetBuffers;
				end
				else begin
					nextState = interpolateState1;
				end
			end
			
			//nextState = chooseNextPixel;
			nextX = start_x;
			nextY = start_y;
			nextDoneRasterizing = ~startRasterizing;
			nextDoneSetup = 1;
		end
		
		resetBuffers: begin // Sort of a "fake" zcheck that doesn't wait for interpolation pipelining (not needed for resetting tiles)
			nextState = chooseNextPixel;
			nextDoneRasterizing = 0;
			nextX = x;
			nextY = y;
		end
		
		interpolateState1: begin
			nextDoneRasterizing = 0;
			nextState = interpolateState2;
			nextX = x;
			nextY = y;
		end
		interpolateState2: begin
			nextDoneRasterizing = 0;
			nextState = zcheck;
			nextX = x;
			nextY = y;
		end
		interpolateState3: begin // This interp state has been optimized out! Woohoo
			nextDoneRasterizing = 0;
			nextState = zcheck;
			nextX = x;
			nextY = y;
		end
		
		zcheck: begin
			basicTestColor = 16'b0 | (trueX[5:0] << 5) | (trueY[4:0] << 11);
			nextDoneRasterizing = 0;
			nextX = x;
			nextY = y;
			//nextState = chooseNextPixel;
			if(trueX >= box[0] && trueX < box[2] &&
				trueY >= box[1] && trueY < box[3] &&
				line01[16] == 0 && line12[16] == 0 && line20[16] == 0) begin
					//nextState = rasterPixel;
					
					if(curZ[15:0] < zBuffer[x-start_x][y-start_y]) begin
						nextState = rasterPixel;
					end
					else begin
						nextState = chooseNextPixel;
					end
					
					//nextState = rasterPixel;
					//basicTestColor = 16'b0 | (trueX[0] << 4);
					//basicTestColor = 16'h0000 | ((curZ[23:18])<<5);
					//basicTestColor = 0;
					//basicTestColor = 16'h0000 | line20[8:4];
			end
			else begin
				//basicTestColor = nanoTile0[x-start_x][y-start_y];
				nextState = rasterDebug;
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
			//basicTestColor = 16'b0 | (trueX[5:0] << 5) | (trueY[4:0] << 11);
			basicTestColor = 16'b0;
			nextState = chooseNextPixel;
		end
		rasterPixel: begin
			nextDoneRasterizing = 0;
			nextX = x;
			nextY = y;
			//basicTestColor = 16'h0000 | ((curZ[31:27])<<5);
			//basicTestColor = 16'b0 | (trueX[5:0] << 5) | (trueY[4:0] << 11);
			//basicTestColor = 16'h0000 | (curZ[15:10]<<5);
			//basicTestColor = 16'h0000 | (KEY[1] ? (curZ[8:3]<<5) : (((line01zmultResult>>>SW) & 9'b11111100)<<5));
			unique case(SW[2:0])
				3'b000: begin
					basicTestColor = 16'h0000 | ((5'b11111 << 11) | (6'd35 << 5) | (n0_sx[7:3]));
				end
				
				3'b010: begin
					basicTestColor = 16'h0000 | ((x == 0 || y == 0) ? -1 : (curZ[9:4]<<5));
					
				end
				
				3'b011: begin
					basicTestColor = 16'h0000 | ((x == start_x || y == start_y || x == 0 || y == 0) ? -1 : (curZ[9:4]<<5));
				end
				
				3'b100: begin
					basicTestColor = 16'h0000 | ((curZ[9:4]<<5));
				end
				
				3'b101: begin
					basicTestColor = 16'h0000 | ((n0_sx[7:3] << 11) | (n1_sx[7:2] << 5) | (n2_sx[7:3]));
				end
				
				default: begin
					basicTestColor = 16'h0000 | (trueX[5:0] << 5) | (trueY[4:0] << 11);
				end
			
			endcase
			//basicTestColor = 16'h0000 | (SW[0] ? ((n0_sx[7:3] << 11) | (n1_sx[7:2] << 5) | (n2_sx[7:3])) : (SW[1] ? (curZ[9:4]<<5)));
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
				nextX = x_temp - nanoTileDim;
				
				nextY = y+1;
				nextState = clearZ ? resetBuffers : interpolateState1;
			end
			else begin
				nextX = x_temp;
				nextY = y_temp;
				nextState = clearZ ? resetBuffers : interpolateState1;
	
			end
		end
		
		done: begin
			nextDoneRasterizing = 1;
			//if(isClearingTiles)
			nextDoneSetup = 1;
			nextState = startRasterizing ? done : start;
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