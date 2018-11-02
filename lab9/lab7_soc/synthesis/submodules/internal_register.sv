


// not currently used for MAR/MDR/IR/ etc... maybe in future?
module internal_register #(parameter width = 16)(

	input logic Clk,
	input logic Load,
	input logic Reset,
	input logic[width-1:0] D,
	output logic[width-1:0] Q
);

always_ff@(posedge Clk) begin
	if(Load)
		Q <= D;
	else if(Reset)
		Q <= 0;
	
end

endmodule