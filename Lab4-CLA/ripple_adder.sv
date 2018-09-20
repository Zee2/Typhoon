module ripple_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

	logic[16:0] carries;
	
	
	
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


