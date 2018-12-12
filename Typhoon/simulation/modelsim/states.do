onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/GPU/doneStreaming
add wave -noupdate /testbench/GPU/doneRasterizing
add wave -noupdate /testbench/GPU/SRAM/idle
add wave -noupdate /testbench/GPU/SRAM/nextIdle
add wave -noupdate /testbench/GPU/SRAM/state
add wave -noupdate /testbench/GPU/SRAM/nextState
add wave -noupdate /testbench/GPU/state
add wave -noupdate /testbench/GPU/nextState
add wave -noupdate /testbench/GPU/tiledRasterizer/state
add wave -noupdate /testbench/GPU/tiledRasterizer/nextState
add wave -noupdate {/testbench/GPU/tiledRasterizer/shaderLoopY[0]/shaderLoopX[0]/shader/state}
add wave -noupdate {/testbench/GPU/tiledRasterizer/shaderLoopY[0]/shaderLoopX[0]/shader/nextState}
add wave -noupdate /testbench/GPU/streamTileTrigger
add wave -noupdate /testbench/GPU/nextStreamTileTrigger
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2077317 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 327
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
WaveRestoreZoom {0 ps} {26837595 ps}
