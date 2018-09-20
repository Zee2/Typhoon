module carry_lookahead_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	logic[3:0] carries;
	logic[3:0] Ps;
	logic[3:0] Gs;
	logic[3:0] dummyCouts;
	logic Cin = 1'b0;
	
	
	genvar i;
	
	generate
		for(i = 0; i < 4; i = i+1) begin : generateLoop
			CLA_4bit FApg_i(A[4*i+3:4*i], B[4*i+3:4*i], carries[i], dummyCouts[i], Sum[4*i+3:4*i], Ps[i], Gs[i]);
		end
		
	endgenerate
	
	  
	always_comb begin
	
		carries[0] = Cin; //Set the first internal carry from the CLU = Cin
		
		//Compute the various look-ahead carries
		
		carries[1] = (Cin & Ps[0]) | Gs[0];
		
		carries[2] = (Cin & Ps[0] & Ps[1]) | (Gs[0] & Ps[1]) | Gs[1];
		
		carries[3] = (Cin & Ps[0] & Ps[1] & Ps[2]) | (Gs[0] & Ps[1] & Ps[2]) | (Gs[1] & Ps[2]) | Gs[2];
		
		CO = (Cin & Ps[0] & Ps[1] & Ps[2] & Ps[3]) | (Gs[0] & Ps[1] & Ps[2] & Ps[3]) | (Gs[1] & Ps[2] & Ps[3]) | (Gs[2] & Ps[3]);
		
		
		
		//Compute group propagate/generate signals for hierarchical implementations
		
		
		//Not needed for this lab demo.
		
		//Pg = Ps[0] & Ps[1] & Ps[2] & Ps[3];
		
		//Gg = Gs[3] | (Gs[2] & Ps[3]) | (Gs[1] & Ps[3] & Ps[2]) | (Gs[0] & Ps[3] & Ps[2] & Ps[1]);
		

	end
     
endmodule
