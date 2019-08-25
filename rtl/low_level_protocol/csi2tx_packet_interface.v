/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_packet_interface.v
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
module csi2tx_packet_interface 
(
 input  wire         txbyteclkhs                 ,
 input  wire         txbyteclkhs_rst_n           ,
 input   wire        tinit_start_byteclkhs       ,
 input   wire        forcetxstopmode             ,
 //Packet Interface Signals                      ,
 output  wire        packet_rdy                  ,  
 output  wire        packet_data_rdy             ,  
 input   wire        packet_valid                ,  
 input   wire [5:0]  packet_dt                   ,  
 input   wire [1:0]  packet_vc                   ,  
 input   wire [15:0] packet_wc_df                ,  
 input   wire        packet_data_valid           ,  
 input   wire [63:0] packet_data                 ,
 input   wire        fifo_almost_full            ,
 input   wire        txreadyhs_fall_pulse        ,
 output  wire [63:0] byte_aligned_data           ,
 output  wire        byte_aligned_data_valid     
 
 );
//------------------------------------------------------------------------------

parameter IDLE               = 3'b000 ;
parameter CHK_FIFO_SPACE_AV  = 3'b001 ;
parameter ACCEPT_HEADER      = 3'b010 ;
parameter WAIT_STATE         = 3'b011 ;
parameter DATA_ACCEPT        = 3'b100 ;
parameter PKT_OVER           = 3'b101 ;

