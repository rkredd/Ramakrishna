/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_raw8_p2b.v
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
module csi2tx_raw8_p2b
 (
 input  wire        clk,
 input  wire        rst_n,
 input  wire [1:0]  pixel_cnt,
 input  wire [7:0]  pixel_data,
 input  wire        pixel_data_vld,
 input  wire        sensor_pixel_vld_falling_edge,
 input  wire        raw8_convrn_enable,
 output wire [31:0] dw,
 output wire        dw_vld
 );
 
 reg  [31:0] dw_reg;
 reg         dw_vld_s;
 wire        min_rxed_pkt_vld;

 /*---------------------------------------------------------------------------*/
 // Output valid generation, when the received packet is of 1,2,3 bytes
 // count is checked for one extra bcuase of falling edge detection of the vld
 // from the sensor interface
 
 assign min_rxed_pkt_vld = ( raw8_convrn_enable  ? 
                           ((( pixel_cnt != 0 ) && sensor_pixel_vld_falling_edge ) ? 1'b1 : 1'b0 ) 
                           : 1'b0 );
                           
 /*---------------------------------------------------------------------------*/
 // Logic to convert the pixel to dw
 // This is been registerd as this interface is expected to work at around 400Mhz
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0 )
   dw_reg <= 32'b0;
  else if (raw8_convrn_enable)
   case(pixel_cnt)
    2'b00   : dw_reg[7:0]   <= pixel_data;
    2'b01   : dw_reg[15:8]  <= pixel_data;
    2'b10   : dw_reg[23:16] <= pixel_data;
    2'b11   : dw_reg[31:24] <= pixel_data;
    default : dw_reg[31:0]  <= 32'h0; 
   endcase
  else
   dw_reg <= 32'b0;   
 end 
 
 assign dw = dw_reg;
 
  // As the data valid is registered version, check the count one clock before
  always@(posedge clk or negedge rst_n)
  begin
   if ( rst_n == 1'b0 )
    dw_vld_s <= 1'b0;
   else if ( (pixel_cnt == 2'b11) && pixel_data_vld && raw8_convrn_enable)
    dw_vld_s <= 1'b1;
   else
    dw_vld_s <= 1'b0;              
  end
  
  assign dw_vld = dw_vld_s | min_rxed_pkt_vld;
endmodule
