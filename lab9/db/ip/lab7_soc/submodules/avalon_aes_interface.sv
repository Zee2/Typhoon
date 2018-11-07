/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);

logic[3:0] registerSelect;
logic[31:0] Q[16];
logic[31:0] mask;

assign AVL_READDATA = Q[registerSelect] & mask;
assign EXPORT_DATA = {Q[0][15:0], Q[3][31:16]};
assign registerSelect = AVL_ADDR;

registerFile registers(
	.Clk(CLK),
	.Reset_ah(RESET),
	
	.D(AVL_WRITEDATA),
	.DR(registerSelect),
	.LD_REG(AVL_WRITE && AVL_CS),

);


always_comb begin
/*
	case(AVL_BYTE_EN)
	
		4'b1111:
			mask = 32'hffffffff;
		4'b1100:
			mask = 32'hffff0000;
		4'b0011:
			mask = 32'h0000ffff;
		4'b1000:
			mask = 32'hff000000;
		4'b0100:
			mask = 32'h00ff0000;
		4'b0010:
			mask = 32'h0000ff00;
		4'b0001:
			mask = 32'h000000ff;
		default:
			mask = 32'h00000000;
	endcase
		
*/
mask = 32'hffffffff;

end




endmodule
