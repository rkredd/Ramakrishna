/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_top.v
// Author      : R DINESH KUMAR
// Version     : v1p2
// Abstract    : This module is the top for the data and the clock lane module 
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
module csi2tx_dphy_top(
  //INPUT SIGNALS
  input     wire         txddr_q_rst_n             ,   //INPUT RESET SIGNAL FOR QUADRATURE CLOCK DOMAIN
  input     wire         txddr_i_rst_n             ,   //INPUT RESET SIGNAL FOR INPHASE CLOCK DOMAIN
  input     wire         rxddr_rst_n               ,   //INPUT RESET SIGNAL FOR HS_RX_CLK DOMAIN
  input     wire         txescclk_rst_n            ,   //INPUT RESET SIGNAL FOR TXCLKESC(LOW POWER CLOCK) CLOCK DOMAIN
  input     wire         rxescclk_rst_0_n          ,   //INPUT RESET SIGNAL FOR RXCLKESC(EX-OR CLOCK) CLOCK DOMAIN
  input     wire         rxescclk_rst_1_n          ,   //INPUT RESET SIGNAL FOR RXCLKESC(EX-OR CLOCK) CLOCK DOMAIN
  input     wire         rxescclk_rst_2_n          ,   //INPUT RESET SIGNAL FOR RXCLKESC(EX-OR CLOCK) CLOCK DOMAIN
  input     wire         rxescclk_rst_3_n          ,   //INPUT RESET SIGNAL FOR RXCLKESC(EX-OR CLOCK) CLOCK DOMAIN
  input     wire         rxescclk_rst_4_n          ,   //INPUT RESET SIGNAL FOR RXCLKESC(EX-OR CLOCK) CLOCK DOMAIN
  input     wire         rxescclk_rst_5_n          ,   //INPUT RESET SIGNAL FOR RXCLKESC(EX-OR CLOCK) CLOCK DOMAIN
  input     wire         rxescclk_rst_6_n          ,   //INPUT RESET SIGNAL FOR RXCLKESC(EX-OR CLOCK) CLOCK DOMAIN
  input     wire         rxescclk_rst_7_n          ,   //INPUT RESET SIGNAL FOR RXCLKESC(EX-OR CLOCK) CLOCK DOMAIN
  input     wire         tx_byte_rst_n             ,   //INPUT RESET SIGNAL FOR TXBYTECLKHS(GENERATED FROM INPHASE CLOCK) CLOCK DOMAIN
  input     wire         rx_byte_rst_n             ,   //INPUT RESET SIGNAL FOR RXBYTECLKHS(GENERATED FROM HS_RX_CLK) CLOCK DOMAIN
  input     wire         txclkesc                  ,   //INPUT LOW POWER CLOCK SIGNAL USED FOR LOW POWER STATE TRANSITION
  input     wire         rxbyteclkhs               ,   //INPUT BYTE CLOCK GENERATED FROM DDR(HS_RX_CLK) CLOCK
  input     wire         txbyteclkhs               ,   //INPUT BYTE CLOCK GENERATED FROM DDR INPHASE CLOCK
  input     wire         master_pin                ,   //INPUT PIN FOR DIFFERENTIATING THE MASTER/SLAVE(1-MASTER, 0-SLAVE)
  input     wire         txddrclkhs_i              ,   //INPUT INPHASE HIGH SPEED DDR CLOCK
  input     wire         txddrclkhs_q              ,   //INPUT QUADRATURE PHASE HIGH SPEED DDR CLOCK
  input     wire         forcerxmode               ,   //INPUT FORCE RECEIVER MODE SIGNAL FROM THE PPI
  input     wire         forcetxstopmode           ,   //INPUT SIGNAL TO FORCE THE TRANSMITTER TO STOP MODE FROM THE PPI
  input     wire         lp_rx_cp_clk              ,   //INPUT LOW POWER DIFFERENTIAL Cp LINE FROM THE TRANSCEIVER - FOR CLOCK LANE
  input     wire         lp_rx_cn_clk              ,   //INPUT LOW POWER DIFFERENTIAL Cn LINE FROM THE TRANSCEIVER - FOR CLOCK LANE
  input     wire         hs_rx_clk                 ,   //INPUT HIGH SPEED DDR CLOCK TRANSMITTED FROM THE CLOCK LANE TRANSMITTER
  input     wire         lp_rx_dp_0                ,   //INPUT LOW POWER DIFFERENTIAL Dp LINE FROM THE TRANSCEIVER - FOR DATA LANE1
  input     wire         lp_rx_dn_0                ,   //INPUT LOW POWER DIFFERENTIAL Dn LINE FROM THE TRANCEIVER - FOR DATA LANE1
  input     wire         hs_rx_0                   ,   //INPUT HIGH SPEED Dp LINE FROM THE TRANCEIVER - FOR DATA LANE1
  input     wire         turndisable_0             ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE1
  input     wire         txulpsexit_0              ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE1 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_0             ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE1 FROM THE TRANSMITTER PPI
  input     wire [7:0]   tx_skewcallhs             ,   //
  input     wire [7:0]   txdatahs_0                ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire         turnrequest_0             ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire         txrequestesc_0            ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire         txlpdtesc_0               ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire         txulpsesc_0               ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire [3:0]   txtriggeresc_0            ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire [7:0]   txdataesc_0               ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE1
  input     wire         txvalidesc_0              ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire         lp_cd_d0_0                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE1
  input     wire         lp_cd_d1_0                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE1
  input     wire [5:0]   sot_sequence              ,   //SOT PATTEN
  input     wire         force_sot_error           ,   //FORCE ERROR
  input     wire         force_control_error       ,   //FORCE FALSE CONTROL ERROR
  input     wire         force_error_esc           ,   //FORCE ERROR ESC
  input     wire         rxclkesc_0                ,   //INPUT ESCAPE MODE EX-OR CLOCK GENERATED FROM LOW POWER DP AND DN LINES OF DATA LANE1
                                                   
  input     wire         lp_rx_dp_1                ,   //INPUT LOW POWER DIFFERENTIAL Dp LINE FROM THE TRANSCEIVER - FOR DATA LANE2
  input     wire         lp_rx_dn_1                ,   //INPUT LOW POWER DIFFERENTIAL Dn LINE FROM THE TRANCEIVER - FOR DATA LANE2
  input     wire         hs_rx_1                   ,   //INPUT HIGH SPEED Dp LINE FROM THE TRANCEIVER - FOR DATA LANE2
  input     wire         turndisable_1             ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI- FOR DATA LANE2
  input     wire         txulpsexit_1              ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE2 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_1             ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE2 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_1                ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire         turnrequest_1             ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire         txrequestesc_1            ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI- FOR DATA LANE2
  input     wire         txlpdtesc_1               ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire         txulpsesc_1               ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire [3:0]   txtriggeresc_1            ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire [7:0]   txdataesc_1               ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE2
  input     wire         txvalidesc_1              ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire         lp_cd_d0_1                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE2
  input     wire         lp_cd_d1_1                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE2
  input     wire         rxclkesc_1                ,   //INPUT ESCAPE MODE EX-OR CLOCK GENERATED FROM LOW POWER DP AND DN LINE OF DATA LANE2
                                                   
  input     wire         lp_rx_dp_2                ,   //INPUT LOW POWER DIFFERENTIAL Dp LINE FROM THE TRANSCEIVER - FOR DATA LANE3
  input     wire         lp_rx_dn_2                ,   //INPUT LOW POWER DIFFERENTIAL Dn LINE FROM THE TRANCEIVER - FOR DATA LANE3
  input     wire         hs_rx_2                   ,   //INPUT HIGH SPEED Dp LINE FROM THE TRANCEIVER - FOR DATA LANE3
  input     wire         turndisable_2             ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE3
  input     wire         txulpsexit_2              ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE3 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_2             ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE3 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_2                ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire         turnrequest_2             ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire         txrequestesc_2            ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire         txlpdtesc_2               ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire         txulpsesc_2               ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire [3:0]   txtriggeresc_2            ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire [7:0]   txdataesc_2               ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE3
  input     wire         txvalidesc_2              ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire         lp_cd_d0_2                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE3
  input     wire         lp_cd_d1_2                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE3
  input     wire         rxclkesc_2                ,   //INPUT ESCAPE MODE EX-OR CLOCK GENERATED FROM LOW POWER DP AND DN LINES OF DATA LANE3
                                                   
  input     wire         lp_rx_dp_3                ,   //INPUT LOW POWER DIFFERENTIAL Dp LINE FROM THE TRANSCEIVER - FOR DATA LANE4
  input     wire         lp_rx_dn_3                ,   //INPUT LOW POWER DIFFERENTIAL Dn LINE FROM THE TRANCEIVER - FOR DATA LANE4
  input     wire         hs_rx_3                   ,   //INPUT HIGH SPEED Dp LINE FROM THE TRANCEIVER - FOR DATA LANE4
  input     wire         turndisable_3             ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE4
  input     wire         txulpsexit_3              ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE4 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_3             ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE4 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_3                ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire         turnrequest_3             ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire         txrequestesc_3            ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire         txlpdtesc_3               ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire         txulpsesc_3               ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire [3:0]   txtriggeresc_3            ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire [7:0]   txdataesc_3               ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE4
  input     wire         txvalidesc_3              ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire         lp_cd_d0_3                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE4
  input     wire         lp_cd_d1_3                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE4
  input     wire         rxclkesc_3                ,   //INPUT ESCAPE MODE EX-OR CLOCK GENERATED FROM LOW POWER DP AND DN LINES - FOR DATA LANE4
                                                   
  input     wire         lp_rx_dp_4                ,   //INPUT LOW POWER DIFFERENTIAL Dp LINE FROM THE TRANSCEIVER - FOR DATA LANE5
  input     wire         lp_rx_dn_4                ,   //INPUT LOW POWER DIFFERENTIAL Dn LINE FROM THE TRANCEIVER - FOR DATA LANE5
  input     wire         hs_rx_4                   ,   //INPUT HIGH SPEED Dp LINE FROM THE TRANCEIVER - FOR DATA LANE5
  input     wire         turndisable_4             ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE5
  input     wire         txulpsexit_4              ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE5 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_4             ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE5 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_4                ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire         turnrequest_4             ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire         txrequestesc_4            ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire         txlpdtesc_4               ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire         txulpsesc_4               ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire [3:0]   txtriggeresc_4            ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire [7:0]   txdataesc_4               ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE5
  input     wire         txvalidesc_4              ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire         lp_cd_d0_4                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE5
  input     wire         lp_cd_d1_4                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE5
  input     wire         rxclkesc_4                ,   //INPUT ESCAPE MODE EX-OR CLOCK GENERATED FROM LOW POWER DP AND DN LINES OF DATA LANE5
                                                   
  input     wire         lp_rx_dp_5                ,   //INPUT LOW POWER DIFFERENTIAL Dp LINE FROM THE TRANSCEIVER - FOR DATA LANE6
  input     wire         lp_rx_dn_5                ,   //INPUT LOW POWER DIFFERENTIAL Dn LINE FROM THE TRANCEIVER - FOR DATA LANE6
  input     wire         hs_rx_5                   ,   //INPUT HIGH SPEED Dp LINE FROM THE TRANCEIVER - FOR DATA LANE6
  input     wire         turndisable_5             ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE6
  input     wire         txulpsexit_5              ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE6 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_5             ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE6 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_5                ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire         turnrequest_5             ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire         txrequestesc_5            ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire         txlpdtesc_5               ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire         txulpsesc_5               ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire [3:0]   txtriggeresc_5            ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire [7:0]   txdataesc_5               ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE6
  input     wire         txvalidesc_5              ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire         lp_cd_d0_5                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE6
  input     wire         lp_cd_d1_5                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE6
  input     wire         rxclkesc_5                ,   //INPUT ESCAPE MODE EX-OR CLOCK GENERATED FROM LOW POWER DP AND DN LINES OF DATA LANE6
                                                   
  input     wire         lp_rx_dp_6                ,   //INPUT LOW POWER DIFFERENTIAL Dp LINE FROM THE TRANSCEIVER - FOR DATA LANE7
  input     wire         lp_rx_dn_6                ,   //INPUT LOW POWER DIFFERENTIAL Dn LINE FROM THE TRANCEIVER - FOR DATA LANE7
  input     wire         hs_rx_6                   ,   //INPUT HIGH SPEED Dp LINE FROM THE TRANCEIVER - FOR DATA LANE7
  input     wire         turndisable_6             ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE7
  input     wire         txulpsexit_6              ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE7 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_6             ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE7 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_6                ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire         turnrequest_6             ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire         txrequestesc_6            ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire         txlpdtesc_6               ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire         txulpsesc_6               ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire [3:0]   txtriggeresc_6            ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire [7:0]   txdataesc_6               ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE7
  input     wire         txvalidesc_6              ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire         lp_cd_d0_6                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE7
  input     wire         lp_cd_d1_6                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE7
  input     wire         rxclkesc_6                ,   //INPUT ESCAPE MODE EX-OR CLOCK GENERATED FROM LOW POWER DP AND DN LINES OF DATA LANE7
                                                   
  input     wire         lp_rx_dp_7                ,   //INPUT LOW POWER DIFFERENTIAL Dp LINE FROM THE TRANSCEIVER - FOR DATA LANE8
  input     wire         lp_rx_dn_7                ,   //INPUT LOW POWER DIFFERENTIAL Dn LINE FROM THE TRANCEIVER - FOR DATA LANE8
  input     wire         hs_rx_7                   ,   //INPUT HIGH SPEED Dp LINE FROM THE TRANCEIVER - FOR DATA LANE8
  input     wire         turndisable_7             ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE8
  input     wire         txulpsexit_7              ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE8 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_7             ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE8 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_7                ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire         turnrequest_7             ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire         txrequestesc_7            ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire         txlpdtesc_7               ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire         txulpsesc_7               ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire [3:0]   txtriggeresc_7            ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire [7:0]   txdataesc_7               ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE8
  input     wire         txvalidesc_7              ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire         lp_cd_d0_7                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE8
  input     wire         lp_cd_d1_7                ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE8
  input     wire         rxclkesc_7                ,   //INPUT ESCAPE MODE EX-OR CLOCK GENERATED FROM LOW POWER DP AND DN LINES OF DATA LANE8
                                                   
  input     wire         txulpsexit_clk            ,   //INPUT SIGNAL TO EXIT THE ULTRA LOW POWER STATE FOR CLOCK LANE FROM THE MASTER TRANSMITTER PPI
  input     wire         txrequesths_clk           ,   //INPUT HIGH SPEED REQUEST SGNAL FOR CLOCK LANE FROM THE MASTER TRASNSMITTER PPI
  input     wire         txulpsclk                 ,   //INPUT ULTRA LOW POWER STATE REQUEST SIGNAL FOR CLOCK LANE FROM THE MASTER TRANSMITTER PPI
  input     wire         eot_handle_proc           ,   //INPUT EOT PROCESS HANDLING 0-EXTERNAL ,1 -INTERNAL 
  input     wire [7:0]   cln_cnt_hs_prep           ,   //INPUT HS PREPARE COUNT FOR CLOCK LANE
  input     wire [7:0]   cln_cnt_hs_zero           ,   //INPUT HS ZERO COUNT COUNT FOR CLOCK LANE
  input     wire [7:0]   cln_cnt_hs_trail          ,   //INPUT HS TRAIL COUNT FOR CLOCK LANE
  input     wire [7:0]   cln_cnt_hs_exit           ,   //INPUT HS EXIT COUNT FOR CLOCK LANE
  input     wire [7:0]   cln_cnt_lpx               ,   //INPUT LPX COUNT COUNT FOR CLOCK LANE

  input     wire [7:0]   dln_cnt_hs_prep           ,   //INPUT HS PREPARE COUNT FOR DATA LANE  
  input     wire [7:0]   dln_cnt_hs_zero           ,   //INPUT HS ZERO COUNT FOR DATA LANE
  input     wire [7:0]   dln_cnt_hs_trail          ,   //INPUT HS TRAIL COUNT FOR DATA LANE 
  input     wire [7:0]   dln_cnt_hs_exit           ,   //INPUT HS EXIT COUNT FOR DATA LANE 
  input     wire [7:0]   dln_cnt_lpx               ,   //INPUT LPX COUNT FOR DATA LANE
                                                   
  //OUTPUT SIGNALS                                 
  output    wire         txreadyhs_0               ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE1
  output    wire         txreadyesc_0              ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE1
  output    wire         direction_0               ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         hs_tx_cntrl_0             ,   //OUTPUT HIGH SPEED TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE1
  output    wire         hs_tx_dp_0                ,   //OUTPUT HIGH SPEED DIFFERNTIAL DP LINE TO THE TRANSCEIVER - FOR DATA LANE1
  output    wire         lp_tx_cntrl_0             ,   //OUTPUT LOW POWER TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE1
  output    wire         lp_tx_dp_0                ,   //OUTPUT LOW POWER DIFFERENTIAL Dp LINE TO THE TRANSCEIVER - FOR DATA LANE1
  output    wire         lp_tx_dn_0                ,   //OUTPUT LOW POWER DIFFERENTIAL DN LINE TO THE TRANSCEIVER - FOR DATA LANE1
  output    wire         stopstate_dat_0           ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE1 IS IN STOPSTATE
  output    wire         errcontentionlp0_0        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE1 HAS DETECTED A
  output    wire         errcontentionlp1_0        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE1 HAS DETECTED A
  output    wire         rxactivehs_0              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE1
  output    wire [7:0]   rxdatahs_0                ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         rxvalidhs_0               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE1
  output    wire         rxsynchs_0                ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE1
  output    wire [7:0]   rxdataesc_0               ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         rxvalidesc_0              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE1
  output    wire [3:0]   rxtriggeresc_0            ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         rxulpsesc_0               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE1 IS IN ULPS
  output    wire         rxskewcallhs_0            ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire         rxlpdtesc_0               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE1 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_0                ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         errsotsynchs_0            ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         erresc_0                  ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         errsyncesc_0              ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         errcontrol_0              ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         ulpsactivenot_0_n         ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE1 IS NOT IN ULTRA LOW POWER STATE
  output    wire         hs_rx_cntrl_0             ,   //OUTPUT HIGH SPEED RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE1
  output    wire         lp_rx_cntrl_0             ,   //OUTPUT LOW POWER RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE2
  output    wire         txreadyhs_1               ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE2
  output    wire         txreadyesc_1              ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE2
  output    wire         direction_1               ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         hs_tx_cntrl_1             ,   //OUTPUT HIGH SPEED TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE2
  output    wire         hs_tx_dp_1                ,   //OUTPUT HIGH SPEED DIFFERNTIAL DP LINE TO THE TRANSCEIVER - FOR DATA LANE2
  output    wire         lp_tx_cntrl_1             ,   //OUTPUT LOW POWER TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE2
  output    wire         lp_tx_dp_1                ,   //OUTPUT LOW POWER DIFFERENTIAL Dp LINE TO THE TRANSCEIVER - FOR DATA LANE2
  output    wire         lp_tx_dn_1                ,   //OUTPUT LOW POWER DIFFERENTIAL DN LINE TO THE TRANSCEIVER - FOR DATA LANE2
  output    wire         stopstate_dat_1           ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE2 IS IN STOPSTATE
  output    wire         errcontentionlp0_1        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE2 HAS DETECTED A
  output    wire         errcontentionlp1_1        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE2 HAS DETECTED A
  output    wire         rxactivehs_1              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE2
  output    wire [7:0]   rxdatahs_1                ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         rxvalidhs_1               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES - FOR DATA LANE2
  output    wire         rxsynchs_1                ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE2
  output    wire [7:0]   rxdataesc_1               ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI- FOR DATA LANE2
  output    wire         rxvalidesc_1              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE2
  output    wire [3:0]   rxtriggeresc_1            ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI- FOR DATA LANE2
  output    wire         rxulpsesc_1               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE2 IS IN ULPS
  output    wire         rxskewcallhs_1            ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire         rxlpdtesc_1               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE2 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_1                ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         errsotsynchs_1            ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         erresc_1                  ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         errsyncesc_1              ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         errcontrol_1              ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         ulpsactivenot_1_n         ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE LANE2 IS NOT IN ULTRA LOW POWER STATE
  output    wire         hs_rx_cntrl_1             ,   //OUTPUT HIGH SPEED RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE2
  output    wire         lp_rx_cntrl_1             ,   //OUTPUT LOW POWER RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE2
                                                   
  output    wire         txreadyhs_2               ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE3
  output    wire         txreadyesc_2              ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE3
  output    wire         direction_2               ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         hs_tx_cntrl_2             ,   //OUTPUT HIGH SPEED TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE3
  output    wire         hs_tx_dp_2                ,   //OUTPUT HIGH SPEED DIFFERNTIAL DP LINE TO THE TRANSCEIVER - FOR DATA LANE3
  output    wire         lp_tx_cntrl_2             ,   //OUTPUT LOW POWER TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE3
  output    wire         lp_tx_dp_2                ,   //OUTPUT LOW POWER DIFFERENTIAL Dp LINE TO THE TRANSCEIVER - FOR DATA LANE3
  output    wire         lp_tx_dn_2                ,   //OUTPUT LOW POWER DIFFERENTIAL DN LINE TO THE TRANSCEIVER - FOR DATA LANE3
  output    wire         stopstate_dat_2           ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE3 IS IN STOPSTATE
  output    wire         errcontentionlp0_2        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE3 HAS DETECTED A
  output    wire         errcontentionlp1_2        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE3 HAS DETECTED A
  output    wire         rxactivehs_2              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE3
  output    wire [7:0]   rxdatahs_2                ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         rxvalidhs_2               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE3
  output    wire         rxsynchs_2                ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE3
  output    wire [7:0]   rxdataesc_2               ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         rxvalidesc_2              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE3
  output    wire [3:0]   rxtriggeresc_2            ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         rxulpsesc_2               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE3 IS IN ULPS
  output    wire         rxskewcallhs_2            ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire         rxlpdtesc_2               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE3 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_2                ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         errsotsynchs_2            ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         erresc_2                  ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         errsyncesc_2              ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         errcontrol_2              ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         ulpsactivenot_2_n         ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE3 IS NOT IN ULTRA LOW POWER STATE
  output    wire         hs_rx_cntrl_2             ,   //OUTPUT HIGH SPEED RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE3
  output    wire         lp_rx_cntrl_2             ,   //OUTPUT LOW POWER RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE3
                                                   
  output    wire         txreadyhs_3               ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE4
  output    wire         txreadyesc_3              ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE4
  output    wire         direction_3               ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         hs_tx_cntrl_3             ,   //OUTPUT HIGH SPEED TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE4
  output    wire         hs_tx_dp_3                ,   //OUTPUT HIGH SPEED DIFFERNTIAL DP LINE TO THE TRANSCEIVER - FOR DATA LANE4
  output    wire         lp_tx_cntrl_3             ,   //OUTPUT LOW POWER TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE4
  output    wire         lp_tx_dp_3                ,   //OUTPUT LOW POWER DIFFERENTIAL Dp LINE TO THE TRANSCEIVER - FOR DATA LANE4
  output    wire         lp_tx_dn_3                ,   //OUTPUT LOW POWER DIFFERENTIAL DN LINE TO THE TRANSCEIVER - FOR DATA LANE4
  output    wire         stopstate_dat_3           ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE4 IS IN STOPSTATE
  output    wire         errcontentionlp0_3        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE4 HAS DETECTED A
  output    wire         errcontentionlp1_3        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE4 HAS DETECTED A
  output    wire         rxactivehs_3              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE4
  output    wire [7:0]   rxdatahs_3                ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         rxvalidhs_3               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES - FOR DATA LANE4
  output    wire         rxsynchs_3                ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE4
  output    wire [7:0]   rxdataesc_3               ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         rxvalidesc_3              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE4
  output    wire [3:0]   rxtriggeresc_3            ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         rxulpsesc_3               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE4 IS IN ULPS
  output    wire         rxskewcallhs_3            ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire         rxlpdtesc_3               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE4 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_3                ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         errsotsynchs_3            ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         erresc_3                  ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         errsyncesc_3              ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         errcontrol_3              ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         ulpsactivenot_3_n         ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE4 IS NOT IN ULTRA LOW POWER STATE
  output    wire         hs_rx_cntrl_3             ,   //OUTPUT HIGH SPEED RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE4
  output    wire         lp_rx_cntrl_3             ,   //OUTPUT LOW POWER RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE4
                                                   
  output    wire         txreadyhs_4               ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE5
  output    wire         txreadyesc_4              ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE5
  output    wire         direction_4               ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         hs_tx_cntrl_4             ,   //OUTPUT HIGH SPEED TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE5
  output    wire         hs_tx_dp_4                ,   //OUTPUT HIGH SPEED DIFFERNTIAL DP LINE TO THE TRANSCEIVER - FOR DATA LANE5
  output    wire         lp_tx_cntrl_4             ,   //OUTPUT LOW POWER TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE5
  output    wire         lp_tx_dp_4                ,   //OUTPUT LOW POWER DIFFERENTIAL Dp LINE TO THE TRANSCEIVER - FOR DATA LANE5
  output    wire         lp_tx_dn_4                ,   //OUTPUT LOW POWER DIFFERENTIAL DN LINE TO THE TRANSCEIVER - FOR DATA LANE5
  output    wire         stopstate_dat_4           ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE5 IS IN STOPSTATE
  output    wire         errcontentionlp0_4        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE5 HAS DETECTED A
  output    wire         errcontentionlp1_4        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE5 HAS DETECTED A
  output    wire         rxactivehs_4              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE5
  output    wire [7:0]   rxdatahs_4                ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         rxvalidhs_4               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE5
  output    wire         rxsynchs_4                ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE5
  output    wire [7:0]   rxdataesc_4               ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         rxvalidesc_4              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE5
  output    wire [3:0]   rxtriggeresc_4            ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         rxulpsesc_4               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE5 IS IN ULPS
  output    wire         rxskewcallhs_4            ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire         rxlpdtesc_4               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE5 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_4                ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         errsotsynchs_4            ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         erresc_4                  ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         errsyncesc_4              ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         errcontrol_4              ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         ulpsactivenot_4_n         ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE5 IS NOT IN ULTRA LOW POWER STATE
  output    wire         hs_rx_cntrl_4             ,   //OUTPUT HIGH SPEED RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE5
  output    wire         lp_rx_cntrl_4             ,   //OUTPUT LOW POWER RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE5
                                                   
  output    wire         txreadyhs_5               ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE6
  output    wire         txreadyesc_5              ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE6
  output    wire         direction_5               ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         hs_tx_cntrl_5             ,   //OUTPUT HIGH SPEED TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE6
  output    wire         hs_tx_dp_5                ,   //OUTPUT HIGH SPEED DIFFERNTIAL DP LINE TO THE TRANSCEIVER - FOR DATA LANE6
  output    wire         lp_tx_cntrl_5             ,   //OUTPUT LOW POWER TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE6
  output    wire         lp_tx_dp_5                ,   //OUTPUT LOW POWER DIFFERENTIAL Dp LINE TO THE TRANSCEIVER - FOR DATA LANE6
  output    wire         lp_tx_dn_5                ,   //OUTPUT LOW POWER DIFFERENTIAL DN LINE TO THE TRANSCEIVER - FOR DATA LANE6
  output    wire         stopstate_dat_5           ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE6 IS IN STOPSTATE
  output    wire         errcontentionlp0_5        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE6 HAS DETECTED A
  output    wire         errcontentionlp1_5        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE6 HAS DETECTED A
  output    wire         rxactivehs_5              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE6
  output    wire [7:0]   rxdatahs_5                ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         rxvalidhs_5               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE6
  output    wire         rxsynchs_5                ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE6
  output    wire [7:0]   rxdataesc_5               ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         rxvalidesc_5              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE6
  output    wire [3:0]   rxtriggeresc_5            ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         rxulpsesc_5               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE6 IS IN ULPS
  output    wire         rxskewcallhs_5            ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire         rxlpdtesc_5               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE6 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_5                ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         errsotsynchs_5            ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         erresc_5                  ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         errsyncesc_5              ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         errcontrol_5              ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         ulpsactivenot_5_n         ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE6 IS NOT IN ULTRA LOW POWER STATE
  output    wire         hs_rx_cntrl_5             ,   //OUTPUT HIGH SPEED RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE6
  output    wire         lp_rx_cntrl_5             ,   //OUTPUT LOW POWER RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE6

  output    wire         txreadyhs_6               ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE7
  output    wire         txreadyesc_6              ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE7
  output    wire         direction_6               ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         hs_tx_cntrl_6             ,   //OUTPUT HIGH SPEED TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE7
  output    wire         hs_tx_dp_6                ,   //OUTPUT HIGH SPEED DIFFERNTIAL DP LINE TO THE TRANSCEIVER - FOR DATA LANE7
  output    wire         lp_tx_cntrl_6             ,   //OUTPUT LOW POWER TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE7
  output    wire         lp_tx_dp_6                ,   //OUTPUT LOW POWER DIFFERENTIAL Dp LINE TO THE TRANSCEIVER - FOR DATA LANE7
  output    wire         lp_tx_dn_6                ,   //OUTPUT LOW POWER DIFFERENTIAL DN LINE TO THE TRANSCEIVER - FOR DATA LANE7
  output    wire         stopstate_dat_6           ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE7 IS IN STOPSTATE
  output    wire         errcontentionlp0_6        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE7 HAS DETECTED A
  output    wire         errcontentionlp1_6        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE7 HAS DETECTED A
  output    wire         rxactivehs_6              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE7
  output    wire [7:0]   rxdatahs_6                ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         rxvalidhs_6               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE7
  output    wire         rxsynchs_6                ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE7
  output    wire [7:0]   rxdataesc_6               ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         rxvalidesc_6              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE7
  output    wire [3:0]   rxtriggeresc_6            ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         rxulpsesc_6               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE7 IS IN ULPS
  output    wire         rxskewcallhs_6            ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire         rxlpdtesc_6               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE7 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_6                ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         errsotsynchs_6            ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         erresc_6                  ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         errsyncesc_6              ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         errcontrol_6              ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         ulpsactivenot_6_n         ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE7 IS NOT IN ULTRA LOW POWER STATE
  output    wire         hs_rx_cntrl_6             ,   //OUTPUT HIGH SPEED RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE7
  output    wire         lp_rx_cntrl_6             ,   //OUTPUT LOW POWER RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE7

  output    wire         txreadyhs_7               ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE8
  output    wire         txreadyesc_7              ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE8
  output    wire         direction_7               ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         hs_tx_cntrl_7             ,   //OUTPUT HIGH SPEED TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE8
  output    wire         hs_tx_dp_7                ,   //OUTPUT HIGH SPEED DIFFERNTIAL DP LINE TO THE TRANSCEIVER - FOR DATA LANE8
  output    wire         lp_tx_cntrl_7             ,   //OUTPUT LOW POWER TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE8
  output    wire         lp_tx_dp_7                ,   //OUTPUT LOW POWER DIFFERENTIAL Dp LINE TO THE TRANSCEIVER - FOR DATA LANE8
  output    wire         lp_tx_dn_7                ,   //OUTPUT LOW POWER DIFFERENTIAL DN LINE TO THE TRANSCEIVER - FOR DATA LANE8
  output    wire         stopstate_dat_7           ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE8 IS IN STOPSTATE
  output    wire         errcontentionlp0_7        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE8 HAS DETECTED A
  output    wire         errcontentionlp1_7        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE8 HAS DETECTED A
  output    wire         rxactivehs_7              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE8
  output    wire [7:0]   rxdatahs_7                ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         rxvalidhs_7               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE8
  output    wire         rxsynchs_7                ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE8
  output    wire [7:0]   rxdataesc_7               ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         rxvalidesc_7              ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE8
  output    wire [3:0]   rxtriggeresc_7            ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         rxulpsesc_7               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE8 IS IN ULPS
  output    wire         rxskewcallhs_7            ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire         rxlpdtesc_7               ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE8 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_7                ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         errsotsynchs_7            ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         erresc_7                  ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         errsyncesc_7              ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         errcontrol_7              ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         ulpsactivenot_7_n         ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE8 IS NOT IN ULTRA LOW POWER STATE
  output    wire         hs_rx_cntrl_7             ,   //OUTPUT HIGH SPEED RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE8
  output    wire         lp_rx_cntrl_7             ,   //OUTPUT LOW POWER RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR DATA LANE8
                                                          
  output    wire         rxclkactivehs             ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED CLOCK
  output    wire         lp_tx_cntrl_clk           ,   //OUTPUT LOW POWER TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR CLOCK LANE
  output    wire         lp_tx_cp_clk              ,   //OUTPUT LOW POWER DIFFERENTIAL CP LINE TO THE TRANSCEIVER - FOR CLOCK LANE
  output    wire         lp_tx_cn_clk              ,   //OUTPUT LOW POWER DIFFERENTIAL CN LINE TO THE TRANSCEIVER - FOR CLOCK LANE
  output    wire         hs_tx_cp_clk              ,   //OUTPUT HIGH SPEED DIFFERENTIAL CP LINE TO THE TRANSCEIVER - FOR CLOCK LANE
  output    wire         hs_tx_cntrl_clk           ,   //OUTPUT HIGH SPEED TRANSMITTER CONTROL SIGNAL TO THE TRANSCEIVER - FOR CLOCK LANE
  output    wire         hs_rx_cntrl_clk           ,   //OUTPUT HIGH SPEED RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR CLOCK LANE
  output    wire         lp_rx_cntrl_clk           ,   //OUTPUT LOW POWER RECEIVER CONTROL SIGNAL TO THE TRANSCEIVER - FOR CLOCK LANE
  output    wire         rxulpsclknot_n            ,   //OUTPUT TO THE SLAVE RECEVIER PPI TO INDICATE THAT THE CLOCK LANE IS IN ULTRA LOW POWER STATE
  output    wire         ulpsactivenot_clk_n       ,   //OUTPUT TO INDICATE THE MASTER TRANSMITTER PPI THAT THE CLOCK LANE IS IN ULTRA LOW POWER STATE
  output    wire         stopstate_clk                 //OUTPUT TO THE PPI TO INDICATE THAT THE CLOCK LANE IS IN STOPSTATE
  
  
  );

  //**************************************************
  // INSTANTIATION OF GLUE.V FILE
  //****************************************************
  
  csi2tx_dphy_glue u_csi2tx_dphy_glue_inst(
    .txclkesc               (txclkesc                                         ),
    .frd_sot                (frd_sot                                          ),
    .master_pin             (master_pin                                       ),
    .mas_stopstate_clk      (mas_stopstate_clk                                ),
    .slv_stopstate_clk      (slv_stopstate_clk                                ),
    .ulpsactivenotclk_s     (ulpsactivenotclk_s                               ),
    .ulpsactivenotclk       (ulpsactivenotclk                                 ),
    
    .sig_lp_tx_cntrl_0      (sig_lp_tx_cntrl_0                                ),
    .sig_hs_tx_cntrl_0      (sig_hs_tx_cntrl_0                                ),
    .stopstate_0            (stopstate_0                                      ),
    .stop_state_data_0      (stop_state_data_0                                ),
    .direction_frm_txr_0    (direction_frm_txr_0                              ),
    .ulps_active_not_dl_0   (ulps_active_not_dl_0                             ),
    .ulpsactivenot_s_0      (ulpsactivenot_s_0                                ),
    .lp_cd_d0_0             (lp_cd_d0_0                                       ),
    .lp_cd_d1_0             (lp_cd_d1_0                                       ),
                                                                              
    .sig_lp_tx_cntrl_1      (sig_lp_tx_cntrl_1                                ),
    .sig_hs_tx_cntrl_1      (sig_hs_tx_cntrl_1                                ),
    .stopstate_1            (stopstate_1                                      ),
    .stop_state_data_1      (stop_state_data_1                                ),
    .direction_frm_txr_1    (direction_frm_txr_1                              ),
    .ulps_active_not_dl_1   (ulps_active_not_dl_1                             ),
    .ulpsactivenot_s_1      (ulpsactivenot_s_1                                ),
    .lp_cd_d0_1             (lp_cd_d0_1                                       ),
    .lp_cd_d1_1             (lp_cd_d1_1                                       ),
    
    .sig_lp_tx_cntrl_2      (sig_lp_tx_cntrl_2                                ),
    .sig_hs_tx_cntrl_2      (sig_hs_tx_cntrl_2                                ),
    .stopstate_2            (stopstate_2                                      ),
    .stop_state_data_2      (stop_state_data_2                                ),
    .direction_frm_txr_2    (direction_frm_txr_2                              ),
    .ulps_active_not_dl_2   (ulps_active_not_dl_2                             ),
    .ulpsactivenot_s_2      (ulpsactivenot_s_2                                ),
    .lp_cd_d0_2             (lp_cd_d0_2                                       ),
    .lp_cd_d1_2             (lp_cd_d1_2                                       ),
    
    .sig_lp_tx_cntrl_3      (sig_lp_tx_cntrl_3                                ),
    .sig_hs_tx_cntrl_3      (sig_hs_tx_cntrl_3                                ),
    .stopstate_3            (stopstate_3                                      ),
    .stop_state_data_3      (stop_state_data_3                                ),
    .direction_frm_txr_3    (direction_frm_txr_3                              ),
    .ulps_active_not_dl_3   (ulps_active_not_dl_3                             ),
    .ulpsactivenot_s_3      (ulpsactivenot_s_3                                ),
    .lp_cd_d0_3             (lp_cd_d0_3                                       ),
    .lp_cd_d1_3             (lp_cd_d1_3                                       ),
   
    .sig_lp_tx_cntrl_4      (sig_lp_tx_cntrl_4                                ),
    .sig_hs_tx_cntrl_4      (sig_hs_tx_cntrl_4                                ),
    .stopstate_4            (stopstate_4                                      ),
    .stop_state_data_4      (stop_state_data_4                                ),
    .direction_frm_txr_4    (direction_frm_txr_4                              ),
    .ulps_active_not_dl_4   (ulps_active_not_dl_4                             ),
    .ulpsactivenot_s_4      (ulpsactivenot_s_4                                ),
    .lp_cd_d0_4             (lp_cd_d0_4                                       ),
    .lp_cd_d1_4             (lp_cd_d1_4                                       ),

    .sig_lp_tx_cntrl_5      (sig_lp_tx_cntrl_5                                ),
    .sig_hs_tx_cntrl_5      (sig_hs_tx_cntrl_5                                ),
    .stopstate_5            (stopstate_5                                      ),
    .stop_state_data_5      (stop_state_data_5                                ),
    .direction_frm_txr_5    (direction_frm_txr_5                              ),
    .ulps_active_not_dl_5   (ulps_active_not_dl_5                             ),
    .ulpsactivenot_s_5      (ulpsactivenot_s_5                                ),
    .lp_cd_d0_5             (lp_cd_d0_5                                       ),
    .lp_cd_d1_5             (lp_cd_d1_5                                       ),

   .sig_lp_tx_cntrl_6       (sig_lp_tx_cntrl_6                                ),
    .sig_hs_tx_cntrl_6      (sig_hs_tx_cntrl_6                                ),
    .stopstate_6            (stopstate_6                                      ),
    .stop_state_data_6      (stop_state_data_6                                ),
    .direction_frm_txr_6    (direction_frm_txr_6                              ),
    .ulps_active_not_dl_6   (ulps_active_not_dl_6                             ),
    .ulpsactivenot_s_6      (ulpsactivenot_s_6                                ),
    .lp_cd_d0_6             (lp_cd_d0_6                                       ),
    .lp_cd_d1_6             (lp_cd_d1_6                                       ),

   .sig_lp_tx_cntrl_7       (sig_lp_tx_cntrl_7                                ),
    .sig_hs_tx_cntrl_7      (sig_hs_tx_cntrl_7                                ),
    .stopstate_7            (stopstate_7                                      ),
    .stop_state_data_7      (stop_state_data_7                                ),
    .direction_frm_txr_7    (direction_frm_txr_7                              ),
    .ulps_active_not_dl_7   (ulps_active_not_dl_7                             ),
    .ulpsactivenot_s_7      (ulpsactivenot_s_7                                ),
    .lp_cd_d0_7             (lp_cd_d0_7                                       ),
    .lp_cd_d1_7             (lp_cd_d1_7                                       ),
                                                                              
    .eot_txr_0              (eot_txr_0                                        ),
                                                                              
    .txescclk_rst_n         (txescclk_rst_n                                   ),
                                                                              
    .eot_txr_sync_out_0     (eot_txr_sync_out_0                               ),
    .slave                  (slave                                            ),
    .syc_sot_frm_clk        (syc_sot_frm_clk                                  ),
    .stopstate_clk          (stopstate_clk                                    ),
                                                                              
    .lp_tx_cntrl_0          (lp_tx_cntrl_0                                    ),
    .hs_tx_cntrl_0          (hs_tx_cntrl_0                                    ),
    .stopstate_dat_0        (stopstate_dat_0                                  ),
    .ulpsactivenot_0_n      (ulpsactivenot_0_n                                ),
    .direction_0            (direction_0                                      ),
    .errcontentionlp0_0     (errcontentionlp0_0                               ),
    .errcontentionlp1_0     (errcontentionlp1_0                               ),
                                                                              
    .lp_tx_cntrl_1          (lp_tx_cntrl_1                                    ),
    .hs_tx_cntrl_1          (hs_tx_cntrl_1                                    ),
    .stopstate_dat_1        (stopstate_dat_1                                  ),
    .ulpsactivenot_1_n      (ulpsactivenot_1_n                                ),
    .direction_1            (direction_1                                      ),
    .errcontentionlp0_1     (errcontentionlp0_1                               ),
    .errcontentionlp1_1     (errcontentionlp1_1                               ),
                                                                              
    .lp_tx_cntrl_2          (lp_tx_cntrl_2                                    ),
    .hs_tx_cntrl_2          (hs_tx_cntrl_2                                    ),
    .stopstate_dat_2        (stopstate_dat_2                                  ),
    .ulpsactivenot_2_n      (ulpsactivenot_2_n                                ),
    .direction_2            (direction_2                                      ),
    .errcontentionlp0_2     (errcontentionlp0_2                               ),
    .errcontentionlp1_2     (errcontentionlp1_2                               ),
                                                                              
    .lp_tx_cntrl_3          (lp_tx_cntrl_3                                    ),
    .hs_tx_cntrl_3          (hs_tx_cntrl_3                                    ),
    .stopstate_dat_3        (stopstate_dat_3                                  ),
    .ulpsactivenot_3_n      (ulpsactivenot_3_n                                ),
    .direction_3            (direction_3                                      ),
    .errcontentionlp0_3     (errcontentionlp0_3                               ),
    .errcontentionlp1_3     (errcontentionlp1_3                               ),
                                                                              
    .lp_tx_cntrl_4          (lp_tx_cntrl_4                                    ),
    .hs_tx_cntrl_4          (hs_tx_cntrl_4                                    ),
    .stopstate_dat_4        (stopstate_dat_4                                  ),
    .ulpsactivenot_4_n      (ulpsactivenot_4_n                                ),
    .direction_4            (direction_4                                      ),
    .errcontentionlp0_4     (errcontentionlp0_4                               ),
    .errcontentionlp1_4     (errcontentionlp1_4                               ),

    .lp_tx_cntrl_5          (lp_tx_cntrl_5                                    ),
    .hs_tx_cntrl_5          (hs_tx_cntrl_5                                    ),
    .stopstate_dat_5        (stopstate_dat_5                                  ),
    .ulpsactivenot_5_n      (ulpsactivenot_5_n                                ),
    .direction_5            (direction_5                                      ),
    .errcontentionlp0_5     (errcontentionlp0_5                               ),
    .errcontentionlp1_5     (errcontentionlp1_5                               ),

    .lp_tx_cntrl_6          (lp_tx_cntrl_6                                    ),
    .hs_tx_cntrl_6          (hs_tx_cntrl_6                                    ),
    .stopstate_dat_6        (stopstate_dat_6                                  ),
    .ulpsactivenot_6_n      (ulpsactivenot_6_n                                ),
    .direction_6            (direction_6                                      ),
    .errcontentionlp0_6     (errcontentionlp0_6                               ),
    .errcontentionlp1_6     (errcontentionlp1_6                               ),

    .lp_tx_cntrl_7          (lp_tx_cntrl_7                                    ),
    .hs_tx_cntrl_7          (hs_tx_cntrl_7                                    ),
    .stopstate_dat_7        (stopstate_dat_7                                  ),
    .ulpsactivenot_7_n      (ulpsactivenot_7_n                                ),
    .direction_7            (direction_7                                      ),
    .errcontentionlp0_7     (errcontentionlp0_7                               ),
    .errcontentionlp1_7     (errcontentionlp1_7                               ),
                                                                              
    .ulpsactivenot_clk_n    (ulpsactivenot_clk_n                              )
    
    
    );
  
  
  
  //**************************************************
  // INSTANTIATION OF CLOCK LANE TOP MODULE
  //****************************************************
  
  csi2tx_dphy_clock_top u_csi2tx_dphy_clock_top(
    
    .txclkesc               (txclkesc                                         ),
    .txddr_q_rst_n          (txddr_q_rst_n                                    ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .txddrclkhs_q           (txddrclkhs_q                                     ),
    .txrequesths_clk        (txrequesths_clk                                  ),
    .txulpsclk              (txulpsclk                                        ),
    .txulpsexit_clk         (txulpsexit_clk                                   ),
    .slave                  (slave                                            ),
    .lp_rx_cp_clk           (lp_rx_cp_clk                                     ),
    .lp_rx_cn_clk           (lp_rx_cn_clk                                     ),
    .slv_stopstate_clk      (slv_stopstate_clk                                ),
    .cln_cnt_hs_prep        (cln_cnt_hs_prep                                  ),
    .cln_cnt_hs_zero        (cln_cnt_hs_zero                                  ),
    .cln_cnt_hs_trail       (cln_cnt_hs_trail                                 ),
    .cln_cnt_hs_exit        (cln_cnt_hs_exit                                  ),
    .cln_cnt_lpx            (cln_cnt_lpx                                      ),
    .eot_txr_sync_out_0     (eot_txr_sync_out_0                               ),
    .lp_tx_cntrl_clk        (lp_tx_cntrl_clk                                  ),
    .lp_tx_cp_clk           (lp_tx_cp_clk                                     ),
    .lp_tx_cn_clk           (lp_tx_cn_clk                                     ),
    .hs_txclk_cp            (hs_tx_cp_clk                                     ),
    .hs_tx_cntrl_clk        (hs_tx_cntrl_clk                                  ),
    .frd_sot                (frd_sot                                          ),
    .ulpsactivenotclk_s     (ulpsactivenotclk_s                               ),
    .mas_stopstate_clk      (mas_stopstate_clk                                ),
                                                                              
    .rxulpsclknot           (rxulpsclknot_n                                   ),
    .ulpsactivenotclk       (ulpsactivenotclk                                 ),
    .rxclkactivehs          (rxclkactivehs                                    ),
    .hs_rx_cntrl_clk        (hs_rx_cntrl_clk                                  ),
    .lp_rx_cntrl_clk        (lp_rx_cntrl_clk                                  ),
    .rev_sot                (rev_sot                                          )
    );
  
  
  //**************************************************
  // INSTANTIATION OF DATA LANE TOP MODULE
  //****************************************************
  csi2tx_dphy_data_top u_csi2tx_dphy_data_top_inst_0(
    .txclkesc               (txclkesc                                         ),
                                     
    .txddr_i_rst_n          (txddr_i_rst_n                                    ),
    .rxddr_rst_n            (rxddr_rst_n                                      ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .rxescclk_rst_n         (rxescclk_rst_0_n                                 ),
    .tx_byte_rst_n          (tx_byte_rst_n                                    ),
    .rx_byte_rst_n          (rx_byte_rst_n                                    ),
    .master_pin             (master_pin                                       ),
    .tx_hs_clk              (txddrclkhs_i                                     ),
    .forcerxmode            (forcerxmode                                      ),
    .forcetxstopmode        (forcetxstopmode                                  ),
    .syc_sot_frm_clk        (syc_sot_frm_clk                                  ),
    .sot_sequence           (sot_sequence                                     ), 
    .force_sot_error        (force_sot_error                                  ), 
    .force_control_error    (force_control_error                              ),
    .force_error_esc        (force_error_esc                                  ),
    .txrequesths            (txrequesths_0                                    ),
    .tx_skewcallhs          (tx_skewcallhs[0]                                 ),
    .txdatahs               (txdatahs_0                                       ),
    .txrequestesc           (txrequestesc_0                                   ),
    .txlpdtesc              (txlpdtesc_0                                      ),
    .txulpsesc              (txulpsesc_0                                      ),
    .txtriggeresc           (txtriggeresc_0                                   ),
    .txdataesc              (txdataesc_0                                      ),
    .txvalidesc             (txvalidesc_0                                     ),
    .txulpsexit             (txulpsexit_0                                     ),
    .turnrequest            (turnrequest_0                                    ),
    .turndisable            (turndisable_0                                    ),
    .txbyteclkhs            (txbyteclkhs                                      ),
    .slave(slave),                                                            
    .rx_hs_clk              (hs_rx_clk                                        ),
    .rxbyteclkhs            (rxbyteclkhs                                      ),
    .lp_rx_dp               (lp_rx_dp_0                                       ),
    .lp_rx_dn               (lp_rx_dn_0                                       ),
    .hs_rx                  (hs_rx_0                                          ),
    .direction              (direction_frm_txr_0                              ),
    .txreadyhs              (txreadyhs_0                                      ),
    .txreadyesc             (txreadyesc_0                                     ),
    .ulpsactivenot_s        (ulpsactivenot_s_0                                ),
    .sig_hs_tx_cntrl        (sig_hs_tx_cntrl_0                                ),
    .hs_tx_dp               (hs_tx_dp_0                                       ),
    .sig_lp_tx_cntrl        (sig_lp_tx_cntrl_0                                ),
    .lp_tx_dp               (lp_tx_dp_0                                       ),
    .lp_tx_dn               (lp_tx_dn_0                                       ),
    .stopstate              (stopstate_0                                      ),
    .eot_txr                (eot_txr_0                                        ),
    .rxactivehs             (rxactivehs_0                                     ),
    .rxdatahs               (rxdatahs_0                                       ),
    .rxvalidhs              (rxvalidhs_0                                      ),
    .rxsynchs               (rxsynchs_0                                       ),
    .rxdataesc              (rxdataesc_0                                      ),
    .rxvalidesc             (rxvalidesc_0                                     ),
    .rxtriggeresc           (rxtriggeresc_0                                   ),
    .rxulpsesc              (rxulpsesc_0                                      ),
    .rxskewcallhs           (rxskewcallhs_0                                   ),
    .ulps_active_not_dl     (ulps_active_not_dl_0                             ),
    .rxlpdtesc              (rxlpdtesc_0                                      ),
    .rxclkesc               (rxclkesc_0                                       ),
    .eot_handle_proc        (eot_handle_proc                                  ),
    .dln_cnt_hs_prep        (dln_cnt_hs_prep                                  ),
    .dln_cnt_hs_zero        (dln_cnt_hs_zero                                  ),
    .dln_cnt_hs_trail       (dln_cnt_hs_trail                                 ),
    .dln_cnt_hs_exit        (dln_cnt_hs_exit                                  ),
    .dln_cnt_lpx            (dln_cnt_lpx                                      ),
    .errsoths               (errsoths_0                                       ),
    .errsotsynchs           (errsotsynchs_0                                   ),
    .erresc                 (erresc_0                                         ),
    .errsyncesc             (errsyncesc_0                                     ),
    .errcontrol             (errcontrol_0                                     ),
    .stop_state_data        (stop_state_data_0                                ),
    .hs_rx_cntrl            (hs_rx_cntrl_0                                    ),
    .lp_rx_cntrl            (lp_rx_cntrl_0                                    )
    
    
    );
  
  //**************************************************
  // INSTANTIATION OF DATA LANE TOP MODULE
  //****************************************************
  csi2tx_dphy_data_top u_csi2tx_dphy_data_top_inst_1(
    .txclkesc               (txclkesc                                         ),
                                                                              
    .txddr_i_rst_n          (txddr_i_rst_n                                    ),
    .rxddr_rst_n            (rxddr_rst_n                                      ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .rxescclk_rst_n         (rxescclk_rst_1_n                                 ),
    .tx_byte_rst_n          (tx_byte_rst_n                                    ),
    .rx_byte_rst_n          (rx_byte_rst_n                                    ),
    .master_pin             (master_pin                                       ),
    .tx_hs_clk              (txddrclkhs_i                                     ),
    .forcerxmode            (forcerxmode                                      ),
    .forcetxstopmode        (forcetxstopmode                                  ),
    .syc_sot_frm_clk        (syc_sot_frm_clk                                  ),
    .sot_sequence           (sot_sequence                                     ), 
    .force_sot_error        (force_sot_error                                  ), 
    .force_control_error    (force_control_error                              ),
    .force_error_esc        (force_error_esc                                  ),
    .txrequesths            (txrequesths_1                                    ),
    .tx_skewcallhs          (tx_skewcallhs[1]                                 ),
    .txdatahs               (txdatahs_1                                       ),
    .txrequestesc           (txrequestesc_1                                   ),
    .txlpdtesc              (txlpdtesc_1                                      ),
    .txulpsesc              (txulpsesc_1                                      ),
    .txtriggeresc           (txtriggeresc_1                                   ),
    .txdataesc              (txdataesc_1                                      ),
    .txvalidesc             (txvalidesc_1                                     ),
    .txulpsexit             (txulpsexit_1                                     ),
    .turnrequest            (turnrequest_1                                    ),
    .turndisable            (turndisable_1                                    ),
    .txbyteclkhs            (txbyteclkhs                                      ),
    .slave                  (slave                                            ),
    .rx_hs_clk              (hs_rx_clk                                        ),
    .rxbyteclkhs            (rxbyteclkhs                                      ),
    .lp_rx_dp               (lp_rx_dp_1                                       ),
    .lp_rx_dn               (lp_rx_dn_1                                       ),
    .hs_rx                  (hs_rx_1                                          ),
    .direction              (direction_frm_txr_1                              ),
    .txreadyhs              (txreadyhs_1                                      ),
    .txreadyesc             (txreadyesc_1                                     ),
    .ulpsactivenot_s        (ulpsactivenot_s_1                                ),
    .sig_hs_tx_cntrl        (sig_hs_tx_cntrl_1                                ),
    .hs_tx_dp               (hs_tx_dp_1                                       ),
    .sig_lp_tx_cntrl        (sig_lp_tx_cntrl_1                                ),
    .lp_tx_dp               (lp_tx_dp_1                                       ),
    .lp_tx_dn               (lp_tx_dn_1                                       ),
    .stopstate              (stopstate_1                                      ),
    .eot_txr                (                                                 ),
    .rxactivehs             (rxactivehs_1                                     ),
    .rxdatahs               (rxdatahs_1                                       ),
    .rxvalidhs              (rxvalidhs_1                                      ),
    .rxsynchs               (rxsynchs_1                                       ),
    .rxdataesc              (rxdataesc_1                                      ),
    .rxvalidesc             (rxvalidesc_1                                     ),
    .rxtriggeresc           (rxtriggeresc_1                                   ),
    .rxulpsesc              (rxulpsesc_1                                      ),
    .rxskewcallhs           (rxskewcallhs_1                                   ),
    .ulps_active_not_dl     (ulps_active_not_dl_1                             ),
    .rxlpdtesc              (rxlpdtesc_1                                      ),
    .rxclkesc               (rxclkesc_1                                       ),
    .eot_handle_proc        (eot_handle_proc                                  ),
    .dln_cnt_hs_prep        (dln_cnt_hs_prep                                  ),
    .dln_cnt_hs_zero        (dln_cnt_hs_zero                                  ),
    .dln_cnt_hs_trail       (dln_cnt_hs_trail                                 ),
    .dln_cnt_hs_exit        (dln_cnt_hs_exit                                  ),
    .dln_cnt_lpx            (dln_cnt_lpx                                      ),
    .errsoths               (errsoths_1                                       ),
    .errsotsynchs           (errsotsynchs_1                                   ),
    .erresc                 (erresc_1                                         ),
    .errsyncesc             (errsyncesc_1                                     ),
    .errcontrol             (errcontrol_1                                     ),
    .stop_state_data        (stop_state_data_1                                ),
    .hs_rx_cntrl            (hs_rx_cntrl_1                                    ),
    .lp_rx_cntrl            (lp_rx_cntrl_1                                    )
    
    
    );
  
  //**************************************************
  // INSTANTIATION OF DATA LANE TOP MODULE
  //****************************************************
  csi2tx_dphy_data_top u_csi2tx_dphy_data_top_inst_2(
    .txclkesc               (txclkesc                                         ),
    .txddr_i_rst_n          (txddr_i_rst_n                                    ),
    .rxddr_rst_n            (rxddr_rst_n                                      ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .rxescclk_rst_n         (rxescclk_rst_2_n                                 ),
    .tx_byte_rst_n          (tx_byte_rst_n                                    ),
    .rx_byte_rst_n          (rx_byte_rst_n                                    ),
    .master_pin             (master_pin                                       ),
    .tx_hs_clk              (txddrclkhs_i                                     ),
    .forcerxmode            (forcerxmode                                      ),
    .forcetxstopmode        (forcetxstopmode                                  ),
    .syc_sot_frm_clk        (syc_sot_frm_clk                                  ),
    .sot_sequence           (sot_sequence                                     ), 
    .force_sot_error        (force_sot_error                                  ), 
    .force_control_error    (force_control_error                              ), 
    .force_error_esc        (force_error_esc                                  ),
    .txrequesths            (txrequesths_2                                    ),
    .tx_skewcallhs          (tx_skewcallhs[2]                                 ),
    .txdatahs               (txdatahs_2                                       ),
    .txrequestesc           (txrequestesc_2                                   ),
    .txlpdtesc              (txlpdtesc_2                                      ),
    .txulpsesc              (txulpsesc_2                                      ),
    .txtriggeresc           (txtriggeresc_2                                   ),
    .txdataesc              (txdataesc_2                                      ),
    .txvalidesc             (txvalidesc_2                                     ),
    .txulpsexit             (txulpsexit_2                                     ),
    .turnrequest            (turnrequest_2                                    ),
    .turndisable            (turndisable_2                                    ),
    .txbyteclkhs            (txbyteclkhs                                      ),
    .slave                  (slave                                            ),
    .rx_hs_clk              (hs_rx_clk                                        ),
    .rxbyteclkhs            (rxbyteclkhs                                      ),
    .lp_rx_dp               (lp_rx_dp_2                                       ),
    .lp_rx_dn               (lp_rx_dn_2                                       ),
    .hs_rx                  (hs_rx_2                                          ),
    .direction              (direction_frm_txr_2                              ),
    .txreadyhs              (txreadyhs_2                                      ),
    .txreadyesc             (txreadyesc_2                                     ),
    .ulpsactivenot_s        (ulpsactivenot_s_2                                ),
    .sig_hs_tx_cntrl        (sig_hs_tx_cntrl_2                                ),
    .hs_tx_dp               (hs_tx_dp_2                                       ),
    .sig_lp_tx_cntrl        (sig_lp_tx_cntrl_2                                ),
    .lp_tx_dp               (lp_tx_dp_2                                       ),
    .lp_tx_dn               (lp_tx_dn_2                                       ),
    .stopstate              (stopstate_2                                      ),
    .eot_txr                (                                                 ),
    .rxactivehs             (rxactivehs_2                                     ),
    .rxdatahs               (rxdatahs_2                                       ),
    .rxvalidhs              (rxvalidhs_2                                      ),
    .rxsynchs               (rxsynchs_2                                       ),
    .rxdataesc              (rxdataesc_2                                      ),
    .rxvalidesc             (rxvalidesc_2                                     ),
    .rxtriggeresc           (rxtriggeresc_2                                   ),
    .rxulpsesc              (rxulpsesc_2                                      ),
    .rxskewcallhs           (rxskewcallhs_2                                   ),
    .ulps_active_not_dl     (ulps_active_not_dl_2                             ),
    .rxlpdtesc              (rxlpdtesc_2                                      ),
    .rxclkesc               (rxclkesc_2                                       ),
    .eot_handle_proc        (eot_handle_proc                                  ),
    .dln_cnt_hs_prep        (dln_cnt_hs_prep                                  ),
    .dln_cnt_hs_zero        (dln_cnt_hs_zero                                  ),
    .dln_cnt_hs_trail       (dln_cnt_hs_trail                                 ),
    .dln_cnt_hs_exit        (dln_cnt_hs_exit                                  ),
    .dln_cnt_lpx            (dln_cnt_lpx                                      ),
    .errsoths               (errsoths_2                                       ),
    .errsotsynchs           (errsotsynchs_2                                   ),
    .erresc                 (erresc_2                                         ),
    .errsyncesc             (errsyncesc_2                                     ),
    .errcontrol             (errcontrol_2                                     ),
    .stop_state_data        (stop_state_data_2                                ),
    .hs_rx_cntrl            (hs_rx_cntrl_2                                    ),
    .lp_rx_cntrl            (lp_rx_cntrl_2                                    )
    
    
    );
  
  //**************************************************
  // INSTANTIATION OF DATA LANE TOP MODULE
  //****************************************************
  csi2tx_dphy_data_top u_csi2tx_dphy_data_top_inst_3(
    .txclkesc               (txclkesc                                         ),
    .txddr_i_rst_n          (txddr_i_rst_n                                    ),
    .rxddr_rst_n            (rxddr_rst_n                                      ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .rxescclk_rst_n         (rxescclk_rst_3_n                                 ),
    .tx_byte_rst_n          (tx_byte_rst_n                                    ),
    .rx_byte_rst_n          (rx_byte_rst_n                                    ),
    .master_pin             (master_pin                                       ),
    .tx_hs_clk              (txddrclkhs_i                                     ),
    .forcerxmode            (forcerxmode                                      ),
    .forcetxstopmode        (forcetxstopmode                                  ),
    .syc_sot_frm_clk        (syc_sot_frm_clk                                  ),
    .sot_sequence           (sot_sequence                                     ), 
    .force_sot_error        (force_sot_error                                  ), 
    .force_control_error    (force_control_error                              ),
    .force_error_esc        (force_error_esc                                  ),
    .txrequesths            (txrequesths_3                                    ),
    .tx_skewcallhs          (tx_skewcallhs[3]                                 ),
    .txdatahs               (txdatahs_3                                       ),
    .txrequestesc           (txrequestesc_3                                   ),
    .txlpdtesc              (txlpdtesc_3                                      ),
    .txulpsesc              (txulpsesc_3                                      ),
    .txtriggeresc           (txtriggeresc_3                                   ),
    .txdataesc              (txdataesc_3                                      ),
    .txvalidesc             (txvalidesc_3                                     ),
    .txulpsexit             (txulpsexit_3                                     ),
    .turnrequest            (turnrequest_3                                    ),
    .turndisable            (turndisable_3                                    ),
    .txbyteclkhs            (txbyteclkhs                                      ),
    .slave                  (slave                                            ),
    .rx_hs_clk              (hs_rx_clk                                        ),
    .rxbyteclkhs            (rxbyteclkhs                                      ),
    .lp_rx_dp               (lp_rx_dp_3                                       ),
    .lp_rx_dn               (lp_rx_dn_3                                       ),
    .hs_rx                  (hs_rx_3                                          ),
    .direction              (direction_frm_txr_3                              ),
    .txreadyhs              (txreadyhs_3                                      ),
    .txreadyesc             (txreadyesc_3                                     ),
    .ulpsactivenot_s        (ulpsactivenot_s_3                                ),
    .sig_hs_tx_cntrl        (sig_hs_tx_cntrl_3                                ),
    .hs_tx_dp               (hs_tx_dp_3                                       ),
    .sig_lp_tx_cntrl        (sig_lp_tx_cntrl_3                                ),
    .lp_tx_dp               (lp_tx_dp_3                                       ),
    .lp_tx_dn               (lp_tx_dn_3                                       ),
    .stopstate              (stopstate_3                                      ),
    .eot_txr                (                                                 ),
    .rxactivehs             (rxactivehs_3                                     ),
    .rxdatahs               (rxdatahs_3                                       ),
    .rxvalidhs              (rxvalidhs_3                                      ),
    .rxsynchs               (rxsynchs_3                                       ),
    .rxdataesc              (rxdataesc_3                                      ),
    .rxvalidesc             (rxvalidesc_3                                     ),
    .rxtriggeresc           (rxtriggeresc_3                                   ),
    .rxulpsesc              (rxulpsesc_3                                      ),
    .rxskewcallhs           (rxskewcallhs_3                                   ),
    .ulps_active_not_dl     (ulps_active_not_dl_3                             ),
    .rxlpdtesc              (rxlpdtesc_3                                      ),
    .rxclkesc               (rxclkesc_3                                       ),
    .eot_handle_proc        (eot_handle_proc                                  ),
    .dln_cnt_hs_prep        (dln_cnt_hs_prep                                  ),
    .dln_cnt_hs_zero        (dln_cnt_hs_zero                                  ),
    .dln_cnt_hs_trail       (dln_cnt_hs_trail                                 ),
    .dln_cnt_hs_exit        (dln_cnt_hs_exit                                  ),
    .dln_cnt_lpx            (dln_cnt_lpx                                      ),
    .errsoths               (errsoths_3                                       ),
    .errsotsynchs           (errsotsynchs_3                                   ),
    .erresc                 (erresc_3                                         ),
    .errsyncesc             (errsyncesc_3                                     ),
    .errcontrol             (errcontrol_3                                     ),
    .stop_state_data        (stop_state_data_3                                ),
    .hs_rx_cntrl            (hs_rx_cntrl_3                                    ),
    .lp_rx_cntrl            (lp_rx_cntrl_3                                    )
    
    
    );


  //**************************************************
  // INSTANTIATION OF DATA LANE TOP MODULE
  //****************************************************
  csi2tx_dphy_data_top u_csi2tx_dphy_data_top_inst_4(
    .txclkesc               (txclkesc                                         ),
    .txddr_i_rst_n          (txddr_i_rst_n                                    ),
    .rxddr_rst_n            (rxddr_rst_n                                      ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .rxescclk_rst_n         (rxescclk_rst_4_n                                 ),
    .tx_byte_rst_n          (tx_byte_rst_n                                    ),
    .rx_byte_rst_n          (rx_byte_rst_n                                    ),
    .master_pin             (master_pin                                       ),
    .tx_hs_clk              (txddrclkhs_i                                     ),
    .forcerxmode            (forcerxmode                                      ),
    .forcetxstopmode        (forcetxstopmode                                  ),
    .syc_sot_frm_clk        (syc_sot_frm_clk                                  ),
    .sot_sequence           (sot_sequence                                     ), 
    .force_sot_error        (force_sot_error                                  ), 
    .force_control_error    (force_control_error                              ), 
    .force_error_esc        (force_error_esc                                  ),
    .txrequesths            (txrequesths_4                                    ),
    .tx_skewcallhs          (tx_skewcallhs[4]                                 ),
    .txdatahs               (txdatahs_4                                       ),
    .txrequestesc           (txrequestesc_4                                   ),
    .txlpdtesc              (txlpdtesc_4                                      ),
    .txulpsesc              (txulpsesc_4                                      ),
    .txtriggeresc           (txtriggeresc_4                                   ),
    .txdataesc              (txdataesc_4                                      ),
    .txvalidesc             (txvalidesc_4                                     ),
    .txulpsexit             (txulpsexit_4                                     ),
    .turnrequest            (turnrequest_4                                    ),
    .turndisable            (turndisable_4                                    ),
    .txbyteclkhs            (txbyteclkhs                                      ),
    .slave                  (slave                                            ),
    .rx_hs_clk              (hs_rx_clk                                        ),
    .rxbyteclkhs            (rxbyteclkhs                                      ),
    .lp_rx_dp               (lp_rx_dp_4                                       ),
    .lp_rx_dn               (lp_rx_dn_4                                       ),
    .hs_rx                  (hs_rx_4                                          ),
    .direction              (direction_frm_txr_4                              ),
    .txreadyhs              (txreadyhs_4                                      ),
    .txreadyesc             (txreadyesc_4                                     ),
    .ulpsactivenot_s        (ulpsactivenot_s_4                                ),
    .sig_hs_tx_cntrl        (sig_hs_tx_cntrl_4                                ),
    .hs_tx_dp               (hs_tx_dp_4                                       ),
    .sig_lp_tx_cntrl        (sig_lp_tx_cntrl_4                                ),
    .lp_tx_dp               (lp_tx_dp_4                                       ),
    .lp_tx_dn               (lp_tx_dn_4                                       ),
    .stopstate              (stopstate_4                                      ),
    .eot_txr                (                                                 ),
    .rxactivehs             (rxactivehs_4                                     ),
    .rxdatahs               (rxdatahs_4                                       ),
    .rxvalidhs              (rxvalidhs_4                                      ),
    .rxsynchs               (rxsynchs_4                                       ),
    .rxdataesc              (rxdataesc_4                                      ),
    .rxvalidesc             (rxvalidesc_4                                     ),
    .rxtriggeresc           (rxtriggeresc_4                                   ),
    .rxulpsesc              (rxulpsesc_4                                      ),
    .rxskewcallhs           (rxskewcallhs_4                                   ),
    .ulps_active_not_dl     (ulps_active_not_dl_4                             ),
    .rxlpdtesc              (rxlpdtesc_4                                      ),
    .rxclkesc               (rxclkesc_4                                       ),
    .eot_handle_proc        (eot_handle_proc                                  ),
    .dln_cnt_hs_prep        (dln_cnt_hs_prep                                  ),
    .dln_cnt_hs_zero        (dln_cnt_hs_zero                                  ),
    .dln_cnt_hs_trail       (dln_cnt_hs_trail                                 ),
    .dln_cnt_hs_exit        (dln_cnt_hs_exit                                  ),
    .dln_cnt_lpx            (dln_cnt_lpx                                      ),
    .errsoths               (errsoths_4                                       ),
    .errsotsynchs           (errsotsynchs_4                                   ),
    .erresc                 (erresc_4                                         ),
    .errsyncesc             (errsyncesc_4                                     ),
    .errcontrol             (errcontrol_4                                     ),
    .stop_state_data        (stop_state_data_4                                ),
    .hs_rx_cntrl            (hs_rx_cntrl_4                                    ),
    .lp_rx_cntrl            (lp_rx_cntrl_4                                    )
    
    
    );
  

  //**************************************************
  // INSTANTIATION OF DATA LANE TOP MODULE
  //****************************************************
   csi2tx_dphy_data_top u_csi2tx_dphy_data_top_inst_5(
    .txclkesc               (txclkesc                                         ),
    .txddr_i_rst_n          (txddr_i_rst_n                                    ),
    .rxddr_rst_n            (rxddr_rst_n                                      ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .rxescclk_rst_n         (rxescclk_rst_5_n                                 ),
    .tx_byte_rst_n          (tx_byte_rst_n                                    ),
    .rx_byte_rst_n          (rx_byte_rst_n                                    ),
    .master_pin             (master_pin                                       ),
    .tx_hs_clk              (txddrclkhs_i                                     ),
    .forcerxmode            (forcerxmode                                      ),
    .forcetxstopmode        (forcetxstopmode                                  ),
    .syc_sot_frm_clk        (syc_sot_frm_clk                                  ),
    .sot_sequence           (sot_sequence                                     ), 
    .force_sot_error        (force_sot_error                                  ), 
    .force_control_error    (force_control_error                              ),
    .force_error_esc        (force_error_esc                                  ),
    .txrequesths            (txrequesths_5                                    ),
    .tx_skewcallhs          (tx_skewcallhs[5]                                 ),
    .txdatahs               (txdatahs_5                                       ),
    .txrequestesc           (txrequestesc_5                                   ),
    .txlpdtesc              (txlpdtesc_5                                      ),
    .txulpsesc              (txulpsesc_5                                      ),
    .txtriggeresc           (txtriggeresc_5                                   ),
    .txdataesc              (txdataesc_5                                      ),
    .txvalidesc             (txvalidesc_5                                     ),
    .txulpsexit             (txulpsexit_5                                     ),
    .turnrequest            (turnrequest_5                                    ),
    .turndisable            (turndisable_5                                    ),
    .txbyteclkhs            (txbyteclkhs                                      ),
    .slave                  (slave                                            ),
    .rx_hs_clk              (hs_rx_clk                                        ),
    .rxbyteclkhs            (rxbyteclkhs                                      ),
    .lp_rx_dp               (lp_rx_dp_5                                       ),
    .lp_rx_dn               (lp_rx_dn_5                                       ),
    .hs_rx                  (hs_rx_5                                          ),
    .direction              (direction_frm_txr_5                              ),
    .txreadyhs              (txreadyhs_5                                      ),
    .txreadyesc             (txreadyesc_5                                     ),
    .ulpsactivenot_s        (ulpsactivenot_s_5                                ),
    .sig_hs_tx_cntrl        (sig_hs_tx_cntrl_5                                ),
    .hs_tx_dp               (hs_tx_dp_5                                       ),
    .sig_lp_tx_cntrl        (sig_lp_tx_cntrl_5                                ),
    .lp_tx_dp               (lp_tx_dp_5                                       ),
    .lp_tx_dn               (lp_tx_dn_5                                       ),
    .stopstate              (stopstate_5                                      ),
    .eot_txr                (                                                 ),
    .rxactivehs             (rxactivehs_5                                     ),
    .rxdatahs               (rxdatahs_5                                       ),
    .rxvalidhs              (rxvalidhs_5                                      ),
    .rxsynchs               (rxsynchs_5                                       ),
    .rxdataesc              (rxdataesc_5                                      ),
    .rxvalidesc             (rxvalidesc_5                                     ),
    .rxtriggeresc           (rxtriggeresc_5                                   ),
    .rxulpsesc              (rxulpsesc_5                                      ),
    .rxskewcallhs           (rxskewcallhs_5                                   ),
    .ulps_active_not_dl     (ulps_active_not_dl_5                             ),
    .rxlpdtesc              (rxlpdtesc_5                                      ),
    .rxclkesc               (rxclkesc_5                                       ),
    .eot_handle_proc        (eot_handle_proc                                  ),
    .dln_cnt_hs_prep        (dln_cnt_hs_prep                                  ),
    .dln_cnt_hs_zero        (dln_cnt_hs_zero                                  ),
    .dln_cnt_hs_trail       (dln_cnt_hs_trail                                 ),
    .dln_cnt_hs_exit        (dln_cnt_hs_exit                                  ),
    .dln_cnt_lpx            (dln_cnt_lpx                                      ),
    .errsoths               (errsoths_5                                       ),
    .errsotsynchs           (errsotsynchs_5                                   ),
    .erresc                 (erresc_5                                         ),
    .errsyncesc             (errsyncesc_5                                     ),
    .errcontrol             (errcontrol_5                                     ),
    .stop_state_data        (stop_state_data_5                                ),
    .hs_rx_cntrl            (hs_rx_cntrl_5                                    ),
    .lp_rx_cntrl            (lp_rx_cntrl_5                                    )
    
    
    );
  

  //**************************************************
  // INSTANTIATION OF DATA LANE TOP MODULE
  //****************************************************
  csi2tx_dphy_data_top u_csi2tx_dphy_data_top_inst_6(
    .txclkesc               (txclkesc                                         ),
    .txddr_i_rst_n          (txddr_i_rst_n                                    ),
    .rxddr_rst_n            (rxddr_rst_n                                      ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .rxescclk_rst_n         (rxescclk_rst_6_n                                 ),
    .tx_byte_rst_n          (tx_byte_rst_n                                    ),
    .rx_byte_rst_n          (rx_byte_rst_n                                    ),
    .master_pin             (master_pin                                       ),
    .tx_hs_clk              (txddrclkhs_i                                     ),
    .forcerxmode            (forcerxmode                                      ),
    .forcetxstopmode        (forcetxstopmode                                  ),
    .syc_sot_frm_clk        (syc_sot_frm_clk                                  ),
    .sot_sequence           (sot_sequence                                     ), 
    .force_sot_error        (force_sot_error                                  ), 
    .force_control_error    (force_control_error                              ),
    .force_error_esc        (force_error_esc                                  ),
    .txrequesths            (txrequesths_6                                    ),
    .tx_skewcallhs          (tx_skewcallhs[6]                                 ),
    .txdatahs               (txdatahs_6                                       ),
    .txrequestesc           (txrequestesc_6                                   ),
    .txlpdtesc              (txlpdtesc_6                                      ),
    .txulpsesc              (txulpsesc_6                                      ),
    .txtriggeresc           (txtriggeresc_6                                   ),
    .txdataesc              (txdataesc_6                                      ),
    .txvalidesc             (txvalidesc_6                                     ),
    .txulpsexit             (txulpsexit_6                                     ),
    .turnrequest            (turnrequest_6                                    ),
    .turndisable            (turndisable_6                                    ),
    .txbyteclkhs            (txbyteclkhs                                      ),
    .slave                  (slave                                            ),
    .rx_hs_clk              (hs_rx_clk                                        ),
    .rxbyteclkhs            (rxbyteclkhs                                      ),
    .lp_rx_dp               (lp_rx_dp_6                                       ),
    .lp_rx_dn               (lp_rx_dn_6                                       ),
    .hs_rx                  (hs_rx_6                                          ),
    .direction              (direction_frm_txr_6                              ),
    .txreadyhs              (txreadyhs_6                                      ),
    .txreadyesc             (txreadyesc_6                                     ),
    .ulpsactivenot_s        (ulpsactivenot_s_6                                ),
    .sig_hs_tx_cntrl        (sig_hs_tx_cntrl_6                                ),
    .hs_tx_dp               (hs_tx_dp_6                                       ),
    .sig_lp_tx_cntrl        (sig_lp_tx_cntrl_6                                ),
    .lp_tx_dp               (lp_tx_dp_6                                       ),
    .lp_tx_dn               (lp_tx_dn_6                                       ),
    .stopstate              (stopstate_6                                      ),
    .eot_txr                (                                                 ),
    .rxactivehs             (rxactivehs_6                                     ),
    .rxdatahs               (rxdatahs_6                                       ),
    .rxvalidhs              (rxvalidhs_6                                      ),
    .rxsynchs               (rxsynchs_6                                       ),
    .rxdataesc              (rxdataesc_6                                      ),
    .rxvalidesc             (rxvalidesc_6                                     ),
    .rxtriggeresc           (rxtriggeresc_6                                   ),
    .rxulpsesc              (rxulpsesc_6                                      ),
    .rxskewcallhs           (rxskewcallhs_6                                   ),
    .ulps_active_not_dl     (ulps_active_not_dl_6                             ),
    .rxlpdtesc              (rxlpdtesc_6                                      ),
    .rxclkesc               (rxclkesc_6                                       ),
    .eot_handle_proc        (eot_handle_proc                                  ),
    .dln_cnt_hs_prep        (dln_cnt_hs_prep                                  ),
    .dln_cnt_hs_zero        (dln_cnt_hs_zero                                  ),
    .dln_cnt_hs_trail       (dln_cnt_hs_trail                                 ),
    .dln_cnt_hs_exit        (dln_cnt_hs_exit                                  ),
    .dln_cnt_lpx            (dln_cnt_lpx                                      ),
    .errsoths               (errsoths_6                                       ),
    .errsotsynchs           (errsotsynchs_6                                   ),
    .erresc                 (erresc_6                                         ),
    .errsyncesc             (errsyncesc_6                                     ),
    .errcontrol             (errcontrol_6                                     ),
    .stop_state_data        (stop_state_data_6                                ),
    .hs_rx_cntrl            (hs_rx_cntrl_6                                    ),
    .lp_rx_cntrl            (lp_rx_cntrl_6                                    )
    
    
    );
  
  //**************************************************
  // INSTANTIATION OF DATA LANE TOP MODULE
  //****************************************************
  csi2tx_dphy_data_top u_csi2tx_dphy_data_top_inst_7(
    .txclkesc               (txclkesc                                         ),
    .txddr_i_rst_n          (txddr_i_rst_n                                    ),
    .rxddr_rst_n            (rxddr_rst_n                                      ),
    .txescclk_rst_n         (txescclk_rst_n                                   ),
    .rxescclk_rst_n         (rxescclk_rst_7_n                                 ),
    .tx_byte_rst_n          (tx_byte_rst_n                                    ),
    .rx_byte_rst_n          (rx_byte_rst_n                                    ),
    .master_pin             (master_pin                                       ),
    .tx_hs_clk              (txddrclkhs_i                                     ),
    .forcerxmode            (forcerxmode                                      ),
    .forcetxstopmode        (forcetxstopmode                                  ),
    .syc_sot_frm_clk        (syc_sot_frm_clk                                  ),
    .sot_sequence           (sot_sequence                                     ), 
    .force_sot_error        (force_sot_error                                  ), 
    .force_control_error    (force_control_error                              ),
    .force_error_esc        (force_error_esc                                  ),
    .txrequesths            (txrequesths_7                                    ),
    .tx_skewcallhs          (tx_skewcallhs[7]                                 ),
    .txdatahs               (txdatahs_7                                       ),
    .txrequestesc           (txrequestesc_7                                   ),
    .txlpdtesc              (txlpdtesc_7                                      ),
    .txulpsesc              (txulpsesc_7                                      ),
    .txtriggeresc           (txtriggeresc_7                                   ),
    .txdataesc              (txdataesc_7                                      ),
    .txvalidesc             (txvalidesc_7                                     ),
    .txulpsexit             (txulpsexit_7                                     ),
    .turnrequest            (turnrequest_7                                    ),
    .turndisable            (turndisable_7                                    ),
    .txbyteclkhs            (txbyteclkhs                                      ),
    .slave                  (slave                                            ),
    .rx_hs_clk              (hs_rx_clk                                        ),
    .rxbyteclkhs            (rxbyteclkhs                                      ),
    .lp_rx_dp               (lp_rx_dp_7                                       ),
    .lp_rx_dn               (lp_rx_dn_7                                       ),
    .hs_rx                  (hs_rx_7                                          ),
    .direction              (direction_frm_txr_7                              ),
    .txreadyhs              (txreadyhs_7                                      ),
    .txreadyesc             (txreadyesc_7                                     ),
    .ulpsactivenot_s        (ulpsactivenot_s_7                                ),
    .sig_hs_tx_cntrl        (sig_hs_tx_cntrl_7                                ),
    .hs_tx_dp               (hs_tx_dp_7                                       ),
    .sig_lp_tx_cntrl        (sig_lp_tx_cntrl_7                                ),
    .lp_tx_dp               (lp_tx_dp_7                                       ),
    .lp_tx_dn               (lp_tx_dn_7                                       ),
    .stopstate              (stopstate_7                                      ),
    .eot_txr                (                                                 ),
    .rxactivehs             (rxactivehs_7                                     ),
    .rxdatahs               (rxdatahs_7                                       ),
    .rxvalidhs              (rxvalidhs_7                                      ),
    .rxsynchs               (rxsynchs_7                                       ),
    .rxdataesc              (rxdataesc_7                                      ),
    .rxvalidesc             (rxvalidesc_7                                     ),
    .rxtriggeresc           (rxtriggeresc_7                                   ),
    .rxulpsesc              (rxulpsesc_7                                      ),
    .rxskewcallhs           (rxskewcallhs_7                                   ),
    .ulps_active_not_dl     (ulps_active_not_dl_7                             ),
    .rxlpdtesc              (rxlpdtesc_7                                      ),
    .rxclkesc               (rxclkesc_7                                       ),
    .eot_handle_proc        (eot_handle_proc                                  ),
    .dln_cnt_hs_prep        (dln_cnt_hs_prep                                  ),
    .dln_cnt_hs_zero        (dln_cnt_hs_zero                                  ),
    .dln_cnt_hs_trail       (dln_cnt_hs_trail                                 ),
    .dln_cnt_hs_exit        (dln_cnt_hs_exit                                  ),
    .dln_cnt_lpx            (dln_cnt_lpx                                      ),
    .errsoths               (errsoths_7                                       ),
    .errsotsynchs           (errsotsynchs_7                                   ),
    .erresc                 (erresc_7                                         ),
    .errsyncesc             (errsyncesc_7                                     ),
    .errcontrol             (errcontrol_7                                     ),
    .stop_state_data        (stop_state_data_7                                ),
    .hs_rx_cntrl            (hs_rx_cntrl_7                                    ),
    .lp_rx_cntrl            (lp_rx_cntrl_7                                    )
    
    
    );
  

endmodule
