
#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3


#**************************************************************
# Create Clock
#**************************************************************

set n64_vclk_per 20.000
set n64_vclk_waveform [list 0.000 [expr $n64_vclk_per*3/5]]

create_clock -name {VCLK_N64_VIRT} -period $n64_vclk_per -waveform $n64_vclk_waveform
create_clock -name {VCLK} -period $n64_vclk_per -waveform $n64_vclk_waveform [get_ports { VCLK }]


#**************************************************************
# Set Input Delay
#**************************************************************

set data_delay_min 2.0
set data_delay_max 8.0
set data_delay_margin 0.2
set input_delay_min [expr $data_delay_min - $data_delay_margin]
set input_delay_max [expr $data_delay_max + $data_delay_margin]

set_input_delay -clock {VCLK_N64_VIRT} -min $input_delay_min [get_ports {nDSYNC D_i[*]}]
set_input_delay -clock {VCLK_N64_VIRT} -max $input_delay_max [get_ports {nDSYNC D_i[*]}]


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {nAutoPad nManualPad}]
set_false_path -to [get_ports {R_o* G_o* B_o* nHSYNC nVSYNC nCSYNC nCLAMP}]
