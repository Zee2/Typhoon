transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

#sorry finn, you're gonna have to rename these :P
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/Synchronizers.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/internal_register.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/registerFile.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/tristate.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/test_memory.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/SLC3_2.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/Mem2IO.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/ISDU.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/multiplexer.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/alu.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/memory_contents.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/NZPlogic.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/datapath.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/slc3.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/lab6_toplevel.sv}
vlog -sv -work work +incdir+C:/Users/kuilin/Desktop/385/385_FPGA/Lab6 {C:/Users/kuilin/Desktop/385/385_FPGA/Lab6/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave -noupdate /testbench/Clk
add wave -noupdate -radix decimal /testbench/S
add wave -noupdate /testbench/Reset
add wave -noupdate /testbench/Run
add wave -noupdate /testbench/Continue
add wave -noupdate /testbench/LED
add wave -noupdate /testbench/OE
add wave -noupdate /testbench/WE
add wave -noupdate /testbench/ADDR

add wave -noupdate {/testbench/tested/my_slc/d0/MDRregister/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/MARregister/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/PCregister/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/IRregister/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/conditionalLogic/NZPregister/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/conditionalLogic/BENregister/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/registers/internal_register_generate[0]/register/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/registers/internal_register_generate[1]/register/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/registers/internal_register_generate[2]/register/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/registers/internal_register_generate[3]/register/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/registers/internal_register_generate[4]/register/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/registers/internal_register_generate[5]/register/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/registers/internal_register_generate[6]/register/Q}
add wave -noupdate {/testbench/tested/my_slc/d0/registers/internal_register_generate[7]/register/Q}
add wave -noupdate {/testbench/tested/my_slc/state_controller/State}
add wave -noupdate {/testbench/tested/my_slc/state_controller/Next_state}
add wave -noupdate {/testbench/tested/my_slc/d0/Bus}
add wave -noupdate {/testbench/tested/my_slc/hex_4}

view structure
view signals
run 1ms
