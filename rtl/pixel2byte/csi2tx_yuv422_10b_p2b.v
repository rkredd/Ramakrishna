/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_yuv422_10b_p2b.v
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
module csi2tx_yuv422_10b_p2b 
 (
 input  wire         clk,
 input  wire         rst_n,
 input  wire [2:0]   pixel_cnt,
 input  wire [31:0]  pixel_data,
 input  wire [31:0]  pixel_data_d1,
 input  wire         pixel_data_vld,
 input  wire         sensor_pixel_vld_falling_edge,
 input  wire         yuv422_10b_convrn_enable,
 output wire [31:0]  dw,
 output wire         dw_vld
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
 
 assign min_rxed_pkt_vld = ( yuv422_10b_convrn_enable  ? 
                           ((( pixel_cnt[2:0] != 0  ) && sensor_pixel_vld_falling_edge ) ? 1'b1 : 1'b0 ) 
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
  else if ( (yuv422_10b_convrn_enable == 1'b1) && pixel_data_vld)  
   case (pixel_cnt[1:0])
    2'b00 : 
    begin
     lsb_pxl_reg[1:0]   <= pixel_data[11:10];
     lsb_pxl_reg[3:2]   <= pixel_data[21:20];
     lsb_pxl_reg[5:4]   <= pixel_data[1:0];
    end
    2'b01 : lsb_pxl_reg[7:6]   <= pixel_data[21:20];
    2'b10 : 
    begin
     lsb_pxl_reg[1:0]   <= pixel_data[11:10];
     lsb_pxl_reg[3:2]   <= pixel_data[21:20];
     lsb_pxl_reg[5:4]   <= pixel_data[1:0];
    end
    2'b11 : lsb_pxl_reg[7:6]   <= pixel_data[21:20];
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
  else if (yuv422_10b_convrn_enable == 1'b1) // even
   case(pixel_cnt[2:0])
    3'b000 : begin
     dw_reg[7:0] <= pixel_data[19:12];
     dw_reg[15:8] <= pixel_data[29:22];
     dw_reg[23:16] <= pixel_data[9:2];
    end 
    3'b001 : dw_reg[31:24] <= pixel_data[29:22];
    3'b010 : begin
     dw_reg[7:0] <= lsb_pxl_reg;
     dw_reg[15:8] <= pixel_data[19:12];
     dw_reg[23:16] <= pixel_data[29:22];
     dw_reg[31:24] <= pixel_data[9:2];
    end
    3'b011 : begin
     dw_reg[7:0] <= pixel_data[29:22];
    end
    3'b100 : begin
     dw_reg[15:8] <=  lsb_pxl_reg;
     dw_reg[23:16] <= pixel_data[19:12];
     dw_reg[31:24] <= pixel_data[29:22];
    end
    3'b101 : begin
     dw_reg[7:0] <= pixel_data_d1[9:2];
     dw_reg[15:8] <= pixel_data[29:22];
    end
    3'b110 : begin
     dw_reg[23:16] <= lsb_pxl_reg;
     dw_reg[31:24] <= pixel_data[19:12];
    end
    3'b111 : begin
     dw_reg[7:0] <= pixel_data_d1[29:22];
     dw_reg[15:8] <= pixel_data_d1[9:2];
     dw_reg[23:16] <= pixel_data[29:22];
     dw_reg[29:24] <= lsb_pxl_reg[5:0];
     dw_reg[31:30] <= pixel_data[21:20];
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
   else if ( ((pixel_cnt[2:0] == 3'b001) || (pixel_cnt[2:0] == 3'b010) || (pixel_cnt[2:0] == 3'b100)
   || (pixel_cnt[2:0] == 3'b110) || (pixel_cnt[2:0] == 3'b111)) && (pixel_data_vld) && (yuv422_10b_convrn_enable) )
    dw_vld_s <= 1'b1;
   else
    dw_vld_s <= 1'b0;              
  end
  
  assign dw_vld = (dw_vld_s || d_min_rxed_pkt_vld);
 
endmodule
