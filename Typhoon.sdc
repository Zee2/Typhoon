#derive_pll_clocks

# Create Clocks
create_clock -name {BOARD_CLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports {BOARD_CLK}]

#create_generated_clock -name {sram} -source [get_pins {myTest|altpll_component|auto_generated|wire_pll1_inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {BOARD_CLK} [get_pins {myTest|altpll_component|auto_generated|wire_pll1_clk[0]}]
#create_generated_clock -source {myTest|altpll_component|auto_generated|pll1|inclk[0]} -multiply_by 8 -divide_by 5 -duty_cycle 50.00 -name {sram} {myTest|altpll_component|auto_generated|pll1|clk[0]}
set_output_delay -clock {BOARD_CLK} -max 3 [all_outputs]
set_output_delay -clock {BOARD_CLK} -min 2 [all_outputs]
# Constrain the input I/O path
set_input_delay -clock {BOARD_CLK} -max 3 [all_inputs]
set_input_delay -clock {BOARD_CLK} -min 2 [all_inputs]

set_input_delay -clock {BOARD_CLK} -max 3 [all_outputs]
set_input_delay -clock {BOARD_CLK} -min 2 [all_outputs]

#set_input_delay -max -clock [get_clocks {sram}]  3.000 [get_ports {SRAM_DQ*}]
#set_input_delay -min -clock [get_clocks {sram}]  2.000 [get_ports {SRAM_DQ*}]

#set_output_delay -max -clock [get_clocks {sram}]  3.000 [get_ports {SRAM_ADDR*}]
#set_output_delay -min -clock [get_clocks {sram}]  2.000 [get_ports {SRAM_ADDR*}]
# Constrain the output I/O path


set_false_path -from * -to [get_ports LEDG*]
set_false_path -from * -to [get_ports LEDR*]
set_false_path -from * -to [get_ports SW*]
set_false_path -from * -to [get_ports HEX*]


set_false_path -from * -to [get_ports VGA_R*]
set_false_path -from * -to [get_ports VGA_G*]
set_false_path -from * -to [get_ports VGA_B*]
set_false_path -from * -to [get_ports VGA_CLK*]
set_false_path -from * -to [get_ports VGA_HS]
set_false_path -from * -to [get_ports VGA_VS]