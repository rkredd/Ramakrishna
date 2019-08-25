/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_yuv4208b_p2b.v
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
module csi2tx_yuv4208b_p2b 
 (
 input  wire         clk,
 input  wire         rst_n,
 input  wire [1:0]   pixel_cnt,
 input  wire [31:0]  pixel_data,
 input  wire         pixel_data_vld,
 input  wire         sensor_pixel_vld_falling_edge,
 input  wire         yuv4208b_odd_even_convrn_enable,
 input  wire         yuv4208b_convrn_enable,
 output wire [31:0]  dw,
 output wire         dw_vld
 );
 
 /*---------------------------------------------------------------------------*/
 // Internal Signal declaration
 /*---------------------------------------------------------------------------*/
 reg  [31:0] dw_reg;
 reg         dw_odd_vld_s;
 reg         dw_even_vld_s;
 wire        min_rxed_pkt_vld;
 
 /*---------------------------------------------------------------------------*/
 // Output valid generation, when the received packet is of 24bits i.e. 3 bytes
 
 assign min_rxed_pkt_vld = ( yuv4208b_convrn_enable  ? 
                           (( ( pixel_cnt != 0 ) && sensor_pixel_vld_falling_edge ) ? 1'b1 : 1'b0 ) 
                           : 1'b0 ); 
                           
 /*---------------------------------------------------------------------------*/
 // Logic to convert the pixel to dw
 // This is been registerd as this interface is expected to work at around 400Mhz
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0 )
   dw_reg <= 32'b0;
  else if ( (yuv4208b_convrn_enable == 1'b1) && (yuv4208b_odd_even_convrn_enable == 1'b0))
   case(pixel_cnt)
    2'b00 : dw_reg[7:0]   <= pixel_data[27:20];
    2'b01 : dw_reg[15:8]  <= pixel_data[27:20];
    2'b10 : dw_reg[23:16] <= pixel_data[27:20];
    2'b11 : dw_reg[31:24] <= pixel_data[27:20];
    default : dw_reg <= 32'b0;
   endcase
  else if ( (yuv4208b_convrn_enable  == 1'b1) && (yuv4208b_odd_even_convrn_enable == 1'b1))
   case(pixel_cnt)
    2'b00 : begin
     dw_reg[7:0] <= pixel_data[17:10]; // u1
     dw_reg[15:8] <= pixel_data[27:20]; // y1
     dw_reg[23:16] <= pixel_data[7:0]; // v1
    end
    2'b01 : begin
     dw_reg[31:24] <= pixel_data[27:20]; // y2
    end
    2'b10 : begin
     dw_reg[7:0] <= pixel_data[17:10]; // u3
     dw_reg[15:8] <= pixel_data[27:20]; // y3
     dw_reg[23:16] <= pixel_data[7:0]; // v3
    end
    2'b11 : begin
     dw_reg[31:24] <= pixel_data[27:20]; // y4
    end
    default : dw_reg <= 32'b0;
   endcase
 end          
 
   assign dw = dw_reg;
 
 // As the data valid is registered version(odd pixels), 
 always@(posedge clk or negedge rst_n)
 begin
  if (rst_n == 1'b0)
   dw_odd_vld_s <= 1'b0;
  else if ( (pixel_cnt == 2'b11 ) && pixel_data_vld && yuv4208b_convrn_enable &&
  (yuv4208b_odd_even_convrn_enable == 1'b0))
   dw_odd_vld_s <= 1'b1;
  else
   dw_odd_vld_s <= 1'b0;
 end
 
  // As the data valid is registered version(even pixels), 
 always@(posedge clk or negedge rst_n)
 begin
  if (rst_n == 1'b0)
   dw_even_vld_s <= 1'b0;
  else if ( ((pixel_cnt == 2'b01) || (pixel_cnt == 2'b11) ) && pixel_data_vld && yuv4208b_convrn_enable &&
  (yuv4208b_odd_even_convrn_enable == 1'b1))
   dw_even_vld_s <= 1'b1;
  else
   dw_even_vld_s <= 1'b0;
 end
 
 assign dw_vld = ( dw_odd_vld_s || dw_even_vld_s || min_rxed_pkt_vld );    
endmodule
