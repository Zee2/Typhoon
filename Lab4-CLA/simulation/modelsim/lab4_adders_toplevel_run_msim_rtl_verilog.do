transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA {C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA {C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA/carry_select_adder.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA {C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA/full_adder_pg.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA {C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA/CLA_4bit.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA {C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA/CSA_unit.sv}
vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA {C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA/lab4_adders_toplevel.sv}

vlog -sv -work work +incdir+C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA {C:/Users/finnn/Documents/385/385_FPGA/Lab4-CLA/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 1000 ns
