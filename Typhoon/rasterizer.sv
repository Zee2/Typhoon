module rasterizer (
	input logic[17:0] SW,
	input logic BOARD_CLK,
	input logic rasterTileID,
	input logic startRasterizing,
	input logic[9:0] rasterxOffset, rasteryOffset,
	input logic[3:0] KEY,
	output logic doneRasterizing,
	output reg[15:0] cBufferTile0 [tileDim][tileDim],
	output reg[15:0] cBufferTile1 [tileDim][tileDim]
	//output logic[17:0] LEDR
);

parameter tileDim = 8'd8;
parameter numPixelShaders = 8'd1;


logic nextDoneRasterizing;
logic startShadersRasterizing;
logic nextStartShadersRasterizing; // To pixel shaders
logic shadersDoneRasterizing = 1; // From pixel shaders
reg[15:0] zBufferTile [tileDim][tileDim];
logic[9:0] tileOffsetX, tileOffsetY;
logic[3:0] lastKey;
pixel_shader #(tileDim, numPixelShaders) shader(.start_x(0), .start_y(0), .startRasterizing(startShadersRasterizing), .doneRasterizing(shadersDoneRasterizing), .*);
//assign LEDR = state | (startRasterizing << 4);

// Current polygon data cache

// Bounding box
logic[9:0] box [4]; // x,y,w,h
logic[9:0] x0,y0,z0,x1,y1,z1,x2,y2,z2;

logic[9:0] debugX = 10'd50;

assign x0 = 100;
assign y0 = 150;

assign x1 = 125;
assign y1 = 100;

assign x2 = box[0] + debugX;
assign y2 = 124;

assign box[0] = 100;//x
assign box[1] = 100;//y
assign box[2] = debugX;//w
assign box[3] = 50;//h


enum logic [4:0] {
	init = 5'd0,
	rasterizingBegin = 5'd1,
	rasterizing = 5'd2,
	done = 5'd3

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
	if(state==rasterizingBegin)begin
		tileOffsetX <= rasterxOffset;
		tileOffsetY <= rasteryOffset;
	end
	//doneRasterizing <= 1;
	/*
	if(rasterTileID == 0)
		cBufferTile0[0][1] <= SW;
	else
		cBufferTile1[1][1] <= SW;
	*/
end

always_comb begin
	case(state)
		init: begin
			nextDoneRasterizing = 0;
			nextState = startRasterizing ? rasterizingBegin : init;
			//nextState = rasterizing;
			nextStartShadersRasterizing = 0;
		end
		
		rasterizingBegin: begin
			nextStartShadersRasterizing = 1;
			nextDoneRasterizing = 0;
			nextState = rasterizing;
		end
		
		rasterizing: begin
			nextStartShadersRasterizing = 0;
			nextDoneRasterizing = 0;
			if(shadersDoneRasterizing == 0) begin
				nextState = rasterizing;
			end else begin
			
				nextState = done;
			end
		end
		
		done: begin
			nextStartShadersRasterizing = 0;
			nextDoneRasterizing = 1;
			nextState = startRasterizing ? done : init;
		end
	endcase

end


endmodule