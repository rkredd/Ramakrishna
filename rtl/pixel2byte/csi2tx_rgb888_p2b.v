/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_rgb888_p2b.v
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
module csi2tx_rgb888_p2b 
(
 input  wire         clk,
 input  wire         rst_n,
 input  wire [1:0]   pixel_cnt,
 input  wire [23:0]  pixel_data,
 input  wire [23:0]  pixel_data_d1,
 input  wire         pixel_data_vld,
 input  wire         sensor_pixel_vld_falling_edge,
 input  wire         rgb888_convrn_enable,
 output wire [31:0]  dw,
 output wire         dw_vld
 );
 
/*---------------------------------------------------------------------------*/
 // Internal Signal declaration
 /*---------------------------------------------------------------------------*/
 reg  [31:0] dw_reg;
 reg         dw_vld_s;
 wire        min_rxed_pkt_vld;
 reg         d_min_rxed_pkt_vld;
 
 
 /*---------------------------------------------------------------------------*/
 // Output valid generation, when the received packet is of 24bits i.e. 3 bytes
 
 assign min_rxed_pkt_vld = ( rgb888_convrn_enable  ? 
                           (( ( pixel_cnt != 0 ) && sensor_pixel_vld_falling_edge ) ? 1'b1 : 1'b0 ) 
                           : 1'b0 );
 
/* Regsiter */
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0 )
    d_min_rxed_pkt_vld <= 1'b0;
  else
    d_min_rxed_pkt_vld <= min_rxed_pkt_vld;
 end
 
 /*---------------------------------------------------------------------------*/
 // Logic to convert the pixel to dw
 // This is been registerd as this interface is expected to work at around 400Mhz
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0 )
   dw_reg <= 32'b0;
  else if (rgb888_convrn_enable)
   case (pixel_cnt)
    2'b00 : dw_reg[23:0]   <= pixel_data;
    2'b01 : dw_reg[31:24]  <= pixel_data[7:0];
    2'b10 :
    begin
     dw_reg[15:0]  <= pixel_data_d1[23:8];
     dw_reg[31:16] <= pixel_data[15:0];
    end
    2'b11 :
     begin
      dw_reg[7:0]  <= pixel_data_d1[23:16];
      dw_reg[31:8] <= pixel_data[23:0];
     end
    default : dw_reg <= 32'b0;
   endcase
  else
   dw_reg <= 32'b0;   
 end
 
 assign dw = dw_reg;
 
 // As the data valid is registered version, check the count one clock before
 always@(posedge clk or negedge rst_n)
 begin
  if (rst_n == 1'b0)
   dw_vld_s <= 1'b0;
  else if ( ((pixel_cnt == 2'b01) || (pixel_cnt == 2'b10) || (pixel_cnt == 2'b11) ) &&
            pixel_data_vld && rgb888_convrn_enable)
   dw_vld_s <= 1'b1;
  else
   dw_vld_s <= 1'b0;
 end
 
 assign dw_vld = ( dw_vld_s || d_min_rxed_pkt_vld ); 
endmodule
