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

	always_comb begin
	g = a & b;
	p = a ^ b;
	s = a ^ b ^ Cin;
	Cout = (a & b) | (a & Cin) | ( b & Cin);
	end
	
endmodule