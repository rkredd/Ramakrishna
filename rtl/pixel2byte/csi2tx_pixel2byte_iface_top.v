/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_pixel2byte_iface_top.v
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
module csi2tx_pixel2byte_iface_top 
(
 input  wire        clk_csi                                ,  
 input  wire        clk_csi_rst_n                          ,
 input  wire        tinit_start_clk_csi                    ,  
 input  wire        forcetxstopmode                        ,
 input  wire [31:0] image_data                             ,  
 input  wire        image_data_valid                       ,  
 input  wire [31:0] image_data_delayed                     ,  
 input  wire [4:0]  pixel_cnt                              ,  
 input  wire        sensor_pixel_vld_falling_edge          ,
 input  wire [31:0] header_info                            ,  
 input  wire        header_info_valid                      ,
 input  wire        orig_image_data_valid                  ,  
 input  wire [31:0] p2b_enable                             ,  
 input  wire [4:0]  p2b_data_sel                           ,  
 input  wire [4:0]  comp_scheme                            ,  
 input  wire        comp_en                                ,  
 input  wire        lyuv4208b_odd_even_convrn_enable       ,  
 input  wire        yuv4208b_csps_odd_even_convrn_enable   ,  
 input  wire        yuv420_10b_csps_odd_even_convrn_enable ,  
 input  wire        yuv4208b_odd_even_convrn_enable        ,  
 input  wire        yuv420_10b_odd_even_convrn_enable      ,  
 output wire [63:0] pixel_data64                           ,  
 output wire        pixel_data64_valid                     ,
 output wire        packet_incr_pulse
 ); 
 
 // [0] --> Null Packet
 // [1] --> Blanking data
 // [2] --> Embedded 8-bit non image data
 // [3] --> YUV420 8-bit
 // [4] --> YUV420 10-bit
 // [5] --> Legacy YUV420 8-bit
 // [6] --> YUV420 8-bit(Chroma shifted)
 // [7] --> YUV420 10-bit(Chroma shifted)
 // [8] --> YUV422 8-bit
 // [9] --> YUV422 10-bit
 // [10] --> RGB444
 // [11] --> RGB555
 // [12] --> RGB565
 // [13] --> RGB666
 // [14] --> RGB888
 // [15] --> RAW6
 // [16] --> RAW7
 // [17] --> RAW8
 // [18] --> RAW10
 // [19] --> RAW12
 // [20] --> RAW14
 // [21] --> USD TYPE-1
 // [22] --> USD TYPE-2
 // [23] --> USD TYPE-3
 // [24] --> USD TYPE-4
 // [25] --> USD TYPE-5
 // [26] --> USD TYPE-6
 // [27] --> USD TYPE-7
 // [28] --> USD TYPE-8
 // [31:29] --> RESERVED

