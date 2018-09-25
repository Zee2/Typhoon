module adder_9(
	input logic[8:0] A,
	input logic[8:0] B,
	input logic sub,
	output logic MSB,
	output logic[7:0] Sum
	
);

	// "Sub" input port is low when adding, high when subtracting.

	logic[9:0] carries; //9 carry signals
	logic[8:0] sum_9bit;

	genvar i;
	generate
		for(i = 0; i < 9; i++) begin: adderGenLoop
			full_adder adder_i(.A(A[i] ^ sub), .B(B[i] ^ sub), .Cin(carries[i]), .Cout(carries[i+1]), .S(sum_9bit[i]));
		end
	endgenerate
	

	assign carries[0] = sub; //Carry in is bound to add/subtract mode signal
	assign Sum = sum_9bit[7:0];
	assign MSB = sum_9bit[8];
	

endmodule