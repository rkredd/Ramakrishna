/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_afe_dfe_top.v
// Author      : R DINESH KUMAR
// Version     : v1p2
// Abstract    : This module is the top dphy tx and the dphy rx  
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
module csi2tx_dphy_afe_dfe_top(
  //INPUT SIGNALS
  input     wire         rst_n                ,   //INPUT RESET SIGNAL FOR QUADRATURE CLOCK DOMAIN
  input     wire         txclkesc             ,   //INPUT LOW POWER CLOCK SIGNAL USED FOR LOW POWER STATE TRANSITION

  input     wire         txddrclkhs_i         ,   //INPUT INPHASE HIGH SPEED DDR CLOCK
  input     wire         txddrclkhs_q         ,   //INPUT QUADRATURE PHASE HIGH SPEED DDR CLOCK
  input     wire         forcerxmode          ,   //INPUT FORCE RECEIVER MODE SIGNAL FROM THE PPI
  input     wire         forcetxstopmode      ,   //INPUT SIGNAL TO FORCE THE TRANSMITTER TO STOP MODE FROM THE PPI
  input     wire         turndisable_0        ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE1
  input     wire         txulpsexit_0         ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE1 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_0        ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE1 FROM THE TRANSMITTER PPI
  input     wire [7:0]   tx_skewcallhs        ,   //
  input     wire [7:0]   txdatahs_0           ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire         turnrequest_0        ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire         txrequestesc_0       ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire         txlpdtesc_0          ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire         txulpsesc_0          ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire [3:0]   txtriggeresc_0       ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire [7:0]   txdataesc_0          ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE1
  input     wire         txvalidesc_0         ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE1
  input     wire         lp_cd_d0_0           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE1
  input     wire         lp_cd_d1_0           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE1
                                              
  input     wire         turndisable_1        ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI- FOR DATA LANE2
  input     wire         txulpsexit_1         ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE2 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_1        ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE2 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_1           ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire         turnrequest_1        ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire         txrequestesc_1       ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI- FOR DATA LANE2
  input     wire         txlpdtesc_1          ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire         txulpsesc_1          ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire [3:0]   txtriggeresc_1       ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire [7:0]   txdataesc_1          ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE2
  input     wire         txvalidesc_1         ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE2
  input     wire         lp_cd_d0_1           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE2
  input     wire         lp_cd_d1_1           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE2
                                              
  input     wire         turndisable_2        ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE3
  input     wire         txulpsexit_2         ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE3 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_2        ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE3 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_2           ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire         turnrequest_2        ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire         txrequestesc_2       ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire         txlpdtesc_2          ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire         txulpsesc_2          ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire [3:0]   txtriggeresc_2       ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire [7:0]   txdataesc_2          ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE3
  input     wire         txvalidesc_2         ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE3
  input     wire         lp_cd_d0_2           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE3
  input     wire         lp_cd_d1_2           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE3
                                              
  input     wire         turndisable_3        ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE4
  input     wire         txulpsexit_3         ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE4 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_3        ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE4 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_3           ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire         turnrequest_3        ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire         txrequestesc_3       ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire         txlpdtesc_3          ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire         txulpsesc_3          ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire [3:0]   txtriggeresc_3       ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire [7:0]   txdataesc_3          ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE4
  input     wire         txvalidesc_3         ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE4
  input     wire         lp_cd_d0_3           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE4
  input     wire         lp_cd_d1_3           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE4
                                              
  input     wire         turndisable_4        ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE5
  input     wire         txulpsexit_4         ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE5 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_4        ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE5 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_4           ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire         turnrequest_4        ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire         txrequestesc_4       ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire         txlpdtesc_4          ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire         txulpsesc_4          ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire [3:0]   txtriggeresc_4       ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire [7:0]   txdataesc_4          ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE5
  input     wire         txvalidesc_4         ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE5
  input     wire         lp_cd_d0_4           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE5
  input     wire         lp_cd_d1_4           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE5
                                              
  input     wire         turndisable_5        ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE6
  input     wire         txulpsexit_5         ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE6 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_5        ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE6 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_5           ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire         turnrequest_5        ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire         txrequestesc_5       ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire         txlpdtesc_5          ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire         txulpsesc_5          ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire [3:0]   txtriggeresc_5       ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire [7:0]   txdataesc_5          ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE6
  input     wire         txvalidesc_5         ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE6
  input     wire         lp_cd_d0_5           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE6
  input     wire         lp_cd_d1_5           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE6
                                              
  input     wire         turndisable_6        ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE7
  input     wire         txulpsexit_6         ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE7 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_6        ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE7 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_6           ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire         turnrequest_6        ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire         txrequestesc_6       ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire         txlpdtesc_6          ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire         txulpsesc_6          ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire [3:0]   txtriggeresc_6       ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire [7:0]   txdataesc_6          ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE7
  input     wire         txvalidesc_6         ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE7
  input     wire         lp_cd_d0_6           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE7
  input     wire         lp_cd_d1_6           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE7
                                              
  input     wire         turndisable_7        ,   //INPUT TURNAROUND DISABLE SIGNAL FROM THE PPI - FOR DATA LANE8
  input     wire         txulpsexit_7         ,   //INPUT SIGNAL TO EXIT FROM ULTRA LOW POWER STATE FOR DATA LANE8 FROM THE TRANSMITTER PPI
  input     wire         txrequesths_7        ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL FOR DATA LANE8 FROM THE TRANSMITTER PPI
  input     wire [7:0]   txdatahs_7           ,   //INPUT HIGH SPEED 8-BIT DATA FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire         turnrequest_7        ,   //INPUT TURNAROUND REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire         txrequestesc_7       ,   //INPUT ESCAPE MODE REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire         txlpdtesc_7          ,   //INPUT ESCAPE MODE LOW POWER DATA TRANSMISSION REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire         txulpsesc_7          ,   //INPUT ESCAPE MODE ULTRA LOW POWER MODE REQUEST SIGNAL FOR DATA LANE FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire [3:0]   txtriggeresc_7       ,   //INPUT ESCAPE MODE TRIGGER REQUEST SIGNAL FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire [7:0]   txdataesc_7          ,   //INPUT ESCAPE MODE 8-BIT DATA FROM THE TRASNSMITTER PPI - FOR DATA LANE8
  input     wire         txvalidesc_7         ,   //INPUT ESCAPE MODE VALID SIGNAL FOR LOW POWER TRANSMISSION FROM THE TRANSMITTER PPI - FOR DATA LANE8
  input     wire         lp_cd_d0_7           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING LOW FROM THE TRANSCEIVER - FOR DATA LANE8
  input     wire         lp_cd_d1_7           ,   //INPUT SIGNAL INDICATING THE CONTENTION ON THE LINE WHILE DRIVING HIGH FROM THE TRANSCEIVER - FOR DATA LANE8
                                              
  input     wire         txulpsexit_clk       ,   //INPUT SIGNAL TO EXIT THE ULTRA LOW POWER STATE FOR CLOCK LANE FROM THE MASTER TRANSMITTER PPI
  input     wire         txrequesths_clk      ,   //INPUT HIGH SPEED REQUEST SGNAL FOR CLOCK LANE FROM THE MASTER TRASNSMITTER PPI
  input     wire         txulpsclk            ,   //INPUT ULTRA LOW POWER STATE REQUEST SIGNAL FOR CLOCK LANE FROM THE MASTER TRANSMITTER PPI
  input     wire         eot_handle_proc      ,   //INPUT EOT PROCESS HANDLING 0-EXTERNAL ,1 -INTERNAL 
  input     wire [7:0]   cln_cnt_hs_prep      ,   //INPUT HS PREPARE COUNT FOR CLOCK LANE
  input     wire [7:0]   cln_cnt_hs_zero      ,   //INPUT HS ZERO COUNT COUNT FOR CLOCK LANE
  input     wire [7:0]   cln_cnt_hs_trail     ,   //INPUT HS TRAIL COUNT FOR CLOCK LANE
  input     wire [7:0]   cln_cnt_hs_exit      ,   //INPUT HS EXIT COUNT FOR CLOCK LANE
  input     wire [7:0]   cln_cnt_lpx          ,   //INPUT LPX COUNT COUNT FOR CLOCK LANE

  input     wire [7:0]   dln_cnt_hs_prep      ,   //INPUT HS PREPARE COUNT FOR DATA LANE  
  input     wire [7:0]   dln_cnt_hs_zero      ,   //INPUT HS ZERO COUNT FOR DATA LANE
  input     wire [7:0]   dln_cnt_hs_trail     ,   //INPUT HS TRAIL COUNT FOR DATA LANE 
  input     wire [7:0]   dln_cnt_hs_exit      ,   //INPUT HS EXIT COUNT FOR DATA LANE 
  input     wire [7:0]   dln_cnt_lpx          ,   //INPUT LPX COUNT FOR DATA LANE  
  input     wire [5:0]   sot_sequence         , //SOT PATTEN
  input     wire         force_sot_error      , //FORCE ERROR
  input     wire         force_control_error  ,//FORCE ERROR CONTROL
  input     wire         force_error_esc      ,//FORCE ERROR ESC
                                            
  //OUTPUT SIGNALS                            
  output     wire        rxbyteclkhs          ,   //INPUT BYTE CLOCK GENERATED FROM DDR(HS_RX_CLK) CLOCK
  output     wire        txbyteclkhs          ,   //INPUT BYTE CLOCK GENERATED FROM DDR INPHASE CLOCK
  output    wire         txreadyhs_0          ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE1
  output    wire         txreadyesc_0         ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE1
  output    wire         direction_0          ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         errcontentionlp0_0   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE1 HAS DETECTED A
  output    wire         errcontentionlp1_0   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE1 HAS DETECTED A
  output    wire         rxactivehs_0         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE1
  output    wire [7:0]   rxdatahs_0           ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         rxvalidhs_0          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE1
  output    wire         rxsynchs_0           ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE1
  output    wire         rxskewcallhs_0       ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire [7:0]   rxdataesc_0          ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         rxvalidesc_0         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE1
  output    wire [3:0]   rxtriggeresc_0       ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         rxulpsesc_0          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE1 IS IN ULPS
  output    wire         rxlpdtesc_0          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE1 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_0           ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         errsotsynchs_0       ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         erresc_0             ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         errsyncesc_0         ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         errcontrol_0         ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE1
  output    wire         ulpsactivenot_0_n    ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE1 IS NOT IN ULTRA LOW POWER STATE
  output    wire         txreadyhs_1          ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE2
  output    wire         txreadyesc_1         ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE2
  output    wire         direction_1          ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         errcontentionlp0_1   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE2 HAS DETECTED A
  output    wire         errcontentionlp1_1   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE2 HAS DETECTED A
  output    wire         rxactivehs_1         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE2
  output    wire [7:0]   rxdatahs_1           ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         rxvalidhs_1          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES - FOR DATA LANE2
  output    wire         rxsynchs_1           ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE2
  output    wire         rxskewcallhs_1       ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire [7:0]   rxdataesc_1          ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI- FOR DATA LANE2
  output    wire         rxvalidesc_1         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE2
  output    wire [3:0]   rxtriggeresc_1       ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI- FOR DATA LANE2
  output    wire         rxulpsesc_1          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE2 IS IN ULPS
  output    wire         rxlpdtesc_1          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE2 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_1           ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         errsotsynchs_1       ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         erresc_1             ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         errsyncesc_1         ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         errcontrol_1         ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE2
  output    wire         ulpsactivenot_1_n    ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE LANE2 IS NOT IN ULTRA LOW POWER STATE
                                              
                                              
  output    wire         txreadyhs_2          ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE3
  output    wire         txreadyesc_2         ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE3
  output    wire         direction_2          ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         errcontentionlp0_2   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE3 HAS DETECTED A
  output    wire         errcontentionlp1_2   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE3 HAS DETECTED A
  output    wire         rxactivehs_2         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE3
  output    wire [7:0]   rxdatahs_2           ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         rxvalidhs_2          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE3
  output    wire         rxsynchs_2           ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE3
  output    wire         rxskewcallhs_2       ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire [7:0]   rxdataesc_2          ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         rxvalidesc_2         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE3
  output    wire [3:0]   rxtriggeresc_2       ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         rxulpsesc_2          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE3 IS IN ULPS
  output    wire         rxlpdtesc_2          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE3 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_2           ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         errsotsynchs_2       ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         erresc_2             ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         errsyncesc_2         ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         errcontrol_2         ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE3
  output    wire         ulpsactivenot_2_n    ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE3 IS NOT IN ULTRA LOW POWER STATE
                                              
  output    wire         txreadyhs_3          ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE4
  output    wire         txreadyesc_3         ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE4
  output    wire         direction_3          ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         errcontentionlp0_3   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE4 HAS DETECTED A
  output    wire         errcontentionlp1_3   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE4 HAS DETECTED A
  output    wire         rxactivehs_3         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE4
  output    wire [7:0]   rxdatahs_3           ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         rxvalidhs_3          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES - FOR DATA LANE4
  output    wire         rxsynchs_3           ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE4
  output    wire         rxskewcallhs_3       ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire [7:0]   rxdataesc_3          ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         rxvalidesc_3         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE4
  output    wire [3:0]   rxtriggeresc_3       ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         rxulpsesc_3          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE4 IS IN ULPS
  output    wire         rxlpdtesc_3          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE4 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_3           ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         errsotsynchs_3       ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         erresc_3             ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         errsyncesc_3         ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         errcontrol_3         ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE4
  output    wire         ulpsactivenot_3_n    ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE4 IS NOT IN ULTRA LOW POWER STATE
                                              
  output    wire         txreadyhs_4          ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE5
  output    wire         txreadyesc_4         ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE5
  output    wire         direction_4          ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         errcontentionlp0_4   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE5 HAS DETECTED A
  output    wire         errcontentionlp1_4   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE5 HAS DETECTED A
  output    wire         rxactivehs_4         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE5
  output    wire [7:0]   rxdatahs_4           ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         rxvalidhs_4          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE5
  output    wire         rxsynchs_4           ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE5
  output    wire         rxskewcallhs_4       ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire [7:0]   rxdataesc_4          ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         rxvalidesc_4         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE5
  output    wire [3:0]   rxtriggeresc_4       ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         rxulpsesc_4          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE5 IS IN ULPS
  output    wire         rxlpdtesc_4          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE5 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_4           ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         errsotsynchs_4       ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         erresc_4             ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         errsyncesc_4         ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         errcontrol_4         ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE5
  output    wire         ulpsactivenot_4_n    ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE5 IS NOT IN ULTRA LOW POWER STATE
                                              
  output    wire         txreadyhs_5          ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE6
  output    wire         txreadyesc_5         ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE6
  output    wire         direction_5          ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         errcontentionlp0_5   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE6 HAS DETECTED A
  output    wire         errcontentionlp1_5   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE6 HAS DETECTED A
  output    wire         rxactivehs_5         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE6
  output    wire [7:0]   rxdatahs_5           ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         rxvalidhs_5          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE6
  output    wire         rxsynchs_5           ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE6
  output    wire         rxskewcallhs_5       ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire [7:0]   rxdataesc_5          ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         rxvalidesc_5         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE6
  output    wire [3:0]   rxtriggeresc_5       ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         rxulpsesc_5          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE6 IS IN ULPS
  output    wire         rxlpdtesc_5          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE6 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_5           ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         errsotsynchs_5       ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         erresc_5             ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         errsyncesc_5         ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         errcontrol_5         ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE6
  output    wire         ulpsactivenot_5_n    ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE6 IS NOT IN ULTRA LOW POWER STATE

  output    wire         txreadyhs_6          ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE7
  output    wire         txreadyesc_6         ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE7
  output    wire         direction_6          ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire         errcontentionlp0_6   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE7 HAS DETECTED A
  output    wire         errcontentionlp1_6   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE7 HAS DETECTED A
  output    wire         rxactivehs_6         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE7
  output    wire [7:0]   rxdatahs_6           ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         rxvalidhs_6          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE7
  output    wire         rxsynchs_6           ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE7
  output    wire         rxskewcallhs_6       ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire [7:0]   rxdataesc_6          ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         rxvalidesc_6         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE7
  output    wire [3:0]   rxtriggeresc_6       ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         rxulpsesc_6          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE7 IS IN ULPS
  output    wire         rxlpdtesc_6          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE7 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_6           ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         errsotsynchs_6       ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         erresc_6             ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         errsyncesc_6         ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         errcontrol_6         ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE7
  output    wire         ulpsactivenot_6_n    ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE7 IS NOT IN ULTRA LOW POWER STATE

  output    wire         txreadyhs_7          ,   //OUTPUT TRANSMITTER READY SIGNAL FOR HIGH SPEED DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE8
  output    wire         txreadyesc_7         ,   //OUTPUT TRANSMITTER READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION TO THE TRANSMITTER PPI - FOR DATA LANE8
  output    wire         direction_7          ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER OR RECEIVER
  output    wire [7:0]   csi1_stopstate_m     ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE8 IS IN STOPSTATE
  output    wire [7:0]   csi1_stopstate_s     ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE8 IS IN STOPSTATE
  output    wire         errcontentionlp0_7   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE8 HAS DETECTED A
  output    wire         errcontentionlp1_7   ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE8 HAS DETECTED A
  output    wire         rxactivehs_7         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA - FOR DATA LANE8
  output    wire [7:0]   rxdatahs_7           ,   //OUTPUT HIGH SPEED 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         rxvalidhs_7          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES- FOR DATA LANE8
  output    wire         rxsynchs_7           ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION - FOR DATA LANE8
  output    wire         rxskewcallhs_7       ,   //OUTPUT SIGNAL TO INDICATES THE SUCCESSFUL DESKEW OPERATION TO THE UPPER LAYER
  output    wire [7:0]   rxdataesc_7          ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         rxvalidesc_7         ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES - FOR DATA LANE8
  output    wire [3:0]   rxtriggeresc_7       ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         rxulpsesc_7          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE8 IS IN ULPS
  output    wire         rxlpdtesc_7          ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE8 IS IN LOW POWER DATA RECEIVE MODE
  output    wire         errsoths_7           ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         errsotsynchs_7       ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         erresc_7             ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         errsyncesc_7         ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         errcontrol_7         ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI - FOR DATA LANE8
  output    wire         ulpsactivenot_7_n    ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE DATA LANE8 IS NOT IN ULTRA LOW POWER STATE

  output    wire         rxclkesc,                                               
  output    wire         rxclkactivehs        ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED CLOCK
  output    wire         rxulpsclknot_n       ,   //OUTPUT TO THE SLAVE RECEVIER PPI TO INDICATE THAT THE CLOCK LANE IS IN ULTRA LOW POWER STATE
  output    wire         ulpsactivenot_clk_n  ,   //OUTPUT TO INDICATE THE MASTER TRANSMITTER PPI THAT THE CLOCK LANE IS IN ULTRA LOW POWER STATE
  output    wire         stopstate_clk            //OUTPUT TO THE PPI TO INDICATE THAT THE CLOCK LANE IS IN STOPSTATE
  
  
  );

   wire            csi1_stopstate_dat_0_m               ;
   wire            csi1_stopstate_dat_1_m               ;
   wire            csi1_stopstate_dat_2_m               ;
   wire            csi1_stopstate_dat_3_m               ;
   wire            csi1_stopstate_dat_4_m               ;
   wire            csi1_stopstate_dat_5_m               ;
   wire            csi1_stopstate_dat_6_m               ;
   wire            csi1_stopstate_dat_7_m               ;
   wire            csi1_stopstate_dat_0_s               ;
   wire            csi1_stopstate_dat_1_s               ;
   wire            csi1_stopstate_dat_2_s               ;
   wire            csi1_stopstate_dat_3_s               ;
   wire            csi1_stopstate_dat_4_s               ;
   wire            csi1_stopstate_dat_5_s               ;
   wire            csi1_stopstate_dat_6_s               ;
   wire            csi1_stopstate_dat_7_s               ;