//------------------------------------------------------------------------------
// Internal wire declaration
wire [31:0] dw_yuv420_8b_w               ;
wire [31:0] dw_yuv420_10b_w              ;
wire [31:0] dw_lyuv420_8b_w              ;
wire [31:0] dw_yuv422_8b_w               ;
wire [31:0] dw_yuv422_10b_w              ;
wire [31:0] dw_rgb565_w                  ;
wire [31:0] dw_rgb666_w                  ;
wire [31:0] dw_rgb888_w                  ;
wire [31:0] dw_raw6_w                    ;
wire [31:0] dw_raw7_w                    ;
wire [31:0] dw_raw8_w                    ;
wire [31:0] dw_raw10_w                   ;
wire [31:0] dw_raw12_w                   ;
wire [31:0] dw_raw14_w                   ;
wire        yuv420_8b_enable_c           ;
wire        yuv420_8b_odd_even_enable_c  ;
wire        yuv420_10b_enable_c          ;
wire        yuv420_10b_odd_even_enable_c ;
reg         raw8_p2b_enable_s            ;
reg         raw7_p2b_enable_s            ;
reg         raw6_p2b_enable_s            ;
wire        pixel2byte_enable_c          ;
wire [7:0]  raw_data_c                   ;
wire [7:0]  raw_data_delayed_c           ;
reg  [31:0] byte_data_r                  ;
reg         byte_data_valid_r            ;
wire [7:0]  enc_data                     ;
wire [7:0]  enc_data_delayed             ;
wire        dw_raw6_valid_w              ;
wire        dw_raw7_valid_w              ;
wire        dw_raw8_valid_w              ;
wire        dw_raw10_valid_w             ;
wire        dw_raw12_valid_w             ;
wire        dw_raw14_valid_w             ;
wire        dw_rgb565_valid_w            ;
wire        dw_rgb666_valid_w            ;
wire        dw_rgb888_valid_w            ;
wire        dw_lyuv420_8b_valid_w        ;
wire        dw_yuv420_10b_valid_w        ;
wire        dw_yuv422_10b_valid_w        ;
wire        dw_yuv420_8b_valid_w         ;
wire        dw_yuv422_8b_valid_w         ; 

 
//------------------------------------------------------------------------------
// As YUV420 8B/CSPS are of same packing OR the enable signal and use the common
// packing module
assign yuv420_8b_enable_c          = p2b_enable[3] | p2b_enable[6]; 
assign yuv420_8b_odd_even_enable_c = (p2b_enable[6] == 1'b1) ? yuv4208b_csps_odd_even_convrn_enable : yuv4208b_odd_even_convrn_enable;

assign yuv420_10b_enable_c          = p2b_enable[4] | p2b_enable[7]; 
assign yuv420_10b_odd_even_enable_c = (p2b_enable[7] == 1'b1) ? yuv420_10b_csps_odd_even_convrn_enable : yuv420_10b_odd_even_convrn_enable;

//------------------------------------------------------------------------------
// Selection betweem RAW8 and when the compression is enable
// When 8bit compression is enabled select the raw8
always@(*) begin
 if ((comp_en == 1'b1) && ((comp_scheme[2:0] == 3'b011) || (comp_scheme[2:0] == 3'b110)))
  raw8_p2b_enable_s = 1'b1;
 else
  raw8_p2b_enable_s = p2b_enable[17];
end

//------------------------------------------------------------------------------
// Selection betweem RAW7 and when the compression is enable
// When 7bit compression is enabled select the raw8
always@(*) begin
 if ((comp_en == 1'b1) && ((comp_scheme[2:0] == 3'b010) || (comp_scheme[2:0] == 3'b101)))
  raw7_p2b_enable_s = 1'b1;
 else
  raw7_p2b_enable_s = p2b_enable[16];
end

//------------------------------------------------------------------------------
// Selection betweem RAW6 and when the compression is enable
// When 6bit compression is enabled select the raw8
always@(*) begin
 if ((comp_en == 1'b1) && ((comp_scheme[2:0] == 3'b001) || (comp_scheme[2:0] == 3'b100)))
  raw6_p2b_enable_s = 1'b1;
 else
  raw6_p2b_enable_s = p2b_enable[15];
end

//8-bit align pixel packing enable
assign pixel2byte_enable_c = (((raw8_p2b_enable_s | p2b_enable[2] | p2b_enable[1] | p2b_enable[0])) | (( (~comp_en) & (|p2b_enable[28:21]))));
                            
//------------------------------------------------------------------------------
// Input RAW data as either ecoded data or without encoded data based on the
// slection
assign raw_data_c         = (comp_en == 1'b1) ? enc_data : image_data[7:0];
assign raw_data_delayed_c = (comp_en == 1'b1) ? enc_data_delayed : image_data_delayed[7:0];
 
//------------------------------------------------------------------------------
// RAW-6 component instantiation
csi2tx_raw6_p2b 
 u_csi2tx_raw6_p2b
 (                                                     
  .clk                             ( clk_csi                         ),
  .rst_n                           ( clk_csi_rst_n                   ),
  .pixel_cnt                       ( pixel_cnt[3:0]                  ),
  .pixel_data                      ( raw_data_c[5:0]                 ),
  .pixel_data_d1                   ( raw_data_delayed_c[5:0]         ),
  .pixel_data_vld                  ( image_data_valid                ),
  .sensor_pixel_vld_falling_edge   ( sensor_pixel_vld_falling_edge   ),
  .raw6_convrn_enable              ( raw6_p2b_enable_s               ),
  .dw                              ( dw_raw6_w                       ),
  .dw_vld                          ( dw_raw6_valid_w                 )
  );
  
//------------------------------------------------------------------------------
// RAW-7 component instantiation  
csi2tx_raw7_p2b 
 u_csi2tx_raw7_p2b
(
 .clk                              ( clk_csi                         ),
 .rst_n                            ( clk_csi_rst_n                   ),
 .pixel_cnt                        ( pixel_cnt[4:0]                  ),
 .pixel_data                       ( raw_data_c[6:0]                 ),
 .pixel_data_d1                    ( raw_data_delayed_c[6:0]         ),
 .pixel_data_vld                   ( image_data_valid                ),
 .sensor_pixel_vld_falling_edge    ( sensor_pixel_vld_falling_edge   ),
 .raw7_convrn_enable               ( raw7_p2b_enable_s               ),
 .dw                               ( dw_raw7_w                       ),
 .dw_vld                           ( dw_raw7_valid_w                 )
 );
 
//------------------------------------------------------------------------------
// RAW-8 component instantiation 
csi2tx_raw8_p2b
 u_csi2tx_raw8_p2b
 (
 .clk                              ( clk_csi                         ),
 .rst_n                            ( clk_csi_rst_n                   ),
 .pixel_cnt                        ( pixel_cnt[1:0]                  ),
 .pixel_data                       ( raw_data_c[7:0]                 ),
 .pixel_data_vld                   ( image_data_valid                ),
 .sensor_pixel_vld_falling_edge    ( sensor_pixel_vld_falling_edge   ),
 .raw8_convrn_enable               ( pixel2byte_enable_c             ),
 .dw                               ( dw_raw8_w                       ),
 .dw_vld                           ( dw_raw8_valid_w                 )
 ); 
 
//------------------------------------------------------------------------------
// RAW-10 component instantiation 
csi2tx_raw10_p2b
 u_csi2tx_raw10_p2b 
 (                                                     
 .clk                              ( clk_csi                         ),
 .rst_n                            ( clk_csi_rst_n                   ),
 .pixel_cnt                        ( pixel_cnt[3:0]                  ),
 .pixel_data                       ( image_data[9:0]                 ),
 .pixel_data_vld                   ( image_data_valid                ),
 .sensor_pixel_vld_falling_edge    ( sensor_pixel_vld_falling_edge   ),
 .raw10_convrn_enable              ( p2b_enable[18]                  ),
 .dw                               ( dw_raw10_w                      ),
 .dw_vld                           ( dw_raw10_valid_w                )
 );
 
//------------------------------------------------------------------------------
// RAW-12 component instantiation 
csi2tx_raw12_p2b 
 u_csi2tx_raw12_p2b
 (
 .clk                              ( clk_csi                         ),
 .rst_n                            ( clk_csi_rst_n                   ),
 .pixel_cnt                        ( pixel_cnt[2:0]                  ),
 .pixel_data                       ( image_data[11:0]                ),
 .pixel_data_vld                   ( image_data_valid                ),
 .sensor_pixel_vld_falling_edge    ( sensor_pixel_vld_falling_edge   ),
 .raw12_convrn_enable              ( p2b_enable[19]                  ),
 .dw                               ( dw_raw12_w                      ),
 .dw_vld                           ( dw_raw12_valid_w                )
 );
 
//------------------------------------------------------------------------------
// RAW14 pixel to DW component instantiation
csi2tx_raw14_p2b
 u_csi2tx_raw14_p2b
 (
 .clk                              ( clk_csi                         ),
 .rst_n                            ( clk_csi_rst_n                   ),
 .pixel_cnt                        ( pixel_cnt[3:0]                  ),
 .pixel_data                       ( image_data[13:0]                ),
 .pixel_data_vld                   ( image_data_valid                ),
 .sensor_pixel_vld_falling_edge    ( sensor_pixel_vld_falling_edge   ),
 .raw14_convrn_enable              ( p2b_enable[20]                  ),
 .dw                               ( dw_raw14_w                      ),
 .dw_vld                           ( dw_raw14_valid_w                )
 );
 
//------------------------------------------------------------------------------
// RGB565 component instantiation 
csi2tx_rgb565_p2b
 u_csi2tx_rgb565_p2b
 (
 .clk                              ( clk_csi                         ),
 .rst_n                            ( clk_csi_rst_n                   ),
 .pixel_cnt                        ( pixel_cnt[1:0]                  ),
 .pixel_data                       ( image_data[15:0]                ),
 .pixel_data_vld                   ( image_data_valid                ),
 .sensor_pixel_vld_falling_edge    ( sensor_pixel_vld_falling_edge   ),
 .rgb565_convrn_enable             ( p2b_enable[12]                  ),
 .rgb555_convrn_enable             ( p2b_enable[11]                  ),
 .rgb444_convrn_enable             ( p2b_enable[10]                  ),
 .dw                               ( dw_rgb565_w                     ),
 .dw_vld                           ( dw_rgb565_valid_w               )
 );   

//------------------------------------------------------------------------------
// RGB666 component instantiation
csi2tx_rgb666_p2b 
 u_csi2tx_rgb666_p2b
 (
 .clk                              ( clk_csi                          ),
 .rst_n                            ( clk_csi_rst_n                    ),
 .pixel_cnt                        ( pixel_cnt[3:0]                   ),
 .pixel_data                       ( image_data[17:0]                 ),
 .pixel_data_d1                    ( image_data_delayed[17:0]         ),
 .pixel_data_vld                   ( image_data_valid                 ),
 .sensor_pixel_vld_falling_edge    ( sensor_pixel_vld_falling_edge    ),
 .rgb666_convrn_enable             ( p2b_enable[13]                   ),
 .dw                               ( dw_rgb666_w                      ),
 .dw_vld                           ( dw_rgb666_valid_w                )
 );

//------------------------------------------------------------------------------
// RGB888 component instantiation
csi2tx_rgb888_p2b 
 u_csi2tx_rgb888_p2b
(
 .clk                              ( clk_csi                          ),
 .rst_n                            ( clk_csi_rst_n                    ),
 .pixel_cnt                        ( pixel_cnt[1:0]                   ),
 .pixel_data                       ( image_data[23:0]                 ),
 .pixel_data_d1                    ( image_data_delayed[23:0]         ),
 .pixel_data_vld                   ( image_data_valid                 ),
 .sensor_pixel_vld_falling_edge    ( sensor_pixel_vld_falling_edge    ),
 .rgb888_convrn_enable             ( p2b_enable[14]                   ),
 .dw                               ( dw_rgb888_w                      ),
 .dw_vld                           ( dw_rgb888_valid_w                )
 );

//------------------------------------------------------------------------------
// LYUV420-8b component instantiation
csi2tx_lyuv4208b_p2b
 u_csi2tx_lyuv4208b_p2b 
 (
 .clk                              ( clk_csi                          ),
 .rst_n                            ( clk_csi_rst_n                    ),
 .pixel_cnt                        ( pixel_cnt[2:0]                   ),
 .pixel_data                       ( image_data[31:0]                 ),
 .pixel_data_d1                    ( image_data_delayed[31:0]         ),
 .pixel_data_vld                   ( image_data_valid                 ),
 .sensor_pixel_vld_falling_edge    ( sensor_pixel_vld_falling_edge    ),
 .lyuv4208b_odd_even_convrn_enable ( lyuv4208b_odd_even_convrn_enable ),
 .lyuv4208b_convrn_enable          ( p2b_enable[5]                    ),
 .dw                               ( dw_lyuv420_8b_w                  ),
 .dw_vld                           ( dw_lyuv420_8b_valid_w            )
 );

//------------------------------------------------------------------------------
// YUV420-10b component instantiation
csi2tx_yuv420_10b_p2b 
 u_csi2tx_yuv420_10b_p2b
 (
 .clk                               ( clk_csi                        ),
 .rst_n                             ( clk_csi_rst_n                  ),
 .pixel_cnt                         ( pixel_cnt[3:0]                 ),
 .pixel_data                        ( image_data[31:0]               ),
 .pixel_data_d1                     ( image_data_delayed[31:0]       ),
 .pixel_data_vld                    ( image_data_valid               ),
 .sensor_pixel_vld_falling_edge     ( sensor_pixel_vld_falling_edge  ),
 .yuv420_10b_odd_even_convrn_enable ( yuv420_10b_odd_even_enable_c   ),
 .yuv420_10b_convrn_enable          ( yuv420_10b_enable_c            ),
 .dw                                ( dw_yuv420_10b_w                ),
 .dw_vld                            ( dw_yuv420_10b_valid_w          )
 );

//------------------------------------------------------------------------------
// YUV422-10b component instantiation
csi2tx_yuv422_10b_p2b 
 u_csi2tx_yuv422_10b_p2b
 (
 .clk                               ( clk_csi                        ),
 .rst_n                             ( clk_csi_rst_n                  ),
 .pixel_cnt                         ( pixel_cnt[2:0]                 ),
 .pixel_data                        ( image_data[31:0]               ),
 .pixel_data_d1                     ( image_data_delayed[31:0]       ),
 .pixel_data_vld                    ( image_data_valid               ),
 .sensor_pixel_vld_falling_edge     ( sensor_pixel_vld_falling_edge  ),
 .yuv422_10b_convrn_enable          ( p2b_enable[9]                  ),
 .dw                                ( dw_yuv422_10b_w                ),
 .dw_vld                            ( dw_yuv422_10b_valid_w          )
 );

//------------------------------------------------------------------------------
// YUV420-8b component instantiation
csi2tx_yuv4208b_p2b
 u_csi2tx_yuv4208b_p2b 
 (
 .clk                               ( clk_csi                        ),
 .rst_n                             ( clk_csi_rst_n                  ),
 .pixel_cnt                         ( pixel_cnt[1:0]                 ),
 .pixel_data                        ( image_data[31:0]               ),
 .pixel_data_vld                    ( image_data_valid               ),
 .sensor_pixel_vld_falling_edge     ( sensor_pixel_vld_falling_edge  ),
 .yuv4208b_odd_even_convrn_enable   ( yuv420_8b_odd_even_enable_c    ),
 .yuv4208b_convrn_enable            ( yuv420_8b_enable_c             ),
 .dw                                ( dw_yuv420_8b_w                 ),
 .dw_vld                            ( dw_yuv420_8b_valid_w           )
 );

//------------------------------------------------------------------------------
// YUV422-8b component instantiation
csi2tx_yuv4228b_p2b 
 u_csi2tx_yuv4228b_p2b
 (
 .clk                               ( clk_csi                        ),
 .rst_n                             ( clk_csi_rst_n                  ),
 .pixel_cnt                         ( pixel_cnt[1:0]                 ),
 .pixel_data                        ( image_data[31:0]               ),
 .pixel_data_vld                    ( image_data_valid               ),
 .sensor_pixel_vld_falling_edge     ( sensor_pixel_vld_falling_edge  ),
 .yuv4228b_convrn_enable            ( p2b_enable[8]                  ),
 .dw                                ( dw_yuv422_8b_w                 ),
 .dw_vld                            ( dw_yuv422_8b_valid_w           )
 );
 
//------------------------------------------------------------------------------
// Compressor module instantiation
//------------------------------------------------------------------------------
csi2tx_compressor 
 u_csi2tx_compressor
 (                              
  .sensor_clk                       ( clk_csi                       ),
  .sys_rst_n                        ( clk_csi_rst_n                 ),
  .comp_scheme                      ( comp_scheme                   ), 
  .enable                           ( image_data_valid              ),
  .pixel_data                       ( image_data[11:0]              ),
  .pixel_data_valid                 ( orig_image_data_valid         ),
  .enc_data                         ( enc_data                      ),
  .enc_data_d1                      ( enc_data_delayed              )
 ); 
 
//----------------------------------------------------------------------------//
// Muxing logic to mux DW from different pixel2dw modules
//----------------------------------------------------------------------------//
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if ( clk_csi_rst_n == 1'b0 )
  byte_data_r <= 32'b0;
 else if (comp_en)
  case(comp_scheme[2:0])
   3'b001 : byte_data_r <= dw_raw6_w;
   3'b010 : byte_data_r <= dw_raw7_w;
   3'b011 : byte_data_r <= dw_raw8_w;
   3'b100 : byte_data_r <= dw_raw6_w;
   3'b101 : byte_data_r <= dw_raw7_w;
   3'b110 : byte_data_r <= dw_raw8_w;
   default : byte_data_r <= 32'b0;     
  endcase
 else
  case (p2b_data_sel)
   5'b00000 : byte_data_r <= dw_raw8_w;       // Null packet
   5'b00001 : byte_data_r <= dw_raw8_w;       // Blanking data
   5'b00010 : byte_data_r <= dw_raw8_w;       // Embedded data
   5'b00011 : byte_data_r <= dw_yuv420_8b_w;  // yuv420_8b
   5'b00100 : byte_data_r <= dw_yuv420_10b_w; // yuv420_10b
   5'b00101 : byte_data_r <= dw_lyuv420_8b_w; // legacy yuv420 8b
   5'b00110 : byte_data_r <= dw_yuv420_8b_w;  // yuv420_8b chroma
   5'b00111 : byte_data_r <= dw_yuv420_10b_w; // yuv420_10b chroma
   5'b01000 : byte_data_r <= dw_yuv422_8b_w;  // yuv422_8b
   5'b01001 : byte_data_r <= dw_yuv422_10b_w; // yuv422_10b
   5'b01010 : byte_data_r <= dw_rgb565_w;     // rgb444
   5'b01011 : byte_data_r <= dw_rgb565_w;     // rgb555
   5'b01100 : byte_data_r <= dw_rgb565_w;     // rgb565
   5'b01101 : byte_data_r <= dw_rgb666_w;     // rgb666
   5'b01110 : byte_data_r <= dw_rgb888_w;     // rgb888
   5'b01111 : byte_data_r <= dw_raw6_w;       // raw6
   5'b10000 : byte_data_r <= dw_raw7_w;       // raw7
   5'b10001 : byte_data_r <= dw_raw8_w;       // raw8
   5'b10010 : byte_data_r <= dw_raw10_w;      // raw10
   5'b10011 : byte_data_r <= dw_raw12_w;      // raw12
   5'b10100 : byte_data_r <= dw_raw14_w;      // raw14
   5'b10101 : byte_data_r <= dw_raw8_w;       // usd1
   5'b10110 : byte_data_r <= dw_raw8_w;       // usd2
   5'b10111 : byte_data_r <= dw_raw8_w;       // usd3
   5'b11000 : byte_data_r <= dw_raw8_w;       // usd4
   5'b11001 : byte_data_r <= dw_raw8_w;       // usd5
   5'b11010 : byte_data_r <= dw_raw8_w;       // usd6
   5'b11011 : byte_data_r <= dw_raw8_w;       // usd7
   5'b11100 : byte_data_r <= dw_raw8_w;       // usd8
   default : byte_data_r <= 32'b0;
  endcase
end



always@(posedge clk_csi or negedge clk_csi_rst_n)
begin
 if ( clk_csi_rst_n == 1'b0 )
  byte_data_valid_r <= 1'b0;
 else if (forcetxstopmode == 1'b1)
  byte_data_valid_r <= 1'b0;
 else
  byte_data_valid_r <= ( dw_raw6_valid_w      | dw_raw7_valid_w       | dw_raw8_valid_w       | dw_raw10_valid_w      | 
                         dw_raw12_valid_w     | dw_raw14_valid_w      | dw_rgb565_valid_w     | dw_rgb666_valid_w     |
                         dw_rgb888_valid_w    | dw_lyuv420_8b_valid_w | dw_yuv420_10b_valid_w | dw_yuv422_10b_valid_w |
                         dw_yuv420_8b_valid_w | dw_yuv422_8b_valid_w );                                                   
 end


//------------------------------------------------------------------------------
// Packet aligner component instantiation
csi2tx_packet_aligner
 u_csi2tx_packet_aligner 
(
 .clk_csi                                ( clk_csi                              ),
 .clk_csi_rst_n                          ( clk_csi_rst_n                        ),
 .tinit_start_clk_csi                    ( tinit_start_clk_csi                  ),
 .forcetxstopmode                        ( forcetxstopmode                      ),
 .header_info                            ( header_info                          ),
 .header_info_valid                      ( header_info_valid                    ),
 .byte_data                              ( byte_data_r                          ),
 .byte_data_valid                        ( byte_data_valid_r                    ),
 .pixel_data64                           ( pixel_data64                         ),
 .pixel_data64_valid                     ( pixel_data64_valid                   ),
 .packet_incr_pulse                      ( packet_incr_pulse                    )
); 
  
endmodule
