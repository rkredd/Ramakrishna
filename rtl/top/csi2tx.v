/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx.v
// Author      : SHYAM SUNDAR B. S
// Abstract    : 
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`include "csi2tx_defines.v"
module csi2tx
  (
  // Global Interface Signals
  input  wire        sysclk                    ,
  input  wire        sysclk_rst_n              ,
  input  wire        txbyteclkhs               ,
  input  wire        txbyteclkhs_rst_n         ,
  input  wire        clk_csi                   ,
  input  wire        clk_csi_rst_n             ,
  input  wire        txclkesc                  ,
  input  wire        txclkesc_rst_n            ,   
  // DPHY Interface signals
  input  wire        dfe_pll_locked            ,
  input  wire [7:0]  txreadyhs                 ,
  input  wire [7:0]  stopstate                 ,
  input  wire        ulpsactivenot_clk_n       ,
  input  wire [7:0]  ulpsactivenot_n           ,
  input  wire        stopstate_clk             ,
  output wire        txrequesths_clk           ,
  output wire [7:0]  txrequesths               ,
  output wire [63:0] txdatahs                  ,
  output wire [7:0]  txulpsesc_entry           ,
  output wire        txulpsesc_entry_clk       ,           
  output wire [7:0]  txulpsesc_exit            ,
  output wire        txulpsesc_exit_clk        ,
  output wire [7:0]  txrequestesc              ,   
  output wire [7:0]  txskewcalhs               , 
  // DPHY configuration interface signals
  output wire [31:0]  afe_trim_0               ,
  output wire [31:0]  afe_trim_1               ,
  output wire [31:0]  afe_trim_2               ,
  output wire [31:0]  afe_trim_3               ,
  output wire [31:0]  dfe_dln_reg_0            ,
  output wire [31:0]  dfe_dln_reg_1            ,
  output wire [31:0]  dfe_cln_reg_0            ,
  output wire [31:0]  dfe_cln_reg_1            ,
  output wire [15:0]  pll_cnt_reg              ,
  output wire [7:0]   dfe_dln_lane_swap        ,     
  // AHB Interface signals
  input  wire         hwrite                   ,
  input  wire         hsel                     ,
  input  wire         hready_in                ,
  input  wire [31:0]  haddr                    ,
  input  wire [2:0]   hsize                    ,
  input  wire [2:0]   hburst                   ,
  input  wire [1:0]   htrans                   ,
  input  wire [31:0]  hwdata                   ,
  output wire [31:0]  hrdata                   ,  
  output wire [1:0]   hresp                    ,
  output wire         hready                   ,      
  // Camera sensor Interface signals
  input  wire         frame_start              ,
  input  wire         frame_end                ,
  input  wire         line_start               ,
  input  wire         line_end                 ,
  input  wire         packet_header_valid      ,
  input  wire [1:0]   virtual_channel          ,
  input  wire [5:0]   data_type                ,
  input  wire [15:0]  word_count               ,
  input  wire         pixel_data_valid         ,
  input  wire [31:0]  pixel_data               ,
  output wire         packet_header_accept     ,
  output wire         pixel_data_accept        ,   
  // MIPI Control signals
  input  wire         forcetxstopmode          ,
  input  wire         txulpsesc                ,
  input  wire         txulpsexit               ,
  input  wire         dphy_clk_mode            ,
  input  wire         loopback_sel             , 
  input  wire         dphy_calib_ctrl          ,  
  //Camera Sensor Buffer
  input  wire [63:0]  rd_data_sensor_fifo      ,
  output wire         cena_n_sensor_fifo       ,
  output wire         wena_n_sensor_fifo       ,
  output wire [`SENSOR_FIFO_ADDR_WIDTH-1:0]  wr_addr_sensor_fifo      ,
  output wire [`SENSOR_FIFO_ADDR_WIDTH-1:0]  rd_addr_sensor_fifo      ,
  output wire [63:0]  wr_data_sensor_fifo      ,
  output wire         cenb_n_sensor_fifo       ,
  output wire         wenb_n_sensor_fifo       
);
//------------------------------------------------------------------------------
// Internal Signal Declaration
wire [31:0] header_info_w                                   ;
wire        header_info_valid_w                             ;
wire        image_data_valid_w                              ;
wire [31:0] image_data_w                                    ;
wire [31:0] image_data_delayed_w                            ;
wire        packet_incr_pulse_w                             ;
wire        sensor_pixel_vld_falling_edge_w                 ;
wire [4:0]  pixel_cnt_w                                     ;
wire [31:0] p2b_enable_w                                    ;
wire [4:0]  p2b_data_sel_w                                  ;
wire        lyuv4208b_odd_even_convrn_enable_w              ;
wire        yuv4208b_csps_odd_even_convrn_enable_w          ;
wire        yuv420_10b_csps_odd_even_convrn_enable_w        ;
wire        yuv4208b_odd_even_convrn_enable_w               ;
wire        yuv420_10b_odd_even_convrn_enable_w             ;
wire        comp_en_w                                       ;
wire        packet_rdy_w                                    ;
wire        packet_data_rdy_w                               ;
wire        packet_valid_w                                  ;
wire [5:0]  packet_dt_w                                     ;
wire [1:0]  packet_vc_w                                     ;
wire [15:0] packet_wc_df_w                                  ;
wire        packet_data_valid_w                             ;
wire [63:0] packet_data_w                                   ;
wire [4:0]  comp_scheme_w                                   ;
wire [39:0] vc0_compression_reg_w                           ;
wire [39:0] vc1_compression_reg_w                           ;
wire [39:0] vc2_compression_reg_w                           ;
wire [39:0] vc3_compression_reg_w                           ;
wire [2:0]  lane_config_sysclk_byteclk_w                    ;
wire        txrequestesc_byteclk_w                          ;
wire        txulpsesc_entry_byteclk_w                       ;
wire        txulpsesc_exit_byteclk_w                        ;
wire [2:0]  lane_config_sysclk_w                            ;
wire [63:0] csi_byte_fifo_rddata_w                          ;
wire        csi_byte_fifo_rden_w                            ;
wire        lane_config_wren_sysclk_w                       ;
wire        forcetxstopmode_clk_csi_w                       ;
wire        tinit_start_txclkesc_byteclk_dm_w               ;
wire        tinit_start_txclkesc_clk_csi_dm_w               ;
wire        sensor_fifo_almost_full_w                       ;
wire        pixel_data64_valid_w                            ;
wire        sensor_fifo_rd_enable_w                         ;
wire        sensor_fifo_empty_w                             ;
wire        sensor_fifo_full_w                              ;
wire        packet_incr_pulse_w_clk_csi_byteclk_w           ;
wire        packet_incr_pulse_byteclk_clk_csi_w             ;
wire        csi_byte_fifo_rd_empty_dm_w                     ;
wire        csi_byte_fifo_rd_empty_sysclk_w                 ;
wire        csi_byte_fifo_rd_full_dm_w                      ;
wire        csi_byte_fifo_rd_full_sysclk_w                  ;
wire        csi_byte_fifo_rd_almost_full_dm_w               ;
wire        csi_byte_fifo_rd_almost_full_sysclk_w           ;
wire        txready_hs_byteclk_pulse_w                      ; 
wire        forcetxstopmode_byteclk_w                       ;
wire        enable_hs_transmission_w                        ;
wire        stopstate_dl_txclkesc_byteclk_w                 ;
wire        dphy_clk_mode_byteclk_w                         ;
wire        txulpsesc_async_byteclk_w                       ;
wire        txulpsexit_async_byteclk_w                      ;
wire        stopstate_clk_txclkesc_byteclk_w                ;
wire        txulpsesc_entry_clk_byteclk_w                   ;
wire        txulpsesc_exit_clk_byteclk_w                    ;
wire  [7:0] data_lane_enabled_w                             ;
wire        sensor_fifo_empty_byteclk_sysclk_w              ;
wire        sensor_fifo_full_clk_csi_sysclk_w               ;
wire        ulpsactivenot_txclkesc_txbyteclkhs_w            ;
wire        dphy_calib_ctrl_byteclk_w                       ;



//------------------------------------------------------------------------------
// Camera sensor component instantiation
csi2tx_sensor_iface
 u_csi2tx_sensor_iface
(
 .clk_csi                                       ( clk_csi                                       ),
 .clk_csi_rst_n                                 ( clk_csi_rst_n                                 ),
 .forcetxstopmode                               ( forcetxstopmode_clk_csi_w                     ),
 .tinit_start_csi_clk                           ( tinit_start_txclkesc_clk_csi_dm_w             ),
 .fifo_almost_full                              ( sensor_fifo_almost_full_w                     ),
 .frame_start                                   ( frame_start                                   ),
 .frame_end                                     ( frame_end                                     ),
 .line_start                                    ( line_start                                    ),
 .line_end                                      ( line_end                                      ),
 .pixel_data                                    ( pixel_data                                    ),
 .pixel_data_valid                              ( pixel_data_valid                              ),
 .packet_header                                 ( data_type                                     ),
 .packet_header_valid                           ( packet_header_valid                           ),
 .word_count                                    ( word_count                                    ),
 .virtual_channel                               ( virtual_channel                               ),
 .pixel_data_accept                             ( pixel_data_accept                             ),
 .pixel_header_accept                           ( packet_header_accept                          ),
 .vc0_compression_reg                           ( vc0_compression_reg_w                         ),
 .vc1_compression_reg                           ( vc1_compression_reg_w                         ),
 .vc2_compression_reg                           ( vc2_compression_reg_w                         ),
 .vc3_compression_reg                           ( vc3_compression_reg_w                         ),
 .header_info                                   ( header_info_w                                 ),
 .header_info_valid                             ( header_info_valid_w                           ),
 .image_data_valid                              ( image_data_valid_w                            ),
 .image_data                                    ( image_data_w                                  ),
 .image_data_delayed                            ( image_data_delayed_w                          ),
 .sensor_pixel_vld_falling_edge                 ( sensor_pixel_vld_falling_edge_w               ),
 .pixel_cnt                                     ( pixel_cnt_w                                   ),
 .p2b_enable                                    ( p2b_enable_w                                  ),
 .p2b_data_sel                                  ( p2b_data_sel_w                                ),
 .lyuv4208b_odd_even_convrn_enable              ( lyuv4208b_odd_even_convrn_enable_w            ),
 .yuv4208b_csps_odd_even_convrn_enable          ( yuv4208b_csps_odd_even_convrn_enable_w        ), 
 .yuv420_10b_csps_odd_even_convrn_enable        ( yuv420_10b_csps_odd_even_convrn_enable_w      ), 
 .yuv4208b_odd_even_convrn_enable               ( yuv4208b_odd_even_convrn_enable_w             ), 
 .yuv420_10b_odd_even_convrn_enable             ( yuv420_10b_odd_even_convrn_enable_w           ), 
 .comp_en                                       ( comp_en_w                                     ),
 .comp_scheme                                   ( comp_scheme_w                                 ),
 .packet_incr_pulse                             ( packet_incr_pulse_byteclk_clk_csi_w           )
);

//------------------------------------------------------------------------------
// Pixel 2 Byte component instantiation
csi2tx_pixel2byte_iface_top 
 u_csi2tx_pixel2byte_iface_top
(
 .clk_csi                                       ( clk_csi                                        ),
 .clk_csi_rst_n                                 ( clk_csi_rst_n                                  ),
 .tinit_start_clk_csi                           ( tinit_start_txclkesc_clk_csi_dm_w              ),
 .image_data                                    ( image_data_w                                   ),
 .forcetxstopmode                               ( forcetxstopmode_clk_csi_w                      ),
 .image_data_valid                              ( image_data_valid_w                             ),
 .image_data_delayed                            ( image_data_delayed_w                           ),
 .pixel_cnt                                     ( pixel_cnt_w                                    ),
 .sensor_pixel_vld_falling_edge                 ( sensor_pixel_vld_falling_edge_w                ),
 .header_info                                   ( header_info_w                                  ),
 .header_info_valid                             ( header_info_valid_w                            ),
 .orig_image_data_valid                         ( pixel_data_valid                               ),
 .p2b_enable                                    ( p2b_enable_w                                   ),
 .p2b_data_sel                                  ( p2b_data_sel_w                                 ),
 .comp_scheme                                   ( comp_scheme_w                                  ),
 .comp_en                                       ( comp_en_w                                      ),
 .lyuv4208b_odd_even_convrn_enable              ( lyuv4208b_odd_even_convrn_enable_w             ),
 .yuv4208b_csps_odd_even_convrn_enable          ( yuv4208b_csps_odd_even_convrn_enable_w         ),
 .yuv420_10b_csps_odd_even_convrn_enable        ( yuv420_10b_csps_odd_even_convrn_enable_w       ),
 .yuv4208b_odd_even_convrn_enable               ( yuv4208b_odd_even_convrn_enable_w              ),
 .yuv420_10b_odd_even_convrn_enable             ( yuv420_10b_odd_even_convrn_enable_w            ),
 .pixel_data64                                  ( wr_data_sensor_fifo                            ),
 .pixel_data64_valid                            ( pixel_data64_valid_w                           ),
 .packet_incr_pulse                             ( packet_incr_pulse_w                            )
 ); 
 
//------------------------------------------------------------------------------
// Sensor FIFO controller interface
csi2tx_sensor_fifo_ctrl #
  (
   .RAM_SIZE  (`SENSOR_FIFO_ADDR_WIDTH)
  )
   u_csi2tx_sensor_fifo_ctrl
  (

  .clk_wr                                       ( clk_csi                                         ),
  .clk_rd                                       ( txbyteclkhs                                     ),
  .rst_wr_n                                     ( clk_csi_rst_n                                   ),
  .rst_rd_n                                     ( txbyteclkhs_rst_n                               ),
  .tinit_start_byteclk                          ( tinit_start_txclkesc_byteclk_dm_w               ),
  .tinit_start_csi_clk                          ( tinit_start_txclkesc_clk_csi_dm_w               ),
  .wr_en                                        ( pixel_data64_valid_w                            ),
  .rd_en                                        ( sensor_fifo_rd_enable_w                         ),
  .fifo_wr_clr                                  ( forcetxstopmode_clk_csi_w                       ),
  .fifo_rd_clr                                  ( forcetxstopmode_byteclk_w                       ),
  .fifo_empty_rd_dm                             ( sensor_fifo_empty_w                             ),
  .fifo_full_wr_dm                              ( sensor_fifo_full_w                              ),
  .almost_full                                  ( sensor_fifo_almost_full_w                       ),
  .wena_n                                       ( wena_n_sensor_fifo                              ),
  .cena_n                                       ( cena_n_sensor_fifo                              ),
  .wr_addr                                      ( wr_addr_sensor_fifo                             ),
  .rd_addr                                      ( rd_addr_sensor_fifo                             ),
  .wenb_n                                       ( wenb_n_sensor_fifo                              ),
  .cenb_n                                       ( cenb_n_sensor_fifo                              )
  );                                                                            
  
