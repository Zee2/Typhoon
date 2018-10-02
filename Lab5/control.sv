module control(
	input logic Reset,
	input logic Clk,
	input logic Run,
	input logic ClearA_LoadB,
	input logic M,
	output logic ClearAX, ClearB, LoadAX, LoadB,
	output logic Shift,
	output logic Add,
	output logic Sub
);

	logic[4:0] shiftCounter;
	enum logic[4:0] {
		StartState, //initial state
		ClearLoadState, //state for ClearA_LoadB
		BeginCycleState, //right after run, initialization
		ShiftState, //shifting XAB next
		AddSubState, //if M=0, nothing, else adding S to XA
		HaltState //all done with everything, waiting for run to fall
	} currentState, nextState;
	
	always_ff @ (posedge Clk)
	begin
		
		
		if (Reset) begin
			// Reset state, and reset the shift counter
			currentState <= StartState;
			shiftCounter <= 4'b0000;
		end
		// Latch in the next state from the output from the combinatorial bits.
		else begin
			currentState <= nextState;
		end
		case(currentState)
			// Increment the shift counter during the shifting states
			ShiftState: shiftCounter <= (shiftCounter + 4'b0001);
			// Reset counter during end-of-cycle states.
			StartState, HaltState: shiftCounter <= 4'b0000;
		endcase
	end
	
	always_comb
	begin
		case(currentState)
			StartState: begin
				// Do nothing.
				ClearAX = 1'b0;
				ClearB = 1'b0;
				
				LoadAX = 1'b0;
				LoadB = 1'b0;
				
				Shift = 1'b0;
				Add = 1'b0;
				Sub = 1'b0;
				
				if (Run) nextState = BeginCycleState; // Begin cycle
				else if (ClearA_LoadB) nextState = ClearLoadState; // Begin clearing and loading
				else nextState = StartState; // Stay at Idle
			end
			
			ClearLoadState: begin
			
				// ClearAX and LoadB, that's it.
				ClearAX = 1'b1;
				ClearB = 1'b0;
				
				LoadAX = 1'b0;
				LoadB = 1'b1;
				
				Shift = 1'b0;
				Add = 1'b0;
				Sub = 1'b0;
				
				// Next state depends only on ClearA_LoadB.
				if (ClearA_LoadB) nextState = ClearLoadState;
				else nextState = StartState;
			end
			
			BeginCycleState: begin
			
				// ClearAX and that's it.
				ClearAX = 1'b1;
				ClearB = 1'b0;
				
				LoadAX = 1'b0;
				LoadB = 1'b0;
				
				Shift = 1'b0;
				Add = 1'b0;
				Sub = 1'b0;
				
				nextState = AddSubState;
			end
			
			ShiftState: begin
				ClearAX = 1'b0;
				ClearB = 1'b0;
				
				LoadAX = 1'b0;
				LoadB = 1'b0;
				
				Shift = 1'b1; // Just shift
				Add = 1'b0;
				Sub = 1'b0;
				
				// If the counter is at the "end", aka we've shifted eight times, halt.
				if(shiftCounter == 4'd7) nextState = HaltState;
				else nextState = AddSubState;
			end
				
			AddSubState: begin
				if(M == 1'b1) begin //If we should add (M = 1)
					ClearAX = 1'b0;
					ClearB = 1'b0;
					
					LoadAX = 1'b1;
					LoadB = 1'b0;
					
					Shift = 1'b0;
					if (shiftCounter == 4'd7) begin
						//subtract if we're on the last bit
						Add = 1'b0;
						Sub = 1'b1;
					end
					else begin
						//otherwise add
						Add = 1'b1;
						Sub = 1'b0;
					end
				end
				else begin
					ClearAX = 1'b0; //If we should just omit the add step (M = 0)
					ClearB = 1'b0;
					
					LoadAX = 1'b0;
					LoadB = 1'b0;
					
					Shift = 1'b0;
					Add = 1'b0;
					Sub = 1'b0;
				end
				
				nextState = ShiftState;
			end
			
			HaltState: begin
				// It's time to STOP
				ClearAX = 1'b0;
				ClearB = 1'b0;
				
				LoadAX = 1'b0;
				LoadB = 1'b0;
				
				Shift = 1'b0;
				Add = 1'b0;
				Sub = 1'b0;
				
				if(!Run) nextState = StartState;
				else nextState = HaltState;
			end
		endcase
	end

endmodule