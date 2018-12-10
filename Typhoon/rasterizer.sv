module rasterizer #(
	tileDim = 8'd8,
	nanoTileDim = 8'd4,
	nanoTilesSide = tileDim/nanoTileDim

	)(
	input logic[17:0] SW,
	input logic BOARD_CLK,
	input logic rasterTileID,
	input logic startRasterizing,
	input logic[9:0] rasterxOffset, rasteryOffset,
	input logic[3:0] KEY,
	output logic doneRasterizing,
	output reg[15:0] cBufferTile0 [tileDim][tileDim],
	output reg[15:0] cBufferTile1 [tileDim][tileDim],
	output logic[17:0] LEDR
);



logic nextDoneRasterizing;
logic startShadersRasterizing;
logic nextStartShadersRasterizing; // To pixel shaders
logic[(nanoTilesSide*nanoTilesSide)-1:0] shadersDoneRasterizing; // From pixel shaders
reg[15:0] zBufferTile [tileDim][tileDim];
logic[9:0] tileOffsetX, tileOffsetY;
logic[9:0] nextTileOffsetX, nextTileOffsetY;
logic[3:0] lastKey;

reg[15:0] nanoTiles0 [tileDim/nanoTileDim][tileDim/nanoTileDim][nanoTileDim][nanoTileDim]; //nanoTile location, then nanoTile pixel indices
reg[15:0] nanoTiles1 [tileDim/nanoTileDim][tileDim/nanoTileDim][nanoTileDim][nanoTileDim];

logic clearZ; // signal to pixel shaders to clear their Z nano-tiles
//assign clearZ = 1;
logic nextClearZ;
//assign clearZ = 1;

generate
genvar x;
genvar y;
for(y = 0; y<tileDim; y++) begin: tileLoopY
	for(x = 0; x<tileDim; x++) begin: tileLoopX
		int nanoX = x/nanoTileDim;
		int nanoY = y/nanoTileDim;
		assign cBufferTile0[x][y] = nanoTiles0[nanoX][nanoY][x-nanoX*nanoTileDim][y-nanoY*nanoTileDim];
		assign cBufferTile1[x][y] = nanoTiles1[nanoX][nanoY][x-nanoX*nanoTileDim][y-nanoY*nanoTileDim];
	end
end
endgenerate

generate
genvar xShader;
genvar yShader;
for(yShader = 0; yShader<nanoTilesSide; yShader++) begin: shaderLoopY
	for(xShader = 0; xShader<nanoTilesSide; xShader++) begin: shaderLoopX
		//int nanoX2 = xShader/nanoTileDim;
		//int nanoY2 = yShader/nanoTileDim;
		pixel_shader #(tileDim, nanoTileDim) shader(.start_x(xShader*nanoTileDim), .start_y(yShader*nanoTileDim),
																.startRasterizing(startShadersRasterizing),
																.doneRasterizing(shadersDoneRasterizing[xShader+nanoTilesSide*yShader]),
																.nanoTile0(nanoTiles0[xShader][yShader]),
																.nanoTile1(nanoTiles1[xShader][yShader]),
																.areaRecip(area_recip),
																.*);
	end
end
endgenerate
/*
generate
genvar i;

for(i = 0; i<numPixelShaders; i++) begin: shaderLoop
	pixel_shader #(tileDim, numPixelShaders) shader(.start_x(i), .start_y(0),
																.startRasterizing(startShadersRasterizing),
																.doneRasterizing(shadersDoneRasterizing),
																.cBufferTile0(nanoTiles0[i]),
																.cBufferTile1(nanoTiles1[i]),
																.*);
end


endgenerate
*/
																
//assign LEDR = state | (startRasterizing << 4);

// Current polygon data cache

// Bounding box
logic[9:0] box [4]; // x,y,w,h
logic[9:0] x0,y0,x1,y1,x2,y2;
logic signed [10:0] x0_sx,y0_sx,x1_sx,y1_sx,x2_sx,y2_sx;

