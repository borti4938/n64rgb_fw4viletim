
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
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set n64_data_delay_min 2.0
set n64_data_delay_max 10.0

set_input_delay -clock {VCLK_N64_VIRT} -min $n64_data_delay_min [get_ports {nDSYNC D_i[*]}]
set_input_delay -clock {VCLK_N64_VIRT} -max $n64_data_delay_max [get_ports {nDSYNC D_i[*]}]


#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {nAutoDeBlur nForceDeBlur n15bit_mode}]
set_false_path -to [get_ports {R_o* G_o* B_o* nHSYNC nVSYNC nCSYNC nCLAMP}]


#**************************************************************
# Set Multicycle Path
#**************************************************************

set dbl_cycle_paths_from [list [get_ports {D_i[*]}] [get_registers {video_demux|*}] [get_registers {get_vinfo|*}] [get_registers {deblur_management|*}]]
set dbl_cycle_paths_to [list [get_registers {video_demux|*}] [get_registers {get_vinfo|*}] [get_registers {deblur_management|*}]]

foreach from_path $dbl_cycle_paths_from {
  foreach to_path $dbl_cycle_paths_to {
    if {!($from_path == "[get_registers {deblur_management|*}]" && $to_path == "[get_registers {get_vinfo|*}]")} {
      set_multicycle_path -from $from_path -to $to_path -setup 2
      set_multicycle_path -from $from_path -to $to_path -hold 1
    }
  }
}

# revert some multicycle paths to their default values
set_multicycle_path -from [get_registers {deblur_management|gradient_changes[*]}] -setup 1
set_multicycle_path -from [get_registers {deblur_management|gradient_changes[*]}] -hold 0
set_multicycle_path -from [get_registers {video_demux|vdata_r_0[*]}] -to [get_registers {video_demux|vdata_r_1[*]}] -setup 1
set_multicycle_path -from [get_registers {video_demux|vdata_r_0[*]}] -to [get_registers {video_demux|vdata_r_1[*]}] -hold 0


#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

