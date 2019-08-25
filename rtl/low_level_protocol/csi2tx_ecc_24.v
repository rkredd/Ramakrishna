/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_ecc_24b.v
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
module csi2tx_ecc_24b
  (

  input   wire        txbyteclkhs         ,
  input   wire        txbyteclkhs_rst_n   ,
  input   wire        tinit_start         ,
  input   wire [23:0] data_in             ,
  input   wire        ecc_en              ,
  output  wire [5:0]  ecc_value           ,
  output  wire        ecc_value_valid
  );

//----------------------------------------------------------------------------//
// Internal signal declaration
//----------------------------------------------------------------------------//
reg   [5:0] ecc_value_r ;
wire  [5:0] parity      ;
wire        parity_0    ;
wire        parity_1    ;
wire        parity_2    ;
wire        parity_3    ;
wire        parity_4    ;
wire        parity_5    ;

//----------------------------------------------------------------------------//
// Parity calculation
//----------------------------------------------------------------------------//

  //PARITY-0 GENERATION
assign parity_0 = data_in[0]  ^ data_in[1]  ^ data_in[2]  ^ data_in[4]  ^
                  data_in[5]  ^ data_in[7]  ^ data_in[10] ^ data_in[11] ^
                  data_in[13] ^ data_in[16] ^ data_in[20] ^ data_in[21] ^
                  data_in[22] ^ data_in[23];

  //PARITY-1 GENERATION
assign parity_1 = data_in[0]  ^ data_in[1]  ^ data_in[3]  ^ data_in[4]  ^
                  data_in[6]  ^ data_in[8]  ^ data_in[10] ^ data_in[12] ^
                  data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[21] ^
                  data_in[22] ^ data_in[23];

  //PARITY-2 GENERATION
assign parity_2 = data_in[0]  ^ data_in[2]  ^ data_in[3]  ^ data_in[5]  ^
                  data_in[6]  ^ data_in[9]  ^ data_in[11] ^ data_in[12] ^
                  data_in[15] ^ data_in[18] ^ data_in[20] ^ data_in[21] ^
                  data_in[22];

  //PARITY-3 GENERATION
assign parity_3 = data_in[1]  ^ data_in[2]  ^ data_in[3]  ^ data_in[7]  ^
                  data_in[8]  ^ data_in[9]  ^ data_in[13] ^ data_in[14] ^
                  data_in[15] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^
                  data_in[23];

  //PARITY-4 GENERATION
assign parity_4 = data_in[4]  ^ data_in[5]  ^ data_in[6]  ^ data_in[7]  ^
                  data_in[8]  ^ data_in[9]  ^ data_in[16] ^ data_in[17] ^
                  data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^
                  data_in[23];

  //PARITY-5 GENERATION
assign parity_5 = data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^
                  data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^
                  data_in[18] ^ data_in[19] ^ data_in[21] ^ data_in[22] ^
                  data_in[23];

  //COMBINING PARITY BITS
assign parity = {parity_5,parity_4,parity_3,parity_2,parity_1,parity_0};

//----------------------------------------------------------------------------//
//PROCESS TO FLOP ECC VALUE
//----------------------------------------------------------------------------//
always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n)
begin
  if(!txbyteclkhs_rst_n)
    ecc_value_r <= 6'h0;
  else if (tinit_start == 1'b0)
    ecc_value_r <= 6'h0;
  else 
    ecc_value_r <= parity;
end


//----------------------------------------------------------------------------//
// assign the internal signal onto output port
//----------------------------------------------------------------------------//
assign ecc_value       = ecc_value_r;
assign ecc_value_valid = ecc_en;

endmodule
