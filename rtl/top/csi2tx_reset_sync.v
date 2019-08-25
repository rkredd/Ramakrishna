/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_reset_sync.v
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

module csi2tx_reset_sync
  (
  input   wire clk_csi         ,
  input   wire txclkesc        ,
  input   wire txbyteclkhs     ,
  input   wire pwr_on_rst_n    ,
  input   wire hclk            ,
  input   wire test_mode       ,
  output  wire reset_clk_csi_n ,
  output  wire txclkesc_rst_n  ,
  output  wire txbyteclk_rst_n ,
  output  wire hreset_n
  );

//----------------------------------------------------------------------------//
// Internal wire declaration
//----------------------------------------------------------------------------//
wire sig_txbyteclk_rst_n;
wire sig_txclkesc_rst_n;
wire sig_reset_clk_csi_n;
wire sig_hreset_n;

//----------------------------------------------------------------------------//
//assign txddr_i_rst_n = (test_mode)?1'b1:sig_txddr_i_rst_n;
// assign txbyteclk_rst_n = (test_mode)?1'b1:sig_txbyteclk_rst_n;
//----------------------------------------------------------------------------//
assign txbyteclk_rst_n = (test_mode)? pwr_on_rst_n : sig_txbyteclk_rst_n;
assign txclkesc_rst_n = (test_mode)? pwr_on_rst_n : sig_txclkesc_rst_n;
assign reset_clk_csi_n = (test_mode)? pwr_on_rst_n : sig_reset_clk_csi_n;
assign hreset_n = (test_mode)? pwr_on_rst_n : sig_hreset_n;

csi2tx_double_flop_sync
  u_csi2tx_txbyteclk_rst_n
  (
   .clk       (txbyteclkhs          ),
   .rst_n     (pwr_on_rst_n         ),
   .in_data   (1'b1                 ),
   .out_data  (sig_txbyteclk_rst_n  )
   );

csi2tx_double_flop_sync
  u_csi2tx_txclkesc_rst_n
  (
   .clk       (txclkesc             ),
   .rst_n     (pwr_on_rst_n         ),
   .in_data   (1'b1                 ),
   .out_data  (sig_txclkesc_rst_n   )
   );

csi2tx_double_flop_sync
  u_csi2tx_clk_csi_rst_n
  (
   .clk       (clk_csi              ),
   .rst_n     (pwr_on_rst_n         ),
   .in_data   (1'b1                 ),
   .out_data  (sig_reset_clk_csi_n  )
   );

csi2tx_double_flop_sync
  u_csi2tx_hrst_n
  (
   .clk       (hclk                 ),
   .rst_n     (pwr_on_rst_n         ),
   .in_data   (1'b1                 ),
   .out_data  (sig_hreset_n         )
   );
endmodule
