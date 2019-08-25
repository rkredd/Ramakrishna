////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//     Copyright (c) 2011 Arasan Chip Systems Inc. All Rights Reserved        //
/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_sync_pulse.v
// Author      : SHYAM SUNDAR B S
// Version     : v1p2
// Abstract    :Pulse Synchronizer  
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`include "csi2tx_defines.v"
module csi2tx_sync_pulse(
  clk_in, 
  clk_out,
  rsta_n,
  rstb_n,
  in_pulse,
  
  out_pulse
  );
  
  input clk_in;       // Clock Input
  input clk_out;      // Clock Output
  input rsta_n;       // Active low Reset
  input rstb_n;       // Active low Reset
  input in_pulse;     // Input Pulse - Asserted for 1 clk (clk_in)
  
  output out_pulse;   // Synchronized Output Pulse - Asserted for 1 clk (clk_out)
  
  reg in_pulse_lat;
  reg flop1;
  reg flop2;
  reg flop3;
  
  assign out_pulse = flop2 ^ flop3;
  
  // in_pulse is latched
  always @(posedge clk_in or negedge rsta_n)
    if (!rsta_n)
      in_pulse_lat <= 1'b 0;
    else if (in_pulse)
      in_pulse_lat <= ~in_pulse_lat;
  
  // Three Flop Synchronizer
  always @(posedge clk_out or negedge rstb_n)
    if (!rstb_n)
      begin : syn_init
        flop1 <= 1'b 0;
        flop2 <= 1'b 0;
        flop3 <= 1'b 0;
      end
    else 
      begin : flop_syn
        flop1 <= in_pulse_lat;
        flop2 <= flop1;
        flop3 <= flop2;
      end
  
endmodule
