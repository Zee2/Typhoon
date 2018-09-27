module multiplier_toplevel(
	input logic[7:0] S_USH,
	input logic Clk,
	input logic Reset_USH,
	input logic Run_USH,
	input logic ClearA_LoadB_USH,
	output logic[6:0] AhexU,
	output logic[6:0] AhexL,
	output logic[6:0] BhexU,
	output logic[6:0] BhexL,
	output logic[7:0] Aval,
	output logic[7:0] Bval,
	output logic X

);

	// Synced inputs
	logic Reset, Run, ClearA_LoadB;
	logic[7:0] S;


	//Hex drivers
	HexDriver hdAU(.In0(Aval[7:4]), .Out0(AhexU));
	HexDriver hdAL(.In0(Aval[3:0]), .Out0(AhexL));
	HexDriver hdBU(.In0(Bval[7:4]), .Out0(BhexU));
	HexDriver hdBL(.In0(Bval[3:0]), .Out0(BhexL));

	// Internal busses
	logic[7:0] adderToA;
	
	// AdderMSB is bound to the MSB of the 9bit adder.
	// On each rising clock edge, the flip flop signal X is either
	// reset by the Clr_Ld signal from the FSM, or it is set to be
	// equal to the adderMSB.
	// This is done with an always_ff section below.
	logic adderMSB;
	
	// These are controlled by the FSM.
	logic ClearAX, ClearB, LoadAX, LoadB, Shift, Add, Sub;
	
	// Instantiate FSM.
	control controller(.M(Bval[0]), .*);
	
	// Adder unit
	adder_9 adderUnit(.A({Aval[7], Aval}), .B({S[7], S}), .MSB(adderMSB), .Sum(adderToA), .Sub(Sub));

	// Leaving regA.Shift_Out unconnected because we can just use A[0].
	//
	// Reset controlled by Clr_Ld signal from FSM
	//
	// Load controlled by the ADD signal. In the add state, we save the sum
	// from the adder to regA in parallel.
	reg_8 regA(.Clk(Clk),
					.Reset(ClearAX),
					.Shift_In(X),
					.Load(LoadAX),
					.Shift_En(Shift),
					.D(adderToA),
					.Shift_Out(),
					.Data_Out(Aval));
	
	// Connecting switches directly to regB.D. Loading/shifting still
	// controlled by the FSM signals.
	//
	// Serial in pin is bound to the LSB of regA. (A[0])
	reg_8 regB(.Clk(Clk),
					.Reset(ClearB),
					.Shift_In(Aval[0]),
					.Load(LoadB),
					.Shift_En(Shift),
					.D(S),
					.Shift_Out(),
					.Data_Out(Bval));
					
	// Implementation of the aforementioned X latch.
	always_ff @ (posedge Clk)
	begin
		// Reset X on the FSM's clr_ld signal
		if(ClearAX)
			X <= 1'b0;
		else
			X <= adderMSB;
	end
	
	sync button_sync[2:0] (Clk, {~Reset_USH, ~ClearA_LoadB_USH, ~Run_USH}, {Reset, ClearA_LoadB, Run});
	sync switch_sync[7:0] (Clk, S_USH, S);
	

endmodule