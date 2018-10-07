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
	
	output logic BEN,
	output logic [15:0] MAR, IR, PC, MDR

);
	// Thank you Mr. Bus Driver.
	logic[15:0] Bus;
	
	// Register output signals.
	logic[15:0] SR1;
	logic[15:0] SR2;
	// Instantiate register file. Hooks up to clk, system bus, and outputs to SR1 and SR2, as of now...
	// Will need more control signals, muxes, etc etc etc :(
	registerFile registers(.*);

	// ALU output.
	logic[15:0] ALU;

	//Connection between Address muxes and the adder.
	logic[15:0] ADDR1;
	logic[15:0] ADDR2;
	
	// Result of addition of ADDR1 + ADDR2
	logic[15:0] MARMUX;
	
	assign MARMUX = ADDR1 + ADDR2;

	//ADDR1MUX.
	always_comb begin
		unique case(ADDR1MUX)
			0: ADDR1 = PC; // This mux mapping is taken from the SLC-3 control signal mapping pdf
			1: ADDR1 = SR1;
			default: ADDR1 = 16'bx;
		endcase
	end
	
	//ADDR2MUX. Needs more work! Not done! TODO!!!
	always_comb begin
		unique case(ADDR2MUX)
			0: ADDR2 = 16'b0;
			1: ADDR2 = $signed(IR[5:0]);
			2: ADDR2 = $signed(IR[8:0]);
			3: ADDR2 = $signed(IR[10:0]);
			default: ADDR2 = 16'bx;
		endcase
	end
	
	

	logic[3:0] BusMuxCode;
	// Bus driver MUX to prevent bus contention.
	always_comb begin
		
		BusMuxCode = {GateMARMUX, GatePC, GateALU, GateMDR};
		unique case(BusMuxCode)
			4'b1000: Bus = MARMUX;
			4'b0100: Bus = PC;
			4'b0010: Bus = ALU;
			4'b0001: Bus = MDR;
			default: Bus = 16'bx;
		endcase
	end
	
	logic[15:0] MDR_MuxedIn; // "Wire" to ensure no accidental latching...
	// MAR Input mux, selecting between bus and Data_In_CPU (technically called MDR_in but that's just bad naming)
	always_comb begin
		unique case(MIO_EN)
			0: MDR_MuxedIn = Bus;
			1: MDR_MuxedIn = MDR_In;
			default: MDR_MuxedIn = 1'bx;
			
		endcase
	end
	
	
	// Connection between PCMUX and PC.
	logic[15:0] PC_MuxedIn;
	//PCMUX implementation
	always_comb begin
		unique case(PCMUX)
			0: PC_MuxedIn = PC + 1;
			1: PC_MuxedIn = Bus;
			2: PC_MuxedIn = MARMUX;
			default: PC_MuxedIn = 1'bx;
		endcase
	end
	
	
	
	// Internal registers. Possibly replace the reset signals in the future... not specced?
	// Parameterized basic flipflop register custom module by Finn :)
	
	internal_register #(16) MDRregister(.D(MDR_MuxedIn), .Q(MDR), .Load(LD_MDR), .Reset(Reset_ah), .*);
	internal_register #(16) MARregister(.D(Bus),         .Q(MAR), .Load(LD_MAR), .Reset(Reset_ah), .*);
	internal_register #(16) IRregister( .D(Bus),         .Q(IR),  .Load(LD_IR),  .Reset(Reset_ah), .*);
	internal_register #(16) PCregister( .D(PC_MuxedIn),  .Q(PC),  .Load(LD_IR),  .Reset(Reset_ah), .*);
	
	
	
	
	
	// Conditional branch logic.
	// Connects to Bus, IR, outputs to BEN.
	NZPlogic conditionalLogic(.Reset(Reset_ah), .*);
	
	
	

	
		
	


endmodule