/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_lane_distribution_top.v
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
module csi2tx_lane_distribution_top 
(
 input  wire        txbyteclkhs            ,
 input  wire        txbyteclkhs_rst_n      ,
 input  wire [2:0]  lane_config            ,
 input  wire        forcetxstopmode        ,
 input  wire        tinit_start            ,
 input  wire        enable_hs_transmission ,
 input  wire        stop_state_dl          ,
 input  wire [7:0]  txreadyhs              ,
 input  wire [63:0] fifo_rd_data           ,
 output wire        fifo_rd_en             ,
 input  wire        fifo_empty_rd_dm       ,
 input  wire [7:0]  hs_exit                ,
 output wire [7:0]  txrequesths            ,
 output wire [63:0] txdatahs               
);

wire header_info_c;
reg [15:0] word_cnt_rd_r;
reg [16:0] word_cnt_wr_r;
wire fifo_rd_en_c;
wire fifo_rd_en_1l_c;
wire fifo_rd_en_2l_c;
wire fifo_rd_en_3l_c;
wire fifo_rd_en_4l_c;
wire fifo_rd_en_5l_c;
wire fifo_rd_en_6l_c;
wire fifo_rd_en_7l_c;
wire fifo_rd_en_8l_c;
wire txrequesths_c;
reg [7:0] lane_configured_s;
wire hs_exit_cnt_decr_enable_1lane_c;
wire hs_exit_cnt_decr_enable_2lane_c;
wire hs_exit_cnt_decr_enable_3lane_c;
wire hs_exit_cnt_decr_enable_4lane_c;
wire hs_exit_cnt_decr_enable_5lane_c;
wire hs_exit_cnt_decr_enable_6lane_c;
wire hs_exit_cnt_decr_enable_7lane_c;
wire hs_exit_cnt_decr_enable_8lane_c;
wire hs_exit_cnt_expired_c;
reg short_packet_dt_r;
wire short_packet_dt_c;
wire wr_size_decr_pulse_1l_c;
wire wr_size_decr_pulse_2l_c;
wire wr_size_decr_pulse_3l_c;
wire wr_size_decr_pulse_4l_c;
wire wr_size_decr_pulse_5l_c;
wire wr_size_decr_pulse_6l_c;
wire wr_size_decr_pulse_7l_c;
wire wr_size_decr_pulse_8l_c;
reg [7:0] hs_exit_r;
wire [7:0]  txdatahs_1lane_c;
wire [15:0] txdatahs_2lane_c;
wire [23:0] txdatahs_3lane_c;
wire [31:0] txdatahs_4lane_c;
wire [39:0] txdatahs_5lane_c;
wire [47:0] txdatahs_6lane_c;
wire [55:0] txdatahs_7lane_c;
wire [63:0] txdatahs_8lane_c;
wire [0:0] txrequesths_1lane_c;
wire [1:0] txrequesths_2lane_c;
wire [2:0] txrequesths_3lane_c;
wire [3:0] txrequesths_4lane_c;
wire [4:0] txrequesths_5lane_c;
wire [5:0] txrequesths_6lane_c;
wire [6:0] txrequesths_7lane_c;
wire [7:0] txrequesths_8lane_c;
wire wr_size_decr_pulse_c;
wire hs_exit_cnt_decr_enable_c;
wire header_info_1lane_c;
wire header_info_2lane_c;
wire header_info_3lane_c;
wire header_info_4lane_c;
wire header_info_5lane_c;
wire header_info_6lane_c;
wire header_info_7lane_c;
wire header_info_8lane_c;
wire tx_done_c;
wire tx_done_1lane_c;
wire tx_done_2lane_c;
wire tx_done_3lane_c;
wire tx_done_4lane_c;
wire tx_done_5lane_c;
wire tx_done_6lane_c;
wire tx_done_7lane_c;
wire tx_done_8lane_c;
wire eop_rd;
wire eop_wr;


