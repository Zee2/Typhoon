module multiplier_toplevel(
	input logic[7:0] S,
	input logic Clk,
	input logic Reset,
	input logic Run,
	input logic ClearA_LoadB,
	output logic X

);


	// Internal busses
	logic[7:0] A;
	logic[7:0] B;
	logic[7:0] adderToA;
	
	// AdderMSB is bound to the MSB of the 9bit adder.
	// On each rising clock edge, the flip flop signal X is either
	// reset by the Clr_Ld signal from the FSM, or it is set to be
	// equal to the adderMSB.
	// This is done with an always_ff section below.
	logic adderMSB;
	
	// These are controlled by the FSM.
	logic Clr_Ld, Shift, Add, Sub;
	
	
	// Instantiate FSM.
	control controller(.*);
	
	// Adder unit
	adder_9 adderUnit(.A({A[7], A}), .B({S[7], S}), .MSB(adderMSB), .Sum(adderToA));


	
	// Leaving regA.Shift_Out unconnected bc we can just use A[0].
	//
	// Reset controlled by Clr_Ld signal from FSM
	//
	// Load controlled by the ADD signal. In the add state, we save the sum
	// from the adder to regA in parallel.
	reg_8 regA(.Clk(Clk),
					.Reset(Clr_Ld),
					.Shift_In(X),
					.Load(Add),
					.Shift_En(Shift),
					.D(adderToA),
					.Shift_Out(),
					.Data_Out(A));
	
	// Connecting switches directly to regB.D. Loading/shifting still
	// controlled by the FSM signals.
	//
	// Serial in pin is bound to the LSB of regA. (A[0])
	reg_8 regB(.Clk(Clk),
					.Reset(ResetB),
					.Shift_In(A[0]),
					.Load(Clr_Ld),
					.Shift_En(Shift),
					.D(S),
					.Shift_Out(),
					.Data_Out(B));
					
	
	
	// Implementation of the aforementioned X latch.
	always_ff @ (posedge Clk)
	begin
		// Reset X on the FSM's clr_ld signal
		if(Clr_Ld)
			X = 1'b0;
		else
			X = adderMSB;
		
	end
	
		




endmodule