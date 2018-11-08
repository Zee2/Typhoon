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
logic[31:0] Qout[16];
logic[31:0] mask;
logic[31:0] AES_MSG_DEC[4];
logic AES_DONE;

assign AVL_READDATA = Qout[registerSelect];
assign EXPORT_DATA = {Qout[0][31:16], Qout[3][15:0]};
assign registerSelect = AVL_ADDR;
					


genvar i;
generate
	for (i=0;i<8;i++) begin: input_register_generate
		internal_register #(32) register(.D((AVL_WRITEDATA & mask) | (Qout[registerSelect] & ~mask)),
													.Q(Qout[i]),
													.Load(AVL_WRITE && AVL_CS),
													.Reset(RESET),
													.Clk(CLK));
	end
	for (i=8;i<12;i++) begin: output_register_generate
		internal_register #(32) register(.D(AES_MSG_DEC[i-8]),
													.Q(Qout[i]),
													.Load(1'b1),
													.Reset(RESET),
													.Clk(CLK));
	end
endgenerate

internal_register #(32) start_register(.D((AVL_WRITEDATA & mask) | (Qout[registerSelect] & ~mask)),
													.Q(Qout[14]),
													.Load(AVL_WRITE && AVL_CS),
													.Reset(RESET),
													.Clk(CLK));
internal_register #(32) done_register(.D(AES_DONE),
													.Q(Qout[15]),
													.Load(1'b1),
													.Reset(RESET),
													.Clk(CLK));


/*
registerFile registers(
	.Clk(CLK),
	.Reset_ah(RESET),
	
	.D((AVL_WRITEDATA & mask) | (Qout[registerSelect] & ~mask)),
	.DR(registerSelect),
	.LD_REG(AVL_WRITE && AVL_CS),
	.Q(Qout)
);
*/
AES AES_module(
	.CLK(Clk),
	.AES_START(Qout[14][0]),
	.AES_DONE(AES_DONE),
	.AES_KEY({Qout[3],Qout[2],Qout[1],Qout[0]}),
	.AES_MSG_ENC({Qout[7],Qout[6],Qout[5],Qout[4]}),
	.AES_MSG_DEC({AES_MSG_DEC[3], AES_MSG_DEC[2], AES_MSG_DEC[1], AES_MSG_DEC[0]}),
	.*

);


always_comb begin

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
		



end




endmodule