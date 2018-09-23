module CSA_unit(

	input logic[3:0] A,
	input logic[3:0] B,
	input logic Cin,
	
	output logic[3:0] sum,
	output logic Cout
	
	
	
);

	logic carry0;
	logic carry1;

	logic[3:0] sum0;
	logic[3:0] sum1;

	
	// The adder that computes the zero-carry sum.
	CRA_4bit adder0(
		.A(A),
		.B(B),
		.Cin(1'b0),
		.Cout(carry0),
		.Sum(sum0)
	);
	// The adder that computes the one-carry sum.
	CRA_4bit adder1(
		.A(A),
		.B(B),
		.Cin(1'b1),
		.Cout(carry1),
		.Sum(sum1)
	);
	
	always_comb begin
	
	// Compute carry out.
	Cout = (carry1 & Cin) | carry0;
	
	
	// Multiplexer to select the proper sum based on the real-world carry-in bit.
	case(Cin)
		1'b0: sum = sum0;
		1'b1: sum = sum1;
		default: sum = sum0;
	endcase
	
	
	end


endmodule