transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4 {C:/Users/finnn/Documents/385/385_FPGA/Lab4/Synchronizers.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4 {C:/Users/finnn/Documents/385/385_FPGA/Lab4/Router.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4 {C:/Users/finnn/Documents/385/385_FPGA/Lab4/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4 {C:/Users/finnn/Documents/385/385_FPGA/Lab4/Control.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4 {C:/Users/finnn/Documents/385/385_FPGA/Lab4/compute.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4 {C:/Users/finnn/Documents/385/385_FPGA/Lab4/Reg_8.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4 {C:/Users/finnn/Documents/385/385_FPGA/Lab4/Register_unit.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4 {C:/Users/finnn/Documents/385/385_FPGA/Lab4/Processor.sv}

vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4 {C:/Users/finnn/Documents/385/385_FPGA/Lab4/testbench_8.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench_8

add wave *
view structure
view signals
run 1000 ns
