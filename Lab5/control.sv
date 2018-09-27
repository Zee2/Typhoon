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
		currentState <= nextState;
		if (Reset) begin
			currentState <= StartState;
			shiftCounter <= 4'b0000;
		end
		case(currentState)
			ShiftState: shiftCounter <= (shiftCounter + 4'b0001);
			StartState, HaltState: shiftCounter <= 4'b0000;
		endcase
	end
	
	always_comb
	begin
		case(currentState)
			StartState: begin
				ClearAX = 1'b0;
				ClearB = 1'b0;
				
				LoadAX = 1'b0;
				LoadB = 1'b0;
				
				Shift = 1'b0;
				Add = 1'b0;
				Sub = 1'b0;
				
				if (Run) nextState = BeginCycleState;
				else if (ClearA_LoadB) nextState = ClearLoadState;
				else nextState = StartState; // Stay at Idle
			end
			
			ClearLoadState: begin
				ClearAX = 1'b1;
				ClearB = 1'b0;
				
				LoadAX = 1'b0;
				LoadB = 1'b1;
				
				Shift = 1'b0;
				Add = 1'b0;
				Sub = 1'b0;
				
				if (ClearA_LoadB) nextState = ClearLoadState;
				else nextState = StartState;
			end
			
			BeginCycleState: begin
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
				
				Shift = 1'b1;
				Add = 1'b0;
				Sub = 1'b0;
				
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