onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /decoder_tb/a
add wave -noupdate -radix binary /decoder_tb/b
add wave -noupdate -radix binary /decoder_tb/sel
add wave -noupdate /decoder_tb/c_in
add wave -noupdate -radix binary /decoder_tb/seg
add wave -noupdate -radix binary /decoder_tb/an
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {11 ns}
