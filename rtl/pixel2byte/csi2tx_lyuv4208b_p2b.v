/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_lyuv4208b_p2b.v
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
module csi2tx_lyuv4208b_p2b 
 (
 input  wire         clk,
 input  wire         rst_n,
 input  wire [2:0]   pixel_cnt,
 input  wire [31:0]  pixel_data,
 input  wire [31:0]  pixel_data_d1,
 input  wire         pixel_data_vld,
 input  wire         sensor_pixel_vld_falling_edge,
 input  wire         lyuv4208b_odd_even_convrn_enable,
 input  wire         lyuv4208b_convrn_enable,
 output wire [31:0]  dw,
 output wire         dw_vld
 );
 
 /*---------------------------------------------------------------------------*/
 // Internal Signal declaration
 /*---------------------------------------------------------------------------*/
 reg  [31:0] dw_reg;
 reg         dw_vld_s;
 wire        min_rxed_pkt_vld;
 
 /*---------------------------------------------------------------------------*/
 // Output valid generation, when the received packet is of 24bits i.e. 3 bytes
 
 assign min_rxed_pkt_vld = ( lyuv4208b_convrn_enable  ? 
                           (( ( pixel_cnt != 0 ) && sensor_pixel_vld_falling_edge ) ? 1'b1 : 1'b0 ) 
                           : 1'b0 );
                           
 /*---------------------------------------------------------------------------*/
 // Logic to convert the pixel to dw
 // This is been registerd as this interface is expected to work at around 400Mhz
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0 )
   dw_reg <= 32'b0;
  else if (lyuv4208b_convrn_enable)
   case(pixel_cnt)
    3'b000 : begin
     if ( lyuv4208b_odd_even_convrn_enable == 1'b0 ) begin // odd
      dw_reg[7:0]   <= pixel_data[17:10]; // u1
      dw_reg[15:8]  <= pixel_data[27:20]; // y1
     end
     else if ( lyuv4208b_odd_even_convrn_enable == 1'b1 ) begin // even
      dw_reg[7:0] <= pixel_data[7:0]; // v1
      dw_reg[15:8] <= pixel_data[27:20]; // y1
     end
    end
    3'b001 : begin
     if ( lyuv4208b_odd_even_convrn_enable == 1'b0 ) begin // odd
      dw_reg[23:16] <= pixel_data[27:20]; // y2
     end
     else if ( lyuv4208b_odd_even_convrn_enable == 1'b1 ) begin// even
      dw_reg[23:16] <= pixel_data[27:20]; // y2
     end     
    end
    3'b010 : begin
     if ( lyuv4208b_odd_even_convrn_enable == 1'b0 ) begin
      dw_reg[31:24] <= pixel_data[17:10]; // u3
     end
     else if ( lyuv4208b_odd_even_convrn_enable == 1'b1 ) begin
      dw_reg[31:24] <= pixel_data[7:0]; // v3
     end
    end
    3'b011 : begin
     if ( lyuv4208b_odd_even_convrn_enable == 1'b0 ) begin
      dw_reg[7:0]   <= pixel_data_d1[27:20]; // y3
      dw_reg[15:8]  <= pixel_data[27:20]; // y4
     end else if ( lyuv4208b_odd_even_convrn_enable == 1'b1 ) begin
      dw_reg[7:0]   <= pixel_data_d1[27:20]; // y3
      dw_reg[15:8]  <= pixel_data[27:20]; // y4
     end
    end
    3'b100 : begin
     if ( lyuv4208b_odd_even_convrn_enable == 1'b0 ) begin
      dw_reg[23:16] <= pixel_data[17:10]; // u5
      dw_reg[31:24] <= pixel_data[27:20]; // y5
     end else if ( lyuv4208b_odd_even_convrn_enable == 1'b1 ) begin
      dw_reg[23:16] <= pixel_data[7:0]; // v5
      dw_reg[31:24] <= pixel_data[27:20]; // y5
     end
    end
    3'b101 : begin
     if ( lyuv4208b_odd_even_convrn_enable == 1'b0 ) begin
      dw_reg[7:0]   <= pixel_data[27:20]; // y6
     end else if ( lyuv4208b_odd_even_convrn_enable == 1'b1 ) begin
      dw_reg[7:0]   <= pixel_data[27:20]; // y6
     end
    end
    3'b110 : begin
     if ( lyuv4208b_odd_even_convrn_enable == 1'b0 ) begin
      dw_reg[15:8]  <= pixel_data[17:10]; // u7
      dw_reg[23:16] <= pixel_data[27:20]; // y7
     end else if ( lyuv4208b_odd_even_convrn_enable == 1'b1 ) begin
      dw_reg[15:8] <= pixel_data[7:0]; // v7
      dw_reg[23:16] <= pixel_data[27:20]; // y7
     end
    end
    3'b111 : begin
     if ( lyuv4208b_odd_even_convrn_enable == 1'b0 ) begin
      dw_reg[31:24] <= pixel_data[27:20]; // y8
     end else if ( lyuv4208b_odd_even_convrn_enable == 1'b1) begin
      dw_reg[31:24] <= pixel_data[27:20]; // y8
     end
    end     
   endcase
 end   
 
  assign dw = dw_reg;
 
 // As the data valid is registered version(odd pixels), 
 always@(posedge clk or negedge rst_n)
 begin
  if (rst_n == 1'b0)
   dw_vld_s <= 1'b0;
  else if (( (pixel_cnt == 3'b010) || (pixel_cnt == 3'b100) || 
             (pixel_cnt == 3'b111) ) && pixel_data_vld && lyuv4208b_convrn_enable)
   dw_vld_s <= 1'b1;
  else
   dw_vld_s <= 1'b0;
 end
 
 assign dw_vld = ( dw_vld_s | min_rxed_pkt_vld ); 
endmodule
