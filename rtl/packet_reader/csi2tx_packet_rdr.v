/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_packet_rdr.v
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
module csi2tx_packet_rdr 
(
 input  wire        txbyteclkhs                   ,
 input  wire        txbyteclkhs_rst_n               ,
 input  wire        packet_rcvd_indication_pulse  ,
 input  wire [63:0] sensor_fifo_rd_data           ,
 output wire        sensor_fifo_rd_enable         ,
 input  wire        tinit_start_txbyteclk         ,
 input  wire        forcetxstopmode               ,
 input  wire        sensor_fifo_empty             , 
 //Packet Interface Signals
 input  wire        packet_rdy                    ,
 input  wire        packet_data_rdy               ,
 output wire        packet_valid                  ,
 output wire [5:0]  packet_dt                     ,
 output wire [1:0]  packet_vc                     ,
 output wire [15:0] packet_wc_df                  ,
 output wire        packet_data_valid             ,
 output wire [63:0] packet_data
 );
 
//------------------------------------------------------------------------------
parameter IDLE               = 3'b000;
parameter FETCH_HDR          = 3'b001;
parameter CHK_HDR            = 3'b010;
parameter VALIDATE_SH_PKT    = 3'b011;
parameter CHK_LONG_PKT       = 3'b100;
parameter VALIDATE_LONG_PKT  = 3'b101;
parameter FIFO_WAIT          = 3'b110;
wire        packet_sent_indication_pulse  ;
reg  [15:0]  pkt_cnt_r                     ;
reg         less_than_8bytes_pkt_rcvd_r   ;
reg         less_than_4bytes_pkt_rcvd_r   ;
reg  [15:0] word_cnt_r                    ;
reg  [15:0] dw_validate_cnt_r             ;
reg         long_pkt_data_valid_r         ; 
reg  [2:0]  cur_state                     ;
//------------------------------------------------------------------------------
assign packet_sent_indication_pulse = (((cur_state == VALIDATE_LONG_PKT) && (packet_rdy == 1'b1) && (packet_data_rdy == 1'b1) && (word_cnt_r <= 16'h4)) |
                                      ((cur_state == FIFO_WAIT) && (word_cnt_r <= 16'h8) && (packet_data_rdy == 1'b1))) ;


//------------------------------------------------------------------------------
// To implement the store and forward mechanisim. The complete packet should
// be ready in the FIFO. Keep a counter to keep track of the same.
// Update the counter once the packet is received from the input sensor and 
// decrement the counter once it is validated to the packet interface
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  pkt_cnt_r <= 16'b0;
 else if (tinit_start_txbyteclk == 1'b0)
  pkt_cnt_r <= 16'b0;
 else if (forcetxstopmode == 1'b1)
  pkt_cnt_r <= 16'b0;
 else if ((packet_rcvd_indication_pulse == 1'b1) && (packet_sent_indication_pulse == 1'b0))
  pkt_cnt_r <= pkt_cnt_r + 1'b1;
 else if ((packet_rcvd_indication_pulse == 1'b0) && (packet_sent_indication_pulse == 1'b1))  
  pkt_cnt_r <= pkt_cnt_r - 1'b1;
end

//------------------------------------------------------------------------------
// Statemachine to control the data flow to packet interface
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  cur_state <= IDLE;
 else if (tinit_start_txbyteclk == 1'b0)
  cur_state <= IDLE;
 else if (forcetxstopmode == 1'b1)
  cur_state <= IDLE;
 else 
  case (cur_state)
   IDLE : begin
    // When ever the FIFO is non-empty and read out the data and validate to
    // packet interface and also check that no previous data is getting validated
     if ((sensor_fifo_empty == 1'b0) && (long_pkt_data_valid_r == 1'b0))
      cur_state <= FETCH_HDR;
     else
      cur_state <= IDLE;
   end
   //
   FETCH_HDR : begin
    cur_state <= CHK_HDR;
   end
   //
   CHK_HDR : begin
    if (sensor_fifo_rd_data[25:24] == 2'b01)
     cur_state <= VALIDATE_SH_PKT;
    else
     cur_state <= CHK_LONG_PKT;
   end
   //
   VALIDATE_SH_PKT : begin
    if (packet_rdy == 1'b1)
     cur_state <= IDLE;
    else
     cur_state <= VALIDATE_SH_PKT;
   end
   //
   CHK_LONG_PKT : begin
    if (pkt_cnt_r > 16'h0)
     cur_state <= VALIDATE_LONG_PKT;
    else
     cur_state <=CHK_LONG_PKT;
   end
   //
   VALIDATE_LONG_PKT : begin
    // if the received packet size is less than 4, the packet will be validated
    // along with the header so move to IDLE directly
    if ((packet_rdy == 1'b1) && (packet_data_rdy == 1'b1) && (word_cnt_r <= 16'h4))
     cur_state <= IDLE;
    else if (packet_rdy == 1'b1)
     cur_state <= FIFO_WAIT;
    else
     cur_state <= VALIDATE_LONG_PKT;
   end
   //
   FIFO_WAIT : begin
    if ((word_cnt_r <= 16'h8) && (packet_data_rdy == 1'b1))
     cur_state <= IDLE;
    else
     cur_state <= FIFO_WAIT;
   end
   //
   default : cur_state <= IDLE;
  endcase   
end

assign sensor_fifo_rd_enable = (cur_state == FETCH_HDR) | ((cur_state == VALIDATE_LONG_PKT) && (packet_rdy == 1'b1) && (less_than_4bytes_pkt_rcvd_r == 1'b1)) | 
                               ((cur_state == FIFO_WAIT) && (packet_data_rdy == 1'b1) && (less_than_8bytes_pkt_rcvd_r == 1'b1));
                          
//------------------------------------------------------------------------------
// This signal is to de-press the read if the received backet is <= 4 bytes
// this is reset when other new long packet is detected
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if ( txbyteclkhs_rst_n == 1'b0 )
  less_than_8bytes_pkt_rcvd_r <= 1'b1;
 else if (tinit_start_txbyteclk == 1'b0)
  less_than_8bytes_pkt_rcvd_r <= 1'b1;
 else if (forcetxstopmode == 1'b1)
  less_than_8bytes_pkt_rcvd_r <= 1'b1;
 else if ( cur_state == CHK_LONG_PKT )
  less_than_8bytes_pkt_rcvd_r <= 1'b1;
 // when validating the packet, check whther next read is required or not, because
 // the data is read one clock early
 else if ( (packet_rdy == 1'b1) && (packet_data_rdy == 1'b1) && (word_cnt_r <= 16'h8))
  less_than_8bytes_pkt_rcvd_r <= 1'b0;
end

//------------------------------------------------------------------------------
// This signal is to de-press the read if the received backet is <= 4 bytes
// when the state is validate_long_pkt
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if ( txbyteclkhs_rst_n == 1'b0 )
  less_than_4bytes_pkt_rcvd_r <= 1'b1;
 else if (tinit_start_txbyteclk == 1'b0)
  less_than_4bytes_pkt_rcvd_r <= 1'b1;
 else if (forcetxstopmode == 1'b1)
  less_than_4bytes_pkt_rcvd_r <= 1'b1;
 else if (cur_state == IDLE)
  less_than_4bytes_pkt_rcvd_r <= 1'b1;
 else if ( (cur_state == CHK_LONG_PKT) && (sensor_fifo_rd_data[23:8] <= 16'h4))
  less_than_4bytes_pkt_rcvd_r <= 1'b0;
end


//------------------------------------------------------------------------------
// Latch the word count  and decrement it for every read
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if ( txbyteclkhs_rst_n == 1'b0 )
  word_cnt_r <= 16'b0;
 else if (tinit_start_txbyteclk == 1'b0)
  word_cnt_r <= 16'b0;
 else if (forcetxstopmode == 1'b1)
  word_cnt_r <= 16'b0;
 else if ( cur_state == CHK_LONG_PKT )
   if (sensor_fifo_rd_data[23:8] <= 16'h4)
     word_cnt_r <= sensor_fifo_rd_data[23:8];
   else
     // -4 is substract as along with the header, 4bytes of payload
   // is also read out
     word_cnt_r <= sensor_fifo_rd_data[23:8] - 4'b0100;
 // decrement is not needed for small packet less than 4 bytes
 else if ( (cur_state == VALIDATE_LONG_PKT) && (sensor_fifo_rd_enable == 1'b1) && (word_cnt_r >= 16'h8))
  word_cnt_r <= word_cnt_r - 16'h8;
 else if ( (long_pkt_data_valid_r == 1'b1) && (packet_data_rdy == 1'b1) && (word_cnt_r >= 16'h8) )
  word_cnt_r <= word_cnt_r - 16'h8;
end    


//------------------------------------------------------------------------------
// Latch the word count  and decrement it for every read
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if ( txbyteclkhs_rst_n == 1'b0 )
  dw_validate_cnt_r <= 16'b0;
 else if (tinit_start_txbyteclk == 1'b0)
  dw_validate_cnt_r <= 16'b0;
 else if (forcetxstopmode == 1'b1)
  dw_validate_cnt_r <= 16'b0;   
 else if ( cur_state == CHK_LONG_PKT )
  dw_validate_cnt_r <= sensor_fifo_rd_data[23:8];
 else if ( (packet_rdy == 1'b1) && (packet_data_rdy == 1'b1) && (dw_validate_cnt_r >= 16'h4) )
  dw_validate_cnt_r <= dw_validate_cnt_r - 16'h4;
 else if ( (long_pkt_data_valid_r == 1'b1) && (packet_data_rdy == 1'b1) && (dw_validate_cnt_r >= 16'h8) )
  dw_validate_cnt_r <= dw_validate_cnt_r - 16'h8;
end

//------------------------------------------------------------------------------
// The following section of the code includes the logic releated to
// packet interface                                                                                        
                
assign packet_valid = (cur_state == VALIDATE_SH_PKT) | (cur_state == VALIDATE_LONG_PKT) ; 
assign packet_dt    =  sensor_fifo_rd_data[5:0];
assign packet_vc    =  sensor_fifo_rd_data[7:6];
assign packet_wc_df =  sensor_fifo_rd_data[23:8];
 
// Long packet data valid generation
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n ) begin
 if ( txbyteclkhs_rst_n == 1'b0 )
  long_pkt_data_valid_r <= 1'b0;
 else if (forcetxstopmode == 1'b1) 
  long_pkt_data_valid_r <= 1'b0;   
 else if (tinit_start_txbyteclk == 1'b0)
  long_pkt_data_valid_r <= 1'b0;
 //for smaller packet where the length is less than 4-bytes, the packet_rdy is
 // a must
 else if ( (dw_validate_cnt_r <= 16'h8) && (packet_data_rdy == 1'b1) && (packet_rdy == 1'b0) )
  long_pkt_data_valid_r <= 1'b0;
 else if ((cur_state == VALIDATE_LONG_PKT) && (packet_rdy == 1'b1) && (dw_validate_cnt_r > 16'h4))
  long_pkt_data_valid_r <= 1'b1;
end
 
assign packet_data_valid = long_pkt_data_valid_r;
assign packet_data       = long_pkt_data_valid_r ? sensor_fifo_rd_data : {30'b0,sensor_fifo_rd_data[25:24],sensor_fifo_rd_data[63:32]};

// End of logic related to packet interface                                                 
//------------------------------------------------------------------------------                     

endmodule
