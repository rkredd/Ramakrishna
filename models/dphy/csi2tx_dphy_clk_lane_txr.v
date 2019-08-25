/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_clk_lane_txr.v
// Author      : R.Dinesh Kumar
// Version     : v1p2
// Abstract    : This module is used for the high speed clock transmission
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
`define psec *1000
`define nsec  *1
//************************************************
//TOP MODULE FOR MASTER CLOCK LANE TRANSMITTER
//************************************************
module csi2tx_dphy_clk_lane_txr_top(
  //INPUT SIGNALS
  input     wire        txclkesc            ,   // INPUT LOW POWER CLOCK SIGNAL FROM THE TRANSMITTER PPI
  input     wire        slave               ,   // INPUT SIGNAL WHICH DECIDES WHETHER MASTER OR SLAVE
  input     wire        txddrclkhs_q        ,   // INPUT HIGH SPEED QUADRATURE CLOCK SIGNAL FROM THE TRANSMITTER PPI
  input     wire        txddr_q_rst_n       ,   // INPUT RESET SIGNAL FOR QUADRATURE CLOCK DOMAIN
  input     wire        txescclk_rst_n      ,   // INPUT RESET SIGNAL FOR TXCLKESC(LOW POWER CLOCK) CLOCK DOMAIN
  input     wire        txrequesths_clk     ,   // INPUT HIGH SPEED CLOCK REQUEST SGNAL FROM THE TRANSMITTER PPI
  input     wire        txulpsclk           ,   // INPUT ULTRA LOW POWER STATE REQUEST SIGNAL FROM THE TRANSMITTER PPI
  input     wire        txulpsexit_clk      ,   // INPUT SIGNAL TO EXIT THE ULTRA LOW POWER MODE
  input     wire        eot                 ,   // INPUT FROM THE DATA LANE TRANSMITTER TO END THE HIGH SPEED CLOCK TRANSMISSION
  input     wire [7:0]  cln_cnt_hs_prep      ,   //INPUT HS PREPARE COUNT FOR CLOCK LANE
  input     wire [7:0]  cln_cnt_hs_zero      ,   //INPUT HS ZERO COUNT COUNT FOR CLOCK LANE
  input     wire [7:0]  cln_cnt_hs_trail     ,   //INPUT HS TRAIL COUNT FOR CLOCK LANE
  input     wire [7:0]  cln_cnt_hs_exit      ,   //INPUT HS EXIT COUNT FOR CLOCK LANE
  input     wire [7:0]  cln_cnt_lpx          ,   //INPUT LPX COUNT COUNT FOR CLOCK LANE
                                            
  //OUTPUT SIGNALS                          
  output    reg         lp_tx_cp_clk        ,   // OUTPUT LOW POWER TRANSMISION LINE P TO THE TRANSCEIVER
  output    reg         lp_tx_cn_clk        ,   // OUTPUT LOW POWER TRANSMISION LINE N TO THE TRANSCEIVER
  output    wire        hs_tx_cp_clk        ,   // OUTPUT HIGH SPEED TRANSMISION LINE TO THE TRANSCEIVER
  output    reg         lp_tx_cntrl_clk     ,   // OUTPUT LOW POWER ENABLE SIGNAL TO THE ANALOG TRANSCEIVER
  output    reg         hs_tx_cntrl_clk     ,   // OUTPUT HIGH SPEED ENABLE SIGNAL TO THE ANALOG TRANSCEIVER
  output    reg         ulpsactivenot_clk   ,   // OUTPUT TO INDICATE THE THAT THE LANE IS IN ULTRA LOW POWER STATE
  output    reg         stopstate_clk       ,   // OUTPUT TO INDICATE THAT THE LANE IS IN STOP STATE
  output    reg         sot                     // OUTPUT TO THE DATA LANE TRANSMITTER TO INDICATE THE START OF TRANSMISSION
  );
  
 
  //**********************************************************************
  //REGISTER AND NET DECLARATIONS
  //**********************************************************************
  //REGISTER DECLARATION
  
  reg [3:0]    lp_pstate                                                      ;
  reg [3:0]    lp_nstate                                                      ;
  reg          sig_lp_tx_cntrl_clk                                            ;
  reg          sig_lp_tx_cp_clk                                               ;
  reg          sig_lp_tx_cn_clk                                               ;
  reg [1:0]    hs_pstate                                                      ;
  reg [1:0]    hs_nstate                                                      ;
  reg          trail_st                                                       ;
  reg          start_hs_txn_st                                                ;
  reg          start_hs_txn_cnt                                               ;
  reg          end_of_dat_txn                                                 ;
  reg          trail_end                                                      ;
  reg          sot_st                                                         ;
  reg [7:0]    count_val                                                      ;
  reg [7:0]    int_counter                                                    ;

  //WIRE DECLARATION
  wire         txclk_precnt_t                                                 ;



  time         interval1                                                      ;
  time         interval2                                                      ;
  time         ui                                                             ;
  integer      tclk_post                                                      ;
  integer      tclk_pre                                                       ;
  integer      tclk_prepare                                                   ;


  initial
   begin
    ui         = 666                                                         ;
    interval1  = 0                                                           ;
    interval2  = 0                                                           ;
   end
  //PARAMETER FOR CLOCK LOW POWER TRANSMITTER STATE MACHINE
  parameter TX_STOP          = 4'b0000                                        ;
  parameter TX_HS_RQST       = 4'b0001                                        ;
  parameter TX_HS_PRPR       = 4'b0010                                        ;
  parameter TX_START_HS_TXN  = 4'b0011                                        ;
  parameter TX_ULPS_RQST     = 4'b0100                                        ;
  parameter TX_ULPS          = 4'b0101                                        ;
  parameter TX_ULPS_EXIT     = 4'b0110                                        ;
  parameter TX_HS_EXIT       = 4'b0111                                        ;
  parameter TX_HS_EXIT_DLY   = 4'b1000                                        ;
  
  
  //PARAMETER FOR CLOCK HIGH SPEED TRANSMITTER STATE MACHINE
  parameter TX_HS_GO         = 2'b00                                          ;
  parameter TX_HS_0          = 2'b01                                          ;
  parameter TX_HS_1          = 2'b10                                          ;
  parameter TRAIL_HS_0       = 2'b11                                          ;
  
  //PARAMETER FOR TIMING CHECK
  parameter TLPX             = 50 `psec;// min = 60ns;    typ = nil; max = nil;
  parameter TCLK_PREPARE     = 38 `psec;// min = 60ns;    typ = nil; max = nil;
  parameter TCLK_TRAIL       = 60 `psec;// min = 60ns;    typ = nil; max = nil;
  parameter TCLK_ZERO        = 350 `psec;//min = 300ns;    typ = nil; max = nil;
 


 always@(*)
  begin
   wait(txddr_q_rst_n == 1);
   @(posedge txddrclkhs_q);
   @(posedge txddrclkhs_q);
   @(posedge txddrclkhs_q);
   @(posedge txddrclkhs_q);
   interval1 = $time;
   @(negedge txddrclkhs_q);
   interval2 = $time;
   ui = interval2 - interval1;
  end

