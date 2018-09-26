module adder_9(
	input logic[8:0] A,
	input logic[8:0] B,
	input logic Sub,
	output logic MSB,
	output logic[7:0] Sum
	
);

	// "Sub" input port is low when adding, high when subtracting.

	logic[9:0] carries; //10 carry signals, one carry out per adder, plus overall carry in
	logic[8:0] sum_9bit;

	generate
		for(genvar i = 0; i < 9; i++) begin: adderGenLoop
			full_adder adder_i(.A(A[i]), .B(B[i] ^ Sub), .Cin(carries[i]), .Cout(carries[i+1]), .S(sum_9bit[i]));
		end
	endgenerate
	
	assign carries[0] = Sub; //Carry in is bound to add/subtract mode signal
	assign {MSB, Sum} = sum_9bit;
endmodule