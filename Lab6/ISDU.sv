//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic[3:0]    Opcode, 
				input logic         IR_5,
				input logic         IR_11,
				input logic         BEN,
				  
				output logic        LD_MAR,
									LD_MDR,
									LD_IR,
									LD_BEN,
									LD_CC,
									LD_REG,
									LD_PC,
									LD_LED, // for PAUSE instruction
									
				output logic        GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
									
				output logic [1:0]  PCMUX,
				output logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
				output logic [1:0]  ADDR2MUX,
									ALUK,
				  
				output logic        Mem_CE,
									Mem_UB,
									Mem_LB,
									Mem_OE,
									Mem_WE
				);

	enum logic [4:0] {  
						Halted, 
						PauseIR1, 
						PauseIR2, 
						S_18,		//MAR <- PC, PC++
						S_33_1, 	//MDR <- M
						S_33_2, 
						S_35, 	//IR <- MDR
						S_32, 	//BEN <- Stuff
						S_01,		//ADD
						S_05, 	//AND
						S_09, 	//NOT
						S_06, 	//LDR MAR<-B+off6
						S_25_1, 	//    MDR<-M[MAR]
						S_25_2,  //    Wait for R
						S_27, 	//    DR<-MDR, setCC
						S_07, 	//STR MAR<-B+off6
						S_23,		//    MDR<-SR
						S_16_1, 	//    M[MAR]<-MDR
						S_16_2, 	//    Wait for R
						S_04,		//JSR R7<-PC
						S_21, 	//    PC<-PC+off11
						S_12, 	//JMP
						S_00, 	//BR	set BEN
						S_22	 	//    PC<-PC+off9
						}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		LD_MAR = 1'b0;
		LD_MDR = 1'b0;
		LD_IR = 1'b0;
		LD_BEN = 1'b0;
		LD_CC = 1'b0;
		LD_REG = 1'b0;
		LD_PC = 1'b0;
		LD_LED = 1'b0;
		 
		GatePC = 1'b0;
		GateMDR = 1'b0;
		GateALU = 1'b0;
		GateMARMUX = 1'b0;
		 
		ALUK = 2'b00;
		 
		PCMUX = 2'b00;
		DRMUX = 1'b0;
		SR1MUX = 1'b0;
		SR2MUX = 1'b0;
		ADDR1MUX = 1'b0;
		ADDR2MUX = 2'b00;
		 
		Mem_OE = 1'b1;
		Mem_WE = 1'b1;
	
		// Assign next state
		unique case (State)
			Halted : 
				if (Run) 
					Next_state = S_18;                      
			S_18 : 
				Next_state = S_33_1;
			// Any states involving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			S_33_1 : 
				Next_state = S_33_2;
			S_33_2 : 
				Next_state = S_35;
			S_35 : 
				Next_state = S_32;
			PauseIR1 : 
				if (~Continue) 
					Next_state = PauseIR1;
				else 
					Next_state = PauseIR2;
			PauseIR2 : 
				if (Continue) 
					Next_state = PauseIR2;
				else 
					Next_state = S_18;
			S_32 : 
				case (Opcode)
					4'b0001 : //ADD
						Next_state = S_01;
					4'b0101 : //AND
						Next_state = S_05;
					4'b1001 : //NOT
						Next_state = S_09;
					4'b0000 : //BR
						Next_state = S_00;
					4'b1100 : //JMP
						Next_state = S_12;
					4'b0100 : //JSR
						Next_state = S_04;
					4'b0110 : //LDR
						Next_state = S_06;
					4'b0111 : //STR
						Next_state = S_07;
					4'b1101 : //PAWS
						Next_state = PauseIR1;
					default :
						//throw new Exception("Illegal instruction (core dumped)");
						Next_state = Halted;
				endcase
			
			S_01, S_05, S_09, S_27, S_16_2, S_21, S_12, S_22:
				Next_state = S_18;
			S_06: 
				Next_state = S_25_1;
			S_25_1:
				Next_state = S_25_2;
			S_25_2:
				Next_state = S_27;
			S_07:
				Next_state = S_23;
			S_23:
				Next_state = S_16_1;
			S_16_1:
				Next_state = S_16_2;
			S_04:
				Next_state = S_21;
			S_00:
				Next_state = BEN ? S_18 : S_22;
			
			default : 
				Next_state = Halted; //to easily spot errors in sim
			
		endcase
		
		// Assign control signals based on current state
		case (State)
			Halted: ;
			S_18 : 
				begin 
					GatePC = 1'b1;
					LD_MAR = 1'b1;
					PCMUX = 2'b00;
					LD_PC = 1'b1;
				end
			S_33_1, S_25_1: //FETCH and LDR's MDR<-M[MAR]
				Mem_OE = 1'b0;
			S_33_2, S_25_2: //FETCH and LDR's MDR<-M[MAR]
				begin 
					Mem_OE = 1'b0;
					LD_MDR = 1'b1;
				end
			S_35 : 
				begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
				end
			PauseIR1, PauseIR2: 
				begin
					LD_LED = 1'b1;
				end
			S_32 : 
				LD_BEN = 1'b1;
			S_01, S_05, S_09: //ADD, AND, NOT
				begin 
					SR2MUX = IR_5;
					unique case(State) 
						S_01: ALUK = 2'b00; //ADD
						S_05: ALUK = 2'b01; //AND
						S_09: ALUK = 2'b10; //NOT
					endcase
					
					GateALU = 1'b1;
					LD_REG = 1'b1;
					
					DRMUX = 1'b0;  //IR[11:9]
					SR1MUX = 1'b1; //IR[8:6]
					LD_CC = 1'b1;
				end
			S_06, S_07: //LDR and STR's MAR <- B+off6
				begin
					SR1MUX = 1'b1;   //IR[8:6]
					ADDR1MUX = 1'b1; //BaseR
					ADDR2MUX = 2'b01; //off6
					
					GateMARMUX = 1'b1;
					LD_MAR = 1'b1;
				end
			S_27: //LDR DR<-MDR, setCC
				begin
					DRMUX = 1'b0; //IR[11:9]
					LD_REG = 1'b1;
					
					GateMDR = 1'b1;
					LD_CC = 1'b1;
				end
			S_23: //STR MDR<-SR
				begin
					LD_MDR = 1'b1;
					//SR1 needs to passthru ALU
					GateALU = 1'b1;
					
					ALUK = 2'b11; //PassA
					SR1MUX = 1'b0; //IR[11:9]
				end
			S_16_1, S_16_2: //STR M[MAR]<-MDR and wait
				begin
					Mem_WE = 1'b0;
				end
			S_04: //JSR R7<-PC
				begin
					GatePC = 1'b1;
					DRMUX = 1'b1; //literal 111 for R7
					LD_REG = 1'b1;
				end
			S_21: //JSR PC<-PC+off11
				begin
					ADDR1MUX = 1'b0; //PC
					ADDR2MUX = 2'b11; //off11
					PCMUX = 2'b10; //adder into PC
					LD_PC = 1'b1;
				end
			S_12: //JMP PC<-BaseR
				begin
					PCMUX = 2'b01; //bus into PC
					LD_PC = 1'b1;
					//SR1 needs to passthru ALU
					GateALU = 1'b1;
					
					ALUK = 2'b11; //PassA
					SR1MUX = 1'b1; //IR[8:6]
				end
			S_00: ; //test BEN, do nothing 
			S_22: //BR PC <- PC+off9
				begin
					PCMUX = 2'b10; //adder into PC
					LD_PC = 1'b1;
					ADDR1MUX = 1'b0; //PC
					ADDR2MUX = 2'b10; //off9
				end
			default : ;
		endcase
	end 

	 // These should always be active
	assign Mem_CE = 1'b0;
	assign Mem_UB = 1'b0;
	assign Mem_LB = 1'b0;
	
endmodule
