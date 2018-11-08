/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);

	
logic [3:0] expandCounter = 0;
logic [3:0] decryptCounter = 0;
logic [3:0] mixCounter = 0;

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

	SubBytes subBytes(.in(currentData[((i+1)*8)-1:i*8]), .out(subBytesOut[((i+1)*8)-1:i*8]), .clk(CLK));

end

endgenerate

enum logic [7:0] {

	waiting,
	done,
	AESbegin,
	expansion,
	shiftRowsState,
	subBytesState1,
	subBytesState2,
	addRoundKeyState,
	mixColumnsState
	
	

} state, nextState;




// Synchronous state latching
always_ff @ (posedge CLK) begin
	state <= nextState;
	currentData <= nextData;
	
	if(state == waiting) begin
		AES_DONE <= 0;
		expandCounter <= 0;
		decryptCounter <= 0;
		mixCounter <= 0;
	end
	
	if(state == expansion)
		expandCounter <= expandCounter + 1;
	
	if(state == mixColumnsState)
		mixCounter <= mixCounter + 1;
	
		
	// Make sure to increment decryptCounter even during the 
	// AESbegin state, because we use decryptCounter as the roundKeySchedule index
	if(state == addRoundKeyState || state == AESbegin)
		decryptCounter <= decryptCounter + 1;
		
	if(state == done) begin
		AES_MSG_DEC <= nextData;
		AES_DONE <= 1;
	end
	
end


// State behavior logic (separate from next state calc)
always_comb begin

	unique case (state)
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
			nextData = subBytesOut;
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
			nextData = mixOut;
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

	unique case (state)
	
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
			if(expandCounter >= 10)
				nextState = expansion;
			else
				nextState = AESbegin;
			
		end
		
		
		// AESbegin also performs the pre-loop AddRoundKey
		AESbegin: begin
			nextState = shiftRowsState;
		
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
			if(mixCounter < 4)
				nextState = mixColumnsState; //Mix more columns....
			else // Done mixing columns....
				nextState = shiftRowsState;
		end
		
		
		default:
			nextState = waiting;
		
	
	endcase

end


endmodule
