#compile all the stuffs
vlog -sv -work work {./../../HexDriver.sv}
vlog -sv -work work {./../../adder_9.sv}
vlog -sv -work work {./../../Reg_8.sv}
vlog -sv -work work {./../../full_adder.sv}
vlog -sv -work work {./../../control.sv}
vlog -sv -work work {./../../multiplier_toplevel.sv}
vlog -sv -work work {./../../testbench.sv}

#run the simulator on testbench
vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc" testbench

#show the stuff
view structure
view signals

#make the waves
add wave Clk
add wave Reset
add wave Run
add wave ClearA_LoadB
add wave X
add wave Switches
radix signal Switches decimal
add wave Aval
radix signal Aval decimal
add wave Bval
radix signal Bval decimal

#run the thingie
run 1000 ns

#zoom out to save our sanity
wave zoom full
