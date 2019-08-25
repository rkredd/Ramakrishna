/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_double_flop_sync.v
// Author      : SHYAM SUNDAR B S
// Version     : v1p2
// Abstract    : 
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`include "csi2tx_defines.v"
module csi2tx_double_flop_sync
  (
  input   rst_n      ,
  input   clk        ,
  input   in_data    ,
  output  out_data
  );

//----------------------------------------------------------------------------//
// internal signal declaration
//----------------------------------------------------------------------------//
reg out_data_s  ;
reg in_d        ;

//----------------------------------------------------------------------------//
// PROCESS FOR FIRST FLOPPING THE INPUT SIGNAL IN DESTINATION CLOCK
//----------------------------------------------------------------------------//
always @(posedge clk or negedge rst_n)
begin : out_proc
  if(!rst_n)
    in_d <= 1'b0;
  else
    in_d <= in_data;
end

//----------------------------------------------------------------------------//
// PROCESS FOR SECOND FLOPPING THE INPUT SIGNAL IN DESTINATION CLOCK
//----------------------------------------------------------------------------//
always @(posedge clk or negedge rst_n)
begin : out_1
  if(!rst_n)
    out_data_s   <= 1'b0;
  else
    out_data_s   <= in_d;
end

//----------------------------------------------------------------------------//
// assign internal signal onto output port
//----------------------------------------------------------------------------//
assign out_data = out_data_s;

endmodule
