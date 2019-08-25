/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_RA2SD1024x64.v
// Author      : R.Dinesh Kumar
// Version     : v1p2
// Abstract    : This is module is used to get the 64k output from the 2 32k RAM      
//              
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
//

`timescale 1 ps / 1 ps
`include "csi2tx_defines.v"
 
module csi2tx_RA2SD1024x64 (
  output wire [63:0] QA         ,
  input  wire        CLKA       ,
  input  wire        CENA_N     ,
  input  wire        WENA_N     ,
  input  wire [`SENSOR_FIFO_ADDR_WIDTH-1:0]  AA         ,
  input  wire [63:0] DA         ,
  output wire [63:0] QB         ,
  input  wire        CLKB       ,
  input  wire        CENB_N     ,
  input  wire        WENB_N     ,
  input  wire [`SENSOR_FIFO_ADDR_WIDTH-1:0]  AB         ,
  input  wire [63:0] DB
  );
 
//------------------------------------------------------------------------------//
csi2tx_RA2SD1024x32
 u0_csi_tx_RA2SD1024x32 
(
  .QA        ( QA[31:0]    ),
  .CLKA      ( CLKA        ),
  .CENA_N    ( CENA_N      ),
  .WENA_N    ( WENA_N      ),
  .AA        ( AA          ),
  .DA        ( DA[31:0]    ),
  .QB        ( QB[31:0]    ),
  .QB_valid  ( /* open */  ),
  .CLKB      ( CLKB        ),
  .CENB_N    ( CENB_N      ),
  .WENB_N    ( WENB_N      ),
  .AB        ( AB          ),
  .DB        ( DB[31:0]    )
 );

csi2tx_RA2SD1024x32
 u1_csi_tx_RA2SD1024x32 
(
  .QA         ( QA[63:32]   ),
  .CLKA       ( CLKA        ),
  .CENA_N     ( CENA_N      ),
  .WENA_N     ( WENA_N      ),
  .AA         ( AA          ),
  .DA         ( DA[63:32]   ),
  .QB         ( QB[63:32]   ),
  .QB_valid   ( /* open */  ),
  .CLKB       ( CLKB        ),
  .CENB_N     ( CENB_N      ),
  .WENB_N     ( WENB_N      ),
  .AB         ( AB          ),
  .DB         ( DB[63:32]   )
  );
endmodule