assign csi1_stopstate_m = {csi1_stopstate_dat_7_m,csi1_stopstate_dat_6_m,csi1_stopstate_dat_5_m,csi1_stopstate_dat_4_m,csi1_stopstate_dat_3_m,csi1_stopstate_dat_2_m,csi1_stopstate_dat_1_m,csi1_stopstate_dat_0_m};
assign csi1_stopstate_s = {csi1_stopstate_dat_7_s,csi1_stopstate_dat_6_s,csi1_stopstate_dat_5_s,csi1_stopstate_dat_4_s,csi1_stopstate_dat_3_s,csi1_stopstate_dat_2_s,csi1_stopstate_dat_1_s,csi1_stopstate_dat_0_s};


reg  skew_clk_reg;

 wire clk_lane_req;
 
 initial
  begin
   skew_clk_reg = 1'b0;
  end
  
 
 assign clk_lane_req = (skew_clk_reg)? 1'b1: txrequesths_clk;


 always@(tx_skewcallhs or rxskewcallhs_0 or rxskewcallhs_1 or rxskewcallhs_2 or rxskewcallhs_3 or rxskewcallhs_4 or rxskewcallhs_5 or rxskewcallhs_6 or rxskewcallhs_7)
  begin
    if(|tx_skewcallhs)
      skew_clk_reg = 1'b1;
    else if(rxskewcallhs_0 | rxskewcallhs_1 | rxskewcallhs_2 | rxskewcallhs_3 | rxskewcallhs_4 | rxskewcallhs_5 | rxskewcallhs_6 | rxskewcallhs_7)
     begin
      repeat(10)
       @(posedge rxbyteclkhs);
      skew_clk_reg = 1'b0;
     end
  end


