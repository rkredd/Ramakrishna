/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_clk_gen.v
// Author      : B. Shenbagaramesh
// Version     : v1p2
// Abstract    : This module generates all the clocks required 
//                
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 21/05/2014
//==============================================================================*/
`timescale 1 ps / 1 fs

module csi2tx_clk_gen(
    input          [31:0]  pixel_width                                         ,
    output  reg           ahb_hrst_n                                          , 
    output  reg           ci_clk                                              ,
    output  wire          hclk                                                ,
    output  reg           txclkesc                                            ,
    output  wire          txddr_clk_q                                         ,
    output  wire          txddr_clk_i                                         ,
    output  reg            clk_generated                                       ,
    output  wire  [31:0]  ci_clk_time                                         ,
    output  wire  [31:0]  ddr_clk_time
   );
 

  /*---------------------------------------------------------------------------
    Internal Register, Wire & Integer Declaration
  ---------------------------------------------------------------------------*/
  reg           hclk_temp                                                     ;
  reg   [31:0]  lane_count                                                    ;

  real          ci_freq                                                       ;
  real          freq_isp                                                      ;
  real          ddr_freq_t                                                    ;
  real          ddr_freq                                                      ;
  real          freq_ddr                                                      ;
  real          txclkesc_freq                                                 ;
  real          hclk_freq                                                     ;
  real          byte_clk_freq                                                 ; 
  real          ci_clk_width                                                  ;
  real          ddr_clk_width                                                 ;
  real          txclkesc_width                                                ;
  real          hclk_width                                                    ;
  
  integer       count                                                         ;
  integer       out                                                           ;
  real          divby2 = 2.000000                                             ;
  real          CI_CLK_PERIOD                                                 ;
  real          DDR_OUT_CLK_PERIOD                                            ;
  real          QUAD_SHIFT                                                    ;
  reg           ddr_clk_i                                                     ;
  reg           ddr_clk_q                                                     ;

  /*---------------------------------------------------------------------------
    Memory Declaration
  ---------------------------------------------------------------------------*/
  reg [31:0] freq_array[0:5]                                                  ;
  
  real ddr_freq_real;
  real sensor_freq_real;

  /*---------------------------------------------------------------------------
    Initalization
  ---------------------------------------------------------------------------*/
  initial
    begin
      ahb_hrst_n      =  1'b1;
      txclkesc        =  1'b0;
      hclk_temp       =  1'b0;
      ci_clk          =  1'b0;
      out             =  $fopen("freq.dat","r");
      hclk_freq       =  100;
      hclk_width      =  10000;
      txclkesc_freq   =  40;
      txclkesc_width  =  25000;
      ddr_clk_i       = 0;
      count           =  $fscanf(out,"%f %f",ddr_freq_real,sensor_freq_real);
      freq_ddr        =  ddr_freq_real;
      freq_isp        =  sensor_freq_real;      
      clk_generated   = 1'b0;

      #50;

      ahb_hrst_n      =  1'b0; 

      #37500;

      ahb_hrst_n      =  1'b1;
    end

  /*---------------------------------------------------------------------------
    This block operates in two modes:
    1. assigns user defined clock frequency if the user sets clock frequencies 
       through command line
    2. assigns clock frequencuies based on the lane, pixel_width relation    
  ---------------------------------------------------------------------------*/
  always@(freq_isp or freq_ddr or lane_count or pixel_width)
  //always@(*)
    begin
       clk_generated = 1'b0;
      `ifdef USER_FREQ
        ci_freq   = freq_isp;
        ddr_freq  = freq_ddr;
      `else
        ci_freq   = freq_isp;

      `ifdef ONE_LANE       lane_count = 3'b000; // lane 1
      `elsif TWO_LANE       lane_count = 3'b001; // lane 2
      `elsif THREE_LANE     lane_count = 3'b010; // lane 3
      `elsif FOUR_LANE      lane_count = 3'b011; // lane 4
      `elsif FIVE_LANE      lane_count = 3'b100; // lane 5
      `elsif SIX_LANE       lane_count = 3'b101; // lane 6
      `elsif SEVEN_LANE     lane_count = 3'b110; // lane 7
      `elsif EIGHT_LANE     lane_count = 3'b111; // lane 8
      `else                 lane_count = 3'b111; // default lane 1
      `endif
      
      byte_clk_freq        = (ci_freq * pixel_width) / ((lane_count+1) * 8); 

      ddr_freq_t  = (byte_clk_freq*4);

        ddr_freq  = ddr_freq_t;

     `endif

     $strobe ($time,"\tCLOCK GEN MODULE: SENSOR CLK FREQUENCY SET BY USER = %fMHz\n",ci_freq);
     $strobe ($time,"\tCLOCK GEN MODULE: BYTE CLK FREQUENCY SET BY USER = %fMHz\n",(ddr_freq/4));
     $strobe ($time,"\tCLOCK GEN MODULE: DDR CLK FREQUENCY SET BY USER  = %fMHz\n",ddr_freq);

    ci_clk_width  = (1/ci_freq)*1000000;
    ddr_clk_width = (1/ddr_freq)*1000000;
    CI_CLK_PERIOD = (ci_clk_width/2);
    DDR_OUT_CLK_PERIOD = (ddr_clk_width/2);
    QUAD_SHIFT     = (DDR_OUT_CLK_PERIOD/2);
  end
 
 initial
  begin
      repeat(4)
      @(posedge txddr_clk_q);
      clk_generated = 1'b1;
  end

 

  /*---------------------------------------------------------------------------
    ahb clock generation process
  ---------------------------------------------------------------------------*/
  always@(*)
    begin
      hclk_width = (1/hclk_freq)*1000000;
    end
 
  always
    #(hclk_width/2) hclk_temp = ~hclk_temp; 

  /*---------------------------------------------------------------------------
    lowpower clock generation process
  ---------------------------------------------------------------------------*/ 
  always@(*)
    begin
      txclkesc_width = (1/txclkesc_freq)*1000000;
    end  

  always
    #(txclkesc_width/2)txclkesc = ~txclkesc;  
  
  /*---------------------------------------------------------------------------
    ci clock generation process
  ---------------------------------------------------------------------------*/
  always
    #CI_CLK_PERIOD ci_clk = ~ci_clk; 
  
  /*---------------------------------------------------------------------------
      DDR Clock
  ---------------------------------------------------------------------------*/ 
  always
   #DDR_OUT_CLK_PERIOD ddr_clk_i = ~ddr_clk_i;
  
 
  always@(ddr_clk_i)
   #QUAD_SHIFT
     ddr_clk_q = ddr_clk_i;

  assign txddr_clk_q        = ddr_clk_q;
  assign txddr_clk_i        = ddr_clk_i;

  assign ci_clk_time  = ci_clk_width;
  assign ddr_clk_time = ddr_clk_width;
  assign hclk         = hclk_temp;

  
endmodule
