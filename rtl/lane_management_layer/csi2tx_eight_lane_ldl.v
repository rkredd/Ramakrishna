/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_eight_lane_ldl.v
// Author      : SHYAM SUNDAR B. S
// Abstract    : 
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


===============================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//=============================================================================*/
`include "csi2tx_defines.v"
module csi2tx_eight_lane_ldl 
(
 input  wire        txbyteclkhs                ,
 input  wire        txbyteclkhs_rst_n          ,
 input  wire        tinit_start                ,
 input  wire        eight_lane_en              ,
 input  wire        csi_byte_fifo_empty        ,  
 input  wire        enable_hs_transmission     ,
 input  wire        short_packet               ,
 input  wire        forcetxstopmode            ,
 input  wire        eop_wr                     ,
 input  wire        eop_rd                     ,
 input  wire [7:0]  txreadyhs                  ,   
 input  wire        hs_exit_cnt_expired        ,
 input  wire        stop_state_dl              ,   
 input  wire [16:0] validated_word_cnt         ,
 input  wire [63:0] fifo_rd_data               ,
 output wire        wr_size_decr_pulse         ,
 output wire        fifo_rd_en                 ,
 output wire [63:0] txdatahs                   ,
 output wire [7:0]  txrequesths                ,
 output wire        hs_exit_cnt_decr_enable    ,
 output wire        header_info                ,
 output wire        tx_done
);
//------------------------------------------------------------------------------
// Internal signal declaration
parameter IDLE                = 3'b000;
parameter RD_HDR              = 3'b001;
parameter DLY                 = 3'b010;
parameter REQ_HS              = 3'b011;
parameter STOP_STATE          = 3'b100;
parameter HS_EXIT             = 3'b101;
reg [2:0] cur_state                ;
wire      fifo_hdr_read_c          ;
wire      fifo_read_on_hready_c    ;
reg [7:0] txrequesths_r            ;

//------------------------------------------------------------------------------
//
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  cur_state <= IDLE;
 else if (tinit_start == 1'b0)
  cur_state <= IDLE;
 else if (forcetxstopmode == 1'b1)
  cur_state <= IDLE;
 else
  case (cur_state)
   IDLE : begin
    if ((eight_lane_en == 1'b1) && (enable_hs_transmission == 1'b1) && (csi_byte_fifo_empty == 1'b0))
     cur_state <= RD_HDR;
    else
     cur_state <= IDLE;
   end
   RD_HDR : begin
    cur_state <= DLY;
   end
   // To accomodate read latency of FIFO
   DLY : begin
    cur_state <= REQ_HS;
   end
   REQ_HS : begin
    if ((txreadyhs[0] == 1'b1) && (short_packet == 1'b1))
     cur_state <= STOP_STATE;
    else if((txreadyhs[0] == 1'b1) && (eop_wr == 1'b1))
     cur_state <= STOP_STATE;
    else
     cur_state <= REQ_HS; 
   end
  STOP_STATE : begin
    if (stop_state_dl == 1'b1)
     cur_state <= HS_EXIT;
    else
     cur_state <= STOP_STATE;
   end
   HS_EXIT : begin
    if (hs_exit_cnt_expired == 1'b1)
     cur_state <= IDLE;
    else
     cur_state <= HS_EXIT;
   end
  endcase
end

assign hs_exit_cnt_decr_enable = (cur_state == HS_EXIT) ? 1'b1 : 1'b0;
//------------------------------------------------------------------------------
//
assign fifo_hdr_read_c       = (cur_state == RD_HDR ) ? 1'b1 : 1'b0;
assign header_info           = (cur_state == DLY    ) ? 1'b1 : 1'b0;
assign fifo_read_on_hready_c = (txreadyhs[0] & txrequesths[0] & !eop_rd);
assign fifo_rd_en            = fifo_hdr_read_c | fifo_read_on_hready_c; 
assign wr_size_decr_pulse    = ((cur_state == REQ_HS) && (txrequesths_r[0] == 1'b0)) ? 1'b1 : 1'b0;
assign tx_done                 = (cur_state == STOP_STATE) ? 1'b1 : 1'b0;
//------------------------------------------------------------------------------
// Txrequesths generation
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  txrequesths_r <= 8'b0000_0000;
 else if (tinit_start == 1'b0)
  txrequesths_r <= 8'b0000_0000;
 else if (forcetxstopmode == 1'b1)
  txrequesths_r <= 8'b0000_0000;
 else if (eop_wr == 1'b1)
  txrequesths_r <= 8'b0000_0000;
 else if ((short_packet == 1'b1) && (cur_state == REQ_HS) && (txrequesths[0] == 1'b1) && (txreadyhs[0] == 1'b1))
   txrequesths_r <= 8'b0000_0000;
 else if ((short_packet == 1'b1) && (cur_state == REQ_HS))
  txrequesths_r <= 8'b0000_1111;
 else if ((cur_state == REQ_HS) && (txrequesths_r[0] == 1'b0))
  if (validated_word_cnt >= 17'h8)
   txrequesths_r <= 8'b1111_1111;
  else
   case(validated_word_cnt[3:0])
    4'b0001 : txrequesths_r <= 8'b0000_0001;
    4'b0010 : txrequesths_r <= 8'b0000_0011;
    4'b0011 : txrequesths_r <= 8'b0000_0111;
    4'b0100 : txrequesths_r <= 8'b0000_1111;
    4'b0101 : txrequesths_r <= 8'b0001_1111;
    4'b0110 : txrequesths_r <= 8'b0011_1111;
    4'b0111 : txrequesths_r <= 8'b0111_1111;
    4'b1000 : txrequesths_r <= 8'b1111_1111;
   endcase 
  else if ((txrequesths_r[0] == 1'b1) && (txreadyhs[0] == 1'b1))
  if (validated_word_cnt >= 17'h8)
   txrequesths_r <= 8'b1111_1111;
  else
   case(validated_word_cnt[3:0])
    4'b0001 : txrequesths_r <= 8'b0000_0001;
    4'b0010 : txrequesths_r <= 8'b0000_0011;
    4'b0011 : txrequesths_r <= 8'b0000_0111;
    4'b0100 : txrequesths_r <= 8'b0000_1111;
    4'b0101 : txrequesths_r <= 8'b0001_1111;
    4'b0110 : txrequesths_r <= 8'b0011_1111;
    4'b0111 : txrequesths_r <= 8'b0111_1111;
    4'b1000 : txrequesths_r <= 8'b1111_1111;
   endcase   
end

assign txrequesths = txrequesths_r; 
assign txdatahs = fifo_rd_data;
endmodule
