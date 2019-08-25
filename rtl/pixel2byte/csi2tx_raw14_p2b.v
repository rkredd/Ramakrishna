/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_raw14_p2b.v
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
module csi2tx_raw14_p2b 
 (
 input  wire         clk,
 input  wire         rst_n,
 input  wire [3:0]   pixel_cnt,
 input  wire [13:0]  pixel_data,
 input  wire         pixel_data_vld,
 input  wire         sensor_pixel_vld_falling_edge,
 input  wire         raw14_convrn_enable,
 output wire [31:0]  dw,
 output wire         dw_vld
 );
 
 reg  [31:0] dw_reg;
 reg         dw_vld_s;
 wire        min_rxed_pkt_vld; 
 reg         d_min_rxed_pkt_vld; 
 reg  [23:0]  lsb_pxl_reg;  
  /*---------------------------------------------------------------------------*/
 // Output valid generation, when the received packet 4 pixel
 // count is checked for one extra bcuase of falling edge detection of the vld
 // from the sensor interface
 assign min_rxed_pkt_vld = ( raw14_convrn_enable  ? 
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
 /* LSB bits capture */
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0 )
   lsb_pxl_reg <= 24'b0;
  else if ( raw14_convrn_enable && pixel_data_vld)
   case ( pixel_cnt[1:0] )
        2'b00 : lsb_pxl_reg[5:0]   <= pixel_data[5:0];
        2'b01 : lsb_pxl_reg[11:6]  <= pixel_data[5:0];
        2'b10 : lsb_pxl_reg[17:12] <= pixel_data[5:0];
        2'b11 : lsb_pxl_reg[23:18] <= pixel_data[5:0];
        default : lsb_pxl_reg[23:0] <= 24'b0;
    endcase
 end
 
 /*---------------------------------------------------------------------------*/
 // Logic to convert the pixel to dw
 // This is been registerd as this interface is expected to work at around 400Mhz
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0)
   dw_reg <= 32'b0;
  else if ( raw14_convrn_enable )
   case (pixel_cnt)
    4'b0000 : dw_reg[7:0]   <= pixel_data[13:6]; // p0
    4'b0001 : dw_reg[15:8]  <= pixel_data[13:6]; // p1
    4'b0010 : dw_reg[23:16] <= pixel_data[13:6]; // p2
    4'b0011 : dw_reg[31:24] <= pixel_data[13:6]; // p3
    4'b0100 : 
    begin
     dw_reg[23:0] <= lsb_pxl_reg;  // lsb of p1,p2,p3, p4[5:0]
     dw_reg[31:24] <= pixel_data[13:6]; // p4
    end 
    4'b0101 : dw_reg[7:0]   <= pixel_data[13:6]; // p5
    4'b0110 : dw_reg[15:8]  <= pixel_data[13:6]; // p6
    4'b0111 : 
    begin
    dw_reg[23:16] <= pixel_data[13:6]; // p7
    dw_reg[31:24] <= lsb_pxl_reg[7:0];
    end
    4'b1000 :
    begin
     dw_reg[15:0]  <= lsb_pxl_reg[23:8];
     dw_reg[23:16] <= pixel_data[13:6]; // p8
    end
    4'b1001 : dw_reg[31:24] <= pixel_data[13:6];    // p9
    4'b1010 : dw_reg[7:0] <= pixel_data[13:6]; // p10
    4'b1011 : 
    begin
    dw_reg[15:8] <= pixel_data[13:6]; // p11
    dw_reg[31:16] <= lsb_pxl_reg[15:0];
    end
    4'b1100 : 
    begin
     dw_reg[7:0]   <= lsb_pxl_reg[23:16];
     dw_reg[15:8]  <= pixel_data[13:6]; // p12
    end
    4'b1101 : dw_reg[23:16] <= pixel_data[13:6]; // p13
    4'b1110 : dw_reg[31:24] <= pixel_data[13:6]; // p14
    4'b1111 :
    begin
     dw_reg[7:0]   <= pixel_data[13:6]; // p15
     dw_reg[25:8]  <= lsb_pxl_reg[17:0];
     dw_reg[31:26] <= pixel_data[5:0]; // p15
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
   else if (( (pixel_cnt == 4'b0011) || (pixel_cnt == 4'b0100) || (pixel_cnt == 4'b0111) || 
              (pixel_cnt == 4'b1001) || (pixel_cnt == 4'b1011) || (pixel_cnt == 4'b1110) || 
              (pixel_cnt == 4'b1111)) && pixel_data_vld && raw14_convrn_enable)
    dw_vld_s <= 1'b1;
   else
    dw_vld_s <= 1'b0;              
  end 
  assign dw_vld = (dw_vld_s || d_min_rxed_pkt_vld);
  
endmodule