//-----------------------------------------------------------------------------
// Packet processing unit component instnatiation
csi2tx_packet_rdr 
 u_csi2tx_packet_rdr
(
 .txbyteclkhs                                   ( txbyteclkhs                                     ),
 .txbyteclkhs_rst_n                             ( txbyteclkhs_rst_n                               ),
 .packet_rcvd_indication_pulse                  ( packet_incr_pulse_w_clk_csi_byteclk_w           ),
 .sensor_fifo_rd_data                           ( rd_data_sensor_fifo                             ),
 .forcetxstopmode                               ( forcetxstopmode_byteclk_w                       ),
 .sensor_fifo_rd_enable                         ( sensor_fifo_rd_enable_w                         ),
 .tinit_start_txbyteclk                         ( tinit_start_txclkesc_byteclk_dm_w               ),
 .sensor_fifo_empty                             ( sensor_fifo_empty_w                             ),
 .packet_rdy                                    ( packet_rdy_w                                    ),
 .packet_data_rdy                               ( packet_data_rdy_w                               ),
 .packet_valid                                  ( packet_valid_w                                  ),              
 .packet_dt                                     ( packet_dt_w                                     ),           
 .packet_vc                                     ( packet_vc_w                                     ),           
 .packet_wc_df                                  ( packet_wc_df_w                                  ),              
 .packet_data_valid                             ( packet_data_valid_w                             ),                   
 .packet_data                                   ( packet_data_w                                   )             
 );                                                                                              
 
