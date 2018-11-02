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

module SRAM_controller(
	inout logic[15:0] SRAM_DQ,
	output logic[19:0] SRAM_ADDR,
	output logic SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,

	input logic[15:0] DataToSRAM[4],
	input logic[19:0] AddressToSRAM[4],
	input logic[3:0] QueueReadReq, QueueWriteReq,

	output logic DataReady[4],
	output logic[15:0] DataFromSRAM[4],

	input logic SRAM_CLK, //100 MHz SRAM clock, allow for "double data rate"
	input logic BOARD_CLK //50 MHz FPGA clock, for incoming requests
);






logic[3:0] FIFOread; // Internal signal for memory fetch loop to read from FIFOs
logic[3:0] FIFOvalid; // Does each FIFO have some data for us?
logic[15:0] FIFOdata[4];
logic[21:0] FIFOaddr[4];
logic[1:0] lastRoundRobin;
logic[1:0] roundRobin = 0; // Round robin counter 
logic[1:0] nextRoundRobin = 0;

logic lastOpRead = 0;
logic controllerIdle = 0;

assign SRAM_CE_N = 0; // Always chip-enable
assign SRAM_UB_N = 0; // Always writing both bytes
assign SRAM_LB_N = 0;

genvar i;
generate

	for(i = 0; i < 4; i++) begin: DATA_FIFO_generate
		SRAM_FIFO data_inputPort(
			.rdclk(SRAM_CLK),
			.wrclk(BOARD_CLK),
			.data({16'b0, DataToSRAM[i]}),
			.wrreq(QueueReadReq[i] || QueueWriteReq[i]),
			.rdreq(FIFOread[i]),
			.rdempty(~FIFOvalid[i]),
			.q(FIFOdata[i])
		);
	end


	// Encodes whether the request is a read or write in an extra two bits.
	for(i = 0; i < 4; i++) begin: ADDR_FIFO_generate
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


always_ff @(posedge SRAM_CLK) begin



	//At clock edge, read data from SRAM if last operation was a read
	if(lastOpRead && ~controllerIdle) begin
		DataFromSRAM[lastRoundRobin] <= SRAM_DQ;
		DataReady[lastRoundRobin] <= 1;
		FIFOread[lastRoundRobin] <= 0;
	end
	else begin
		DataReady[0] <= 0;
		DataReady[1] <= 0;
		DataReady[2] <= 0;
		DataReady[3] <= 0;
	end
	
	SRAM_ADDR <= FIFOaddr[roundRobin][19:0]; // Assert 20-bit address on SRAM, always
	if(FIFOaddr[roundRobin][21] == 1  && ~controllerIdle) begin // It's a read request
		FIFOread[roundRobin] <= 1;
		lastOpRead <= 1; // So we fetch data next clock
		SRAM_OE_N <= 0; // Bring OE low to read
		SRAM_WE_N <= 1;
	end
	else begin
		if(~controllerIdle) begin
			lastOpRead <= 0; // This op was not a read, so don't read next clock
		FIFOread[roundRobin] <= 0;
		SRAM_DQ <= FIFOdata[roundRobin][15:0]; // Assert FIFO data on SRAM bus
		SRAM_OE_N <= 1;
		SRAM_WE_N <= 0; // Bring WE low to write
		end
	end

	lastRoundRobin <= roundRobin;
	if(~controllerIdle) begin
		roundRobin <= nextRoundRobin; // nextRoundRobin should indicate valid FIFO
	end
end


// Intelligent round-robin queueing. Cascades to the next non-empty FIFO
// if the immediately adjacent FIFO is empty. 

always_comb begin

	if(FIFOvalid[roundRobin+1] == 1) begin
		nextRoundRobin = roundRobin + 2'd1;
		controllerIdle = 0;
	end
	else begin
		if(FIFOvalid[roundRobin+2] == 1) begin
			nextRoundRobin = roundRobin + 2'd2;
			controllerIdle = 0;
		end
		else begin
			if(FIFOvalid[roundRobin+3] == 1) begin
				nextRoundRobin = roundRobin + 2'd3;
				controllerIdle = 0;
			end
			else begin
				controllerIdle = 1;
				nextRoundRobin = roundRobin;
				// All next ports are empty, just idle
			end
		end
	end

end
endmodule