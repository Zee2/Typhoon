module registerFile(

	input logic Clk,
	input logic[15:0] Bus,
	output logic[15:0] SR1, SR2
	
);

	internal_register #(16) registers[7:0]();
	
	//TODO: obviously all of this

endmodule