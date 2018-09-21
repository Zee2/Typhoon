module CSA_unit(

	input logic[3:0] A,
	input logic[3:0] B,
	input logic Cin,
	
	output logic[3:0] sum,
	output logic Cout
	
	
	
);

	logic[1:0] carries;

	logic[3:0] sum0;
	logic[3:0] sum1;
	logic dummies[3:0];

	CLA_4bit adder0(
		.A(A),
		.B(B),
		.Cin(1'b0),
		.Cout(carries[0]),
		.Sum(sum0),
		.Pg(),
		.Gg()
	);

	CLA_4bit adder1(
		.A(A),
		.B(B),
		.Cin(1'b1),
		.Cout(carries[1]),
		.Sum(sum1),
		.Pg(),
		.Gg()
	);
	
	always_comb begin
	
	Cout = (carries[1] & Cin) | carries[0];
	
	case(Cin)
		1'b0: sum = sum0;
		1'b1: sum = sum1;
		default: sum = sum0;
	endcase
	
	
	end


endmodule