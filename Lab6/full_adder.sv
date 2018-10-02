module full_adder
(
	input logic a,
	input logic b,
	input logic Cin,
	output logic Cout,
	output logic s

);

	// An extremely basic full adder unit that computes a 1 bit sum, with carry in and carry out support.

	always_comb begin
	
	
	// Compute sum and carry out.
	s = a ^ b ^ Cin;
	Cout = (a & b) | (a & Cin) | ( b & Cin);
	
	end
	
endmodule