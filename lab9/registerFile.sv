module registerFile(
	input logic Clk,
	input logic[31:0] D,
	input logic Reset_ah,
	
	input logic LD_REG, 
	
	input logic[3:0] DR,
	input logic[3:0] SR1,
	input logic[3:0] SR2,
	
	output logic[31:0] Q[16],
	output logic[31:0] SR1_Out,
	output logic[31:0] SR2_Out
);

	logic Load[16];
	
	
	
	
	genvar i;
	generate
		for (i=0;i<16;i++) begin: internal_register_generate
			internal_register #(32) register(.D(D),  .Q(Q[i]),  .Load(Load[i]),  .Reset(Reset_ah), .Clk(Clk));
		end
	endgenerate
	
	always_comb begin
		//load BUS into DR
		Load = '{16{'0}};
		Load[DR] = LD_REG;
		
		//output the correct SR's
		SR1_Out = Q[SR1];
		SR2_Out = Q[SR2];
	end
	
endmodule
