/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_data_top.v
// Author      : R.Dinesh Kumar
// Version     : v1p2
// Abstract    : This  is the top module for the data lane 
//               
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
//MODULE FOR D_PHY DATA TOP
module csi2tx_dphy_data_top(
  //INPUT SIGNALS
  input     wire         txclkesc                ,    //INPUT LOW POWER CLOCK SIGNAL USED FOR LOW POWER STATE TRANSITION
  input     wire         txescclk_rst_n          ,    //INPUT GATED RESET SIGNAL FOR TXCLKESC(LOW POWER CLOCK) CLOCK DOMAIN
  input     wire         rxescclk_rst_n          ,    //INPUT GATED RESET SIGNAL FOR RXCLKESC(EX-OR CLOCK) CLOCK DOMAIN
  input     wire         rxddr_rst_n             ,    //INPUT GATED RESET SIGNAL FOR QUADRATURE CLOCK DOMAIN
  input     wire         txddr_i_rst_n           ,    //INPUT GATED RESET SIGNAL FOR INPHASE CLOCK DOMAIN
  input     wire         tx_byte_rst_n           ,    //INPUT GATED RESET SIGNAL FOR TXBYTECLKHS(GENERATED FROM INPHASE CLOCK) CLOCK DOMAIN
  input     wire         rx_byte_rst_n           ,    //INPUT GATED RESET SIGNAL FOR RXBYTECLKHS(GENERATED FROM HS_RX_CLK) CLOCK DOMAIN
  input     wire         master_pin              ,    //INPUT SIGNAL INDICATING WHETHER THE SETUP IS FOR MASTER OR SLAVE(1-MASTER, 0-SLAVE)
  input     wire         tx_hs_clk               ,    //INPUT CLOCK FOR HIGH SPEED DATA TRANSMITTER
  input     wire         forcerxmode             ,    //INPUT SIGNAL TO FORCE DPHY TO SWITCH RX MODE AND WAIT FOR STOP STATE IN DPHY LINES
  input     wire         forcetxstopmode         ,    //INPUT SIGNAL TO FORCE DPHY TO SWITCH TX MODE AND TO TRANSMIT STOP STATE IN DPHY LINES
  input     wire         syc_sot_frm_clk         ,    //INPUT ENABLE SIGNAL FOR START OF TRANSMISSION SIGNAL TO THE DATA LANE
  input     wire         txrequesths             ,    //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI
  input     wire         tx_skewcallhs           ,   //
  input     wire [7:0]   txdatahs                ,    //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI
  input     wire         txrequestesc            ,    //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI
  input     wire         txlpdtesc               ,    //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI
  input     wire         txulpsesc               ,    //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI
  input     wire [3:0]   txtriggeresc            ,    //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdataesc               ,    //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI
  input     wire         txvalidesc              ,    //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI
  input     wire         txulpsexit              ,    //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE FROM THE TRANSMITTER PPI
  input     wire         turnrequest             ,    //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI
  input     wire         turndisable             ,    //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI
  input     wire         slave                   ,    //INPUT MASTER/SLAVE SELECT SIGNAL
  input     wire         rx_hs_clk               ,    //INPUT RECEIVED DDR CLOCK FROM THE CLOCK LANE
  input     wire         rxbyteclkhs             ,    //INPUT BYTE CLOCK GENERATED FROM DDR(HS_RX_CLK) CLOCK
  input     wire         lp_rx_dp                ,    //INPUT LOW POWER DIFFERENTIAL Dp LINE FROM THE TRANSCEIVER - FOR DATA LANE
  input     wire         lp_rx_dn                ,    //INPUT LOW POWER DIFFERENTIAL Dn LINE FROM THE TRANCEIVER - FOR DATA LANE
  input     wire         hs_rx                   ,    //INPUT HIGH SPEED Dp LINE FROM THE TRANCEIVER - FOR DATA LANE
  input     wire         txbyteclkhs             ,    //INPUT BYTE CLOCK GENERATED FROM DDR INPHASE CLOCK
  input     wire         rxclkesc                ,    //INPUT ESCAPE MODE EX-OR CLOCK GENERATED FROM LOW POWER DP AND DN LINES,
  input     wire         eot_handle_proc         ,    //INPUT EOT PROCESS HANDLING 0-EXTERNAL ,1 -INTERNAL 
  input     wire [7:0]   dln_cnt_hs_prep         ,   //INPUT HS PREPARE COUNT FOR DATA LANE  
  input     wire [7:0]   dln_cnt_hs_zero         ,   //INPUT HS ZERO COUNT FOR DATA LANE
  input     wire [7:0]   dln_cnt_hs_trail        ,   //INPUT HS TRAIL COUNT FOR DATA LANE 
  input     wire [7:0]   dln_cnt_hs_exit         ,   //INPUT HS EXIT COUNT FOR DATA LANE 
  input     wire [7:0]   dln_cnt_lpx             ,   //INPUT LPX COUNT FOR DATA LANE
  input     wire [5:0]   sot_sequence            ,   //SOT PATTEN
  input     wire         force_sot_error         ,   //FORCE ERROR
  input     wire         force_control_error     ,   //FORCE FALSE ERROR CONTROL
  input     wire         force_error_esc         ,   //FORCE ERROR ESC
 
  //OUTPUT SIGNALS
  output    wire         direction               ,    //OUTPUT SIGNAL TO INDICATE THE DIRECTION(1 -RX ,0 - TX)
  output    wire         txreadyhs               ,    //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI
  output    wire         txreadyesc              ,    //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI
  output    wire         ulpsactivenot_s         ,    //OUTPUT ENABLE SIGNAL INDICATING THAT THE DATA LANE IS NOT IN ULP STATE OF TRANSMITTER
  output    wire         sig_hs_tx_cntrl         ,    //OUTPUT CONTROL SIGNAL INDICATING THE HIGH SPEED DATA TRANSMISSION FOR DATA LANE
  output    wire         hs_tx_dp                ,    //OUTPUT HIGH SPEED DIFFERNTIAL DP LINE TO THE TRANSCEIVER - FOR DATA LANE
  output    wire         sig_lp_tx_cntrl         ,    //OUTPUT CONRTOL SIGNAL INDICATING THE LOW POWER DATA TRANSMISSION FOR DATA LANE
  output    wire         lp_tx_dp                ,    //OUTPUT LOW POWER DIFFERENTIAL Dp LINE TO THE TRANSCEIVER - FOR DATA LANE
  output    wire         lp_tx_dn                ,    //OUTPUT LOW POWER DIFFERENTIAL DN LINE TO THE TRANSCEIVER - FOR DATA LANE
  output    wire         stopstate               ,    //OUTPUT SIGNAL TO INDICATE THAT DATA TRANSMITTER LANE IS IN STOP STATE
  output    wire         eot_txr                 ,    //OUTPUT END OF TRANSMISSION SIGNAL FROM THE DATA LANE ZERO
  
  output    wire         rxactivehs              ,    //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA
  output    wire [7:0]   rxdatahs                ,    //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI
  output    wire         rxvalidhs               ,    //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES
  output    wire         rxsynchs                ,    //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION
  output    wire         rxskewcallhs            ,    //OUTPUR PULSE TO INDICATE THE RECEIVER PPI DESKEW CALIBRATIION
  output    wire [7:0]   rxdataesc               ,    //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI
  output    wire         rxvalidesc              ,    //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES
  output    wire [3:0]   rxtriggeresc            ,    //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI
  output    wire         rxulpsesc               ,    //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE IS IN ULPS
  output    wire         ulps_active_not_dl      ,    //OUTPUT ENABLE SIGNAL INDICATING THAT THE DATA LANE IS NOT IN ULP STATE OF RECEIVER
  output    wire         rxlpdtesc               ,    //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths                ,    //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI
  output    wire         errsotsynchs            ,    //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI
  output    wire         erresc                  ,    //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI
  output    wire         errsyncesc              ,    //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI
  output    wire         errcontrol              ,    //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI
  output    wire         stop_state_data         ,    //OUTPUT SIGNAL TO INDICATE THAT DATA LANE RECEIVER IS IN STOP STATE
  output    wire         hs_rx_cntrl             ,    //OUTPUT HIGH SPEED RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE
  output    wire         lp_rx_cntrl                  //OUTPUT LOW POWER RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE
  );
  
  
  //**********************************************
  // INSTANTIATION OF DATA LANE TRANSMITTER NO: 1
  //**********************************************
  csi2tx_dphy_dat_lane_txr u_csi2tx_dphy_dat_lane_txr_inst(
    .txclkesc            (txclkesc                                            ),
    .master_pin          (master_pin                                          ),
    .txescclk_rst_n      (txescclk_rst_n                                      ),
    .txddr_i_rst_n       (txddr_i_rst_n                                       ),
    .tx_byte_rst_n       (tx_byte_rst_n                                       ),
    .txddrclkhs_i        (tx_hs_clk                                           ),
    .forcerxmode         (forcerxmode                                         ),
    .forcetxstopmode     (forcetxstopmode                                     ), 
    .sot_frm_clk         (syc_sot_frm_clk                                     ),
    .eot_handle_proc     (eot_handle_proc                                     ),
    .dln_cnt_hs_prep     (dln_cnt_hs_prep                                     ),
    .dln_cnt_hs_zero     (dln_cnt_hs_zero                                     ),
    .dln_cnt_hs_trail    (dln_cnt_hs_trail                                    ),
    .dln_cnt_hs_exit     (dln_cnt_hs_exit                                     ),
    .dln_cnt_lpx         (dln_cnt_lpx                                         ),
    .sot_sequence        (sot_sequence                                        ), 
    .force_sot_error     (force_sot_error                                     ), 
    .force_control_error (force_control_error                                 ),
    .force_error_esc     (force_error_esc                                     ),
    .txrequesths         (txrequesths                                         ),
    .tx_skewcallhs       (tx_skewcallhs                                       ),
    .txdatahs            (txdatahs                                            ),
    .txrequestesc        (txrequestesc                                        ),
    .txlpdtesc           (txlpdtesc                                           ),
    .txulpsesc           (txulpsesc                                           ),
    .txtriggeresc        (txtriggeresc                                        ),
    .txdataesc           (txdataesc                                           ),
    .txvalidesc          (txvalidesc                                          ),
    .txulpsexit          (txulpsexit                                          ),
    .turnrequest         (turnrequest                                         ),
    .turndisable         (turndisable                                         ),
    .txn_en_frm_rxr      (change_direction_s                                  ),
    .dir_frm_rxr         (direction_frm_rxr                                   ),
    .direction           (direction                                           ),
    .txreadyhs           (txreadyhs                                           ),
    .txreadyesc          (txreadyesc                                          ),
    .ulpsactivenot       (ulpsactivenot_s                                     ),
    .hs_tx_cntrl         (sig_hs_tx_cntrl                                     ),
    .hs_tx_dp            (hs_tx_dp                                            ),
    .lp_tx_cntrl         (sig_lp_tx_cntrl                                     ),
    .lp_tx_dp            (lp_tx_dp                                            ),
    .lp_tx_dn            (lp_tx_dn                                            ),
    .stopstate           (stopstate                                           ),
    .rxn_en_to_rxr       (rxn_en_to_rxr                                       ),
    .eot_to_clk          (eot_txr                                             ),
    .txbyteclkhs         (txbyteclkhs                                         )
    );
  
  //**********************************************
  // INSTANTIATION OF DATA LANE RECEIVER NO: 1
  //**********************************************
  csi2tx_dphy_dat_lane_rxr_top u_csi2tx_d_phy_dat_lane_rxr_top_inst(
    .slave               (slave                                               ),
    .txclkesc            (txclkesc                                            ),
    .txescclk_rst_n      (txescclk_rst_n                                      ),
    .rxescclk_rst_n      (rxescclk_rst_n                                      ),
    .rxddr_rst_n         (rxddr_rst_n                                         ),
    .rx_byte_rst_n       (rx_byte_rst_n                                       ),
    .forcerxmode         (forcerxmode                                         ),
    .forcetxstopmode     (forcetxstopmode                                     ),
    .rxddrclkhs          (rx_hs_clk                                           ),
    .rxbyteclkhs         (rxbyteclkhs                                         ),
    .turndisable         (turndisable                                         ),
    .lp_rx_dp            (lp_rx_dp                                            ),
    .lp_rx_dn            (lp_rx_dn                                            ),
    .hs_rx               (hs_rx                                               ),
    .enable_rxn          (rxn_en_to_rxr                                       ),
    .rxactivehs          (rxactivehs                                          ),
    .rxdatahs            (rxdatahs                                            ),
    .rxvalidhs           (rxvalidhs                                           ),
    .rxsynchs            (rxsynchs                                            ),
    .rxskewcallhs        (rxskewcallhs                                        ),
    .chg_dir_pulse       (change_direction_s                                  ),
    .direction           (direction_frm_rxr                                   ),
    .rxdataesc           (rxdataesc                                           ),
    .rxvalidesc          (rxvalidesc                                          ),
    .rxtriggeresc        (rxtriggeresc                                        ),
    .rxulpsesc           (rxulpsesc                                           ),
    .ulpsactivenot       (ulps_active_not_dl                                  ),
    .rxlpdtesc           (rxlpdtesc                                           ),
    .rxclkesc            (rxclkesc                                            ),
    .eot_handle_proc     (eot_handle_proc                                     ),
    .errsoths            (errsoths                                            ),
    .errsotsynchs        (errsotsynchs                                        ),
    .erresc              (erresc                                              ),
    .errsyncesc          (errsyncesc                                          ),
    .errcontrol          (errcontrol                                          ),
    .stopstate_out       (stop_state_data                                     ),
    .hs_rx_en            (hs_rx_cntrl                                         ),
    .lp_rx_en            (lp_rx_cntrl                                         )
    );
  
endmodule
