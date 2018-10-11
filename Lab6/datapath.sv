module datapath(
	input logic Reset_ah,
	input logic Clk,
	input logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED,
	input logic GatePC,
	input logic GateMDR,
	input logic GateALU,
	input logic GateMARMUX,
	input logic [1:0] PCMUX, ADDR2MUX, ALUK,
	input logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX,
	input logic MIO_EN,
	input logic [15:0] MDR_In, //technically actually data_to_CPU (bad naming)
	output logic[11:0] LED,
	output logic BEN,
	output logic [15:0] MAR, IR, PC, MDR

);


	// Thank you Mr. Bus Driver.
	logic[15:0] Bus;
	
	// Internal signals
	logic[15:0] SR1_Out, SR2_Out, ALU_Out, MARMUX;
	// Output of muxes
	logic[15:0] PCMUX_Muxed, ADDR1MUX_Muxed, ADDR2MUX_Muxed, SR2MUX_Muxed, MDR_MuxedIn;
	logic[2:0] DRMUX_Muxed, SR1MUX_Muxed;
	
	// Register file
	registerFile registers(.Clk(Clk), .D(Bus), .DR(DRMUX_Muxed), .LD_REG(LD_REG), .SR1(SR1MUX_Muxed), .SR2(IR[2:0]), 
									.SR1_Out(SR1_Out), .SR2_Out(SR2_Out), .Reset_ah(Reset_ah));
	
	// Muxes
	four_mux #(16) PCMux_Mux(.A(PC+1), .B(Bus), .C(MARMUX), .D(16'bx), .Sel(PCMUX), .Out(PCMUX_Muxed));
	two_mux #(3) DRMUX_Mux(.A(IR[11:9]), .B(3'b111), .Sel(DRMUX), .Out(DRMUX_Muxed));
	two_mux #(3) SR1MUX_Mux(.A(IR[11:9]), .B(IR[8:6]), .Sel(SR1MUX), .Out(SR1MUX_Muxed));
	two_mux #(16) ADDR1MUX_Mux(.A(PC), .B(SR1_Out), .Sel(ADDR1MUX), .Out(ADDR1MUX_Muxed));
	four_mux #(16) ADDR2MUX_Mux(	.A(16'b0), 
											.B({{10{IR[ 5]}}, IR[ 5:0]}), 
											.C({{ 7{IR[ 8]}}, IR[ 8:0]}),
											.D({{ 5{IR[10]}}, IR[10:0]}), 
											.Sel(ADDR2MUX), .Out(ADDR2MUX_Muxed));
	two_mux #(16) SR2MUX_Mux(.A(SR2_Out), .B({{11{IR[4]}}, IR[4:0]}), .Sel(SR2MUX), .Out(SR2MUX_Muxed));
	alu ALU_Inst(.A(SR1_Out), .B(SR2MUX_Muxed), .K(ALUK), .Out(ALU_Out));
	
	// * MARMUX addition module
	assign MARMUX = ADDR1MUX_Muxed + ADDR2MUX_Muxed;
	
	logic[3:0] BusMuxCode;
	// Bus driver MUX to prevent bus contention.
	always_comb begin
		BusMuxCode = {GateMARMUX, GatePC, GateALU, GateMDR};
		unique case(BusMuxCode)
			4'b1000: Bus = MARMUX;
			4'b0100: Bus = PC;
			4'b0010: Bus = ALU_Out;
			4'b0001: Bus = MDR;
			default: Bus = 16'bx;
		endcase
	end
	
	// MAR Input mux, selecting between bus and Data_In_CPU (technically called MDR_in but that's just bad naming)
	always_comb begin
		unique case(MIO_EN)
			0: MDR_MuxedIn = Bus;
			1: MDR_MuxedIn = MDR_In;
			default: MDR_MuxedIn = 1'bx;
			
		endcase
	end
	
	/* //I wrote this, and then realized you already wrote it... lmao why so much vertical space after the internal registers ;-;
	//BEN and NZP logic
	logic BEN_In;
	logic[2:0] NZP_In;
	logic[2:0] NZP;
	always_comb begin
		BEN_In = (IR[11] & NZP[2])| //N
					(IR[10] & NZP[1])| //Z
					(IR[ 9] & NZP[0]); //P
		
		NZP_In = ~Bus[15] ? Bus[15:0] == 16'b0 ? 3'b001 : 3'b010 : 3'b100;
	end
	
	internal_register #(1) BENregister( .D(BEN_In),      .Q(BEN), .Load(LD_BEN), .Reset(Reset_ah), .*);
	internal_register #(3) NZPregister( .D(NZP_In),      .Q(NZP), .Load(LD_CC),  .Reset(Reset_ah), .*);
	*/
	
	// Internal registers. Possibly replace the reset signals in the future... not specced?
	// Parameterized basic flipflop register custom module by Finn :)
	internal_register #(16) MDRregister(.D(MDR_MuxedIn), .Q(MDR), .Load(LD_MDR), .Reset(Reset_ah), .*);
	internal_register #(16) MARregister(.D(Bus),         .Q(MAR), .Load(LD_MAR), .Reset(Reset_ah), .*);
	internal_register #(16) IRregister( .D(Bus),         .Q(IR),  .Load(LD_IR),  .Reset(Reset_ah), .*);
	internal_register #(16) PCregister( .D(PCMUX_Muxed), .Q(PC),  .Load(LD_PC),  .Reset(Reset_ah), .*);
	
	assign LED = IR[11:0];
	
	
	// Conditional branch logic.
	// Connects to Bus, IR, outputs to BEN.
	NZPlogic conditionalLogic(.Reset(Reset_ah), .*);

endmodule
