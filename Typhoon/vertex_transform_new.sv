module vertex_transform_new #(screenWidth = 800, screenHeight = 525) (

	input logic start,
	output logic done,
	
	input logic[6:0] bin_y, 
	input logic[6:0] bin_x, 
	input logic[1:0] bin_seq, 
	output logic[35:0] triangle[3],
	output logic[31:0] norms,
	
	input logic BOARD_CLK

);

endmodule