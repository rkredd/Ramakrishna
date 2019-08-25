/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_sensor_iface.v
// Author      : SHYAM SUNDAR B. S
// Abstract    : 
// 1. This module interfaces to external camera sensor and generates required
// handshake signals to accept the short and long packets
// 2. If any short sync packet recieved are send out to Sensor FIFO directly
// 3. Generates enable for respective pixel2byte module
// 4. Controls the Odd/Even packing enable for YUV data formats
// . 
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`include "csi2tx_defines.v"
module csi2tx_sensor_iface
(
 input wire        clk_csi                                   ,
 input wire        clk_csi_rst_n                             ,
 input wire        forcetxstopmode                           ,
 input wire        tinit_start_csi_clk                       ,
 input wire        fifo_almost_full                          ,
 input wire        packet_incr_pulse                         ,
 //Sensor Interface signal
 input wire        frame_start                               ,
 input wire        frame_end                                 ,
 input wire        line_start                                ,
 input wire        line_end                                  ,
 input wire [31:0] pixel_data                                ,
 input wire        pixel_data_valid                          ,
 input wire [5:0]  packet_header                             ,
 input wire        packet_header_valid                       ,
 input wire [15:0] word_count                                ,
 input wire [1:0]  virtual_channel                           ,
 output wire       pixel_data_accept                         ,
 output wire       pixel_header_accept                       ,
 // AHB Interface signals
 input  wire [39:0] vc0_compression_reg                      ,
 input  wire [39:0] vc1_compression_reg                      ,
 input  wire [39:0] vc2_compression_reg                      ,
 input  wire [39:0] vc3_compression_reg                      ,
 // Control signal to other modules
 output wire [31:0] header_info                              ,
 output wire        header_info_valid                        ,
 output wire        image_data_valid                         ,
 output wire [31:0] image_data                               ,
 output wire [31:0] image_data_delayed                       ,
 output wire        sensor_pixel_vld_falling_edge            ,
 output wire [4:0]  pixel_cnt                                ,
 output wire [31:0] p2b_enable                               ,
 output wire [4:0]  p2b_data_sel                             ,
 output wire        lyuv4208b_odd_even_convrn_enable         ,
 output wire        yuv4208b_csps_odd_even_convrn_enable     ,
 output wire        yuv420_10b_csps_odd_even_convrn_enable   ,
 output wire        yuv4208b_odd_even_convrn_enable          ,
 output wire        yuv420_10b_odd_even_convrn_enable        ,
 output wire        comp_en                                  ,
 output wire [4:0]  comp_scheme                           
);

//------------------------------------------------------------------------------
// Internal signal declaration
parameter IDLE              = 3'b000;
parameter CHK_FIFO_SPACE_AV = 3'b001;
parameter ACCEPT_HEADER     = 3'b010;
parameter WAIT_STATE        = 3'b011;
parameter DATA_ACCEPT       = 3'b100;
parameter PKT_OVER          = 3'b101;
parameter IDLE_CYCLE        = 3'b110;

reg [2:0]   cur_state                                   ;
reg [31:0]  gen_sh_pkt_field_r                          ;
reg         sh_pkt_write_pulse_r                        ;
reg         sh_pkt_write_pulse_end_r                    ;
reg         sh_pkt_write_pulse_d                        ;
wire        packet_header_valid_c                       ;
reg         gen_sh_pkt_rcvd                             ;
wire        pixel_header_accept_w                       ;
wire        pixel_data_accept_w                         ;
wire        image_data_valid_w                          ;
wire [31:0] image_data_w                                ;
reg  [31:0] image_data_delayed_r                        ;
reg         pixel_data_valid_d                          ;
wire        sensor_pixel_vld_falling_edge_c             ;
reg  [4:0]  pixel_cnt_r                                 ;
reg  [31:0] p2b_enable_r                                ;
reg  [4:0]  p2b_data_sel_r                              ;
reg  [1:0]  vc_r                                        ;
reg  [5:0]  data_type_r                                 ;
reg  [3:0]  lyuv4208b_odd_even_convrn_enable_vc_r       ;
reg         lyuv4208b_odd_even_convrn_enable_s          ;
reg  [3:0]  yuv4208b_csps_odd_even_convrn_enable_vc_r   ;
reg         yuv4208b_csps_odd_even_convrn_enable_s      ;
reg  [3:0]  yuv420_10b_csps_odd_even_convrn_enable_vc_r ;
reg         yuv420_10b_csps_odd_even_convrn_enable_s    ;
reg  [3:0]  yuv4208b_odd_even_convrn_enable_vc_r        ;
reg         yuv4208b_odd_even_convrn_enable_s           ;
reg  [3:0]  yuv420_10b_odd_even_convrn_enable_vc_r      ;
reg         yuv420_10b_odd_even_convrn_enable_s         ;
reg  [39:0] d_vc0_comp_r                                ;
reg  [39:0] d_vc1_comp_r                                ;
reg  [39:0] d_vc2_comp_r                                ;
reg  [39:0] d_vc3_comp_r                                ;
reg  [39:0] vc_comp_reg_s                               ;
reg  [4:0]  comp_scheme_s                               ;
wire        comp_en_c                                   ;


//------------------------------------------------------------------------------
// The following logic includes the header formation for the following
// 1. Sync packet formation logic
// 2. Generic short packet formation logic
// 3. Long Packet header formation
//------------------------------------------------------------------------------
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  gen_sh_pkt_field_r <= 32'b0;
 else if (tinit_start_csi_clk == 1'b0)
  gen_sh_pkt_field_r <= 32'b0;
 else if (frame_start) begin
  gen_sh_pkt_field_r[5:0] <= `FRAME_START;
  gen_sh_pkt_field_r[7:6] <= virtual_channel;
  gen_sh_pkt_field_r[23:8] <= word_count;
  // This is used internally to idetify the short packet / long packet header
  // 2'b01 - Short Packet
  // 2'b10 - Long Packet
  gen_sh_pkt_field_r[25:24] <= 2'b01;
  gen_sh_pkt_field_r[31:26] <= 6'b0; 
 end else if (frame_end) begin
  gen_sh_pkt_field_r[5:0]   <= `FRAME_END;
  gen_sh_pkt_field_r[7:6]   <= virtual_channel;
  gen_sh_pkt_field_r[23:8]  <= word_count;
  gen_sh_pkt_field_r[25:24] <= 2'b01;
  gen_sh_pkt_field_r[31:26] <= 6'b0;   
 end else if (line_start) begin
  gen_sh_pkt_field_r[5:0]   <= `LINE_START;
  gen_sh_pkt_field_r[7:6]   <= virtual_channel;
  gen_sh_pkt_field_r[23:8]  <= word_count;
  gen_sh_pkt_field_r[25:24] <= 2'b01;
  gen_sh_pkt_field_r[31:26] <= 6'b0;  
 end else if (line_end) begin
  gen_sh_pkt_field_r[5:0]   <= `LINE_END;
  gen_sh_pkt_field_r[7:6]   <= virtual_channel;
  gen_sh_pkt_field_r[23:8]  <= word_count;
  gen_sh_pkt_field_r[25:24] <= 2'b01;
  gen_sh_pkt_field_r[31:26] <= 6'b0;  
 //other genric short packets which will have only header and data is embedded 
 // in the word count
 end else if ((packet_header_valid == 1'b1) && 
 ((packet_header == `GEN_SH_PKT1) ||(packet_header == `GEN_SH_PKT2) || 
  (packet_header == `GEN_SH_PKT3) ||(packet_header == `GEN_SH_PKT4) || 
  (packet_header == `GEN_SH_PKT5) ||(packet_header == `GEN_SH_PKT6) || 
  (packet_header == `GEN_SH_PKT7) || (packet_header == `GEN_SH_PKT8))) begin
  gen_sh_pkt_field_r[5:0]   <= packet_header;
  gen_sh_pkt_field_r[7:6]   <= virtual_channel;
  gen_sh_pkt_field_r[23:8]  <= word_count;
  gen_sh_pkt_field_r[25:24] <= 2'b01;
  gen_sh_pkt_field_r[31:26] <= 6'b0;
 end else if (packet_header_valid == 1'b1) begin
  gen_sh_pkt_field_r[5:0]   <= packet_header;
  gen_sh_pkt_field_r[7:6]   <= virtual_channel;
  gen_sh_pkt_field_r[23:8]  <= word_count;
  gen_sh_pkt_field_r[25:24] <= 2'b10;
  gen_sh_pkt_field_r[31:26] <= 6'b0; 
 end  
end

//------------------------------------------------------------------------------
// Short Packet Valid generation

// Short packet wire pulse generation when FS,LS and packet header information is
// received
// Here the end packet are not used as we need to induce a extra delay while
// validating the FE/LE becuase of pipeline delay from p2b modules. If this
// delay is not added, the write for the FE/LE and datafrom p2b will come at the
// same clock and hence separate logic for the FS/LS and FE/LE, where FE/LE will
// have an additonal one clock delay [ THese will happen only when FE/LE are recieve
// one clock immediatly after the data de-assertion]
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  sh_pkt_write_pulse_r <= 1'b0;
 else if (tinit_start_csi_clk == 1'b0)
  sh_pkt_write_pulse_r <= 1'b0;
 else if (forcetxstopmode == 1'b1)
  sh_pkt_write_pulse_r <= 1'b0;
 else if ((frame_start == 1'b1) || (line_start == 1'b1) || (cur_state == ACCEPT_HEADER))
  sh_pkt_write_pulse_r <= 1'b1;
 else
  sh_pkt_write_pulse_r <= 1'b0;
end

always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  sh_pkt_write_pulse_end_r <= 1'b0;
 else if (tinit_start_csi_clk == 1'b0)
  sh_pkt_write_pulse_end_r <= 1'b0;
 else if (forcetxstopmode == 1'b1)
  sh_pkt_write_pulse_end_r <= 1'b0;   
 else if ((frame_end == 1'b1) || (line_end == 1'b1))
  sh_pkt_write_pulse_end_r <= 1'b1;
 else
  sh_pkt_write_pulse_end_r <= 1'b0;
end

// An additional delay for the above said reason
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  sh_pkt_write_pulse_d <= 1'b0;
 else if (tinit_start_csi_clk == 1'b0)
  sh_pkt_write_pulse_d <= 1'b0;
 else
  sh_pkt_write_pulse_d <= sh_pkt_write_pulse_end_r; 
end

assign packet_header_valid_c = (sh_pkt_write_pulse_d | sh_pkt_write_pulse_r); 

//------------------------------------------------------------------------------
// The following signal will get asserted when ever an generic short packet is 
// received, this signal is used to control the state machine flow
//------------------------------------------------------------------------------
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  gen_sh_pkt_rcvd <= 1'b0;
 else if (tinit_start_csi_clk == 1'b0)
  gen_sh_pkt_rcvd <= 1'b0;
 else if ((packet_header_valid == 1'b1) && 
 ((packet_header == `GEN_SH_PKT1) ||(packet_header == `GEN_SH_PKT2) || 
  (packet_header == `GEN_SH_PKT3) ||(packet_header == `GEN_SH_PKT4) || 
  (packet_header == `GEN_SH_PKT5) ||(packet_header == `GEN_SH_PKT6) || 
  (packet_header == `GEN_SH_PKT7) || (packet_header == `GEN_SH_PKT8)))
  gen_sh_pkt_rcvd <= 1'b1;
 else
  gen_sh_pkt_rcvd <= 1'b0;
end
//------------------------------------------------------------------------------
// The following state machine control the flow in accepting the long packet
//------------------------------------------------------------------------------
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  cur_state <= IDLE;
 else if (tinit_start_csi_clk == 1'b0)
  cur_state <= IDLE;
 else if (forcetxstopmode == 1'b1)
  cur_state <= IDLE;
 else
  case(cur_state)
   // Wait for the packet header assertion
   IDLE : begin
    if (packet_header_valid == 1'b1)
     cur_state <= CHK_FIFO_SPACE_AV;
    else
     cur_state <= IDLE;
   end
   // Check is enough space is available in the sensor FIFO to accomodate a new
   // frame
   // Note : The FIFO space is checked only for generic short and long packets
   // whereas for sync short packet it is not checked as it is assumed that
   // the user will control these. As these are not expected back2back in the
   // real time environment
   CHK_FIFO_SPACE_AV : begin
    if (fifo_almost_full == 1'b0)
     cur_state <= ACCEPT_HEADER;
    else
     cur_state <= CHK_FIFO_SPACE_AV;
   end 
   // Accept the header information by asserting the header acept for a clock and
   // as per the protocol assert the data accept as well in this state
   ACCEPT_HEADER : begin
    if (gen_sh_pkt_rcvd == 1'b1)
     cur_state <= IDLE;
    //else if (fifo_almost_full == 1'b0)
    // cur_state <= DATA_ACCEPT;
    //else
    // cur_state <= WAIT_STATE;
    else
       cur_state <= IDLE_CYCLE;
   end
   IDLE_CYCLE : begin
    if (fifo_almost_full == 1'b0)
     cur_state <= DATA_ACCEPT;
    else
     cur_state <= WAIT_STATE;
   end 
   // If not enough space is available in the FIFO wait until space get free
   WAIT_STATE : begin
    if ((fifo_almost_full == 1'b0) && (pixel_data_valid == 1'b1))
     cur_state <= DATA_ACCEPT;
    else if (pixel_data_valid == 1'b0)
     cur_state <= PKT_OVER;
    else
     cur_state <= WAIT_STATE;
   end
   //
   DATA_ACCEPT : begin
    if (fifo_almost_full == 1'b1)
     cur_state <= WAIT_STATE;
    else if (pixel_data_valid == 1'b0)
     cur_state <= PKT_OVER;
    else
     cur_state <= DATA_ACCEPT;
   end
   //
   PKT_OVER : begin
     // This signal check is a must incase where The sensor clock is HIGH
     // and Byteclk is of LOW frequency. This signal will make sure that
     // the Packet counter will first get incremented for the first frame
     // then only a new packet will be accepted. This overcomes the SYNC
     // issue in the above said frequency
     // Run the 1932 - selecting the frequency in other way
     if (packet_incr_pulse == 1'b1)
      cur_state <= IDLE;
     else
      cur_state <= PKT_OVER;
   end
   //
   default : begin
    cur_state <= IDLE;
   end
  endcase  
end

//------------------------------------------------------------------------------
// Header accept logic generation
// Insert the header accept for one clock when ever the state is header accept
assign pixel_header_accept_w = (cur_state == ACCEPT_HEADER) ? 1'b1 : 1'b0;

//------------------------------------------------------------------------------
// Data accept logic generation
// 1. The data accept should be asserted as soon the header is accepted
// 2. When ever the state is in data accept state
// 3. The data accept should be de-asserted along with pixel data valid
assign pixel_data_accept_w = (cur_state == ACCEPT_HEADER) ? 1'b1 : 
                             ((cur_state == DATA_ACCEPT) && (pixel_data_valid == 1'b1)) ? 1'b1 :
                             1'b0;
                             
//------------------------------------------------------------------------------
// This signal indicates the actual valid for the pixel data, this is generated
// only when respective pixel data is accpeted 
assign image_data_valid_w = (pixel_data_accept_w) & (pixel_data_valid) ;
assign image_data_w        = pixel_data;

//Delayed version of pixel_data, used by pixel2byte packing modules
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  image_data_delayed_r <= 32'b0;
 else if (tinit_start_csi_clk == 1'b0)
  image_data_delayed_r <= 32'b0;
 else if (image_data_valid_w == 1'b1)
  image_data_delayed_r <= image_data_w;
end

//------------------------------------------------------------------------------
// Falling edge detection
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)                     
  pixel_data_valid_d <= 1'b0;
 else if (tinit_start_csi_clk == 1'b0)
  pixel_data_valid_d <= 1'b0;
 else if (forcetxstopmode == 1'b1)
  pixel_data_valid_d <= 1'b0;   
 else
  pixel_data_valid_d <= pixel_data_valid;
end

assign sensor_pixel_vld_falling_edge_c = (~pixel_data_valid) & (pixel_data_valid_d);

/*
//Delayed version for other modules
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  sensor_pixel_vld_falling_edge_delayed_r <= 1'b0;
 else
  sensor_pixel_vld_falling_edge_delayed_r <= sensor_pixel_vld_falling_edge_c;
end

assign sensor_pixel_vld_falling_edge_delayed = sensor_pixel_vld_falling_edge_delayed_r;
*/

//------------------------------------------------------------------------------
// Pixel count : This signal is used by pixel2byte packing module in order to
// pack the pixel as specified in the specification. The MAX pixel count across
// all data type is 32 and hence the size
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  pixel_cnt_r <= 5'b0;
 else if (tinit_start_csi_clk == 1'b0)
  pixel_cnt_r <= 5'b0;
 else if (forcetxstopmode == 1'b1)
  pixel_cnt_r <= 5'b0;   
 else if (sensor_pixel_vld_falling_edge_c == 1'b1)
  pixel_cnt_r <= 5'b0;
 else if (image_data_valid_w == 1'b1)
  pixel_cnt_r <= pixel_cnt_r + 1'b1;
end

//------------------------------------------------------------------------------
// Pixel 2 Byte packing enable
// Based on the received data type respective bit in the register is enable
// This information is used in Pixel 2 Byte packing for enabling the respective
// packet
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
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  p2b_enable_r <= 32'b0;
 else if (tinit_start_csi_clk == 1'b0)
  p2b_enable_r <= 32'b0;
 else if (forcetxstopmode == 1'b1)
  p2b_enable_r <= 32'b0;   
 else if (sensor_pixel_vld_falling_edge_c == 1'b1)
  p2b_enable_r <= 32'b0;
 else if (pixel_header_accept == 1'b1)
  case (packet_header[5:0])
   `NULL_PKT         : p2b_enable_r[0]  <= 1'b1;
   `BLK_DATA         : p2b_enable_r[1]  <= 1'b1;
   `EMBEDDED_DATA    : p2b_enable_r[2]  <= 1'b1;
   `YUV420_8B        : p2b_enable_r[3]  <= 1'b1;
   `YUV420_10B       : p2b_enable_r[4]  <= 1'b1;
   `LYUV420_8B       : p2b_enable_r[5]  <= 1'b1;
   `YUV420_8B_CSPS   : p2b_enable_r[6]  <= 1'b1;
   `YUV420_10B_CSPS  : p2b_enable_r[7]  <= 1'b1;
   `YUV422_8B        : p2b_enable_r[8]  <= 1'b1;
   `YUV422_10B       : p2b_enable_r[9]  <= 1'b1;
   `RGB444           : p2b_enable_r[10] <= 1'b1;
   `RGB555           : p2b_enable_r[11] <= 1'b1;
   `RGB565           : p2b_enable_r[12] <= 1'b1;
   `RGB666           : p2b_enable_r[13] <= 1'b1;
   `RGB888           : p2b_enable_r[14] <= 1'b1;
   `RAW6             : p2b_enable_r[15] <= 1'b1;
   `RAW7             : p2b_enable_r[16] <= 1'b1;
   `RAW8             : p2b_enable_r[17] <= 1'b1;
   `RAW10            : p2b_enable_r[18] <= 1'b1;
   `RAW12            : p2b_enable_r[19] <= 1'b1;
   `RAW14            : p2b_enable_r[20] <= 1'b1;
   `USD_TYPE1        : p2b_enable_r[21] <= 1'b1;
   `USD_TYPE2        : p2b_enable_r[22] <= 1'b1;
   `USD_TYPE3        : p2b_enable_r[23] <= 1'b1;
   `USD_TYPE4        : p2b_enable_r[24] <= 1'b1;
   `USD_TYPE5        : p2b_enable_r[25] <= 1'b1;
   `USD_TYPE6        : p2b_enable_r[26] <= 1'b1;
   `USD_TYPE7        : p2b_enable_r[27] <= 1'b1;
   `USD_TYPE8        : p2b_enable_r[28] <= 1'b1;
   default           : p2b_enable_r     <= 32'b0;
  endcase
end

//------------------------------------------------------------------------------
// Selection line to de-multiplexer to select the byte data from the different
// byte 2 pixel modules
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  p2b_data_sel_r <= 5'b0;
 else if (tinit_start_csi_clk == 1'b0)
  p2b_data_sel_r <= 5'b0;
 else if (forcetxstopmode == 1'b1)
  p2b_data_sel_r <= 5'b0;   
 else if (pixel_header_accept == 1'b1)
  case (packet_header[5:0])
   `NULL_PKT         : p2b_data_sel_r <= 5'b00000;
   `BLK_DATA         : p2b_data_sel_r <= 5'b00001;
   `EMBEDDED_DATA    : p2b_data_sel_r <= 5'b00010;
   `YUV420_8B        : p2b_data_sel_r <= 5'b00011;
   `YUV420_10B       : p2b_data_sel_r <= 5'b00100;
   `LYUV420_8B       : p2b_data_sel_r <= 5'b00101;
   `YUV420_8B_CSPS   : p2b_data_sel_r <= 5'b00110;
   `YUV420_10B_CSPS  : p2b_data_sel_r <= 5'b00111;
   `YUV422_8B        : p2b_data_sel_r <= 5'b01000;
   `YUV422_10B       : p2b_data_sel_r <= 5'b01001;
   `RGB444           : p2b_data_sel_r <= 5'b01010;
   `RGB555           : p2b_data_sel_r <= 5'b01011;
   `RGB565           : p2b_data_sel_r <= 5'b01100;
   `RGB666           : p2b_data_sel_r <= 5'b01101;
   `RGB888           : p2b_data_sel_r <= 5'b01110;
   `RAW6             : p2b_data_sel_r <= 5'b01111;
   `RAW7             : p2b_data_sel_r <= 5'b10000;
   `RAW8             : p2b_data_sel_r <= 5'b10001;
   `RAW10            : p2b_data_sel_r <= 5'b10010;
   `RAW12            : p2b_data_sel_r <= 5'b10011;
   `RAW14            : p2b_data_sel_r <= 5'b10100;
   `USD_TYPE1        : p2b_data_sel_r <= 5'b10101;
   `USD_TYPE2        : p2b_data_sel_r <= 5'b10110;
   `USD_TYPE3        : p2b_data_sel_r <= 5'b10111;
   `USD_TYPE4        : p2b_data_sel_r <= 5'b11000;
   `USD_TYPE5        : p2b_data_sel_r <= 5'b11001;
   `USD_TYPE6        : p2b_data_sel_r <= 5'b11010;
   `USD_TYPE7        : p2b_data_sel_r <= 5'b11011;
   `USD_TYPE8        : p2b_data_sel_r <= 5'b11100;
   default           : p2b_data_sel_r <= 5'b00000;  
  endcase
end

//------------------------------------------------------------------------------
// YUV ODD/EVEN pixel channel logic generation
  
//Register the virtual channel on packet header accept
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  vc_r <= 2'b00;
 else if (tinit_start_csi_clk == 1'b0)
  vc_r <= 2'b00;  
 else if (pixel_header_accept == 1'b1)
  vc_r <= virtual_channel; 
end
 
 //Register the packet header informaiton
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if (clk_csi_rst_n == 1'b0)
  data_type_r <= 6'b0;
 else if (tinit_start_csi_clk == 1'b0)
  data_type_r <= 6'b0;  
 else if (pixel_header_accept == 1'b1)
  data_type_r <= packet_header[5:0]; 
end

//------------------------------------------------------------------------------ 
// Based on the channel number, even/odd is selected for legacy YUV format
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if ( clk_csi_rst_n == 1'b0 )
  lyuv4208b_odd_even_convrn_enable_vc_r <= 4'b1111; // Even
 else if ( tinit_start_csi_clk == 1'b0 )
  lyuv4208b_odd_even_convrn_enable_vc_r <= 4'b1111; // Even  
 else if ((pixel_header_accept == 1'b1) && (packet_header[5:0] == `LYUV420_8B))
  case ( virtual_channel )
   2'b00 : lyuv4208b_odd_even_convrn_enable_vc_r[0] <= ~lyuv4208b_odd_even_convrn_enable_vc_r[0];
   2'b01 : lyuv4208b_odd_even_convrn_enable_vc_r[1] <= ~lyuv4208b_odd_even_convrn_enable_vc_r[1];
   2'b10 : lyuv4208b_odd_even_convrn_enable_vc_r[2] <= ~lyuv4208b_odd_even_convrn_enable_vc_r[2];
   2'b11 : lyuv4208b_odd_even_convrn_enable_vc_r[3] <= ~lyuv4208b_odd_even_convrn_enable_vc_r[3];
   default : lyuv4208b_odd_even_convrn_enable_vc_r <= 4'b1111;
  endcase
end
 
always@(*) begin
 case(vc_r)
  2'b00 : lyuv4208b_odd_even_convrn_enable_s = lyuv4208b_odd_even_convrn_enable_vc_r[0];
  2'b01 : lyuv4208b_odd_even_convrn_enable_s = lyuv4208b_odd_even_convrn_enable_vc_r[1];
  2'b10 : lyuv4208b_odd_even_convrn_enable_s = lyuv4208b_odd_even_convrn_enable_vc_r[2];
  2'b11 : lyuv4208b_odd_even_convrn_enable_s = lyuv4208b_odd_even_convrn_enable_vc_r[3];
  default : lyuv4208b_odd_even_convrn_enable_s = 1'b1;
 endcase
end
 
//------------------------------------------------------------------------------
 // Based on the channel number, even/odd is selected for CSPS YUV 8b format
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if ( clk_csi_rst_n == 1'b0 )
  yuv4208b_csps_odd_even_convrn_enable_vc_r <= 4'b1111; // Even
 else if ( tinit_start_csi_clk == 1'b0 )
  yuv4208b_csps_odd_even_convrn_enable_vc_r <= 4'b1111; // Even
 else if ((pixel_header_accept == 1'b1) && (packet_header[5:0] == `YUV420_8B_CSPS))
  case (virtual_channel)
   2'b00 : yuv4208b_csps_odd_even_convrn_enable_vc_r[0] <= ~yuv4208b_csps_odd_even_convrn_enable_vc_r[0];
   2'b01 : yuv4208b_csps_odd_even_convrn_enable_vc_r[1] <= ~yuv4208b_csps_odd_even_convrn_enable_vc_r[1];
   2'b10 : yuv4208b_csps_odd_even_convrn_enable_vc_r[2] <= ~yuv4208b_csps_odd_even_convrn_enable_vc_r[2];
   2'b11 : yuv4208b_csps_odd_even_convrn_enable_vc_r[3] <= ~yuv4208b_csps_odd_even_convrn_enable_vc_r[3];
   default : yuv4208b_csps_odd_even_convrn_enable_vc_r <= 4'b1111;
  endcase
end
 
always@(*) begin
 case(vc_r)
  2'b00 : yuv4208b_csps_odd_even_convrn_enable_s = yuv4208b_csps_odd_even_convrn_enable_vc_r[0];
  2'b01 : yuv4208b_csps_odd_even_convrn_enable_s = yuv4208b_csps_odd_even_convrn_enable_vc_r[1];
  2'b10 : yuv4208b_csps_odd_even_convrn_enable_s = yuv4208b_csps_odd_even_convrn_enable_vc_r[2];
  2'b11 : yuv4208b_csps_odd_even_convrn_enable_s = yuv4208b_csps_odd_even_convrn_enable_vc_r[3];
  default : yuv4208b_csps_odd_even_convrn_enable_s = 1'b1;
 endcase
end
 
//------------------------------------------------------------------------------ 
 // Based on the channel number, even/odd is selected for CSPS YUV 10b format
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if ( clk_csi_rst_n == 1'b0 )
  yuv420_10b_csps_odd_even_convrn_enable_vc_r <= 4'b1111; // Even
 else if ( tinit_start_csi_clk == 1'b0 )
  yuv420_10b_csps_odd_even_convrn_enable_vc_r <= 4'b1111; // Even
 else if ((pixel_header_accept == 1'b1) && (packet_header[5:0] == `YUV420_10B_CSPS))
  case (virtual_channel)
   2'b00 : yuv420_10b_csps_odd_even_convrn_enable_vc_r[0] <= ~yuv420_10b_csps_odd_even_convrn_enable_vc_r[0];
   2'b01 : yuv420_10b_csps_odd_even_convrn_enable_vc_r[1] <= ~yuv420_10b_csps_odd_even_convrn_enable_vc_r[1];
   2'b10 : yuv420_10b_csps_odd_even_convrn_enable_vc_r[2] <= ~yuv420_10b_csps_odd_even_convrn_enable_vc_r[2];
   2'b11 : yuv420_10b_csps_odd_even_convrn_enable_vc_r[3] <= ~yuv420_10b_csps_odd_even_convrn_enable_vc_r[3];
   default : yuv420_10b_csps_odd_even_convrn_enable_vc_r <= 4'b1111;
  endcase
end
 
always@(*) begin
 case(vc_r)
  2'b00 : yuv420_10b_csps_odd_even_convrn_enable_s = yuv420_10b_csps_odd_even_convrn_enable_vc_r[0];
  2'b01 : yuv420_10b_csps_odd_even_convrn_enable_s = yuv420_10b_csps_odd_even_convrn_enable_vc_r[1];
  2'b10 : yuv420_10b_csps_odd_even_convrn_enable_s = yuv420_10b_csps_odd_even_convrn_enable_vc_r[2];
  2'b11 : yuv420_10b_csps_odd_even_convrn_enable_s = yuv420_10b_csps_odd_even_convrn_enable_vc_r[3];
  default : yuv420_10b_csps_odd_even_convrn_enable_s = 1'b1;
 endcase
end

//------------------------------------------------------------------------------ 
// Based on the channel number, even/odd is selected for  YUV 8b format
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if ( clk_csi_rst_n == 1'b0 )
  yuv4208b_odd_even_convrn_enable_vc_r <= 4'b1111; // Even
 else if ( tinit_start_csi_clk == 1'b0 )
  yuv4208b_odd_even_convrn_enable_vc_r <= 4'b1111; // Even
 else if ((pixel_header_accept == 1'b1) && (packet_header[5:0] == `YUV420_8B))
  case ( virtual_channel )
   2'b00 : yuv4208b_odd_even_convrn_enable_vc_r[0] <= ~yuv4208b_odd_even_convrn_enable_vc_r[0];
   2'b01 : yuv4208b_odd_even_convrn_enable_vc_r[1] <= ~yuv4208b_odd_even_convrn_enable_vc_r[1];
   2'b10 : yuv4208b_odd_even_convrn_enable_vc_r[2] <= ~yuv4208b_odd_even_convrn_enable_vc_r[2];
   2'b11 : yuv4208b_odd_even_convrn_enable_vc_r[3] <= ~yuv4208b_odd_even_convrn_enable_vc_r[3];
   default : yuv4208b_odd_even_convrn_enable_vc_r <= 4'b1111;
  endcase
end
 
always@(*) begin
 case(vc_r)
  2'b00 : yuv4208b_odd_even_convrn_enable_s = yuv4208b_odd_even_convrn_enable_vc_r[0];
  2'b01 : yuv4208b_odd_even_convrn_enable_s = yuv4208b_odd_even_convrn_enable_vc_r[1];
  2'b10 : yuv4208b_odd_even_convrn_enable_s = yuv4208b_odd_even_convrn_enable_vc_r[2];
  2'b11 : yuv4208b_odd_even_convrn_enable_s = yuv4208b_odd_even_convrn_enable_vc_r[3];
  default : yuv4208b_odd_even_convrn_enable_s = 1'b1;
 endcase
end

//------------------------------------------------------------------------------ 
// Based on the channel number, even/odd is selected for  YUV 10b format
always@(posedge clk_csi or negedge clk_csi_rst_n) begin
 if ( clk_csi_rst_n == 1'b0 )
  yuv420_10b_odd_even_convrn_enable_vc_r <= 4'b1111; // Even
 else if ( tinit_start_csi_clk == 1'b0 )
  yuv420_10b_odd_even_convrn_enable_vc_r <= 4'b1111; // Even
 else if ((pixel_header_accept == 1'b1) && (packet_header[5:0] == `YUV420_10B))
  case (virtual_channel)
   2'b00 : yuv420_10b_odd_even_convrn_enable_vc_r[0] <= ~yuv420_10b_odd_even_convrn_enable_vc_r[0];
   2'b01 : yuv420_10b_odd_even_convrn_enable_vc_r[1] <= ~yuv420_10b_odd_even_convrn_enable_vc_r[1];
   2'b10 : yuv420_10b_odd_even_convrn_enable_vc_r[2] <= ~yuv420_10b_odd_even_convrn_enable_vc_r[2];
   2'b11 : yuv420_10b_odd_even_convrn_enable_vc_r[3] <= ~yuv420_10b_odd_even_convrn_enable_vc_r[3];
   default : yuv420_10b_odd_even_convrn_enable_vc_r <= 4'b1111;
  endcase
end
 
always@(*) begin
 case(vc_r)
  2'b00 : yuv420_10b_odd_even_convrn_enable_s = yuv420_10b_odd_even_convrn_enable_vc_r[0];
  2'b01 : yuv420_10b_odd_even_convrn_enable_s = yuv420_10b_odd_even_convrn_enable_vc_r[1];
  2'b10 : yuv420_10b_odd_even_convrn_enable_s = yuv420_10b_odd_even_convrn_enable_vc_r[2];
  2'b11 : yuv420_10b_odd_even_convrn_enable_s = yuv420_10b_odd_even_convrn_enable_vc_r[3];
  default : yuv420_10b_odd_even_convrn_enable_s = 1'b1;
 endcase
end

//------------------------------------------------------------------------------
// Compression Technique
always @(posedge clk_csi or negedge clk_csi_rst_n) begin
 if(clk_csi_rst_n == 1'b0) begin
  d_vc0_comp_r[39:0]  <= 40'b0;
  d_vc1_comp_r[39:0]  <= 40'b0;
  d_vc2_comp_r[39:0]  <= 40'b0;
  d_vc3_comp_r[39:0]  <= 40'b0;
 end else begin
  d_vc0_comp_r[39:0] <= vc0_compression_reg; 
  d_vc1_comp_r[39:0] <= vc1_compression_reg; 
  d_vc2_comp_r[39:0] <= vc2_compression_reg; 
  d_vc3_comp_r[39:0] <= vc3_compression_reg; 
 end 
end

// Choose the appropriate compression register with respect to the channel
always @(*) begin
 case (vc_r) 
  2'd1    : vc_comp_reg_s = d_vc1_comp_r; 
  2'd2    : vc_comp_reg_s = d_vc2_comp_r; 
  2'd3    : vc_comp_reg_s = d_vc3_comp_r; 
  default : vc_comp_reg_s = d_vc0_comp_r;
 endcase
end 

// Choose the appropriate user defined type 
always @(*) begin
 case (data_type_r) 
   `USD_TYPE1 : comp_scheme_s = vc_comp_reg_s[4:0]; 
   `USD_TYPE2 : comp_scheme_s = vc_comp_reg_s[9:5]; 
   `USD_TYPE3 : comp_scheme_s = vc_comp_reg_s[14:10]; 
   `USD_TYPE4 : comp_scheme_s = vc_comp_reg_s[19:15]; 
   `USD_TYPE5 : comp_scheme_s = vc_comp_reg_s[24:20]; 
   `USD_TYPE6 : comp_scheme_s = vc_comp_reg_s[29:25]; 
   `USD_TYPE7 : comp_scheme_s = vc_comp_reg_s[34:30]; 
   `USD_TYPE8 : comp_scheme_s = vc_comp_reg_s[39:35]; 
   default    : comp_scheme_s = 5'b0; 
 endcase
end 

// If no compression or predictor algorithm is used then disable the compression
assign comp_en_c = ((comp_scheme_s[2:0] == 3'b000) || (comp_scheme_s[2:0] == 3'b111)) ? 1'b0 : 
                   (comp_scheme_s[4:3] == 2'b00)                                 ? 1'b0 : 1'b1;
                 
//------------------------------------------------------------------------------
// Ouput port assignment     
assign pixel_header_accept                    = pixel_header_accept_w;  
assign pixel_data_accept                      = pixel_data_accept_w;    
    
assign header_info                            = gen_sh_pkt_field_r;
assign header_info_valid                      = packet_header_valid_c;           
assign image_data_valid                       = image_data_valid_w;
assign image_data                             = image_data_w; 
assign image_data_delayed                     = image_data_delayed_r;  
assign sensor_pixel_vld_falling_edge          = sensor_pixel_vld_falling_edge_c;
assign pixel_cnt                              = pixel_cnt_r;
assign p2b_enable                             = p2b_enable_r;
assign p2b_data_sel                           = p2b_data_sel_r;
assign lyuv4208b_odd_even_convrn_enable       = lyuv4208b_odd_even_convrn_enable_s;
assign yuv4208b_csps_odd_even_convrn_enable   = yuv4208b_csps_odd_even_convrn_enable_s;
assign yuv420_10b_csps_odd_even_convrn_enable = yuv420_10b_csps_odd_even_convrn_enable_s;
assign yuv4208b_odd_even_convrn_enable        = yuv4208b_odd_even_convrn_enable_s;
assign yuv420_10b_odd_even_convrn_enable      = yuv420_10b_odd_even_convrn_enable_s;
assign comp_en                                = comp_en_c;       
assign comp_scheme                            = comp_scheme_s;                   

endmodule
