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

	
logic [3:0] loopCounter = 0;
logic [1407:0] RoundKeySchedule;

KeyExpansion keyExpander(
	.clk(CLK),
	.Cipherkey(AES_KEY),
	.KeySchedule(RoundKeySchedule)
);

enum logic [7:0] {

	waiting,
	done,
	AESbegin,
	expansion
	
	

} state, nextState;




// Synchronous state latching
always_ff @ (posedge CLK) begin
	state <= nextState;

end

// Combinatorial next state calcs
always_comb begin

	case (state)
	
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
			if(loopCounter >= 10)
				nextState = expansion;
			else
				nextState = AESbegin;
			
		end
		
		default:
			nextState = waiting;
		
	
	endcase

end


endmodule
