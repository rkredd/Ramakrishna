/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_raw10_p2b.v
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
module csi2tx_raw10_p2b 
 (
 input  wire        clk,
 input  wire        rst_n,
 input  wire [3:0]  pixel_cnt,
 input  wire [9:0]  pixel_data,
 input  wire        pixel_data_vld,
 input  wire        sensor_pixel_vld_falling_edge,
 input  wire        raw10_convrn_enable,
 output wire [31:0] dw,
 output wire        dw_vld
 );
 
 reg  [31:0] dw_reg;
 reg         dw_vld_s;
 wire        min_rxed_pkt_vld; 
 reg  [7:0]  lsb_pxl_reg;         
 reg         d_min_rxed_pkt_vld; 
 
 /*---------------------------------------------------------------------------*/
 // Output valid generation, when the received packet 4 pixel
 // count is checked for one extra bcuase of falling edge detection of the vld
 // from the sensor interface
 
 assign min_rxed_pkt_vld = ( raw10_convrn_enable  ? 
                           ((( pixel_cnt != 0  ) && sensor_pixel_vld_falling_edge ) ? 1'b1 : 1'b0 ) 
                           : 1'b0 );
 // This section is a must, otherwise the min and actual will overlap
 always@(posedge clk or negedge rst_n)
  begin
   if ( rst_n == 1'b0 )
    d_min_rxed_pkt_vld <= 1'b0;
   else
    d_min_rxed_pkt_vld <= min_rxed_pkt_vld;
  end
                           
 /*---------------------------------------------------------------------------*/
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0)
   lsb_pxl_reg <= 8'b0;
  else if ( (raw10_convrn_enable == 1'b1) && pixel_data_vld )
   case (pixel_cnt[1:0])
    2'b00 : lsb_pxl_reg[1:0]   <= pixel_data[1:0];
    2'b01 : lsb_pxl_reg[3:2]   <= pixel_data[1:0];
    2'b10 : lsb_pxl_reg[5:4]   <= pixel_data[1:0];
    2'b11 : lsb_pxl_reg[7:6]   <= pixel_data[1:0];
    default : lsb_pxl_reg[7:0] <= 8'b0;
   endcase   

 end
                           
 /*---------------------------------------------------------------------------*/
 // Logic to convert the pixel to dw
 // This is been registerd as this interface is expected to work at around 400Mhz
 always@(posedge clk or negedge rst_n)
 begin
  if (rst_n == 1'b0)
   dw_reg <= 32'b0;
  else if (raw10_convrn_enable)
   case(pixel_cnt)
    4'b0000 : dw_reg[7:0]   <= pixel_data[9:2];   // p1[9:2]
    4'b0001 : dw_reg[15:8]  <= pixel_data[9:2];   // p2[9:2]
    4'b0010 : dw_reg[23:16] <= pixel_data[9:2];   // p3[9:2]
    4'b0011 : dw_reg[31:24] <= pixel_data[9:2];   // p4[9:2]  // one wr
    4'b0100 : 
    begin
     dw_reg[7:0]   <= lsb_pxl_reg;   // p4, p3, p2 , p1 [1:0]
     dw_reg[15:8]  <= pixel_data[9:2];    // p5[9:2]
    end
    4'b0101 : dw_reg[23:16]  <= pixel_data[9:2];   // p6[9:2] 
    4'b0110 : dw_reg[31:24]  <= pixel_data[9:2];   // p7[9:2] // one wr
    4'b0111 : dw_reg[7:0]    <= pixel_data[9:2];   // p8[9:2]
    4'b1000 : 
    begin
     dw_reg[15:8]  <= lsb_pxl_reg; // p8, p7, p6, p5 [1:0]
     dw_reg[23:16] <= pixel_data[9:2];  // p9[9:2]
    end
    4'b1001 : dw_reg[31:24]  <= pixel_data[9:2];  // p10[9:2] // one_wr
    4'b1010 : dw_reg[7:0]    <= pixel_data[9:2];  // p11[9:2]
    4'b1011 : dw_reg[15:8]   <= pixel_data[9:2];  // p12[9:2]
    4'b1100 : 
    begin
     dw_reg[23:16] <= lsb_pxl_reg; // p12,11,10,9 [1:0]
     dw_reg[31:24] <= pixel_data[9:2];  // p13[9:2] //one_wr
    end
    4'b1101 : dw_reg[7:0]  <= pixel_data[9:2]; // p14[9:2]
    4'b1110 : dw_reg[15:8] <= pixel_data[9:2]; // p15
    4'b1111 :
    begin
     dw_reg[23:16] <= pixel_data[9:2];
     dw_reg[29:24] <= lsb_pxl_reg[5:0];
     dw_reg[31:30] <= pixel_data[1:0];
    end
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
   else if (( (pixel_cnt == 4'b0011) || (pixel_cnt == 4'b0110) || 
              (pixel_cnt == 4'b1001) || (pixel_cnt == 4'b1100) || 
              (pixel_cnt == 4'b1111)) && pixel_data_vld && raw10_convrn_enable)
    dw_vld_s <= 1'b1;
   else
    dw_vld_s <= 1'b0;              
  end
  
  assign dw_vld = dw_vld_s | d_min_rxed_pkt_vld;
endmodule
