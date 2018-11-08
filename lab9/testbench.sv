module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

logic Clk = 0;

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end


/*
module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);
*/

logic RESET, AES_START, AES_DONE;
logic [127:0] AES_KEY, AES_MSG_ENC, AES_MSG_DEC;
logic CONTINUE = 0;
AES tested(.CLK(Clk), .*);

initial begin : testLoop
	RESET = 1;
	AES_START = 0;
	#10 RESET = 0;
	
	AES_KEY = 128'h000102030405060708090a0b0c0d0e0f;
	AES_MSG_ENC = 128'hdaec3055df058e1c39e814ea76f6747e;
	#10 AES_START = 1;
	#10000000 AES_START = 0;
end

endmodule