reg         sh_pkt_rcvd_r                         ;
reg [2:0]   cur_state                             ;
wire        packet_rdy_w                          ;
wire        packet_data_rdy_w                     ;
wire [5:0]  ecc_value_w                           ;
wire        ecc_value_valid_w                     ;
wire [3:0]  valid_bytes_c                         ;
reg  [15:0] word_cnt_r                            ;
reg  [63:0] byte_aligned_data_r                   ;
wire [15:0] crc_w                                 ;
wire [23:0] header                                ;
wire        eop_pkt_sht_data_pkt_c                ;
wire        eop_long_data_pkt_c                   ;
wire        eop_c                                 ;
reg  [63:0] byte_aligned_data_s                   ;
reg         crc_data_valid_d                      ;
reg         long_data_pkt_crc_additional_valid_r  ;
reg         sht_data_pkt_crc_additional_valid_r   ;
reg         eop_pkt_sht_data_pkt_c_d              ;
reg         eop_long_data_pkt_c_d                 ;
wire        crc_valid_c                           ;
wire        crc_data_valid_c                      ;


 
//------------------------------------------------------------------------------
// The following signal will get asserted when ever an generic short packet is 
// received, this signal is used to control the state machine flow
//------------------------------------------------------------------------------
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  sh_pkt_rcvd_r <= 1'b0;
 else if (tinit_start_byteclkhs == 1'b0)
  sh_pkt_rcvd_r <= 1'b0;
 else if (forcetxstopmode == 1'b1)
  sh_pkt_rcvd_r <= 1'b0;
 else if ((packet_valid == 1'b1) && 
 ((packet_dt == `GEN_SH_PKT1) || (packet_dt == `GEN_SH_PKT2) || 
  (packet_dt == `GEN_SH_PKT3) || (packet_dt == `GEN_SH_PKT4) || 
  (packet_dt == `GEN_SH_PKT5) || (packet_dt == `GEN_SH_PKT6) || 
  (packet_dt == `GEN_SH_PKT7) || (packet_dt == `GEN_SH_PKT8) ||
  (packet_dt == `FRAME_START) || (packet_dt == `FRAME_END)   ||
  (packet_dt == `LINE_START)  || (packet_dt == `LINE_END)))
  sh_pkt_rcvd_r <= 1'b1;
 else
  sh_pkt_rcvd_r <= 1'b0;
end

//------------------------------------------------------------------------------
// The following state machine control the flow in accepting the long packet
//------------------------------------------------------------------------------
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  cur_state <= IDLE;
 else if (tinit_start_byteclkhs == 1'b0)
  cur_state <= IDLE;
 else if (forcetxstopmode == 1'b1)
   cur_state <= IDLE;
 else
  case(cur_state)
   // Wait for the packet header assertion
   IDLE : begin
    if (packet_valid == 1'b1)
     cur_state <= CHK_FIFO_SPACE_AV;
    else
     cur_state <= IDLE;
   end
   // Check is enough space is available in the sensor FIFO to accomodate a new
   // frame
   CHK_FIFO_SPACE_AV : begin
    if (fifo_almost_full == 1'b0)
     cur_state <= ACCEPT_HEADER;
    else
     cur_state <= CHK_FIFO_SPACE_AV;
   end 
   // Accept the header information by asserting the header acept for a clock and
   // as per the protocol assert the data accept as well in this state
   ACCEPT_HEADER : begin
    if (sh_pkt_rcvd_r == 1'b1)
     cur_state <= PKT_OVER;
    else if ((sh_pkt_rcvd_r == 1'b0) && (packet_valid == 1'b1) && (packet_rdy_w == 1'b1) && (packet_wc_df <= 16'h4))
     cur_state <= PKT_OVER;
    else if (fifo_almost_full == 1'b0)
     cur_state <= DATA_ACCEPT;
    else
     cur_state <= WAIT_STATE;
   end
   // If not enough space is available in the FIFO wait until space get free
   WAIT_STATE : begin
    if ((fifo_almost_full == 1'b0) && (packet_data_valid == 1'b1))
     cur_state <= DATA_ACCEPT;
    else if (packet_data_valid == 1'b0)
     cur_state <= PKT_OVER;
    else
     cur_state <= WAIT_STATE;
   end
   //
   DATA_ACCEPT : begin
    if (fifo_almost_full == 1'b1)
     cur_state <= WAIT_STATE;
    else if (packet_data_valid == 1'b0)
     cur_state <= PKT_OVER;
    else
     cur_state <= DATA_ACCEPT;
   end
   //
   PKT_OVER : begin
     if (txreadyhs_fall_pulse == 1'b1)
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
assign packet_rdy_w = (cur_state == ACCEPT_HEADER) ? 1'b1 : 1'b0;

//------------------------------------------------------------------------------
// Data accept logic generation
// 1. The data accept should be asserted as soon the header is accepted
// 2. When ever the state is in data accept state
// 3. The data accept should be de-asserted along with pixel data valid
assign packet_data_rdy_w =   (cur_state == ACCEPT_HEADER) ? 1'b1 : 
                             ((cur_state == DATA_ACCEPT) && (packet_data_valid == 1'b1)) ? 1'b1 :
                             1'b0;
//-----------------------------------------------------------------------------
assign header = {packet_wc_df,packet_vc,packet_dt}; 

//------------------------------------------------------------------------------
//ECC component instantiation
csi2tx_ecc_24b
 u_csi2tx_ecc_24b
  (
  .txbyteclkhs         ( txbyteclkhs                    ),
  .txbyteclkhs_rst_n   ( txbyteclkhs_rst_n              ),
  .tinit_start         ( tinit_start_byteclkhs          ),
  .data_in             ( header                         ),
  .ecc_en              ( packet_rdy_w                   ),
  .ecc_value           ( ecc_value_w                    ),
  .ecc_value_valid     ( ecc_value_valid_w              )
  );
  
//------------------------------------------------------------------------------
assign valid_bytes_c = ((packet_rdy_w == 1'b1) && (packet_data[33:32] == 2'b10) && (packet_wc_df <= 16'h4)) ? packet_wc_df[3:0] : 
                       ((packet_rdy_w == 1'b1) && (packet_data[33:32] == 2'b10) && (packet_wc_df >  16'h4)) ? 4'b0100 : 
                       ((word_cnt_r <= 16'h8) && (packet_data_rdy_w == 1'b1)) ? word_cnt_r[3:0] : 4'b1000;



//------------------------------------------------------------------------------
// Extract the packet word count
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  word_cnt_r <= 16'b0;
 else if (forcetxstopmode == 1'b1)
   word_cnt_r <= 16'h0;
 else if ((packet_rdy_w == 1'b1) && (packet_data[33:32] == 2'b10))
   if (packet_wc_df <= 16'h4)
     word_cnt_r <= packet_wc_df;
   else
     word_cnt_r <= packet_wc_df - 16'h4;
 else if ((packet_data_valid == 1'b1) && (packet_data_rdy_w == 1'b1) && (word_cnt_r > 16'h8))
  word_cnt_r <= word_cnt_r - 4'b1000; 
end


//------------------------------------------------------------------------------
// Use the Byte_data_r register to append the ECC field and CRC field
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  byte_aligned_data_r <= 64'b0;
 else if (forcetxstopmode == 1'b1)
   byte_aligned_data_r <= 64'b0;
 else if (ecc_value_valid_w == 1'b1)
  byte_aligned_data_r <= {packet_data[31:0],2'b00,ecc_value_w,header[23:0]};
 else if ((packet_data_valid == 1'b1) && (packet_data_rdy_w == 1'b1))
  byte_aligned_data_r <= packet_data;  
end

//------------------------------------------------------------------------------
// CRC calculation and component instantiation
assign crc_data_valid_c = (((packet_data_valid & packet_data_rdy_w) | packet_rdy_w ) & (!sh_pkt_rcvd_r));

assign eop_pkt_sht_data_pkt_c = ((packet_rdy_w == 1'b1) && (packet_data[33:32] == 2'b10) && (packet_wc_df <= 16'h4)) ? 1'b1 : 1'b0;
assign eop_long_data_pkt_c    = ((packet_data_valid == 1'b1) && (packet_data_rdy_w == 1'b1) && (word_cnt_r <= 16'h8)) ? 1'b1 : 1'b0;
assign eop_c                  = (eop_pkt_sht_data_pkt_c | eop_long_data_pkt_c );

csi2tx_crc16_d64
 u_csi2tx_crc16_d64
(
 .rxbyteclkhs             (txbyteclkhs            ),
 .rxbyteclkhs_rst_n       (txbyteclkhs_rst_n      ),
 .forcetxstopmode         (forcetxstopmode        ),
 .rxdatahs                (packet_data            ),
 .rxdatahs_vld            (crc_data_valid_c       ),
 .valid_bytes             (valid_bytes_c          ),
 .eop                     (eop_c                  ),
 .tinit_start             (tinit_start_byteclkhs  ),                                            
 .crc_valid               (crc_valid_c            ),
 .crc                     (crc_w                  )
);

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// This logic is to validated the CRC of the packet when the received packet is
// short packet that is less than 4-bytes and this requires an extra write to
// valid to perform in order to validate the CRC data
// 1-byte packet : {8'b0, CRC, data[8], header}
// 2-byte packet : { crc, data[16], header }
// 3-byte packet : {crc[8], data[24], header }
//                 {56'b0, crc[8]} -- valid generation
// 4-byte packet : {data[32], header}
//               : {48'b0, crc} -valid generation

always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0) begin
  eop_pkt_sht_data_pkt_c_d <= 1'b0; 
  eop_long_data_pkt_c_d <= 1'b0;
 end else begin
  eop_pkt_sht_data_pkt_c_d <= eop_pkt_sht_data_pkt_c;
  eop_long_data_pkt_c_d    <= eop_long_data_pkt_c;
 end
end

always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0) 
  crc_data_valid_d <= 1'b0;   
 else
  crc_data_valid_d <= ((packet_data_valid & packet_data_rdy_w) | packet_rdy_w );  
end

always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  sht_data_pkt_crc_additional_valid_r <= 1'b0;
 else if ((eop_pkt_sht_data_pkt_c_d == 1'b1) && ((word_cnt_r[3:0] == 4'b0011) || (word_cnt_r[3:0] == 4'b0100)))
  sht_data_pkt_crc_additional_valid_r <= 1'b1;
 else
  sht_data_pkt_crc_additional_valid_r <= 1'b0;
end

always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  long_data_pkt_crc_additional_valid_r <= 1'b0;
 else if ((eop_long_data_pkt_c_d == 1'b1) && ((word_cnt_r[3:0] == 4'b0111) || (word_cnt_r[3:0] == 4'b1000)))
  long_data_pkt_crc_additional_valid_r <= 1'b1;
 else
  long_data_pkt_crc_additional_valid_r <= 1'b0;
end

//------------------------------------------------------------------------------
// Appending the CRC to data
always@(*) begin
 if ((crc_valid_c == 1'b1) && (eop_pkt_sht_data_pkt_c_d == 1'b1))
  case(word_cnt_r[2:0])
   3'b001  : byte_aligned_data_s = {8'b0, crc_w, byte_aligned_data_r[39:0]};
   3'b010  : byte_aligned_data_s = {crc_w, byte_aligned_data_r[47:0]};
   3'b011  : byte_aligned_data_s = {crc_w[7:0], byte_aligned_data_r[55:0]};
   default : byte_aligned_data_s = byte_aligned_data_r;    
  endcase
 else if (sht_data_pkt_crc_additional_valid_r == 1'b1)
  case(word_cnt_r[2:0])
   3'b011  : byte_aligned_data_s = {56'b0, crc_w[15:8]};
   default : byte_aligned_data_s = {48'b0, crc_w};
  endcase
 else if ((crc_valid_c == 1'b1) && (eop_long_data_pkt_c_d == 1'b1))
  case(word_cnt_r[3:0])
   4'b0001 : byte_aligned_data_s = {40'b0,crc_w,byte_aligned_data_r[7:0]};
   4'b0010 : byte_aligned_data_s = {32'b0,crc_w,byte_aligned_data_r[15:0]}; 
   4'b0011 : byte_aligned_data_s = {24'b0,crc_w,byte_aligned_data_r[23:0]};
   4'b0100 : byte_aligned_data_s = {16'b0,crc_w,byte_aligned_data_r[31:0]};  
   4'b0101 : byte_aligned_data_s = {8'b0 ,crc_w,byte_aligned_data_r[39:0]};    
   4'b0110 : byte_aligned_data_s = {crc_w,byte_aligned_data_r[47:0]};
   4'b0111 : byte_aligned_data_s = {crc_w[7:0],byte_aligned_data_r[55:0]};
   4'b1000 : byte_aligned_data_s = byte_aligned_data_r;
   default : byte_aligned_data_s = byte_aligned_data_r;
  endcase
  else if (long_data_pkt_crc_additional_valid_r == 1'b1)
   case(word_cnt_r[3:0])
    4'b0111 : byte_aligned_data_s = {56'b0, crc_w[15:8]};
    4'b1000 : byte_aligned_data_s = {48'b0, crc_w};
    default : byte_aligned_data_s = byte_aligned_data_r;
   endcase
 else
  byte_aligned_data_s = byte_aligned_data_r;
end

assign byte_aligned_data       = byte_aligned_data_s;
assign byte_aligned_data_valid = (crc_data_valid_d | long_data_pkt_crc_additional_valid_r |  sht_data_pkt_crc_additional_valid_r);
//-----------------------------------------------------------------------------
//output assignment
assign packet_rdy = packet_rdy_w;
assign packet_data_rdy = packet_data_rdy_w;
 

endmodule