reg [63:0] fifo_rd_data_d;
reg [63:0] fifo_rd_data_d1;
reg [63:0] fifo_rd_data_d2;




//31st bit is internally set to identify the short packet / logn packet
// if 31st bit is '1' it is short packet
// if 31st bit is '0' it is long packet
assign short_packet_dt_c = ((header_info_c == 1'b1) && ((fifo_rd_data[5:0] == `GEN_SH_PKT1)||
                             (fifo_rd_data[5:0] == `GEN_SH_PKT2)|| (fifo_rd_data[5:0] == `GEN_SH_PKT3)||
                             (fifo_rd_data[5:0] == `GEN_SH_PKT4)|| (fifo_rd_data[5:0] == `GEN_SH_PKT5)||
                             (fifo_rd_data[5:0] == `GEN_SH_PKT6)|| (fifo_rd_data[5:0] == `GEN_SH_PKT7)||
                             (fifo_rd_data[5:0] == `GEN_SH_PKT8)|| (fifo_rd_data[5:0] == `FRAME_START)||
                             (fifo_rd_data[5:0] == `FRAME_END)  || (fifo_rd_data[5:0] == `LINE_START)||
                             (fifo_rd_data[5:0] == `LINE_END))) ? 1'b1 : 1'b0;
                             
//------------------------------------------------------------------------------
// Hold the short packet indication till it is validated to DPHY
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  short_packet_dt_r <= 1'b0;
 else if (tinit_start == 1'b0)
  short_packet_dt_r <= 1'b0;
 else if (forcetxstopmode == 1'b1)
  short_packet_dt_r <= 1'b0;
 else if (short_packet_dt_c == 1'b1)
  short_packet_dt_r <= 1'b1; 
//else if ((txrequesths_c[0] == 1'b1) && (txreadyhs[0] == 1'b1))
 else if (tx_done_c == 1'b1)
  short_packet_dt_r <= 1'b0;
end                              
                             
assign txrequesths_c = txrequesths[0];

//This signal endicates the last bytes of the packet processing
// One bit is extra as we add CRC count to this
assign eop_rd = (word_cnt_rd_r == 16'b0) ? 1'b1 : 1'b0;

//This signal indicates the last byte validated to DPHY
assign eop_wr = ((word_cnt_wr_r == 17'b0) && (txrequesths_c == 1'b1) && (txreadyhs[0] == 1'b1) && (short_packet_dt_r == 1'b0)) ? 1'b1 : 1'b0;

//Extract the Word count from the packet and decrement for every read
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  word_cnt_rd_r <= 16'b0;
 else if (forcetxstopmode == 1'b1)
  word_cnt_rd_r <= 16'h0;
 else if ((header_info_c == 1'b1) && (short_packet_dt_c == 1'b0))
  // Here the CRC value is not needed as when we read out the header along with
  // 32-bit header already 16-bit data is also been readout
  // Substracted with -2 because 32-bit is been read out - out of which
  // 16-bit can be considered as CRC and remaining 2 bytes is actual data
  if (fifo_rd_data[23:8] <= 16'h2)
    word_cnt_rd_r <= 16'b0;
  else
    word_cnt_rd_r <= fifo_rd_data[23:8] - 2'b10; 
 else if (fifo_rd_en_c == 1'b1)
   if (word_cnt_rd_r <= 16'h8)
     word_cnt_rd_r <= 16'b0;
   else
     word_cnt_rd_r <= word_cnt_rd_r - 4'b1000; 
end

//Extract the word count from the packet and decrement for every validating
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  word_cnt_wr_r <= 17'b0;
 else if (forcetxstopmode == 1'b1)
  word_cnt_wr_r <= 17'b0;
 else if ((header_info_c == 1'b1) && (short_packet_dt_c == 1'b0))
  word_cnt_wr_r <= fifo_rd_data[23:8] + 4'b0110; // Actual payload + CRC + Header
 else if (wr_size_decr_pulse_c == 1'b1)
  if ((word_cnt_wr_r[16:4] == 13'b0) && (word_cnt_wr_r[3:0] <= (lane_config + 1'b1)))
    word_cnt_wr_r <= 17'b0;
  else
   word_cnt_wr_r <= word_cnt_wr_r - (lane_config + 1'b1); 
else if((txrequesths_c == 1'b1) && (txreadyhs[0] == 1'b1))
  if ((word_cnt_wr_r[16:4] == 13'b0) && (word_cnt_wr_r[3:0] <= (lane_config + 1'b1)))
   word_cnt_wr_r <= 17'b0;
  else
   word_cnt_wr_r <= word_cnt_wr_r - (lane_config + 1'b1); 
end

always@(*) begin
 case (lane_config)
  3'b000 : lane_configured_s = 8'b0000_0001; // one   lane
  3'b001 : lane_configured_s = 8'b0000_0010; // two   lane
  3'b010 : lane_configured_s = 8'b0000_0100; // three lane
  3'b011 : lane_configured_s = 8'b0000_1000; // four  lane
  3'b100 : lane_configured_s = 8'b0001_0000; // five  lane
   3'b101 : lane_configured_s = 8'b0010_0000; // six   lane
  3'b110 : lane_configured_s = 8'b0100_0000; // seven lane
  3'b111 : lane_configured_s = 8'b1000_0000; // eight lane
  default : lane_configured_s = 8'b1000_0000; // eight lane
 endcase
end

//------------------------------------------------------------------------------
//
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  hs_exit_r <= 8'b0;
 else if ((hs_exit_cnt_decr_enable_c == 1'b1) && (hs_exit_r > 8'h0))
  hs_exit_r <= hs_exit_r - 1'b1;
 else
  hs_exit_r <= hs_exit; 
end
assign  hs_exit_cnt_expired_c = (hs_exit_r == 8'b0) ? 1'b1 : 1'b0;
//------------------------------------------------------------------------------
//
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
  if (txbyteclkhs_rst_n == 1'b0) begin
    fifo_rd_data_d <= 64'b0;
    fifo_rd_data_d1 <= 64'b0;
    fifo_rd_data_d2 <= 64'b0;
  end else if (forcetxstopmode == 1'b1) begin
    fifo_rd_data_d <= 64'b0;
    fifo_rd_data_d1 <= 64'b0;
    fifo_rd_data_d2 <= 64'b0;    
  end else begin
    fifo_rd_data_d <= fifo_rd_data;
    fifo_rd_data_d1 <= fifo_rd_data_d;
    fifo_rd_data_d2 <= fifo_rd_data_d1;
  end
end
//------------------------------------------------------------------------------
csi2tx_one_lane_ldl
 u_csi2tx_one_lane_ldl 
(
 .txbyteclkhs                 ( txbyteclkhs                     ),
 .txbyteclkhs_rst_n           ( txbyteclkhs_rst_n               ),
 .tinit_start                 ( tinit_start                     ),
 .one_lane_en                 ( lane_configured_s[0]            ),
 .csi_byte_fifo_empty         ( fifo_empty_rd_dm                ),
 .forcetxstopmode             ( forcetxstopmode                 ),
 .enable_hs_transmission      ( enable_hs_transmission          ),
 .short_packet                ( short_packet_dt_r               ),
 .eop_wr                      ( eop_wr                          ),
 .eop_rd                      ( eop_rd                          ),
 .txreadyhs                   ( txreadyhs                       ), 
 .hs_exit_cnt_expired         ( hs_exit_cnt_expired_c           ),
 .stop_state_dl               ( stop_state_dl                   ), 
 .fifo_rd_data                ( fifo_rd_data                    ),
 .wr_size_decr_pulse          ( wr_size_decr_pulse_1l_c         ),
 .fifo_rd_en                  ( fifo_rd_en_1l_c                 ),
 .txdatahs                    ( txdatahs_1lane_c                ),
 .txrequesths                 ( txrequesths_1lane_c             ), 
 .hs_exit_cnt_decr_enable     ( hs_exit_cnt_decr_enable_1lane_c ),
 .header_info                 ( header_info_1lane_c             ),
                        .tx_done                     ( tx_done_1lane_c                 ) 
);

//------------------------------------------------------------------------------
//
csi2tx_two_lane_ldl
 u_csi2tx_two_lane_ldl 
(
 .txbyteclkhs                 (    txbyteclkhs                     ), 
 .txbyteclkhs_rst_n           (    txbyteclkhs_rst_n               ), 
 .tinit_start                 (    tinit_start                     ), 
 .two_lane_en                 (    lane_configured_s[1]            ), 
 .csi_byte_fifo_empty         (    fifo_empty_rd_dm                ), 
 .enable_hs_transmission      (    enable_hs_transmission          ), 
 .forcetxstopmode             (    forcetxstopmode                 ),
 .short_packet                (    short_packet_dt_r               ), 
 .eop_wr                      (    eop_wr                          ), 
 .eop_rd                      (    eop_rd                          ), 
 .txreadyhs                   (    txreadyhs                       ), 
 .hs_exit_cnt_expired         (    hs_exit_cnt_expired_c           ), 
 .stop_state_dl               (    stop_state_dl                   ), 
 .validated_word_cnt          (    word_cnt_wr_r                   ), 
 .fifo_rd_data                (    fifo_rd_data                    ), 
 .wr_size_decr_pulse          (    wr_size_decr_pulse_2l_c         ), 
 .fifo_rd_en                  (    fifo_rd_en_2l_c                 ), 
 . txdatahs                   (    txdatahs_2lane_c                ), 
 .txrequesths                 (    txrequesths_2lane_c             ), 
 .hs_exit_cnt_decr_enable     (    hs_exit_cnt_decr_enable_2lane_c ), 
 .header_info                 (    header_info_2lane_c             ), 
 .tx_done                     (    tx_done_2lane_c                 )  
);
//-----------------------------------------------------------------------------
//
csi2tx_three_lane_ldl
 u_csi2tx_three_lane_ldl 
(
 .txbyteclkhs                 ( txbyteclkhs                     ),
 .txbyteclkhs_rst_n           ( txbyteclkhs_rst_n               ),
 .tinit_start                 ( tinit_start                     ),
 .three_lane_en               ( lane_configured_s[2]            ),
 .csi_byte_fifo_empty         ( fifo_empty_rd_dm                ),
 .enable_hs_transmission      ( enable_hs_transmission          ),
 .short_packet                ( short_packet_dt_r               ),
 .forcetxstopmode             ( forcetxstopmode                 ),
 .eop_wr                      ( eop_wr                          ),
 .eop_rd                      ( eop_rd                          ),
 .txreadyhs                   ( txreadyhs                       ), 
 .hs_exit_cnt_expired         ( hs_exit_cnt_expired_c           ),
 .stop_state_dl               ( stop_state_dl                   ), 
 .validated_word_cnt          ( word_cnt_wr_r                   ),
 .fifo_rd_data                ( fifo_rd_data                    ),
 .fifo_rd_data_d              ( fifo_rd_data_d                  ),
 .wr_size_decr_pulse          ( wr_size_decr_pulse_3l_c         ),
 .fifo_rd_en                  ( fifo_rd_en_3l_c                 ),
 .txdatahs                    ( txdatahs_3lane_c                ),
 .txrequesths                 ( txrequesths_3lane_c             ), 
 .hs_exit_cnt_decr_enable     ( hs_exit_cnt_decr_enable_3lane_c ),
 .header_info                 ( header_info_3lane_c             ),
 .tx_done                     ( tx_done_3lane_c                 ) 
);
//-----------------------------------------------------------------------------
//
csi2tx_four_lane_ldl
 u_csi2tx_four_lane_ldl 
(
 .txbyteclkhs                 ( txbyteclkhs                     ),
 .txbyteclkhs_rst_n           ( txbyteclkhs_rst_n               ),
 .tinit_start                 ( tinit_start                     ),
 .four_lane_en                ( lane_configured_s[3]            ),
 .csi_byte_fifo_empty         ( fifo_empty_rd_dm                ),
 .enable_hs_transmission      ( enable_hs_transmission          ),
 .short_packet                ( short_packet_dt_r               ),
 .forcetxstopmode             ( forcetxstopmode                 ),
 .eop_wr                      ( eop_wr                          ),
 .eop_rd                      ( eop_rd                          ),
 .txreadyhs                   ( txreadyhs                       ), 
 .hs_exit_cnt_expired         ( hs_exit_cnt_expired_c           ),
 .stop_state_dl               ( stop_state_dl                   ), 
 .validated_word_cnt          ( word_cnt_wr_r                   ),
 .fifo_rd_data                ( fifo_rd_data                    ),
 .wr_size_decr_pulse          ( wr_size_decr_pulse_4l_c         ),
 .fifo_rd_en                  ( fifo_rd_en_4l_c                 ),
 .txdatahs                    ( txdatahs_4lane_c                ),
 .txrequesths                 ( txrequesths_4lane_c             ), 
 .hs_exit_cnt_decr_enable     ( hs_exit_cnt_decr_enable_4lane_c ),
 .header_info                 ( header_info_4lane_c             ),
                        .tx_done                     ( tx_done_4lane_c                 ) 
);
//------------------------------------------------------------------------------
// Five lane component instantiation
csi2tx_five_lane_ldl 
 u_csi2tx_five_lane_ldl
(
 .txbyteclkhs                ( txbyteclkhs                     ),
 .txbyteclkhs_rst_n          ( txbyteclkhs_rst_n               ),
 .tinit_start                ( tinit_start                     ),
 .five_lane_en               ( lane_configured_s[4]            ),
 .csi_byte_fifo_empty        ( fifo_empty_rd_dm                ),
 .enable_hs_transmission     ( enable_hs_transmission          ),
 .short_packet               ( short_packet_dt_r               ),
 .forcetxstopmode            ( forcetxstopmode                 ),
 .eop_wr                     ( eop_wr                          ),
 .eop_rd                     ( eop_rd                          ),
 .txreadyhs                  ( txreadyhs                       ),
 .hs_exit_cnt_expired        ( hs_exit_cnt_expired_c           ),
 .stop_state_dl              ( stop_state_dl                   ),
 .validated_word_cnt         ( word_cnt_wr_r                   ),
 .fifo_rd_data               ( fifo_rd_data                    ),
 .fifo_rd_data_d             ( fifo_rd_data_d                  ),
 .fifo_rd_data_d1            ( fifo_rd_data_d1                 ),
 .fifo_rd_data_d2            ( fifo_rd_data_d2                 ),
 .wr_size_decr_pulse         ( wr_size_decr_pulse_5l_c         ),
 .fifo_rd_en                 ( fifo_rd_en_5l_c                 ),
 .txdatahs                   ( txdatahs_5lane_c                ),
 .txrequesths                ( txrequesths_5lane_c            ),
 .hs_exit_cnt_decr_enable    ( hs_exit_cnt_decr_enable_5lane_c ),
 .header_info                ( header_info_5lane_c             ),
 .tx_done                    ( tx_done_5lane_c                 ) 
);
//------------------------------------------------------------------------------
// siz lane component instantiation
csi2tx_six_lane_ldl 
 u_csi2tx_six_lane_ldl
(
 .txbyteclkhs                ( txbyteclkhs                     ),
 .txbyteclkhs_rst_n          ( txbyteclkhs_rst_n               ),
 .tinit_start                ( tinit_start                     ),
 .six_lane_en                ( lane_configured_s[5]            ),
 .csi_byte_fifo_empty        ( fifo_empty_rd_dm                ),
 .enable_hs_transmission     ( enable_hs_transmission          ),
 .short_packet               ( short_packet_dt_r               ),
 .forcetxstopmode            ( forcetxstopmode                 ),
 .eop_wr                     ( eop_wr                          ),
 .eop_rd                     ( eop_rd                          ),
 .txreadyhs                  ( txreadyhs                       ),
 .hs_exit_cnt_expired        ( hs_exit_cnt_expired_c           ),
 .stop_state_dl              ( stop_state_dl                   ),
 .validated_word_cnt         ( word_cnt_wr_r                   ),
 .fifo_rd_data               ( fifo_rd_data                    ),
 .fifo_rd_data_d             ( fifo_rd_data_d                  ),
 .wr_size_decr_pulse         ( wr_size_decr_pulse_6l_c         ),
 .fifo_rd_en                 ( fifo_rd_en_6l_c                 ),
 .txdatahs                   ( txdatahs_6lane_c                ),
 .txrequesths                ( txrequesths_6lane_c            ),
 .hs_exit_cnt_decr_enable    ( hs_exit_cnt_decr_enable_6lane_c ),
 .header_info                ( header_info_6lane_c             ),
 .tx_done                    ( tx_done_6lane_c                 ) 
);
//------------------------------------------------------------------------------
// Five lane component instantiation
csi2tx_seven_lane_ldl 
 u_csi2tx_seven_lane_ldl
(
 .txbyteclkhs                ( txbyteclkhs                     ),
 .txbyteclkhs_rst_n          ( txbyteclkhs_rst_n               ),
 .tinit_start                ( tinit_start                     ),
 .seven_lane_en              ( lane_configured_s[6]            ),
 .csi_byte_fifo_empty        ( fifo_empty_rd_dm                ),
 .enable_hs_transmission     ( enable_hs_transmission          ),
 .short_packet               ( short_packet_dt_r               ),
 .forcetxstopmode            ( forcetxstopmode                 ),
 .eop_wr                     ( eop_wr                          ),
 .eop_rd                     ( eop_rd                          ),
 .txreadyhs                  ( txreadyhs                       ),
 .hs_exit_cnt_expired        ( hs_exit_cnt_expired_c           ),
 .stop_state_dl              ( stop_state_dl                   ),
 .validated_word_cnt         ( word_cnt_wr_r                   ),
 .fifo_rd_data               ( fifo_rd_data                    ),
 .fifo_rd_data_d             ( fifo_rd_data_d                  ),
 .wr_size_decr_pulse         ( wr_size_decr_pulse_7l_c         ),
 .fifo_rd_en                 ( fifo_rd_en_7l_c                 ),
 .txdatahs                   ( txdatahs_7lane_c                ),
 .txrequesths                ( txrequesths_7lane_c            ),
 .hs_exit_cnt_decr_enable    ( hs_exit_cnt_decr_enable_7lane_c ),
 .header_info                ( header_info_7lane_c             ),
 .tx_done                    ( tx_done_7lane_c                 ) 
);
//------------------------------------------------------------------------------
// Eight Lane component instantiation
csi2tx_eight_lane_ldl 
 u_csi2tx_eight_lane_ldl
(
 .txbyteclkhs              ( txbyteclkhs                     ),
 .txbyteclkhs_rst_n        ( txbyteclkhs_rst_n               ),
 .tinit_start              ( tinit_start                     ),
 .eight_lane_en            ( lane_configured_s[7]            ),
 .csi_byte_fifo_empty      ( fifo_empty_rd_dm                ),
 .enable_hs_transmission   ( enable_hs_transmission          ),
 .short_packet             ( short_packet_dt_r               ),
 .forcetxstopmode          ( forcetxstopmode                 ),
 .eop_rd                   ( eop_rd                          ),
 .eop_wr                   ( eop_wr                          ),
 .txreadyhs                ( txreadyhs                       ),  
 .hs_exit_cnt_expired      ( hs_exit_cnt_expired_c           ),
 .stop_state_dl            ( stop_state_dl                   ),  
 .validated_word_cnt       ( word_cnt_wr_r                   ),
 .fifo_rd_data             ( fifo_rd_data                    ),
 .fifo_rd_en               ( fifo_rd_en_8l_c                 ),
 .txdatahs                 ( txdatahs_8lane_c                ),
 .txrequesths              ( txrequesths_8lane_c             ),
 .hs_exit_cnt_decr_enable  ( hs_exit_cnt_decr_enable_8lane_c ),
 .header_info              ( header_info_8lane_c             ),
 .wr_size_decr_pulse       ( wr_size_decr_pulse_8l_c         ),
 .tx_done                  ( tx_done_8lane_c                 ) 
);


assign wr_size_decr_pulse_c      = wr_size_decr_pulse_1l_c | wr_size_decr_pulse_2l_c | wr_size_decr_pulse_3l_c | wr_size_decr_pulse_4l_c |
                                   wr_size_decr_pulse_5l_c | wr_size_decr_pulse_6l_c | wr_size_decr_pulse_7l_c | wr_size_decr_pulse_8l_c;

assign fifo_rd_en_c              = fifo_rd_en_1l_c | fifo_rd_en_2l_c | fifo_rd_en_3l_c | fifo_rd_en_4l_c | 
                                   fifo_rd_en_5l_c | fifo_rd_en_6l_c | fifo_rd_en_7l_c | fifo_rd_en_8l_c ;


assign hs_exit_cnt_decr_enable_c = hs_exit_cnt_decr_enable_1lane_c | hs_exit_cnt_decr_enable_2lane_c | hs_exit_cnt_decr_enable_3lane_c | hs_exit_cnt_decr_enable_4lane_c |
                                   hs_exit_cnt_decr_enable_5lane_c | hs_exit_cnt_decr_enable_6lane_c | hs_exit_cnt_decr_enable_7lane_c | hs_exit_cnt_decr_enable_8lane_c;


assign header_info_c             = header_info_1lane_c | header_info_2lane_c |  header_info_3lane_c | header_info_4lane_c | 
                                   header_info_5lane_c | header_info_6lane_c | header_info_7lane_c | header_info_8lane_c;

assign fifo_rd_en                = fifo_rd_en_c;

assign tx_done_c                 = tx_done_1lane_c | tx_done_2lane_c | tx_done_3lane_c | tx_done_4lane_c |
                                   tx_done_5lane_c | tx_done_6lane_c | tx_done_7lane_c | tx_done_8lane_c;



assign txdatahs = (lane_config == 3'b000) ? {56'b0,txdatahs_1lane_c} :
                  (lane_config == 3'b001) ? {48'b0,txdatahs_2lane_c} :
                  (lane_config == 3'b010) ? {40'b0,txdatahs_3lane_c} :
                  (lane_config == 3'b011) ? {32'b0,txdatahs_4lane_c} :
                  (lane_config == 3'b100) ? {24'b0,txdatahs_5lane_c} :
                  (lane_config == 3'b101) ? {16'b0,txdatahs_6lane_c} :
                  (lane_config == 3'b110) ? {8'b0 ,txdatahs_7lane_c } : txdatahs_8lane_c;
 
assign txrequesths = (lane_config == 3'b000) ? {7'b0,txrequesths_1lane_c} :                                      
                  (lane_config == 3'b001) ? {6'b0,txrequesths_2lane_c} :                                       
                  (lane_config == 3'b010) ? {5'b0,txrequesths_3lane_c} :                                       
                  (lane_config == 3'b011) ? {4'b0,txrequesths_4lane_c} :                     
                  (lane_config == 3'b100) ? {3'b0,txrequesths_5lane_c} :                     
                  (lane_config == 3'b101) ? {2'b0,txrequesths_6lane_c} :                     
                  (lane_config == 3'b110) ? {1'b0,txrequesths_7lane_c } : txrequesths_8lane_c;
endmodule
