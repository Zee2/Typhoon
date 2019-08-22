onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /testbench/GPU/tiledRasterizer/geometry_data_out
add wave -noupdate -radix decimal /testbench/GPU/tiledRasterizer/geometry_addr_in
add wave -noupdate -radix decimal /testbench/GPU/tiledRasterizer/box
add wave -noupdate -radix decimal /testbench/GPU/tiledRasterizer/x0
add wave -noupdate -radix decimal /testbench/GPU/tiledRasterizer/y0
add wave -noupdate -radix decimal /testbench/GPU/tiledRasterizer/x1
add wave -noupdate -radix decimal /testbench/GPU/tiledRasterizer/y1
add wave -noupdate -radix decimal /testbench/GPU/tiledRasterizer/x2
add wave -noupdate -radix decimal /testbench/GPU/tiledRasterizer/y2
add wave -noupdate /testbench/GPU/tiledRasterizer/state
add wave -noupdate /testbench/GPU/tiledRasterizer/nextState
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {843962 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 331
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {277516 ps} {1112003 ps}
