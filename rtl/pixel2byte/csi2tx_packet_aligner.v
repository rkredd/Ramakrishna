/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_packet_aligner.v
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
module csi2tx_packet_aligner 
(
 input  wire        clk_csi                                 ,
 input  wire        clk_csi_rst_n                           ,
 input  wire        tinit_start_clk_csi                     ,
 input  wire        forcetxstopmode                         ,
 input  wire [31:0] header_info                             , 
 input  wire        header_info_valid                       , 
 input  wire [31:0] byte_data                               ,
 input  wire        byte_data_valid                         ,
 output wire [63:0] pixel_data64                            ,
 output wire        pixel_data64_valid                      ,
 output wire        packet_incr_pulse 
); 

wire rcvd_short_packet_c;
wire long_pkt_hdr_rcvd_c;
reg [63:0] pixel_data64_r;
reg [63:0] pixel_data64_d;
reg        pixel_data64_valid_r;
wire       eop_c;
reg        rcvd_short_packet_d;
reg [15:0] packet_size_r;
reg [16:0] packet_size_wr_r;
reg [1:0]  cur_state;
wire       eop_wr_c;
reg        eop_wr_c_d;
wire       packet_incr_pulse_c;
parameter IDLE                   = 2'b00;
parameter VALIDATE_HDR_PLUS_DATA = 2'b01;
parameter CAPTURE_ODD_DATA       = 2'b10;
parameter CAPTURE_EVEN_DATA      = 2'b11;

//------------------------------------------------------------------------------
// Detecte whether the received packet is short packet header or long packet
// header, if it is a short packet forward as it othwise convert the received
// 32-bit data to 64-bit before forwarding
assign rcvd_short_packet_c = ((header_info[25:24] == 2'b01) && (header_info_valid == 1'b1)) ? 1'b1 : 1'b0;
assign long_pkt_hdr_rcvd_c = ((header_info[25:24] == 2'b10) && (header_info_valid == 1'b1)) ? 1'b1 : 1'b0;

//------------------------------------------------------------------------------
//
assign eop_c = ((packet_size_r <= 16'h4) && (byte_data_valid == 1'b1));