//***************************************************************************//
//********************DPHY MASTER MODULE*************************************//
//***************************************************************************//

 csi2tx_dphy_top u_csi2tx_dphy_tx_top_inst(
     .txddr_q_rst_n           (rst_n                                          ),
     .txddr_i_rst_n           (rst_n                                          ),
     .rxddr_rst_n             (rst_n                                          ),
     .txescclk_rst_n          (rst_n                                          ),
     .rxescclk_rst_0_n        (rst_n                                          ),
     .rxescclk_rst_1_n        (rst_n                                          ),
     .rxescclk_rst_2_n        (rst_n                                          ),
     .rxescclk_rst_3_n        (rst_n                                          ),
     .rxescclk_rst_4_n        (rst_n                                          ),
     .rxescclk_rst_5_n        (rst_n                                          ),
     .rxescclk_rst_6_n        (rst_n                                          ),
     .rxescclk_rst_7_n        (rst_n                                          ),
     .tx_byte_rst_n           (rst_n                                          ),
     .rx_byte_rst_n           (rst_n                                          ),
                              
     .master_pin              (1'b1                                           ),
     .txclkesc                (txclkesc                                       ),
     .txddrclkhs_i            (txddrclkhs_i                                   ),
     .txddrclkhs_q            (txddrclkhs_q                                   ),
     .forcerxmode             (1'b0                                           ),
     .forcetxstopmode         (forcetxstopmode                                ),
     .lp_rx_cp_clk            (/*OPEN*/                                       ),
     .lp_rx_cn_clk            (/*OPEN*/                                       ),
     .hs_rx_clk               (/*OPEN*/                                       ),
     .lp_rx_dp_0              (/*OPEN*/                                       ),
     .lp_rx_dn_0              (/*OPEN*/                                       ),
     .hs_rx_0                 (/*OPEN*/                                       ),
     .turndisable_0           (1'b0                                           ),
     .txulpsexit_0            (txulpsexit_0                                   ),
     .txrequesths_0           (txrequesths_0                                  ),
     .tx_skewcallhs           (tx_skewcallhs                                  ),
     .txdatahs_0              (txdatahs_0                                     ),
     .turnrequest_0           (1'b0                                           ),
     .txrequestesc_0          (txrequestesc_0                                 ),
     .txlpdtesc_0             (1'b0                                           ),
     .txulpsesc_0             (txulpsesc_0                                    ),
     .txtriggeresc_0          (4'h0                                           ),
     .txdataesc_0             (8'h0                                           ),
     .txvalidesc_0            (1'b0                                           ),
     .lp_cd_d0_0              (1'b0                                           ),
     .lp_cd_d1_0              (1'b0                                           ),
                              
     .lp_rx_dp_1              (/*OPEN*/                                       ),
     .lp_rx_dn_1              (/*OPEN*/                                       ),
     .hs_rx_1                 (/*OPEN*/                                       ),
     .turndisable_1           (1'b0                                           ),
     .txulpsexit_1            (txulpsexit_1                                   ),
     .txrequesths_1           (txrequesths_1                                  ),
     .txdatahs_1              (txdatahs_1                                     ),
     .turnrequest_1           (1'b0                                           ),
     .txrequestesc_1          (txrequestesc_1                                 ),
     .txlpdtesc_1             (1'b0                                           ),
     .txulpsesc_1             (txulpsesc_1                                    ),
     .txtriggeresc_1          (4'h0                                           ),
     .txdataesc_1             (8'h0                                           ),
     .txvalidesc_1            (1'b0                                           ),
     .lp_cd_d0_1              (1'b0                                           ),
     .lp_cd_d1_1              (1'b0                                           ),
                              
     .lp_rx_dp_2              (/*OPEN*/                                       ),
     .lp_rx_dn_2              (/*OPEN*/                                       ),
     .hs_rx_2                 (/*OPEN*/                                       ),
     .turndisable_2           (1'b0                                           ),
     .txulpsexit_2            (txulpsexit_2                                   ),
     .txrequesths_2           (txrequesths_2                                  ),
     .txdatahs_2              (txdatahs_2                                     ),
     .turnrequest_2           (1'b0                                           ),
     .txrequestesc_2          (txrequestesc_2                                 ),
     .txlpdtesc_2             (1'b0                                           ),
     .txulpsesc_2             (txulpsesc_2                                    ),
     .txtriggeresc_2          (4'h0                                           ),
     .txdataesc_2             (8'h0                                           ),
     .txvalidesc_2            (1'b0                                           ),
     .lp_cd_d0_2              (1'b0                                           ),
     .lp_cd_d1_2              (1'b0                                           ),
                                                                              
     .lp_rx_dp_3              (/*OPEN*/                                       ),
     .lp_rx_dn_3              (/*OPEN*/                                       ),
     .hs_rx_3                 (/*OPEN*/                                       ),
     .turndisable_3           (1'b0                                           ),
     .txulpsexit_3            (txulpsexit_3                                   ),
     .txrequesths_3           (txrequesths_3                                  ),
     .txdatahs_3              (txdatahs_3                                     ),
     .turnrequest_3           (1'b0                                           ),
     .txrequestesc_3          (txrequestesc_3                                 ),
     .txlpdtesc_3             (1'b0                                           ),
     .txulpsesc_3             (txulpsesc_3                                    ),
     .txtriggeresc_3          (4'h0                                           ),
     .txdataesc_3             (8'h0                                           ),
     .txvalidesc_3            (1'b0                                           ),
     .lp_cd_d0_3              (1'b0                                           ),
     .lp_cd_d1_3              (1'b0                                           ),
                              
     .lp_rx_dp_4              (/*OPEN*/                                       ),
     .lp_rx_dn_4              (/*OPEN*/                                       ),
     .hs_rx_4                 (/*OPEN*/                                       ),
     .turndisable_4           (1'b0                                           ),
     .txulpsexit_4            (txulpsexit_4                                   ),
     .txrequesths_4           (txrequesths_4                                  ),
     .txdatahs_4              (txdatahs_4                                     ),
     .turnrequest_4           (1'b0                                           ),
     .txrequestesc_4          (txrequestesc_4                                 ),
     .txlpdtesc_4             (1'b0                                           ),
     .txulpsesc_4             (txulpsesc_4                                    ),
     .txtriggeresc_4          (4'h0                                           ),
     .txdataesc_4             (8'h0                                           ),
     .txvalidesc_4            (1'b0                                           ),
     .lp_cd_d0_4              (1'b0                                           ),
     .lp_cd_d1_4              (1'b0                                           ),
                              
     .lp_rx_dp_5              (/*OPEN*/                                       ),
     .lp_rx_dn_5              (/*OPEN*/                                       ),
     .hs_rx_5                 (/*OPEN*/                                       ),
     .turndisable_5           (1'b0                                           ),
     .txulpsexit_5            (txulpsexit_5                                   ),
     .txrequesths_5           (txrequesths_5                                  ),
     .txdatahs_5              (txdatahs_5                                     ),
     .turnrequest_5           (1'b0                                           ),
     .txrequestesc_5          (txrequestesc_5                                 ),
     .txlpdtesc_5             (1'b0                                           ),
     .txulpsesc_5             (txulpsesc_5                                    ),
     .txtriggeresc_5          (4'h0                                           ),
     .txdataesc_5             (8'h0                                           ),
     .txvalidesc_5            (1'b0                                           ),
     .lp_cd_d0_5              (1'b0                                           ),
     .lp_cd_d1_5              (1'b0                                           ),
                              
     .lp_rx_dp_6              (/*OPEN*/                                       ),
     .lp_rx_dn_6              (/*OPEN*/                                       ),
     .hs_rx_6                 (/*OPEN*/                                       ),
     .turndisable_6           (1'b0                                           ),
     .txulpsexit_6            (txulpsexit_6                                   ),
     .txrequesths_6           (txrequesths_6                                  ),
     .txdatahs_6              (txdatahs_6                                     ),
     .turnrequest_6           (1'b0                                           ),
     .txrequestesc_6          (txrequestesc_6                                 ),
     .txlpdtesc_6             (1'b0                                           ),
     .txulpsesc_6             (txulpsesc_6                                    ),
     .txtriggeresc_6          (4'h0                                           ),
     .txdataesc_6             (8'h0                                           ),
     .txvalidesc_6            (1'b0                                           ),
     .lp_cd_d0_6              (1'b0                                           ),
     .lp_cd_d1_6              (1'b0                                           ),

     .lp_rx_dp_7              (/*OPEN*/                                       ),
     .lp_rx_dn_7              (/*OPEN*/                                       ),
     .hs_rx_7                 (/*OPEN*/                                       ),
     .turndisable_7           (1'b0                                           ),
     .txulpsexit_7            (txulpsexit_7                                   ),
     .txrequesths_7           (txrequesths_7                                  ),
     .txdatahs_7              (txdatahs_7                                     ),
     .turnrequest_7           (1'b0                                           ),
     .txrequestesc_7          (txrequestesc_7                                 ),
     .txlpdtesc_7             (1'b0                                           ),
     .txulpsesc_7             (txulpsesc_7                                    ),
     .txtriggeresc_7          (4'h0                                           ),
     .txdataesc_7             (8'h0                                           ),
     .txvalidesc_7            (1'b0                                           ),
     .lp_cd_d0_7              (1'b0                                           ),
     .lp_cd_d1_7              (1'b0                                           ),

     .txulpsexit_clk          (txulpsexit_clk                                 ),
     .txrequesths_clk         (clk_lane_req                                   ),
     .txulpsclk               (txulpsclk                                      ),
     .eot_handle_proc         (eot_handle_proc                                ),
     .cln_cnt_hs_prep         (cln_cnt_hs_prep                                ),
     .cln_cnt_hs_zero         (cln_cnt_hs_zero                                ),
     .cln_cnt_hs_trail        (cln_cnt_hs_trail                               ),
     .cln_cnt_hs_exit         (cln_cnt_hs_exit                                ),
     .cln_cnt_lpx             (cln_cnt_lpx                                    ),
     .dln_cnt_hs_prep         (dln_cnt_hs_prep                                ),
     .dln_cnt_hs_zero         (dln_cnt_hs_zero                                ),
     .dln_cnt_hs_trail        (dln_cnt_hs_trail                               ),
     .dln_cnt_hs_exit         (dln_cnt_hs_exit                                ),
     .dln_cnt_lpx             (dln_cnt_lpx                                    ),
     .txreadyhs_0             (txreadyhs_0                                    ),
     .txreadyesc_0            (/*OPEN*/                                       ),
     .direction_0             (/*OPEN*/                                       ),
     .hs_tx_cntrl_0           (csi1_hs_tx_ctrl_0                              ),
     .hs_tx_dp_0              (csi1_hs_tx_0                                   ),
     .lp_tx_cntrl_0           (csi1_lp_tx_ctrl_0                              ),
     .lp_tx_dp_0              (csi1_lp_tx_dp0                                 ),
     .lp_tx_dn_0              (csi1_lp_tx_dn0                                 ),
     .stopstate_dat_0         (csi1_stopstate_dat_0_m                         ),
     .errcontentionlp0_0      (/*OPEN*/                                       ),
     .errcontentionlp1_0      (/*OPEN*/                                       ),
     .rxactivehs_0            (/*OPEN*/                                       ),
     .rxdatahs_0              (/*OPEN*/                                       ),
     .rxvalidhs_0             (/*OPEN*/                                       ),
     .rxsynchs_0              (/*OPEN*/                                       ),
     .rxdataesc_0             (/*OPEN*/                                       ),
     .rxvalidesc_0            (/*OPEN*/                                       ),
     .rxtriggeresc_0          (/*OPEN*/                                       ),
     .rxulpsesc_0             (/*OPEN*/                                       ),
     .rxskewcallhs_0          (/*OPEN*/                                       ),
     .rxlpdtesc_0             (/*OPEN*/                                       ),
     .rxclkesc_0              (/*OPEN*/                                       ),
     .errsoths_0              (/*OPEN*/                                       ),
     .errsotsynchs_0          (/*OPEN*/                                       ),
     .erresc_0                (/*OPEN*/                                       ),
     .errsyncesc_0            (/*open*/                                       ),
     .errcontrol_0            (/*OPEN*/                                       ),
     .ulpsactivenot_0_n       (/*OPEN*/                                       ),
     .hs_rx_cntrl_0           (/*OPEN*/                                       ),
     .lp_rx_cntrl_0           (/*OPEN*/                                       ),
     .sot_sequence            (sot_sequence                                   ), 
     .force_sot_error         (force_sot_error                                ),    
     .force_control_error     (force_control_error                            ),
     .force_error_esc         (force_error_esc                                ),
     .txreadyhs_1             (txreadyhs_1                                    ),
     .txreadyesc_1            (/*OPEN*/                                       ),
     .direction_1             (/*OPEN*/                                       ),
     .hs_tx_cntrl_1           (csi1_hs_tx_ctrl_1                              ),
     .hs_tx_dp_1              (csi1_hs_tx_1                                   ),
     .lp_tx_cntrl_1           (csi1_lp_tx_ctrl_1                              ),
     .lp_tx_dp_1              (csi1_lp_tx_dp1                                 ),
     .lp_tx_dn_1              (csi1_lp_tx_dn1                                 ),
     .stopstate_dat_1         (csi1_stopstate_dat_1_m                         ),
     .errcontentionlp0_1      (/*OPEN*/                                       ),
     .errcontentionlp1_1      (/*OPEN*/                                       ),
     .rxactivehs_1            (/*OPEN*/                                       ),
     .rxdatahs_1              (/*OPEN*/                                       ),
     .rxvalidhs_1             (/*OPEN*/                                       ),
     .rxsynchs_1              (/*OPEN*/                                       ),
     .rxdataesc_1             (/*OPEN*/                                       ),
     .rxvalidesc_1            (/*OPEN*/                                       ),
     .rxtriggeresc_1          (/*OPEN*/                                       ),
     .rxulpsesc_1             (/*OPEN*/                                       ),
     .rxskewcallhs_1          (/*OPEN*/                                       ),
     .rxlpdtesc_1             (/*OPEN*/                                       ),
     .rxclkesc_1              (/*OPEN*/                                       ),
     .errsoths_1              (/*OPEN*/                                       ),
     .errsotsynchs_1          (/*OPEN*/                                       ),
     .erresc_1                (/*OPEN*/                                       ),
     .errsyncesc_1            (/*OPEN*/                                       ),
     .errcontrol_1            (/*OPEN*/                                       ),
     .ulpsactivenot_1_n       (/*OPEN*/                                       ),
     .hs_rx_cntrl_1           (/*OPEN*/                                       ),
     .lp_rx_cntrl_1           (/*OPEN*/                                       ),
     
     .txreadyhs_2             (txreadyhs_2                                    ),
     .txreadyesc_2            (/*OPEN*/                                       ),
     .direction_2             (/*OPEN*/                                       ),
     .hs_tx_cntrl_2           (csi1_hs_tx_ctrl_2                              ),
     .hs_tx_dp_2              (csi1_hs_tx_2                                   ),
     .lp_tx_cntrl_2           (csi1_lp_tx_ctrl_2                              ),
     .lp_tx_dp_2              (csi1_lp_tx_dp2                                 ),
     .lp_tx_dn_2              (csi1_lp_tx_dn2                                 ),
     .stopstate_dat_2         (csi1_stopstate_dat_2_m                         ),
     .errcontentionlp0_2      (/*OPEN*/                                       ),
     .errcontentionlp1_2      (/*OPEN*/                                       ),
     .rxactivehs_2            (/*OPEN*/                                       ),
     .rxdatahs_2              (/*OPEN*/                                       ),
     .rxvalidhs_2             (/*OPEN*/                                       ),
     .rxsynchs_2              (/*OPEN*/                                       ),
     .rxdataesc_2             (/*OPEN*/                                       ),
     .rxvalidesc_2            (/*OPEN*/                                       ),
     .rxtriggeresc_2          (/*OPEN*/                                       ),
     .rxulpsesc_2             (/*OPEN*/                                       ),
     .rxskewcallhs_2          (/*OPEN*/                                       ),
     .rxlpdtesc_2             (/*OPEN*/                                       ),
     .rxclkesc_2              (/*OPEN*/                                       ),
     .errsoths_2              (/*OPEN*/                                       ),
     .errsotsynchs_2          (/*OPEN*/                                       ),
     .erresc_2                (/*OPEN*/                                       ),
     .errsyncesc_2            (/*OPEN*/                                       ),
     .errcontrol_2            (/*OPEN*/                                       ),
     .ulpsactivenot_2_n       (/*OPEN*/                                       ),
     .hs_rx_cntrl_2           (/*OPEN*/                                       ),
     .lp_rx_cntrl_2           (/*OPEN*/                                       ),
                                                                              
     .txreadyhs_3             (txreadyhs_3                                    ),
     .txreadyesc_3            (/*OPEN*/                                       ),
     .direction_3             (/*OPEN*/                                       ),
     .hs_tx_cntrl_3           (csi1_hs_tx_ctrl_3                              ),
     .hs_tx_dp_3              (csi1_hs_tx_3                                   ),
     .lp_tx_cntrl_3           (csi1_lp_tx_ctrl_3                              ),
     .lp_tx_dp_3              (csi1_lp_tx_dp3                                 ),
     .lp_tx_dn_3              (csi1_lp_tx_dn3                                 ),
     .stopstate_dat_3         (csi1_stopstate_dat_3_m                         ),
     .errcontentionlp0_3      (/*OPEN*/                                       ),
     .errcontentionlp1_3      (/*OPEN*/                                       ),
     .rxactivehs_3            (/*OPEN*/                                       ),
     .rxdatahs_3              (/*OPEN*/                                       ),
     .rxvalidhs_3             (/*OPEN*/                                       ),
     .rxsynchs_3              (/*OPEN*/                                       ),
     .rxdataesc_3             (/*OPEN*/                                       ),
     .rxvalidesc_3            (/*OPEN*/                                       ),
     .rxtriggeresc_3          (/*OPEN*/                                       ),
     .rxulpsesc_3             (/*OPEN*/                                       ),
     .rxskewcallhs_3          (/*OPEN*/                                       ),
     .rxlpdtesc_3             (/*OPEN*/                                       ),
     .rxclkesc_3              (/*OPEN*/                                       ),
     .errsoths_3              (/*OPEN*/                                       ),
     .errsotsynchs_3          (/*OPEN*/                                       ),
     .erresc_3                (/*OPEN*/                                       ),
     .errsyncesc_3            (/*OPEN*/                                       ),
     .errcontrol_3            (/*OPEN*/                                       ),
     .ulpsactivenot_3_n       (/*OPEN*/                                       ),
     .hs_rx_cntrl_3           (/*OPEN*/                                       ),
     .lp_rx_cntrl_3           (/*OPEN*/                                       ),
                                                                              
     .txreadyhs_4             (txreadyhs_4                                    ),
     .txreadyesc_4            (/*OPEN*/                                       ),
     .direction_4             (/*OPEN*/                                       ),
     .hs_tx_cntrl_4           (csi1_hs_tx_ctrl_4                              ),
     .hs_tx_dp_4              (csi1_hs_tx_4                                   ),
     .lp_tx_cntrl_4           (csi1_lp_tx_ctrl_4                              ),
     .lp_tx_dp_4              (csi1_lp_tx_dp4                                 ),
     .lp_tx_dn_4              (csi1_lp_tx_dn4                                 ),
     .stopstate_dat_4         (csi1_stopstate_dat_4_m                         ),
     .errcontentionlp0_4      (/*OPEN*/                                       ),
     .errcontentionlp1_4      (/*OPEN*/                                       ),
     .rxactivehs_4            (/*OPEN*/                                       ),
     .rxdatahs_4              (/*OPEN*/                                       ),
     .rxvalidhs_4             (/*OPEN*/                                       ),
     .rxsynchs_4              (/*OPEN*/                                       ),
     .rxdataesc_4             (/*OPEN*/                                       ),
     .rxvalidesc_4            (/*OPEN*/                                       ),
     .rxtriggeresc_4          (/*OPEN*/                                       ),
     .rxulpsesc_4             (/*OPEN*/                                       ),
     .rxskewcallhs_4          (/*OPEN*/                                       ),
     .rxlpdtesc_4             (/*OPEN*/                                       ),
     .rxclkesc_4              (/*OPEN*/                                       ),
     .errsoths_4              (/*OPEN*/                                       ),
     .errsotsynchs_4          (/*OPEN*/                                       ),
     .erresc_4                (/*OPEN*/                                       ),
     .errsyncesc_4            (/*OPEN*/                                       ),
     .errcontrol_4            (/*OPEN*/                                       ),
     .ulpsactivenot_4_n       (/*OPEN*/                                       ),
     .hs_rx_cntrl_4           (/*OPEN*/                                       ),
     .lp_rx_cntrl_4           (/*OPEN*/                                       ),
                                                                              
     .txreadyhs_5             (txreadyhs_5                                    ),
     .txreadyesc_5            (/*OPEN*/                                       ),
     .direction_5             (/*OPEN*/                                       ),
     .hs_tx_cntrl_5           (csi1_hs_tx_ctrl_5                              ),
     .hs_tx_dp_5              (csi1_hs_tx_5                                   ),
     .lp_tx_cntrl_5           (csi1_lp_tx_ctrl_5                              ),
     .lp_tx_dp_5              (csi1_lp_tx_dp5                                 ),
     .lp_tx_dn_5              (csi1_lp_tx_dn5                                 ),
     .stopstate_dat_5         (csi1_stopstate_dat_5_m                         ),
     .errcontentionlp0_5      (/*OPEN*/                                       ),
     .errcontentionlp1_5      (/*OPEN*/                                       ),
     .rxactivehs_5            (/*OPEN*/                                       ),
     .rxdatahs_5              (/*OPEN*/                                       ),
     .rxvalidhs_5             (/*OPEN*/                                       ),
     .rxsynchs_5              (/*OPEN*/                                       ),
     .rxdataesc_5             (/*OPEN*/                                       ),
     .rxvalidesc_5            (/*OPEN*/                                       ),
     .rxtriggeresc_5          (/*OPEN*/                                       ),
     .rxulpsesc_5             (/*OPEN*/                                       ),
     .rxskewcallhs_5          (/*OPEN*/                                       ),
     .rxlpdtesc_5             (/*OPEN*/                                       ),
     .rxclkesc_5              (/*OPEN*/                                       ),
     .errsoths_5              (/*OPEN*/                                       ),
     .errsotsynchs_5          (/*OPEN*/                                       ),
     .erresc_5                (/*OPEN*/                                       ),
     .errsyncesc_5            (/*OPEN*/                                       ),
     .errcontrol_5            (/*OPEN*/                                       ),
     .ulpsactivenot_5_n       (/*OPEN*/                                       ),
     .hs_rx_cntrl_5           (/*OPEN*/                                       ),
     .lp_rx_cntrl_5           (/*OPEN*/                                       ),
                              
     .txreadyhs_6             (txreadyhs_6                                    ),
     .txreadyesc_6            (/*OPEN*/                                       ),
     .direction_6             (/*OPEN*/                                       ),
     .hs_tx_cntrl_6           (csi1_hs_tx_ctrl_6                              ),
     .hs_tx_dp_6              (csi1_hs_tx_6                                   ),
     .lp_tx_cntrl_6           (csi1_lp_tx_ctrl_6                              ),
     .lp_tx_dp_6              (csi1_lp_tx_dp6                                 ),
     .lp_tx_dn_6              (csi1_lp_tx_dn6                                 ),
     .stopstate_dat_6         (csi1_stopstate_dat_6_m                         ),
     .errcontentionlp0_6      (/*OPEN*/                                       ),
     .errcontentionlp1_6      (/*OPEN*/                                       ),
     .rxactivehs_6            (/*OPEN*/                                       ),
     .rxdatahs_6              (/*OPEN*/                                       ),
     .rxvalidhs_6             (/*OPEN*/                                       ),
     .rxsynchs_6              (/*OPEN*/                                       ),
     .rxdataesc_6             (/*OPEN*/                                       ),
     .rxvalidesc_6            (/*OPEN*/                                       ),
     .rxtriggeresc_6          (/*OPEN*/                                       ),
     .rxulpsesc_6             (/*OPEN*/                                       ),
     .rxskewcallhs_6          (/*OPEN*/                                       ),
     .rxlpdtesc_6             (/*OPEN*/                                       ),
     .rxclkesc_6              (/*OPEN*/                                       ),
     .errsoths_6              (/*OPEN*/                                       ),
     .errsotsynchs_6          (/*OPEN*/                                       ),
     .erresc_6                (/*OPEN*/                                       ),
     .errsyncesc_6            (/*OPEN*/                                       ),
     .errcontrol_6            (/*OPEN*/                                       ),
     .ulpsactivenot_6_n       (/*OPEN*/                                       ),
     .hs_rx_cntrl_6           (/*OPEN*/                                       ),
     .lp_rx_cntrl_6           (/*OPEN*/                                       ),

     .txreadyhs_7             (txreadyhs_7                                    ),
     .txreadyesc_7            (/*OPEN*/                                       ),
     .direction_7             (/*OPEN*/                                       ),
     .hs_tx_cntrl_7           (csi1_hs_tx_ctrl_7                              ),
     .hs_tx_dp_7              (csi1_hs_tx_7                                   ),
     .lp_tx_cntrl_7           (csi1_lp_tx_ctrl_7                              ),
     .lp_tx_dp_7              (csi1_lp_tx_dp7                                 ),
     .lp_tx_dn_7              (csi1_lp_tx_dn7                                 ),
     .stopstate_dat_7         (csi1_stopstate_dat_7_m                         ),
     .errcontentionlp0_7      (/*OPEN*/                                       ),
     .errcontentionlp1_7      (/*OPEN*/                                       ),
     .rxactivehs_7            (/*OPEN*/                                       ),
     .rxdatahs_7              (/*OPEN*/                                       ),
     .rxvalidhs_7             (/*OPEN*/                                       ),
     .rxsynchs_7              (/*OPEN*/                                       ),
     .rxdataesc_7             (/*OPEN*/                                       ),
     .rxvalidesc_7            (/*OPEN*/                                       ),
     .rxtriggeresc_7          (/*OPEN*/                                       ),
     .rxulpsesc_7             (/*OPEN*/                                       ),
     .rxskewcallhs_7          (/*OPEN*/                                       ),
     .rxlpdtesc_7             (/*OPEN*/                                       ),
     .rxclkesc_7              (/*OPEN*/                                       ),
     .errsoths_7              (/*OPEN*/                                       ),
     .errsotsynchs_7          (/*OPEN*/                                       ),
     .erresc_7                (/*OPEN*/                                       ),
     .errsyncesc_7            (/*OPEN*/                                       ),
     .errcontrol_7            (/*OPEN*/                                       ),
     .ulpsactivenot_7_n       (/*OPEN*/                                       ),
     .hs_rx_cntrl_7           (/*OPEN*/                                       ),
     .lp_rx_cntrl_7           (/*OPEN*/                                       ),
                              
     .rxclkactivehs           (/*OPEN*/                                       ),
     .lp_tx_cntrl_clk         (csi1_lp_tx_cntrl_clk                           ),
     .lp_tx_cp_clk            (csi1_lp_tx_cp_clk                              ),
     .lp_tx_cn_clk            (csi1_lp_tx_cn_clk                              ),
     .hs_tx_cp_clk            (csi1_hs_tx_clk                                 ),
     .hs_tx_cntrl_clk         (csi1_hs_tx_cntrl_clk                           ),
     .hs_rx_cntrl_clk         (/*OPEN*/                                       ),
     .lp_rx_cntrl_clk         (/*OPEN*/                                       ),
     .rxulpsclknot_n          (/*OPEN*/                                       ),
     .ulpsactivenot_clk_n     (/*OPEN*/                                       ),
     .stopstate_clk           (stopstate_clk                                  ),
     .rxbyteclkhs             (/*OPEN*/                                       ),
     .txbyteclkhs             (txbyteclkhs                                    )
    
    
    );



//***************************************************************************//
//********************DPHY SLAVE MODEL***************************************//
//***************************************************************************//

 csi2tx_dphy_top u_csi2tx_dphy_rx_top_inst(
     .txddr_q_rst_n           (rst_n                                          ),
     .txddr_i_rst_n           (rst_n                                          ),
     .rxddr_rst_n             (rst_n                                          ),
     .txescclk_rst_n          (rst_n                                          ),
     .rxescclk_rst_0_n        (rst_n                                          ),
     .rxescclk_rst_1_n        (rst_n                                          ),
     .rxescclk_rst_2_n        (rst_n                                          ),
     .rxescclk_rst_3_n        (rst_n                                          ),
     .rxescclk_rst_4_n        (rst_n                                          ),
     .rxescclk_rst_5_n        (rst_n                                          ),
     .rxescclk_rst_6_n        (rst_n                                          ),
     .rxescclk_rst_7_n        (rst_n                                          ),
     .tx_byte_rst_n           (rst_n                                          ),
     .rx_byte_rst_n           (rst_n                                          ),
     
     .master_pin              (1'b0                                           ),
     .txclkesc                (txclkesc                                       ),
     .txddrclkhs_i            (1'b0                                           ),
     .txddrclkhs_q            (1'b0                                           ),
     .forcerxmode             (1'b0                                           ),
     .forcetxstopmode         (1'b0                                           ),
     .lp_rx_cp_clk            (csi1_lp_rx_cp_clk                              ),
     .lp_rx_cn_clk            (csi1_lp_rx_cn_clk                              ),
     .hs_rx_clk               (csi1_hs_rx_clk                                 ),
     .lp_rx_dp_0              (csi1_lp_rx_dp_0                                ),
     .lp_rx_dn_0              (csi1_lp_rx_dn_0                                ),
     .hs_rx_0                 (csi1_hs_rx_0                                   ),
     .turndisable_0           (1'b0                                           ),
     .txulpsexit_0            (1'b0                                           ),
     .txrequesths_0           (1'b0                                           ),
     .tx_skewcallhs           (8'b0                                           ),
     .txdatahs_0              (8'b0                                           ),
     .turnrequest_0           (1'b0                                           ),
     .txrequestesc_0          (1'b0                                           ),
     .txlpdtesc_0             (1'b0                                           ),
     .txulpsesc_0             (1'b0                                           ),
     .txtriggeresc_0          (4'h0                                           ),
     .txdataesc_0             (8'h0                                           ),
     .txvalidesc_0            (1'b0                                           ),
     .lp_cd_d0_0              (1'b0                                           ),
     .lp_cd_d1_0              (1'b0                                           ),
     
     .lp_rx_dp_1              (csi1_lp_rx_dp_1                                ),
     .lp_rx_dn_1              (csi1_lp_rx_dn_1                                ),
     .hs_rx_1                 (csi1_hs_rx_1                                   ),
     .turndisable_1           (1'b0                                           ),
     .txulpsexit_1            (1'b0                                           ),
     .txrequesths_1           (1'b0                                           ),
     .txdatahs_1              (8'h0                                           ),
     .turnrequest_1           (1'b0                                           ),
     .txrequestesc_1          (1'b0                                           ),
     .txlpdtesc_1             (1'b0                                           ),
     .txulpsesc_1             (1'b0                                           ),
     .txtriggeresc_1          (4'h0                                           ),
     .txdataesc_1             (8'h0                                           ),
     .txvalidesc_1            (1'b0                                           ),
     .lp_cd_d0_1              (1'b0                                           ),
     .lp_cd_d1_1              (1'b0                                           ),
     
     .lp_rx_dp_2              (csi1_lp_rx_dp_2                                ),
     .lp_rx_dn_2              (csi1_lp_rx_dn_2                                ),
     .hs_rx_2                 (csi1_hs_rx_2                                   ),
     .turndisable_2           (1'b0                                           ),
     .txulpsexit_2            (1'b0                                           ),
     .txrequesths_2           (1'b0                                           ),
     .txdatahs_2              (8'h0                                           ),
     .turnrequest_2           (1'b0                                           ),
     .txrequestesc_2          (1'b0                                           ),
     .txlpdtesc_2             (1'b0                                           ),
     .txulpsesc_2             (1'b0                                           ),
     .txtriggeresc_2          (4'h0                                           ),
     .txdataesc_2             (8'h0                                           ),
     .txvalidesc_2            (1'b0                                           ),
     .lp_cd_d0_2              (1'b0                                           ),
     .lp_cd_d1_2              (1'b0                                           ),
     
     .lp_rx_dp_3              (csi1_lp_rx_dp_3                                ),
     .lp_rx_dn_3              (csi1_lp_rx_dn_3                                ),
     .hs_rx_3                 (csi1_hs_rx_3                                   ),
     .turndisable_3           (1'b0                                           ),
     .txulpsexit_3            (1'b0                                           ),
     .txrequesths_3           (1'b0                                           ),
     .txdatahs_3              (8'h0                                           ),
     .turnrequest_3           (1'b0                                           ),
     .txrequestesc_3          (1'b0                                           ),
     .txlpdtesc_3             (1'b0                                           ),
     .txulpsesc_3             (1'b0                                           ),
     .txtriggeresc_3          (4'h0                                           ),
     .txdataesc_3             (8'h0                                           ),
     .txvalidesc_3            (1'b0                                           ),
     .lp_cd_d0_3              (1'b0                                           ),
     .lp_cd_d1_3              (1'b0                                           ),
   
     .lp_rx_dp_4              (csi1_lp_rx_dp_4                                ),
     .lp_rx_dn_4              (csi1_lp_rx_dn_4                                ),
     .hs_rx_4                 (csi1_hs_rx_4                                   ),
     .turndisable_4           (1'b0                                           ),
     .txulpsexit_4            (1'b0                                           ),
     .txrequesths_4           (1'b0                                           ),
     .txdatahs_4              (8'h0                                           ),
     .turnrequest_4           (1'b0                                           ),
     .txrequestesc_4          (1'b0                                           ),
     .txlpdtesc_4             (1'b0                                           ),
     .txulpsesc_4             (1'b0                                           ),
     .txtriggeresc_4          (4'h0                                           ),
     .txdataesc_4             (8'h0                                           ),
     .txvalidesc_4            (1'b0                                           ),
     .lp_cd_d0_4              (1'b0                                           ),
     .lp_cd_d1_4              (1'b0                                           ),


     .lp_rx_dp_5              (csi1_lp_rx_dp_5                                ),
     .lp_rx_dn_5              (csi1_lp_rx_dn_5                                ),
     .hs_rx_5                 (csi1_hs_rx_5                                   ),
     .turndisable_5           (1'b0                                           ),
     .txulpsexit_5            (1'b0                                           ),
     .txrequesths_5           (1'b0                                           ),
     .txdatahs_5              (8'h0                                           ),
     .turnrequest_5           (1'b0                                           ),
     .txrequestesc_5          (1'b0                                           ),
     .txlpdtesc_5             (1'b0                                           ),
     .txulpsesc_5             (1'b0                                           ),
     .txtriggeresc_5          (4'h0                                           ),
     .txdataesc_5             (8'h0                                           ),
     .txvalidesc_5            (1'b0                                           ),
     .lp_cd_d0_5              (1'b0                                           ),
     .lp_cd_d1_5              (1'b0                                           ),


     .lp_rx_dp_6              (csi1_lp_rx_dp_6                                ),
     .lp_rx_dn_6              (csi1_lp_rx_dn_6                                ),
     .hs_rx_6                 (csi1_hs_rx_6                                   ),
     .turndisable_6           (1'b0                                           ),
     .txulpsexit_6            (1'b0                                           ),
     .txrequesths_6           (1'b0                                           ),
     .txdatahs_6              (8'h0                                           ),
     .turnrequest_6           (1'b0                                           ),
     .txrequestesc_6          (1'b0                                           ),
     .txlpdtesc_6             (1'b0                                           ),
     .txulpsesc_6             (1'b0                                           ),
     .txtriggeresc_6          (4'h0                                           ),
     .txdataesc_6             (8'h0                                           ),
     .txvalidesc_6            (1'b0                                           ),
     .lp_cd_d0_6              (1'b0                                           ),
     .lp_cd_d1_6              (1'b0                                           ),

     .lp_rx_dp_7              (csi1_lp_rx_dp_7                                ),
     .lp_rx_dn_7              (csi1_lp_rx_dn_7                                ),
     .hs_rx_7                 (csi1_hs_rx_7                                   ),
     .turndisable_7           (1'b0                                           ),
     .txulpsexit_7            (1'b0                                           ),
     .txrequesths_7           (1'b0                                           ),
     .txdatahs_7              (8'h0                                           ),
     .turnrequest_7           (1'b0                                           ),
     .txrequestesc_7          (1'b0                                           ),
     .txlpdtesc_7             (1'b0                                           ),
     .txulpsesc_7             (1'b0                                           ),
     .txtriggeresc_7          (4'h0                                           ),
     .txdataesc_7             (8'h0                                           ),
     .txvalidesc_7            (1'b0                                           ),
     .lp_cd_d0_7              (1'b0                                           ),
     .lp_cd_d1_7              (1'b0                                           ),
 
     .txulpsexit_clk          (1'b0                                           ),
     .txrequesths_clk         (1'b1                                           ),
     .txulpsclk               (1'b0                                           ),
     .eot_handle_proc         (eot_handle_proc                                ),
     .cln_cnt_hs_prep         (cln_cnt_hs_prep                                ),
     .cln_cnt_hs_zero         (cln_cnt_hs_zero                                ),
     .cln_cnt_hs_trail        (cln_cnt_hs_trail                               ),
     .cln_cnt_hs_exit         (cln_cnt_hs_exit                                ),
     .cln_cnt_lpx             (cln_cnt_lpx                                    ),
     .dln_cnt_hs_prep         (dln_cnt_hs_prep                                ),
     .dln_cnt_hs_zero         (dln_cnt_hs_zero                                ),
     .dln_cnt_hs_trail        (dln_cnt_hs_trail                               ),
     .dln_cnt_hs_exit         (dln_cnt_hs_exit                                ),
     .dln_cnt_lpx             (dln_cnt_lpx                                    ),
     .txreadyhs_0             (/*OPEN*/                                       ),
     .txreadyesc_0            (/*OPEN*/                                       ),
     .direction_0             (/*OPEN*/                                       ),
     .hs_tx_cntrl_0           (/*OPEN*/                                       ),
     .hs_tx_dp_0              (/*OPEN*/                                       ),
     .lp_tx_cntrl_0           (/*OPEN*/                                       ),
     .lp_tx_dp_0              (/*OPEN*/                                       ),
     .lp_tx_dn_0              (/*OPEN*/                                       ),
     .stopstate_dat_0         (csi1_stopstate_dat_0_s                         ),
     .errcontentionlp0_0      (/*OPEN*/                                       ),
     .errcontentionlp1_0      (/*OPEN*/                                       ),
     .rxactivehs_0            (rxactivehs_0                                   ),
     .rxdatahs_0              (rxdatahs_0                                     ),
     .rxvalidhs_0             (rxvalidhs_0                                    ),
     .rxsynchs_0              (rxsynchs_0                                     ),
     .rxdataesc_0             (/*OPEN*/                                       ),
     .rxvalidesc_0            (/*OPEN*/                                       ),
     .rxtriggeresc_0          (/*OPEN*/                                       ),
     .rxulpsesc_0             (rxulpsesc_0                                    ),
     .rxskewcallhs_0          (rxskewcallhs_0                                 ),
     .rxlpdtesc_0             (rxlpdtesc_0                                    ),
     .rxclkesc_0              (csi1_rxclkesc_0                                ),
     .errsoths_0              (errsoths_0                                     ),
     .errsotsynchs_0          (errsotsynchs_0                                 ),
     .erresc_0                (erresc_0                                       ),
     .errsyncesc_0            (/*OPEN*/                                       ),
     .errcontrol_0            (errcontrol_0                                   ),
     .ulpsactivenot_0_n       (ulpsactivenot_0_n                              ),
     .hs_rx_cntrl_0           (csi1_hs_rx_cntrl_0                             ),
     .lp_rx_cntrl_0           (csi1_lp_rx_cntrl_0                             ),
   
     .sot_sequence            (sot_sequence                                   ), 
     .force_sot_error         (force_sot_error                                ),    
     .force_control_error     (force_control_error                            ),                                                                          
     .force_error_esc         (force_error_esc                                ),                                                                          
     .txreadyhs_1             (/*OPEN*/                                       ),
     .txreadyesc_1            (/*OPEN*/                                       ),
     .direction_1             (/*OPEN*/                                       ),
     .hs_tx_cntrl_1           (/*OPEN*/                                       ),
     .hs_tx_dp_1              (/*OPEN*/                                       ),
     .lp_tx_cntrl_1           (/*OPEN*/                                       ),
     .lp_tx_dp_1              (/*OPEN*/                                       ),
     .lp_tx_dn_1              (/*OPEN*/                                       ),
     .stopstate_dat_1         (csi1_stopstate_dat_1_s                         ),
     .errcontentionlp0_1      (/*OPEN*/                                       ),
     .errcontentionlp1_1      (/*OPEN*/                                       ),
     .rxactivehs_1            (rxactivehs_1                                   ),
     .rxdatahs_1              (rxdatahs_1                                     ),
     .rxvalidhs_1             (rxvalidhs_1                                    ),
     .rxsynchs_1              (rxsynchs_1                                     ),
     .rxdataesc_1             (/*OPEN*/                                       ),
     .rxvalidesc_1            (/*OPEN*/                                       ),
     .rxtriggeresc_1          (/*OPEN*/                                       ),
     .rxulpsesc_1             (rxulpsesc_1                                    ),
     .rxskewcallhs_1          (rxskewcallhs_1                                 ),
     .rxlpdtesc_1             (rxlpdtesc_1                                    ),
     .rxclkesc_1              (csi1_rxclkesc_1                                ),
     .errsoths_1              (errsoths_1                                     ),
     .errsotsynchs_1          (errsotsynchs_1                                 ),
     .erresc_1                (erresc_1                                       ),
     .errsyncesc_1            (/*OPEN*/                                       ),
     .errcontrol_1            (errcontrol_1                                   ),
     .ulpsactivenot_1_n       (ulpsactivenot_1_n                              ),
     .hs_rx_cntrl_1           (csi1_hs_rx_cntrl_1                             ),
     .lp_rx_cntrl_1           (csi1_lp_rx_cntrl_1                             ),
     
     .txreadyhs_2             (/*OPEN*/                                       ),
     .txreadyesc_2            (/*OPEN*/                                       ),
     .direction_2             (/*OPEN*/                                       ),
     .hs_tx_cntrl_2           (/*OPEN*/                                       ),
     .hs_tx_dp_2              (/*OPEN*/                                       ),
     .lp_tx_cntrl_2           (/*OPEN*/                                       ),
     .lp_tx_dp_2              (/*OPEN*/                                       ),
     .lp_tx_dn_2              (/*OPEN*/                                       ),
     .stopstate_dat_2         (csi1_stopstate_dat_2_s                         ),
     .errcontentionlp0_2      (/*OPEN*/                                       ),
     .errcontentionlp1_2      (/*OPEN*/                                       ),
     .rxactivehs_2            (rxactivehs_2                                   ),
     .rxdatahs_2              (rxdatahs_2                                     ),
     .rxvalidhs_2             (rxvalidhs_2                                    ),
     .rxsynchs_2              (rxsynchs_2                                     ),
     .rxdataesc_2             (/*OPEN*/                                       ),
     .rxvalidesc_2            (/*OPEN*/                                       ),
     .rxtriggeresc_2          (/*OPEN*/                                       ),
     .rxulpsesc_2             (rxulpsesc_2                                    ),
     .rxskewcallhs_2          (rxskewcallhs_2                                 ),
     .rxlpdtesc_2             (rxlpdtesc_2                                    ),
     .rxclkesc_2              (csi1_rxclkesc_2                                ),
     .errsoths_2              (errsoths_2                                     ),
     .errsotsynchs_2          (errsotsynchs_2                                 ),
     .erresc_2                (erresc_2                                       ),
     .errsyncesc_2            (/*OPEN*/                                       ),
     .errcontrol_2            (errcontrol_2                                   ),
     .ulpsactivenot_2_n       (ulpsactivenot_2_n                              ),
     .hs_rx_cntrl_2           (csi1_hs_rx_cntrl_2                             ),
     .lp_rx_cntrl_2           (csi1_lp_rx_cntrl_2                             ),
   
     .txreadyhs_3             (/*OPEN*/                                       ),
     .txreadyesc_3            (/*OPEN*/                                       ),
     .direction_3             (/*OPEN*/                                       ),
     .hs_tx_cntrl_3           (/*OPEN*/                                       ),
     .hs_tx_dp_3              (/*OPEN*/                                       ),
     .lp_tx_cntrl_3           (/*OPEN*/                                       ),
     .lp_tx_dp_3              (/*OPEN*/                                       ),
     .lp_tx_dn_3              (/*OPEN*/                                       ),
     .stopstate_dat_3         (csi1_stopstate_dat_3_s                         ),
     .errcontentionlp0_3      (/*OPEN*/                                       ),
     .errcontentionlp1_3      (/*OPEN*/                                       ),
     .rxactivehs_3            (rxactivehs_3                                   ),
     .rxdatahs_3              (rxdatahs_3                                     ),
     .rxvalidhs_3             (rxvalidhs_3                                    ),
     .rxsynchs_3              (rxsynchs_3                                     ),                                             
     .rxdataesc_3             (/*OPEN*/                                       ),
     .rxvalidesc_3            (/*OPEN*/                                       ),
     .rxtriggeresc_3          (/*OPEN*/                                       ),
     .rxulpsesc_3             (rxulpsesc_3                                    ),
     .rxskewcallhs_3          (rxskewcallhs_3                                 ),
     .rxlpdtesc_3             (rxlpdtesc_3                                    ),
     .rxclkesc_3              (csi1_rxclkesc_3                                ),
     .errsoths_3              (errsoths_3                                     ),
     .errsotsynchs_3          (errsotsynchs_3                                 ),
     .erresc_3                (erresc_3                                       ),
     .errsyncesc_3            (/*OPEN*/                                       ),
     .errcontrol_3            (errcontrol_3                                   ),
     .ulpsactivenot_3_n       (ulpsactivenot_3_n                              ),
     .hs_rx_cntrl_3           (csi1_hs_rx_cntrl_3                             ),
     .lp_rx_cntrl_3           (csi1_lp_rx_cntrl_3                             ),

     .txreadyhs_4             (/*OPEN*/                                       ),
     .txreadyesc_4            (/*OPEN*/                                       ),
     .direction_4             (/*OPEN*/                                       ),
     .hs_tx_cntrl_4           (/*OPEN*/                                       ),
     .hs_tx_dp_4              (/*OPEN*/                                       ),
     .lp_tx_cntrl_4           (/*OPEN*/                                       ),
     .lp_tx_dp_4              (/*OPEN*/                                       ),
     .lp_tx_dn_4              (/*OPEN*/                                       ),
     .stopstate_dat_4         (csi1_stopstate_dat_4_s                         ),
     .errcontentionlp0_4      (/*OPEN*/                                       ),
     .errcontentionlp1_4      (/*OPEN*/                                       ),
     .rxactivehs_4            (rxactivehs_4                                   ),
     .rxdatahs_4              (rxdatahs_4                                     ),
     .rxvalidhs_4             (rxvalidhs_4                                    ),
     .rxsynchs_4              (rxsynchs_4                                     ),
     .rxdataesc_4             (/*OPEN*/                                       ),
     .rxvalidesc_4            (/*OPEN*/                                       ),
     .rxtriggeresc_4          (/*OPEN*/                                       ),
     .rxulpsesc_4             (rxulpsesc_4                                    ),
     .rxskewcallhs_4          (rxskewcallhs_4                                 ),
     .rxlpdtesc_4             (rxlpdtesc_4                                    ),
     .rxclkesc_4              (csi1_rxclkesc_4                                ),
     .errsoths_4              (errsoths_4                                     ),
     .errsotsynchs_4          (errsotsynchs_4                                 ),
     .erresc_4                (erresc_4                                       ),
     .errsyncesc_4            (/*OPEN*/                                       ),
     .errcontrol_4            (errcontrol_4                                   ),
     .ulpsactivenot_4_n       (ulpsactivenot_4_n                              ),
     .hs_rx_cntrl_4           (csi1_hs_rx_cntrl_4                             ),
     .lp_rx_cntrl_4           (csi1_lp_rx_cntrl_4                             ),

     .txreadyhs_5             (/*OPEN*/                                       ),
     .txreadyesc_5            (/*OPEN*/                                       ),
     .direction_5             (/*OPEN*/                                       ),
     .hs_tx_cntrl_5           (/*OPEN*/                                       ),
     .hs_tx_dp_5              (/*OPEN*/                                       ),
     .lp_tx_cntrl_5           (/*OPEN*/                                       ),
     .lp_tx_dp_5              (/*OPEN*/                                       ),
     .lp_tx_dn_5              (/*OPEN*/                                       ),
     .stopstate_dat_5         (csi1_stopstate_dat_5_s                         ),
     .errcontentionlp0_5      (/*OPEN*/                                       ),
     .errcontentionlp1_5      (/*OPEN*/                                       ),
     .rxactivehs_5            (rxactivehs_5                                   ),
     .rxdatahs_5              (rxdatahs_5                                     ),
     .rxvalidhs_5             (rxvalidhs_5                                    ),
     .rxsynchs_5              (rxsynchs_5                                     ),
     .rxdataesc_5             (/*OPEN*/                                       ),
     .rxvalidesc_5            (/*OPEN*/                                       ),
     .rxtriggeresc_5          (/*OPEN*/                                       ),
     .rxulpsesc_5             (rxulpsesc_5                                    ),
     .rxskewcallhs_5          (rxskewcallhs_5                                 ),
     .rxlpdtesc_5             (rxlpdtesc_5                                    ),
     .rxclkesc_5              (csi1_rxclkesc_5                                ),
     .errsoths_5              (errsoths_5                                     ),
     .errsotsynchs_5          (errsotsynchs_5                                 ),
     .erresc_5                (erresc_5                                       ),
     .errsyncesc_5            (/*OPEN*/                                       ),
     .errcontrol_5            (errcontrol_5                                   ),
     .ulpsactivenot_5_n       (ulpsactivenot_5_n                              ),
     .hs_rx_cntrl_5           (csi1_hs_rx_cntrl_5                             ),
     .lp_rx_cntrl_5           (csi1_lp_rx_cntrl_5                             ),

     .txreadyhs_6             (/*OPEN*/                                       ),
     .txreadyesc_6            (/*OPEN*/                                       ),
     .direction_6             (/*OPEN*/                                       ),
     .hs_tx_cntrl_6           (/*OPEN*/                                       ),
     .hs_tx_dp_6              (/*OPEN*/                                       ),
     .lp_tx_cntrl_6           (/*OPEN*/                                       ),
     .lp_tx_dp_6              (/*OPEN*/                                       ),
     .lp_tx_dn_6              (/*OPEN*/                                       ),
     .stopstate_dat_6         (csi1_stopstate_dat_6_s                         ),
     .errcontentionlp0_6      (/*OPEN*/                                       ),
     .errcontentionlp1_6      (/*OPEN*/                                       ),
     .rxactivehs_6            (rxactivehs_6                                   ),
     .rxdatahs_6              (rxdatahs_6                                     ),
     .rxvalidhs_6             (rxvalidhs_6                                    ),
     .rxsynchs_6              (rxsynchs_6                                     ),
     .rxdataesc_6             (/*OPEN*/                                       ),
     .rxvalidesc_6            (/*OPEN*/                                       ),
     .rxtriggeresc_6          (/*OPEN*/                                       ),
     .rxulpsesc_6             (rxulpsesc_6                                    ),
     .rxskewcallhs_6          (rxskewcallhs_6                                 ),
     .rxlpdtesc_6             (rxlpdtesc_6                                    ),
     .rxclkesc_6              (csi1_rxclkesc_6                                ),
     .errsoths_6              (errsoths_6                                     ),
     .errsotsynchs_6          (errsotsynchs_6                                 ),
     .erresc_6                (erresc_6                                       ),
     .errsyncesc_6            (/*OPEN*/                                       ),
     .errcontrol_6            (errcontrol_6                                   ),
     .ulpsactivenot_6_n       (ulpsactivenot_6_n                              ),
     .hs_rx_cntrl_6           (csi1_hs_rx_cntrl_6                             ),
     .lp_rx_cntrl_6           (csi1_lp_rx_cntrl_6                             ),

     .txreadyhs_7             (/*OPEN*/                                       ),
     .txreadyesc_7            (/*OPEN*/                                       ),
     .direction_7             (/*OPEN*/                                       ),
     .hs_tx_cntrl_7           (/*OPEN*/                                       ),
     .hs_tx_dp_7              (/*OPEN*/                                       ),
     .lp_tx_cntrl_7           (/*OPEN*/                                       ),
     .lp_tx_dp_7              (/*OPEN*/                                       ),
     .lp_tx_dn_7              (/*OPEN*/                                       ),
     .stopstate_dat_7         (csi1_stopstate_dat_7_s                         ),
     .errcontentionlp0_7      (/*OPEN*/                                       ),
     .errcontentionlp1_7      (/*OPEN*/                                       ),
     .rxactivehs_7            (rxactivehs_7                                   ),
     .rxdatahs_7              (rxdatahs_7                                     ),
     .rxvalidhs_7             (rxvalidhs_7                                    ),
     .rxsynchs_7              (rxsynchs_7                                     ),
     .rxdataesc_7             (/*OPEN*/                                       ),
     .rxvalidesc_7            (/*OPEN*/                                       ),
     .rxtriggeresc_7          (/*OPEN*/                                       ),
     .rxulpsesc_7             (rxulpsesc_7                                    ),
     .rxskewcallhs_7          (rxskewcallhs_7                                 ),
     .rxlpdtesc_7             (rxlpdtesc_7                                    ),
     .rxclkesc_7              (csi1_rxclkesc_7                                ),
     .errsoths_7              (errsoths_7                                     ),
     .errsotsynchs_7          (errsotsynchs_7                                 ),
     .erresc_7                (erresc_7                                       ),
     .errsyncesc_7            (/*OPEN*/                                       ),
     .errcontrol_7            (errcontrol_7                                   ),
     .ulpsactivenot_7_n       (ulpsactivenot_7_n                              ),
     .hs_rx_cntrl_7           (csi1_hs_rx_cntrl_7                             ),
     .lp_rx_cntrl_7           (csi1_lp_rx_cntrl_7                             ),

     .rxclkactivehs           (/*OPEN*/                                       ),
     .lp_tx_cntrl_clk         (/*OPEN*/                                       ),
     .lp_tx_cp_clk            (/*OPEN*/                                       ),
     .lp_tx_cn_clk            (/*OPEN*/                                       ),
     .hs_tx_cp_clk            (/*OPEN*/                                       ),
     .hs_tx_cntrl_clk         (/*OPEN*/                                       ),
     .hs_rx_cntrl_clk         (csi1_hs_rx_cntrl_clk                           ),
     .lp_rx_cntrl_clk         (csi1_lp_rx_cntrl_clk                           ),
     .rxulpsclknot_n          (rxulpsclknot_n                                 ),
     .ulpsactivenot_clk_n     (ulpsactivenot_clk_n                            ),
     .stopstate_clk           (/*OPEN*/                                       ),
     .rxbyteclkhs             (rxbyteclkhs                                    ),
     .txbyteclkhs             (                                               )
    
    
    );


//***************************************************************************//
//********************DPHY CRU MODEL*****************************************//
//***************************************************************************//


  csi2tx_dphy_cru u_csi2tx_dphy_cru_inst(
     .pwr_on_rst              (rst_n                                          ),
     .enable                  (1'b1                                           ),
     .txddrclkhs_q            (txddrclkhs_q                                   ),
     .txddrclkhs_i            (txddrclkhs_i                                   ),
     .txclkesc                (txclkesc                                       ),
     .lp_rx_dp_0              (csi1_lp_rx_dp_0                                ),
     .lp_rx_dn_0              (csi1_lp_rx_dn_0                                ),
     .lp_rx_dp_1              (csi1_lp_rx_dp_1                                ),
     .lp_rx_dn_1              (csi1_lp_rx_dn_1                                ),
     .lp_rx_dp_2              (csi1_lp_rx_dp_2                                ),
     .lp_rx_dn_2              (csi1_lp_rx_dn_2                                ),
     .lp_rx_dp_3              (csi1_lp_rx_dp_3                                ),
     .lp_rx_dn_3              (csi1_lp_rx_dn_3                                ),
     .lp_rx_dp_4              (csi1_lp_rx_dp_4                                ),
     .lp_rx_dn_4              (csi1_lp_rx_dn_4                                ),
     .lp_rx_dp_5              (csi1_lp_rx_dp_5                                ),
     .lp_rx_dn_5              (csi1_lp_rx_dn_5                                ),
     .lp_rx_dp_6              (csi1_lp_rx_dp_6                                ),
     .lp_rx_dn_6              (csi1_lp_rx_dn_6                                ),
     .lp_rx_dp_7              (csi1_lp_rx_dp_7                                ),
     .lp_rx_dn_7              (csi1_lp_rx_dn_7                                ),
     .txddr_q_rst_n           (txddr_q_rst_n                                  ),
     .txddr_i_rst_n           (txddr_i_rst_n                                  ),
     .rxddr_rst_n             (rxddr_rst_n                                    ),
     .txescclk_rst_n          (txescclk_rst_n                                 ),
     .rcvclkesc_rst_n         (rcvclkesc_rst_n                                ),
     .rxescclk_rst_0_n        (rxescclk_rst_0_n                               ),
     .rxescclk_rst_1_n        (rxescclk_rst_1_n                               ),
     .rxescclk_rst_2_n        (rxescclk_rst_2_n                               ),
     .rxescclk_rst_3_n        (rxescclk_rst_3_n                               ),
     .rxescclk_rst_4_n        (rxescclk_rst_4_n                               ),
     .rxescclk_rst_5_n        (rxescclk_rst_5_n                               ),
     .rxescclk_rst_6_n        (rxescclk_rst_6_n                               ),
     .rxescclk_rst_7_n        (rxescclk_rst_7_n                               ),
     .tx_byte_rst_n           (tx_byte_rst_n                                  ),
     .rx_byte_rst_n           (rx_byte_rst_n                                  ),
     .rxclkesc                (rxclkesc                                       ),    
     .rxclkesc_0              (csi1_rxclkesc_0                                ),
     .rxclkesc_1              (csi1_rxclkesc_1                                ),
     .rxclkesc_2              (csi1_rxclkesc_2                                ),
     .rxclkesc_3              (csi1_rxclkesc_3                                ),
     .rxclkesc_4              (csi1_rxclkesc_4                                ),
     .rxclkesc_5              (csi1_rxclkesc_5                                ),
     .rxclkesc_6              (csi1_rxclkesc_6                                ),
     .rxclkesc_7              (csi1_rxclkesc_7                                ),
     .rxbyteclkhs             (rxbyteclkhs                                    ),
     .csi1_rxbyteclkhs_n      (csi1_rxbyteclkhs_n                             ),
     .txbyteclkhs             (txbyteclkhs                                    )
    );


//***************************************************************************//
//********************DPHY MASTER TRANSCEIVER********************************//
//***************************************************************************//


csi2tx_phy_afe_buf u_csi2tx_phy_afe_masdat_txcvr_inst_0(


     .hs_tx_en                (csi1_hs_tx_ctrl_0                              ),
     .hs_tx_data              (csi1_hs_tx_0                                   ),
     .lp_tx_en                (csi1_lp_tx_ctrl_0                              ),
     .lp_tx_dp                (csi1_lp_tx_dp0                                 ),
     .lp_tx_dn                (csi1_lp_tx_dn0                                 ),
     .hs_rx_en                (1'b0                                           ),
     .hs_rcv_data             (/*OPEN*/                                       ),
     .lp_rcv_dp               (/*OPEN*/                                       ),
     .lp_rcv_dn               (/*OPEN*/                                       ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp0                                            ),
     .dn                      (dn0                                            )
);

 csi2tx_phy_afe_buf u_csi2tx_phy_afe_masdat_txcvr_inst_1(
     .hs_tx_en                (csi1_hs_tx_ctrl_1                              ),
     .hs_tx_data              (csi1_hs_tx_1                                   ),
     .lp_tx_en                (csi1_lp_tx_ctrl_1                              ),
     .lp_tx_dp                (csi1_lp_tx_dp1                                 ),
     .lp_tx_dn                (csi1_lp_tx_dn1                                 ),
     .hs_rx_en                (1'b0                                           ),
     .hs_rcv_data             (/*OPEN*/                                       ),
     .lp_rcv_dp               (/*OPEN*/                                       ),
     .lp_rcv_dn               (/*OPEN*/                                       ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp1                                            ),
     .dn                      (dn1                                            )
);

 csi2tx_phy_afe_buf u_csi2tx_phy_afe_masdat_txcvr_inst_2(
     .hs_tx_en                (csi1_hs_tx_ctrl_2                              ),
     .hs_tx_data              (csi1_hs_tx_2                                   ),
     .lp_tx_en                (csi1_lp_tx_ctrl_2                              ),
     .lp_tx_dp                (csi1_lp_tx_dp2                                 ),
     .lp_tx_dn                (csi1_lp_tx_dn2                                 ),
     .hs_rx_en                (1'b0                                           ),
     .hs_rcv_data             (/*OPEN*/                                       ),
     .lp_rcv_dp               (/*OPEN*/                                       ),
     .lp_rcv_dn               (/*OPEN*/                                       ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp2                                            ),
     .dn                      (dn2                                            )
);

 csi2tx_phy_afe_buf u_csi2tx_phy_afe_masdat_txcvr_inst_3(
     .hs_tx_en                (csi1_hs_tx_ctrl_3                              ),
     .hs_tx_data              (csi1_hs_tx_3                                   ),
     .lp_tx_en                (csi1_lp_tx_ctrl_3                              ),
     .lp_tx_dp                (csi1_lp_tx_dp3                                 ),
     .lp_tx_dn                (csi1_lp_tx_dn3                                 ),
     .hs_rx_en                (1'b0                                           ),
     .hs_rcv_data             (/*OPEN*/                                       ),
     .lp_rcv_dp               (/*OPEN*/                                       ),
     .lp_rcv_dn               (/*OPEN*/                                       ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp3                                            ),
     .dn                      (dn3                                            )
);



 csi2tx_phy_afe_buf u_csi2tx_phy_afe_masdat_txcvr_inst_4(
     .hs_tx_en                (csi1_hs_tx_ctrl_4                              ),
     .hs_tx_data              (csi1_hs_tx_4                                   ),
     .lp_tx_en                (csi1_lp_tx_ctrl_4                              ),
     .lp_tx_dp                (csi1_lp_tx_dp4                                 ),
     .lp_tx_dn                (csi1_lp_tx_dn4                                 ),
     .hs_rx_en                (1'b0                                           ),
     .hs_rcv_data             (/*OPEN*/                                       ),
     .lp_rcv_dp               (/*OPEN*/                                       ),
     .lp_rcv_dn               (/*OPEN*/                                       ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp4                                            ),
     .dn                      (dn4                                            )
);



 csi2tx_phy_afe_buf u_csi2tx_phy_afe_masdat_txcvr_inst_5(
     .hs_tx_en                (csi1_hs_tx_ctrl_5                              ),
     .hs_tx_data              (csi1_hs_tx_5                                   ),
     .lp_tx_en                (csi1_lp_tx_ctrl_5                              ),
     .lp_tx_dp                (csi1_lp_tx_dp5                                 ),
     .lp_tx_dn                (csi1_lp_tx_dn5                                 ),
     .hs_rx_en                (1'b0                                           ),
     .hs_rcv_data             (/*OPEN*/                                       ),
     .lp_rcv_dp               (/*OPEN*/                                       ),
     .lp_rcv_dn               (/*OPEN*/                                       ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp5                                            ),
     .dn                      (dn5                                            )
);


 csi2tx_phy_afe_buf u_csi2tx_phy_afe_masdat_txcvr_inst_6(
     .hs_tx_en                (csi1_hs_tx_ctrl_6                              ),
     .hs_tx_data              (csi1_hs_tx_6                                   ),
     .lp_tx_en                (csi1_lp_tx_ctrl_6                              ),
     .lp_tx_dp                (csi1_lp_tx_dp6                                 ),
     .lp_tx_dn                (csi1_lp_tx_dn6                                 ),
     .hs_rx_en                (1'b0                                           ),
     .hs_rcv_data             (/*OPEN*/                                       ),
     .lp_rcv_dp               (/*OPEN*/                                       ),
     .lp_rcv_dn               (/*OPEN*/                                       ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp6                                            ),
     .dn                      (dn6                                            )
);



 csi2tx_phy_afe_buf u_csi2tx_phy_afe_masdat_txcvr_inst_7(
     .hs_tx_en                (csi1_hs_tx_ctrl_7                              ),
     .hs_tx_data              (csi1_hs_tx_7                                   ),
     .lp_tx_en                (csi1_lp_tx_ctrl_7                              ),
     .lp_tx_dp                (csi1_lp_tx_dp7                                 ),
     .lp_tx_dn                (csi1_lp_tx_dn7                                 ),
     .hs_rx_en                (1'b0                                           ),
     .hs_rcv_data             (/*OPEN*/                                       ),
     .lp_rcv_dp               (/*OPEN*/                                       ),
     .lp_rcv_dn               (/*OPEN*/                                       ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp7                                            ),
     .dn                      (dn7                                            )
);

 csi2tx_phy_afe_buf u_csi2tx_phy_afe_masclk_txcvr_inst(
     .hs_tx_en                (csi1_hs_tx_cntrl_clk                           ),
     .hs_tx_data              (csi1_hs_tx_clk                                 ),
     .lp_tx_en                (csi1_lp_tx_cntrl_clk                           ),
     .lp_tx_dp                (csi1_lp_tx_cp_clk                              ),
     .lp_tx_dn                (csi1_lp_tx_cn_clk                              ),
     .hs_rx_en                (1'b0                                           ),
     .hs_rcv_data             (/*OPEN*/                                       ),
     .lp_rcv_dp               (/*OPEN*/                                       ),
     .lp_rcv_dn               (/*OPEN*/                                       ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dpck                                           ),
     .dn                      (dnck                                           )
);


//***************************************************************************//
//********************DPHY SLAVE TRANSCEIVER*********************************//
//***************************************************************************//

csi2tx_phy_afe_buf u_csi2tx_phy_afe_slvdat_txcvr_inst_0(


     .hs_tx_en                (1'b0                                           ),
     .hs_tx_data              (1'b0                                           ),
     .lp_tx_en                (1'b0                                           ),
     .lp_tx_dp                (1'b0                                           ),
     .lp_tx_dn                (1'b0                                           ),
     .hs_rx_en                (csi1_lp_rx_cntrl_0 || csi1_hs_rx_cntrl_0       ),
     .hs_rcv_data             (csi1_hs_rx_0                                   ),
     .lp_rcv_dp               (csi1_lp_rx_dp_0                                ),
     .lp_rcv_dn               (csi1_lp_rx_dn_0                                ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp0                                            ),
     .dn                      (dn0                                            )
);

 csi2tx_phy_afe_buf u_csi2tx_phy_afe_slvdat_txcvr_inst_1(
     .hs_tx_en                (1'b0                                           ),
     .hs_tx_data              (1'b0                                           ),
     .lp_tx_en                (1'b0                                           ),
     .lp_tx_dp                (1'b0                                           ),
     .lp_tx_dn                (1'b0                                           ),
     .hs_rx_en                (csi1_lp_rx_cntrl_1 || csi1_hs_rx_cntrl_1       ),
     .hs_rcv_data             (csi1_hs_rx_1                                   ),
     .lp_rcv_dp               (csi1_lp_rx_dp_1                                ),
     .lp_rcv_dn               (csi1_lp_rx_dn_1                                ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp1                                            ),
     .dn                      (dn1                                            )
);

 csi2tx_phy_afe_buf u_csi2tx_phy_afe_slvdat_txcvr_inst_2(
     .hs_tx_en                (1'b0                                           ),
     .hs_tx_data              (1'b0                                           ),
     .lp_tx_en                (1'b0                                           ),
     .lp_tx_dp                (1'b0                                           ),
     .lp_tx_dn                (1'b0                                           ),
     .hs_rx_en                (csi1_lp_rx_cntrl_2 || csi1_hs_rx_cntrl_2       ),
     .hs_rcv_data             (csi1_hs_rx_2                                   ),
     .lp_rcv_dp               (csi1_lp_rx_dp_2                                ),
     .lp_rcv_dn               (csi1_lp_rx_dn_2                                ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp2                                            ),
     .dn                      (dn2                                            )
);

 csi2tx_phy_afe_buf u_csi2tx_phy_afe_slvdat_txcvr_inst_3(
     .hs_tx_en                (1'b0                                           ),
     .hs_tx_data              (1'b0                                           ),
     .lp_tx_en                (1'b0                                           ),
     .lp_tx_dp                (1'b0                                           ),
     .lp_tx_dn                (1'b0                                           ),
     .hs_rx_en                (csi1_lp_rx_cntrl_3 || csi1_hs_rx_cntrl_3       ),
     .hs_rcv_data             (csi1_hs_rx_3                                   ),
     .lp_rcv_dp               (csi1_lp_rx_dp_3                                ),
     .lp_rcv_dn               (csi1_lp_rx_dn_3                                ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp3                                            ),
     .dn                      (dn3                                            )
);


 csi2tx_phy_afe_buf u_csi2tx_phy_afe_slvdat_txcvr_inst_4(
     .hs_tx_en                (1'b0                                           ),
     .hs_tx_data              (1'b0                                           ),
     .lp_tx_en                (1'b0                                           ),
     .lp_tx_dp                (1'b0                                           ),
     .lp_tx_dn                (1'b0                                           ),
     .hs_rx_en                (csi1_lp_rx_cntrl_4 || csi1_hs_rx_cntrl_4       ),
     .hs_rcv_data             (csi1_hs_rx_4                                   ),
     .lp_rcv_dp               (csi1_lp_rx_dp_4                                ),
     .lp_rcv_dn               (csi1_lp_rx_dn_4                                ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp4                                            ),
     .dn                      (dn4                                            )
);


 csi2tx_phy_afe_buf u_csi2tx_phy_afe_slvdat_txcvr_inst_5(
     .hs_tx_en                (1'b0                                           ),
     .hs_tx_data              (1'b0                                           ),
     .lp_tx_en                (1'b0                                           ),
     .lp_tx_dp                (1'b0                                           ),
     .lp_tx_dn                (1'b0                                           ),
     .hs_rx_en                (csi1_lp_rx_cntrl_5 || csi1_hs_rx_cntrl_5       ),
     .hs_rcv_data             (csi1_hs_rx_5                                   ),
     .lp_rcv_dp               (csi1_lp_rx_dp_5                                ),
     .lp_rcv_dn               (csi1_lp_rx_dn_5                                ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp5                                            ),
     .dn                      (dn5                                            )
);

 csi2tx_phy_afe_buf u_csi2tx_phy_afe_slvdat_txcvr_inst_6(
     .hs_tx_en                (1'b0                                           ),
     .hs_tx_data              (1'b0                                           ),
     .lp_tx_en                (1'b0                                           ),
     .lp_tx_dp                (1'b0                                           ),
     .lp_tx_dn                (1'b0                                           ),
     .hs_rx_en                (csi1_lp_rx_cntrl_6 || csi1_hs_rx_cntrl_6       ),
     .hs_rcv_data             (csi1_hs_rx_6                                   ),
     .lp_rcv_dp               (csi1_lp_rx_dp_6                                ),
     .lp_rcv_dn               (csi1_lp_rx_dn_6                                ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp6                                            ),
     .dn                      (dn6                                            )
);

 csi2tx_phy_afe_buf u_csi2tx_phy_afe_slvdat_txcvr_inst_7(
     .hs_tx_en                (1'b0                                           ),
     .hs_tx_data              (1'b0                                           ),
     .lp_tx_en                (1'b0                                           ),
     .lp_tx_dp                (1'b0                                           ),
     .lp_tx_dn                (1'b0                                           ),
     .hs_rx_en                (csi1_lp_rx_cntrl_7 || csi1_hs_rx_cntrl_7       ),
     .hs_rcv_data             (csi1_hs_rx_7                                   ),
     .lp_rcv_dp               (csi1_lp_rx_dp_7                                ),
     .lp_rcv_dn               (csi1_lp_rx_dn_7                                ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dp7                                            ),
     .dn                      (dn7                                            )
);


 csi2tx_phy_afe_buf u_csi2tx_phy_afe_slvclk_txcvr_inst(
     .hs_tx_en                (1'b0                                           ),
     .hs_tx_data              (1'b0                                           ),
     .lp_tx_en                (1'b0                                           ),
     .lp_tx_dp                (1'b0                                           ),
     .lp_tx_dn                (1'b0                                           ),
     .hs_rx_en                (csi1_hs_rx_cntrl_clk/*||csi1_lp_rx_cntrl_clk)*/),
     .hs_rcv_data             (csi1_hs_rx_clk                                 ),
     .lp_rcv_dp               (csi1_lp_rx_cp_clk                              ),
     .lp_rcv_dn               (csi1_lp_rx_cn_clk                              ),
     .lp_cd_low               (/*OPEN*/                                       ),
     .lp_cd_high              (/*OPEN*/                                       ),
     .dp                      (dpck                                           ),
     .dn                      (dnck                                           )
);

endmodule
