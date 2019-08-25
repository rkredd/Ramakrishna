/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_ahb_slave_iface_top.v
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
module csi2tx_ahb_slave_iface_top 
(
 // Global Interface signals
 input  wire         clk_sys             ,
 input  wire         clk_sys_rst_n       ,
 // AHB Interface signals                
 input  wire [1:0]   htrans              ,
 input  wire [2:0]   hburst              ,
 input  wire         hwrite              ,
 input  wire         hsel                ,
 input  wire [31:0]  hwdata              ,
 input  wire [31:0]  haddr               ,
 input  wire [2:0]   hsize               ,
 input  wire         hready_in           ,
 output wire         hready              ,
 output wire [31:0]  hrdata              ,
 output wire [1:0]   hresp               ,
 output wire         int_to_ahb          ,
 // Other control interface signals      
 input  wire         sfifo_empty         ,
 input  wire         sfifo_full          ,
 input  wire         sfifo_almost_full   ,
 input  wire         asfifo_empty        ,
 input  wire         asfifo_full         ,
 input  wire         data_id_error       ,
 output wire [2:0]   prog_lane_cnt       ,
 output wire         prog_lane_cnt_en    ,
 output wire [31:0]  trim_0              ,
 output wire [31:0]  trim_1              ,
 output wire [31:0]  trim_2              ,
 output wire [31:0]  trim_3              ,
 output wire [31:0]  dfe_dln_reg_0       ,
 output wire [31:0]  dfe_dln_reg_1       ,
 output wire [31:0]  dfe_cln_reg_0       ,
 output wire [31:0]  dfe_cln_reg_1       ,
 output wire [15:0]  pll_cnt_reg         ,
 output wire [7:0]   dfe_dln_lane_swap   ,
 output wire [39:0]  vc0_compression_reg ,
 output wire [39:0]  vc1_compression_reg ,
 output wire [39:0]  vc2_compression_reg ,
 output wire [39:0]  vc3_compression_reg     
);
//------------------------------------------------------------------------------
// Internal interface signal declaration
wire        lb_cs       ;
wire        lb_adsm     ;
wire        lb_wrout    ;
wire [31:0] lb_aout     ;
wire [31:0] lb_dout     ;
wire [31:0] lb_din      ;
wire        ready       ;
wire        ahb_error_flag;    
//------------------------------------------------------------------------------
// AHB Slave interface component instantiation
csi2tx_ahb_slave_iface
 u_csi2tx_ahb_slave_iface
 (
  .clk_ahb                 ( clk_sys             ),
  .rstahb_n                ( clk_sys_rst_n       ),
  .t_htrans                ( htrans              ),
  .t_hburst                ( hburst              ),
  .t_hwrite                ( hwrite              ),
  .t_hsel                  ( hsel                ),
  .t_hwdata                ( hwdata              ),
  .t_haddr                 ( haddr               ),
  .t_hsize                 ( hsize               ),
  .t_hready_in             ( hready_in           ),
  .t_hready                ( hready              ),
  .t_hrdata                ( hrdata              ),
  .t_hresp                 ( hresp               ),
  .lb_rdyh                 ( ready               ),
  .ahb_error_flag          ( ahb_error_flag      ),
  .lb_din                  ( lb_din              ),
  .lb_cs                   ( lb_cs               ),
  .lb_adsm                 ( lb_adsm             ),
  .lb_wrout                ( lb_wrout            ),
  .lb_beout                ( /* open */          ),
  .lb_aout                 ( lb_aout             ),
  .lb_dout                 ( lb_dout             ),
  .lb_burst_addr_incr      ( 1'b0                )
);

//------------------------------------------------------------------------------
// Register interface component instantiation
csi2tx_register_iface
 u_csi2tx_register_iface
  (
    .clk_sys              ( clk_sys             ),
    .reset_clk_sys_n      ( clk_sys_rst_n       ),
    .csr_addr             ( lb_aout             ),
    .csr_rd               ( lb_adsm             ),
    .csr_wr               ( lb_wrout            ),
    .csr_cs_n             ( lb_cs               ),
    .csr_wr_data          ( lb_dout             ),
    .sfifo_empty          ( sfifo_empty         ),
    .sfifo_full           ( sfifo_full          ),
    .sfifo_almost_full    ( sfifo_almost_full   ),
    .asfifo_empty         ( asfifo_empty        ),
    .asfifo_full          ( asfifo_full         ),
    .data_id_error        ( data_id_error       ),
    .ready                ( ready               ),
    .ahb_error_flag       ( ahb_error_flag      ),
    .csr_rd_data          ( lb_din              ),
    .prog_lane_cnt        ( prog_lane_cnt       ),
    .prog_lane_cnt_en     ( prog_lane_cnt_en    ),
    .trim_0               ( trim_0              ),
    .trim_1               ( trim_1              ),
    .trim_2               ( trim_2              ),
    .trim_3               ( trim_3              ),
    .dfe_dln_reg_0        ( dfe_dln_reg_0       ),
    .dfe_dln_reg_1        ( dfe_dln_reg_1       ),
    .dfe_cln_reg_0        ( dfe_cln_reg_0       ),
    .dfe_cln_reg_1        ( dfe_cln_reg_1       ),
    .pll_cnt_reg          ( pll_cnt_reg         ),
    .dfe_dln_lane_swap    ( dfe_dln_lane_swap   ),
    .vc0_compression_reg  ( vc0_compression_reg ),
    .vc1_compression_reg  ( vc1_compression_reg ),
    .vc2_compression_reg  ( vc2_compression_reg ),
    .vc3_compression_reg  ( vc3_compression_reg )
  );
endmodule
