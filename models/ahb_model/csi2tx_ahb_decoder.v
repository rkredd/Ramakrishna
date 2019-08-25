/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_ahb_decoder.v
// Author      : SANDEEPA S M
// Version     : v1p2
// Abstract    : This model decodes the the corresponding slave among the multiple 
//               slaves for read and write opration
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`timescale 1 ps / 1 ps
module csi2tx_ahb_decoder
    (
        //INPUT SIGNALS
        input     [31:0]        haddr , // 32-BIT SYSTEM ADDR BUS

        //OUTPUT SIGNALS
        output    reg           hsel1 , // SLAVE SELECT 1
        output    reg           hsel2 , // SLAVE SELECT 2
        output    reg           hsel3   // SLAVE SELECT 3
    );

 //========================================================//
 //  LOGIC TO SELECT THE SLAVE DEPENDS ON ADDRESS PRIORITY 
 //========================================================//
  
     always @(haddr)
       begin
         if (haddr >= 32'h00 && haddr <= 32'h0000007c)
           begin
             hsel1 <= 1'b0;
             hsel2 <= 1'b1;
             hsel3 <= 1'b0;
           end
         else if ( haddr >= 32'h00003004 && haddr <=32'h00006000)
           begin
             hsel1 <= 1'b1;
             hsel2 <= 1'b0;
             hsel3 <= 1'b0;
           end
         else
           begin
             hsel1 <= 1'b0;
             hsel2 <= 1'b0;
             hsel3 <= 1'b1;
           end
       end

endmodule
