/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_mux_based_sync.v
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
module csi2tx_mux_based_sync #
(
 parameter DATA_WIDTH        = 32,
 parameter INIT_VALUE        = 0
 )
  (
  input   wire clk_src                       ,
  input   wire clk_dest                      ,
  input   wire rsta_n                        ,
  input   wire rstb_n                        ,                   
  input   wire enable                        ,
  input   wire [DATA_WIDTH-1:0] in_data      ,
  output  wire [DATA_WIDTH-1:0] out_data
  );

//----------------------------------------------------------------------------//
// internal signal declaration
//----------------------------------------------------------------------------//
reg  [DATA_WIDTH-1:0] ff_q_r         ;
wire                enable_pulse_sync;
//----------------------------------------------------------------------------//
// Pulse synchronizer for synchronizing the enable pin
//----------------------------------------------------------------------------//

 csi2tx_sync_pulse u0_csi2tx_mux_sync_pulse(
    .clk_in(clk_src),
    .clk_out(clk_dest),
    .rsta_n(rsta_n),
    .rstb_n(rstb_n),
    .in_pulse(enable),
    .out_pulse(enable_pulse_sync)
    );

//----------------------------------------------------------------------------//
// Floping the mux out
//----------------------------------------------------------------------------//
always @(posedge clk_dest or negedge rstb_n)
begin : out_proc
  if(!rstb_n)
    ff_q_r <= INIT_VALUE;
  else if(enable_pulse_sync)
    ff_q_r <= in_data;
end


//----------------------------------------------------------------------------//
// assign internal signal onto output port
//----------------------------------------------------------------------------//
assign out_data = ff_q_r;

endmodule
