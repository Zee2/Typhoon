module ripple_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

	// This is a totally basic ripple adder. It calculates a 4-bit sum, and supports carry out.

	// These are the internal carry signals. The last signal serves as the carry out.
	logic[16:0] carries;
	
	
	// This loop generates the four full adders that make up the unit.
	genvar i;
   generate
		for(i = 0; i < 16; i = i+1) begin : generateLoop
			full_adder FA_i(A[i], B[i], carries[i], carries[i+1], Sum[i]);
		end
	endgenerate
	
	
	
	always_comb begin
		carries[0] = 1'b0; // This sets the initial carry-in to be zero.
		CO = carries[16];
	end
endmodule


