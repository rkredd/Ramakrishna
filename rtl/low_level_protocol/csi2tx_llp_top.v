/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_llp_top.v
// Author      : SHYAM SUNDAR B S
// Version     : v1p2
// Abstract    :               
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`include "csi2tx_defines.v"
module csi2tx_llp_top
(
 input   wire        txbyteclkhs                     ,
 input   wire        txbyteclkhs_rst_n               ,
 input   wire        tinit_start_byteclkhs           ,
 input   wire        forcetxstopmode                 ,
 output  wire        packet_rdy                      ,
 output  wire        packet_data_rdy                 ,
 input   wire        packet_valid                    ,
 input   wire [5:0]  packet_dt                       ,
 input   wire [1:0]  packet_vc                       ,
 input   wire [15:0] packet_wc_df                    ,
 input   wire        packet_data_valid               ,
 input   wire [63:0] packet_data                     ,
 input   wire        txreadyhs_fall_pulse            ,
 output  wire [63:0] csi_byte_fifo_rddata            ,
 input   wire        csi_byte_fifo_rden              ,
 output  wire        csi_byte_fifo_rd_empty_dm       ,
 output  wire        csi_byte_fifo_rd_full_dm        ,
 output  wire        csi_byte_fifo_rd_almost_full_dm 
);
//------------------------------------------------------------------------------
// Internal wire declaration
wire        fifo_almost_full_w;
wire [63:0] byte_aligned_data_w;
wire        byte_aligned_data_valid_w; 
  
//------------------------------------------------------------------------------
// packet interface component instantiation
csi2tx_packet_interface
 u_csi2tx_packet_interface 
(
 .txbyteclkhs                 ( txbyteclkhs                 ),
 .txbyteclkhs_rst_n           ( txbyteclkhs_rst_n           ),
 .tinit_start_byteclkhs       ( tinit_start_byteclkhs       ),
 .forcetxstopmode             ( forcetxstopmode             ),
 .packet_rdy                  ( packet_rdy                  ),
 .packet_data_rdy             ( packet_data_rdy             ),
 .packet_valid                ( packet_valid                ),
 .packet_dt                   ( packet_dt                   ),
 .packet_vc                   ( packet_vc                   ),
 .packet_wc_df                ( packet_wc_df                ),
 .packet_data_valid           ( packet_data_valid           ),
 .packet_data                 ( packet_data                 ),
 .fifo_almost_full            ( fifo_almost_full_w          ),
 .txreadyhs_fall_pulse        ( txreadyhs_fall_pulse        ),
 .byte_aligned_data           ( byte_aligned_data_w         ),
 .byte_aligned_data_valid     ( byte_aligned_data_valid_w   )
 );

//------------------------------------------------------------------------------
// sync register buffer component instatiation
csi2tx_sync_reg_buffer
 u_csi2tx_sync_reg_buffer
 (
  .clk                        ( txbyteclkhs                 ),
  .rst_n                      ( txbyteclkhs_rst_n           ),
  .wren                       ( byte_aligned_data_valid_w   ),
  .rden                       ( csi_byte_fifo_rden          ),
  .wrdata                     ( byte_aligned_data_w         ),
  .rddata                     ( csi_byte_fifo_rddata        ),
  .rddata_vld                 ( /* open */                  ),
  .clr_buffer                 ( forcetxstopmode             ),
  .wraddr                     ( /* open */                  ),
  .rdaddr                     ( /* open */                  ),
  .full                       ( csi_byte_fifo_rd_full_dm    ),
  .empty                      ( csi_byte_fifo_rd_empty_dm   ),
  .almostfull                 ( fifo_almost_full_w          ),
  .almostempty                ( /* open */                  ),
  .spacefilled                ( /* open */                  ),
  .spaceempty                 ( /* open */                  )
 );    
           
assign csi_byte_fifo_rd_almost_full_dm = fifo_almost_full_w;
                                           
endmodule                                                    
