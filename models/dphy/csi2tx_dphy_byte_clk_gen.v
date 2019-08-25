/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_byte_clk_gen.v
// Author      : B. Shenbagaramesh
// Version     : v1p2
// Abstract    : This module is used to generate byte clock for both 
//               transmitter and the receiver       
//              
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`timescale 1ps / 1ps
//MODULE TO GENERATE BYTE CLOCK FOR BOTH TRANSMITTER AND RECEIVER
module csi2tx_dphy_byte_clk_gen(
  //INPUTS
  input                ddrclkhs                                 , //HIGH SPEED DDR CLOCK
  input                rst_n                                    , //ASYNCHRONOUS ACTIVE LOW RESET SIGNAL
  //OUTPUTS
  output   wire        byteclkhs                                  //GENERATED OUTPUT BYTE CLOCK SIGNAL
  );
  
  //INTERNAL REG/NET DECLARATION
  reg [1:0]byteclk_cnt;
  
  
//------------------------------------------------------------------
// Shift register that generates the divided by clock from the  
// DDR clock
//------------------------------------------------------------------
reg [1:0] clk_shift_reg;

always @(posedge ddrclkhs or negedge rst_n) begin
  if(!rst_n) begin
    clk_shift_reg = 'b0;
  end else begin
    clk_shift_reg[1:0] = {clk_shift_reg[0],(~clk_shift_reg[1])};
  end
end

assign byteclkhs = clk_shift_reg[0];


endmodule
