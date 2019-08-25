set design_root <Design path>
set_attribute library {/tools/TSMC/45/ts45nkksdst_ff.lib}

set DESIGN csi2tx_mipi_top

# Read the RTL files

read_hdl -v2001 $design_root/rtl/ahb_interface/csi2tx_ahb_slave_iface_top.v          
read_hdl -v2001 $design_root/rtl/ahb_interface/csi2tx_ahb_slave_iface.v          
read_hdl -v2001 $design_root/rtl/ahb_interface/csi2tx_register_iface.v          
read_hdl -v2001 $design_root/rtl/clock_lane_ctrl/csi2tx_clock_lane_ctrl.v          
read_hdl -v2001 $design_root/rtl/clock_synchronizers/csi2tx_double_flop_sync.v          
read_hdl -v2001 $design_root/rtl/clock_synchronizers/csi2tx_sync_module.v          
read_hdl -v2001 $design_root/rtl/clock_synchronizers/csi2tx_sync_pulse.v          
read_hdl -v2001 $design_root/rtl/clock_synchronizers/csi2tx_mux_based_sync.v 
read_hdl -v2001 $design_root/rtl/lane_management_layer/csi2tx_lane_distribution_top.v
read_hdl -v2001 $design_root/rtl/lane_management_layer/csi2tx_one_lane_ldl.v
read_hdl -v2001 $design_root/rtl/lane_management_layer/csi2tx_two_lane_ldl.v
read_hdl -v2001 $design_root/rtl/lane_management_layer/csi2tx_three_lane_ldl.v
read_hdl -v2001 $design_root/rtl/lane_management_layer/csi2tx_four_lane_ldl.v
read_hdl -v2001 $design_root/rtl/lane_management_layer/csi2tx_five_lane_ldl.v               
read_hdl -v2001 $design_root/rtl/lane_management_layer/csi2tx_six_lane_ldl.v
read_hdl -v2001 $design_root/rtl/lane_management_layer/csi2tx_seven_lane_ldl.v
read_hdl -v2001 $design_root/rtl/lane_management_layer/csi2tx_eight_lane_ldl.v
read_hdl -v2001 $design_root/rtl/low_level_protocol/csi2tx_crc16_d64.v  
read_hdl -v2001 $design_root/rtl/low_level_protocol/csi2tx_ecc_24.v  
read_hdl -v2001 $design_root/rtl/low_level_protocol/csi2tx_packet_interface.v
read_hdl -v2001 $design_root/rtl/low_level_protocol/csi2tx_sync_reg_buffer.v    
read_hdl -v2001 $design_root/rtl/low_level_protocol/csi2tx_llp_top.v 
read_hdl -v2001 $design_root/rtl/packet_reader/csi2tx_packet_rdr.v          
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_compressor.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_decoder.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_encoder.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_lyuv4208b_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_packet_aligner.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_pixel2byte_iface_top.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_predictor.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_raw6_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_raw7_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_raw8_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_raw10_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_raw12_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_raw14_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_rgb565_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_rgb666_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_rgb888_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_yuv420_10b_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_yuv422_10b_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_yuv4208b_p2b.v      
read_hdl -v2001 $design_root/rtl/pixel2byte/csi2tx_yuv4228b_p2b.v      
read_hdl -v2001 $design_root/rtl/sensor_iface/csi2tx_sensor_iface.v      
read_hdl -v2001 $design_root/rtl/top/csi2tx.v      
read_hdl -v2001 $design_root/rtl/top/csi2tx_defines.v      
read_hdl -v2001 $design_root/rtl/top/csi2tx_mipi_top.v      
read_hdl -v2001 $design_root/rtl/top/csi2tx_reset_sync.v      
read_hdl -v2001 $design_root/rtl/top/csi2tx_sensor_fifo_ctrl.v      

elaborate $DESIGN


read_sdc synthesis_script.sdc


check_design -unresolved


report timing -lint > ../report/lint_report.rpt 


#*Synthesizing to generic 
synthesize -to_generic -eff medium 

#*Synthesizing to gates
synthesize -to_mapped -eff medium -no_incr

report clock        > ../report/csi2tx_mipi_top_clock.rpt
report area         > ../report/csi2tx_mipi_top_area.rpt
report power        > ../report/csi2tx_mipi_top_power.rpt
report gates        > ../report/csi2tx_mipi_top_gates.rpt
write_hdl -m        > ../report/csi2tx_mipi_top_m.v

report timing > ../report/timing.rpt
write -m  >  ${DESIGN}.mapped.v

write_sdc >  ${DESIGN}.sdc
