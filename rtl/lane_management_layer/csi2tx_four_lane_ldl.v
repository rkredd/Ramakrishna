/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_four_lane_ldl.v
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
module csi2tx_four_lane_ldl 
(
 input  wire        txbyteclkhs                ,
 input  wire        txbyteclkhs_rst_n          ,
 input  wire        tinit_start                ,
 input  wire        four_lane_en               ,
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
 output wire [31:0] txdatahs                   ,
 output wire [3:0]  txrequesths                ,
 output wire        hs_exit_cnt_decr_enable    ,
 output wire        header_info                ,
 output wire        tx_done 
);

parameter IDLE                = 3'b000;
parameter RD_HDR              = 3'b001;
parameter DLY                 = 3'b010;
parameter REQ_HS              = 3'b011;
parameter STOP_STATE          = 3'b100;
parameter HS_EXIT             = 3'b101;
reg [2:0] cur_state                ;
wire      fifo_hdr_read_c          ;
reg [3:0] txrequesths_r            ;
reg [31:0] txdatahs_s              ;
reg [0:0]  data_mux_cnt_r          ;
reg        fifo_read_on_hready_s   ;
//------------------------------------------------------------------------------
// Internal signal declaration
// 5 Continuous read + 2 -dips
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  cur_state <= IDLE;
 else if (forcetxstopmode == 1'b1)
  cur_state <= IDLE;
 else
  case(cur_state)
   IDLE : begin
    if ((four_lane_en == 1'b1) && (enable_hs_transmission == 1'b1) && (csi_byte_fifo_empty == 1'b0))
     cur_state <= RD_HDR;
    else
     cur_state <= IDLE;
   end 
   RD_HDR : begin
    cur_state <= DLY;
   end
   DLY : begin
    cur_state <= REQ_HS;
   end
   REQ_HS : begin
    if ((txreadyhs[0] == 1'b1) && (short_packet == 1'b1))
     cur_state <= STOP_STATE;
    else if ((txreadyhs[0] == 1'b1) && (eop_wr == 1'b1))
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
assign fifo_hdr_read_c         = (cur_state == RD_HDR) ? 1'b1 : 1'b0;
assign header_info             = (cur_state == DLY) ? 1'b1 : 1'b0;

//------------------------------------------------------------------------------
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  data_mux_cnt_r <= 1'b0;
 else if (cur_state == IDLE)
  data_mux_cnt_r <= 1'b0;
 else if ((txreadyhs[0] == 1'b1) && (txrequesths[0] == 1'b1))
  data_mux_cnt_r <= ~data_mux_cnt_r; 
end

//------------------------------------------------------------------------------
// This logic control the read enable to FIFO. As it is 5-lane distrubution
// there will be enough data to give out DPHY. The FIFO is read 5-clock
// continuously and de-asserted for 2-clock before resumming
always@(*) begin
 if (cur_state == REQ_HS)
  if ((data_mux_cnt_r != 1'b1))
   fifo_read_on_hready_s = 1'b0;
  else
   fifo_read_on_hready_s = (txreadyhs[0] & txrequesths[0] & !eop_rd);
 else
  fifo_read_on_hready_s = 1'b0;
end

assign fifo_rd_en              = (fifo_hdr_read_c | fifo_read_on_hready_s); 
assign wr_size_decr_pulse      = ((cur_state == REQ_HS) && (txrequesths_r[0] == 1'b0)) ? 1'b1 : 1'b0;
assign tx_done                 = (cur_state == STOP_STATE) ? 1'b1 : 1'b0;
//------------------------------------------------------------------------------
// Request HS generation
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
 if (txbyteclkhs_rst_n == 1'b0)
  txrequesths_r <= 4'b0000;
 else if (tinit_start == 1'b0)
  txrequesths_r <= 4'b0000;
 else if (forcetxstopmode == 1'b1)
  txrequesths_r <= 4'b0000;
 else if (eop_wr == 1'b1)
  txrequesths_r <= 4'b0000;
 else if ((short_packet == 1'b1) && (cur_state == REQ_HS) && (txrequesths[0] == 1'b1) && (txreadyhs[0] == 1'b1))
   txrequesths_r <= 4'b0000;
 else if ((short_packet == 1'b1) && (cur_state == REQ_HS))
  txrequesths_r <= 4'b1111;
 else if ((cur_state == REQ_HS) && (txrequesths_r[0] == 1'b0))
  if (validated_word_cnt >= 17'h4)
   txrequesths_r <= 4'b1111;
  else
   case(validated_word_cnt[1:0])
    2'b01 : txrequesths_r <= 4'b0001;
    2'b10 : txrequesths_r <= 4'b0011;
    2'b11 : txrequesths_r <= 4'b0111;
   endcase 
  else if ((txrequesths_r[0] == 1'b1) && (txreadyhs[0] == 1'b1))
  if (validated_word_cnt >= 17'h4)
   txrequesths_r <= 4'b1111;
  else
   case(validated_word_cnt[1:0])
    2'b01 : txrequesths_r <= 4'b0001;
    2'b10 : txrequesths_r <= 4'b0011;
    2'b11 : txrequesths_r <= 4'b0111;
   endcase 
end

always@(*) begin
 case(data_mux_cnt_r)
  1'b0  : txdatahs_s = fifo_rd_data[31:0];
  1'b1  : txdatahs_s = fifo_rd_data[63:32];
  default : txdatahs_s = fifo_rd_data[31:0];
 endcase
end

assign txrequesths = txrequesths_r;
assign txdatahs = txdatahs_s;

endmodule
