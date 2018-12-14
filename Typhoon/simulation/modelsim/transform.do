onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/GPU/state
add wave -noupdate /testbench/GPU/nextState
add wave -noupdate /testbench/GPU/transform_core/state
add wave -noupdate /testbench/GPU/transform_core/nextState
add wave -noupdate /testbench/GPU/tiledRasterizer/state
add wave -noupdate /testbench/GPU/tiledRasterizer/nextState
add wave -noupdate /testbench/GPU/startTransformTrigger
add wave -noupdate -radix decimal /testbench/GPU/transform_core/x0
add wave -noupdate -radix decimal /testbench/GPU/transform_core/z0
add wave -noupdate -radix decimal /testbench/GPU/transform_core/x0_out
add wave -noupdate -radix decimal -childformat {{{/testbench/GPU/transform_core/zdiv_result[0]} -radix decimal} {{/testbench/GPU/transform_core/zdiv_result[1]} -radix decimal} {{/testbench/GPU/transform_core/zdiv_result[2]} -radix decimal}} -expand -subitemconfig {{/testbench/GPU/transform_core/zdiv_result[0]} {-height 15 -radix decimal} {/testbench/GPU/transform_core/zdiv_result[1]} {-height 15 -radix decimal} {/testbench/GPU/transform_core/zdiv_result[2]} {-height 15 -radix decimal}} /testbench/GPU/transform_core/zdiv_result
add wave -noupdate -radix hexadecimal /testbench/GPU/transform_core/inputMemoryData
add wave -noupdate -radix hexadecimal /testbench/GPU/transform_core/inputMemoryAddress
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {92396 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 316
configure wave -valuecolwidth 230
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1886664 ps}
