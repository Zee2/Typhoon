module adder2 (input [1:0] A, B, input c_in, output [1:0] S, output c_out);
	logic c1;
	
	full_adder FA0 (.x(A[0]), .y(B[0]), .z(c_in), .s(S[0]), .c(c1));
	full_adder FA1 (.x(A[1]), .y(B[1]), .z(c1), .s(S[1]), .c(c_out));
endmodule
