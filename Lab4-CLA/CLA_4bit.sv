module CLA_4bit(
	input logic[3:0] A,
	input logic[3:0] B,
	input logic Cin,
	output logic Cout,
	output logic[3:0] Sum,
	output logic Pg,
	output logic Gg
	

);

	logic[3:0] carries; //Internal carries
	logic[3:0] dummyCouts; //Dummy signals to 
	logic[3:0] Ps;
	logic[3:0] Gs;
	
	genvar i;
	// Loop to instantiate the full adders with propagate/generate support.
	generate
		for(i = 0; i < 4; i = i+1) begin : generateLoop
			full_adder_pg FApg_i(A[i], B[i], carries[i], dummyCouts[i], Sum[i], Ps[i], Gs[i]);
		end
		
	endgenerate
	
		
	always_comb begin
	
		carries[0] = Cin; //Set the first internal carry from the CLU = Cin
		
		//Compute the various look-ahead carries
		
		carries[1] = (Cin & Ps[0]) | Gs[0];
		
		carries[2] = (Cin & Ps[0] & Ps[1]) | (Gs[0] & Ps[1]) | Gs[1];
		
		carries[3] = (Cin & Ps[0] & Ps[1] & Ps[2]) | (Gs[0] & Ps[1] & Ps[2]) | (Gs[1] & Ps[2]) | Gs[2];
		
		Cout = (Cin & Ps[0] & Ps[1] & Ps[2] & Ps[3]) | (Gs[0] & Ps[1] & Ps[2] & Ps[3]) | (Gs[1] & Ps[2] & Ps[3]) | (Gs[2] & Ps[3]);
		
		
		
		//Compute group propagate/generate signals for hierarchical implementations
		
		Pg = Ps[0] & Ps[1] & Ps[2] & Ps[3];
		
		Gg = Gs[3] | (Gs[2] & Ps[3]) | (Gs[1] & Ps[3] & Ps[2]) | (Gs[0] & Ps[3] & Ps[2] & Ps[1]);
		

	end
		
		
endmodule