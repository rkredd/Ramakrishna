/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_dat_lane_txr.v
// Author      : R.Dinesh Kumar
// Version     : v1p2
// Abstract    : This module is used for the data lane transmission
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
//*****************************************************************************
// TOP MODULE FOR THE DATA LANE TRANSMITTER
//*****************************************************************************

`define psec  *1000
`define nsec  *1
`define T_LPX *50 *1000

//TOP MODULE FOR THE DATA LANE TRANSMITTER
module csi2tx_dphy_dat_lane_txr(
  //INPUTS
  //INPUT CLOCK AND POWER ON RESET SIGNAL FROM THE TRANSMITTER PPI
  input     wire        txclkesc                 ,   //INPUT LOW POWER CLK SIGNAL USED FOR LOW POWER STATE TRANSITION
  input     wire        txescclk_rst_n           ,   //INPUT GATED RESET SIGNAL FOR TXCLKESC(LOW POWER CLOCK) CLOCK DOMAIN
  input     wire        tx_byte_rst_n            ,   //INPUT GATED RESET SIGNAL FOR TXBYTECLKHS(GENERATED FROM INPHASE CLOCK) CLOCK DOMAIN
  input     wire        txddr_i_rst_n            ,   //INPUT GATED RESET SIGNAL FOR INPHASE CLOCK DOMAIN
  
  //INPUT SIGNAL TO SELECT WHETHER MASTER TRANSMITTER OR SLAVE TRANSMITTER
  input     wire        master_pin               ,   //INPUT PIN FOR DIFFERENTIATING THE MASTER/SLAVE TRANSMITTER
  
  //INPUT HIGH SPEED TRANSMISSION SIGNALS FROM THE PPI
  input     wire        txddrclkhs_i             ,   //INPUT INPHASE HIGH SPEED DDR CLOCK SIGNAL
  input     wire        txrequesths              ,   //INPUT HIGH SPEED TRANSMISSION REQUEST SIGNAL
  input     wire        tx_skewcallhs            ,   //
  input     wire [7:0]  txdatahs                 ,   //INPUT HIGH SPEED BYTE DATA
  
  //INPUT ESCAPE MODE SIGNALS FROM THE PPI
  input     wire        txrequestesc             ,   //INPUT ESCAPE MODE REQUEST SIGNAL
  input     wire        txlpdtesc                ,   //INPUT ESCAPE MODE, LOW POWER DATA TRANSMISSION REQUEST SIGNAL
  input     wire        txulpsesc                ,   //INPUT ESCAPE MODE, ULTRA LOW POWER MODE REQUEST SIGNAL
  input     wire [3:0]  txtriggeresc             ,   //INPUT ESCAPE MODE, TRIGGER REQUEST SIGNAL
  input     wire [7:0]  txdataesc                ,   //INPUT ESCAPE MODE, BYTE DATA
  input     wire        txvalidesc               ,   //INPUT ESCAPE MODE, VALID SIGNAL FOR LOW POWER TRANSMISSION
  input     wire        txulpsexit               ,   //INPUT SIGNAL TO END THE ULP EXIT STATE
  
  //INPUT TURNAROUND CONTROL SIGNALS FROM THE PPI
  input     wire        turnrequest              ,   //INPUT TURNAROUND REQUEST SIGNAL
  input     wire        turndisable              ,   //INPUT TURNAROUND DISABLE SIGNAL
  
  //INPUT COMMON CONTROL SIGNALS
  input     wire        forcerxmode              ,   //INPUT FORCE RECEIVE MODE SIGNAL
  input     wire        forcetxstopmode          ,   //INPUT SIGNAL TO FORCE THE TRANSMITTER TO STOP MODE
  
  //INTERNAL INPUT SIGNALS WITHIN THE PHY(FROM THE RECEIVER AND THE CLOCK TRANSMITTER)
  input     wire        txn_en_frm_rxr           ,   //INPUT SIGNAL IS FROM THE RECEIVER MODULE
  input     wire        dir_frm_rxr              ,   //INPUT SIGNAL FROM THE RECEIVER MODULE FOR TURNAROUND CHANGE DIRECTION
  input     wire        sot_frm_clk              ,   //INPUT SIGNAL FROM THE CLOCK LANE TO INITIATE THE DATA TRANSMISSION
  input     wire        eot_handle_proc          ,   //INPUT EOT PROCESS HANDLING 0-EXTERNAL ,1 -INTERNAL 
  input     wire        txbyteclkhs              ,   //INPUT TRANSMITTER BYTE CLOCK GENERATED FROM THE DDR CLOCK
  input     wire [7:0]  dln_cnt_hs_prep          ,   //INPUT HS PREPARE COUNT FOR DATA LANE  
  input     wire [7:0]  dln_cnt_hs_zero          ,   //INPUT HS ZERO COUNT FOR DATA LANE
  input     wire [7:0]  dln_cnt_hs_trail         ,   //INPUT HS TRAIL COUNT FOR DATA LANE 
  input     wire [7:0]  dln_cnt_hs_exit          ,   //INPUT HS EXIT COUNT FOR DATA LANE 
  input     wire [7:0]  dln_cnt_lpx              ,   //INPUT LPX COUNT FOR DATA LANE
  input     wire [5:0]  sot_sequence             , //SOT PATTEN
  input     wire        force_sot_error          , //FORCE ERROR
  input     wire        force_control_error      ,
  input     wire        force_error_esc          , //FORCE ERROR ESC
 
  //OUTPUTS
  //OUTPUT HIGH SPEED TRANSMISSION SIGNALS TO THE TRANSMITTER PPI
  output    reg         txreadyhs                ,   //OUTPUT READY SIGNAL FOR HIGH SPEED SIGNAL
  
  //OUTPUT ESCAPE MODE SIGNALS TO THE TRANSMITTER PPI
  output    reg         txreadyesc               ,   //OUTPUT READY SIGNAL FOR ESCAPE MODE LOW POWER DATA TRANSMISSION
  output    reg         ulpsactivenot            ,   //OUTPUT SIGNAL TO INTIMATE THE START OF ULPS EXIT STATE
  
  //OUTPUT HIGN SPEED TRANSMISSION SIGNALS TO THE TRANSCEIVER
  output    reg         hs_tx_cntrl              ,   //OUTPUT HIGH SPEED TRANSMITTER ENABLE SIGNAL
  output    reg         hs_tx_dp                 ,   //OUTPUT HIGH SPEED DATA LINE
  
  //OUTPUT LOW POWER DATA TRANSMISSION SIGNALS TO THE TRANSCEIVER
  output    reg         lp_tx_cntrl              ,   //OUTPUT LOW POWER TRANSMITTER ENABLE SIGNAL
  output    reg         lp_tx_dp                 ,   //OUTPUT LOW POWER LINE
  output    reg         lp_tx_dn                 ,   //OUTPUT LOW POWER LINE
  
  //OUTPUT COMMON CONTROL SIGNAL TO THE PPI
  output    reg         stopstate                ,   //OUTPUT SIGNAL TO INDICATE THAT THE LANE MODULE IS IN STOP_STATE
  
  //OUTPUT DIRECTION SIGNAL TO THE PPI
  output    wire        direction                ,   //OUTPUT DIRECTION BIT TO INDICATE WHETHER THE LANE INTERCONNECT IS TRANMITTER/RECEIVER
  
  //INRTERNAL OUPUT SIGNALS WITHIN THE PHY
  output    reg         rxn_en_to_rxr            ,   //OUTPUT SIGNAL TO THE RECEIVER MODULE DURING TURNAROUND
  output    reg         eot_to_clk                   //OUTPUT SIGNAL TO THE CLOCK LANE TO END THE CLOCK TRANSMISSION
  );
  
 
  //**********************************************************************
  //REGISTER AND NET DECLARATIONS
  //**********************************************************************
  //REGISTER DECLARATIONS
  
  //INTERNAL SIGNALS FOR HIGH SPEED TRANSMINSSION
  reg         enable_hs_sig                                                   ;
  reg         hs_st_txn_st                                                    ;
  reg         hs_txn_st                                                       ;
  reg         count_en                                                        ;
  reg         count_en_d                                                      ;
  reg         trail_end_frm_hs_dat                                            ;
  reg         end_hs_sig                                                      ;
  reg         hs_lp_tx_dp                                                     ;
  reg         hs_lp_tx_dn                                                     ;
  reg         hs_prepare_en                                                   ;
  reg         hs_prepare_dis                                                  ;
  reg [7:0]   txdata_d                                                        ;
  reg [7:0]   txdata_dd                                                       ;
  reg [7:0]   txdata_ddd                                                      ;
  reg [7:0]   txdata_dddd                                                     ;
  reg [7:0]   txdata_ddddd                                                    ;
  reg [7:0]   txdata_dd_m                                                     ;
  reg [7:0]   txdata_ddd_m                                                    ;
  
  //INTERNAL SIGNALS FOR LOW POWER CONTROL MODE
  reg         int_lp_tx_cntrl                                                 ;
  reg [2:0]   lp_mas_nstate                                                   ;
  reg [2:0]   lp_mas_pstate                                                   ;
  reg         mas_lp_tx_dp                                                    ;
  reg         mas_lp_tx_dn                                                    ;
  
  //INTERNAL SIGNALS FOR LOW POWER ESCAPE MODE
  reg         ulps                                                            ;
  reg [7:0]   cmd_dat                                                         ;
  reg [7:0]   lpdt_buffer                                                     ;
  reg         esc_end                                                         ;
  reg [3:0]   es_state                                                        ;
  reg [3:0]   lp_esc_nstate                                                   ;
  reg [3:0]   lp_esc_pstate                                                   ;
  reg         end_esc_sig                                                     ;
  reg         enable_esc_sig                                                  ;
  reg         esc_lp_tx_dp                                                    ;
  reg         esc_lp_tx_dn                                                    ;
  
  //INTERNAL SIGNALS FOR TURNAROUND PROCEDURE
  reg         sig_turnrequest                                                 ;
  reg         int_en_fr_rxn                                                   ;
  reg         end_ta_sig                                                      ;
  reg         enable_ta_sig                                                   ;
  reg         ta_lp_tx_dp                                                     ;
  reg         ta_lp_tx_dn                                                     ;
  reg         ta_ex_state                                                     ;
  reg         ta_get_cnt_en                                                   ;
  reg         ta_get_cnt_bit                                                  ;
  reg         to_assert_rxr_en                                                ;
  
 
  reg         tx_skew_req                                                     ;
  reg         toggle                                                          ;
  reg [7:0]    count_val                                                      ;
  reg [7:0]    int_counter                                                    ;
 
  //OUTPUT SIGNALS FOR LOW POWER ESCAPE MODE
  reg         enable_esc_cmd_cnt                                              ;
  reg         enable_esc                                                      ;
  reg         tx_esc_cmd_task_st                                              ;
  reg         tx_esc_cmd_task_st_end                                          ;
  reg         tx_esc_lpdt_dat_st                                              ;
  
  //OUTPUT SIGNAL FOR TURNAROUND PROCEDURE
  reg [3:0]   enb_trgg                                                        ;
  reg         lpdt                                                            ;
  //INTERNAL NET DECLARATIONS                                                 
  wire        init_mas_txn                                                    ;
  wire        init_slv_txn                                                    ;
  
  //INTERNAL SIGNAL USED FOR HIGH SPEED CONTROL SIGNAL
  wire        int_sig_hs_tx_cntrl                                             ;
  
  //INTERNAL SIGNALS FOR LOW POWER ESCAPE MODE
  wire [5:0]  sel_esc                                                         ;
  wire        enb_trgg1                                                       ;
  wire        enb_trgg2                                                       ;
  wire        enb_trgg3                                                       ;
  wire        enb_trgg4                                                       ;
  
  //INTERNAL SIGNALS FOR LOW POWER CONTROL MODE
  wire        async_stop_chk                                                  ;
  wire        int_sig_lp_tx_cntrl                                             ;
  wire        sig_lp_tx_dp                                                    ;
  wire        sig_lp_tx_dn                                                    ;
  
  //INTERNAL SIGNALS FOR TURNAROUND PROCEDURE
  wire        int_en_fr_rxn_dis                                               ;
  wire        int_en_fr_rxn_en                                                ;


  wire [7:0] HS_PATTERN;

  //OUTPUT NET DECLARATION
  
  //INTEGER DECLARATION
  integer i                                                                   ;
  integer j                                                                   ;
  
  //***************************************************************************
  // PARAMETER DECLARATIONS FOR THE LOW POWER CONTROL MODE MASTER
  //***************************************************************************
  parameter   TX_STOP             = 3'b000                                    ;
  parameter   TX_LP_RQST          = 3'b001                                    ;
  parameter   TX_LP_BRIDGE        = 3'b010                                    ;
  parameter   TX_HS_RQST          = 3'b011                                    ;
  parameter   TX_HS_PRPR          = 3'b100                                    ;
  parameter   TX_WAIT_ST          = 3'b101                                    ;
  parameter   TX_LP_RQST_ESC      = 3'b110                                    ;
  parameter   TX_LP_BRIDGE_ESC    = 3'b111                                    ;
  
  //***************************************************************************
  // PARAMETER DECLARATIONS FOR THE LOW POWER ESCAPE MODE
  //***************************************************************************
  parameter   TX_ESC_STOP         = 4'b0000                                   ;
  parameter   TX_ESC_RQST         = 4'b0001                                   ;
  parameter   TX_ESC_GO           = 4'b0010                                   ;
  parameter   TX_ESC_CMD          = 4'b0011                                   ;
  parameter   TX_ESC_TRIGGER      = 4'b0100                                   ;
  parameter   TX_ESC_ULP_DATA     = 4'b0101                                   ;
  parameter   TX_ESC_LPDT_DATA    = 4'b0110                                   ;
  parameter   TX_ESC_READY        = 4'b0111                                   ;
  parameter   TX_ESC_LPDT_DAT_OUT = 4'b1000                                   ;
  parameter   TX_ESC_MARK         = 4'b1001                                   ;
  
  parameter TLPX             = 50 `psec;// min = 60ns;    typ = nil; max = nil;
  //***************************************************************************
  //PARAMETER DECLARATION FOR HS_SYNC SEQUENCE PATTERN
  //***************************************************************************
 // parameter   HS_PATTERN = 8'b00011101;
  parameter   CALI_PATTERN = 16'b1111111111111111                             ;
  parameter   SKEW_CAL   = 16'b0101010101010101                               ;
  

  assign HS_PATTERN = force_sot_error ? {2'b00,sot_sequence} : 8'b00011101; 

  //***************************************************************************
  //PARAMETER DECLARATION FOR HS_TRAIL TIME
  //***************************************************************************
  time         interval1                                                      ;
  time         interval2                                                      ;
  time         ui                                                             ;
  integer      ths_trail_a_1                                                  ;  
  integer      ths_trail_a_2                                                  ;  
  integer      ths_trail_b_1                                                  ;  
  integer      ths_trail_b_2                                                  ;  
  integer      ths_prepare                                                    ;
  integer      ths_prepare_plus                                               ;
  integer      ths_zero                                                       ;

 initial
  begin
   ui          = 666                                                          ;
   interval1   = 0                                                            ;
   interval2   = 0                                                            ;
  end

 always@(txddrclkhs_i or txddr_i_rst_n)
  begin
   wait(txddr_i_rst_n == 1);
   @(posedge txddrclkhs_i);
   @(posedge txddrclkhs_i);
   @(posedge txddrclkhs_i);
   @(posedge txddrclkhs_i);
   interval1 = $time;
   @(negedge txddrclkhs_i);
   interval2 = $time;
   ui = interval2 - interval1;

  end
 


 always@(ui)
   begin
     ths_trail_a_1 = 1*8*ui;
     ths_trail_a_2 = 4*8*ui;
     ths_trail_b_1 = (60 `psec + (1*4*ui));
     ths_trail_b_2 = (60 `psec + (4*4*ui));

   `ifdef max ths_prepare   =  85 `psec + 6*ui;
   `elsif min ths_prepare   =  40 `psec + 4*ui;
   `else  ths_prepare   =  40 `psec + 4*ui;
   `endif
     ths_prepare_plus = 145 `psec - (40 `psec + 4*ui);
     ths_zero = 10*ui;
   end

 

  //***************************************************************************
  //PARAMETER DECLARATION FOR TA_GO TIME
  //***************************************************************************
  parameter   TA_GO = 4 `T_LPX;
  
  //***************************************************************************
  //PARAMETER DECLARATION FOR TA_GET TIME
  //***************************************************************************
  parameter   TA_GET  = 5 `T_LPX;
  
  //***************************************************************************
  //SIGNAL INITIALIZATION
  //***************************************************************************
  initial
    begin
      //SIGNALS FOR TURNAROUND PROCEDURE
      ta_get_cnt_en           = 1'b0                            ;
      ta_get_cnt_bit          = 1'b0                            ;
      rxn_en_to_rxr           = 1'b0                            ;
      end_ta_sig              = 1'b0                            ;
      ta_lp_tx_dp             = 1'b1                            ;
      ta_lp_tx_dn             = 1'b1                            ;
      ta_ex_state             = 1'b0                            ;
      to_assert_rxr_en        = 1'b0                            ;
      sig_turnrequest         = 1'b0                            ;
      int_en_fr_rxn           = 1'b0                            ;
      
      //SIGNALS FOR HIGH SPEED TRANSMINSSION
      hs_txn_st               = 1'b0                            ;
      count_en                = 1'b0                            ;
      count_en_d              = 1'b0                            ;
      hs_tx_dp                = 1'b0                            ;
      trail_end_frm_hs_dat    = 1'b0                            ;
      txreadyhs               = 1'b0                            ;
      eot_to_clk              = 1'b0                            ;
      hs_st_txn_st            = 1'b0                            ;
      end_hs_sig              = 1'b0                            ;
      hs_lp_tx_dp             = 1'b1                            ;
      hs_lp_tx_dn             = 1'b1                            ;
      hs_prepare_en           = 1'b0                            ;
      hs_prepare_dis          = 1'b0                            ;
      
      //SIGNAL FOR LOW POWER CONTROL MODE
      int_lp_tx_cntrl         = 1'b1                           ;
      
      //SIGNALS FOR LOW POWER ESCAPE MODE
      enable_esc              = 1'b0                           ;
      tx_esc_cmd_task_st      = 1'b0                           ;
      tx_esc_cmd_task_st_end  = 1'b0                           ;
      enable_esc_cmd_cnt      = 1'b0                           ;
      tx_esc_lpdt_dat_st      = 1'b0                           ;
      ulps                    = 1'b0                           ;
      tx_skew_req             = 1'b0                           ;
    end
 
  always@(negedge tx_byte_rst_n)
   begin

          end_ta_sig         <= 1'b0                          ;
          ta_lp_tx_dp        <= 1'b1                          ;
          ta_lp_tx_dn        <= 1'b1                          ;
          end_hs_sig         <= 1'b0                          ;
          hs_lp_tx_dp        <= 1'b1                          ;
          hs_lp_tx_dn        <= 1'b1                          ;
          int_lp_tx_cntrl    <= 1'b1                          ;
          hs_tx_cntrl        <= 1'b0                          ;
          disable enable_hs_sig_loop  	                      ;
          disable comb_block          	                      ;
          disable comb_block1         	                      ;
          disable lp_mas_pstate_loop	                      ;
          disable ta_get_cnt_bit_loop	                      ;
          disable ta_lp_tx_dp_loop	                      ;
          disable rxn_en_to_rxr_loop	                      ;
          disable eot_to_clk_loop	                      ;
          disable hs_prepare_en_loop	                      ;
          disable hs_prepare_dis_loop	                      ;
          disable fsm_esc_mode		                      ;
          disable for_loop_esc_lp	                      ;
          disable esc_counter		                      ;
          disable lp_esc_pstate_loop	                      ;
          disable lp_esc_pstate_loop1	                      ;
          disable count_en_d_loop	                      ;
          disable stopstate_loop	                      ;
          disable hs_txn_st_loop	                      ;
          disable hs_tx_dp_loop		                      ;
          disable txclkesc_output_loop	                      ;
          disable txclkesc_cntrl_loop	                      ;
          disable esc_end_loop		                      ;
          disable ulps1_loop		                      ;
          disable ulps2_loop		                      ;
          disable ulps_loop		                      ;
          disable enb_trgg_loop		                      ;
          disable lpdt_loop		                      ;
          disable txdata_flop_loop	                      ;
          disable txdata_flop_d_loop	                      ;
          disable int_en_fr_rxn_loop	                      ;
          disable int_en_fr_rxn1_loop	                      ;
          disable sig_turnrequest_loop	                      ;
          disable sig_turnrequest1	                      ;
          disable sig_turnrequest2	                      ;
          disable lpdt_buffer_loop	                      ;
          disable async_stop_chk_loop	                      ;
      //SIGNALS FOR TURNAROUND PROCEDURE
      ta_get_cnt_en           = 1'b0                          ;
      ta_get_cnt_bit          = 1'b0                          ;
      rxn_en_to_rxr           = 1'b0                          ;
      end_ta_sig              = 1'b0                          ;
      ta_lp_tx_dp             = 1'b1                          ;
      ta_lp_tx_dn             = 1'b1                          ;
      ta_ex_state             = 1'b0                          ;
      to_assert_rxr_en        = 1'b0                          ;
      sig_turnrequest         = 1'b0                          ;
      int_en_fr_rxn           = 1'b0                          ;
      //SIGNALS FOR HIGH SPEED TRANSMINSSION
      hs_txn_st               = 1'b0                          ;
      count_en                = 1'b0                          ;
      count_en_d              = 1'b0                          ;
      hs_tx_dp                = 1'b0                          ;
      trail_end_frm_hs_dat    = 1'b0                          ;
      txreadyhs               = 1'b0                          ;
      eot_to_clk              = 1'b0                          ;
      hs_st_txn_st            = 1'b0                          ;
      end_hs_sig              = 1'b0                          ;
      hs_lp_tx_dp             = 1'b1                          ;
      hs_lp_tx_dn             = 1'b1                          ;
      hs_prepare_en           = 1'b0                          ;
      hs_prepare_dis          = 1'b0                          ;
      
      //SIGNAL FOR LOW POWER CONTROL MODE
      int_lp_tx_cntrl         = 1'b1                          ;
      
      //SIGNALS FOR LOW POWER ESCAPE MODE
      enable_esc              = 1'b0                          ;
      tx_esc_cmd_task_st      = 1'b0                          ;
      tx_esc_cmd_task_st_end  = 1'b0                          ;
      enable_esc_cmd_cnt      = 1'b0                          ;
      tx_esc_lpdt_dat_st      = 1'b0                          ;
      ulps                    = 1'b0                          ;
      tx_skew_req             = 1'b0                          ;
      toggle                  = 1'b0                          ;

   end	   
 
  always@(*) 
   begin
    if(tx_skewcallhs)
     begin
       tx_skew_req = 1'b1;
       wait(count_en_d);
       wait(!count_en_d);
       tx_skew_req = 1'b0;
     end
   end
  


  //***************************************************************************
  // ASYNCHRONOUS SIGNAL ASSIGNMENTS FOR INTERNAL AND OUTPUT SIGNALS
  //***************************************************************************
  //INTERNAL SIGNALS TO INDICATE THE TRIGGER VALUES
  assign enb_trgg1 = txtriggeresc[0];
  assign enb_trgg2 = txtriggeresc[1];
  assign enb_trgg3 = txtriggeresc[2];
  assign enb_trgg4 = txtriggeresc[3];
  
  //INTERNAL SIGNAL TO SELECT THE ESCAPE MODE ENTRY COMMAND
  assign sel_esc = {ulps,lpdt,enb_trgg[3],enb_trgg[2],enb_trgg[1],enb_trgg[0]};
  
  //OUTPUT DIRECTION BIT FROM THE TRANSMITTER PHY
  assign direction = dir_frm_rxr;
  
  //INTERNAL SIGNAL TO INITIATE THE MASTER OPERATION AFTER ITS REQUEST
  assign init_mas_txn = ((((txrequesths | tx_skew_req) & !trail_end_frm_hs_dat)
    | (txrequestesc & !esc_end) | (sig_turnrequest & !turndisable)) & master_pin);
  
  //INTERNAL SIGNAL TO INITIATE THE SLAVE OPERATION AFTER ITS REQUEST
  assign init_slv_txn = ((((txrequesths | tx_skew_req) & !trail_end_frm_hs_dat)
    | (txrequestesc & !esc_end) | (sig_turnrequest & !turndisable)) & !master_pin);
  
  //INTERNAL SIGNAL TO ASSERT THE ASYNCHRONOUS STOP
  assign async_stop_chk = (forcetxstopmode | forcerxmode);
  
  //INTERNAL LOW POWER DATA TRANSMITTER ENABLE SIGNAL
  assign int_sig_lp_tx_cntrl = (int_lp_tx_cntrl & !int_en_fr_rxn & !dir_frm_rxr);
  
  //INTERNAL HIGH SPEED DATA TRANSMITTER ENABLE SIGNAL
  assign int_sig_hs_tx_cntrl = (!int_lp_tx_cntrl & !dir_frm_rxr);
  
  //INTERNAL LOW POWER DATA TRANSMISSION LINE
  assign sig_lp_tx_dp = (esc_lp_tx_dp & mas_lp_tx_dp & ta_lp_tx_dp
    & hs_lp_tx_dp) ? 1'b1 : 1'b0;
  
  //INTERNAL LOW POWER DATA TRANSMISSION LINE
  assign sig_lp_tx_dn = (esc_lp_tx_dn & mas_lp_tx_dn & ta_lp_tx_dn
    & hs_lp_tx_dn) ? 1'b1 : 1'b0;
  
  //INTERNAL SIGNAL ASSIGNED DURING TURNAROUND OPERATION
  assign int_en_fr_rxn_dis = (forcetxstopmode | (dir_frm_rxr & txn_en_frm_rxr));
  
  //INTERNAL SIGNAL ASSIGNED DURING TURNAROUND OPERATION
  assign int_en_fr_rxn_en = (ta_ex_state && !dir_frm_rxr);
  
  //***************************************************************************
  //ASSIGNING THE ESCAPE MODE ENTRY COMMAND FOR THE APPROPRIATE REQUEST SIGNAL
  //***************************************************************************
  always @(sel_esc)
    begin :comb_block
      cmd_dat  = 8'b00000000;
      es_state = TX_ESC_STOP;
      case(sel_esc)
        6'b100000:
          begin
           if(force_error_esc)
            cmd_dat  = 8'b00011100;
           else
            cmd_dat  = 8'b00011110;
            es_state = TX_ESC_ULP_DATA;
          end
        6'b010000:
          begin
           if(force_error_esc)
            cmd_dat  = 8'b00011100;
           else
            cmd_dat  = 8'b11100001;
            es_state = TX_ESC_LPDT_DATA;
          end
        6'b000001:
          begin
           if(force_error_esc)
            cmd_dat  = 8'b00011100;
           else
            cmd_dat  = 8'b01100010;
            es_state = TX_ESC_TRIGGER;
          end
        6'b000010:
          begin
           if(force_error_esc)
            cmd_dat  = 8'b00011100;
           else
            cmd_dat  = 8'b01011101;
            es_state = TX_ESC_TRIGGER;
          end
        6'b000100:
          begin
           if(force_error_esc)
            cmd_dat  = 8'b00011100;
           else
            cmd_dat  = 8'b00100001;
            es_state = TX_ESC_TRIGGER;
          end
        6'b001000:
          begin
           if(force_error_esc)
            cmd_dat  = 8'b00011100;
           else
            cmd_dat  = 8'b10100000;
            es_state = TX_ESC_TRIGGER;
          end
        default:
          begin
            cmd_dat  = 8'b00000000;
            es_state = TX_ESC_STOP;
            
          end
      endcase
    end
  
  //***************************************************************************
  //MASTER FSM FOR LOW POWER CONTROL MODE TRANSMITTER
  //***************************************************************************
  always @(lp_mas_pstate or txrequesths or tx_skew_req
    or txrequestesc or sig_turnrequest
    or init_mas_txn  or init_slv_txn
    or sot_frm_clk or txn_en_frm_rxr or dir_frm_rxr
    or end_hs_sig or end_ta_sig or end_esc_sig or ta_get_cnt_bit)
    begin :comb_block1
      lp_mas_nstate  = TX_STOP;
      enable_esc_sig = 1'b0;
      enable_hs_sig  = 1'b0;
      enable_ta_sig  = 1'b0;
      mas_lp_tx_dp   = 1'b1;
      mas_lp_tx_dn   = 1'b1;
      case(lp_mas_pstate)
        //INTIAL AND IDLE STOP STATE
        TX_STOP:
          tx_stop_task;
        
        //TRANSMITTER LP RQST STATE
        TX_LP_RQST:
          tx_lp_rqst_task;
        
        //TRANSMITTER LP RQST STATE
        TX_LP_RQST_ESC:
          tx_lp_rqst_esc_task;
        
        //TRANSMITTER LP BRIDGE STATE
        TX_LP_BRIDGE:
          tx_lp_bridge_task;
        
        //TRANSMITTER LP BRIDGE STATE
        TX_LP_BRIDGE_ESC:
          tx_lp_bridge_esc_task;
        
        //HIGH SPEED DATA TRANSMISSION REQUEST STATE
        TX_HS_RQST:
          tx_hs_rqst_task;
        
        //HIGH SPEED PREPARE STATE
        TX_HS_PRPR:
          tx_hs_prpr_task;
        
        //WAIT STATE TO HOLD THE STATE MACHINE DURING DIFFERENT OPERATIONS
        TX_WAIT_ST:
          tx_wait_st_task;
        
        //DEFAULT STATE
        default :
          begin
            enable_esc_sig = 1'b0;
            enable_hs_sig  = 1'b0;
            enable_ta_sig  = 1'b0;
            lp_mas_nstate = TX_STOP;
          end
      endcase
    end

  //***************************************************************************
  //INTIAL AND IDLE STOP STATE
  //***************************************************************************
  task tx_stop_task;
    begin
      enable_esc_sig = 1'b0;
      enable_hs_sig  = 1'b0;
      enable_ta_sig  = 1'b0;
      ta_ex_state = 1'b0;
      end_ta_sig = 1'b0;
      hs_st_txn_st = 1'b0;
      end_hs_sig = 1'b0;
      //eot_to_clk = 1'b0;
      ta_get_cnt_en = 1'b0;
      ta_get_cnt_bit = 1'b0;
      if(txn_en_frm_rxr & dir_frm_rxr)
        begin
          mas_lp_tx_dp  = 1'b0;
          mas_lp_tx_dn  = 1'b0;
          ta_get_cnt_en = 1'b1;
          lp_mas_nstate = TX_LP_BRIDGE;
        end
      else if((init_mas_txn | init_slv_txn)&((txrequesths & sot_frm_clk)
        | txrequestesc | sig_turnrequest | tx_skew_req))
        begin
          if((txrequesths | tx_skew_req))
            begin
            if(force_control_error)
              lp_mas_nstate = TX_LP_RQST;
            else
              lp_mas_nstate = TX_HS_RQST;
              enable_esc_sig = 1'b0;
              enable_hs_sig  = 1'b0;
              enable_ta_sig  = 1'b0;
              mas_lp_tx_dp = 1'b0;
              mas_lp_tx_dn = 1'b1;
            end
          else if(txrequestesc)
            begin
              mas_lp_tx_dp  = 1'b1;
              mas_lp_tx_dn  = 1'b1;
              lp_mas_nstate = TX_LP_RQST_ESC;
            end
          else if(sig_turnrequest)
            begin
              mas_lp_tx_dp  = 1'b1;
              mas_lp_tx_dn  = 1'b1;
              lp_mas_nstate = TX_LP_RQST;
            end
          else
            begin
              mas_lp_tx_dp  = 1'b1;
              mas_lp_tx_dn  = 1'b1;
              lp_mas_nstate = TX_STOP;
            end
        end
      else
        begin
          mas_lp_tx_dp  = 1'b1;
          mas_lp_tx_dn  = 1'b1;
          lp_mas_nstate = TX_STOP;
        end
    end
  endtask
  
  //***************************************************************************
  //TRANSMITTER LP RQST STATE
  //***************************************************************************
  task tx_lp_rqst_task;
    begin
      enable_esc_sig = 1'b0;
      enable_hs_sig  = 1'b0;
      enable_ta_sig  = 1'b0;
      if(sig_turnrequest)
        begin
          lp_mas_nstate = TX_LP_BRIDGE;
          mas_lp_tx_dp = 1'b1;
          mas_lp_tx_dn = 1'b0;
        end
      else
        begin
          lp_mas_nstate = TX_STOP;
          mas_lp_tx_dp = 1'b1;
          mas_lp_tx_dn = 1'b1;
        end
    end
  endtask
  
  //TRANSMITTER LP RQST STATE
  task tx_lp_rqst_esc_task;
    begin
      enable_esc_sig = 1'b0;
      enable_hs_sig  = 1'b0;
      enable_ta_sig  = 1'b0;
      lp_mas_nstate = TX_LP_BRIDGE_ESC;
      mas_lp_tx_dp = 1'b1;
      mas_lp_tx_dn = 1'b0;
    end
  endtask
  
  //***************************************************************************
  //TRANSMITTER LP BRIDGE STATE
  //***************************************************************************
  task tx_lp_bridge_task;
    begin
      mas_lp_tx_dp = 1'b0;
      mas_lp_tx_dn = 1'b0;
      enable_hs_sig  = 1'b0;
      
      if( sig_turnrequest || ta_get_cnt_bit)
        begin
          
          enable_esc_sig = 1'b0;
          enable_ta_sig  = 1'b1;
          lp_mas_nstate = TX_WAIT_ST;
        end
      else if(!ta_get_cnt_bit)
        begin
          
          lp_mas_nstate = TX_LP_BRIDGE;
          enable_esc_sig = 1'b0;
          enable_ta_sig  = 1'b0;
        end
      else
        begin
          enable_esc_sig = 1'b0;
          enable_ta_sig  = 1'b0;
          lp_mas_nstate = TX_STOP;
        end
    end
  endtask
  
  //TRANSMITTER LP BRIDGE STATE
  task tx_lp_bridge_esc_task;
    begin
      mas_lp_tx_dp = 1'b0;
      mas_lp_tx_dn = 1'b0;
      enable_hs_sig  = 1'b0;
      enable_ta_sig  = 1'b0;
      enable_esc_sig = 1'b1;
      lp_mas_nstate = TX_WAIT_ST;
    end
  endtask
  
  //***************************************************************************
  //HIGH SPEED DATA TRANSMISSION REQUEST STATE
  //***************************************************************************
  task tx_hs_rqst_task;
    begin
      mas_lp_tx_dp = 1'b0;
      mas_lp_tx_dn = 1'b0;
      enable_esc_sig = 1'b0;
      enable_ta_sig  = 1'b0;
      if(txrequesths | tx_skew_req)
        lp_mas_nstate = TX_HS_PRPR;
      else
        lp_mas_nstate = TX_STOP;
    end
  endtask
  
  //***************************************************************************
  //HIGH SPEED PREPARE STATE
  //***************************************************************************
  task tx_hs_prpr_task;
    begin
      mas_lp_tx_dp = 1'b0;
      mas_lp_tx_dn = 1'b0;
      enable_esc_sig = 1'b0;
      enable_ta_sig  = 1'b0;
      if(txrequesths | tx_skew_req)
        begin
          enable_hs_sig = 1'b1;
          lp_mas_nstate = TX_WAIT_ST;
        end
      else
        begin
          enable_hs_sig  = 1'b0;
          lp_mas_nstate = TX_STOP;
        end
    end
  endtask
  
  //***************************************************************************
  //WAIT STATE TO HOLD THE STATE MACHINE DURING DIFFERENT OPERATIONS
  //***************************************************************************
  task tx_wait_st_task;
    begin
      enable_esc_sig = 1'b0;
      enable_hs_sig  = 1'b0;
      enable_ta_sig  = 1'b0;
      mas_lp_tx_dp = 1'b1;
      mas_lp_tx_dn = 1'b1;
      if(end_hs_sig | end_ta_sig | end_esc_sig)
        lp_mas_nstate = TX_STOP;
      else
        lp_mas_nstate = TX_WAIT_ST;
    end
  endtask
  
  
  //***************************************************************************
  //PROCESS FOR NEXT STATE TRANSITION
  //***************************************************************************
  always @(posedge txclkesc)
    begin:lp_mas_pstate_loop
      if(txescclk_rst_n)
        begin
          if(async_stop_chk)
            lp_mas_pstate <= TX_STOP;
          else
            lp_mas_pstate <= lp_mas_nstate;
        end
    end
  
  //******************************************************************************
  //PROCESS TO GENERATE ENABLE SIGNAL TO STOP TRANSMITING LP00 DURING TA_GET TIME
  //******************************************************************************
  always @ (posedge ta_get_cnt_en)
    begin:ta_get_cnt_bit_loop
//      #(TA_GET `nsec);
      count_val = (5 *  (4 * dln_cnt_lpx));//for getting ddr count
      tx_counter(count_val);
      ta_get_cnt_bit = 1'b1;
    end
  
  //***************************************************************************
  //PROCESS FOR TRANSMITTING LOW POWER CONTROL SEQUENCE DURING TURN AROUND
  //FROM RECEIVER TO TRANSMITTER OR FROM TRANSMITTER TO RECEIVER
  //***************************************************************************
  always @(posedge enable_ta_sig)
    begin:ta_lp_tx_dp_loop
      @(posedge txclkesc);
      ta_lp_tx_dp = 1'b1;
      ta_lp_tx_dn = 1'b0;
      if(sig_turnrequest)
        begin
          end_ta_sig = 1'b0;
          to_assert_rxr_en = 1'b1;
          if(dir_frm_rxr)
            begin
              while(dir_frm_rxr)
                begin
                  @(posedge txclkesc);
                end
            end
          else
            begin
              @(posedge txclkesc);
              ta_lp_tx_dp = 1'b0;
              ta_lp_tx_dn = 1'b0;
            //  #(TA_GO `nsec);
      
      count_val = (4 * (4 * dln_cnt_lpx));
      tx_counter(count_val);
            end
          ta_ex_state = 1'b1;
          end_ta_sig = 1'b1;
          @(posedge txclkesc);
          ta_lp_tx_dp = 1'b1;
          ta_lp_tx_dn = 1'b1;
        end
      else
        begin
          @(posedge txclkesc);
          end_ta_sig = 1'b1;
          ta_lp_tx_dp = 1'b1;
          ta_lp_tx_dn = 1'b1;
        end
    end
  
  //***************************************************************************
  //PROCESS FOR ASSIGNING THE RXN_EN_TO_RXR OUTPUT SIGNAL DURING TURNAROUND
  //***************************************************************************
  always @(posedge to_assert_rxr_en)
    begin:rxn_en_to_rxr_loop
      @(posedge txclkesc);
      @(posedge txclkesc);
      @(posedge txclkesc);
      if(txescclk_rst_n)
        rxn_en_to_rxr <= 1'b1;
      @(posedge txclkesc);
      rxn_en_to_rxr <= 1'b0;
      to_assert_rxr_en = 1'b0;
    end
  
  //***************************************************************************
  //PROCESS FOR TRANSMITTING LOW POWER CONTROL SEQUENCE DURING
  //HIGH SPEED DATA TRANSMISSION
  //***************************************************************************
  always @(posedge enable_hs_sig)
    begin : enable_hs_sig_loop
      end_hs_sig = 1'b0;
      hs_lp_tx_dp = 1'b0;
      hs_lp_tx_dn = 1'b0;
      int_lp_tx_cntrl = 1'b1;
      hs_prepare_en = 1'b1;
      @(posedge hs_prepare_dis);
      int_lp_tx_cntrl = 1'b0;
      hs_st_txn_st = 1'b1;
      @(posedge trail_end_frm_hs_dat);
      hs_txn_st = 1'b0;
      //eot_to_clk = 1'b1;
      hs_lp_tx_dp = 1'b1;
      hs_lp_tx_dn = 1'b1;
      int_lp_tx_cntrl = 1'b1;
      @(posedge txclkesc);
      trail_end_frm_hs_dat <= 1'b0;
      //eot_to_clk = 1'b0;
      end_hs_sig = 1'b0;
      hs_lp_tx_dp = 1'b1;
      hs_lp_tx_dn = 1'b1;
      int_lp_tx_cntrl = 1'b1;
     if(!eot_handle_proc)
      @(posedge txclkesc);
      hs_lp_tx_dp = 1'b1;
      hs_lp_tx_dn = 1'b1;
      int_lp_tx_cntrl = 1'b1;
      end_hs_sig = 1'b1;
    end
  
  always @(posedge stopstate)
    begin:eot_to_clk_lp
      eot_to_clk = 1'b1;
    end
  
  always @(posedge async_stop_chk)
    begin:eot_to_clk_lp1
      @(posedge txclkesc);
      eot_to_clk = 1'b1;
    end
  always @(posedge txrequesths or posedge tx_skew_req)
    begin:eot_to_clk_loop
      eot_to_clk = 1'b0;
    end
  //***************************************************************************
  //PROCESS TO GENERATE ENABLE SIGNLAL FOR STOPING THE THS_PREPARE TRANSMISSION
  //***************************************************************************
  always @(posedge hs_prepare_en)
    begin:hs_prepare_en_loop
      //#(THS_PREPARE `nsec);
      //#(ths_prepare `nsec);
      count_val = (4 * dln_cnt_hs_prep);//for getting ddr count
      tx_counter(count_val);
      hs_prepare_dis = 1'b1;
      hs_prepare_en = 1'b0;
    end
  
  //***************************************************************************
  //PROCESS TO GENERATE ENABLE SIGNAL FOR STOPING THE THS_ZERO TRANSMISSION
  //***************************************************************************
  always @(posedge hs_st_txn_st)
    begin:hs_prepare_dis_loop
     // #(THS_PREPARE_PLUS `nsec);
      #(ths_prepare_plus `nsec);
    //  #(THS_ZERO `nsec);
      count_val = (4 * dln_cnt_hs_zero);//for getting ddr count
      tx_counter(count_val);
      hs_txn_st = 1'b1;
      hs_prepare_dis = 1'b0;
    end
  
  //***************************************************************************
  //FSM FOR LOW POWER ESCAPE MODE TRANSMITTER
  //***************************************************************************
  always @(lp_esc_pstate
    or txrequestesc or esc_end or ulps or es_state or txvalidesc
    or txulpsexit or enable_esc_sig or tx_esc_cmd_task_st_end
    or enable_esc_cmd_cnt or enable_esc)
    begin : fsm_esc_mode
      lp_esc_nstate = TX_ESC_STOP;
      end_esc_sig = 1'b0;
      case(lp_esc_pstate)
        
        //INTIAL AND IDLE STOP STATE
        TX_ESC_STOP:
          tx_esc_stop_task;
        
        //TRANSMITTER ESCAPE MODE REQUEST STATE
        TX_ESC_RQST:
          tx_esc_rqst_task;
        
        //TRANSMITTER ESCAPE MODE GO STATE
        TX_ESC_GO:
          tx_esc_go_task;
        
        //TRANSMISION OF ESCAPE MODE ENTRY COMMAND STATE
        TX_ESC_CMD:
          tx_esc_cmd_task;
        
        //ESCAPE MODE TRIGGERS TRANSMISSION STATE
        TX_ESC_TRIGGER:
          tx_esc_trigger_task;
        
        //ESCAPE MODE ULTRA LOW POWER TRANSMISSION STATE
        TX_ESC_ULP_DATA:
          tx_esc_ulp_data_task;
        
        //ESCAPE MODE LOW POWER DATA TRANSMISSION INITIATING STATE
        TX_ESC_LPDT_DATA:
          tx_esc_lpdt_data_task;
        
        //ESCAPE MODE STATE  TO SEND THE READY STATE
        TX_ESC_READY:
          tx_esc_ready_task;
        
        //ESCAPE MODE DATA OUTPUT STATE
        TX_ESC_LPDT_DAT_OUT:
          tx_esc_lpdt_dat_out_task;
        
        //ESCAPE MODE FINAL MARK STATE BEFORE STOP STATE
        TX_ESC_MARK:
          tx_esc_mark_task;
        
        //DEFAULT STATE
        default :
          begin
            esc_lp_tx_dp = 1'b1;
            esc_lp_tx_dn = 1'b1;
            end_esc_sig = 1'b0;
            lp_esc_nstate = TX_ESC_STOP;
          end
      endcase
    end
  
  //***************************************************************************
  //INTIAL AND IDLE STOP STATE
  //***************************************************************************
  task tx_esc_stop_task;
    begin
      end_esc_sig = 1'b0;
      esc_lp_tx_dp = 1'b1;
      esc_lp_tx_dn = 1'b1;
      tx_esc_cmd_task_st = 1'b0;
      tx_esc_cmd_task_st_end = 1'b0;
      if(enable_esc_sig)
        lp_esc_nstate = TX_ESC_RQST;
      else
        lp_esc_nstate = TX_ESC_STOP;
    end
  endtask
  
  //***************************************************************************
  //TRANSMITTER ESCAPE MODE REQUEST STATE
  //***************************************************************************
  task tx_esc_rqst_task;
    begin
      esc_lp_tx_dp = 1'b0;
      esc_lp_tx_dn = 1'b1;
      lp_esc_nstate = TX_ESC_GO;
      end_esc_sig = 1'b0;
    end
  endtask
  
  //***************************************************************************
  //TRANSMITTER ESCAPE MODE GO STATE
  //***************************************************************************
  task tx_esc_go_task;
    begin
      esc_lp_tx_dp = 1'b0;
      esc_lp_tx_dn = 1'b0;
      tx_esc_cmd_task_st = 1'b1;
      lp_esc_nstate = TX_ESC_CMD;
      end_esc_sig = 1'b0;
    end
  endtask
  
  //***************************************************************************
  //TRANSMISION OF ESCAPE MODE ENTRY COMMAND STATE
  //***************************************************************************
  task tx_esc_cmd_task;
    begin
      
      end_esc_sig = 1'b0;
      if(!tx_esc_cmd_task_st_end)
        lp_esc_nstate = TX_ESC_CMD;
      else
        lp_esc_nstate = es_state;
    end
  endtask
  
  //***************************************************************************
  //ASSIGNING COMMAND PATTERN TO INTERNAL LOW POWER DATA TRANSMISSION LINES
  //***************************************************************************
  always @(posedge tx_esc_cmd_task_st)
    begin: for_loop_esc_lp
      for(i=8;i>0;i=i-1)
        begin
          @(posedge txclkesc);
          esc_lp_tx_dp = cmd_dat[i-1];
          esc_lp_tx_dn = ~cmd_dat[i-1];
          @(posedge txclkesc);
          esc_lp_tx_dp = 1'b0;
          esc_lp_tx_dn = 1'b0;
        end
      tx_esc_cmd_task_st_end = 1'b1;
    end
  
  //***************************************************************************
  //ESCAPE MODE TRIGGERS TRANSMISSION STATE
  //***************************************************************************
  task tx_esc_trigger_task;
    begin
      if(!txrequestesc)
        begin
          end_esc_sig = 1'b0;
          esc_lp_tx_dp = 1'b1;
          esc_lp_tx_dn = 1'b0;
          lp_esc_nstate = TX_ESC_MARK;
        end
      else
        begin
          end_esc_sig = 1'b0;
          esc_lp_tx_dp = 1'b0;
          esc_lp_tx_dn = 1'b0;
          lp_esc_nstate = TX_ESC_TRIGGER;
        end
    end
  endtask
  
  //***************************************************************************
  //ESCAPE MODE ULTRA LOW POWER TRANSMISSION STATE
  //***************************************************************************
  task tx_esc_ulp_data_task;
    begin
      enable_esc_cmd_cnt = 1'b0;
      if(txrequestesc)
        begin
          end_esc_sig = 1'b0;
          if (!txulpsexit)
            begin
              esc_lp_tx_dp = 1'b0;
              esc_lp_tx_dn = 1'b0;
              lp_esc_nstate = TX_ESC_ULP_DATA;
            end
          else
            begin
              esc_lp_tx_dp = 1'b1;
              esc_lp_tx_dn = 1'b0;
              lp_esc_nstate = TX_ESC_MARK;
            end
        end
      else
        begin
          esc_lp_tx_dp = 1'b0;
          esc_lp_tx_dn = 1'b0;
          lp_esc_nstate = TX_ESC_STOP;
          end_esc_sig = 1'b1;
        end
    end
  endtask
  
  //  //***************************************************************************
  //  //ESCAPE MODE LOW POWER DATA TRANSMISSION INITIATING STATE
  //  //***************************************************************************
  task tx_esc_lpdt_data_task;
    begin
      esc_lp_tx_dp = 1'b0;
      esc_lp_tx_dn = 1'b0;
      enable_esc_cmd_cnt = 1'b0;
      enable_esc = 1'b0;
      tx_esc_lpdt_dat_st = 1'b0;
      end_esc_sig = 1'b0;
      lp_esc_nstate = TX_ESC_READY;
    end
  endtask
  //
  //***************************************************************************
  //ESCAPE MODE STATE  TO SEND THE READY STATE
  //***************************************************************************
  task tx_esc_ready_task;
    begin
      end_esc_sig = 1'b0;
      //      esc_lp_tx_dp = 1'b0;
      //      esc_lp_tx_dn = 1'b0;
      
      if(txrequestesc)
        begin
          esc_lp_tx_dp = 1'b0;
          esc_lp_tx_dn = 1'b0;
          if(txvalidesc)
            begin
              lp_esc_nstate = TX_ESC_LPDT_DAT_OUT;
              
            end
          else
            lp_esc_nstate = TX_ESC_READY;
        end
      else
        begin
          esc_lp_tx_dp = 1'b1;
          esc_lp_tx_dn = 1'b0;
          lp_esc_nstate = TX_ESC_MARK;
        end
      
    end
  endtask
  
  //***************************************************************************
  //ESCAPE MODE DATA OUTPUT STATE
  //***************************************************************************
  task tx_esc_lpdt_dat_out_task;
    begin
      end_esc_sig = 1'b0;
      if(!enable_esc_cmd_cnt && txescclk_rst_n)// && !esc_end)
        begin
          tx_esc_lpdt_dat_st = 1'b1;
          lp_esc_nstate = TX_ESC_LPDT_DAT_OUT;
        end
      else
        begin
          lp_esc_nstate = TX_ESC_LPDT_DATA;
        end
    end
  endtask
  
  //***************************************************************************
  //ASSIGNING DATA TO INTERNAL LOW POWER DATA TRANSMISSION LINES
  //***************************************************************************
  always @(posedge tx_esc_lpdt_dat_st)
    begin: esc_counter
      for(j=8;j>0;j=j-1)
        begin
          @(posedge txclkesc);
          esc_lp_tx_dp = lpdt_buffer[j-1];
          esc_lp_tx_dn = ~lpdt_buffer[j-1];
          @(posedge txclkesc);
          esc_lp_tx_dp = 1'b0;
          esc_lp_tx_dn = 1'b0;
        end
      enable_esc_cmd_cnt = 1'b1;
      enable_esc = 1'b1;
    end
  
  //***************************************************************************
  //ESCAPE MODE FINAL MARK STATE BEFORE STOP STATE
  //***************************************************************************
  task tx_esc_mark_task;
    begin
      if(ulps & txrequestesc)
        begin
          esc_lp_tx_dp = 1'b1;
          esc_lp_tx_dn = 1'b0;
          end_esc_sig = 1'b0;
          lp_esc_nstate = TX_ESC_MARK;
        end
      else
        begin
          esc_lp_tx_dp = 1'b1;
          esc_lp_tx_dn = 1'b1;
          lp_esc_nstate = TX_ESC_STOP;
          end_esc_sig = 1'b1;
        end
    end
  endtask
  
  //***************************************************************************
  //PROCESS FOR NEXT STATE TRANSITION
  //***************************************************************************
  always @(posedge txclkesc)
    begin:lp_esc_pstate_loop
      if(txescclk_rst_n)
        begin
          if(async_stop_chk)
            lp_esc_pstate <= TX_ESC_STOP;
          else
            lp_esc_pstate <= lp_esc_nstate;
        end
    end
  
  //***************************************************************************
  //PROCESS FOR TRANSMITTING THE PATTERN SEQUENCE AND DATA DURING HIGH
  //SPEED TRANSMISSION
  //***************************************************************************
  always @(posedge count_en_d)
    begin:hs_tx_dp_loop
      //FORWARD HIGH SPEED TRANSMISSION
      if(master_pin)
        begin
          //HIGH SPEED FORWARD SYNCHRONIZATION SEQUENCE TRANSMISSION
          if(txrequesths)
            begin
              @(posedge txddrclkhs_i);
              hs_tx_dp <= HS_PATTERN[7];
              @(posedge txbyteclkhs);
              txreadyhs <= 1'b1;
              @(negedge txddrclkhs_i);
              hs_tx_dp <= HS_PATTERN[6];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= HS_PATTERN[5];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= HS_PATTERN[4];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= HS_PATTERN[3];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= HS_PATTERN[2];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= HS_PATTERN[1];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= HS_PATTERN[0];
            end 
	   else if(tx_skew_req)
            begin
              $display($time,"\tDPHY MASTER BFM :TSKEWCAL_SYNC PATTERN TRANSMISSION\n");
              @(posedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[15];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[14];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[13];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[12];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[11];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[10];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[9];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[8];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[7];
//              @(posedge txbyteclkhs);
//              txreadyhs <= 1'b1;
              @(negedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[6];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[5];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[4];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[3];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[2];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[1];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= CALI_PATTERN[0];
              $display($time,"\tDPHY MASTER BFM : TSKEWCAL SECEQUENCE TRANSMISSION\n");

             //repeat(16380)
             while(tx_skewcallhs)
              begin
               if(toggle)
                begin
                 @(posedge txddrclkhs_i);
                 hs_tx_dp <= 1'b0;
                end
               else
                begin
                 @(negedge txddrclkhs_i);
                 hs_tx_dp <= 1'b1;
                end
                toggle = ~toggle;
              end
          /*    @(posedge txddrclkhs_i);
              hs_tx_dp <=  ~hs_tx_dp;
              @(posedge txbyteclkhs);
            //  txreadyhs <= 1'b1;
              @(negedge txddrclkhs_i);
              hs_tx_dp <=  1'b1;
              @(posedge txddrclkhs_i);
              hs_tx_dp <=  1'b0;
              @(negedge txddrclkhs_i);
              hs_tx_dp <=  1'b1;
              @(posedge txddrclkhs_i);
              hs_tx_dp <=  1'b0;
              @(negedge txddrclkhs_i);
              hs_tx_dp <=  1'b1;
              @(posedge txddrclkhs_i);
              hs_tx_dp <=  1'b0;
              @(negedge txddrclkhs_i);
              hs_tx_dp <=  1'b1;*/
            
            end 
         else
            hs_tx_dp <= 1'b0;

         //FORWARD HIGH SPEED DATA TRANSMISSION
          while(txrequesths)
            begin
              @(posedge txddrclkhs_i);
              hs_tx_dp <= txdata_ddd_m[0];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= txdata_ddd_m[1];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= txdata_ddd_m[2];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= txdata_ddd_m[3];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= txdata_ddd_m[4];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= txdata_ddd_m[5];
              @(posedge txddrclkhs_i);
              hs_tx_dp <= txdata_ddd_m[6];
              @(negedge txddrclkhs_i);
              hs_tx_dp <= txdata_ddd_m[7];
            end
         //HIGH SPEED FORWARD TRAIL SEQUENCE TRANSMISSION
          @(posedge txddrclkhs_i);
          txreadyhs <= 1'b0;
          if(txdata_dd[7])//TRAIL_0 TRANSMISSION
            hs_tx_dp <= 1'b0;
          else if(!txdata_dd[7])//TRAIL_1 TRANSMISSION
            hs_tx_dp <= 1'b1;

 if(eot_handle_proc)
   begin
       count_en = 1'b0;
       @(posedge txbyteclkhs);
       @(posedge txbyteclkhs);
       @(posedge txbyteclkhs);
       trail_end_frm_hs_dat <= 1'b1;
       int_lp_tx_cntrl = 1'b1;
       lp_tx_cntrl = 1'b1;
       hs_tx_cntrl = 1'b0;
       lp_tx_dp = 1'b1;
       lp_tx_dn = 1'b1;
     end
  else
    begin
   if(master_pin)
            begin
           count_val = (4 * dln_cnt_hs_trail); //for getting ddr count
           tx_counter(count_val);

            end
          else
            begin
           count_val = (4 * dln_cnt_hs_trail); //for getting ddr count
           tx_counter(count_val);

            end
          count_en = 1'b0;
       @(posedge txbyteclkhs);
       @(posedge txbyteclkhs);
          trail_end_frm_hs_dat <= 1'b1;


    end
        
        end
      //REVERSE HIGH SPEED TRANSMISSION
      else if(!master_pin)
        begin
          //HIGH SPEED FORWARD SYNCHRONIZATION SEQUENCE TRANSMISSION
          if(txrequesths)
            begin
              @(posedge txbyteclkhs);
              hs_tx_dp <= HS_PATTERN[7];
              @(negedge txbyteclkhs);
              hs_tx_dp <= HS_PATTERN[6];
              @(posedge txbyteclkhs);
              hs_tx_dp <= HS_PATTERN[5];
              @(negedge txbyteclkhs);
              hs_tx_dp <= HS_PATTERN[4];
              @(posedge txbyteclkhs);
              hs_tx_dp <= HS_PATTERN[3];
              @(negedge txbyteclkhs);
              hs_tx_dp <= HS_PATTERN[2];
              @(posedge txbyteclkhs);
              txreadyhs <= 1'b1;
              hs_tx_dp <= HS_PATTERN[1];
              @(negedge txbyteclkhs);
              hs_tx_dp <= HS_PATTERN[0];
            end
          else
            hs_tx_dp <= 1'b0;
          //REVERSE HIGH SPEED DATA TRANSMISSION
          while(txrequesths)
            begin
              @(posedge txbyteclkhs);
              txreadyhs <= 1'b0;
              hs_tx_dp <= txdata_dddd[0];
              @(negedge txbyteclkhs);
              hs_tx_dp <= txdata_dddd[1];
              @(posedge txbyteclkhs);
              hs_tx_dp <= txdata_dddd[2];
              @(negedge txbyteclkhs);
              hs_tx_dp <= txdata_dddd[3];
              @(posedge txbyteclkhs);
              hs_tx_dp <= txdata_dddd[4];
              @(negedge txbyteclkhs);
              hs_tx_dp <= txdata_dddd[5];
              @(posedge txbyteclkhs);
              txreadyhs <= 1'b1;
              hs_tx_dp <= txdata_dddd[6];
              @(negedge txbyteclkhs);
              hs_tx_dp <= txdata_dddd[7];
            end
          //HIGH SPEED REVERSE TRAIL SEQUENCE TRANSMISSION
          @(posedge txbyteclkhs);
          txreadyhs <= 1'b0;
          if(txdata_ddddd[7])//TRAIL_0 TRANSMISSION
            hs_tx_dp <= 1'b0;
          else if(!txdata_ddddd[7])//TRAIL_1 TRANSMISSION
            hs_tx_dp <= 1'b1;
          if(master_pin)
            begin
           count_val = (4 * dln_cnt_hs_trail);//for getting ddr count
           tx_counter(count_val);

            end
          else
            begin
           count_val = (4 * dln_cnt_hs_trail);//for getting ddr count
           tx_counter(count_val);

            end
          count_en = 1'b0;
          trail_end_frm_hs_dat <= 1'b1;
        end
    end
  
  
  //***************************************************************************
  //PROCESS TO TRANSMITT DEFAULT VALUE IN HS_TX_DP LINE DURING STOPSTATE
  //***************************************************************************
  always @(posedge stopstate)
    begin:stopstate_loop
      hs_tx_dp = 1'b0;
    end
  
  //***************************************************************************
  //PROCESS TO GENERATE COUNT_EN SIGNAL
  //***************************************************************************
  always @(posedge hs_txn_st)
    begin:hs_txn_st_loop
      @(negedge txbyteclkhs);
      count_en = 1'b1;
    end
  
  //***************************************************************************
  //PROCESS TO GENERATE COUNT_EN_D SIGNAL
  //***************************************************************************
  always @(posedge count_en)
    begin:count_en_d_loop
      @(posedge txddrclkhs_i);
      count_en_d = 1'b1;
      @(negedge count_en);
      count_en_d = 1'b0;
    end
  
  //***************************************************************************
  //PROCESS FOR ASSIGNING ALL TXCLKESC OUTPUT SIGNALS
  //***************************************************************************
  always @(posedge txclkesc)
    begin:txclkesc_output_loop
      if(txescclk_rst_n)
        begin
          //HIGH SPEED DATA TRANSMITTER ENABLE SIGNAL
          hs_tx_cntrl <= int_sig_hs_tx_cntrl & !async_stop_chk;
          //LP DATA LINE OUTPUT
          lp_tx_dp <= sig_lp_tx_dp;
          //LP DATA LINE OUTPUT
          lp_tx_dn <= sig_lp_tx_dn;
          //STOP STATE SIGNAL OUTPUT
          stopstate <= sig_lp_tx_dp & sig_lp_tx_dn & (lp_mas_pstate == 3'b000) & (lp_mas_nstate == 3'b000);
          //ULTRA LOW POWER STATE ACTIVE NOT SIGNAL OUTPUT
          ulpsactivenot <= lp_esc_pstate != TX_ESC_ULP_DATA;
        end
    end





  
  //***************************************************************************
  //PROCESS FOR ASSIGNING ALL TXCLKESC CONTROL SIGNALS
  //***************************************************************************
  always @(posedge txclkesc)
    begin:txclkesc_cntrl_loop
      if(txescclk_rst_n)
        begin
          //LOW POWER DATA TRANSMITTER ENABLE SIGNAL
          if(forcerxmode)
            lp_tx_cntrl <= 1'b0;
          else if(forcetxstopmode | (dir_frm_rxr & txn_en_frm_rxr))
           begin
            lp_tx_cntrl <= 1'b1;
            hs_prepare_dis <= 1'b0;
           end
          else
            lp_tx_cntrl <= int_sig_lp_tx_cntrl;
          //OUTPUT ESCAPE MODE READY SIGNAL
          txreadyesc <= (lp_esc_pstate == TX_ESC_READY && txrequestesc && !(txvalidesc && txreadyesc));
        end
    end
  
  //***************************************************************************
  //PROCESS FOR SAMPLING THE INPUT TXDATAESC
  //***************************************************************************
  always @(posedge txclkesc)
    begin:esc_end_loop
      if(txescclk_rst_n)
        begin
          if(lp_mas_pstate == TX_STOP)
            esc_end <= 1'b0;
          else if((lp_esc_pstate == TX_ESC_READY && !txrequestesc)
            || (lp_esc_pstate == TX_ESC_ULP_DATA && !(txulpsesc & txrequestesc))
            || (lp_esc_pstate == TX_ESC_TRIGGER && !txrequestesc))
            esc_end <= 1'b1;
        end
    end
  
  always @(negedge txclkesc)
    begin:lpdt_buffer_loop
      if(txescclk_rst_n)
        begin
          //BUFFERING THE LOW POWER DATA
          if (txreadyesc && txvalidesc)//(lp_esc_pstate == TX_ESC_LPDT_DATA)// && txvalidesc )
            lpdt_buffer <=   {txdataesc[0],txdataesc[1],txdataesc[2],txdataesc[3],
            txdataesc[4],txdataesc[5],txdataesc[6],txdataesc[7]};
        end
    end
  //***************************************************************************
  //PROCESS FOR DEASSERTING THE ULTRA LOW POWER STATE INTERNAL SIGNAL
  //DURING FORCE STOP MODES
  //***************************************************************************
  always @ (posedge async_stop_chk)
    begin:ulps1_loop
      ulps = 1'b0;
    end
  
  //***************************************************************************
  //PROCESS FOR DEASSERTING THE ULTRA LOW POWER STATE INTERNAL SIGNAL
  //DURING TXREQUESTESC DEASSERTION
  //***************************************************************************
  always @ (negedge txrequestesc)
    begin:ulps_loop
      ulps = 1'b0;
    end
  
  //***************************************************************************
  //PROCESS FOR GENERATING THE INTERNAL SIGNAL FOR ULTRA LOW POWER STATE
  //***************************************************************************
  always @ (posedge txulpsesc)
    begin:ulps2_loop
      ulps = 1'b1;
    end
  
  //***************************************************************************
  //PROCESS FOR ASSERTING AND DEASSERTING THE INTERNAL TRIGGER VALUES
  //***************************************************************************
  always @ (posedge txclkesc)
    begin:enb_trgg_loop
      if(stopstate | async_stop_chk)
        enb_trgg = 4'h0;
      else if(|txtriggeresc)
        enb_trgg = txtriggeresc;
    end
  
  //***************************************************************************
  //PROCESS FOR ASSERTING AND DEASSERTING THE INTERNAL LPDT SIGNAL
  //***************************************************************************
  always @ (posedge txclkesc)
    begin:lpdt_loop
      if(stopstate | async_stop_chk)
        lpdt = 1'b0;
      else if(txlpdtesc)
        lpdt = 1'b1;
    end
  
  //***************************************************************************
  //PROCESS TO DELAY THE DATA DURING HIGH SPEED TRANSMISSION
  //***************************************************************************
  always @ (negedge txbyteclkhs)
    begin:txdata_flop_loop
      if(tx_byte_rst_n)
        begin
          txdata_d <= txdatahs;
          txdata_dd <= txdata_d;
          txdata_ddd <= txdata_dd;
          txdata_dddd <= txdata_ddd;
          txdata_ddddd <= txdata_dddd;
        end
    end
  //***************************************************************************
  //PROCESS TO DELAY THE DATA DURING HIGH SPEED TRANSMISSION
  //***************************************************************************
  always @ (negedge txddrclkhs_i)
    begin:txdata_flop_d_loop
      if(txddr_i_rst_n)
        begin
          txdata_dd_m <= txdata_d;
          txdata_ddd_m <= txdata_dd_m;
        end
    end
  
  //***************************************************************************
  //PROCESS FOR DEASSERTING INTERNAL SIGNAL USED FOR TURNAROUND OPERATION
  //***************************************************************************
  always @ (posedge int_en_fr_rxn_dis)
    begin:int_en_fr_rxn_loop
      int_en_fr_rxn = 1'b0;
    end
  
  //***************************************************************************
  //PROCESS FOR ASSIGNING INTERNAL SIGNAL USED FOR TURNAROUND OPERATION
  //***************************************************************************
  always @ (posedge ta_ex_state)
    begin:int_en_fr_rxn1_loop
      @ (posedge txclkesc);
      int_en_fr_rxn = 1'b1;
    end
  
  //***************************************************************************
  //PROCESS FOR GENERATING THE CONTINUOUS SIGNAL FOR TURNREQUEST
  //***************************************************************************
  always @(posedge turnrequest)
    begin:sig_turnrequest_loop
      if(!turndisable)
        sig_turnrequest = 1'b1;
    end
  
  //***************************************************************************
  //PROCESS FOR DEASSERTING THE CONTINUOUS SIGNAL USED FOR TURNREQUEST
  //***************************************************************************
  always @(posedge ta_ex_state)
    begin:sig_turnrequest1
      if(!dir_frm_rxr)
        sig_turnrequest = 1'b0;
    end
  
  always @(posedge async_stop_chk)
    begin:sig_turnrequest2
      sig_turnrequest = 1'b0;
    end
  
  //***************************************************************************
  //PROCESS FOR SENDING THE DATA LANE TO STOP STATE DURING ASYNCHRONOUS STOP
  //***************************************************************************
  always @(posedge txclkesc)
    begin:async_stop_chk_loop
      if(async_stop_chk)
        begin
          end_ta_sig          <= 1'b0                           ;
          ta_lp_tx_dp         <= 1'b1                           ;
          ta_lp_tx_dn         <= 1'b1                           ;
          end_hs_sig          <= 1'b0                           ;
          hs_lp_tx_dp         <= 1'b1                           ;
          hs_lp_tx_dn         <= 1'b1                           ;
          int_lp_tx_cntrl     <= 1'b1                           ;
          hs_tx_cntrl         <= 1'b0                           ;
          disable enable_hs_sig_loop	                        ;
          disable comb_block		                        ;
          disable comb_block1		                        ;
          disable lp_mas_pstate_loop	                        ;
          disable ta_get_cnt_bit_loop	                        ;
          disable ta_lp_tx_dp_loop	                        ;
          disable rxn_en_to_rxr_loop	                        ;
          disable eot_to_clk_loop	                        ;
          disable hs_prepare_en_loop	                        ;
          disable hs_prepare_dis_loop	                        ;
          disable fsm_esc_mode		                        ;
          disable for_loop_esc_lp	                        ;
          disable esc_counter		                        ;
          disable lp_esc_pstate_loop	                        ;
          disable lp_esc_pstate_loop1	                        ;
          disable count_en_d_loop	                        ;
          disable stopstate_loop	                        ;
          disable hs_txn_st_loop	                        ;
          disable hs_tx_dp_loop		                        ;
          disable txclkesc_output_loop	                        ;
          disable txclkesc_cntrl_loop	                        ;
          disable esc_end_loop		                        ;
          disable ulps1_loop		                        ;
          disable ulps2_loop		                        ;
          disable ulps_loop		                        ;
          disable enb_trgg_loop		                        ;
          disable lpdt_loop		                        ;
          disable txdata_flop_loop	                        ;
          disable txdata_flop_d_loop	                        ;
          disable int_en_fr_rxn_loop	                        ;
          disable int_en_fr_rxn1_loop	                        ;
          disable sig_turnrequest_loop	                        ;
          disable sig_turnrequest1	                        ;
          disable sig_turnrequest2	                        ;
          disable lpdt_buffer_loop	                        ;
          disable async_stop_chk_loop	                        ;
        end
    end
  
  always @(posedge txclkesc)
    begin:lp_esc_pstate_loop1
      if(txescclk_rst_n)
        begin
          if(async_stop_chk)
            begin
              lp_esc_pstate <= TX_ESC_STOP;
              lp_tx_dp <= 1'b1;
              lp_tx_dn <= 1'b1;
              stopstate <= 1'b1;
            end
          else
            lp_esc_pstate <= lp_esc_nstate;
        end
    end
  //***************************************************************************
  //PROCESS FOR STABILIZING THE SIGNALS DURING ASYNCHRONOUS RESET
  //***************************************************************************
  always @(negedge txescclk_rst_n)
    begin
      
      //HIGH SPEED SIGNALS IN TXBYTECLKHS AND TXDDRCLKHS_I
      txreadyhs        = 1'b0                     ;
      count_en         = 1'b0                     ;
      hs_txn_st        = 1'b0                     ;
      count_en_d       = 1'b0                     ;
      hs_tx_dp         = 1'b0                     ;
      
      //INTERNAL HIGH SPEED SIGNALS IN TXDDRCLKHS_I
      txdata_dd_m      = 8'b0                    ;
      txdata_ddd_m     = 8'b0                    ;
      
      //INTERNAL HIGH SPEED SIGNALS IN TXBYTECLKHS
      txdata_d         = 8'b0                    ;
      txdata_dd        = 8'b0                    ;
      txdata_ddd       = 8'b0                    ;
      txdata_dddd      = 8'b0                    ;
      txdata_ddddd     = 8'b0                    ;
      
      //INTERNAL LOW POWER SIGNALS IN TXCLKESC
      lpdt_buffer      = 8'h00                  ;
      esc_end          = 1'b0                   ;
      
      //LOW POWER STATE SIGNAL IN TXCLKESC
      lp_mas_pstate <= TX_STOP                  ;
      
      //LOW POWER ESCAPE MODE STATE VECTOR IN TXCLKESC
      lp_esc_pstate <= TX_ESC_STOP              ;
      
      //LOW POWER SIGNALS IN TXCLKESC
      lp_tx_cntrl 	= master_pin            ;
      hs_tx_cntrl 	= 1'b0                  ;
      lp_tx_dp 		= 1'b1                  ;
      lp_tx_dn          = 1'b1                  ;
      stopstate 	= 1'b1                  ;
      txreadyesc 	= 1'b0                  ;
      ulpsactivenot 	= 1'b1                  ;
      
    end
  
  //***************************************************************************
  //SIGNAL INITIALIZATION
  //***************************************************************************
  always @(negedge txescclk_rst_n)
    begin
      //SIGNALS FOR TURNAROUND PROCEDURE
      tx_esc_lpdt_dat_st 	= 1'b0                     ;
      ta_get_cnt_en 		= 1'b0                     ;
      ta_get_cnt_bit 		= 1'b0                     ;
      rxn_en_to_rxr 		= 1'b0                     ;
      end_ta_sig 		= 1'b0                     ;
      ta_lp_tx_dp 		= 1'b1                     ;
      ta_lp_tx_dn 		= 1'b1                     ;
      ta_ex_state 		= 1'b0                     ;
      to_assert_rxr_en 		= 1'b0                     ;
      sig_turnrequest 		= 1'b0                     ;
      int_en_fr_rxn 		= 1'b0                     ;
      disable enable_hs_sig_loop	                   ;
      disable comb_block		                   ;
      disable comb_block1		                   ;
      disable lp_mas_pstate_loop	                   ;
      disable ta_get_cnt_bit_loop	                   ;
      disable ta_lp_tx_dp_loop		                   ;
      disable rxn_en_to_rxr_loop	                   ;
      disable eot_to_clk_lp		                   ;
      disable eot_to_clk_lp1		                   ;
      disable eot_to_clk_loop		                   ;
      disable hs_prepare_en_loop	                   ;
      disable hs_prepare_dis_loop	                   ;
      disable fsm_esc_mode		                   ;
      disable for_loop_esc_lp		                   ;
      disable esc_counter		                   ;
      disable lp_esc_pstate_loop	                   ;
      disable lp_esc_pstate_loop1	                   ;
      disable count_en_d_loop		                   ;
      disable stopstate_loop		                   ;
      disable hs_txn_st_loop		                   ;
      disable hs_tx_dp_loop		                   ;
      disable txclkesc_output_loop	                   ;
      disable txclkesc_cntrl_loop	                   ;
      disable esc_end_loop		                   ;
      disable ulps1_loop		                   ;
      disable ulps2_loop		                   ;
      disable ulps_loop			                   ;
      disable enb_trgg_loop		                   ;
      disable lpdt_loop			                   ;
      disable txdata_flop_loop		                   ;
      disable txdata_flop_d_loop	                   ;
      disable int_en_fr_rxn_loop	                   ;
      disable int_en_fr_rxn1_loop	                   ;
      disable sig_turnrequest_loop	                   ;
      disable sig_turnrequest1		                   ;
      disable sig_turnrequest2		                   ;
      disable async_stop_chk_loop	                   ;
      disable lpdt_buffer_loop		                   ;
      //SIGNALS FOR HIGH SPEED TRANSMINSSION
      hs_txn_st 		= 1'b0                     ;
      count_en 			= 1'b0                     ;
      count_en_d 		= 1'b0                     ;
      hs_tx_dp 			= 1'b0                     ;
      trail_end_frm_hs_dat 	= 1'b0                     ;
      txreadyhs 		= 1'b0                     ;
      eot_to_clk 		= 1'b0                     ;
      hs_st_txn_st 		= 1'b0                     ;
      end_hs_sig 		= 1'b0                     ;
      hs_lp_tx_dp 		= 1'b1                     ;
      hs_lp_tx_dn 		= 1'b1                     ;
      hs_prepare_en 		= 1'b0                     ;
      hs_prepare_dis 		= 1'b0                     ;
      
      //SIGNAL FOR LOW POWER CONTROL MODE
      int_lp_tx_cntrl 		= 1'b1                     ;
      
      //SIGNALS FOR LOW POWER ESCAPE MODE
      enable_esc_cmd_cnt 	= 1'b0                     ;
      enable_esc 		= 1'b0                     ;
      tx_esc_cmd_task_st 	= 1'b0                     ;
      tx_esc_cmd_task_st_end 	= 1'b0                     ;
      enable_esc_cmd_cnt 	= 1'b0                     ;
      tx_esc_lpdt_dat_st 	= 1'b0                     ;
      ulps = 1'b0;
      wait(txescclk_rst_n)                                 ;
    end
  
   task tx_counter;
    input [7:0] count_val;
    begin
      int_counter = 8'b0;
      @(posedge txddrclkhs_i)
     while(int_counter<count_val)
      begin
       @(negedge txddrclkhs_i)
        int_counter = int_counter + 8'b1; 

      end
    end
  endtask

 

 
endmodule
