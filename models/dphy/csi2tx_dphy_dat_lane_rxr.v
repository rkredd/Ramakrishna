/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_dat_lane_rxr.v
// Author      : B. Shenbgaramesh
// Version     : v1p2
// Abstract    : This module is used for the data lane reception in the DPHY
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
//module for data lane receiver top layer
module csi2tx_dphy_dat_lane_rxr_top(
  //INPUTS
  //  FROM CLOCK LANE TRANSCEIVER
  input     wire        rxddrclkhs           ,   // INPUT HIGH SPEED DDR CLOCK
  //INPUT FROM PPI
  input     wire        txclkesc             ,   //INPUT LOW POWER CLOCK SIGNAL USED FOR LOW POWER STATE TRANSITION
  input     wire        slave                ,   //INPUT MASTER/SLAVE SELECT SIGNAL
  input     wire        txescclk_rst_n       ,   //INPUT GATED RESET SIGNAL FOR TXCLKESC(LOW POWER CLOCK) CLOCK DOMAIN
  input     wire        rxescclk_rst_n       ,   //INPUT GATED RESET SIGNAL FOR RXCLKESC(EX-OR CLOCK) CLOCK DOMAIN
  input     wire        rxddr_rst_n          ,   //INPUT GATED RESET SIGNAL FOR QUADRATURE CLOCK DOMAIN
  input     wire        rx_byte_rst_n        ,   //INPUT GATED RESET SIGNAL FOR RXBYTECLKHS(GENERATED FROM HS_RX_CLK) CLOCK DOMAIN
  input     wire        turndisable          ,   //INPUT TURNAROUND DISABLE signal to prevent change of direction(ie Tx -> Rx or Rx -> Tx)
  input     wire        forcerxmode          ,   //INPUT FORCE RECEIVER MODE SIGNAL FROM THE PPI
  input     wire        forcetxstopmode      ,   //INPUT SIGNAL TO FORCE THE TRANSMITTER TO STOP MODE FROM THE PPI
         
  //INPUT FROM DATA LANE TRANSCEIVER
  input     wire        lp_rx_dp             ,   //INPUT LOW POWER DIFFERENTIAL Dp LINE FROM THE TRANSCEIVER - FOR DATA LANE
  input     wire        lp_rx_dn             ,   //INPUT LOW POWER DIFFERENTIAL Dn LINE FROM THE TRANCEIVER - FOR DATA LANE
  input     wire        hs_rx                ,   //INPUT HIGH SPEED Dp LINE FROM THE TRANCEIVER - FOR DATA LANE

  //INPUT FROM TRANSMITTER
  input     wire        enable_rxn           ,   //INPUT INTERNAL SIGNAL FROM TRANSMITTER TO CHANGE DIRECTION
  input     wire        rxbyteclkhs          ,   //INPUT BYTE CLOCK GENERATED FROM DDR(HS_RX_CLK) CLOCK
  input     wire        rxclkesc             ,   //INPUT ESCAPE MODE EX-OR CLOCK GENERATED FROM LOW POWER DP AND DN LINES,
 input     wire         eot_handle_proc       ,   //INPUT EOT PROCESS HANDLING 0-EXTERNAL ,1 -INTERNAL 
 
  //TO PPI (HS)
  output    reg         rxactivehs           ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DPHY IS RECEIVING HIGH SPEED DATA
  output    reg [7:0]   rxdatahs             ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES
  output    reg         rxvalidhs            ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE HIGH SPEED DATA IS VALID ON RXDATAHS LINES
  output    reg         rxsynchs             ,   //OUTPUT PULSE TO INDICATE THE RECEIVER PPI START AND END OF HIGH SPEED DATA RECEPTION
  output    reg         rxskewcallhs         ,   //OUTPUR PULSE TO INDICATE THE RECEIVER PPI DESKEW CALIBRATIION
        
  //TO DPHY TX( OF SAME DEVICE)
  output    reg         chg_dir_pulse        ,   //OUTPUT PULSE TO INDICATE CHANGE OF DIRECTION(IE RX -> TX)
  output    reg         direction            ,   //OUTPUT SIGNAL TO INDICATE THE DIRECTION(1 -RX ,0 - TX)
          
  //TO PPI (ESC)
  output    wire [7:0]  rxdataesc            ,   //OUTPUT ESCAPE MODE 8-BIT DATA TO THE RECEIVER PPI
  output    wire        rxvalidesc           ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE ESCAPE MODE DATA IS VALID ON RXDATAESC LINES
  output    wire [3:0]  rxtriggeresc         ,   //OUTPUT ESCAPE MODE RECEIVED TRIGGER TO THE RECEIVER PPI
  output    reg         rxulpsesc            ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI THAT THE DATALANE IS IN ULPS
  output    wire        rxlpdtesc            ,   //OUTPUT SIGNAL TO INDICATE THE RECEIVER PPI DATALANE IS IN LOW POWER DATA RECEIVE MODE
  output    reg         ulpsactivenot        ,   //OUTPUT SIGNAL TO INTIMATE THE PPI THAT THE LANE MODULE IS NOT IN ULTRA LOW POWER STATE
        
  //TO PPI (ERROR)
  output    reg         errsoths             ,   //OUTPUT PULSE TO INDICATE THE START OF TRANSMISSION ERROR(SOFT ERROR) TO THE RECEIVER PPI
  output    reg         errsotsynchs         ,   //OUTPUT PULSE TO INDICATE START OF TRANSMISSION SYNCHRONIZATION ERROR TO THE RECEIVER PPI
  output    reg         erresc               ,   //OUTPUT TO INDICATE THE ESCAPE MODE ENTRY ERROR TO THE RECEIVER PPI
  output    reg         errsyncesc           ,   //OUTPUT TO INDICATE THE LOW POWER DATA TRANSMISSION SYNCHRONIZATION ERRO TO THE RECEIVER PPI
  output    reg         errcontrol           ,   //OUTPUT SIGNAL TO INDICATE THE LOW POWER STATE ERROR TO THE RECEIVER PPI
                                             
  //TO PPI (CONTROL)                         
  output    wire        stopstate_out        ,   //OUTPUT SIGNAL TO INDICATE THAT THE DATA LANE MODULE IS IN STOPSTATE
  output    wire        lp_rx_en             ,   //OUTPUT ENABLE SIGNAL FOR LOW POWER DATA LINES
  output    reg         hs_rx_en                 //OUTPUT ENABLE SIGNAL FOR HIGH SPEED DATA LINES
  );
  
  

  
  //PARAMETER DECLARATION
  parameter STOP_STATE      = 4'h0                                             ;
  parameter HS_RCV          = 4'h1                                             ;
  parameter TURN_REQ_STATE  = 4'h2                                             ;
  parameter TURN_STATE      = 4'h3                                             ;
  parameter LOW_POW         = 4'h4                                             ;
  parameter EXIT_ESCAPE     = 4'h5                                             ;
  parameter CHG_DIR         = 4'h6                                             ;
  parameter WAIT_STOP       = 4'h7                                             ;
  parameter BRIDGE_ESCAPE   = 4'h8                                             ;
  
  //**********************************************************************
  //REGISTER AND NET DECLARATIONS
  //**********************************************************************
  
  //INTERNAL REGISTER DECLARATION
      reg [7:0]        shift_reg_esc                                          ;
      reg [2:0]        bit_count                                              ;
      reg [7:0]        esc_cmd_reg                                            ;
      reg              esc_cmd_over                                           ;
      reg [3:0]        state                                                  ;
      reg [3:0]        nxt_state                                              ;
      reg              turn_req                                               ;
      reg              turn_req_s                                             ;
      reg              start_esc_rx_s                                         ;
      reg              err_control_s                                          ;
      reg              high_speed_req                                         ;
      reg              stopstate                                              ;
      reg              hs_req_f                                               ;
      reg              hs_enb_req_s                                           ;
      reg [3:0]        stop_cnt                                               ;
      reg              esc_req_s                                              ;
      reg              err_ctrl_cleard_s                                      ;
      reg              enable_high_speed_fwd                                  ;
      reg              err_ctrl_cleard_f                                      ;
      reg              low_pow_req_s                                          ;
      reg              low_pow_req                                            ;
      reg              ulps_en                                                ;
      reg [1:0]        dlpln_d                                                ;
      reg              hs_rx_en_s                                             ;
      reg              hs_rx_en_t                                             ;
      reg [2:0]        esc_cmd_en_cnt                                         ;
      reg [2:0]        bit_cnt                                                ;
      reg              data_neg                                               ;
      reg              err_sot_sync_hs_int_hs                                 ;
      reg [7:0]       sync_reg                                                ;
      reg [15:0]       sync_reg_cali                                           ;
      reg [3:0]        counter_hs                                             ;
      reg              enable_high_speed_rev                                  ;
      reg              sync_detected_hs                                       ;
      reg              sync_detected_d                                        ;
      reg              disable_state_d                                        ;
      reg [7:0]        rxdatahs_int_hs                                        ;
      reg              hs_rx_p                                                ;
      reg [7:0]        shift_reg_hs                                           ;
      reg              data_pos                                               ;
      reg [2:0]        sync_bit_counter                                       ;
      reg [2:0]        sync_bit_counter1                                       ;
      reg [2:0]        reverse_clk_count                                      ;
      reg              start_sync_count                                       ;
      reg              byte_over_t                                            ;
      reg              hs_rx_n_neg                                            ;
      reg              rxsynchs_s                                             ;
      reg              lckd_frst_clk                                          ;
      reg              lckd_sec_clk                                           ;
      reg              enable_lpdt_rcv                                        ;
      reg              sync_detected_l                                        ;
      reg              sync_detected_s                                        ;
      reg              sync_detected_cal                                      ;
      reg              disable_ext                                            ;
      reg              err_sot_hs_int_hs                                      ;
      reg              lp_rx_en_s                                             ;
      reg              revert_diretction                                      ;
      reg              skew_detect                                            ;
      reg              rxbyteclkhs_1                                          ; 
      reg              byte_clk_gen                                           ;                                                                       
      reg              rxactivehs_1                                           ;                                                                       
      reg              rxvalidhs_1                                            ;                                                                       
      reg              rxsynchs_1                                             ;                                                                       
      reg [7:0]        rxdatahs_1                                             ;
      reg 	       rxactivehs_skew                                        ;
      reg              rxskewcallhs_1                                         ;

  //INTERNAL WIRE DECLARATION                                                 
      wire            esc_cmd_reg_en                                          ;                                         
      wire [7:0]      rx_data_esc_s                                           ;                                          
      wire [3:0]      rxtrigger_esc_s                                         ;                                        
      wire [3:0]      rxtrigger_esc_s1                                        ;                                       
      wire            rxlpdt_esc_s                                            ;                                           
      wire            byte_over_hs                                            ;                                           
      wire            lock_sync_detection                                     ;                                    
      wire [1:0]      dlpln                                                   ;                                                  
      wire            ignore_sync_err_hs                                      ;                                     
      wire            ignore_sotsync_err                                      ;                                     
      wire            byte_over                                               ;                                              
      wire            rxtriggeresc_sig                                        ;                                       
      wire            temp_comp                                               ;                                              

 
  //########################
  // SIGNALS INITIALISATION
  //########################
  
  initial
    begin
      sync_detected_s           = 1'b0                                        ;
      sync_detected_cal         = 1'b0                                        ;
      shift_reg_esc             = 8'h00                                       ;
      sync_reg                  = 8'h00                                       ;
      sync_reg_cali             = 16'h00                                      ;
      revert_diretction         = 1'b0                                        ;
      err_sot_sync_hs_int_hs    = 1'b0                                        ;
      errsyncesc                = 1'b0                                        ;
      esc_cmd_reg               = 8'h00                                       ;
      lckd_frst_clk             = 1'b0                                        ;
      lckd_sec_clk              = 1'b0                                        ;
      enable_high_speed_rev     = 1'b0                                        ;
      enable_high_speed_fwd     = 1'b0                                        ;
      errcontrol                = 1'b0                                        ;
      shift_reg_hs              = 8'h0                                        ;
      rxsynchs_s                = 1'b0                                        ;
      rxactivehs                = 1'b0                                        ;
      rxactivehs_1              = 1'b0                                        ;
      rxvalidhs_1               = 1'b0                                        ;
      rxsynchs_1                = 1'b0                                        ;
      disable_ext               = 1'b0                                        ;
      rxvalidhs                 = 1'b0                                        ;
      ulps_en                   = 1'b0                                        ;
      rxsynchs                  = 1'b0                                        ;
      rxdatahs                  = 8'h00                                       ;
      rxdatahs_1                = 8'h00                                       ;
      errsotsynchs              = 1'b0                                        ;
      errsoths                  = 1'b0                                        ;
      enable_lpdt_rcv           = 1'b0                                        ;
      sync_bit_counter          = 3'h0                                        ;
      sync_bit_counter1         = 3'h0                                        ;
      erresc                    = 1'b0                                        ;
      bit_count                 = 3'h0                                        ;
      esc_cmd_over              = 1'b0                                        ;
      esc_cmd_en_cnt            = 3'h0                                        ;
      bit_cnt                   = 3'h0                                        ;
      data_pos                  = 1'b0                                        ;
      direction                 = 1'b0                                        ;
      rxbyteclkhs_1             = 1'b0                                        ;
      byte_clk_gen              = 1'b0                                        ;
      skew_detect               = 0                                           ;
      rxactivehs_skew           = 1'b0                                        ;
      rxskewcallhs              = 1'b0                                        ;
      rxskewcallhs_1            = 1'b0                                        ;
    end


 always@(negedge rx_byte_rst_n)
   begin
     disable phase_match;
     byte_clk_gen  = 0;
     rxbyteclkhs_1 = 0; 
   end

  
  always@(posedge hs_rx or negedge stopstate)
   begin
    if(hs_rx)
     byte_clk_gen = 1'b1;
    else if(!stopstate)
     begin
     byte_clk_gen = 1'b0;
     end
    end

  always@(negedge byte_clk_gen)
    begin
     @(posedge rxbyteclkhs_1);
     @(posedge rxbyteclkhs_1);
     disable phase_match;
     rxbyteclkhs_1 =1'b0;
    end
