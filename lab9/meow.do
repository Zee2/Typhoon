transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlib lab7_soc
vmap lab7_soc lab7_soc
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/lab9 {C:/Users/kuilin/Desktop/385/385_FPGA/lab9/SubBytes.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/lab9 {C:/Users/kuilin/Desktop/385/385_FPGA/lab9/lab9_top.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/lab9 {C:/Users/kuilin/Desktop/385/385_FPGA/lab9/KeyExpansion.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/lab9 {C:/Users/kuilin/Desktop/385/385_FPGA/lab9/InvShiftRows.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/lab9 {C:/Users/kuilin/Desktop/385/385_FPGA/lab9/InvMixColumns.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/lab9 {C:/Users/kuilin/Desktop/385/385_FPGA/lab9/hexdriver.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/lab9 {C:/Users/kuilin/Desktop/385/385_FPGA/lab9/AES.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/lab9 {C:/Users/kuilin/Desktop/385/385_FPGA/lab9/testbench.sv}

