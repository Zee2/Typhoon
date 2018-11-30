module rasterizer (
	input logic[17:0] SW,
	input logic BOARD_CLK,
	input logic rasterTileID,
	input logic startRasterizing,
	input logic[9:0] rasterxOffset, rasteryOffset,
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

pixel_shader #(tileDim, numPixelShaders) shader(.start_x(box[0]), .start_y(box[1]), .startRasterizing(startShadersRasterizing), .doneRasterizing(shadersDoneRasterizing), .*);
//assign LEDR = state | (startRasterizing << 4);

// Current polygon data cache

// Bounding box
logic[9:0] box [4]; // x,y,w,h
logic[9:0] x1,y1,z1,x2,y2,z2,x3,y3,z3;

assign box[0] = 100;
assign box[1] = 100;
assign box[2] = 50;
assign box[3] = 50;


enum logic [4:0] {
	init = 5'd0,
	rasterizing = 5'd1,
	done = 5'd2

} state = init, nextState = init;

always_ff @(posedge BOARD_CLK) begin
	state <= nextState;
	doneRasterizing <= nextDoneRasterizing;
	startShadersRasterizing <= nextStartShadersRasterizing;
	//doneRasterizing <= 1;
	//if(rasterTileID == 0)
		//cBufferTile0[0][1] <= SW + rasterxOffset;
	//else
		//cBufferTile1[1][1] <= SW + rasterxOffset;
end

always_comb begin
	case(state)
		init: begin
			nextDoneRasterizing = 0;
			nextState = startRasterizing ? rasterizing : init;
			//nextState = rasterizing;
			nextStartShadersRasterizing = 0;
		end
		
		rasterizing: begin
			nextStartShadersRasterizing = 1;
			nextDoneRasterizing = 0;
			if(shadersDoneRasterizing == 1) begin
				nextState = done;
			end else begin
			
				nextState = rasterizing;
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