//phase matching byteclk
  always@(posedge byte_clk_gen)
    begin:phase_match
    while(1)
     begin
      @(negedge rxddrclkhs);
      rxbyteclkhs_1 <= 1'b1;
      @(posedge rxddrclkhs);
      @(negedge rxddrclkhs);
      @(posedge rxddrclkhs);
      @(negedge rxddrclkhs);
      rxbyteclkhs_1 <= 1'b0;
      @(posedge rxddrclkhs);
      @(negedge rxddrclkhs);
      @(posedge rxddrclkhs);
      end
    end
  
 always@(stopstate)
  begin
   if(stopstate)
    disable fwd_rec_loop;
  end
  //####################################
  // LP RECEIVER PART ASSIGN STATEMENTS
  //####################################
  assign dlpln ={lp_rx_dp,lp_rx_dn};
  
  assign lp_rx_en = lp_rx_en_s;
  
  
  //#####################################
  // ESCAPE RECIVER ASSIGN STATEMENTS
  //#####################################
  
  assign esc_cmd_reg_en=(start_esc_rx_s &&  esc_cmd_en_cnt == 3'b111)? 1'b1 : 1'b0;
  
  assign byte_over = (rxlpdt_esc_s && bit_cnt == 3'b111)?1'b1 : 1'b0;
  
  assign rx_data_esc_s ={shift_reg_esc[0],shift_reg_esc[1],shift_reg_esc[2],shift_reg_esc[3],
    shift_reg_esc[4],shift_reg_esc[5],shift_reg_esc[6],shift_reg_esc[7]};
  
  assign rxlpdt_esc_s = (esc_cmd_reg == 8'b11100001) && start_esc_rx_s && !(lp_rx_dp & lp_rx_dn)? 1'b1:1'b0;
  
  assign rxlpdtesc = rxlpdt_esc_s;
  
  assign rxvalidesc =byte_over;
  
  assign rxtrigger_esc_s =!(rxlpdtesc || dlpln==2'b11 || rxulpsesc) ?  (shift_reg_esc == 8'b01100010)? 4'h1 :(shift_reg_esc == 8'b01011101)? 4'h2 :
    (shift_reg_esc == 8'b00100001)? 4'h4 :(shift_reg_esc == 8'b10100000)? 4'h8:4'h0 : 4'h0;
  
  assign  rxdataesc = rx_data_esc_s;
  
  assign rxtrigger_esc_s1 = (esc_cmd_reg == 8'b01100010)? 4'h1 : (esc_cmd_reg == 8'b01011101)? 4'h2 :
    (esc_cmd_reg == 8'b00100001)? 4'h4 : (esc_cmd_reg == 8'b10100000)? 4'h8:4'h0;
  
  assign rxtriggeresc = !(rxlpdtesc || dlpln==2'b11 || rxulpsesc) ? (|rxtrigger_esc_s1) ? rxtrigger_esc_s1 :(|rxtrigger_esc_s )?rxtrigger_esc_s:  4'h0 : 4'h0;
  
  assign  stopstate_out = (stopstate==1'b1 && dlpln ==2'b11) ? 1'b1: 1'b0;
  
  assign rxtriggeresc_sig = |rxtriggeresc;
  
  //##############################################
  // HS RECEIVER ASSIGN STATEMENTS
  //##############################################
  
  assign ignore_sync_err_hs =(ignore_sotsync_err ==1'b1)? (lock_sync_detection && !sync_detected_hs):1'b0;
  
  assign byte_over_hs =(slave && counter_hs ==4'b0011) ? 1'b1 :(!slave && counter_hs ==4'b1000)? 1'b1 : 1'b0;
  
  assign lock_sync_detection =(slave && sync_bit_counter[1]==1'b1)?1'b1:(!slave && sync_bit_counter==3'b101)?1'b1:1'b0;
  
  assign ignore_sotsync_err =1'b0;
  
  assign temp_comp = (sync_detected_hs||ignore_sync_err_hs);
  
  //#######################
  //LP RECEIVER MODULE
  //#######################
  
  //STATE MACHINE
  always @(state or dlpln or  hs_req_f or forcetxstopmode or
    turndisable or dlpln_d or turn_req or
    enable_rxn or err_ctrl_cleard_f or low_pow_req or forcerxmode)
    begin :comb_block
      start_esc_rx_s =1'b0;
      high_speed_req = 1'b0;
      stopstate=1'b0;
      nxt_state = STOP_STATE;
      chg_dir_pulse=1'b0;
      turn_req_s=1'b0;
      hs_enb_req_s =1'b0;
      revert_diretction =1'b0;
      err_control_s =1'b0;
      err_ctrl_cleard_s =1'b0;
      esc_req_s =1'b0;
      low_pow_req_s=1'b0;
      hs_rx_en_s=1'b0;
      enable_lpdt_rcv =1'b0;
      case(state)
        //stop state
        STOP_STATE:
          begin
            stop_state;
          end
        //change direction from tx to rx
        CHG_DIR:
          begin
            chg_dir;
          end
        //'high speed receive request' receive state
        HS_RCV:
          begin
            hs_rcv;
          end
        //Low power entry request receive state
        LOW_POW:
          begin
            low_pow;
          end
        //turn(change direction) request receive state
        TURN_REQ_STATE:
          begin
            turn_req_state;
          end
        
        //turn(change direction) conformation state
        TURN_STATE:
          begin
            turn_state;
          end
        
        //escape mode exit state
        BRIDGE_ESCAPE:
          begin
            bridge_escape;
          end
        
        EXIT_ESCAPE:
          begin
            exit_escape;
          end
        
        //wait for stop state
        WAIT_STOP:
          begin
            wait_stop;
          end
        
        //default state
        default:
          begin
            nxt_state = STOP_STATE;
            stopstate=1'b1;
          end
      endcase
    end
  
  ////////////////////////////
  //PROCESS FOR DISABLE_EXT //
  ////////////////////////////
  always @(forcerxmode | forcetxstopmode)
    begin:disable_ext_loop
      disable_ext =1'b0;
      @(negedge txclkesc);
      disable_ext =1'b1;
      @(negedge txclkesc);
      disable_ext =1'b0;
    end
  
  
  ////////////////////////////
  //PROCESS FOR ERRSYNCESC  //
  ////////////////////////////
  always @(start_esc_rx_s)
    begin:errsyncesc_loop
      wait(start_esc_rx_s ==1'b0);
      if(esc_cmd_reg == 8'b11100001 && (bit_count!=3'b000 ||
        //(esc_cmd_over && !shift_reg_esc[0])) && !(forcerxmode |
        (esc_cmd_over && dlpln_d !=2'b10)) && !(forcerxmode |
        forcetxstopmode | disable_ext) && !start_esc_rx_s)
        begin
          errsyncesc =1'b1;
        end
      @(dlpln);
      errsyncesc =1'b0;
    end
  
  
  /////////////////////////////////////////////////
  //PROCESS FOR SYNCHRONISE STATE CHANGE AT RESET//
  /////////////////////////////////////////////////
  always @(txescclk_rst_n)
    begin
      if(!txescclk_rst_n)
        begin
      state             = STOP_STATE                            ;
      hs_req_f          = 1'b0                                  ;
      turn_req          = 1'b0                                  ;
      rxulpsesc         = 1'b0                                  ;
      ulpsactivenot     = 1'b1                                  ;
      low_pow_req       = 1'b0                                  ;
      err_ctrl_cleard_f = 1'b0                                  ;
      reverse_clk_count = 3'b001                                ;
      counter_hs        = 4'b0000                               ;
      revert_diretction = 1'b0                                  ;
      hs_rx_n_neg       = 1'b0                                  ;
      data_neg          = 1'b0                                  ;
      hs_rx_p           = 1'b0                                  ;
      rxdatahs_int_hs   = 8'h00                                 ;
      byte_over_t       = 1'b0                                  ;
      sync_detected_d   = 1'b0                                  ;
      sync_detected_hs  = 1'b0                                  ;
      disable_state_d   = 1'b0                                  ;
      disable comb_block                                        ;
      disable disable_ext_loop                                  ;
      disable errsyncesc_loop                                   ;
      disable req_loop                                          ;
      disable state_loop                                        ;
      disable sync_detected_s_loop                              ;
      disable direction_loop                                    ;
      disable hs_rx_en_t_loop                                   ;
      disable dlpln_d_loop                                      ;
      disable data_pos_loop                                     ;
      disable start_sync_count_loop                             ;
      disable disable_state_d_loop                              ;
      disable sync_detected_hs_loop                             ;
      disable data_neg_loop                                     ;
      disable errsotsynchs_loop                                 ;
      disable exit_lpdt                                         ;
      disable fwd_rec_loop                                      ;
      disable sync_detected_l_loop                              ;
      disable rev_rec_loop                                      ;
      disable ulps_loop                                         ;
      disable exit_hs_fwd                                       ;
      disable hs_cntrl_loop                                     ;
      disable rst_cntrl_sig                                     ;
      disable hs_rev_cntrl_loop                                 ;
      disable pro_lp_rx_en_s                                    ;
      disable pro_bit_cnt                                       ;
      disable errcontrol_loop                                   ;
     end
    end
  
  ///////////////////////////////////////////
  //PROCESS FOR ASSIGNING SIGNALS AT RESET //
  ///////////////////////////////////////////
  always @(txescclk_rst_n)
    begin
      //if(!txescclk_rst_n)
      //  direction = slave;
      stop_cnt=4'h0;
      dlpln_d =2'b00;
      start_sync_count = 1'b0;
      hs_rx_en_t=1'b0;
      hs_rx_en=1'b0;
      bit_count =3'b0;
    end
  
  ////////////////////////////////////////
  //PROCESS FOR REQUEST(HS,LP) SIGNALS  //
  ////////////////////////////////////////
  always @(posedge txclkesc)
    begin:req_loop
      if(txescclk_rst_n)
        begin
          if(state == STOP_STATE)
            begin
              hs_req_f <=1'b0;
              turn_req <=1'b0;
              low_pow_req <=1'b0;
              err_ctrl_cleard_f <=1'b0;
            end
          else
            begin
              if(high_speed_req)
                hs_req_f <=1'b1;
              if(turn_req_s)
                turn_req <=1'b1;
              if(low_pow_req_s)
                low_pow_req <=1'b1;
              if(err_ctrl_cleard_s)
                err_ctrl_cleard_f <=1'b1;
            end
        end
      
    end
  
  ////////////////////////////////////////
  //PROCESS FOR SYNCHRONISE STATE CHANGE //
  ////////////////////////////////////////
  always @(posedge txclkesc)
    begin:state_loop
      if(txescclk_rst_n)
        begin
          if(dlpln == 2'b11 || forcetxstopmode)
            state <= STOP_STATE;
          else if(forcerxmode)
            state <= WAIT_STOP;
          else
            state <= nxt_state;
        end
    end
  
  ///////////////////////////////////////////
  // PROCESS FOR ASSIGNING SYNC DETECTION  //
  ///////////////////////////////////////////
  always @(sync_reg or lock_sync_detection)
    begin:sync_detected_s_loop
      wait(((sync_reg == 8'b00011101) ||
      (sync_reg ==8'b00011100 )|| (sync_reg ==8'b00011111 )||
      (sync_reg == 8'b00011001)|| (sync_reg ==8'b00010101 )||
      (sync_reg ==8'b00001101 )|| (sync_reg ==8'b00111101 )||
      (sync_reg == 8'b01011101) ) || dlpln ==2'b11);
      if(dlpln !=2'b11 && (!(slave && sync_bit_counter[1]==1'b1) ||
        (!slave && ((sync_bit_counter==3'b101 && sync_reg !=8'b00001101)
        ||(sync_bit_counter==3'b100 && sync_reg ==8'b00001101)) )))
        begin
          sync_detected_s =1'b1;
          @(posedge rxddrclkhs);
          sync_detected_s <=1'b0;
        end
    end
  
  ///////////////////////////////////////////
  // PROCESS FOR ASSIGNING  DIRECTION      //
  ///////////////////////////////////////////
  always @(posedge txclkesc or negedge txescclk_rst_n)
    begin:direction_loop
      if(forcerxmode)
        direction<=1'b1;
      else if(forcetxstopmode)
        direction<= 1'b0;
      else if ((chg_dir_pulse|revert_diretction) && txescclk_rst_n)
        direction <= ~direction;
      else if(!txescclk_rst_n)
        direction <= slave;
    end
  
  //////////////////////////////////////////////
  // PROCESS FOR ASSIGNING HS RECEIVER ENAB   //
  //////////////////////////////////////////////
  always @ (posedge txclkesc)
    begin:hs_rx_en_t_loop
      if(hs_rx_en_s)
        hs_rx_en_t<=1'b1;
      else if(dlpln ==2'b11 ||!hs_rx_en_s)
        hs_rx_en_t<=1'b0;
      //hs_rx_en= hs_rx_en_t;
    end
  
  
  ///////////////////////////////////////////////
  // PROCESS TO FLOP DATA LINES FROM DATA LANE //
  //////////////////////////////////////////////
  always @(posedge txclkesc)
    begin:dlpln_d_loop
      dlpln_d<=dlpln;
      hs_rx_en<= hs_rx_en_t;
    end
  
  //////////////////////////////////
  // PROCESS TO ASSIGN  DATA POS  //
  //////////////////////////////////
  always @ (posedge hs_enb_req_s)
    begin:data_pos_loop
      while(hs_enb_req_s !=1'b0)
        begin
          @(posedge rxddrclkhs);
          data_pos<= hs_rx_p;
        end
    end
  
  //////////////////////////////////////////
  // PROCESS TO ASSIGN  START SYNC COUNT  //
  //////////////////////////////////////////
  always @ (hs_enb_req_s)
    begin:start_sync_count_loop
      wait(hs_rx_p | data_neg | !hs_enb_req_s);
      if((hs_rx_p || data_neg) && hs_enb_req_s)
        begin
          @(posedge rxddrclkhs);
          if(hs_enb_req_s)
            start_sync_count <= 1'b1;
        end
      else
        start_sync_count = 1'b0;
    end
  
  
  /////////////////////////////
  // DELAY DISABLE_STATE_LP  //
  /////////////////////////////
  always @(posedge rxddrclkhs)
    begin:disable_state_d_loop
      if(rxddr_rst_n)
        begin
          disable_state_d<=(forcerxmode | forcetxstopmode);
          sync_detected_d<=sync_detected_hs;
          byte_over_t <= byte_over_hs;
          hs_rx_p <= hs_rx;
        end
    end
 


 
  ////////////////////////////////
  //HIGH SPEED RECEPTION        //
  ////////////////////////////////
  always @(posedge rxddrclkhs)
    begin:sync_detected_hs_loop
      if(rxddr_rst_n)
        begin
          if(sync_detected_s)
            sync_detected_hs <=1'b1;
          else if( dlpln ==2'b11 || disable_state_d)
            sync_detected_hs <= 1'b0;
          if( hs_enb_req_s &&  byte_over_t && slave)
            rxdatahs_int_hs <= shift_reg_hs;
          else if(counter_hs==4'b0111 && !slave && hs_enb_req_s )
            rxdatahs_int_hs <={data_pos,shift_reg_hs[7:1]};
          else if(forcetxstopmode | forcerxmode)
            rxdatahs_int_hs <= 8'h00;
          if(!hs_enb_req_s || (byte_over_hs && slave) ||(forcerxmode & forcetxstopmode))
            counter_hs <= 4'b0000;
          else if(byte_over_hs && reverse_clk_count==3'b010)
            counter_hs <= 4'b0001;
          else if((ignore_sync_err_hs || sync_detected_hs) && ((!slave && reverse_clk_count==3'b010) || slave))
            counter_hs <= counter_hs + 4'b001;
          if (reverse_clk_count ==3'b010 )
            reverse_clk_count<=3'b001;
          else if (!slave && (start_sync_count|| hs_rx_p || data_neg))
            reverse_clk_count<=reverse_clk_count +3'b1;
        end
    end
  
  //#################################
  //PROCESS TO ASSIGN DATA NEG SIGNAL
  //#################################
  always @(negedge rxddrclkhs)
    begin:data_neg_loop
      if(rxddr_rst_n)
        begin
          hs_rx_n_neg <= hs_rx;
          if(hs_enb_req_s)
            data_neg<=hs_rx_n_neg;
          else
            data_neg<=1'b0;
        end
    end
  
  //###########################################
  //PROCESS TO ASSERT SOT SYNC AND SOT HS ERROR
  //###########################################
  always @(posedge err_sot_sync_hs_int_hs or posedge err_sot_hs_int_hs)
    begin:errsotsynchs_loop
      @(posedge rxbyteclkhs_1);
      errsotsynchs <= err_sot_sync_hs_int_hs;
      errsoths<= err_sot_hs_int_hs;
      @(posedge rxbyteclkhs_1);
      errsotsynchs <= 1'b0;
      errsoths<= 1'b0;
      wait(dlpln ==2'b11);
    end
  
  //////////////////////////////////////////////
  //PROCESS TO RECEIVE LOW POWER DATA RECEPTION
  //////////////////////////////////////////////
  always @(posedge enable_lpdt_rcv)
    begin :exit_lpdt
      erresc =1'b0;
      esc_cmd_over =1'b0;
      shift_reg_esc = 8'h00;
      bit_count =3'h0;
      esc_cmd_reg =8'h00;
      while (bit_count <3'h7 && dlpln !=2'b11 && !forcerxmode && !forcetxstopmode)
        begin
          if(start_esc_rx_s)
            @(posedge rxclkesc)
            shift_reg_esc<={shift_reg_esc[6:0],lp_rx_dp};
          bit_count <=bit_count +3'h1;
        end
      bit_count =3'h0;
      if({shift_reg_esc[6:0],lp_rx_dp} == 8'h1e)
        ulps_en =1'b1;
      @(negedge rxclkesc);
      ulps_en =1'b0;
      esc_cmd_reg<=shift_reg_esc;
      esc_cmd_over <=1'b1;
      if(esc_cmd_reg == 8'h1e)
        begin
          wait(dlpln ==2'b11);
        end
      wait(esc_cmd_over ==1'b1);
      if( !((esc_cmd_reg == 8'b00011110) || (esc_cmd_reg == 8'b11100001)||(esc_cmd_reg == 8'b01100010) ||
        (esc_cmd_reg == 8'b01011101) || (esc_cmd_reg == 8'b00100001) || (esc_cmd_reg == 8'b10100000))
        && !(forcerxmode | forcetxstopmode |stopstate))
        begin
          erresc<= 1'b1;
          @(posedge rxclkesc);
          erresc<= 1'b0;
          wait(dlpln ==2'b11 | forcerxmode| forcetxstopmode);
        end
      if(esc_cmd_reg == 8'he1)
        begin
          shift_reg_esc<={shift_reg_esc[6:0],lp_rx_dp};
          while (bit_count <3'h6)
            begin
              @(posedge rxclkesc)
              shift_reg_esc<={shift_reg_esc[6:0],lp_rx_dp};
              bit_count <=bit_count +3'h1;
            end
          while (dlpln !=2'b11)
            begin
              bit_count =3'h1;
              while (bit_count <3'h7)
                begin
                  @(posedge rxclkesc);
                  shift_reg_esc<={shift_reg_esc[6:0],lp_rx_dp};
                  bit_count <=bit_count +3'h1;
                end
            end
        end
      shift_reg_esc = 8'h00;
      @(posedge rxclkesc);
      esc_cmd_reg <= 8'h00;
    end
  always@(stopstate_out)
   begin
   if(stopstate_out)
     begin
     erresc = 1'b0;
     rxactivehs_skew = 1'b0;
     end
    end
  
  //////////////////////////////////////////////
  //PROCESS TO ASSIGN SHIFT_REG_ESC
  //////////////////////////////////////////////
  always @(negedge rxlpdtesc or negedge rxulpsesc or negedge rxtriggeresc_sig)
    begin:shift_reg_esc_loop
      shift_reg_esc = 8'h00;
    end

  
  //######################################################
  //                  HS RECEIVER PART
  //######################################################
  
  ///////////////////////
  // FORWARD RECEPTION //
  ///////////////////////
  always @ (posedge enable_high_speed_fwd)
    begin:fwd_rec_loop
      err_sot_hs_int_hs =1'b0;
      shift_reg_hs =8'h00;
      sync_bit_counter=3'h0;
      while (!sync_detected_s && sync_bit_counter <3'h2)
        begin
          sync_reg <={sync_reg[5:0],hs_rx_p,hs_rx_n_neg};
          @(posedge rxddrclkhs);
          if(start_sync_count)
            sync_bit_counter<=sync_bit_counter +3'h1;
        end

      if(!sync_detected_s && !sync_detected_hs)
        err_sot_sync_hs_int_hs<=1'b1;
      if ((sync_detected_s| sync_detected_hs) &&(sync_reg != 8'b00011101))
        err_sot_hs_int_hs <=1'b1;
      while(dlpln!=2'b11  & !forcerxmode & !forcetxstopmode)
        begin
          @(posedge rxddrclkhs);
          shift_reg_hs <={data_neg,data_pos,shift_reg_hs[7:2]};
        end
      @(posedge rxddrclkhs);
      shift_reg_hs <= 8'h00;
      sync_reg<=8'h00;
    end
  
  
    always @ (posedge enable_high_speed_fwd)
    begin:calibration
      sync_bit_counter1=3'h0;
      while (!sync_detected_s && sync_bit_counter1 <3'h7)
        begin
          sync_reg_cali <={sync_reg_cali[13:0],hs_rx_p,hs_rx_n_neg};
          @(posedge rxddrclkhs);
          if(start_sync_count)
            sync_bit_counter1<=sync_bit_counter1 +3'h1;
        end
      sync_reg_cali<=16'h00;
    end
 

  always@(*)
    begin:skew_check
     if(sync_reg_cali == 16'hffff && sync_bit_counter1 == 3'h7)
      begin
       sync_detected_cal = 1'b1;
       $display($time,"\tDPHY SLAVE BFM : TSKEWCAL_SYNC PATTERN DETECTED\n");
       @(posedge rxddrclkhs);
       sync_detected_cal = 1'b0;
      end
    end 
 
 
  
  ///////////////////////
  // SYNC DETECTION    //
  ///////////////////////
  
  always @(sync_detected_s)
    begin:sync_detected_l_loop
      if(sync_detected_s)
        sync_detected_l =1'b1;
      wait(dlpln ==2'b11)
      sync_detected_l =1'b0;
    end
 
always@(posedge sync_detected_cal)
  begin
     //repeat(16384)
   wait((hs_rx_p == 0 && hs_rx_n_neg == 1));
    while((hs_rx_p == 0 && hs_rx_n_neg == 1))
      begin
       //  if(hs_rx_p == 0 && hs_rx_n_neg == 1)
          skew_detect = 1;
      //   else
      //     skew_detect = 0;
          @(posedge rxddrclkhs);
       end
           skew_detect = 0;
       $display($time,"\tDPHY SLAVE BFM : TSKEWCAL SEQUENCE DETECTED\n");

  end


 
  ///////////////////////
  // REVERSE RECEPTION //
  ///////////////////////
  always @ (posedge enable_high_speed_rev)
    begin:rev_rec_loop
      err_sot_hs_int_hs =1'b0;
      shift_reg_hs =8'h00;
      sync_bit_counter<=3'h0;
      wait((hs_rx_p || data_neg));
      @(posedge rxddrclkhs);
      @(posedge rxddrclkhs);
      while (!sync_detected_s && sync_bit_counter <=3'h6)
        begin :sync_while_loop
          sync_reg <={sync_reg[6:0],hs_rx_p};
          sync_bit_counter<=sync_bit_counter +3'h1;
          @(posedge rxddrclkhs);
          if(sync_detected_s)
            begin
              lckd_frst_clk = 1'b1;
              disable sync_while_loop;
            end
          @(posedge rxddrclkhs);
          if(sync_detected_s)
            begin
              lckd_sec_clk = 1'b1;
              disable sync_while_loop;
            end
        end
      if(!sync_detected_s && !sync_detected_hs)
        err_sot_sync_hs_int_hs<=1'b1;
      if ((sync_detected_s| sync_detected_hs) &&(sync_reg != 8'b00011101))
        err_sot_hs_int_hs <=1'b1;
      while(dlpln!=2'b11)
        begin
          if(lckd_frst_clk == 1'b1)
            @(posedge rxddrclkhs);
          shift_reg_hs <={data_pos,shift_reg_hs[7:1]};
          lckd_frst_clk = 1'b0;
          @(posedge rxddrclkhs);
          @(posedge rxddrclkhs);
        end
      @(posedge rxddrclkhs);
      shift_reg_hs <= 8'h00;
      sync_reg<=8'h00;
    end
  
  ///////////////////////////////////
  //PROCESS TO ASSIGN ERROR CONTROL //
  ////////////////////////////////////
  always @(posedge txclkesc)
    begin:errcontrol_loop
      if(err_control_s)
        errcontrol <= 1'b1;
      else if(dlpln!=dlpln_d)
        errcontrol <= 1'b0;
    end
  
  
  //////////////////////////////////////////////////
  // ESCAPE RECIEVER COMBINATIONAL BLOCK (ULPS)   //
  //////////////////////////////////////////////////
  always @(rxulpsesc or dlpln or ulps_en or shift_reg_esc or esc_cmd_reg)
    
    begin: ulps_loop
      rxulpsesc =1'b0;
      if(start_esc_rx_s && ((shift_reg_esc == 8'h1e && ulps_en) || esc_cmd_reg == 8'h1e) && !rxlpdtesc)
        begin
          ulpsactivenot = 1'b0;
          rxulpsesc =1'b1;
          wait(dlpln ==2'b10 || dlpln ==2'b11 | forcerxmode | forcetxstopmode);
          if(dlpln ==2'b10 | forcerxmode | forcetxstopmode)
            ulpsactivenot = 1'b1;
          wait(dlpln ==2'b11| forcerxmode | forcetxstopmode);
          rxulpsesc =1'b0;
          shift_reg_esc=8'h00;
        end
    end
  
  
  ////////////////////////////////////////////
  // PROCESS FOR FORWARD HIGH SPEED RECEPTION
  ////////////////////////////////////////////
  always @(posedge enable_high_speed_fwd)
    begin :exit_hs_fwd
      @ (posedge temp_comp);
      if(hs_enb_req_s ==1'b1)
        begin
          @(posedge rxbyteclkhs_1);
          @(posedge rxbyteclkhs_1);
          rxsynchs_1 <=1'b1;
          rxactivehs_1 <=1'b1;
        end
      @(posedge rxbyteclkhs_1);
      if(hs_enb_req_s ==1'b1)
        begin
          rxsynchs_1 <=1'b0;
          rxvalidhs_1 <= 1'b1;
          rxdatahs_1 <= rxdatahs_int_hs;
        end
      while(dlpln!=2'b11 & !forcerxmode &!forcetxstopmode)
        begin
          
          @(posedge rxbyteclkhs_1);
          rxdatahs_1 <= rxdatahs_int_hs;
        end
  if(eot_handle_proc)
    begin
      start_sync_count =1'b0;
    end
   else
     begin
       hs_enb_req_s =1'b0;
       start_sync_count =1'b0;
       @(posedge rxbyteclkhs_1);
     end
      rxvalidhs_1 <= 1'b0;
      rxactivehs_1 <=1'b0;
      rxdatahs_1 <= 8'h00;
      err_sot_sync_hs_int_hs =1'b0;
    end
  
  //////////////////////////////////////////
  // PROCESS TO DEASSERT HS CONTROL SIGNALS //
  ////////////////////////////////////////////
  always @(posedge forcerxmode or posedge forcetxstopmode)
    begin:hs_cntrl_loop
      @(posedge rxbyteclkhs_1);
      rxvalidhs_1 <= 1'b0;
      rxsynchs_1 <=1'b0;
      @(posedge rxbyteclkhs_1);
      rxactivehs_1 <=1'b0;
      rxsynchs_1 <=1'b0;
      rxdatahs_1 <= 8'h00;
    end
  
  //////////////////////////////////////////////
  //PROCESS TO RESET THE CONTROL SIGNALS      //
  //////////////////////////////////////////////
  always @ (dlpln or errsyncesc or rxddr_rst_n)
    begin:rst_cntrl_sig
      if(dlpln ==2'b11 || errsyncesc |!rxddr_rst_n)
        begin
          if(errsyncesc |!rxddr_rst_n)
            esc_cmd_reg =8'h00;
          hs_enb_req_s =1'b0;
          hs_rx_en_s=1'b0;
          disable exit_lpdt;
          if(esc_cmd_reg == 8'b11100001)
            begin
              @(posedge rxclkesc);
              esc_cmd_reg <=8'h00;
            end
          else
            esc_cmd_reg =8'h00;
          disable exit_lpdt;
        end
    end
  
  ////////////////////////////////////////////
  // PROCESS FOR REVERSE HIGH SPEED RECEPTION
  ////////////////////////////////////////////
  always @(posedge enable_high_speed_rev)
    begin:hs_rev_cntrl_loop
      wait(sync_detected_d|ignore_sync_err_hs);
      if(hs_enb_req_s ==1'b1)
        begin
          @(posedge rxbyteclkhs_1);
          @(posedge rxbyteclkhs_1);
          @(posedge rxbyteclkhs_1);
          rxsynchs_1 <=1'b1;
          rxactivehs_1 <=1'b1;
        end
      @(posedge rxbyteclkhs_1);
      if(hs_enb_req_s ==1'b1)
        begin
          rxsynchs_1 <=1'b0;
          @(posedge rxbyteclkhs_1);
          rxdatahs_1 <= rxdatahs_int_hs;
          @(posedge rxbyteclkhs_1);
          rxdatahs_1 <= rxdatahs_int_hs;
          @(posedge rxbyteclkhs_1);
          rxvalidhs_1 <= 1'b1;
          rxdatahs_1 <= rxdatahs_int_hs;
          @(posedge rxbyteclkhs_1);
          rxvalidhs_1 <= 1'b0;
          rxdatahs_1 <= rxdatahs_int_hs;
        end
      while(dlpln!=2'b11 & !forcerxmode  & !forcetxstopmode)
        begin :rev_hs_task
          
          @(posedge rxbyteclkhs_1);
          rxdatahs_1 <= rxdatahs_int_hs;
          @(posedge rxbyteclkhs_1);
          rxdatahs_1 <= rxdatahs_int_hs;
          
          @(posedge rxbyteclkhs_1);
          rxvalidhs_1 <= 1'b1;
          @(posedge rxbyteclkhs_1);
          rxvalidhs_1 <= 1'b0;
        end
      @(posedge rxbyteclkhs_1);
      rxvalidhs_1 <= 1'b0;
      @(posedge rxbyteclkhs_1);
      rxactivehs_1 <=1'b0;
      rxdatahs_1 <= 8'h00;
      
    end
  
  
//flop to rxbyteclk
 always@(posedge rxbyteclkhs)
  begin
     rxsynchs <= rxsynchs_1;
    if(rxactivehs_skew)
      rxactivehs <=rxactivehs_skew;
    else
      rxactivehs <=rxactivehs_1;
     rxvalidhs <= rxvalidhs_1;
     rxdatahs <= rxdatahs_1;
     rxskewcallhs <= rxskewcallhs_1;
  end



 always@(posedge sync_detected_cal)
  begin
      @(posedge rxbyteclkhs_1);
      rxactivehs_skew = 1'b1;
      wait(rxskewcallhs_1);
      wait(!rxskewcallhs_1);
      @(posedge rxbyteclkhs_1);
      rxactivehs_skew = 1'b0;

  end

 always@(negedge skew_detect)
  begin
      @(posedge rxbyteclkhs_1);
      rxskewcallhs_1 = 1'b1;
      @(posedge rxbyteclkhs_1);
      rxskewcallhs_1 = 1'b0;
  end



  /////////////////////////////
  // TASKS FOR STATE MACHINE //
  /////////////////////////////
  
  ////////////////
  // STOP STATE //
  ////////////////
  task stop_state;
    begin
      stopstate=1'b1;
      enable_high_speed_fwd =1'b0;
      enable_high_speed_rev =1'b0;
      revert_diretction =1'b0;
      hs_rx_en=1'b0;
      if(enable_rxn)
        begin
          nxt_state = CHG_DIR;
          stopstate=1'b0;
        end
      else if(direction && dlpln_d ==2'b11 && dlpln== 2'b01)
        begin
          nxt_state = HS_RCV;
          high_speed_req = 1'b1;
          stopstate=1'b1;
        end
      else if(direction && dlpln_d ==2'b11 && dlpln== 2'b10)
        begin
          nxt_state = LOW_POW;
          low_pow_req_s=1'b1;
          stopstate=1'b0;
        end
      else
        begin
          nxt_state = STOP_STATE;
          stopstate=1'b1;
        end
    end
  endtask
  
  //////////////////////
  // CHANGE DIRECTION //
  //////////////////////
  task chg_dir;
    begin
      if(dlpln==2'b11)
        begin
          nxt_state = STOP_STATE;
          stopstate=1'b1;
          err_control_s =(dlpln_d !=2'b10);
        end
      
      else if(dlpln_d ==2'b10 && (dlpln_d !=dlpln))
        begin
          revert_diretction =1'b1;
          err_control_s =1'b1;
          nxt_state = STOP_STATE;
        end
      else
        begin
          err_control_s =(dlpln !=2'b00) && (dlpln !=2'b10);
          chg_dir_pulse= (dlpln ==2'b10) && (dlpln_d !=2'b10);
          if(dlpln ==2'b00 ||(dlpln ==2'b10))
            nxt_state = CHG_DIR;
          else
            nxt_state = STOP_STATE;
        end
    end
  endtask
  
  ////////////////////////
  // HIGH SPEED RECEIVE //
  ////////////////////////
  task hs_rcv;
    begin
      if(dlpln==2'b11)
        begin
          nxt_state = STOP_STATE;
          stopstate=1'b1;
          hs_enb_req_s=1'b0;
          if(!err_ctrl_cleard_f)
            err_control_s =1'b1;
        end
      else if(dlpln_d == 2'b00 && (dlpln !=2'b11 && dlpln != 2'b00))
        err_control_s =1'b1;
      else if(dlpln ==2'b00)
        begin
          err_ctrl_cleard_s =1'b1;
          nxt_state = HS_RCV;
          hs_enb_req_s=1'b1;
          hs_rx_en_s=1'b1;
          if(slave)
            enable_high_speed_fwd =1'b1;
          else
            enable_high_speed_rev =1'b1;
        end
      else if(dlpln == 2'b01)
        begin
          nxt_state = HS_RCV;
        end
      else
        begin
          nxt_state = STOP_STATE;
          if(!err_ctrl_cleard_f)
            err_control_s =1'b1;
        end
    end
  endtask
  
  //////////////////////
  // LOW POWER        //
  //////////////////////
  task low_pow;
    begin
      if(dlpln ==2'b11)
        begin
          err_control_s =1'b1;
          stopstate=1'b1;
        end
      else if(dlpln == 2'b10 && !low_pow_req && dlpln_d ==2'b00)
        begin
          turn_req_s =1'b1;
          nxt_state = TURN_REQ_STATE;
        end
      else if(dlpln ==2'b01 && dlpln_d ==2'b00)
        begin
          nxt_state = BRIDGE_ESCAPE;
          esc_req_s =1'b1;
        end
      else if(dlpln == 2'b01)
        err_control_s =1'b1;
      else
        nxt_state = LOW_POW;
    end
  endtask
  
  
  //////////////////////
  // TURN REQUEST     //
  //////////////////////
  task turn_req_state;
    begin
      if(dlpln==2'b11)
        begin
          stopstate=1'b1;
          nxt_state = STOP_STATE;
          if(!err_ctrl_cleard_f)
            err_control_s =1'b1;
          else
            err_control_s =1'b0;
        end
      else if (turn_req && dlpln ==2'b00)
        begin
          nxt_state = TURN_STATE;
          err_ctrl_cleard_s =1'b1;
        end
      else if (turn_req && dlpln ==2'b10)
        nxt_state = TURN_REQ_STATE;
      else
        begin
          nxt_state = STOP_STATE;
          if(!err_ctrl_cleard_f)
            err_control_s =1'b1;
          else
            err_control_s =1'b0;
        end
      
    end
  endtask
  
  
  //////////////////////
  // TURN STATE       //
  //////////////////////
  task turn_state;
    begin
      
      if(dlpln==2'b11)
        begin
          stopstate=1'b1;
          nxt_state = STOP_STATE;
          //if(!err_ctrl_cleard_f)
          err_control_s =1'b1;
        end
      else if(dlpln == 2'b00 && !turndisable)
        begin
          chg_dir_pulse=1'b1;
          nxt_state = STOP_STATE;
        end
      else if(turndisable | forcerxmode)
        begin
          nxt_state = WAIT_STOP;
        end
      else
        begin
          err_control_s =1'b1;
          nxt_state = WAIT_STOP;
        end
    end
  endtask
  
  /////////////////////////
  // BRIDGE_ESCAPE STATE //
  ////////////////////////
  task bridge_escape;
    begin
      if(dlpln==2'b11)
        begin
          nxt_state = STOP_STATE;
          if(!err_ctrl_cleard_f)
            err_control_s =1'b1;
        end
      else if(dlpln ==2'b00)
        begin
          start_esc_rx_s =1'b1;
          err_ctrl_cleard_s =1'b1;
          nxt_state = EXIT_ESCAPE;
        end
      else if(dlpln ==2'b01)
        begin
          err_ctrl_cleard_s =1'b1;
          nxt_state = BRIDGE_ESCAPE;
        end
      else
        begin
          err_control_s =1'b1;
          nxt_state = WAIT_STOP;
        end
    end
  endtask
  
  
  //////////////////////
  // EXIT ESCAPE      //
  //////////////////////
  
  task exit_escape;
    begin
      if(dlpln==2'b11)
        begin
          stopstate=1'b1;
          nxt_state = STOP_STATE;
          enable_lpdt_rcv =1'b0;
        end
      else
        begin
          start_esc_rx_s =1'b1;
          enable_lpdt_rcv =1'b1;
          err_ctrl_cleard_s =1'b1;
          nxt_state = EXIT_ESCAPE;
        end
    end
  endtask
  
  //////////////////////
  // WAIT STOP        //
  //////////////////////
  
  task wait_stop;
    begin
      shift_reg_esc = 8'h00;
      esc_cmd_reg = 8'h00;
      if(dlpln==2'b11)
        begin
          stopstate=1'b1;
          nxt_state = STOP_STATE;
        end
      else if(forcetxstopmode)
        begin
          nxt_state = STOP_STATE;
        end
      else
        begin
          nxt_state= WAIT_STOP;
        end
    end
  endtask
  
  
  //LOW POWER RECEPTION ENABLE SIGNAL TO TRANSCEIVER
  always @(posedge txclkesc or negedge txescclk_rst_n)
    begin : pro_lp_rx_en_s
      if(!txescclk_rst_n)
        lp_rx_en_s<=slave;
      else if  (forcerxmode)
        lp_rx_en_s<= 1'b1;
      else if (forcetxstopmode)
        lp_rx_en_s<= 1'b0;
      else if((enable_rxn && !direction) ||(chg_dir_pulse && direction))
        lp_rx_en_s<=~lp_rx_en_s;
    end
  
  
  
  //DATA BIT COUNTER
  always @(posedge rxclkesc or negedge rxescclk_rst_n)
    begin : pro_bit_cnt
      if(!rxescclk_rst_n)
        bit_cnt <=3'b000;
      else if(rxlpdt_esc_s && start_esc_rx_s)
        bit_cnt <= bit_cnt + 3'b001;
      else if (!start_esc_rx_s)
        bit_cnt <=3'b000;
    end
  always @(negedge enable_high_speed_fwd)
    begin
      sync_reg= 8'h00;
      start_sync_count = 1'b0;
    end
  
endmodule
