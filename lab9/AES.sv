/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic CONTINUE,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);


logic [7:0] expandCounter = 0;
logic [7:0] decryptCounter = 0;
logic [7:0] mixCounter = 0;

logic [1407:0] RoundKeySchedule;

logic [127:0] rowShiftIn;
logic [127:0] rowShiftOut;

logic [31:0] mixIn;
logic [31:0] mixOut;

logic [127:0] currentData;
logic [127:0] nextData;

logic [127:0] subBytesOut;

KeyExpansion keyExpander(
	.clk(CLK),
	.Cipherkey(AES_KEY),
	.KeySchedule(RoundKeySchedule)
);

InvShiftRows rowShifter(
	.data_in(rowShiftIn),
	.data_out(rowShiftOut)

);

assign rowShiftIn = currentData; //optimizationnn

InvMixColumns columnMixer(
	.in(mixIn),
	.out(mixOut)
);

assign mixIn = currentData[mixCounter*32 +: 32]; //optimizationnn

genvar i;
generate

for(i = 0; i < 16; i++) begin: subBytesGenerate

	InvSubBytes subBytes(.in(currentData[i*8+:8]), .out(subBytesOut[i*8+:8]), .clk(CLK));

end

endgenerate

enum logic [7:0] {

	waiting = 8'd0,
	done = 8'd1,
	AESbegin = 8'd2,
	expansion = 8'd3,
	shiftRowsState = 8'd4,
	subBytesState1 = 8'd5,
	subBytesState2 = 8'd6,
	addRoundKeyState = 8'd7,
	mixColumnsState = 8'd8
	
	

} currentState, nextState;

initial currentState = waiting;

//assign AES_DONE = state == done;

// Synchronous state latching
always_ff @ (posedge CLK) begin

	if(RESET)
		currentState <= waiting;
		//nextState <= waiting;
		currentData <= 128'h0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;

	currentState <= nextState;
	currentData <= nextData;
	//AES_MSG_DEC <= {8'h0f, 8'h0f, nextData[111:16], currentState, nextState}; //debug
	
	if(currentState == waiting) begin
		expandCounter <= 0;
		decryptCounter <= 0;
		mixCounter <= 0;
	end
	
	if(currentState == expansion)
		expandCounter <= expandCounter + 1;
	else
		expandCounter <= 0;
	
	if(currentState == mixColumnsState)
		mixCounter <= mixCounter + 1;
	else
		mixCounter <= 0;
		
	// Make sure to increment decryptCounter even during the 
	// AESbegin state, because we use decryptCounter as the roundKeySchedule index
	if(currentState == addRoundKeyState || currentState == AESbegin)
		decryptCounter <= decryptCounter + 1;
		
	if(currentState == done) begin
		AES_MSG_DEC <= nextData;
		
		AES_DONE <= 1;
	end
	else begin
		AES_DONE <= 0;
	end
	
end


// State behavior logic (separate from next state calc)
always_comb begin

	unique case (currentState)
		expansion: begin
			
			nextData = AES_MSG_ENC;
		end
		
		// Set row shifters input to currentData, set nextData
		// to row shifters' output. Then 
		shiftRowsState: begin
			//rowShiftIn = currentData;
			nextData = rowShiftOut;
		
		end
		
		// Perform subBytes. All subBytes modules already have
		// the currentData as their input. Simply set nextData to the output
		subBytesState1: begin
			nextData = currentData;
		end
		
		subBytesState2: begin
			nextData = subBytesOut;
		end
		
		// Add round key (XOR) during AESbegin and addRoundKeyState
		addRoundKeyState, AESbegin: begin
			nextData = currentData ^ RoundKeySchedule[128*decryptCounter +: 128];
			/*
			case(decryptCounter)
				0: nextData = currentData ^ RoundKeySchedule[128+:decryptCounter*128];
				1: nextData = currentData ^ RoundKeySchedule[128+:i*128];
				2: nextData = currentData ^ RoundKeySchedule[128+:i*128];
				3: nextData = currentData ^ RoundKeySchedule[128+:i*128];
				4: nextData = currentData ^ RoundKeySchedule[128+:i*128];
 				5: nextData = currentData ^ RoundKeySchedule[128+:i*128];
				6: nextData = currentData ^ RoundKeySchedule[128+:i*128];
				7: nextData = currentData ^ RoundKeySchedule[128+:i*128];
				8: nextData = currentData ^ RoundKeySchedule[128+:i*128];
				9: nextData = currentData ^ RoundKeySchedule[128+:i*128];
				10: nextData = currentData ^ RoundKeySchedule[128+:i*128];
			
			endcase
			// OOoooh, fancy parameterized multiplexer
			genvar i;
			generate
			for(i = 0; i < 11; i++) begin: caseloop
				if(decryptCounter == i)
					nextData = currentData ^ RoundKeySchedule[((i+1)*128)-1:i*128];
			
			end
			endgenerate
			*/
			
		end
		
		
		mixColumnsState: begin
		
			//mixIn = currentData[mixCounter*32 +: 32]; // Now in assign statement
			
			/*
			// OOOh, another parameterized multiplexer
			genvar i;
			generate
			for(i = 0; i < 4; i++) begin: caseloop
				if(i == mixCounter)
					mixIn = currentData[32+:i*32];
			
			end
			endgenerate
			*/
			nextData = currentData;
			nextData[mixCounter*32+:32] = mixOut;
		end
		
		done: begin
			nextData = currentData;
		end
		
		default:
			nextData = currentData;
	endcase

end


// Combinatorial next state calcs
always_comb begin

	unique case (currentState)
	
		waiting: begin
			if(AES_START == 0)
				nextState = waiting;
			else
				nextState = expansion;
		end
		
		
		done: begin
			if(AES_START == 0)
				nextState = waiting;
			else
				nextState = done;
		
		end
		
		expansion: begin
			if(expandCounter <= 10)
				nextState = expansion;
			else
				nextState = AESbegin;
			
		end
		
		
		// AESbegin also performs the pre-loop AddRoundKey
		AESbegin: begin
			nextState = shiftRowsState; // DEBUG
		
		end
		
		shiftRowsState: begin
			nextState = subBytesState1;
		end
		
		subBytesState1: begin
			nextState = subBytesState2;
		end
		
		subBytesState2: begin
			nextState = addRoundKeyState;
		end
		
		addRoundKeyState: begin
			if(decryptCounter >= 10)
				nextState = done;
			else
				nextState = mixColumnsState;
		end
		
		mixColumnsState: begin
			if(mixCounter < 3)
				nextState = mixColumnsState; //Mix more columns....
			else // Done mixing columns....
				nextState = shiftRowsState;
		end
		
		
		default:
			nextState = waiting;
		
	
	endcase

end


endmodule