//------------------------------------------------------------------------------
// Low level protocol component instantiaon
csi2tx_llp_top
 u_csi2tx_llp_top
(
 .txbyteclkhs                                   ( txbyteclkhs                                     ),
 .txbyteclkhs_rst_n                             ( txbyteclkhs_rst_n                               ),
 .tinit_start_byteclkhs                         ( tinit_start_txclkesc_byteclk_dm_w               ),
 .forcetxstopmode                               ( forcetxstopmode_byteclk_w                       ),
 .packet_rdy                                    ( packet_rdy_w                                    ),
 .packet_data_rdy                               ( packet_data_rdy_w                               ),
 .packet_valid                                  ( packet_valid_w                                  ),
 .packet_dt                                     ( packet_dt_w                                     ),
 .packet_vc                                     ( packet_vc_w                                     ),
 .packet_wc_df                                  ( packet_wc_df_w                                  ),
 .packet_data_valid                             ( packet_data_valid_w                             ),
 .packet_data                                   ( packet_data_w                                   ),
 .csi_byte_fifo_rddata                          ( csi_byte_fifo_rddata_w                          ),
 .csi_byte_fifo_rden                            ( csi_byte_fifo_rden_w                            ),
 .csi_byte_fifo_rd_empty_dm                     ( csi_byte_fifo_rd_empty_dm_w                     ),
 .csi_byte_fifo_rd_full_dm                      ( csi_byte_fifo_rd_full_dm_w                      ),
 .csi_byte_fifo_rd_almost_full_dm               ( csi_byte_fifo_rd_almost_full_dm_w               ),
 .txreadyhs_fall_pulse                          ( txready_hs_byteclk_pulse_w                      ) 
);
//------------------------------------------------------------------------------
// Lane Distibution component instantiation
csi2tx_lane_distribution_top 
 u_csi2tx_lane_distribution_top
