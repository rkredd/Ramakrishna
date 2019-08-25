/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_clock_top.v
// Author      : B Shenbgaramesh
// Version     : v1p2
// Abstract    : This module is the top for both the transmitter and the receiver
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
//MODULE FOR D_PHY TOP
module csi2tx_dphy_clock_top(
  //INPUTS
  input     wire        txclkesc             ,   //INPUT LOW POWER CLOCK
  input     wire        txddr_q_rst_n        ,   //INPUT RESET SIGNAL FOR QUADRATURE CLOCK DOMAIN
  input     wire        txescclk_rst_n       ,   //INPUT RESET SIGNAL FOR TXCLKESC(LOW POWER CLOCK) CLOCK DOMAIN
  input     wire        txddrclkhs_q         ,   //INPUT QUADRATURE PHASE CLOCK
  input     wire        txrequesths_clk      ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR CLOCK LANE
  input     wire        txulpsclk            ,   //INPUT ULTRA LOW POWER STATE ENABLE SIGNAL FOR CLOCK LANE
  input     wire        txulpsexit_clk       ,   //INPUT ULTRA LOW POWER STATE EXIT SIGNAL FOR CLOCK LANE
  input     wire        slave                ,   //INPUT SIGNAL INDICATING WHETHER THE LANE MODULE IS MASTER OR SLAVE
  input     wire        lp_rx_cp_clk         ,   //INPUT LOW POWER DIFFERENTIAL CP LINE FROM THE TRANSCEIVER
  input     wire        lp_rx_cn_clk         ,   //INPUT LOW POWER DIFFERENTIAL CN LINE FROM THE TRANSCEIVER
  input     wire        eot_txr_sync_out_0   ,   //INPUT END OF TRANSMISSION SIGNAL FROM THE DATA LANE TRANSMITTER
  input     wire [7:0]  cln_cnt_hs_prep      ,   //INPUT HS PREPARE COUNT FOR CLOCK LANE
  input     wire [7:0]  cln_cnt_hs_zero      ,   //INPUT HS ZERO COUNT COUNT FOR CLOCK LANE
  input     wire [7:0]  cln_cnt_hs_trail     ,   //INPUT HS TRAIL COUNT FOR CLOCK LANE
  input     wire [7:0]  cln_cnt_hs_exit      ,   //INPUT HS EXIT COUNT FOR CLOCK LANE
  input     wire [7:0]  cln_cnt_lpx          ,   //INPUT LPX COUNT COUNT FOR CLOCK LANE

  //OUTPUTS
  output    wire        lp_tx_cntrl_clk      ,   //OUTPUT LOW POWER TRANSMISSION CONTROL SIGNAL FOR CLOCK LANE TO THE TRANSCEIVER
  output    wire        lp_tx_cp_clk         ,   //OUTPUT LOW POWER DIFFERENTIAL CP LINE FOR THE CLOCK LANE
  output    wire        lp_tx_cn_clk         ,   //OUTPUT LOW POWER DIFFERENTIAL CN LINE FOR THE CLOCK LANE
  output    wire        hs_txclk_cp          ,   //OUTPUT HIGH SPEED DIFFERENTIAL CP LINE FOR THE CLOCK LANE
  output    wire        hs_tx_cntrl_clk      ,   //OUTPUT HIGH SPEED TRANSMISSION CONTROL SIGNAL FOR CLOCK LANE TO THE TRANSCEIVER
  output    wire        frd_sot              ,   //OUTPUT START OF TRANSMISSION ENABLE SIGNAL TO THE DATA LANE WHEN MASTER
  output    wire        ulpsactivenotclk_s   ,   //OUTPUT ENABLE SIGNAL INDICATING THAT THE CLOCK TRANSMITTER IS NOT IN ULP STATE
  output    wire        mas_stopstate_clk    ,   //OUTPUT ENABLE SIGNAL FROM THE TRANSMITTER INDICATING THE LANE MODULE IS IN STOP STATE
  output    wire        slv_stopstate_clk    ,   //OUTPUT ENABLE SIGNAL FROM RECEIVER INIDICATING THE LANE MODULE IS IN STOP STATE
  output    wire        rxulpsclknot         ,   //OUTPUT ENABLE SIGNAL INDICATING THE RECEPTION OF ULP STATE
  output    wire        ulpsactivenotclk     ,   //OUTPUT ENABLE SIGNAL INDICATING THAT THE CLOCK RECEIVER IS NOT IN ULP STATE
  output    wire        rxclkactivehs        ,   //OUTPUT ENABLE SIGNAL INDICATING THE RECEPTION OF HIGH SPEED DDR CLOCK
  output    wire        hs_rx_cntrl_clk      ,   //OUPTUT HIGH SPEED RECEPTION CONTROL SIGNAL FOR CLOCK LANE TO THE TRANSCEIVER
  output    wire        lp_rx_cntrl_clk      ,   //OUTPUT LOW POWER RECEPTION CONTROL SIGNAL FOR CLOCK LANE TO THE TRANSCEIVER
  output    wire        rev_sot                  //OUPUT START OF TRANSMISSION ENABLE SIGNAL TO THE DATA LANE WHEN RECEIVER
  
  );
  

  
  //**********************************************
  // INSTANTIATION OF CLOCK LANE TRANSMITTER
  //**********************************************
  csi2tx_dphy_clk_lane_txr_top u_csi2tx_dphy_clk_lane_txr_top_inst(
    .txclkesc               (txclkesc                                         ),
    .txddr_q_rst_n          (txddr_q_rst_n                                    ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .txddrclkhs_q           (txddrclkhs_q                                     ),
    .slave                  (slave                                            ),
    .txrequesths_clk        (txrequesths_clk                                  ),
    .txulpsclk              (txulpsclk                                        ),
    .txulpsexit_clk         (txulpsexit_clk                                   ),
    .eot                    (eot_txr_sync_out_0                               ),
    .cln_cnt_hs_prep        (cln_cnt_hs_prep                                  ),
    .cln_cnt_hs_zero        (cln_cnt_hs_zero                                  ),
    .cln_cnt_hs_trail       (cln_cnt_hs_trail                                 ),
    .cln_cnt_hs_exit        (cln_cnt_hs_exit                                  ),
    .cln_cnt_lpx            (cln_cnt_lpx                                      ),
    .lp_tx_cntrl_clk        (lp_tx_cntrl_clk                                  ),
    .lp_tx_cp_clk           (lp_tx_cp_clk                                     ),
    .lp_tx_cn_clk           (lp_tx_cn_clk                                     ),
    .hs_tx_cp_clk           (hs_txclk_cp                                      ),
    .hs_tx_cntrl_clk        (hs_tx_cntrl_clk                                  ),
    .sot                    (frd_sot                                          ),
    .ulpsactivenot_clk      (ulpsactivenotclk_s                               ),
    .stopstate_clk          (mas_stopstate_clk                                )
    );
  
  //***********************************************
  // INSTANTIATION OF CLOCK LANE RECEIVER
  //***********************************************
  csi2tx_dphy_clk_lane_lp_rxr u_csi2tx_d_phy_clk_lane_lp_rxr_inst(
    .txclkesc               (txclkesc                                         ),
    .slave                  (slave                                            ),
    .lp_rx_cp_clk           (lp_rx_cp_clk                                     ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .lp_rx_cn_clk           (lp_rx_cn_clk                                     ),
    .stopstate              (slv_stopstate_clk                                ),
    .rxulpsclknot           (rxulpsclknot                                     ),
    .ulpsactivenot          (ulpsactivenotclk                                 ),
    .rxclkactivehs          (rxclkactivehs                                    ),
    .hs_rx_cntrl_clk        (hs_rx_cntrl_clk                                  ),
    .lp_rx_cntrl_clk        (lp_rx_cntrl_clk                                  ),
    .sot                    (rev_sot                                          )
    );
  
  
  
endmodule
