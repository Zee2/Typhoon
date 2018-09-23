module adder_9(
	input logic[8:0] A,
	input logic[8:0] B,
	output logic MSB,
	output logic[7:0] Sum
	
);

	logic[9:0] carries; //10 carry signals
	logic[8:0] sum_9bit;

	genvar i;
	generate
		for(i = 0; i < 8; i++) begin: adderGenLoop
			full_adder adder_i(.A(A[i]), .B(B[i]), .Cin(carries[i]), .Cout(carries[i+1]), .S(sum_9bit[i]));
		end
	endgenerate
	

	assign carries[0] = 1'b0; //Carry in is always zero.
	assign Sum = sum_9bit[7:0];
	assign MSB = sum_9bit[8];
	

endmodule