(
 .txbyteclkhs                                  ( txbyteclkhs                                   ),
 .txbyteclkhs_rst_n                            ( txbyteclkhs_rst_n                             ),
 .lane_config                                  ( lane_config_sysclk_byteclk_w                  ),
 .forcetxstopmode                              ( forcetxstopmode_byteclk_w                     ),
 .tinit_start                                  ( tinit_start_txclkesc_byteclk_dm_w             ),
 .enable_hs_transmission                       ( enable_hs_transmission_w                      ),
 .stop_state_dl                                ( stopstate_dl_txclkesc_byteclk_w               ),
 .txreadyhs                                    ( txreadyhs                                     ),
 .fifo_rd_data                                 ( csi_byte_fifo_rddata_w                        ),
 .fifo_rd_en                                   ( csi_byte_fifo_rden_w                          ),
 .fifo_empty_rd_dm                             ( csi_byte_fifo_rd_empty_dm_w                   ),
 .hs_exit                                      ( dfe_dln_reg_0[23:16]                          ),
 .txrequesths                                  ( txrequesths                                   ),
 .txdatahs                                     ( txdatahs                                      )
);

//------------------------------------------------------------------------------
// clock lane control component instantiation
csi2tx_clock_lane_ctrl 
 u_csi2tx_clock_lane_ctrl
