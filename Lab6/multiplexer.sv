//several multiplexers
//this could be parameterized better into one with a width and height parameter
//but eh

module two_mux #(int W = 1) (
	input logic [W-1:0] A, 
	input logic [W-1:0] B, 
	input logic Sel, 
	output logic [W-1:0] Out
);
	always_comb Out = Sel ? B : A;
endmodule

module four_mux #(int W = 1) (
	input logic [W-1:0] A, 
	input logic [W-1:0] B, 
	input logic [W-1:0] C, 
	input logic [W-1:0] D, 
	input logic [1:0] Sel, 
	output logic [W-1:0] Out
);
	always_comb
		unique case(Sel)
			0: Out = A;
			1: Out = B;
			2: Out = C;
			3: Out = D;
		endcase
endmodule
