module Typhoon(
	inout logic[15:0] SRAM_DQ,
	output logic[19:0] SRAM_ADDR,
	output logic SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
	input logic Clk
	
);


	// Various specced system clocks

	logic SRAM_CLK, VGA_CLK, SDRAM_CLK;

	// VGA timing signals
	
	logic VGA_reset, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	
	// VGA x-y scan coords, used for framebuffer polling
	
	logic[9:0] VGA_SCAN_X, VGA_SCAN_Y;

	SysPLL systemPLL(.inclk0(Clk), .c0(SRAM_CLK), .c1(VGA_CLK), .c2(SDRAM_CLK));
	
	
	VGA_controller VGAtiming(.Reset(VGA_reset), .DrawX(VGA_SCAN_X), .DrawY(VGA_SCAN_Y), .*);
	
	SRAM_controller SRAM();

endmodule