(
 .txbyteclkhs                                    ( txbyteclkhs                                   ),
 .txbyteclkhs_rst_n                              ( txbyteclkhs_rst_n                             ),
 .sleep_mode_enable                              ( txulpsesc_async_byteclk_w                     ),
 .sleep_mode_exit                                ( txulpsexit_async_byteclk_w                    ),
 .lane_config                                    ( lane_config_sysclk_byteclk_w                  ),
 .forcetxstopmode                                ( forcetxstopmode_byteclk_w                     ),
 .dphy_clk_mode                                  ( dphy_clk_mode_byteclk_w                       ),
 .txrequesths                                    ( txrequesths[0]                                ),
 .tinit_start                                    ( tinit_start_txclkesc_byteclk_dm_w             ),
 .stop_state_cl                                  ( stopstate_clk_txclkesc_byteclk_w              ),
 .stop_state_dl                                  ( stopstate_dl_txclkesc_byteclk_w               ),
 .ulpsactivenot_n                                ( ulpsactivenot_txclkesc_txbyteclkhs_w          ),
 .tclk_lpx                                       ( dfe_cln_reg_1[7:0]                            ),
 .tclk_prep                                      ( dfe_cln_reg_0[15:8]                           ),
 .tclk_zero                                      ( dfe_cln_reg_0[7:0]                            ),
 .tclk_pre                                       ( dfe_cln_reg_1[15:8]                           ),
 .tclk_post                                      ( dfe_cln_reg_1[23:16]                          ),
 .tclk_trial                                     ( dfe_dln_reg_0[31:24]                          ),
 .ths_exit                                       ( dfe_cln_reg_0[23:16]                          ),
 .txrequesths_cl                                 ( txrequesths_clk                               ),
 .txrequestesc                                   ( txrequestesc_byteclk_w                        ),
 .txulpsesc_entry_dl                             ( txulpsesc_entry_byteclk_w                     ),
 .txulpsesc_exit_dl                              ( txulpsesc_exit_byteclk_w                      ),
 .txulpsesc_entry_cl                             ( txulpsesc_entry_clk_byteclk_w                 ),
 .txulpsesc_exit_cl                              ( txulpsesc_exit_clk_byteclk_w                  ),
 .enable_hs_transmission                         ( enable_hs_transmission_w                      ),
 .elastic_fifo_empty_rd_dm                       ( csi_byte_fifo_rd_empty_dm_w                   ),
 .dphy_calib_ctrl                                ( dphy_calib_ctrl_byteclk_w                     ),
 .txskewcalhs                                    ( txskewcalhs                                   ),
 .data_lane_enabled                              ( data_lane_enabled_w                           )
);

