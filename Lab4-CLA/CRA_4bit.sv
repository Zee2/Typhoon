module CRA_4bit(
	input logic[3:0] A,
	input logic[3:0] B,
	input logic Cin,
	output logic Cout,
	output logic[3:0] Sum
);


// Simple ripple carry adder with 4 full adders. Supports carry in and carry out.

logic[4:0] carries;


// Loop to instantiate all four full adder units.
genvar i;
generate
	for(i = 0; i < 4; i = i+1) begin: genLoop
		full_adder adder_i(A[i], B[i], carries[i], carries[i+1], Sum[i]);
	end
endgenerate

// Hook up the carry signals.
assign carries[0] = Cin;
assign Cout = carries[4];

endmodule