always@(ui)
 begin
   tclk_post  = 60 `psec + 52*ui;
   tclk_pre  =  8*ui;
   `ifdef max tclk_prepare =  95 `nsec;
   `elsif min tclk_prepare =  38 `nsec;
   `else  tclk_prepare     =  38 `nsec;
   `endif

 end

 
 
  // PROCESS TO INITIALISE ALL THE SIGNALS
  initial
    begin
      start_hs_txn_cnt   = 1'b0                                               ;
      trail_end          = 1'b0                                               ;
      end_of_dat_txn     = 1'b0                                               ;
      start_hs_txn_st    = 1'b0                                               ;
    end


  //CONTINIOUS ASSIGN STATEMENTS
  //HIGH SPEED CLOCK FOR CLOCK LANE
  assign hs_tx_cp_clk = (hs_pstate == TX_HS_0 || hs_pstate == TX_HS_1)? txddrclkhs_q :  1'b0;
  //INTERNAL TCLK_PRE UNIT INTERVALS
  assign txclk_precnt_t = hs_pstate == TX_HS_1 || hs_pstate == TX_HS_0;
  
  //FOR CLK LANE LOW POWER TRANSMITTER
  //***************************************************************************
  // CLOCK LANE LOW POWER TRANSMITTER FSM
  //***************************************************************************
  always @(lp_pstate or txrequesths_clk or txulpsclk or txulpsexit_clk
    or trail_end)
    begin: LP_ST_FSM
      lp_nstate = TX_STOP;
      sig_lp_tx_cntrl_clk = 1'b1;
      sig_lp_tx_cp_clk = 1'b1;
      sig_lp_tx_cn_clk = 1'b1;
      case(lp_pstate)
        TX_STOP :
          tx_stop;
        TX_ULPS_RQST :
          tx_ulps_rqst;
        TX_ULPS :
          tx_ulps;
        TX_ULPS_EXIT :
          tx_ulps_exit;
        TX_HS_RQST :
          tx_hs_rqst;
        TX_HS_PRPR :
          tx_hs_prpr;
        TX_START_HS_TXN :
          tx_start_hs_txn;
        TX_HS_EXIT :
          tx_hs_exit;
        TX_HS_EXIT_DLY :
          tx_hs_exit_dly;
        default: //DEFAULT STATE
          begin
            sig_lp_tx_cntrl_clk = 1'b1;
            sig_lp_tx_cp_clk = 1'b1;
            sig_lp_tx_cn_clk = 1'b1;
            lp_nstate = TX_STOP;
          end
      endcase
    end
  
  //************TASK START*************************
  
  //*****************************************************
  // INITIAL_STOP_STATE
  //*****************************************************
  task tx_stop;
    begin
      trail_end = 1'b0;
      sig_lp_tx_cntrl_clk = 1'b1;
      sig_lp_tx_cp_clk = 1'b1;
      sig_lp_tx_cn_clk = 1'b1;
      if(txrequesths_clk)
        lp_nstate = TX_HS_RQST;
      else if(txulpsclk)
        lp_nstate = TX_ULPS_RQST;
      else
        lp_nstate = TX_STOP;
    end
  endtask
  
  //*****************************************************
  // ULPS_REQUEST_STATE
  //*****************************************************
  task tx_ulps_rqst;
    begin
      sig_lp_tx_cntrl_clk = 1'b1;
      sig_lp_tx_cp_clk = 1'b1;
      sig_lp_tx_cn_clk = 1'b0;
      lp_nstate = TX_ULPS;
    end
  endtask
  
  //*****************************************************
  //ULPS_TXN_STATE
  //*****************************************************
  task tx_ulps;
    begin
      sig_lp_tx_cntrl_clk = 1'b1;
      sig_lp_tx_cp_clk = 1'b0;
      sig_lp_tx_cn_clk = 1'b0;
      if(txulpsclk & !txulpsexit_clk)
        lp_nstate = TX_ULPS;
      else if(txulpsclk & txulpsexit_clk)
        lp_nstate = TX_ULPS_EXIT;
      else
        lp_nstate = TX_STOP;
    end
  endtask
  
  //*****************************************************
  // ULPS_EXIT_STATE
  //*****************************************************
  task tx_ulps_exit;
    begin
      sig_lp_tx_cntrl_clk = 1'b1;
      sig_lp_tx_cp_clk = 1'b1;
      sig_lp_tx_cn_clk = 1'b0;
      if(txulpsclk)
        lp_nstate = TX_ULPS_EXIT;
      else
        lp_nstate = TX_STOP;
    end
  endtask
  
  //*****************************************************
  //HIGH_SPEED_REQUEST_STATE
  //*****************************************************
  task tx_hs_rqst;
    begin
      sig_lp_tx_cntrl_clk = 1'b1;
      sig_lp_tx_cp_clk = 1'b0;
      sig_lp_tx_cn_clk = 1'b1;
      count_val = (4 * cln_cnt_lpx);//for getting ddr count
      tx_counter(count_val);
      if(txrequesths_clk)
        lp_nstate = TX_HS_PRPR;
      else
        lp_nstate = TX_STOP;
    end
  endtask
  
  //*****************************************************
  // HIGH_SPEED_PREPARE_STATE
  //*****************************************************
  task tx_hs_prpr;
    begin
      sig_lp_tx_cntrl_clk = 1'b1;
      sig_lp_tx_cp_clk = 1'b0;
      sig_lp_tx_cn_clk = 1'b0;
      count_val = (4 * cln_cnt_hs_prep);//for getting ddr count
      tx_counter(count_val);
      if(txrequesths_clk)
        lp_nstate = TX_START_HS_TXN;
      else
        lp_nstate = TX_STOP;
    end
  endtask
  
  //*****************************************************
  //HIGH_SPEED_TRANSMISSION_STATE
  //*****************************************************
  task tx_start_hs_txn;
    begin
      if(txrequesths_clk == 1'b0) 
       begin
        lp_nstate = TX_STOP;
        start_hs_txn_st = 1'b0;
        hs_pstate = TX_HS_GO;
        hs_nstate = TX_HS_GO;
       end
      else if(trail_end)
        begin
          sig_lp_tx_cp_clk = 1'b1;
          sig_lp_tx_cn_clk = 1'b1;
          sig_lp_tx_cntrl_clk = 1'b1;
          lp_nstate = TX_HS_EXIT;
          start_hs_txn_st = 1'b0;
        end
      else
        begin
          start_hs_txn_st = 1'b1;
          sig_lp_tx_cp_clk = 1'b0;
          sig_lp_tx_cn_clk = 1'b0;
          sig_lp_tx_cntrl_clk = 1'b0;
          lp_nstate = TX_START_HS_TXN;
        end
    end
  endtask
  
  //*****************************************************
  //STOP STATE TO BE RETAINED AFTER THE HS TRAIL STATE
  //*****************************************************
  task tx_hs_exit;
    begin
      sig_lp_tx_cntrl_clk = 1'b1;
      sig_lp_tx_cp_clk = 1'b1;
      sig_lp_tx_cn_clk = 1'b1;
      lp_nstate = TX_HS_EXIT_DLY;
    end
  endtask
  
  //***************************************************
  //EXTENTION OF THE HS EXIT STATE
  //***************************************************
  task tx_hs_exit_dly;
    begin
      sig_lp_tx_cntrl_clk = 1'b1;
      sig_lp_tx_cp_clk = 1'b1;
      sig_lp_tx_cn_clk = 1'b1;
      lp_nstate = TX_STOP;
    end
  endtask
  
  //************TASK END*********************************
  
  //***************************************************
  //SIGNAL ASSIGNMENT DURING RESET
  //***************************************************
  always @(negedge txescclk_rst_n)
    begin
      hs_tx_cntrl_clk = 1'b0;
      lp_tx_cntrl_clk = !slave;
      lp_tx_cp_clk = 1'b1;
      lp_tx_cn_clk = 1'b1;
      stopstate_clk = 1'b1;
      ulpsactivenot_clk = 1'b1;
      lp_pstate = TX_STOP;
      disable LP_ST_FSM;
      disable output_cntrl_sig;
      disable HS_CLK_FSM;
      disable end_of_dat_txn_loop1;
      disable trail_end_loop;
      disable start_hs_txn_cnt_loop;
      disable start_hs_txn_cnt1_loop;
      disable end_of_dat_txn_loop;
      disable sot_st_loop;
      disable sot_loop;
    end
  
  //***************************************************
  //OUTPUT SIGNALS ASSIGNMENT
  //***************************************************
  always @(posedge txclkesc)
    begin:output_cntrl_sig
      if(txescclk_rst_n)
        begin
          hs_tx_cntrl_clk <=!sig_lp_tx_cntrl_clk & (!slave);
          lp_tx_cntrl_clk <=sig_lp_tx_cntrl_clk & (!slave);
          lp_tx_cp_clk <= sig_lp_tx_cp_clk;
          lp_tx_cn_clk <= sig_lp_tx_cn_clk;
          stopstate_clk <= sig_lp_tx_cp_clk & sig_lp_tx_cn_clk;
          ulpsactivenot_clk <= lp_pstate != TX_ULPS;
          lp_pstate <= lp_nstate;//INTERNAL STATE MACHINE SIGNAL
        end
    end
  
  //***************************************************
  //FOR CLK LANE HIGH SPEED TRANSMITTER
  //***************************************************
  
  //************************************************
  //CLOCK LANE HIGH SPEED CLOCK TRANSMITTER FSM
  //************************************************
  always @(hs_pstate or start_hs_txn_cnt or txrequesths_clk or end_of_dat_txn or trail_end
    or start_hs_txn_st)
    begin: HS_CLK_FSM
      hs_nstate = TX_HS_GO;
      trail_st = 1'b0;
      
      case(hs_pstate)
        TX_HS_GO :
          tx_hs_go;
        TX_HS_0 :
          tx_hs_0;
        TX_HS_1 :
          tx_hs_1;
        TRAIL_HS_0 :
          trail_hs_0;
        default :
          hs_nstate = TX_HS_GO;
      endcase
    end
  
  //************TASK START*************************
  reg temp_stop;
  initial
    begin
      temp_stop = 1'b0;
    end
  //************************************************
  //INITIAL_HS0_ST
  //************************************************
  task tx_hs_go;
    begin
      if(start_hs_txn_st & txrequesths_clk & start_hs_txn_cnt)
        hs_nstate = TX_HS_1;
      else if(start_hs_txn_st && !txrequesths_clk)
        begin
          temp_stop = 1'b1;
          hs_nstate = TX_HS_GO;
        end
      else
        hs_nstate = TX_HS_GO;
    end
  endtask
  
  //************************************************
  //TRANSMIT_HS_CLOCK_STATE
  //************************************************
  task tx_hs_0;
    begin
      if((end_of_dat_txn & !txrequesths_clk))
        hs_nstate = TRAIL_HS_0;
      else
        hs_nstate = TX_HS_1;
    end
  endtask
  
  //************************************************
  // TRANSMIT_HS_CLOCK_STATE
  //************************************************
  task tx_hs_1;
    begin
      if((end_of_dat_txn & !txrequesths_clk))
        hs_nstate = TRAIL_HS_0;
      else
        hs_nstate = TX_HS_0;
    end
  endtask
  
  //************************************************
  //TRAIL_HS0_STATE
  //************************************************
  task trail_hs_0;
    begin
      trail_st = 1'b1;
      sot_st = 1'b0;
      if(trail_end)
        hs_nstate = TX_HS_GO;
      else
        hs_nstate = TRAIL_HS_0;
    end
  endtask
  
  //************************************************
  //DISABLE THE END OF DATA TRANSMISSION SIGNAL
  //************************************************
  always @(negedge eot)
    begin:end_of_dat_txn_loop1
      end_of_dat_txn = 1'b0;
    end
  
  //***********TASK END***************************************************
  
  //************************************************
  //PROCESS COUNTING THE TCLK_TRAIL INTERVALS
  //************************************************
  always @(posedge trail_st)
    begin:trail_end_loop
      count_val = (4 * cln_cnt_hs_trail);//for getting ddr count
      tx_counter(count_val);
      trail_end = 1'b1;
    end
  
  //************************************************
  //PROCESS FOR COUNTING THE TCLK_ZERO INTERVALS
  //************************************************
  always @(posedge start_hs_txn_st)
    begin:start_hs_txn_cnt_loop
      count_val = (4 * cln_cnt_hs_zero);//for getting ddr count
      tx_counter(count_val);
      start_hs_txn_cnt = 1'b1;
    end
  
  //************************************************
  //PROCESS FOR COUNTING THE TCLK_ZERO INTERVALS
  //************************************************
  always @(negedge start_hs_txn_st)
    begin:start_hs_txn_cnt1_loop
      @ (posedge txddrclkhs_q);
      start_hs_txn_cnt = 1'b0;
    end
  
  //****************************************************************************
  //PROCESS COUNTING THE TCLK_POST VALUE
  //****************************************************************************
  always @(posedge eot)
    begin:end_of_dat_txn_loop
      #(tclk_post `nsec);
      end_of_dat_txn = 1'b1;
    end
  
  always@(posedge temp_stop)
    begin
      trail_end = 1'b1;
      temp_stop = 1'b0;
    end
  //************************************************
  //PROCESS COUNTING THE TCLK_PRE UNIT INTERVALS
  //************************************************
  always @(posedge txclk_precnt_t)
    begin:sot_st_loop
      #(tclk_pre `nsec);
      sot_st = 1'b1;
    end
  
  //************************************************
  //PROCESS FOR DISABLING SOT
  //************************************************
  always @(negedge txddr_q_rst_n)
    begin:hs_pstate_loop
      hs_pstate = TX_HS_GO;
      sot = 1'b0;
      sot_st = 1'b0;
      start_hs_txn_cnt = 1'b0;
      start_hs_txn_st = 1'b0;
      end_of_dat_txn = 1'b0;
    end
  
  //************************************************
  //ASSIGNING SOT SIGNAL
  //************************************************
  always @(posedge txddrclkhs_q)
    begin:sot_loop
      if(txddr_q_rst_n)
        hs_pstate <= hs_nstate;
      if(hs_pstate == TRAIL_HS_0)
        sot <= 1'b0;
      else if(sot_st)
        sot <= 1'b1;
    end
  //************************************************
  //PROCESS FOR THE COUNTER
  //************************************************

   task tx_counter;
    input [7:0] count_val;
    begin
      int_counter = 8'b0;
      @(posedge txddrclkhs_q)
     while(int_counter<count_val)
      begin
       @(negedge txddrclkhs_q)
        int_counter = int_counter + 8'b1; 

      end
    end
  endtask
  
endmodule