//------------------------------------------------------------------------------
//
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
  if (clk_csi_rst_n == 1'b0)
   rcvd_short_packet_d <= 1'b0;
  else
   rcvd_short_packet_d <= rcvd_short_packet_c;
end

//------------------------------------------------------------------------------
//
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
  if (clk_csi_rst_n == 1'b0)
    packet_size_r <= 16'b0;
  else if (forcetxstopmode == 1'b1)
    packet_size_r <= 16'b0;    
  else if (long_pkt_hdr_rcvd_c == 1'b1)
    packet_size_r <= header_info[23:8];
  else if (byte_data_valid == 1'b1)
    if (packet_size_r <= 16'h4)
      packet_size_r <= packet_size_r;
    else
      packet_size_r <= packet_size_r - 4'b0100;
end

//-----------------------------------------------------------------------------
// This packet size is used to generate the EOF. This signal is used by the
// packet reader to update the internal counter. This is to make sure that
// packet counter will get updated only after complete packet is been written
// to buffer. To confirm the same the falling edge detection is performed
// This will come handy when the Sensor clock is very LOW compared to byte
// clock frequency
// BUGZILLA BUG ID : 1932
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
  if (clk_csi_rst_n == 1'b0)
    packet_size_wr_r <= 17'b0;
  else if (forcetxstopmode == 1'b1)
    packet_size_wr_r <= 17'b0;
  else if (long_pkt_hdr_rcvd_c == 1'b1)
    packet_size_wr_r <= header_info[23:8] + 16'h4; // Header
  else if (pixel_data64_valid_r == 1'b1)
    if (packet_size_wr_r <= 17'h8)
      packet_size_wr_r <= 17'b0;
    else
      packet_size_wr_r <= packet_size_wr_r - 16'h8;
end

assign eop_wr_c = ((packet_size_wr_r <= 17'h8) && (pixel_data64_valid_r == 1'b1)) ? 1'b1 : 1'b0;

always@(posedge clk_csi or negedge clk_csi_rst_n) begin
  if (clk_csi_rst_n == 1'b0)
    eop_wr_c_d <= 1'b0;
  else
    eop_wr_c_d <= eop_wr_c;
end

assign packet_incr_pulse_c = (~eop_wr_c) & eop_wr_c_d;


//------------------------------------------------------------------------------
//
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
  if (clk_csi_rst_n == 1'b0)
    cur_state <= IDLE;
  else if (forcetxstopmode == 1'b1)
    cur_state <= IDLE;    
  else
    case (cur_state)
      IDLE : begin
        if (long_pkt_hdr_rcvd_c == 1'b1)
          cur_state <= VALIDATE_HDR_PLUS_DATA;
        else
          cur_state <= IDLE;
      end
      VALIDATE_HDR_PLUS_DATA : begin
        if (eop_c == 1'b1)
          cur_state <= IDLE;
        else if (byte_data_valid == 1'b1)
          cur_state <= CAPTURE_ODD_DATA;
        else
          cur_state <= VALIDATE_HDR_PLUS_DATA;
      end
      CAPTURE_ODD_DATA : begin
        if ((eop_c == 1'b1))
          cur_state <= IDLE;
        else if (byte_data_valid == 1'b1)
          cur_state <= CAPTURE_EVEN_DATA;
        else
          cur_state <= CAPTURE_ODD_DATA;
      end
      CAPTURE_EVEN_DATA : begin
        if ((eop_c == 1'b1))
          cur_state <= IDLE;
        else if (byte_data_valid == 1'b1)
          cur_state <= CAPTURE_ODD_DATA;
        else
          cur_state <= CAPTURE_EVEN_DATA;
       end
    endcase
end

//------------------------------------------------------------------------------
//
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
  if (clk_csi_rst_n == 1'b0)
  pixel_data64_r <= 64'b0;
 else if (tinit_start_clk_csi == 1'b0)
  pixel_data64_r <=64'b0;
 else if (rcvd_short_packet_c == 1'b1)
  pixel_data64_r <= {32'b0, header_info};
 else if ((long_pkt_hdr_rcvd_c == 1'b1) && (cur_state == IDLE))
  pixel_data64_r <= {32'b0, header_info};
 else if ((byte_data_valid == 1'b1) && (cur_state == VALIDATE_HDR_PLUS_DATA))
  pixel_data64_r <= {byte_data, pixel_data64_r[31:0]};
 else if ((byte_data_valid == 1'b1) && (cur_state == CAPTURE_ODD_DATA)) 
  pixel_data64_r <= {32'b0, byte_data};
 else if ((byte_data_valid == 1'b1) && (cur_state == CAPTURE_EVEN_DATA)) 
  pixel_data64_r <= {byte_data, pixel_data64_r[31:0]};
end

always@(posedge clk_csi or negedge clk_csi_rst_n) begin
  if (clk_csi_rst_n == 1'b0)
    pixel_data64_d <= 64'b0;
  else
    pixel_data64_d <= pixel_data64;
end

//------------------------------------------------------------------------------
//Valid generation for the 64-bit data
// There should be minimum of 2-clock between each packet request
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
  if (clk_csi_rst_n == 1'b0)
    pixel_data64_valid_r <= 1'b0;
  else if (forcetxstopmode == 1'b1)
    pixel_data64_valid_r <= 1'b0;    
  else
    case (cur_state)
      IDLE : begin
        if (long_pkt_hdr_rcvd_c == 1'b1)
          pixel_data64_valid_r <= 1'b0;
        else
          pixel_data64_valid_r <= 1'b0;
      end
      VALIDATE_HDR_PLUS_DATA : begin
        if (eop_c == 1'b1)
          pixel_data64_valid_r <= 1'b1;
        else if (byte_data_valid == 1'b1)
          pixel_data64_valid_r <= 1'b1;
        else
          pixel_data64_valid_r <= 1'b0;
      end
      CAPTURE_ODD_DATA : begin
        if ((eop_c == 1'b1))
          pixel_data64_valid_r <= 1'b1;
        else if (byte_data_valid == 1'b1)
          pixel_data64_valid_r <= 1'b0;
        else
          pixel_data64_valid_r <= 1'b0;
      end
      CAPTURE_EVEN_DATA : begin
        if ((eop_c == 1'b1))
          pixel_data64_valid_r <= 1'b1;
        else if (byte_data_valid == 1'b1)
          pixel_data64_valid_r <= 1'b1;
        else
          pixel_data64_valid_r <= 1'b0;
       end
    endcase
end


//------------------------------------------------------------------------------
//output assignment
assign pixel_data64 = (pixel_data64_valid == 1'b1) ? pixel_data64_r : pixel_data64_d;
assign pixel_data64_valid = pixel_data64_valid_r | rcvd_short_packet_d; 
assign packet_incr_pulse  = packet_incr_pulse_c;
                    
endmodule
