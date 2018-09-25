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
	enum logic[4:0] {StartState, BeginCycleState, ShiftState, AddState, SubState, ClearingLoadingState, HaltState} currentState, nextState;
	
	always_ff @ (posedge Clk)
	begin
		if (Reset) begin
			currentState <= StartState;
			shiftCounter <= 4'b0000;
		end
		else begin
			currentState <= nextState;
			if(currentState == ShiftState)
				shiftCounter <= (shiftCounter + 4'b0001);
			if(currentState == HaltState)
				shiftCounter <= 4'b0000;
		end
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
				
				if (Run)
					nextState = BeginCycleState;
				else if(ClearA_LoadB)
					nextState = ClearingLoadingState; // ClearA_LoadB
				else
					nextState = currentState; // Stay at Idle
			end
					
			ClearingLoadingState: begin // Clear A, Load B.
				ClearAX = 1'b1;
				ClearB = 1'b0;
				
				LoadAX = 1'b0;
				LoadB = 1'b1;
				
				Shift = 1'b0;
				Add = 1'b0;
				Sub = 1'b0;
				nextState = StartState;
			end
			
			BeginCycleState: begin //Clears AX.
				ClearAX = 1'b1;
				ClearB = 1'b0;
				
				LoadAX = 1'b0;
				LoadB = 1'b0;
				
				Shift = 1'b0;
				Add = 1'b0;
				Sub = 1'b0;
				nextState = AddState;
			
			end
			
			ShiftState: begin
				
				ClearAX = 1'b0;
				ClearB = 1'b0;
				
				LoadAX = 1'b0;
				LoadB = 1'b0;
				
				Shift = 1'b1;
				Add = 1'b0;
				Sub = 1'b0;
				
				
				if(shiftCounter == 4'd6) begin
					nextState = SubState;
				end
				else if(shiftCounter == 4'd7) begin
					nextState = HaltState;
				end
				else
					
				
					nextState = AddState;
				
			
			end
				
			AddState: begin
				if(M == 1'b1) begin //If we should add (M = 1)
					ClearAX = 1'b0;
					ClearB = 1'b0;
					
					LoadAX = 1'b1;
					LoadB = 1'b0;
					
					Shift = 1'b0;
					Add = 1'b1;
					Sub = 1'b0;
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
				
			SubState: begin
				if(M == 1'b1) begin //If we should add (M = 1)
					ClearAX = 1'b0;
					ClearB = 1'b0;
					
					LoadAX = 1'b1;
					LoadB = 1'b0;
					
					Shift = 1'b0;
					Add = 1'b0;
					Sub = 1'b1;
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
				
				
				if(!Run)
					nextState = StartState;
				else
				
					nextState = currentState;
			end
			
			default:
				begin
				end
				
			
		endcase
				
	end


endmodule