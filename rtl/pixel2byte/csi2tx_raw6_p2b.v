/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_raw6_p2b.v
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
module csi2tx_raw6_p2b 
(
 input  wire        clk,
 input  wire        rst_n,
 input  wire [3:0]  pixel_cnt,
 input  wire [5:0]  pixel_data,
 input  wire [5:0]  pixel_data_d1,
 input  wire        pixel_data_vld,
 input  wire        sensor_pixel_vld_falling_edge,
 input  wire        raw6_convrn_enable,
 output wire [31:0] dw,
 output wire        dw_vld
 );
 
 /*---------------------------------------------------------------------------*/
 // Internal Signal declaration
 /*---------------------------------------------------------------------------*/
 reg  [31:0] dw_reg;
 reg         dw_vld_s;
 wire        min_rxed_pkt_vld;
 
 
 /*---------------------------------------------------------------------------*/
 // Output valid generation, when the received packet is of 24bits i.e. 3 bytes
 
 assign min_rxed_pkt_vld = ( raw6_convrn_enable  ? 
                           (( (pixel_cnt != 0) && (sensor_pixel_vld_falling_edge) ) ? 1'b1 : 1'b0 ) 
                           : 1'b0 );
 
 
 /*---------------------------------------------------------------------------*/
 // Logic to convert the pixel to dw
 // This is been registerd as this interface is expected to work at around 400Mhz
 
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0)
   dw_reg <= 32'b0;
  else if ( raw6_convrn_enable )
   case(pixel_cnt)
    4'b0000 : dw_reg[5:0]   <= pixel_data; //p0
    4'b0001 : dw_reg[11:6]  <= pixel_data; //p1
    4'b0010 : dw_reg[17:12] <= pixel_data; //p2
    4'b0011 : dw_reg[23:18] <= pixel_data; //p3
    4'b0100 : dw_reg[29:24] <= pixel_data; //p4
    4'b0101 : dw_reg[31:30] <= pixel_data[1:0]; //p5
    4'b0110 : dw_reg[9:0]   <= {pixel_data, pixel_data_d1[5:2]}; //p6, p5
    4'b0111 : dw_reg[15:10] <= pixel_data; //p7
    4'b1000 : dw_reg[21:16] <= pixel_data; //p8
    4'b1001 : dw_reg[27:22] <= pixel_data; //p9
    4'b1010 : dw_reg[31:28] <= pixel_data[3:0]; //p10
    4'b1011 : dw_reg[7:0]   <= {pixel_data, pixel_data_d1[5:4]}; // p11, p10
    4'b1100 : dw_reg[13:8]  <= pixel_data; //p12
    4'b1101 : dw_reg[19:14] <= pixel_data; //p13
    4'b1110 : dw_reg[25:20] <= pixel_data; //p14
    4'b1111 : dw_reg[31:26] <= pixel_data; //p15
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
  else if ( ((pixel_cnt == 4'b0101) || (pixel_cnt == 4'b1010) || (pixel_cnt == 4'b1111) ) &&
            pixel_data_vld && raw6_convrn_enable)
   dw_vld_s <= 1'b1;
  else
   dw_vld_s <= 1'b0;
 end
 
 assign dw_vld = ( dw_vld_s || min_rxed_pkt_vld );

endmodule
