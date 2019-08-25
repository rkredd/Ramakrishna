/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_rgb666_p2b.v
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
module csi2tx_rgb666_p2b 
 (
 input  wire         clk,
 input  wire         rst_n,
 input  wire [3:0]   pixel_cnt,
 input  wire [17:0]  pixel_data,
 input  wire [17:0]  pixel_data_d1,
 input  wire         pixel_data_vld,
 input  wire         sensor_pixel_vld_falling_edge,
 input  wire         rgb666_convrn_enable,
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
 
 assign min_rxed_pkt_vld = ( rgb666_convrn_enable  ? 
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
  else if (rgb666_convrn_enable)
   case (pixel_cnt)
    4'b0000 : dw_reg[17:0]  <= pixel_data; // p1
    4'b0001 : dw_reg[31:18] <= pixel_data[13:0]; // p2
    4'b0010 :
    begin
     dw_reg[3:0] <= pixel_data_d1[17:14]; // p2
     dw_reg[21:4] <= pixel_data; // p3
    end
    4'b0011 : dw_reg[31:22] <= pixel_data[9:0]; // p4
    4'b0100 :
    begin
     dw_reg[7:0]  <= pixel_data_d1[17:10]; // p4
     dw_reg[25:8] <= pixel_data; // p5
   end
   4'b0101 : dw_reg[31:26] <= pixel_data[5:0]; // p6
   4'b0110 :
   begin
    dw_reg[11:0]  <= pixel_data_d1[17:6]; // p6
    dw_reg[29:12] <= pixel_data; // p7
   end
   4'b0111 : dw_reg[31:30] <= pixel_data[1:0]; // p8
   4'b1000 :
   begin
    dw_reg[15:0]  <= pixel_data_d1[17:2]; // p8
    dw_reg[31:16] <= pixel_data[15:0]; // p9
   end
   4'b1001 :
   begin
    dw_reg[1:0] <= pixel_data_d1[17:16]; // p9
    dw_reg[19:2] <= pixel_data; // p10
   end
   4'b1010 : dw_reg[31:20] <= pixel_data[11:0]; // p11
   4'b1011 : 
   begin
    dw_reg[5:0] <= pixel_data_d1[17:12]; // p11
    dw_reg[23:6] <= pixel_data; // p12
   end
   4'b1100 : dw_reg[31:24] <= pixel_data[7:0]; //p13
   4'b1101 : 
   begin
    dw_reg[9:0]   <= pixel_data_d1[17:8]; // p13
    dw_reg[27:10] <= pixel_data; // p14 
   end
   4'b1110 : dw_reg[31:28] <= pixel_data[3:0]; // p15
   4'b1111 :
   begin
    dw_reg[13:0] <= pixel_data_d1[17:4]; // p15
    dw_reg[31:14] <= pixel_data; // p16
   end
  endcase 
 end
 
 assign dw = dw_reg;
 
 // As the data valid is registered version, check the count one clock before
 always@(posedge clk or negedge rst_n)
 begin
  if (rst_n == 1'b0)
   dw_vld_s <= 1'b0;
  else if (((pixel_cnt == 4'b0001) || (pixel_cnt == 4'b0011) || (pixel_cnt == 4'b0101) || 
            (pixel_cnt == 4'b0111) || (pixel_cnt == 4'b1000) ||
            (pixel_cnt == 4'b1010) || (pixel_cnt == 4'b1100) || (pixel_cnt == 4'b1110) ||
            (pixel_cnt == 4'b1111) ) && pixel_data_vld && rgb666_convrn_enable)
   dw_vld_s <= 1'b1;
  else
   dw_vld_s <= 1'b0;
 end
 
 assign dw_vld = ( dw_vld_s || d_min_rxed_pkt_vld ); 
endmodule