assign x0_sx = $signed({1'b0,x0});
assign y0_sx = $signed({1'b0,y0});
assign x1_sx = $signed({1'b0,x1});
assign y1_sx = $signed({1'b0,y1});
assign x2_sx = $signed({1'b0,x2});
assign y2_sx = $signed({1'b0,y2});

logic[15:0] z0,z1,z2;

logic[9:0] debugX = 10'd50;

logic signed [23:0] area;
logic signed [23:0] quotientResult;
logic signed [23:0] area_recip;

logic [9:0] currentTriangleAddress = 1023;

assign x0 = 100;
assign y0 = 200;
assign z0 = 1;

assign x2 = 125;
assign y2 = 100;
assign z2 = 400;

assign x1 = 100 + debugX;
assign y1 = 124;
assign z1 = 800;

assign box[0] = x0 < x1
			 ? x0 < x2
				  ? x0
				  : x2
			 : x1 < x2
				  ? x1
				  : x2;

assign box[1] = y0 < y1
		 ? y0 < y2
			  ? y0
			  : y2
		 : y1 < y2
			  ? y1
			  : y2;
			  
assign box[2] = (x0 > x1
		 ? x0 > x2
			  ? x0
			  : x2
		 : x1 > x2
			  ? x1
			  : x2);
			  
assign box[3] = (y0 > y1
		 ? y0 > y2
			  ? y0
			  : y2
		 : y1 > y2
			  ? y1
			  : y2);

/*					  
assign area = (x1_sx - x0_sx)*
					(y2_sx - y0_sx) -
					(y1_sx - y0_sx)*
					(x2_sx - x0_sx);
*/				
assign area = (x2_sx - x0_sx)*(y1_sx - y0_sx) - (y2_sx - y0_sx)*(x1_sx - x0_sx);


//assign area = ({22'b0, box[2]}-{22'b0, box[0]})*({22'b0, box[3]}-{22'b0, box[1]});


assign LEDR = shadersDoneRasterizing;


logic[7:0] divideCounter = 0;
logic DIVIDE_EN = 0;
reciprocal areaDivider(.denom(area),
				.numer(32'h7FFFFF),
				.quotient(quotientResult),
				.remain(),
				.clock(BOARD_CLK),
				.clken(DIVIDE_EN));


enum logic [4:0] {
	init,
	setupBegin,
	setupLatency1,
	setupLatency2,
	setupWait,
	loadTriangle,
	recipState,
	rasterizingBegin,
	rasterizingLatency1,
	rasterizingLatency2,
	rasterizing,
	done

} state = init, nextState = init;

always_ff @(posedge BOARD_CLK) begin
	lastKey <= KEY;
	state <= nextState;
	doneRasterizing <= nextDoneRasterizing;
	
	if(KEY[0]==0 && KEY != lastKey) begin
		debugX <= debugX + 10;
	end
	else if(KEY[1]==0 && KEY != lastKey) begin
		debugX <= debugX - 10;
	end

	startShadersRasterizing <= nextStartShadersRasterizing;
	
	tileOffsetX <= nextTileOffsetX;
	tileOffsetY <= nextTileOffsetY;
	
	area_recip <= quotientResult;
	if(DIVIDE_EN)
		divideCounter <= divideCounter+1;
	else
		divideCounter <= 0;
	//doneRasterizing <= 1;
	/*
	if(rasterTileID == 0)
		cBufferTile0[0][1] <= SW;
	else
		cBufferTile1[1][1] <= SW;
	*/
	
	clearZ <= nextClearZ;
end

always_comb begin
	nextClearZ = 0;
	DIVIDE_EN = 0;
	nextTileOffsetX = tileOffsetX;
	nextTileOffsetY = tileOffsetY;
	nextDoneRasterizing = 0;
	nextStartShadersRasterizing = 0;
	case(state)
		init: begin
			nextDoneRasterizing = 0;
			nextState = startRasterizing ? setupBegin : init;
			//nextState = rasterizing;
			nextStartShadersRasterizing = 0;
			DIVIDE_EN = 0;
			nextClearZ = 1;
		end
		
		setupBegin: begin
			nextTileOffsetX = rasterxOffset;
			nextTileOffsetY = rasteryOffset;
			DIVIDE_EN = 1;
			nextStartShadersRasterizing = 1;
			nextDoneRasterizing = 0;
			nextClearZ = 1;
			nextState = setupLatency1;
		end
		setupLatency1: begin
			nextClearZ = 1;
			DIVIDE_EN = 1;
			nextState = setupLatency2;
		end
		setupLatency2: begin
			nextClearZ = 1;
			DIVIDE_EN = 1;
			nextState = setupWait;
		end
		
		setupWait: begin
			
			DIVIDE_EN = 1;
			if(divideCounter < 6 || shadersDoneRasterizing != {(nanoTilesSide*nanoTilesSide){1'b1}}) begin
				nextState = setupWait;
				nextClearZ = 1;
			end
			else begin
				nextState = rasterizingBegin;
				nextClearZ = 0;
			end
		end
		
		rasterizingBegin: begin
			nextStartShadersRasterizing = 1;
			nextDoneRasterizing = 0;
			nextState = rasterizingLatency1;
		end
		
		rasterizingLatency1: begin
			nextState = rasterizingLatency2;
		end
		rasterizingLatency2: begin
			nextState = rasterizing;
		end
		
		rasterizing: begin
			nextStartShadersRasterizing = 0;
			nextDoneRasterizing = 0;
			if(shadersDoneRasterizing != {(nanoTilesSide*nanoTilesSide){1'b1}}) begin
			
				nextState = rasterizing;
			end else begin
			
				nextState = done;
			end
		end
		
		done: begin
			nextClearZ = 1;
			nextStartShadersRasterizing = 0;
			nextDoneRasterizing = 1;
			nextState = startRasterizing ? done : init;
		end
	endcase

end


endmodule