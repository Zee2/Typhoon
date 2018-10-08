//todo, find out if it's kosher to do this
//or if we have to use a CRA or whatever
module alu #(int W=16) (
	input logic[W-1:0] A, 
	input logic[W-1:0] B, 
	
	input logic[1:0] K,
	output logic[W-1:0] Out
);
	always_comb
		unique case(K)
			0: Out = A + B;
			1: Out = A & B;
			2: Out = ~A;
			3: Out = A;
		endcase
endmodule
