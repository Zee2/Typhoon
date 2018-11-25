transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/finnnorth/Documents/385/385_FPGA/Typhoon {C:/Users/finnnorth/Documents/385/385_FPGA/Typhoon/SRAM_FIFO.v}
vlog -sv -work work +incdir+C:/Users/finnnorth/Documents/385/385_FPGA/Typhoon {C:/Users/finnnorth/Documents/385/385_FPGA/Typhoon/VGA_controller.sv}
vlog -sv -work work +incdir+C:/Users/finnnorth/Documents/385/385_FPGA/Typhoon {C:/Users/finnnorth/Documents/385/385_FPGA/Typhoon/SRAM_controller.sv}
vlog -sv -work work +incdir+C:/Users/finnnorth/Documents/385/385_FPGA/Typhoon {C:/Users/finnnorth/Documents/385/385_FPGA/Typhoon/Typhoon.sv}

vlog -sv -work work +incdir+C:/Users/finnnorth/Documents/385/385_FPGA/Typhoon {C:/Users/finnnorth/Documents/385/385_FPGA/Typhoon/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 1 ms
