/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_clock_lane_ctrl.v
// Author      : SHYAM SUNDAR B. S
// Abstract    : 
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`include "csi2tx_defines.v"
module csi2tx_clock_lane_ctrl 
(
 input  wire        txbyteclkhs               ,
 input  wire        txbyteclkhs_rst_n         ,
 input  wire        sleep_mode_enable         ,
 input  wire        sleep_mode_exit           ,
 input  wire [2:0]  lane_config               ,
 input  wire        forcetxstopmode           ,
 input  wire        dphy_clk_mode             ,
 input  wire        txrequesths               ,
 input  wire        tinit_start               ,
 input  wire        stop_state_cl             ,
 input  wire        stop_state_dl             ,
 input  wire        ulpsactivenot_n           ,
 input  wire [7:0]  tclk_lpx                  ,
 input  wire [7:0]  tclk_prep                 ,
 input  wire [7:0]  tclk_zero                 ,
 input  wire [7:0]  tclk_pre                  ,
 input  wire [7:0]  tclk_post                 ,
 input  wire [7:0]  tclk_trial                ,
 input  wire [7:0]  ths_exit                  ,
 input  wire        elastic_fifo_empty_rd_dm  ,
 input  wire        dphy_calib_ctrl           ,
 output wire        txrequesths_cl            ,
 output wire        txrequestesc              ,
 output wire        txulpsesc_entry_dl        ,
 output wire        txulpsesc_exit_dl         ,
 output wire        txulpsesc_entry_cl        ,
 output wire        txulpsesc_exit_cl         ,
 output wire        enable_hs_transmission    ,
 output wire [7:0]  txskewcalhs               ,
 output wire [7:0]  data_lane_enabled      
);
//------------------------------------------------------------------------------
// Internal signal declaration
reg [3:0] cur_state;
parameter IDLE        = 4'b0000 ;
parameter CLK_EN      = 4'b0001 ;
parameter START_CLK   = 4'b0010 ;
parameter CLK_ACTIVE  = 4'b0011 ;
parameter STOP_CLK    = 4'b0100 ;
parameter WAIT        = 4'b0101 ;
parameter SLEEP_MODE  = 4'b0110 ;
parameter SLEEP_EXIT  = 4'b0111 ;
parameter ULPM_EXIT   = 4'b1000 ;
parameter CALIB_START = 4'b1001 ;
parameter CALIB_END   = 4'b1010 ;
reg        sleep_mode_entry_r          ;
reg        init_clk_pre_done_r         ;
reg        enable_hs_transmission_r    ;
reg        txrequesths_cl_r            ;
reg  [9:0] tclk_pre_r                  ;
wire       tclk_pre_cnt_down2zero_c    ;
reg  [7:0] tclk_post_r                 ;
wire       tclk_post_cnt_down2zero_c   ;
reg  [7:0] data_lane_enabled_s         ;
reg        txrequestesc_r              ;
reg        txulpsesc_entry_dl_r        ;
reg        txulpsesc_exit_dl_r         ;
reg        txulpsesc_entry_cl_r        ;
reg        txulpsesc_exit_cl_r         ;
reg  [7:0] txskewcalhs_r               ;




//------------------------------------------------------------------------------
// 1. This statemachine control the HS request for clock in continuous and 
//    non-continuous clock mode
// 2. Controls the ULPS entry and exit
// 3. Controls the calbiration
// 4. Generates an enable signal for the HS data transmission
//------------------------------------------------------------------------------
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  cur_state <= IDLE;
 else if (forcetxstopmode == 1'b1)
   cur_state <= IDLE;
 else
  case (cur_state)
   IDLE : begin
    if ((tinit_start == 1'b1) && (sleep_mode_enable == 1'b1) && (txrequesths == 1'b0) && (tclk_post_cnt_down2zero_c == 1'b1)) begin
     cur_state <= SLEEP_MODE;
    // Make sure the data lane are in STOP STATE(LP) and there is either a HS data to be processed before enabling the
    // clock 
    // 1. In continuous clock mode this is valid only at the start up
    // 2. In non-continuos clock mode this is valid for every transaction
    end else if ((tinit_start == 1'b1) && (stop_state_dl == 1'b1) && ((elastic_fifo_empty_rd_dm == 1'b0) || (txrequesths == 1'b1)) && (sleep_mode_enable == 1'b0) && (dphy_calib_ctrl == 1'b0) ) begin
     // In non-continous clock mode make sure even the clock lane in stop state before requesting next HS
      if ((stop_state_cl == 1'b1) && (dphy_clk_mode == 1'b1))
       cur_state <= CLK_EN;
      else if (dphy_clk_mode == 1'b0)
       cur_state <= CLK_EN;
   end else if ((tinit_start == 1'b1) && (dphy_calib_ctrl == 1'b1)) begin
      cur_state <= CALIB_START;
    end else begin
     cur_state <= IDLE;
    end
   end
   //---------------------------------------------------------------------------
   // 1. When the SLEEP mode is requested, make a entry when the state machine
   // enter SLEEP MODE. use this signal to start the clock when the SLEEP mode
   // is exited. As before starting the clock the the CLOCK PRE needs to be satisfied 
   // 2. On first time start up, make sure the clock timing are met and then
   // only the clock is started
   CLK_EN : begin
    if ((tclk_pre_cnt_down2zero_c == 1'b1) && (sleep_mode_entry_r == 1'b1))
     cur_state <= START_CLK;
    else if ((tclk_pre_cnt_down2zero_c == 1'b1) && (init_clk_pre_done_r == 1'b1))
     cur_state <= START_CLK;
    else if (init_clk_pre_done_r == 1'b1)
     cur_state <= START_CLK;
    else
     cur_state <= CLK_EN;
   end
   //---------------------------------------------------------------------------
   // As the clock is started wait for the data lane to enter the HS transmission
   START_CLK : begin
    if (stop_state_dl == 1'b0)
     cur_state <= CLK_ACTIVE;
    else
     cur_state <= START_CLK;
   end
   //---------------------------------------------------------------------------
   // As the data lane is in HS mode, wait till the current transaction get over
   // one it it over
   CLK_ACTIVE : begin
    if (stop_state_dl == 1'b1)
     cur_state <= STOP_CLK;
    else
     cur_state <= CLK_ACTIVE;
   end
   //---------------------------------------------------------------------------
   // Wait for the Clock-Post to stop the clock
   STOP_CLK : begin
    if ((tclk_post_cnt_down2zero_c == 1'b1) && (dphy_clk_mode == 1'b1))
     cur_state <= WAIT;
    // Note : The POST CNT will be taken care only if the SLEEP mode is requrested
    // the condition is covered in IDLE state
    else if (dphy_clk_mode == 1'b0)
     cur_state <= WAIT;
    else
     cur_state <= STOP_CLK;
   end
   //---------------------------------------------------------------------------
   WAIT : begin
    // Checking of stop state cl will take care the tclk_trial in non-continuoud
    // clock mode
    if ((dphy_clk_mode == 1'b1) && (stop_state_cl == 1'b1))
     cur_state <= IDLE;
    else if (dphy_clk_mode == 1'b0)
     cur_state <= IDLE;
    else
     cur_state <= WAIT;     
   end
   //---------------------------------------------------------------------------
   SLEEP_MODE : begin
    if (sleep_mode_exit == 1'b1)
     cur_state <= SLEEP_EXIT;
    else
     cur_state <= SLEEP_MODE;
   end
   //---------------------------------------------------------------------------
   SLEEP_EXIT : begin
    if (ulpsactivenot_n == 1'b1)
     cur_state <= ULPM_EXIT;
    else
     cur_state <= SLEEP_EXIT;
   end
   //---------------------------------------------------------------------------
   ULPM_EXIT : begin
    if (sleep_mode_exit == 1'b0)
     cur_state <= IDLE;
    else
     cur_state <= ULPM_EXIT;
   end
   //---------------------------------------------------------------------------
   CALIB_START : begin
    if (dphy_calib_ctrl == 1'b0)
      cur_state <= CALIB_END;
    else
      cur_state <= CALIB_START;
   end
   //---------------------------------------------------------------------------
   CALIB_END : begin
    cur_state <= IDLE;
   end
  endcase
end

//-----------------------------------------------------------------------------
// Calibration PPI control
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
  if (txbyteclkhs_rst_n == 1'b0) 
   txskewcalhs_r <= 8'b0;
  else 
   case(cur_state)
     CALIB_START : begin
       txskewcalhs_r <= data_lane_enabled_s;
     end 
     default : txskewcalhs_r <= 8'b0;
   endcase
end

assign txskewcalhs = txskewcalhs_r;

//------------------------------------------------------------------------------
// The sleep mode entry signal is used to indicates that the PHY had entered
// the sleep mode and exited. After the exit make sure to when requesting for 
// new HS request, all the timing for the clock lane is met. 
//------------------------------------------------------------------------------
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  sleep_mode_entry_r <= 1'b0;
 else if (tinit_start == 1'b0)
  sleep_mode_entry_r <= 1'b0;
 else if (cur_state == SLEEP_MODE)
  sleep_mode_entry_r <= 1'b1;
 else if (((cur_state == CLK_EN) && (tclk_pre_cnt_down2zero_c == 1'b1)) || (forcetxstopmode == 1'b1)) 
  sleep_mode_entry_r <= 1'b0;
end

always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  init_clk_pre_done_r <= 1'b0;
 else if (tinit_start == 1'b0)
  init_clk_pre_done_r <= 1'b0;
 // 1. For continuous clock mode one set will be held high until the reset
 // 2. For non-continoud clock mode de-asserted for every burst and asserted back
 else if ((cur_state == CLK_EN) && (tclk_pre_cnt_down2zero_c == 1'b1))
  init_clk_pre_done_r <= 1'b1;
 else if ((cur_state == SLEEP_MODE) || ( (cur_state == IDLE) && (dphy_clk_mode == 1'b1)) || (forcetxstopmode == 1'b1))
  init_clk_pre_done_r <= 1'b0;
end

//------------------------------------------------------------------------------
// This signal is driven high only after the clock is driven on the clock lane
// to meet the DPHY specificaiton
//------------------------------------------------------------------------------
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  enable_hs_transmission_r <= 1'b0;
 else if (tinit_start == 1'b0)
  enable_hs_transmission_r <= 1'b0;
 else if (cur_state == IDLE)
  enable_hs_transmission_r <= 1'b0;
 // 1. For continuous clock mode one set will be held high until the reset
 // 2. For non-continoud clock mode de-asserted for every burst and asserted back
 else if ((cur_state == CLK_EN) && (tclk_pre_cnt_down2zero_c == 1'b1))
  enable_hs_transmission_r <= 1'b1;
 else if ((cur_state == STOP_CLK) && (dphy_clk_mode == 1'b1))
   enable_hs_transmission_r <= 1'b0;
 else if ((cur_state == SLEEP_MODE) || (forcetxstopmode == 1'b1))
  enable_hs_transmission_r <= 1'b0;
end

assign enable_hs_transmission = enable_hs_transmission_r;

//------------------------------------------------------------------------------
// Clock lane HS request generation
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  txrequesths_cl_r <= 1'b0;
 else if (tinit_start == 1'b0)
  txrequesths_cl_r <= 1'b0;
 else if (forcetxstopmode == 1'b1)
   txrequesths_cl_r <= 1'b0;
 else 
  case (cur_state)
   IDLE : begin
    if (dphy_clk_mode == 1'b0)
     txrequesths_cl_r <= 1'b1;
    else if (dphy_clk_mode == 1'b1)
     txrequesths_cl_r <= 1'b0;
    else 
     txrequesths_cl_r <= 1'b0;
   end
   CLK_EN : begin
    txrequesths_cl_r <= 1'b1;
   end
   STOP_CLK : begin
    if ((tclk_post_cnt_down2zero_c == 1'b1) && (dphy_clk_mode == 1'b1))
     txrequesths_cl_r <= 1'b0;
    // Note : The POST CNT will be taken care only if the SLEEP mode is requrested
    // the condition is covered in IDLE state
    else if (dphy_clk_mode == 1'b0)
     txrequesths_cl_r <= 1'b1;
    else
     txrequesths_cl_r <= txrequesths_cl_r;
   end
   SLEEP_MODE : begin
    txrequesths_cl_r <= 1'b0;
   end
   default : txrequesths_cl_r <= txrequesths_cl_r;   
  endcase 
end

assign txrequesths_cl = txrequesths_cl_r;

//------------------------------------------------------------------------------
// Tclk Pre
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  tclk_pre_r <= 10'b0;
 else if ((tinit_start == 1'b0) || (forcetxstopmode == 1'b1))
  tclk_pre_r <= 10'b0;
 else if ((cur_state == CLK_EN) && (tclk_pre_r != 10'h0) &&  (stop_state_cl == 1'b0))
  tclk_pre_r <= tclk_pre_r - 1'b1;
 else if (((cur_state == IDLE) && (init_clk_pre_done_r == 1'b0)) || ((cur_state == IDLE) && (dphy_clk_mode == 1'b1)))
  tclk_pre_r <= tclk_pre + tclk_lpx + tclk_zero + tclk_prep;
end

assign tclk_pre_cnt_down2zero_c = (!(|tclk_pre_r)) ? 1'b1 : 1'b0;

//------------------------------------------------------------------------------
// Tclk post
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  tclk_post_r <= 8'b0;
 else if ((tinit_start == 1'b0) || (forcetxstopmode == 1'b1))
  tclk_post_r <= 8'b0;
 else if ((cur_state == IDLE) && (tclk_post_r != 0) && (txrequesths == 1'b0) && (sleep_mode_enable == 1'b1))
  tclk_post_r <= tclk_post_r - 1'b1;
 else if ((cur_state == STOP_CLK) && (tclk_post_r != 0) && (txrequesths == 1'b0) && (dphy_clk_mode == 1'b1))
  tclk_post_r <= tclk_post_r - 1'b1;
 else if (cur_state == IDLE)
  tclk_post_r <= tclk_post;
end

assign tclk_post_cnt_down2zero_c = (!(|tclk_post_r)) ? 1'b1 : 1'b0;

//------------------------------------------------------------------------------
//
always@(*) begin
 case (lane_config)
  3'b000  : data_lane_enabled_s = 8'b0000_0001;
  3'b001  : data_lane_enabled_s = 8'b0000_0011;
  3'b010  : data_lane_enabled_s = 8'b0000_0111;
  3'b011  : data_lane_enabled_s = 8'b0000_1111;
  3'b100  : data_lane_enabled_s = 8'b0001_1111;
  3'b101  : data_lane_enabled_s = 8'b0011_1111;
  3'b110  : data_lane_enabled_s = 8'b0111_1111;
  3'b111  : data_lane_enabled_s = 8'b1111_1111;
  default : data_lane_enabled_s = 8'b0000_0000;
 endcase
end

assign data_lane_enabled = data_lane_enabled_s;

//------------------------------------------------------------------------------
// ULPS and ESC request generation
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0) begin
  txrequestesc_r        <= 1'b0;
  txulpsesc_entry_dl_r  <= 1'b0;
  txulpsesc_exit_dl_r   <= 1'b0;
  txulpsesc_entry_cl_r  <= 1'b0;
  txulpsesc_exit_cl_r   <= 1'b0;
 end else if ((tinit_start == 1'b0) || (forcetxstopmode == 1'b1)) begin
  txrequestesc_r        <= 1'b0;
  txulpsesc_entry_dl_r  <= 1'b0;
  txulpsesc_exit_dl_r   <= 1'b0;
  txulpsesc_entry_cl_r  <= 1'b0;
  txulpsesc_exit_cl_r   <= 1'b0;
 end else  
  case (cur_state)
   SLEEP_MODE : begin
   txrequestesc_r        <= 1'b1;
   txulpsesc_entry_dl_r  <= 1'b1;
   txulpsesc_exit_dl_r   <= 1'b0;
   txulpsesc_entry_cl_r  <= 1'b1;
   txulpsesc_exit_cl_r   <= 1'b0;
  end
   //---------------------------------------------------------------------------
   SLEEP_EXIT : begin
     txrequestesc_r        <= 1'b1;
     txulpsesc_entry_dl_r  <= 1'b1;
     txulpsesc_exit_dl_r   <= 1'b1;
     txulpsesc_entry_cl_r  <= 1'b1;
     txulpsesc_exit_cl_r   <= 1'b1;
    end
   //---------------------------------------------------------------------------
   ULPM_EXIT : begin
    if (sleep_mode_exit == 1'b0) begin
     txrequestesc_r        <= 1'b0;
     txulpsesc_entry_dl_r  <= 1'b0;
     txulpsesc_exit_dl_r   <= 1'b0;
     txulpsesc_entry_cl_r  <= 1'b0;
     txulpsesc_exit_cl_r   <= 1'b0;
    end
   end    
   //---------------------------------------------------------------------------
   default : begin
     txrequestesc_r        <= 1'b0;
     txulpsesc_entry_dl_r  <= 1'b0;
     txulpsesc_exit_dl_r   <= 1'b0;
     txulpsesc_entry_cl_r  <= 1'b0;
     txulpsesc_exit_cl_r   <= 1'b0;
   end
  endcase
end

assign txrequestesc          = txrequestesc_r       ;
assign txulpsesc_entry_dl    = txulpsesc_entry_dl_r ;
assign txulpsesc_exit_dl     = txulpsesc_exit_dl_r  ;
assign txulpsesc_entry_cl    = txulpsesc_entry_cl_r ;
assign txulpsesc_exit_cl     = txulpsesc_exit_cl_r  ;

endmodule
