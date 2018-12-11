onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/BOARD_CLK
add wave -noupdate /testbench/GPU/tiledRasterizer/clearZ
add wave -noupdate /testbench/GPU/tiledRasterizer/nextClearZ
add wave -noupdate /testbench/GPU/tiledRasterizer/divideCounter
add wave -noupdate /testbench/GPU/tiledRasterizer/state
add wave -noupdate /testbench/GPU/tiledRasterizer/nextState
add wave -noupdate {/testbench/GPU/tiledRasterizer/shaderLoopY[0]/shaderLoopX[0]/shader/state}
add wave -noupdate {/testbench/GPU/tiledRasterizer/shaderLoopY[0]/shaderLoopX[0]/shader/nextState}
add wave -noupdate {/testbench/GPU/tiledRasterizer/shaderLoopY[0]/shaderLoopX[1]/shader/state}
add wave -noupdate {/testbench/GPU/tiledRasterizer/shaderLoopY[0]/shaderLoopX[1]/shader/nextState}
add wave -noupdate /testbench/GPU/tiledRasterizer/shadersDoneRasterizing
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {402061 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 347
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
WaveRestoreZoom {150891 ps} {845519 ps}
