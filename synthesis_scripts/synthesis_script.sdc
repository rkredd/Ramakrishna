create_clock sysclk -period 10 -waveform {0 5 }
set_dont_touch_network  [get_clocks sysclk] 

create_clock sensor_clk -period 1.333 -waveform {0 0.666 }
set_dont_touch_network  [ get_clocks sensor_clk] 

create_clock txbyteclkhs -period 3.571 -waveform {0 1.785 }
set_dont_touch_network  [ get_clocks txbyteclkhs] 

create_clock txclkesc -period 50 -waveform {0 25 }
set_dont_touch_network  [ get_clocks txclkesc] 


################### sysclk ###################
set sysclk_inputs  [ list test_mode hwrite hsel haddr hsize hburst htrans hwdata hready_in]
set_input_delay 1.65 -clock sysclk [ get_ports $sysclk_inputs ]

set sysclk_outputs [ list hrdata hresp hready afe_trim_0 afe_trim_1 afe_trim_2 afe_trim_3 dfe_dln_reg_0 dfe_dln_reg_1 dfe_cln_reg_0 dfe_cln_reg_1 pll_cnt_reg dfe_dln_lane_swap]
set_output_delay 1.65 -clock sysclk [ get_ports $sysclk_outputs ]

################### sensor_clk ###################
set sensor_clk_inputs  [ list frame_start frame_end line_start line_end packet_header_valid virtual_channel data_type word_count pixel_data_valid pixel_data]
set_input_delay 0.21 -clock sensor_clk [ get_ports $sensor_clk_inputs ]

set sensor_clk_outputs [ list packet_header_accept pixel_data_accept cena_n_sensor_fifo wena_n_sensor_fifo wr_addr_sensor_fifo  wr_data_sensor_fifo]
set_output_delay 0.21 -clock sensor_clk [ get_ports $sensor_clk_outputs ]

################### txbyteclkhs ###################
set txbyteclkhs_inputs  [ list txreadyhs rd_data_sensor_fifo]
set_input_delay 0.6 -clock txbyteclkhs [ get_ports $txbyteclkhs_inputs ]

set txbyteclkhs_outputs  [ list txrequesths_clk txrequesths txdatahs txskewcalhs rd_addr_sensor_fifo cenb_n_sensor_fifo wenb_n_sensor_fifo]
set_output_delay 0.6 -clock txbyteclkhs [ get_ports $txbyteclkhs_outputs ]

################### txclkesc ###################
set txclkesc_inputs  [ list ulpsactivenot_clk_n ulpsactivenot_n ]
set_input_delay 8.25 -clock txclkesc [ get_ports $txclkesc_inputs ]

set txclkesc_outputs [ list txulpsesc_entry txulpsesc_entry_clk txulpsesc_exit txulpsesc_exit_clk txrequestesc]
set_output_delay 8.25 -clock txclkesc [ get_ports $txclkesc_outputs ]



set_false_path -from [get_clocks txbyteclkhs]   -to [get_clocks [ list sysclk sensor_clk txclkesc]]
set_false_path -from [get_clocks txclkesc]      -to [get_clocks [ list txbyteclkhs sysclk sensor_clk]]
set_false_path -from [get_clocks sensor_clk]    -to [get_clocks [ list txbyteclkhs sysclk txclkesc]]
set_false_path -from [get_clocks sysclk]	-to [get_clocks [ list txbyteclkhs sensor_clk txclkesc]]

#Synthesizing to generic 
synthesize -to_generic -eff high

#Synthesizing to gates
synthesize -to_mapped -eff high -no_incr csi2tx_mipi_top
synthesize -to_mapped -eff high -incr csi2tx_mipi_top

#Setting constraints on the reset pin
set_dont_touch_network [get_ports pwr_on_rst_n]


