/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_clk_lane_lp_rxr.v
// Author      : B Shenbagaramesh 
// Version     : v1p2
// Abstract    : This module is used for the clock lane reception
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
//************************************************
//MODULE FOR LOW POWER CLOCK LANE RECEIVER
//************************************************
`timescale 1 ps / 1 ps
module csi2tx_dphy_clk_lane_lp_rxr(
  //INPUT SIGNALS
  //INPUT FROM PPI
  input     wire        txclkesc
  ,        //INPUT LOW POWER CLK
  input     wire        txescclk_rst_n   ,   //INPUT GATED RESET SIGNAL FOR TXCLKESC(LOW POWER CLOCK) CLOCK DOMAIN
  input     wire        slave            ,
  input     wire        lp_rx_cp_clk     ,   //INPUT LOW POWER CP LINE
  input     wire        lp_rx_cn_clk     ,   //INPUT LOW POWER CN LINE
  
  //OUTPUT SIGNALS
  //OUTPUT TO PPI
  output    wire        stopstate        ,   //OUTPUT SIGNAL TO INDICATE THAT CLOCK LANE IS IN STOP STATE
  output    wire        rxulpsclknot,        //OUTPUT ACTIVE LOW SIGNAL TO INDICATE ULPS STATE
  output    wire        ulpsactivenot    ,   //OUTPUT ACTIVE LOW WHEN CLOCK LANE IS IN ULPS STATE AND BECOMES WHEN MARK-1 STATE IS RECEIVED
  output    wire        rxclkactivehs    ,   //OUTPUT SIGNAL TO INDICATE THAT DDRCLK IS BEING RECEIVED
  
  //OUTPUT TO TRANSCEIVER
  output    wire        hs_rx_cntrl_clk  ,   //OUPTUT HIGH SPEED RECEPTION CONTROL SIGNAL FOR CLOCK LANE TO THE TRANSCEIVER
  output    wire        lp_rx_cntrl_clk  ,   //OUTPUT LOW POWER RECEPTION CONTROL SIGNAL FOR CLOCK LANE TO THE TRANSCEIVER
  
  //OUTPUT TO TRANSMITTER
  output    wire        sot                  //OUPUT START OF TRANSMISSION ENABLE SIGNAL TO THE DATA LANE DURING CLOCK RECEPTION
  );
  
  
  
  //**********************************************************************
  //REGISTER AND NET DECLARATIONS
  //**********************************************************************
  //WIRE DECLARATIONS
  wire [1:0]    cpcn                                                          ;
                                                                              
  //REGISTER DECLARATIONS                                                     
  reg [1:0]     state                                                         ;
  reg [1:0]     nxt_state                                                     ;
  reg           stop_state_s                                                  ;
  reg           hs_enb_s                                                      ;
  reg           rx_ulps_clk_s                                                 ;
  reg           hs_enb_t                                                      ;
  reg [1:0]     cpcn_d                                                        ;
  reg           ulps_exit                                                     ;
  reg           ulps_entry                                                    ;
  reg           hs_entry                                                      ;
  
  //PARAMETER FOR CLOCK LANE LOW POWER RECEIVER
  parameter STOP_STATE  = 2'b00                                               ;
  parameter WAIT_STOP   = 2'b01                                               ;
  parameter ENTER_ULPS  = 2'b10                                               ;
  
  ////////////////////////////////////////////////////////////////////////////////////////
  
  //ASSIGN STATEMENTS
  //SIGNAL INDICATING STOPSTATE FOR CLOCK LANE
  assign  stopstate = stop_state_s && (cpcn == 2'b11);
  
  //SIGNAL INDICATING ULPS STATE
  assign rxulpsclknot = !(rx_ulps_clk_s && (cpcn !=2'b11));
  
  //SIGNAL INDICATING MARK-1 IS RECEIVED IN ULPS STATE
  assign ulpsactivenot = !rx_ulps_clk_s  || (cpcn !=2'b00);
  
  //SIGNAL COMBINING CP, CN LINE OF CLOCK LANE
  assign cpcn = {lp_rx_cp_clk,lp_rx_cn_clk};
  
  //SIGNAL TO INDICATE CLOCK LANE IS RECEIVING DDR CLOCK
  assign rxclkactivehs =  hs_enb_s;
  
  //SIGNAL TO INDICATE CLOCK LANE IS RECEIVING DDR CLOCK
  assign sot = hs_enb_s;
  
  //SIGNAL TO ENABLE TRANSCEIVER LOW POWER INPUT
  assign lp_rx_cntrl_clk = slave;
  
  //SIGNAL TO ENABLE TRANSCEIVER HIGH SPEED INPUT
  assign hs_rx_cntrl_clk = slave && hs_enb_t;
  
  initial
    begin
      hs_enb_t          = 1'b0                             ;
      cpcn_d            = 2'b00                            ;
      ulps_exit         = 1'b0                             ;
      ulps_entry        = 1'b0                             ;
      hs_entry          = 1'b0                             ;
    end
  
  //**********************************************************************
  // CLOCK LANE LOW POWER RECEIVER FSM
  //**********************************************************************
  always @(state or cpcn)
    begin : comb_block
      stop_state_s=1'b0;
      nxt_state = STOP_STATE;
      rx_ulps_clk_s=1'b0;
      hs_enb_s=1'b0;
      case(state)
        STOP_STATE:
          stop_state;
        WAIT_STOP:
          wait_stop;
        ENTER_ULPS:
          enter_ulps;
        default:
          begin
            nxt_state = STOP_STATE;
            stop_state_s=1'b1;
          end
      endcase
    end
  
  //************TASK START*************************
  
  //*********************************
  //STOP STATE
  //*********************************
  task stop_state;
    begin
      stop_state_s=1'b1;
      if( cpcn_d ==2'b11 && cpcn == 2'b01)
        begin
          nxt_state = WAIT_STOP;
        end
      else if(cpcn_d ==2'b11 && cpcn == 2'b10)
        begin
          nxt_state = ENTER_ULPS;
        end
      else
        begin
          nxt_state = STOP_STATE;
        end
    end
  endtask
  
  //*********************************
  //HIGH SPEED STATE IN CLOCK LANE
  //*********************************
  task wait_stop;
    begin
      if(cpcn ==2'b11)
        begin
          stop_state_s=1'b1;
          nxt_state = STOP_STATE;
        end
      else if(!hs_entry  && (cpcn ==2'b00 || cpcn ==2'b01))
        begin
          nxt_state = WAIT_STOP;
          hs_enb_s= (cpcn ==2'b00);
        end
      else if(hs_entry  && (cpcn ==2'b00))
        begin
          nxt_state = WAIT_STOP;
          hs_enb_s= 1'b1;
        end
      else
        nxt_state = STOP_STATE;
    end
  endtask
  
  //************************
  //CLOCK LANE IN ULPS STATE
  //************************
  task  enter_ulps;
    begin
      if(cpcn ==2'b11)
        begin
          stop_state_s=1'b1;
          nxt_state = STOP_STATE;
        end
      else if(ulps_exit && (cpcn == 2'b00))
        begin
          nxt_state = STOP_STATE;
        end
      else if(!ulps_entry && (cpcn == 2'b00 ||cpcn ==2'b10))
        begin
          rx_ulps_clk_s=(cpcn == 2'b00);
          nxt_state = ENTER_ULPS;
        end
      else if(ulps_entry && (cpcn == 2'b00 ||cpcn ==2'b10))
        begin
          rx_ulps_clk_s=1'b1;
          nxt_state = ENTER_ULPS;
        end
      else
        begin
          nxt_state = STOP_STATE;
        end
    end
  endtask
  
  //************TASK END*************************
  
  //************************
  //PROCESS FOR STATE CHANGE
  //************************
  always @(posedge txclkesc or negedge txescclk_rst_n)
    begin : pro_state
      if(!txescclk_rst_n)
        state <= STOP_STATE;
      else if(cpcn == 2'b11)
        state <= STOP_STATE;
      else
        state <= nxt_state;
    end
  
  //************************
  //PROCESS FOR HS_ENB
  //************************
  always @ (posedge txclkesc)
    begin
      //@(posedge txclkesc);
      @(posedge txclkesc);
      hs_enb_t <= hs_enb_s;
    end
  
  
  //************************
  //PROCESS FOR HS_ENB
  //************************
  always @ (posedge txclkesc)
    begin
      cpcn_d <= cpcn;
    end
  
  
  //************************************************
  //PROCESS FOR HS_ENTRY
  //************************************************
  always @ (posedge txclkesc)
    begin
      if(!txescclk_rst_n)
        hs_entry <= 1'b0;
      else if(state == WAIT_STOP  && (cpcn ==2'b00 ))
        hs_entry <= 1'b1;
      else if(state != WAIT_STOP || state == STOP_STATE)
        hs_entry <= 1'b0;
    end
  
  //************************************************
  //PROCESS FOR ULPS_ENTRY
  //************************************************
  always @ (posedge txclkesc)
    begin
      if(!txescclk_rst_n)
        ulps_entry <= 1'b0;
      else if(state ==ENTER_ULPS && (cpcn ==2'b00 ))
        ulps_entry <= 1'b1;
      else if(state !=ENTER_ULPS || state == STOP_STATE)
        ulps_entry <= 1'b0;
    end
  
  //************************************************
  //PROCESS FOR ULPS_EXIT
  //************************************************
  always @ (posedge txclkesc)
    begin
      if(!txescclk_rst_n)
        ulps_exit <= 1'b0;
      else if(ulps_entry && (cpcn ==2'b10 ))
        ulps_exit <= 1'b1;
      else if(state !=ENTER_ULPS || state == STOP_STATE)
        ulps_exit <= 1'b0;
    end
  
  
endmodule