//------------------------------------------------------------------------------
// AHB Interface component instantiation
csi2tx_ahb_slave_iface_top 
 u_csi2tx_ahb_slave_iface_top
(
 .clk_sys                                        ( sysclk                                         ),
 .clk_sys_rst_n                                  ( sysclk_rst_n                                   ),
 .htrans                                         ( htrans                                         ),
 .hburst                                         ( hburst                                         ),
 .hwrite                                         ( hwrite                                         ),
 .hsel                                           ( hsel                                           ),
 .hwdata                                         ( hwdata                                         ),
 .haddr                                          ( haddr                                          ),
 .hsize                                          ( hsize                                          ),
 .hready_in                                      ( hready_in                                      ),
 .hready                                         ( hready                                         ),
 .hrdata                                         ( hrdata                                         ),
 .hresp                                          ( hresp                                          ),
 .int_to_ahb                                     ( /*open*/                                       ),
 .sfifo_empty                                    ( csi_byte_fifo_rd_empty_sysclk_w                ),
 .sfifo_full                                     ( csi_byte_fifo_rd_full_sysclk_w                 ),
 .sfifo_almost_full                              ( csi_byte_fifo_rd_almost_full_sysclk_w          ),
 .asfifo_empty                                   ( sensor_fifo_empty_byteclk_sysclk_w             ),
 .asfifo_full                                    ( sensor_fifo_full_clk_csi_sysclk_w              ),
 .data_id_error                                  ( /*open*/                                       ),
 .prog_lane_cnt                                  ( lane_config_sysclk_w                           ),
 .prog_lane_cnt_en                               ( lane_config_wren_sysclk_w                      ),
 .trim_0                                         ( afe_trim_0                                     ),
 .trim_1                                         ( afe_trim_1                                     ),
 .trim_2                                         ( afe_trim_2                                     ),
 .trim_3                                         ( afe_trim_3                                     ),
 .dfe_dln_reg_0                                  ( dfe_dln_reg_0                                  ),
 .dfe_dln_reg_1                                  ( dfe_dln_reg_1                                  ),
 .dfe_cln_reg_0                                  ( dfe_cln_reg_0                                  ),
 .dfe_cln_reg_1                                  ( dfe_cln_reg_1                                  ),
 .pll_cnt_reg                                    ( pll_cnt_reg                                    ),
 .dfe_dln_lane_swap                              ( dfe_dln_lane_swap                              ),
 .vc0_compression_reg                            ( vc0_compression_reg_w                          ),
 .vc1_compression_reg                            ( vc1_compression_reg_w                          ),
 .vc2_compression_reg                            ( vc2_compression_reg_w                          ),
 .vc3_compression_reg                            ( vc3_compression_reg_w                          )
);

