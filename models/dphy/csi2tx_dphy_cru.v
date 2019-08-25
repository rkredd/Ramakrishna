/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_cru.v
// Author      : B Shenbagaramesh
// Version     : v1p2
// Abstract    : This model is used for the clock and reset generation 
//               
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`timescale 1ps / 1ps
module csi2tx_dphy_cru(

  input                          pwr_on_rst                     ,
  input                          enable                         ,

  input                          txddrclkhs_q                   ,
  input                          txddrclkhs_i                   ,
  input                          txclkesc                       ,
  
  input                          lp_rx_dp_0                     ,
  input                          lp_rx_dn_0                     ,
  input                          lp_rx_dp_1                     ,
  input                          lp_rx_dn_1                     ,
  input                          lp_rx_dp_2                     ,
  input                          lp_rx_dn_2                     ,
  input                          lp_rx_dp_3                     ,
  input                          lp_rx_dn_3                     ,

  input                          lp_rx_dp_4                     ,
  input                          lp_rx_dn_4                     ,
  input                          lp_rx_dp_5                     ,
  input                          lp_rx_dn_5                     ,
  input                          lp_rx_dp_6                     ,
  input                          lp_rx_dn_6                     ,
  input                          lp_rx_dp_7                     ,
  input                          lp_rx_dn_7                     ,

  output      wire               txddr_q_rst_n                  ,
  output      wire               txddr_i_rst_n                  ,
  output      wire               rxddr_rst_n                    ,
  output      wire               txescclk_rst_n                 ,
  output      wire               rxescclk_rst_0_n               ,
  output      wire               rxescclk_rst_1_n               ,
  output      wire               rxescclk_rst_2_n               ,
  output      wire               rxescclk_rst_3_n               ,
  output      wire               rxescclk_rst_4_n               ,
  output      wire               rxescclk_rst_5_n               ,
  output      wire               rxescclk_rst_6_n               ,
  output      wire               rxescclk_rst_7_n               ,
  output      wire               rcvclkesc_rst_n                ,
  output      wire               tx_byte_rst_n                  ,
  output      wire               rx_byte_rst_n                  ,
  output      wire               rxclkesc                       ,
  output      wire               rxclkesc_0                     ,
  output      wire               rxclkesc_1                     ,
  output      wire               rxclkesc_2                     ,
  output      wire               rxclkesc_3                     ,
  output      wire               rxclkesc_4                     ,
  output      wire               rxclkesc_5                     ,
  output      wire               rxclkesc_6                     ,
  output      wire               rxclkesc_7                     ,

  output      wire               rxbyteclkhs,
  output      wire               txbyteclkhs,
  output      reg                csi1_rxbyteclkhs_n


  );

  wire            sig_txddr_q_rst_n                           ;
  wire            sig_txddr_i_rst_n                           ;

  assign  sig_txddr_q_rst_n    = pwr_on_rst & enable;
  assign  sig_txddr_i_rst_n    = pwr_on_rst & enable;
  assign  rxddr_rst_n          = pwr_on_rst & enable;
  assign  txescclk_rst_n       = pwr_on_rst & enable;
  assign  rxescclk_rst_0_n     = pwr_on_rst & enable;
  assign  rxescclk_rst_1_n     = pwr_on_rst & enable;
  assign  rxescclk_rst_2_n     = pwr_on_rst & enable;
  assign  rxescclk_rst_3_n     = pwr_on_rst & enable;
  assign  rxescclk_rst_4_n     = pwr_on_rst & enable;
  assign  rxescclk_rst_5_n     = pwr_on_rst & enable;
  assign  rxescclk_rst_6_n     = pwr_on_rst & enable;
  assign  rxescclk_rst_7_n     = pwr_on_rst & enable;
  assign  tx_byte_rst_n        = pwr_on_rst & enable;
  assign  rx_byte_rst_n        = pwr_on_rst & enable;

  assign  txddr_q_rst_n        = sig_txddr_q_rst_n;
  assign  txddr_i_rst_n        = sig_txddr_i_rst_n;
  assign  rcvclkesc_rst_n      = pwr_on_rst & enable;
  assign  rxclkesc             = txclkesc;//need to update

   always @(rxbyteclkhs)
   begin
      if(!sig_txddr_i_rst_n)
         csi1_rxbyteclkhs_n = 1'b0;
      else
         csi1_rxbyteclkhs_n = ~ rxbyteclkhs;
   end

  //******************************************************
  // INSTANTIATION OF BYTE CLOCK GENERATOR FOR TRANSMITTER
  //******************************************************
  csi2tx_dphy_byte_clk_gen u_csi2tx_txbyteclk_gen_inst(
    .ddrclkhs(txddrclkhs_i),
    .rst_n(sig_txddr_i_rst_n),
    .byteclkhs(txbyteclkhs)
    );
  //******************************************************
  // INSTANTIATION OF BYTE CLOCK GENERATOR FOR RECEIVER
  //******************************************************
  csi2tx_dphy_byte_clk_gen u_csi2tx_rxbyteclk_gen_inst(
    .ddrclkhs(txddrclkhs_q),
    .rst_n(sig_txddr_q_rst_n),
    .byteclkhs(rxbyteclkhs)
    );
  //***********************************************
  // INSTANTIATION OF LOW POWER CLOCK GENERATOR
  //***********************************************
  csi2tx_dphy_dat_lane_rxclkesc_gen u_csi2tx_dphy_dat_lane_rxclkesc_gen_inst_0(
    .lp_rx_dp(lp_rx_dp_0),
    .lp_rx_dn(lp_rx_dn_0),
    .rxclkesc(rxclkesc_0)
    );
  //***********************************************
  // INSTANTIATION OF LOW POWER CLOCK GENERATOR
  //***********************************************
  csi2tx_dphy_dat_lane_rxclkesc_gen u_csi2tx_dphy_dat_lane_rxclkesc_gen_inst_1(
    .lp_rx_dp(lp_rx_dp_1),
    .lp_rx_dn(lp_rx_dn_1),
    .rxclkesc(rxclkesc_1)
    );
  //***********************************************
  // INSTANTIATION OF LOW POWER CLOCK GENERATOR
  //***********************************************
  csi2tx_dphy_dat_lane_rxclkesc_gen u_csi2tx_dphy_dat_lane_rxclkesc_gen_inst_2(
    .lp_rx_dp(lp_rx_dp_2),
    .lp_rx_dn(lp_rx_dn_2),
    .rxclkesc(rxclkesc_2)
    );
  //***********************************************
  // INSTANTIATION OF LOW POWER CLOCK GENERATOR
  //***********************************************
  csi2tx_dphy_dat_lane_rxclkesc_gen u_csi2tx_dphy_dat_lane_rxclkesc_gen_inst_3(
    .lp_rx_dp(lp_rx_dp_3),
    .lp_rx_dn(lp_rx_dn_3),
    .rxclkesc(rxclkesc_3)
    );

  //***********************************************
  // INSTANTIATION OF LOW POWER CLOCK GENERATOR
  //***********************************************
  csi2tx_dphy_dat_lane_rxclkesc_gen u_csi2tx_dphy_dat_lane_rxclkesc_gen_inst_4(
    .lp_rx_dp(lp_rx_dp_4),
    .lp_rx_dn(lp_rx_dn_4),
    .rxclkesc(rxclkesc_4)
    );
  //***********************************************
  // INSTANTIATION OF LOW POWER CLOCK GENERATOR
  //***********************************************
  csi2tx_dphy_dat_lane_rxclkesc_gen u_csi2tx_dphy_dat_lane_rxclkesc_gen_inst_5(
    .lp_rx_dp(lp_rx_dp_5),
    .lp_rx_dn(lp_rx_dn_5),
    .rxclkesc(rxclkesc_5)
    );
  //***********************************************
  // INSTANTIATION OF LOW POWER CLOCK GENERATOR
  //***********************************************
  csi2tx_dphy_dat_lane_rxclkesc_gen u_csi2tx_dphy_dat_lane_rxclkesc_gen_inst_6(
    .lp_rx_dp(lp_rx_dp_6),
    .lp_rx_dn(lp_rx_dn_6),
    .rxclkesc(rxclkesc_6)
    );
  //***********************************************
  // INSTANTIATION OF LOW POWER CLOCK GENERATOR
  //***********************************************
  csi2tx_dphy_dat_lane_rxclkesc_gen u_csi2tx_dphy_dat_lane_rxclkesc_gen_inst_7(
    .lp_rx_dp(lp_rx_dp_7),
    .lp_rx_dn(lp_rx_dn_7),
    .rxclkesc(rxclkesc_7)
    );

endmodule
