onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /testbench/GPU/transform_core/inputMemoryAddress
add wave -noupdate -radix unsigned /testbench/GPU/transform_core/binMemoryAddress
add wave -noupdate /testbench/GPU/transform_core/box
add wave -noupdate /testbench/GPU/transform_core/minXbin
add wave -noupdate /testbench/GPU/transform_core/minYbin
add wave -noupdate /testbench/GPU/transform_core/maxXbin
add wave -noupdate /testbench/GPU/transform_core/maxYbin
add wave -noupdate /testbench/GPU/transform_core/curBinX
add wave -noupdate /testbench/GPU/transform_core/curBinY
add wave -noupdate /testbench/GPU/transform_core/state
add wave -noupdate /testbench/GPU/transform_core/nextState
add wave -noupdate /testbench/GPU/state
add wave -noupdate /testbench/GPU/nextState
add wave -noupdate /testbench/GPU/tiledRasterizer/state
add wave -noupdate {/testbench/GPU/tiledRasterizer/shaderLoopY[0]/shaderLoopX[0]/shader/state}
add wave -noupdate /testbench/GPU/transform_core/listRegisters
add wave -noupdate /testbench/GPU/tiledRasterizer/tileOffsetX
add wave -noupdate /testbench/GPU/tiledRasterizer/tileOffsetY
add wave -noupdate /testbench/GPU/tiledRasterizer/nextPointer
add wave -noupdate /testbench/GPU/tiledRasterizer/binMemoryReadAddress
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {867095099 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 420
configure wave -valuecolwidth 269
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
WaveRestoreZoom {865772386 ps} {870093248 ps}