//------------------------------------------------------------------------------
// Sync module component instantiation
csi2tx_sync_module
 u_csi2tx_sync_module
(
 .sysclk                                         ( sysclk                                          ),
 .sysclk_rst_n                                   ( sysclk_rst_n                                    ),
 .txbyteclkhs                                    ( txbyteclkhs                                     ),
 .txbyteclkhs_rst_n                              ( txbyteclkhs_rst_n                               ),
 .clk_csi                                        ( clk_csi                                         ),
 .clk_csi_rst_n                                  ( clk_csi_rst_n                                   ),
 .txclkesc                                       ( txclkesc                                        ),
 .txclkesc_rst_n                                 ( txclkesc_rst_n                                  ),
 .sensor_fifo_empty                              ( sensor_fifo_empty_w                             ),
 .sensor_fifo_empty_byteclk_sysclk               ( sensor_fifo_empty_byteclk_sysclk_w              ),
 .sensor_fifo_full                               ( sensor_fifo_full_w                              ),
 .sensor_fifo_full_clk_csi_sysclk                ( sensor_fifo_full_clk_csi_sysclk_w               ),
 .dfe_pll_locked                                 ( dfe_pll_locked                                  ),
 .tinit_start_txclkesc_byteclk_dm                ( tinit_start_txclkesc_byteclk_dm_w               ),
 .tinit_start_txclkesc_clk_csi_dm                ( tinit_start_txclkesc_clk_csi_dm_w               ),
 .csi_byte_fifo_rd_empty                         ( csi_byte_fifo_rd_empty_dm_w                     ),
 .csi_byte_fifo_rd_empty_sysclk                  ( csi_byte_fifo_rd_empty_sysclk_w                 ),
 .csi_byte_fifo_rd_full                          ( csi_byte_fifo_rd_full_dm_w                      ),
 .csi_byte_fifo_rd_full_sysclk                   ( csi_byte_fifo_rd_full_sysclk_w                  ),
 .csi_byte_fifo_rd_almost_full                   ( csi_byte_fifo_rd_almost_full_dm_w               ),
 .csi_byte_fifo_rd_almost_full_sysclk            ( csi_byte_fifo_rd_almost_full_sysclk_w           ),
 .txready_hs                                     ( txreadyhs[0]                                    ),
 .txready_hs_byteclk_pulse                       ( txready_hs_byteclk_pulse_w                      ),
 .dphy_clk_mode                                  ( dphy_clk_mode                                   ),
 .dphy_clk_mode_byteclk                          ( dphy_clk_mode_byteclk_w                         ),
 .forcetxstopmode                                ( forcetxstopmode                                 ),
 .forcetxstopmode_byteclk                        ( forcetxstopmode_byteclk_w                       ),
 .forcetxstopmode_clk_csi                        ( forcetxstopmode_clk_csi_w                       ),
 .lane_config_sysclk                             ( lane_config_sysclk_w                            ),
 .lane_config_wren_sysclk                        ( lane_config_wren_sysclk_w                       ),
 .lane_config_sysclk_byteclk                     ( lane_config_sysclk_byteclk_w                    ),
 .stopstate_clk_txclkesc                         ( stopstate_clk                                   ),
 .stopstate_clk_txclkesc_byteclk                 ( stopstate_clk_txclkesc_byteclk_w                ),
 .stopstate_dl_txclkesc                          ( stopstate                                       ),
 .stopstate_dl_txclkesc_byteclk                  ( stopstate_dl_txclkesc_byteclk_w                 ),
 .txulpsesc_entry_byteclk                        ( txulpsesc_entry_byteclk_w                       ),
 .txulpsesc_entry_byteclk_txclkesc               ( txulpsesc_entry                                 ),
 .txulpsesc_entry_clk_byteclk                    ( txulpsesc_entry_clk_byteclk_w                   ),
 .txulpsesc_entry_clk_byteclk_txclesc            ( txulpsesc_entry_clk                             ),
 .txulpsesc_exit_byteclk                         ( txulpsesc_exit_byteclk_w                        ),
 .txulpsesc_exit_byteclk_txclkesc                ( txulpsesc_exit                                  ),
 .txulpsesc_exit_clk_byteclk                     ( txulpsesc_exit_clk_byteclk_w                    ),
 .txulpsesc_exit_clk_byteclk_txclkesc            ( txulpsesc_exit_clk                              ),
 .txrequestesc_byteclk                           ( txrequestesc_byteclk_w                          ),
 .txrequestesc_byteclk_txclkesc                  ( txrequestesc                                    ),
 .txulpsesc_async                                ( txulpsesc                                       ),
 .txulpsesc_async_byteclk                        ( txulpsesc_async_byteclk_w                       ),
 .txulpsexit_async                               ( txulpsexit                                      ),
 .txulpsexit_async_byteclk                       ( txulpsexit_async_byteclk_w                      ),
 .packet_incr_pulse                              ( packet_incr_pulse_w                             ),
 .packet_incr_pulse_clk_csi_byteclk              ( packet_incr_pulse_w_clk_csi_byteclk_w           ),
 .packet_incr_pulse_byteclk_clk_csi              ( packet_incr_pulse_byteclk_clk_csi_w             ),
 .ulpsactivenot_n                                ( ulpsactivenot_n                                 ),
 .ulpsactivenot_clk_n                            ( ulpsactivenot_clk_n                             ),
 .ulpsactivenot_txclkesc_txbyteclkhs             ( ulpsactivenot_txclkesc_txbyteclkhs_w            ),
 .dphy_calib_ctrl                                ( dphy_calib_ctrl                                 ),
 .dphy_calib_ctrl_byteclk                        ( dphy_calib_ctrl_byteclk_w                       ),
 .data_lane_enabled                              ( data_lane_enabled_w                             )                                                  
);


endmodule
