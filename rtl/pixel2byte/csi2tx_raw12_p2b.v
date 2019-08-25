/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_raw12_p2b.v
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
module csi2tx_raw12_p2b 
 (
 input  wire         clk,
 input  wire         rst_n,
 input  wire [2:0]   pixel_cnt,
 input  wire [11:0]  pixel_data,
 input  wire         pixel_data_vld,
 input  wire         sensor_pixel_vld_falling_edge,
 input  wire         raw12_convrn_enable,
 output wire [31:0]  dw,
 output wire         dw_vld
 );
 
 reg  [31:0] dw_reg;
 reg         d_min_rxed_pkt_vld;
 reg         dw_vld_s;
 wire        min_rxed_pkt_vld; 
 reg  [7:0]  lsb_pxl_reg;  
 
 /*---------------------------------------------------------------------------*/
 // Output valid generation, when the received packet 4 pixel
 // count is checked for one extra bcuase of falling edge detection of the vld
 // from the sensor interface
 
 assign min_rxed_pkt_vld = ( raw12_convrn_enable  ? 
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
  else if ( (raw12_convrn_enable == 1'b1) && pixel_data_vld )
   case (pixel_cnt[0])
    1'b0 : lsb_pxl_reg[3:0]   <= pixel_data[3:0];
    1'b1 : lsb_pxl_reg[7:4]   <= pixel_data[3:0];
   default : lsb_pxl_reg[7:0] <= 8'b0;
   endcase   
  
 end
 
 /*---------------------------------------------------------------------------*/
 // Logic to convert the pixel to dw
 // This is been registerd as this interface is expected to work at around 400Mhz
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0 )
   dw_reg <= 32'b0;
  else if (raw12_convrn_enable)
   case ( pixel_cnt )
    3'b000 : dw_reg[7:0]  <= pixel_data[11:4]; // p1
    3'b001 : dw_reg[15:8] <= pixel_data[11:4]; // p2
    3'b010 : 
    begin
     dw_reg[23:16] <= lsb_pxl_reg; // p1-2[3:0]
     dw_reg[31:24] <= pixel_data[11:4];  // p3
    end
    3'b011 : dw_reg[7:0] <= pixel_data[11:4]; // p4
    3'b100 : 
    begin
     dw_reg[15:8]  <= lsb_pxl_reg; // p3-4[3:0]
     dw_reg[23:16] <= pixel_data[11:4]; // p5
    end
    3'b101 : dw_reg[31:24] <= pixel_data[11:4]; // p6
    3'b110 : 
    begin
     dw_reg[7:0]  <= lsb_pxl_reg; // p5-6[3:0]
     dw_reg[15:8] <= pixel_data[11:4]; // p7
    end
    3'b111 :
    begin
     dw_reg[23:16] <= pixel_data[11:4]; // p8
     dw_reg[27:24] <= lsb_pxl_reg[3:0]; // p7[3:0]
     dw_reg[31:28] <= pixel_data[3:0];  // p8[3:0]     
    end
   endcase
 end
 
 assign dw = dw_reg;
 
 // As the data valid is registered version, check the count one clock before
  always@(posedge clk or negedge rst_n)
  begin
   if ( rst_n == 1'b0 )
    dw_vld_s <= 1'b0;
   else if (( (pixel_cnt == 3'b010) || (pixel_cnt == 3'b101) || 
              (pixel_cnt == 3'b111)) && pixel_data_vld && raw12_convrn_enable )
    dw_vld_s <= 1'b1;
   else
    dw_vld_s <= 1'b0;              
  end 
  
  assign dw_vld = dw_vld_s | d_min_rxed_pkt_vld;
 
endmodule
