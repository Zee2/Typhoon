module full_adder_pg
(
	input logic a,
	input logic b,
	input logic Cin,
	output logic Cout,
	output logic s,
	output logic p,
	output logic g

);

	// Basic full adder, but this one has support for propagate and generate signals.

	always_comb begin
	g = a & b; // Compute output signals.
	p = a ^ b;
	s = a ^ b ^ Cin;
	Cout = (a & b) | (a & Cin) | ( b & Cin);
	end
	
endmodule