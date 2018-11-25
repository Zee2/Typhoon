/*

	SRAM_controller.sv
	Finn Sinclair 2018

	Pipelined, dual-clock SRAM memory controller for high-speed applications.
	This is useful when you have an SRAM module clocked at a significantly higher
	clock speed than your main FPGA fabric. This allows for multiple low-speed modules
	to put memory requests (both reading and writing) into the FIFO ports of the memory
	controller, and then be notified when the information is available from that port.

	Each port is both read and write. The nature of the operation is stored in the FIFO
	next to the address bits. This saves on coding time for the customer module.

	This SRAM controller allows the system to take advantage of the faster memory clock.
	If the SRAM clock is twice the speed of the board clock, two board-clocked modules
	can perform memory operations effectively at the same time, as the SRAM controller
	can fulfill their requests twice as fast as they can give them.

	Customer modules should watch the appropriate active-high DataReady signal.

*/

module SRAM_controller #(parameter numInputPorts = 4)(
	inout wire[15:0] SRAM_DQ,
	output logic[19:0] SRAM_ADDR,
	output logic SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,

	input logic[15:0] DataToSRAM[numInputPorts],
	input logic[19:0] AddressToSRAM[numInputPorts],
	input logic [numInputPorts-1:0] QueueReadReq, QueueWriteReq,
	

	output logic [numInputPorts-1:0] DataReady = -1,
	output logic [15:0] DataFromSRAM[numInputPorts],

	input logic SRAM_CLK, //100 MHz SRAM clock, allow for "double data rate"
	input logic BOARD_CLK //50 MHz FPGA clock, for incoming requests
);

logic [numInputPorts-1:0]FIFOread = 0; // Internal signal for memory fetch loop to read from FIFOs
logic [numInputPorts-1:0]FIFOempty; // Does each FIFO have some data for us?
logic[15:0] FIFOdata[numInputPorts];
logic[21:0] FIFOaddr[numInputPorts];



logic[7:0] lastRoundRobin = 8'd0;
logic[7:0] roundRobin = 8'd1; // Round robin counter 
logic[7:0] nextRoundRobin = 8'd2;


logic[15:0] DQ_buffer; // tri-state buffer

logic lastOpRead = 0;
logic controllerIdle = 1;
logic controllerIdleNext;

assign SRAM_CE_N = 0; // Always chip-enable
assign SRAM_UB_N = 0; // Always writing both bytes
assign SRAM_LB_N = 0;

assign SRAM_OE_N = 0; // Hmmm...

genvar i;
generate

	for(i = 0; i < numInputPorts; i++) begin: DATA_FIFO_generate
		SRAM_FIFO data_inputPort(
			.rdclk(SRAM_CLK),
			.wrclk(BOARD_CLK),
			.data({16'b0, DataToSRAM[i]}),
			.wrreq(QueueReadReq[i] || QueueWriteReq[i]),
			.rdreq(FIFOread[i]),
			.rdempty(FIFOempty[i]),
			.q(FIFOdata[i])
		);
	end


	// Encodes whether the request is a read or write in an extra two bits.
	for(i = 0; i < numInputPorts; i++) begin: ADDR_FIFO_generate
		SRAM_FIFO addr_inputPort(
			.rdclk(SRAM_CLK),
			.wrclk(BOARD_CLK),
			.data({ 18'b0, QueueReadReq[i], QueueWriteReq[i], AddressToSRAM[i]}),
			.wrreq(QueueReadReq[i] || QueueWriteReq[i]),
			.rdreq(FIFOread[i]),
			.q(FIFOaddr[i])
		);
	end

endgenerate

assign SRAM_DQ = ~SRAM_WE_N ? DQ_buffer : 16'bz;


always_ff @(posedge SRAM_CLK) begin: mainblock
	
	// If some customer has queued a read or write, assert their dataReady signal low.
	for(integer i = 0; i < numInputPorts; i++) begin: readLoop
		if((QueueReadReq[i]) && DataReady[i] == 1) begin
			DataReady[i] <= 0;
		end

	end

	//Assert that the port we last touched is now done.
	

	//At clock edge, read data from SRAM if last operation was a read
	if(lastOpRead && ~controllerIdle) begin
		DataReady[lastRoundRobin] <= 1;
		DataFromSRAM[lastRoundRobin] <= SRAM_DQ; // Latch in output, but the port output has already had this data for 2ns
		
	end 
	
	SRAM_ADDR <= FIFOaddr[roundRobin][19:0]; // Assert 20-bit address on SRAM, always
	if(FIFOaddr[roundRobin][21] == 1  && ~controllerIdle) begin // It's a read request
		//FIFOread[roundRobin] <= 1;
		lastOpRead <= 1; // So we fetch data next clock

		
		//SRAM_OE_N <= 0; // Bring OE low to read, start 8ns countdown..!
		SRAM_WE_N <= 1;
	end
	else begin
		if(~controllerIdle) begin
			lastOpRead <= 0; // This op was not a read, so don't read next clock
			//FIFOread[roundRobin] <= 1;
			DQ_buffer <= FIFOdata[roundRobin][15:0]; // Assert FIFO data on SRAM bus
			//SRAM_OE_N <= 1;
			SRAM_WE_N <= 0; // Bring WE low to write
		end
	end

	FIFOread[roundRobin] <= 0;
	lastRoundRobin <= roundRobin;
	controllerIdle <= controllerIdleNext;
	roundRobin <= nextRoundRobin;
	if(controllerIdleNext == 0) begin
		 // nextRoundRobin should indicate valid FIFO
		FIFOread[nextRoundRobin] <= 1;
	end
	else begin 
		//SRAM_OE_N <= 1;
		SRAM_WE_N <= 1;

	end
end


// Intelligent round-robin queueing. Cascades to the next non-empty FIFO
// if the immediately adjacent FIFO is empty. 

always_comb begin
	
	
	for(int i = 1; i < numInputPorts+2; i++) begin
		if(i == numInputPorts+1) begin
			controllerIdleNext = 1;
			nextRoundRobin = roundRobin;
			break;
		end
		if(~FIFOempty[(roundRobin+i)%numInputPorts] == -1) begin
			nextRoundRobin = (roundRobin+i)%numInputPorts;
			controllerIdleNext = 0;
			break;
		end
	end
	
	
	/*
	if(~FIFOempty[roundRobin+2'b01] == -1) begin
		nextRoundRobin = roundRobin + 2'd1;
		controllerIdleNext = 0;
	end
	else begin
		if(~FIFOempty[roundRobin+2'b10] == -1) begin
			nextRoundRobin = roundRobin + 2'd2;
			controllerIdleNext = 0;
		end
		else begin
			if(~FIFOempty[roundRobin+2'b11] == -1) begin
				nextRoundRobin = roundRobin + 2'd3;
				controllerIdleNext = 0;
			end
			else begin
				if(~FIFOempty[roundRobin] == -1) begin
					nextRoundRobin = roundRobin;
					controllerIdleNext = 0;
				end
				else begin
					controllerIdleNext = 1;
					nextRoundRobin = roundRobin;
					// All next ports are empty, just idle
				end
				
			end
		end
	end
	*/

end
endmodule