transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab5 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab5/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab5 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab5/adder_9.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab5 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab5/Reg_8.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab5 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab5/full_adder.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab5 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab5/control.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab5 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab5/multiplier_toplevel.sv}

vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab5 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab5/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 1000 ns
