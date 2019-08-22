/*

WORLD MEMORY: 3x vertex_memory
2^14 words, all sequential data

one word:
21 bits 63:43 x (2's complement)
21 bits 42:22 y (2's complement)
21 bits 21: 1 z (2's complement, negative = behind camera)
1 bit end of data detection, set to 1 for all vertices, stops calculating when 0 is hit

**

RASTER MEMORY: 3x vertex_memory_bins
2^16 (max) words, in pieces depending on address bits
memory address format: {bin y-index (7 bits), bin number x (7 bits), sequential (2 bits)}

one word: (36 bits)
10 bits 35:26 x (unsigned) (overscan a bit to allow for triangles to be off the screen a bit)
10 bits 25:16 y (unsigned)
16 bits 15: 0 z (unsigned)

then, also 1x vertex_memory_norms
memory address format: same
one word: (32 bits)
10 bits 31:22 normx
10 bits 21:12 normy
10 bits 11: 2 normz
1 bit detection
1 bit for good luck

---

start going from 0 to 1 when done=1 makes it restart
while done=1, address to data guaranteed one clock cycle delay (directly to and from M9K)

---

debug:

world memory: 
(1000, 1500, 10)
(125, 100, 1)
(200, 250, 2)

after division: 
(100, 150)
(125, 100)
(100, 125)

after shifting:
(500, 412)
(525, 362)
(500, 387)

*/
module vertex_transform #(screenWidth = 800, screenHeight = 525) (
	input logic start,
	output logic done,
	
	input logic[6:0] bin_y, 
	input logic[6:0] bin_x, 
	input logic[1:0] bin_seq, 
	output logic[35:0] triangle[3],
	output logic[31:0] norms,
	
	input logic BOARD_CLK
);

	//params
	parameter shiftX = screenWidth / 2;
	parameter shiftY = screenHeight / 2;

	//signals
	logic[63:0] world_memory_out[3];
	logic[35:0] raster_memory_in[3];
	logic[31:0] raster_memory_norms_in;
	logic[15:0] raster_memory_in_addr;
	logic raster_memory_wren;
	
	//registers and their next's
	enum logic[7:0] {
		initState,
		
		calcState1, 
		calcState2, 
		calcState3, 
		
		saveState,
		
		doneState1, 
		doneState2
	} state = initState, state_next;
	logic[13:0] world_memory_addr, world_memory_addr_next;
	
	genvar i;
	generate //3 vertexes in triangle
	for(i = 0; i < 3; i++) begin: vertex_memory_generate
		//worldspace vertices
		vertex_memory world_memory (.clock(BOARD_CLK), //todo: write to world memory? keyboard controls?
											 .wraddress(14'd0), .data(64'd0), .wren(1'd0), 
											 .rdaddress(world_memory_addr), .q(world_memory_out[i]));
		
		//raster space bins
		vertex_memory_bins raster_memory(.clock(BOARD_CLK), .wraddress(raster_memory_in_addr), .data(raster_memory_in[i]), .wren(raster_memory_wren), 
																			 .rdaddress({bin_y, bin_x, bin_seq}), .q(triangle[i]));
		
		//two divisions per vertex
		vertex_divide divx(.clock(BOARD_CLK), 
								.numer(world_memory_out[i][63:43]),   //x
								.denom(world_memory_out[i][21:1]),    //z
								.quotient(raster_memory_in[i][35:26]),//into x (todo: not just blindly truncate MSB's?)
								.remain());
		vertex_divide divy(.clock(BOARD_CLK), 
								.numer(world_memory_out[i][42:22]),   //y
								.denom(world_memory_out[i][21:1]),    //z
								.quotient(raster_memory_in[i][25:16]),//into x
								.remain());
		//and just assign z, right shifted to fit
		assign raster_memory_in[i][15:0] = world_memory_out[i][21:6];
		end
	endgenerate
	
	//raster space norms
	vertex_memory_norms raster_norms(.clock(BOARD_CLK), .wraddress(raster_memory_in_addr), .data(raster_memory_norms_in), .wren(raster_memory_wren), 
																		 .rdaddress({bin_y, bin_x, bin_seq}), .q(norms));
	
	always_ff @(posedge BOARD_CLK) begin
		state <= state_next;
		world_memory_addr <= world_memory_addr_next;
	end
	
	//next state logic
	always_comb begin
		state_next = state;
		world_memory_addr_next = world_memory_addr;
		raster_memory_wren = 0;
		done = 0;
		
		unique case(state)
			initState: begin
				//initially we start at zero
				world_memory_addr_next = 0;
				state_next = calcState1;
			end
			
			calcState1: begin
				//finished reading from memory here, so we check if we need to halt
				if (world_memory_out[0] == 0) state_next = doneState1;
				else state_next = calcState2;
			end
			//these we are just waiting for the divider to catch up with everything
			calcState2: state_next = calcState3;
			calcState3: state_next = saveState;
			
			saveState: begin
				//save everything to raster memory
				raster_memory_wren = 1;
				//begin loading next world memory
				world_memory_addr_next = world_memory_addr + 1;
				
				state_next = calcState1;
			end
			
			doneState1: begin
				//wait until start is low, just in case we finished more quickly than anticipated
				if (start == 0) state_next = doneState2;
				done = 1;
			end
			
			doneState2: begin
				//now we wait until start is high again to start again
				if (start == 1) state_next = initState;
				done = 1;
			end
			
			default: ;
		endcase
	end
	
	//calculating the norms, 6 multipliers required
	//this does a cross product
	//genvar i;
	generate //this generate loops thru the 3 dimensions, not the 3 vertices
	for(i = 0; i < 3; i++) begin: norm_generate
		logic[41:0] vector1 = world_memory_out[0][i*21+21:i*21+1] - world_memory_out[1][i*21+21:i*21+1],
						vector2 = world_memory_out[0][i*21+21:i*21+1] - world_memory_out[2][i*21+21:i*21+1];
		logic[41:0] A, B;
		
		vertex_multiply mult_A(.clock(BOARD_CLK), .dataa(vector1[(i+1)%3]), .datab(vector2[(i+2)%3]), .result(A));
		vertex_multiply mult_B(.clock(BOARD_CLK), .dataa(vector1[(i-1)%3]), .datab(vector2[(i-2)%3]), .result(B));
		
		//truncating those MSB's might not be the best option here... but tbh most of them are zeros... right?
		assign raster_memory_norms_in[i*10+11:i*10+2] = A - B;
	end
	endgenerate
endmodule
