module rasterizer #(
	tileDim = 8'd4,
	binFactor = 6,
	nanoTileDim = 8'd4,
	nanoTilesSide = tileDim/nanoTileDim,
	binBits = 11-binFactor,
	numBinsSideX = 2**(binBits-1),
	numBinsSideY = 2**(binBits-1)
	)(
	input logic[17:0] SW,
	input logic BOARD_CLK,
	input logic rasterTileID,
	input logic startRasterizing,
	input logic[9:0] rasterxOffset, rasteryOffset,
	input logic[3:0] KEY,
	input logic[11:0] linkedListHeadPointers[numBinsSideX][numBinsSideY],
	
	input logic[143:0] binMemoryQ,
	output logic[11:0] binMemoryReadAddress,
	
	output logic doneRasterizing,
	output reg[15:0] cBufferTile0 [tileDim][tileDim],
	output reg[15:0] cBufferTile1 [tileDim][tileDim]
	//output logic[17:0] LEDR
);


logic[11:0] nextBinMemoryReadAddress;

logic[11:0] nextPointer;





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
logic [9:0] box [4]; // x,y,w,h
logic[9:0] x0,y0,x1,y1,x2,y2;
logic signed [10:0] x0_sx,y0_sx,x1_sx,y1_sx,x2_sx,y2_sx;
logic [7:0] n0_sx, n1_sx, n2_sx;
assign x0_sx = $signed({1'b0,x0});
assign y0_sx = $signed({1'b0,y0});
assign x1_sx = $signed({1'b0,x1});
assign y1_sx = $signed({1'b0,y1});
assign x2_sx = $signed({1'b0,x2});
assign y2_sx = $signed({1'b0,y2});

logic[15:0] z0,z1,z2;

logic[9:0] debugX = 10'd50;

logic signed [18:0] area;
logic signed [18:0] quotientResult;
logic signed [18:0] area_recip;



assign x0 = binMemoryQ[9:0];
assign y0 = binMemoryQ[19:10];
assign z0 = binMemoryQ[35:20];
assign x1 = binMemoryQ[45:36];
assign y1 = binMemoryQ[55:46];
assign z1 = binMemoryQ[71:56];
assign x2 = binMemoryQ[81:72];
assign y2 = binMemoryQ[91:82];
assign z2 = binMemoryQ[107:92];

assign n0_sx = binMemoryQ[115:108];
assign n1_sx = binMemoryQ[123:116];
assign n2_sx = binMemoryQ[131:124];

assign nextPointer = binMemoryQ[143:132];

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
		 ? ( x0 > x2
			  ? x0
			  : x2 )
		 : ( x1 > x2
			  ? x1
			  : x2 ));
			  
assign box[3] = (y0 > y1
		 ? ( y0 > y2
			  ? y0
			  : y2 )
		 : ( y1 > y2
			  ? y1
			  : y2 ));

/*					  
assign area = (x1_sx - x0_sx)*
					(y2_sx - y0_sx) -
					(y1_sx - y0_sx)*
					(x2_sx - x0_sx);
*/				
assign area = (x2_sx - x0_sx)*(y1_sx - y0_sx) - (y2_sx - y0_sx)*(x1_sx - x0_sx);


//assign area = ({22'b0, box[2]}-{22'b0, box[0]})*({22'b0, box[3]}-{22'b0, box[1]});





logic[7:0] divideCounter = 0;
logic DIVIDE_EN = 0;
reciprocal areaDivider(.denom(area),
				.numer({1'b0,-18'd1}),
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
	triangleLoad,
	recipState,
	rasterizingBegin,
	rasterizingLatency1,
	rasterizingLatency2,
	rasterizing,
	singleRasterComplete,
	done

} state = init, nextState = init;

//assign LEDR = state;

always_ff @(posedge BOARD_CLK) begin
	lastKey <= KEY;
	state <= nextState;
	doneRasterizing <= nextDoneRasterizing;
	binMemoryReadAddress <= nextBinMemoryReadAddress;
	
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
	
	
	if(state == recipState || setupWait) begin
		/*
		x0 <= geometry_data_out[9:0];
		y0 <= geometry_data_out[19:10];
		z0 <= geometry_data_out[35:20];
		x1 <= geometry_data_out[45:36];
		y1 <= geometry_data_out[55:46];
		z1 <= geometry_data_out[71:56];
		x2 <= geometry_data_out[81:72];
		y2 <= geometry_data_out[91:82];
		z2 <= geometry_data_out[107:92];
		
		n0_sx <= geometry_data_out[115:108];
		n1_sx <= geometry_data_out[123:116];
		n2_sx <= geometry_data_out[131:124];
		*/
		/*
		box[0] <= x0 < x1
			 ? x0 < x2
				  ? x0
				  : x2
			 : x1 < x2
				  ? x1
				  : x2;

		box[1] <= y0 < y1
				 ? y0 < y2
					  ? y0
					  : y2
				 : y1 < y2
					  ? y1
					  : y2;
					  
		box[2] <= (x0 > x1
				 ? ( x0 > x2
					  ? x0
					  : x2 )
				 : ( x1 > x2
					  ? x1
					  : x2 ));
					  
		box[3] <= (y0 > y1
				 ? ( y0 > y2
					  ? y0
					  : y2 )
				 : ( y1 > y2
					  ? y1
					  : y2 ));
		*/
	
	end
	
	clearZ <= nextClearZ;
end

always_comb begin
	nextClearZ = 0;
	DIVIDE_EN = 0;
	nextTileOffsetX = tileOffsetX;
	nextTileOffsetY = tileOffsetY;
	nextDoneRasterizing = 0;
	nextStartShadersRasterizing = 0;
	nextBinMemoryReadAddress = binMemoryReadAddress;
	unique case(state)
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
			nextStartShadersRasterizing = 1;
			nextDoneRasterizing = 0;
			nextClearZ = 1;
			nextState = setupLatency1;
			nextBinMemoryReadAddress = linkedListHeadPointers[rasterxOffset >> binFactor][rasteryOffset >> binFactor];
		end
		setupLatency1: begin
			nextClearZ = 1;
			nextState = setupLatency2;
		end
		setupLatency2: begin
			nextClearZ = 1;
			nextState = setupWait;
		end
		
		setupWait: begin
			
			if(shadersDoneRasterizing != {(nanoTilesSide*nanoTilesSide){1'b1}}) begin
				nextState = setupWait;
				nextClearZ = 1;
			end
			else begin
				nextState = triangleLoad;
				nextClearZ = 0;
			end
		end
		
		triangleLoad: begin
			if(binMemoryReadAddress == 0)
				nextState = done;
			else
				nextState = recipState;
			
		end
		
		recipState: begin
			if((box[2] < tileOffsetX) || (box[3] < tileOffsetY) || (box[0] > tileOffsetX + tileDim) || (box[1] > tileOffsetY + tileDim)) begin
				nextBinMemoryReadAddress = nextPointer;
				if(nextPointer == 0)
					nextState = done;
				else
					nextState = triangleLoad;
			end
			else begin
				DIVIDE_EN = 1;
				if(divideCounter < 7) begin
					nextState = recipState;
				end
				else begin
					nextStartShadersRasterizing = 1;
					nextState = rasterizingBegin;
				end
			end
		end
		
		rasterizingBegin: begin
			nextDoneRasterizing = 0;
			nextState = rasterizingLatency2;
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
			
				nextState = singleRasterComplete;
			end
		end
		
		singleRasterComplete: begin
			nextBinMemoryReadAddress = nextPointer;
			if(nextPointer == 0)
				nextState = done;
			else
				nextState = triangleLoad;
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