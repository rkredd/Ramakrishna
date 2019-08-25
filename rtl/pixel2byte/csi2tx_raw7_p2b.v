/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_raw7_p2b.v
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
module csi2tx_raw7_p2b 
(
 input  wire        clk,
 input  wire        rst_n,
 input  wire [4:0]  pixel_cnt,
 input  wire [6:0]  pixel_data,
 input  wire [6:0]  pixel_data_d1,
 input  wire        pixel_data_vld,
 input  wire        sensor_pixel_vld_falling_edge,
 input  wire        raw7_convrn_enable,
 output wire [31:0] dw,
 output wire        dw_vld
 );
 
 reg  [31:0] dw_reg;
 reg         dw_vld_s;
 wire        min_rxed_pkt_vld;
 
 /*---------------------------------------------------------------------------*/
 // Output valid generation, when the received packet is of 7 pixel
 // count is checked for one extra bcuase of falling edge detection of the vld
 // from the sensor interface
 
 assign min_rxed_pkt_vld = ( raw7_convrn_enable  ? 
                           (( (pixel_cnt != 0) && (sensor_pixel_vld_falling_edge) ) ? 1'b1 : 1'b0 ) 
                           : 1'b0 );
                           
 /*---------------------------------------------------------------------------*/
 // Logic to convert the pixel to dw
 // This is been registerd as this interface is expected to work at around 400Mhz
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0)
   dw_reg <= 32'b0;
  else if (raw7_convrn_enable)
   case(pixel_cnt)
    5'b0_0000 : dw_reg[6:0]   <= pixel_data;
    5'b0_0001 : dw_reg[13:7]  <= pixel_data;
    5'b0_0010 : dw_reg[20:14] <= pixel_data;
    5'b0_0011 : dw_reg[27:21] <= pixel_data;
    5'b0_0100 : dw_reg[31:28] <= pixel_data[3:0];
    5'b0_0101 : dw_reg[9:0]   <= {pixel_data, pixel_data_d1[6:4]};
    5'b0_0110 : dw_reg[16:10] <= pixel_data;
    5'b0_0111 : dw_reg[23:17] <= pixel_data;
    5'b0_1000 : dw_reg[30:24] <= pixel_data;
    5'b0_1001 : dw_reg[31]    <= pixel_data[0];
    5'b0_1010 : dw_reg[12:0]  <= {pixel_data, pixel_data_d1[6:1]};
    5'b0_1011 : dw_reg[19:13] <= pixel_data;
    5'b0_1100 : dw_reg[26:20] <= pixel_data;
    5'b0_1101 : dw_reg[31:27] <= pixel_data[4:0];
    5'b0_1110 : dw_reg[8:0]   <= {pixel_data, pixel_data_d1[6:5]};
    5'b0_1111 : dw_reg[15:9]  <= pixel_data;
    5'b1_0000 : dw_reg[22:16] <= pixel_data;
    5'b1_0001 : dw_reg[29:23] <= pixel_data;
    5'b1_0010 : dw_reg[31:30] <= pixel_data[1:0];
    5'b1_0011 : dw_reg[11:0]  <= {pixel_data,pixel_data_d1[6:2]};
    5'b1_0100 : dw_reg[18:12] <= pixel_data;
    5'b1_0101 : dw_reg[25:19] <= pixel_data;
    5'b1_0110 : dw_reg[31:26] <= pixel_data[5:0];
    5'b1_0111 : dw_reg[7:0]   <= {pixel_data, pixel_data_d1[6]};
    5'b1_1000 : dw_reg[14:8]  <= pixel_data;
    5'b1_1001 : dw_reg[21:15] <= pixel_data;
    5'b1_1010 : dw_reg[28:22] <= pixel_data;
    5'b1_1011 : dw_reg[31:29] <= pixel_data[2:0];
    5'b1_1100 : dw_reg[10:0]  <= {pixel_data, pixel_data_d1[6:3]};
    5'b1_1101 : dw_reg[17:11] <= pixel_data;
    5'b1_1110 : dw_reg[24:18] <= pixel_data;
    5'b1_1111 : dw_reg[31:25] <= pixel_data;
    default   : dw_reg <= 32'b0;    
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
   else if (( (pixel_cnt == 5'b0_0100) || (pixel_cnt == 5'b0_1001) || (pixel_cnt == 5'b0_1101) ||
              (pixel_cnt == 5'b1_0010) || (pixel_cnt == 5'b1_0110) || (pixel_cnt == 5'b1_1011) ||
              (pixel_cnt == 5'b1_1111) ) && pixel_data_vld && raw7_convrn_enable )
    dw_vld_s <= 1'b1;
   else
    dw_vld_s <= 1'b0;              
  end
  
  assign dw_vld = (dw_vld_s || min_rxed_pkt_vld);
endmodule
