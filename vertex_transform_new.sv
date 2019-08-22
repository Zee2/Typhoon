module vertex_transform_new #(
	binFactor = 7,
	screenWidth = 800,
	screenHeight = 525,
	maxInputMemoryAddress = 12'hEE5,
	binBits = 11-binFactor,
	numBinsSideX = 2**(binBits-1),
	numBinsSideY = 2**(binBits-1)
	) (

	input logic startTrigger,
	input logic[17:0] SW,
	input logic[3:0] KEY,
	output logic[17:0] LEDR,
	output logic doneBinning,
	output logic[11:0] listRegisters[numBinsSideX][numBinsSideY],
	output logic[143:0] binMemoryQ,
	input logic[11:0] binMemoryReadAddress,
	input logic BOARD_CLK

);

logic signed [10:0] framewidth = 640/2;
logic signed [10:0] frameheight = 640/2;

logic signed [10:0] momentumX;
logic signed [10:0] momentumY;

logic[3:0] lastKEY;
reg[11:0] inputMemoryAddress = 0;
logic[11:0] nextInputMemoryAddress;
logic[143:0] inputMemoryData;

logic[11:0] binMemoryAddress;
logic[11:0] nextBinMemoryAddress;
logic[143:0] binMemoryData;
logic binMemoryWREN;




logic[7:0] divCounter = 0;
logic[7:0] nextDivCounter;

logic zdiv_en;
logic signed [16:0] zdiv_result [3]; // Reciprocals of all z depth values of each vertex;

logic signed [10:0] cameraX = 320, cameraY = 240;

logic signed [10:0] x0,y0,x1,y1,x2,y2;
logic signed [7:0] n0,n1,n2;
logic [15:0] z0,z1,z2;
logic signed [16:0] z0_sx,z1_sx,z2_sx;

logic signed [10:0] x0_out,y0_out,x1_out,y1_out,x2_out,y2_out;

logic signed [10:0] box[4];
logic[binBits-1:0] minXbin;
logic[binBits-1:0] minYbin;
logic[binBits-1:0] maxXbin;
logic[binBits-1:0] maxYbin;

