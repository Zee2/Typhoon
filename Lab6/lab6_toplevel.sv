//-------------------------------------------------------------------------
//      lab6_toplevel.sv                                                 --
//                                                                       --
//      Created 10-19-2017 by Po-Han Huang                               --
//                        Spring 2018 Distribution                       --
//                                                                       --
//      For use with ECE 385 Experment 6                                 --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------
module lab6_toplevel( input logic [15:0] S,
                      input logic Clk, Reset, Run, Continue,
                      output logic [11:0] LED,
                      output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
                      output logic CE, UB, LB, OE, WE,
                      output logic [19:0] ADDR,
							 output logic[15:0] test,
							 input logic[18:0] test2,
                      inout wire [15:0] Data);

logic ResetSync, RunSync, ContinueSync; // Synchronizer signals

sync SwitchSync0(Clk, Reset, ResetSync);
sync SwitchSync1(Clk, Run, RunSync);
sync SwitchSync2(Clk, Continue, ContinueSync);

slc3 my_slc(.Reset(ResetSync), .Run(RunSync), .Continue(ContinueSync), .*);

// Even though test memory is instantiated here, it will be synthesized into 
// a blank module, and will not interfere with the actual SRAM.
// Test memory is to play the role of physical SRAM in simulation.
test_memory my_test_memory(.Reset(~ResetSync), .I_O(Data), .A(ADDR), .*);

endmodule