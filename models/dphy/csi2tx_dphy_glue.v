/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_glue.v
// Author      : R.Dinesh Kumar
// Version     : v1p2
// Abstract    : This module incorporates all the top level glue logics for
//               eight lanes DPHY.
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
`timescale 1 ps / 1 ps
//MODULE FOR GLUE TOP
module csi2tx_dphy_glue(


  //INPUT SIGNALS
  input    wire        txclkesc               ,  //INPUT LOW POWER CLOCK SIGNAL USED FOR LOW POWER STATE TRANSITION
  input    wire        txescclk_rst_n         ,  //INPUT RESET SIGNAL FOR TXCLKESC(LOW POWER CLOCK) CLOCK DOMAIN
  input    wire        frd_sot                ,  //START OF TRANSMISSION ENABLE SIGNAL FOR FORWARD HIGH SPEED TRANSMISSION
  input    wire        master_pin             ,  //INPUT SIGNAL INDICATING WHETHER THE SETUP IS FOR MASTER OR SLAVE(1-MASTER, 0-SLAVE)
  input    wire        mas_stopstate_clk      ,  //ENABLE SIGNAL INDICATING THE CLOCK LANE STOP STATE DURING MASTER TRANSMISSION
  input    wire        slv_stopstate_clk      ,  //ENABLE SIGNAL INDICATING THE CLOCK LANE STOP STATE IN SLAVE RECEPTION
  input    wire        ulpsactivenotclk_s     ,  //ENABLE SIGNAL INDICATING THAT THE CLOCK LANE IS NOT IN ULPS STATE DURING MASTER TRANSMISSION
  input    wire        ulpsactivenotclk       ,  //ENABLE SIGNAL INDICATING THAT THE CLOCK LANE IS NOT IN ULPS STATE DURING SLAVE RECEPTION
  input    wire        sig_lp_tx_cntrl_0      ,  //CONRTOL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 1
  input    wire        sig_hs_tx_cntrl_0      ,  //CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 1
  input    wire        stopstate_0            ,  //ENABLE SIGNAL INDICATING THE DATA LANE 1 STOP STATE OF TRANSMITTER
  input    wire        stop_state_data_0      ,  //ENABLE SIGNAL INDICATING THE DATA LANE 1 STOP STATE OF RECEIVER
  input    wire        direction_frm_txr_0    ,  //SIGNAL INDICATING THE DIRECTION OF THE DATA LANE 1 WHETHER TRANSMITTER OR RECEIVER
  input    wire        ulps_active_not_dl_0   ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 1 IS NOT IN ULPS STATE OF RECEIVER
  input    wire        ulpsactivenot_s_0      ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 1 IS NOT IN ULPS STATE OF TRANSMITTER
  input    wire        lp_cd_d0_0             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 1 WHILE DRIVING LOW FROM THE TRANSCEIVER
  input    wire        lp_cd_d1_0             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 1 WHILE DRIVING HIGH FROM THE TRANSCEIVER

  input    wire        sig_lp_tx_cntrl_1      ,  //CONRTOL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 2
  input    wire        sig_hs_tx_cntrl_1      ,  //CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 2
  input    wire        stopstate_1            ,  //ENABLE SIGNAL INDICATING THE DATA LANE 2 STOP STATE OF TRANSMITTER
  input    wire        stop_state_data_1      ,  //ENABLE SIGNSL INDICATING THE DATA LANE 2 STOP STATE OF RECEIVER
  input    wire        direction_frm_txr_1    ,  //SIGNAL INDICATING THE DIRECTION OF THE DATA LANE 2 WHETHER TRANSMITTER OR RECEIVER
  input    wire        ulps_active_not_dl_1   ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 2 IS NOT IN ULPS STATE OF RECEIVER
  input    wire        ulpsactivenot_s_1      ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 2 IS NOT IN ULPS STATE OF TRANSMITTER
  input    wire        lp_cd_d0_1             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 2 WHILE DRIVING LOW FROM THE TRANSCEIVER
  input    wire        lp_cd_d1_1             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 2 WHILE DRIVING HIGH FROM THE TRANSCEIVER

  input    wire        sig_lp_tx_cntrl_2      ,  //CONRTOL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 3
  input    wire        sig_hs_tx_cntrl_2      ,  //CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 3
  input    wire        stopstate_2            ,  //ENABLE SIGNAL INDICATING THE DATA LANE 3 STOP STATE OF TRANSMITTER
  input    wire        stop_state_data_2      ,  //ENABLE SIGNSL INDICATING THE DATA LANE 3 STOP STATE OF RECEIVER
  input    wire        direction_frm_txr_2    ,  //SIGNAL INDICATING THE DIRECTION OF THE DATA LANE 3 WHETHER TRANSMITTER OR RECEIVER
  input    wire        ulps_active_not_dl_2   ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 3 IS NOT IN ULPS STATE OF RECEIVER
  input    wire        ulpsactivenot_s_2      ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 3 IS NOT IN ULPS STATE OF TRANSMITTER
  input    wire        lp_cd_d0_2             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 3 WHILE DRIVING LOW FROM THE TRANSCEIVER
  input    wire        lp_cd_d1_2             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 3 WHILE DRIVING HIGH FROM THE TRANSCEIVER

  input    wire        sig_lp_tx_cntrl_3      ,  //CONRTOL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 4
  input    wire        sig_hs_tx_cntrl_3      ,  //CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 4
  input    wire        stopstate_3            ,  //INPUT ENABLE SIGNAL INDICATING THE DATA LANE 4 STOP STATE OF TRANSMITTER
  input    wire        stop_state_data_3      ,  //INPUT ENABLE SIGNSL INDICATING THE DATA LANE 4 STOP STATE OF RECEIVER
  input    wire        direction_frm_txr_3    ,  //INPUT SIGNAL INDICATING THE DIRECTION OF THE DATA LANE 4 WHETHER TRANSMITTER OR RECEIVER
  input    wire        ulps_active_not_dl_3   ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 4 IS NOT IN ULPS STATE OF RECEIVER
  input    wire        ulpsactivenot_s_3      ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 4 IS NOT IN ULPS STATE OF TRANSMITTER
  input    wire        lp_cd_d0_3             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 4 WHILE DRIVING LOW FROM THE TRANSCEIVER
  input    wire        lp_cd_d1_3             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 4 WHILE DRIVING HIGH FROM THE TRANSCEIVER

  input    wire        sig_lp_tx_cntrl_4      ,  //CONRTOL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 5
  input    wire        sig_hs_tx_cntrl_4      ,  //CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 5
  input    wire        stopstate_4            ,  //ENABLE SIGNAL INDICATING THE DATA LANE 5 STOP STATE OF TRANSMITTER
  input    wire        stop_state_data_4      ,  //ENABLE SIGNAL INDICATING THE DATA LANE 5 STOP STATE OF RECEIVER
  input    wire        direction_frm_txr_4    ,  //SIGNAL INDICATING THE DIRECTION OF THE DATA LANE 1 WHETHER TRANSMITTER OR RECEIVER
  input    wire        ulps_active_not_dl_4   ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 5 IS NOT IN ULPS STATE OF RECEIVER
  input    wire        ulpsactivenot_s_4      ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 5 IS NOT IN ULPS STATE OF TRANSMITTER
  input    wire        lp_cd_d0_4             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 5 WHILE DRIVING LOW FROM THE TRANSCEIVER
  input    wire        lp_cd_d1_4             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 5 WHILE DRIVING HIGH FROM THE TRANSCEIVER

  input    wire        sig_lp_tx_cntrl_5      ,  //CONRTOL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 6
  input    wire        sig_hs_tx_cntrl_5      ,  //CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 6
  input    wire        stopstate_5            ,  //ENABLE SIGNAL INDICATING THE DATA LANE 6 STOP STATE OF TRANSMITTER
  input    wire        stop_state_data_5      ,  //ENABLE SIGNAL INDICATING THE DATA LANE 6 STOP STATE OF RECEIVER
  input    wire        direction_frm_txr_5    ,  //SIGNAL INDICATING THE DIRECTION OF THE DATA LANE 6 WHETHER TRANSMITTER OR RECEIVER
  input    wire        ulps_active_not_dl_5   ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 6 IS NOT IN ULPS STATE OF RECEIVER
  input    wire        ulpsactivenot_s_5      ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 6 IS NOT IN ULPS STATE OF TRANSMITTER
  input    wire        lp_cd_d0_5             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 6 WHILE DRIVING LOW FROM THE TRANSCEIVER
  input    wire        lp_cd_d1_5             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 6 WHILE DRIVING HIGH FROM THE TRANSCEIVER

  input    wire        sig_lp_tx_cntrl_6      ,  //CONRTOL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 7
  input    wire        sig_hs_tx_cntrl_6      ,  //CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 7
  input    wire        stopstate_6            ,  //ENABLE SIGNAL INDICATING THE DATA LANE 7 STOP STATE OF TRANSMITTER
  input    wire        stop_state_data_6      ,  //ENABLE SIGNAL INDICATING THE DATA LANE 7 STOP STATE OF RECEIVER
  input    wire        direction_frm_txr_6    ,  //SIGNAL INDICATING THE DIRECTION OF THE DATA LANE 7 WHETHER TRANSMITTER OR RECEIVER
  input    wire        ulps_active_not_dl_6   ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 7 IS NOT IN ULPS STATE OF RECEIVER
  input    wire        ulpsactivenot_s_6      ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 7 IS NOT IN ULPS STATE OF TRANSMITTER
  input    wire        lp_cd_d0_6             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 7 WHILE DRIVING LOW FROM THE TRANSCEIVER
  input    wire        lp_cd_d1_6             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 7 WHILE DRIVING HIGH FROM THE TRANSCEIVER

  input    wire        sig_lp_tx_cntrl_7      ,  //CONRTOL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 8
  input    wire        sig_hs_tx_cntrl_7      ,  //CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 8
  input    wire        stopstate_7            ,  //ENABLE SIGNAL INDICATING THE DATA LANE 8 STOP STATE OF TRANSMITTER
  input    wire        stop_state_data_7      ,  //ENABLE SIGNAL INDICATING THE DATA LANE 8 STOP STATE OF RECEIVER
  input    wire        direction_frm_txr_7    ,  //SIGNAL INDICATING THE DIRECTION OF THE DATA LANE 1 WHETHER TRANSMITTER OR RECEIVER
  input    wire        ulps_active_not_dl_7   ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 8 IS NOT IN ULPS STATE OF RECEIVER
  input    wire        ulpsactivenot_s_7      ,  //ENABLE SIGNAL INDICATING THAT THE DATA LANE 8 IS NOT IN ULPS STATE OF TRANSMITTER
  input    wire        lp_cd_d0_7             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 8 WHILE DRIVING LOW FROM THE TRANSCEIVER
  input    wire        lp_cd_d1_7             ,  //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE 8 WHILE DRIVING HIGH FROM THE TRANSCEIVER
 
  input    wire        eot_txr_0              ,  //INPUT END OF TRANSMISSION SIGNAL FROM THE DATA LANE

  output   wire        eot_txr_sync_out_0     ,  //OUTPUT SYNCHRONISED END OF TRANSMISSION SIGNAL
  output   wire        slave                  ,  //OUTPUT ENABLE SIGNAL INDICATING WHETHER SLAVE OR MASTER
  output   reg         syc_sot_frm_clk        ,  //OUTPUT ENABLE SIGNAL FOR START OF TRANSMISSION SIGNAL TO THE DATA LANE
  output   wire        stopstate_clk          ,  //OUTPUT ENABLE SIGNAL INDICATING THE STOPSTATE OF THE CLOCK LANE
  //OUTPUT SIGNALS
  output   wire        lp_tx_cntrl_0          ,  //OUTPUT CONTROL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 1
  output   wire        hs_tx_cntrl_0          ,  //OUTPUT CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 1
  output   wire        stopstate_dat_0        ,  //OUTPUT ENABLE SIGNAL INDICATING THE STOPSTATE OF THE DATA LANE 1
  output   wire        ulpsactivenot_0_n      ,  //OUTPUT ENABLE SIGNAL INDICATING THAT THE DATA LANE 1 IS NOT IN THE ULPS STATE
  output   wire        direction_0            ,  //OUTPUT ENABLE SIGNAL INDICATING WHETHER THE LANE 1 IS TRANSMITTER OR RECEIVER
  output   wire        errcontentionlp0_0     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING LOW ON THE LINE 1
  output   wire        errcontentionlp1_0     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING HIGH ON THE LINE 1

  output   wire        lp_tx_cntrl_1          ,  //OUTPUT CONTROL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 2
  output   wire        hs_tx_cntrl_1          ,  //OUTPUT CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION  FOR DATA LANE 2
  output   wire        stopstate_dat_1        ,  //OUTPUT ENABLE SIGNAL INDICATING THE STOPSTATE OF THE DATA LANE 2
  output   wire        ulpsactivenot_1_n      ,  //OUTPUT ENABLE SIGNAL INDICATING THAT THE DATA LANE 2 IS NOT IN THE ULPS STATE
  output   wire        direction_1            ,  //OUTPUT ENABLE SIGNAL INDICATING WHETHE THE LANE 2 IS TRANSMITTER OR RECEIVER
  output   wire        errcontentionlp0_1     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING LOW ON THE LINE 2
  output   wire        errcontentionlp1_1     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING HIGH ON THE LINE 2

  output   wire        lp_tx_cntrl_2          ,  //OUTPUT CONTROL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 3
  output   wire        hs_tx_cntrl_2          ,  //OUTPUT CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 3
  output   wire        stopstate_dat_2        ,  //OUTPUT ENABLE SIGNAL INDICATING THE STOPSTATE OF THE DATA LANE 3
  output   wire        ulpsactivenot_2_n      ,  //OUTPUT ENABLE SIGNAL INDICATING THAT THE DATA LANE 3 IS NOT IN THE ULPS STATE
  output   wire        direction_2            ,  //OUTPUT ENABLE SIGNAL INDICATING WHETHE THE LANE 3 IS TRANSMITTER OR RECEIVER
  output   wire        errcontentionlp0_2     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING LOW ON THE LINE 3
  output   wire        errcontentionlp1_2     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING HIGH ON THE LINE 3

  output   wire        lp_tx_cntrl_3          ,  //OUTPUT CONTROL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 4
  output   wire        hs_tx_cntrl_3          ,  //OUTPUT CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 4
  output   wire        stopstate_dat_3        ,  //OUTPUT ENABLE SIGNAL INDICATING THE STOPSTATE OF THE DATA LANE 4
  output   wire        ulpsactivenot_3_n      ,  //OUTPUT ENABLE SIGNAL INDICATING THAT THE DATA LANE 4 IS NOT IN THE ULPS STATE
  output   wire        direction_3            ,  //OUTPUT ENABLE SIGNAL INDICATING WHETHE THE LANE 4 IS TRANSMITTER OR RECEIVER
  output   wire        errcontentionlp0_3     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING LOW ON THE LINE 4
  output   wire        errcontentionlp1_3     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING HIGH ON THE LINE 4

  output   wire        lp_tx_cntrl_4          ,  //OUTPUT CONTROL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 5
  output   wire        hs_tx_cntrl_4          ,  //OUTPUT CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 5
  output   wire        stopstate_dat_4        ,  //OUTPUT ENABLE SIGNAL INDICATING THE STOPSTATE OF THE DATA LANE 5
  output   wire        ulpsactivenot_4_n      ,  //OUTPUT ENABLE SIGNAL INDICATING THAT THE DATA LANE 5 IS NOT IN THE ULPS STATE
  output   wire        direction_4            ,  //OUTPUT ENABLE SIGNAL INDICATING WHETHER THE LANE 5 IS TRANSMITTER OR RECEIVER
  output   wire        errcontentionlp0_4     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING LOW ON THE LINE 5
  output   wire        errcontentionlp1_4     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING HIGH ON THE LINE 5

  output   wire        lp_tx_cntrl_5          ,  //OUTPUT CONTROL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 6
  output   wire        hs_tx_cntrl_5          ,  //OUTPUT CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 6
  output   wire        stopstate_dat_5        ,  //OUTPUT ENABLE SIGNAL INDICATING THE STOPSTATE OF THE DATA LANE 6
  output   wire        ulpsactivenot_5_n      ,  //OUTPUT ENABLE SIGNAL INDICATING THAT THE DATA LANE 6 IS NOT IN THE ULPS STATE
  output   wire        direction_5            ,  //OUTPUT ENABLE SIGNAL INDICATING WHETHER THE LANE 6 IS TRANSMITTER OR RECEIVER
  output   wire        errcontentionlp0_5     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING LOW ON THE LINE 6
  output   wire        errcontentionlp1_5     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING HIGH ON THE LINE 6

  output   wire        lp_tx_cntrl_6          ,  //OUTPUT CONTROL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 7
  output   wire        hs_tx_cntrl_6          ,  //OUTPUT CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 7
  output   wire        stopstate_dat_6        ,  //OUTPUT ENABLE SIGNAL INDICATING THE STOPSTATE OF THE DATA LANE 7
  output   wire        ulpsactivenot_6_n      ,  //OUTPUT ENABLE SIGNAL INDICATING THAT THE DATA LANE 7 IS NOT IN THE ULPS STATE
  output   wire        direction_6            ,  //OUTPUT ENABLE SIGNAL INDICATING WHETHER THE LANE 7 IS TRANSMITTER OR RECEIVER
  output   wire        errcontentionlp0_6     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING LOW ON THE LINE 7
  output   wire        errcontentionlp1_6     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING HIGH ON THE LINE 7

  output   wire        lp_tx_cntrl_7          ,  //OUTPUT CONTROL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE 8
  output   wire        hs_tx_cntrl_7          ,  //OUTPUT CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE 8
  output   wire        stopstate_dat_7        ,  //OUTPUT ENABLE SIGNAL INDICATING THE STOPSTATE OF THE DATA LANE 8
  output   wire        ulpsactivenot_7_n      ,  //OUTPUT ENABLE SIGNAL INDICATING THAT THE DATA LANE 8 IS NOT IN THE ULPS STATE
  output   wire        direction_7            ,  //OUTPUT ENABLE SIGNAL INDICATING WHETHER THE LANE 8 IS TRANSMITTER OR RECEIVER
  output   wire        errcontentionlp0_7     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING LOW ON THE LINE 8
  output   wire        errcontentionlp1_7     ,  //OUTPUT CONTENTION ERROR SIGNAL WHEN TRANSMITTING HIGH ON THE LINE 8
         
  output   wire        ulpsactivenot_clk_n       //OUTPUT ENABLE SIGNAL INDICATING THAT THE CLOCK LANE IS NOT IN THE ULPS STATE


    
  );
 
  //**********************************************************************
  //CONTINUOUS ASSIGNMENTS
  //**********************************************************************
  //SLAVE SIGNAL
  assign slave = !master_pin;
  
  assign sot_frm_clk = frd_sot;
  
  //STOPSTATE_CLK SIGNAL
  assign stopstate_clk = master_pin  ? mas_stopstate_clk : slv_stopstate_clk;
  
  //ULPSACTIVENOT_CLK_N SIGNAL
  assign ulpsactivenot_clk_n = master_pin? ulpsactivenotclk_s : ulpsactivenotclk;
  
  //LP_TX_CNTRL_0 SIGNAL
  assign lp_tx_cntrl_0 = sig_lp_tx_cntrl_0;
  
  //HS_TX_CNTRL_0 SIGNAL
  assign hs_tx_cntrl_0 = sig_hs_tx_cntrl_0;
  
  //STOPSTATE_DAT_0 SIGNAL
  assign stopstate_dat_0 =   (sig_hs_tx_cntrl_0 || sig_lp_tx_cntrl_0) ? stopstate_0 : stop_state_data_0;
  
  //ULPSACTIVENOT_0_N SIGNAL
  assign ulpsactivenot_0_n = direction_frm_txr_0 ? ulps_active_not_dl_0:ulpsactivenot_s_0;
  
  //DIRECTION_0 SIGNAL
  assign direction_0 = direction_frm_txr_0;
  
  //ERRCONTENTIONLP0_0 SIGNAL
  assign  errcontentionlp0_0 = lp_cd_d0_0;
  
  //ERRCONTENTIONLP1_0 SIGNAL
  assign  errcontentionlp1_0 = lp_cd_d1_0;
  
  //LP_TX_CNTRL_1 SIGNAL
  assign lp_tx_cntrl_1 = sig_lp_tx_cntrl_1;
  
  //HS_TX_CNTRL_1 SIGNAL
  assign hs_tx_cntrl_1 = sig_hs_tx_cntrl_1;
  
  //STOPSTATE_DAT_1 SIGNAL
  assign stopstate_dat_1 =   (sig_hs_tx_cntrl_1 || sig_lp_tx_cntrl_1) ? stopstate_1 : stop_state_data_1;
  
  //ULPSACTIVENOT_1_N SIGNAL
  assign ulpsactivenot_1_n = direction_frm_txr_1 ? ulps_active_not_dl_1:ulpsactivenot_s_1;
  
  //DIRECTION_1 SIGNAL
  assign direction_1 = direction_frm_txr_1;
  
  //ERRCONTENTIONLP0_1 SIGNAL
  assign  errcontentionlp0_1 = lp_cd_d0_1;
  
  //ERRCONTENTIONLP1_1 SIGNAL
  assign  errcontentionlp1_1 = lp_cd_d1_1;
  
  //LP_TX_CNTRL_2 SIGNAL
  assign lp_tx_cntrl_2 = sig_lp_tx_cntrl_2;
  
  //HS_TX_CNTRL_2 SIGNAL
  assign hs_tx_cntrl_2 = sig_hs_tx_cntrl_2;
  
  //STOPSTATE_DAT_2 SIGNAL
  assign stopstate_dat_2 =   (sig_hs_tx_cntrl_2 || sig_lp_tx_cntrl_2) ? stopstate_2 : stop_state_data_2;
  
  //ULPSACTIVENOT_2_N SIGNAL
  assign ulpsactivenot_2_n = direction_frm_txr_2 ? ulps_active_not_dl_2:ulpsactivenot_s_2;
  
  //DIRECTION_2 SIGNAL
  assign direction_2 = direction_frm_txr_2;
  
  //ERRCONTENTIONLP0_2 SIGNAL
  assign  errcontentionlp0_2 = lp_cd_d0_2;
  
  //ERRCONTENTIONLP1_2 SIGNAL
  assign  errcontentionlp1_2 = lp_cd_d1_2;
  
  //LP_TX_CNTRL_3 SIGNAL
  assign lp_tx_cntrl_3 = sig_lp_tx_cntrl_3;
  
  //HS_TX_CNTRL_3 SIGNAL
  assign hs_tx_cntrl_3 = sig_hs_tx_cntrl_3;
  
  //STOPSTATE_DAT_3 SIGNAL
  assign stopstate_dat_3 = (sig_hs_tx_cntrl_3 || sig_lp_tx_cntrl_3) ? stopstate_3 : stop_state_data_3;
  
  //ULPSACTIVENOT_3_N SIGNAL
  assign ulpsactivenot_3_n = direction_frm_txr_3 ? ulps_active_not_dl_3:ulpsactivenot_s_3;
  
  //DIRECTION_3 SIGNAL
  assign direction_3 = direction_frm_txr_3;
  
  //ERRCONTENTIONLP0_3 SIGNAL
  assign  errcontentionlp0_3 = lp_cd_d0_3;
  
  //ERRCONTENTIONLP1_3 SIGNAL
  assign  errcontentionlp1_3 = lp_cd_d1_3;


  //LP_TX_CNTRL_4 SIGNAL
  assign lp_tx_cntrl_4 = sig_lp_tx_cntrl_4;
  
  //HS_TX_CNTRL_4 SIGNAL
  assign hs_tx_cntrl_4 = sig_hs_tx_cntrl_4;
  
  //STOPSTATE_DAT_4 SIGNAL
  assign stopstate_dat_4 =   (sig_hs_tx_cntrl_4 || sig_lp_tx_cntrl_4) ? stopstate_4 : stop_state_data_4;
  
  //ULPSACTIVENOT_4_N SIGNAL
  assign ulpsactivenot_4_n = direction_frm_txr_4 ? ulps_active_not_dl_4:ulpsactivenot_s_4;
  
  //DIRECTION_4 SIGNAL
  assign direction_4 = direction_frm_txr_4;
  
  //ERRCONTENTIONLP0_4 SIGNAL
  assign  errcontentionlp0_4 = lp_cd_d0_4;
  
  //ERRCONTENTIONLP1_4 SIGNAL
  assign  errcontentionlp1_4 = lp_cd_d1_4;


  //LP_TX_CNTRL_5 SIGNAL
  assign lp_tx_cntrl_5 = sig_lp_tx_cntrl_5;
  
  //HS_TX_CNTRL_5 SIGNAL
  assign hs_tx_cntrl_5 = sig_hs_tx_cntrl_5;
  
  //STOPSTATE_DAT_5 SIGNAL
  assign stopstate_dat_5 =   (sig_hs_tx_cntrl_5 || sig_lp_tx_cntrl_5) ? stopstate_5 : stop_state_data_5;
  
  //ULPSACTIVENOT_5_N SIGNAL
  assign ulpsactivenot_5_n = direction_frm_txr_5 ? ulps_active_not_dl_5:ulpsactivenot_s_5;
  
  //DIRECTION_5 SIGNAL
  assign direction_5 = direction_frm_txr_5;
  
  //ERRCONTENTIONLP0_5 SIGNAL
  assign  errcontentionlp0_5 = lp_cd_d0_5;
  
  //ERRCONTENTIONLP1_5 SIGNAL
  assign  errcontentionlp1_5 = lp_cd_d1_5;


  //LP_TX_CNTRL_6 SIGNAL
  assign lp_tx_cntrl_6 = sig_lp_tx_cntrl_6;
  
  //HS_TX_CNTRL_6 SIGNAL
  assign hs_tx_cntrl_6 = sig_hs_tx_cntrl_6;
  
  //STOPSTATE_DAT_6 SIGNAL
  assign stopstate_dat_6 =   (sig_hs_tx_cntrl_6 || sig_lp_tx_cntrl_6) ? stopstate_6 : stop_state_data_6;
  
  //ULPSACTIVENOT_6_N SIGNAL
  assign ulpsactivenot_6_n = direction_frm_txr_6 ? ulps_active_not_dl_6:ulpsactivenot_s_6;
  
  //DIRECTION_6 SIGNAL
  assign direction_6 = direction_frm_txr_6;
  
  //ERRCONTENTIONLP0_6 SIGNAL
  assign  errcontentionlp0_6 = lp_cd_d0_6;
  
  //ERRCONTENTIONLP1_6 SIGNAL
  assign  errcontentionlp1_6 = lp_cd_d1_6;


  //LP_TX_CNTRL_7 SIGNAL
  assign lp_tx_cntrl_7 = sig_lp_tx_cntrl_7;
  
  //HS_TX_CNTRL_7 SIGNAL
  assign hs_tx_cntrl_7 = sig_hs_tx_cntrl_7;
  
  //STOPSTATE_DAT_7 SIGNAL
  assign stopstate_dat_7 =   (sig_hs_tx_cntrl_7 || sig_lp_tx_cntrl_7) ? stopstate_7 : stop_state_data_7;
  
  //ULPSACTIVENOT_7_N SIGNAL
  assign ulpsactivenot_7_n = direction_frm_txr_7 ? ulps_active_not_dl_7:ulpsactivenot_s_7;
  
  //DIRECTION_7 SIGNAL
  assign direction_7 = direction_frm_txr_7;
  
  //ERRCONTENTIONLP0_7 SIGNAL
  assign  errcontentionlp0_7 = lp_cd_d0_7;
  
  //ERRCONTENTIONLP1_7 SIGNAL
  assign  errcontentionlp1_7 = lp_cd_d1_7;

  
  assign eot_txr_sync_out_0=eot_txr_0;
  
  always @(posedge sot_frm_clk)
    begin
      @(posedge txclkesc);
      syc_sot_frm_clk <= 1'b1;
    end
  
  always @(negedge sot_frm_clk)
    begin
      @(posedge txclkesc);
      syc_sot_frm_clk <= 1'b0;
    end
  

  
endmodule