assign minXbin = ({(binBits){1'b0}} | (box[0] >> binFactor));
assign minYbin = ({(binBits){1'b0}} | (box[1] >> binFactor));
assign maxXbin = ({(binBits){1'b0}} | (box[2] >> binFactor));
assign maxYbin = ({(binBits){1'b0}} | (box[3] >> binFactor));

logic[binBits-1:0] curBinX;
logic[binBits-1:0] curBinY;
logic[binBits-1:0] nextBinX;
logic[binBits-1:0] nextBinY;

assign LEDR = x0_out;

assign box[0] = x0_out < x1_out
			 ? x0_out < x2_out
				  ? x0_out
				  : x2_out
			 : x1_out < x2_out
				  ? x1_out
				  : x2_out;

assign box[1] = y0_out < y1_out
		 ? y0_out < y2_out
			  ? y0_out
			  : y2_out
		 : y1_out < y2_out
			  ? y1_out
			  : y2_out;
			  
assign box[2] = (x0_out > x1_out
		 ? ( x0_out > x2_out
			  ? x0_out
			  : x2_out )
		 : ( x1_out > x2_out
			  ? x1_out
			  : x2_out ));
			  
assign box[3] = (y0_out > y1_out
		 ? ( y0_out > y2_out
			  ? y0_out
			  : y2_out )
		 : ( y1_out > y2_out
			  ? y1_out
			  : y2_out ));

assign x0 = $signed({1'b0,inputMemoryData[9:0]}) - cameraX;
assign y0 = $signed({1'b0,inputMemoryData[19:10]}) - cameraY;
assign z0 = inputMemoryData[35:20] + SW[17:10];

assign x1 = $signed({1'b0,inputMemoryData[45:36]}) - cameraX;
assign y1 = $signed({1'b0,inputMemoryData[55:46]}) - cameraY;
assign z1 = inputMemoryData[71:56] + SW[17:10];

assign x2 = $signed({1'b0,inputMemoryData[81:72]}) - cameraX;
assign y2 = $signed({1'b0,inputMemoryData[91:82]}) - cameraY;
assign z2 = inputMemoryData[107:92] + SW[17:10];

assign z0_sx = $signed({1'b0,z0});
assign z1_sx = $signed({1'b0,z1});
assign z2_sx = $signed({1'b0,z2});

assign n0 = inputMemoryData[115:108];
assign n1 = inputMemoryData[123:116];
assign n2 = inputMemoryData[131:124];
/*
assign x0_out = (((x0 * zdiv_result[0])*framewidth) >>> 16) + $signed({22'b0,cameraX});
assign x1_out = (((x1 * zdiv_result[1])*framewidth) >>> 16) + $signed({22'b0,cameraX});
assign x2_out = (((x2 * zdiv_result[2])*framewidth) >>> 16) + $signed({22'b0,cameraX});

//zdiv_result has 16 decimal bits
assign y0_out = (((y0 * zdiv_result[0])*frameheight) >>> 16) + $signed({22'b0,cameraY});
assign y1_out = (((y1 * zdiv_result[1])*frameheight) >>> 16) + $signed({22'b0,cameraY});
assign y2_out = (((y2 * zdiv_result[2])*frameheight) >>> 16) + $signed({22'b0,cameraY});
*/
assign binMemoryData[9:0] = x0_out[9:0];
assign binMemoryData[19:10] = y0_out[9:0];
assign binMemoryData[35:20] = z0;
assign binMemoryData[45:36] = x1_out[9:0];
assign binMemoryData[55:46] = y1_out[9:0];
assign binMemoryData[71:56] = z1;
assign binMemoryData[81:72] = x2_out[9:0];
assign binMemoryData[91:82] = y2_out[9:0];
assign binMemoryData[107:92] = z2;

assign binMemoryData[115:108] = n0;
assign binMemoryData[123:116] = n1;
assign binMemoryData[131:124] = n2;

assign binMemoryData[143:132] = listRegisters[curBinX][curBinY];

vertex_memory_input inputGeometry(
	.clock(BOARD_CLK),
	.data(0),
	.rdaddress(inputMemoryAddress),
	.wraddress(0),
	.wren(0),
	.q(inputMemoryData)
);

vertex_memory_bins binnedGeometry(
	.clock(BOARD_CLK),
	.data(binMemoryData),
	.rdaddress(binMemoryReadAddress),
	.wraddress(binMemoryAddress),
	.wren(binMemoryWREN),
	.q(binMemoryQ)

);

perspective_divide z0div(
	.clock(BOARD_CLK),
	.clken(zdiv_en),
	.numer({1'b0,-16'b1}),
	.denom(z0_sx),
	.quotient(zdiv_result[0]),
	.remain()

);
perspective_divide z1div(
	.clock(BOARD_CLK),
	.clken(zdiv_en),
	.numer({1'b0,-16'b1}),
	.denom(z1_sx),
	.quotient(zdiv_result[1]),
	.remain()

);
perspective_divide z2div(
	.clock(BOARD_CLK),
	.clken(zdiv_en),
	.numer({1'b0,-16'b1}),
	.denom(z2_sx),
	.quotient(zdiv_result[2]),
	.remain()

);


enum logic[7:0]{
	start_state,
	adjust_state,
	start_new_tri,
	div_state,
	project_state,
	choose_bin,
	write_bin,
	end_bin

} state = start_state, nextState = start_state;

always_ff @(posedge BOARD_CLK) begin

	state <= nextState;
	divCounter <= nextDivCounter;
	lastKEY <= KEY;
	
	if(state == adjust_state) begin
		cameraX <= cameraX + momentumX;
		cameraY <= cameraY + momentumY;
		
		if(KEY[0] == 0) begin
			momentumX <= momentumX + 1;
		end
		else if(KEY[1] == 0) begin
			momentumX <= momentumX - 1;
		end
		else begin
			if(momentumX > 0)
				momentumX <= momentumX - 1;
			else if(momentumX < 0)
				momentumX <= momentumX + 1;
		end
		
		if(KEY[2] == 0) begin
			momentumY <= momentumY + 1;
		end
		else
		if(KEY[3] == 0) begin
			momentumY <= momentumY - 1;
		end
		else begin
			if(momentumY > 0)
				momentumY <= momentumY - 1;
			else if(momentumY < 0)
				momentumY <= momentumY + 1;
		end
	end
	
	
	if(state == adjust_state) begin
		for(int x = 0; x < numBinsSideX; x++) begin
			for(int y = 0; y < numBinsSideY; y++) begin
				listRegisters[x][y] <= 12'b0;
			end
		end
		
	end
	
	if(state == write_bin) begin
		listRegisters[curBinX][curBinY] <= binMemoryAddress;
	end
	
	binMemoryAddress <= nextBinMemoryAddress;
	inputMemoryAddress <= nextInputMemoryAddress;
	curBinX <= nextBinX;
	curBinY <= nextBinY;
	if(nextState == project_state) begin
		x0_out <= (((x0 * zdiv_result[0])*framewidth) >>> 16) + $signed({22'b0,cameraX});
		x1_out <= (((x1 * zdiv_result[1])*framewidth) >>> 16) + $signed({22'b0,cameraX});
		x2_out <= (((x2 * zdiv_result[2])*framewidth) >>> 16) + $signed({22'b0,cameraX});

		//zdiv_result has 16 decimal bits
		y0_out <= (((y0 * zdiv_result[0])*frameheight) >>> 16) + $signed({22'b0,cameraY});
		y1_out <= (((y1 * zdiv_result[1])*frameheight) >>> 16) + $signed({22'b0,cameraY});
		y2_out <= (((y2 * zdiv_result[2])*frameheight) >>> 16) + $signed({22'b0,cameraY});
	end
	
end

always_comb begin

	doneBinning = 0;
	zdiv_en = 0;
	nextDivCounter = divCounter;
	binMemoryWREN = 0;
	
	nextBinX = curBinX;
	nextBinY = curBinY;
	
	nextInputMemoryAddress = inputMemoryAddress;
	nextBinMemoryAddress = binMemoryAddress;
	
	unique case(state)
	
		start_state: begin
			nextBinMemoryAddress = 1;
			nextInputMemoryAddress =1;
			if(startTrigger) begin
				nextState = adjust_state;
			end
			else begin
				nextState = start_state;
				doneBinning = 1;
			end
		end
		adjust_state: begin
			nextState = start_new_tri;
		end
		start_new_tri: begin
			
			nextState = div_state;
		end
		
		div_state: begin
			zdiv_en = 1;
			nextDivCounter = divCounter+1;
			if(divCounter < 5) begin
				 nextState = div_state;			
			end
			else begin
				nextState = project_state;
			end
			
			if(inputMemoryData == 144'b0) begin
				nextDivCounter = 0;
				nextState = start_state;
			end
		end
		
		project_state: begin
			nextDivCounter = 0;
			if(box[0] < 0 || box[1] < 0 || box[2] < 0 || box[3] < 0) begin // Clip out-of-screen triangles (todo: make this not sketchy)
				nextInputMemoryAddress = inputMemoryAddress + 1;
				nextState = end_bin;
			end
			else
				nextState = choose_bin;
		end
		
		choose_bin: begin
			nextBinX = minXbin;
			nextBinY = minYbin;
			nextState = write_bin;
		end
		
		write_bin: begin
			binMemoryWREN = 1; // writes contents of curBin
			nextBinMemoryAddress = binMemoryAddress + 1; // Increment bin pointer
			binMemoryWREN = 1;
			if((curBinX == maxXbin && curBinY == maxYbin) || binMemoryAddress + 1 == 0) begin // Done with all bins for this triangle
				nextBinX = -1;
				nextBinY = -1;
				nextState = end_bin;
				
				nextInputMemoryAddress = inputMemoryAddress + 1; // Increment world geo pointer
			end
			else
			if(curBinX == maxXbin) begin
				nextBinX = minXbin;
				nextBinY = curBinY+1;
				nextState = write_bin;
			end
			else begin
				nextBinX = curBinX + 1;
				nextBinY = curBinY;
				nextState = write_bin;
			end
		end
		
		end_bin: begin
			
			if(inputMemoryAddress == maxInputMemoryAddress || binMemoryAddress == 0)
				nextState = start_state;
			else
				nextState = start_new_tri;
		end
		
		default: begin
			nextState = start_state;
		end
		
		
		
	
	endcase

end


endmodule