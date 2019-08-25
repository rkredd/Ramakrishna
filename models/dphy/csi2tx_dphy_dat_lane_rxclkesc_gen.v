/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_data_lane_rxclkesc_gen.v
// Author      : B Shenbagaramesh
// Version     : v1p2
// Abstract    : This module generated the rxclkesc from low power data lines by
//                EXOR operstion
//                                 
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
//MODULE FOR LOW POWER DATA CLOCK GENERATOR
module csi2tx_dphy_dat_lane_rxclkesc_gen(

  //INPUT FROM DATA LANE TRANSCEIVER
  input                   lp_rx_dp                              , //LOW POWER DP LINE
  input                   lp_rx_dn                              , //LOW POWER DN LINE
  //OUTPUT TO ESCAPE MODE RECEIVER MODULE
  output  wire            rxclkesc                                //ESCAPE CLOCK GENERATED FROM LOW POWER DP AND DN LINES
  );
   
  //ASSIGN STATEMENTS
  assign #1 rxclkesc = lp_rx_dp ^lp_rx_dn;
  
endmodule
