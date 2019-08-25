/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_mipi_top.v
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
module csi2tx_mipi_top
  (
  // Global Interface Signals
  input  wire        pwr_on_rst_n              ,
  input  wire        sysclk                    ,
  input  wire        txbyteclkhs               ,
  input  wire        sensor_clk                ,
  input  wire        txclkesc                  ,
  input  wire        test_mode                 ,   
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
wire reset_clk_csi_n_w ;
wire txclkesc_rst_n_w  ;
wire txbyteclk_rst_n_w ;
wire hreset_n_w        ;



//------------------------------------------------------------------------------
//
csi2tx_reset_sync
 u_csi2tx_reset_sync
  (
  .clk_csi                  ( sensor_clk                 ),
  .txclkesc                 ( txclkesc                   ),
  .txbyteclkhs              ( txbyteclkhs                ),
  .pwr_on_rst_n             ( pwr_on_rst_n               ),
  .hclk                     ( sysclk                     ),
  .test_mode                ( test_mode                  ),
  .reset_clk_csi_n          ( reset_clk_csi_n_w          ),
  .txclkesc_rst_n           ( txclkesc_rst_n_w           ),
  .txbyteclk_rst_n          ( txbyteclk_rst_n_w          ),
  .hreset_n                 ( hreset_n_w                 )
);

//------------------------------------------------------------------------------
//
csi2tx
 u_csi2tx
  (
  .sysclk                   ( sysclk                     ),
  .sysclk_rst_n             ( hreset_n_w                 ),
  .txbyteclkhs              ( txbyteclkhs                ),
  .txbyteclkhs_rst_n        ( txbyteclk_rst_n_w          ),
  .clk_csi                  ( sensor_clk                 ),
  .clk_csi_rst_n            ( reset_clk_csi_n_w          ),
  .txclkesc                 ( txclkesc                   ),
  .txclkesc_rst_n           ( txclkesc_rst_n_w           ),
  .dfe_pll_locked           ( dfe_pll_locked             ),
  .txreadyhs                ( txreadyhs                  ),
  .stopstate                ( stopstate                  ),
  .ulpsactivenot_clk_n      ( ulpsactivenot_clk_n        ),
  .ulpsactivenot_n          ( ulpsactivenot_n            ),
  .stopstate_clk            ( stopstate_clk              ),
  .txrequesths_clk          ( txrequesths_clk            ),
  .txrequesths              ( txrequesths                ),
  .txdatahs                 ( txdatahs                   ),
  .txulpsesc_entry          ( txulpsesc_entry            ),
  .txulpsesc_entry_clk      ( txulpsesc_entry_clk        ),        
  .txulpsesc_exit           ( txulpsesc_exit             ),
  .txulpsesc_exit_clk       ( txulpsesc_exit_clk         ),
  .txrequestesc             ( txrequestesc               ),
  .txskewcalhs              ( txskewcalhs                ),
  .afe_trim_0               ( afe_trim_0                 ),
  .afe_trim_1               ( afe_trim_1                 ),
  .afe_trim_2               ( afe_trim_2                 ),
  .afe_trim_3               ( afe_trim_3                 ),
  .dfe_dln_reg_0            ( dfe_dln_reg_0              ),
  .dfe_dln_reg_1            ( dfe_dln_reg_1              ),
  .dfe_cln_reg_0            ( dfe_cln_reg_0              ),
  .dfe_cln_reg_1            ( dfe_cln_reg_1              ),
  .pll_cnt_reg              ( pll_cnt_reg                ),
  .dfe_dln_lane_swap        ( dfe_dln_lane_swap          ), 
  .hwrite                   ( hwrite                     ),
  .hsel                     ( hsel                       ),
  .hready_in                ( hready_in                  ),
  .haddr                    ( haddr                      ),
  .hsize                    ( hsize                      ),
  .hburst                   ( hburst                     ),
  .htrans                   ( htrans                     ),
  .hwdata                   ( hwdata                     ),
  .hrdata                   ( hrdata                     ),
  .hresp                    ( hresp                      ),
  .hready                   ( hready                     ),  
  .frame_start              ( frame_start                ),
  .frame_end                ( frame_end                  ),
  .line_start               ( line_start                 ),
  .line_end                 ( line_end                   ),
  .packet_header_valid      ( packet_header_valid        ),
  .virtual_channel          ( virtual_channel            ),
  .data_type                ( data_type                  ),
  .word_count               ( word_count                 ),
  .pixel_data_valid         ( pixel_data_valid           ),
  .pixel_data               ( pixel_data                 ),
  .packet_header_accept     ( packet_header_accept       ),
  .pixel_data_accept        ( pixel_data_accept          ),
  .forcetxstopmode          ( forcetxstopmode            ),
  .txulpsesc                ( txulpsesc                  ),
  .txulpsexit               ( txulpsexit                 ),
  .dphy_clk_mode            ( dphy_clk_mode              ),
  .loopback_sel             ( loopback_sel               ),
  .dphy_calib_ctrl          ( dphy_calib_ctrl            ),
  .rd_data_sensor_fifo      ( rd_data_sensor_fifo        ),
  .cena_n_sensor_fifo       ( cena_n_sensor_fifo         ),
  .wena_n_sensor_fifo       ( wena_n_sensor_fifo         ),
  .wr_addr_sensor_fifo      ( wr_addr_sensor_fifo        ),
  .rd_addr_sensor_fifo      ( rd_addr_sensor_fifo        ),
  .wr_data_sensor_fifo      ( wr_data_sensor_fifo        ),
  .cenb_n_sensor_fifo       ( cenb_n_sensor_fifo         ),
  .wenb_n_sensor_fifo       ( wenb_n_sensor_fifo         )
);


endmodule
