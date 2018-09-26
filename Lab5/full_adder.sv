module full_adder
(
	input logic A,
	input logic B,
	input logic Cin,
	output logic Cout,
	output logic S

);

	// An extremely basic full adder unit that computes a 1 bit sum, with carry in and carry out support.

	always_comb begin
	
	// Compute sum and carry out.
	S = A ^ B ^ Cin;
	Cout = (A & B) | (A & Cin) | (B & Cin);
	
	end
	
endmodule