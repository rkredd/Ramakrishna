/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_crc16_d64.v
// Author      : SHYAM SUNDAR B. S.
// Version     : v1p2
// Abstract    : This module calculates the CRC for the received payload and
//               checks with the received CRC for any errors.
//               If any mismatch flags the error. 
//               If error to be masked, does the same and fowards the packet
//
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`include "csi2tx_defines.v" 
module csi2tx_crc16_d64
(
 input  wire        rxbyteclkhs           ,
 input  wire        rxbyteclkhs_rst_n     ,
 input  wire        forcetxstopmode       ,
 input  wire [63:0] rxdatahs              ,
 input  wire        rxdatahs_vld          ,
 input  wire [3:0]  valid_bytes           ,
 input  wire        eop                   ,
 input  wire        tinit_start           ,                                            
 output wire        crc_valid             ,
 output wire [15:0] crc 
);

//============================================================================//
// Internal Signal Declaration
//===========================================================================//

reg  [15:0]   p_crc                    ;
wire [15:0]   n_crc_8                  ;
wire [15:0]   n_crc_16                 ;
wire [15:0]   n_crc_24                 ;
wire [15:0]   n_crc_32                 ;
wire [15:0]   n_crc_40                 ;
wire [15:0]   n_crc_48                 ;
wire [15:0]   n_crc_56                 ;
wire [15:0]   n_crc_64                 ;
reg  [63:0]   rxdatahs_r               ;
wire [63:0]   rxdatahs_c               ;
reg           chk_crc_en_r             ;
reg           chk_crc_en_r_d           ; 
                 
//============================================================================//
// Intermediate CRC equations
//============================================================================//
// D[7:0] CRC equations
assign n_crc_8[15] = p_crc[7]  ^ p_crc[3]    ^ rxdatahs_c[3] ^ rxdatahs_c[7]                                            ;
assign n_crc_8[14] = p_crc[6]  ^ p_crc[2]    ^ rxdatahs_c[2] ^ rxdatahs_c[6]                                            ;
assign n_crc_8[13] = p_crc[5]  ^ p_crc[1]    ^ rxdatahs_c[1] ^ rxdatahs_c[5]                                            ;
assign n_crc_8[12] = p_crc[4]  ^ p_crc[0]    ^ rxdatahs_c[0] ^ rxdatahs_c[4]                                            ;
assign n_crc_8[11] = p_crc[3]  ^ rxdatahs_c[3]                                                                          ;
assign n_crc_8[10] = p_crc[2]  ^ rxdatahs_c[2] ^ p_crc[7]    ^ p_crc[3]    ^ rxdatahs_c[3] ^ rxdatahs_c[7]              ;
assign n_crc_8[9]  = p_crc[1]  ^ rxdatahs_c[1] ^ p_crc[6]    ^ p_crc[2]    ^ rxdatahs_c[2] ^ rxdatahs_c[6]              ;
assign n_crc_8[8]  = p_crc[0]  ^ rxdatahs_c[0] ^ p_crc[5]    ^ p_crc[1]    ^ rxdatahs_c[1] ^ rxdatahs_c[5]              ;
assign n_crc_8[7]  = p_crc[15] ^ p_crc[4]    ^ p_crc[0]    ^ rxdatahs_c[0] ^ rxdatahs_c[4]                              ;
assign n_crc_8[6]  = p_crc[14] ^ p_crc[3]    ^ rxdatahs_c[3]                                                            ;
assign n_crc_8[5]  = p_crc[13] ^ p_crc[2]    ^ rxdatahs_c[2]                                                            ;
assign n_crc_8[4]  = p_crc[12] ^ p_crc[1]    ^ rxdatahs_c[1]                                                            ;
assign n_crc_8[3]  = p_crc[11] ^ p_crc[0]    ^ rxdatahs_c[0] ^ p_crc[7]    ^ p_crc[3]    ^ rxdatahs_c[3] ^ rxdatahs_c[7];
assign n_crc_8[2]  = p_crc[10] ^ p_crc[6]    ^ p_crc[2]    ^ rxdatahs_c[2] ^ rxdatahs_c[6]                              ;
assign n_crc_8[1]  = p_crc[9]  ^ p_crc[5]    ^ p_crc[1]    ^ rxdatahs_c[1] ^ rxdatahs_c[5]                              ;
assign n_crc_8[0]  = p_crc[8]  ^ p_crc[4]    ^ p_crc[0]    ^ rxdatahs_c[0] ^ rxdatahs_c[4]                              ;
// D[15:0] CRC equations
assign n_crc_16[15] = n_crc_8[7]  ^ n_crc_8[3]   ^ rxdatahs_c[11] ^ rxdatahs_c[15]                                                 ;
assign n_crc_16[14] = n_crc_8[6]  ^ n_crc_8[2]   ^ rxdatahs_c[10] ^ rxdatahs_c[14]                                                 ;
assign n_crc_16[13] = n_crc_8[5]  ^ n_crc_8[1]   ^ rxdatahs_c[9]  ^ rxdatahs_c[13]                                                 ;
assign n_crc_16[12] = n_crc_8[4]  ^ n_crc_8[0]   ^ rxdatahs_c[8]  ^ rxdatahs_c[12]                                                 ;
assign n_crc_16[11] = n_crc_8[3]  ^ rxdatahs_c[11]                                                                                 ;
assign n_crc_16[10] = n_crc_8[2] ^ rxdatahs_c[10]  ^ n_crc_8[7]   ^ n_crc_8[3]   ^ rxdatahs_c[11] ^ rxdatahs_c[15]                 ;
assign n_crc_16[9]  = n_crc_8[1]  ^ rxdatahs_c[9]  ^ n_crc_8[6]   ^ n_crc_8[2]   ^ rxdatahs_c[10] ^ rxdatahs_c[14]                 ;
assign n_crc_16[8]  = n_crc_8[0]  ^ rxdatahs_c[8]  ^ n_crc_8[5]   ^ n_crc_8[1]   ^ rxdatahs_c[9]  ^ rxdatahs_c[13]                 ;
assign n_crc_16[7]  = n_crc_8[15] ^ n_crc_8[4]   ^ n_crc_8[0]   ^ rxdatahs_c[8]  ^ rxdatahs_c[12]                                  ;
assign n_crc_16[6]  = n_crc_8[14] ^ n_crc_8[3]   ^ rxdatahs_c[11]                                                                  ;
assign n_crc_16[5]  = n_crc_8[13] ^ n_crc_8[2]   ^ rxdatahs_c[10]                                                                  ;
assign n_crc_16[4]  = n_crc_8[12] ^ n_crc_8[1]   ^ rxdatahs_c[9]                                                                   ;
assign n_crc_16[3]  = n_crc_8[11] ^ n_crc_8[0]   ^ rxdatahs_c[8]  ^ n_crc_8[7]   ^ n_crc_8[3]    ^ rxdatahs_c[11] ^ rxdatahs_c[15] ;
assign n_crc_16[2]  = n_crc_8[10] ^ n_crc_8[6]   ^ n_crc_8[2]   ^ rxdatahs_c[10] ^ rxdatahs_c[14]                                  ;
assign n_crc_16[1]  = n_crc_8[9]  ^ n_crc_8[5]   ^ n_crc_8[1]   ^ rxdatahs_c[9]  ^ rxdatahs_c[13]                                  ;
assign n_crc_16[0]  = n_crc_8[8]  ^ n_crc_8[4]   ^ n_crc_8[0]   ^ rxdatahs_c[8]  ^ rxdatahs_c[12]                                  ;                                                                                                                                                 
// D[23:16] CRC equatoions
assign n_crc_24[15] = n_crc_16[7]  ^ n_crc_16[3] ^ rxdatahs_c[19] ^ rxdatahs_c[23]                                                  ;
assign n_crc_24[14] = n_crc_16[6]  ^ n_crc_16[2] ^ rxdatahs_c[18] ^ rxdatahs_c[22]                                                  ;
assign n_crc_24[13] = n_crc_16[5]  ^ n_crc_16[1] ^ rxdatahs_c[17] ^ rxdatahs_c[21]                                                  ;
assign n_crc_24[12] = n_crc_16[4]  ^ n_crc_16[0] ^ rxdatahs_c[16] ^ rxdatahs_c[20]                                                  ;
assign n_crc_24[11] = n_crc_16[3]  ^ rxdatahs_c[19]                                                                                 ;
assign n_crc_24[10] = n_crc_16[2]  ^ rxdatahs_c[18]     ^ n_crc_16[7] ^ n_crc_16[3] ^ rxdatahs_c[19] ^ rxdatahs_c[23]               ;
assign n_crc_24[9] =  n_crc_16[1]  ^ rxdatahs_c[17]     ^ n_crc_16[6] ^ n_crc_16[2] ^ rxdatahs_c[18] ^ rxdatahs_c[22]               ;
assign n_crc_24[8] =  n_crc_16[0]  ^ rxdatahs_c[16]     ^ n_crc_16[5] ^ n_crc_16[1] ^ rxdatahs_c[17] ^ rxdatahs_c[21]               ;
assign n_crc_24[7] =  n_crc_16[15] ^ n_crc_16[4] ^ n_crc_16[0] ^ rxdatahs_c[16]     ^ rxdatahs_c[20]                                ;
assign n_crc_24[6] =  n_crc_16[14] ^ n_crc_16[3] ^ rxdatahs_c[19]                                                                   ;
assign n_crc_24[5] =  n_crc_16[13] ^ n_crc_16[2] ^ rxdatahs_c[18]                                                                   ;
assign n_crc_24[4] =  n_crc_16[12] ^ n_crc_16[1] ^ rxdatahs_c[17]                                                                   ;
assign n_crc_24[3] =  n_crc_16[11] ^ n_crc_16[0] ^ rxdatahs_c[16]     ^ n_crc_16[7] ^ n_crc_16[3] ^ rxdatahs_c[19] ^ rxdatahs_c[23] ;
assign n_crc_24[2] =  n_crc_16[10] ^ n_crc_16[6] ^ n_crc_16[2] ^ rxdatahs_c[18]     ^ rxdatahs_c[22]                                ;
assign n_crc_24[1] =  n_crc_16[9]  ^ n_crc_16[5] ^ n_crc_16[1] ^ rxdatahs_c[17]     ^ rxdatahs_c[21]                                ;
assign n_crc_24[0] =  n_crc_16[8]  ^ n_crc_16[4] ^ n_crc_16[0] ^ rxdatahs_c[16]     ^ rxdatahs_c[20]                                ;
// D[31:24] CRC equations
assign n_crc_32[15] = n_crc_24[7] ^ n_crc_24[3] ^ rxdatahs_c[27]     ^ rxdatahs_c[31]                                             ;
assign n_crc_32[14] = n_crc_24[6] ^ n_crc_24[2] ^ rxdatahs_c[26]     ^ rxdatahs_c[30]                                             ;
assign n_crc_32[13] = n_crc_24[5] ^ n_crc_24[1] ^ rxdatahs_c[25]     ^ rxdatahs_c[29]                                             ;
assign n_crc_32[12] = n_crc_24[4] ^ n_crc_24[0] ^ rxdatahs_c[24]     ^ rxdatahs_c[28]                                             ;
assign n_crc_32[11] = n_crc_24[3] ^ rxdatahs_c[27]                                                                                ;
assign n_crc_32[10] = n_crc_24[2] ^ rxdatahs_c[26]     ^ n_crc_24[7] ^ n_crc_24[3] ^ rxdatahs_c[27] ^ rxdatahs_c[31]              ;
assign n_crc_32[9] = n_crc_24[1]  ^ rxdatahs_c[25]     ^ n_crc_24[6] ^ n_crc_24[2] ^ rxdatahs_c[26] ^ rxdatahs_c[30]              ;
assign n_crc_32[8] = n_crc_24[0]  ^ rxdatahs_c[24]     ^ n_crc_24[5] ^ n_crc_24[1] ^ rxdatahs_c[25] ^ rxdatahs_c[29]              ;
assign n_crc_32[7] = n_crc_24[15] ^ n_crc_24[4] ^ n_crc_24[0] ^ rxdatahs_c[24]     ^ rxdatahs_c[28]                               ;
assign n_crc_32[6] = n_crc_24[14] ^ n_crc_24[3] ^ rxdatahs_c[27]                                                                  ;
assign n_crc_32[5] = n_crc_24[13] ^ n_crc_24[2] ^ rxdatahs_c[26]                                                                  ;
assign n_crc_32[4] = n_crc_24[12] ^ n_crc_24[1] ^ rxdatahs_c[25]                                                                  ;
assign n_crc_32[3] = n_crc_24[11] ^ n_crc_24[0] ^ rxdatahs_c[24]     ^ n_crc_24[7] ^ n_crc_24[3] ^ rxdatahs_c[27] ^ rxdatahs_c[31];
assign n_crc_32[2] = n_crc_24[10] ^ n_crc_24[6] ^ n_crc_24[2] ^ rxdatahs_c[26]     ^ rxdatahs_c[30]                               ;
assign n_crc_32[1] = n_crc_24[9]  ^ n_crc_24[5] ^ n_crc_24[1] ^ rxdatahs_c[25]     ^ rxdatahs_c[29]                               ;
assign n_crc_32[0] = n_crc_24[8]  ^ n_crc_24[4] ^ n_crc_24[0] ^ rxdatahs_c[24]     ^ rxdatahs_c[28]                               ;
// D[39:32] CRC equations            
assign n_crc_40[15] = n_crc_32[7]  ^ n_crc_32[3]  ^ rxdatahs_c[35]  ^ rxdatahs_c[39]                                             ;
assign n_crc_40[14] = n_crc_32[6]  ^ n_crc_32[2]  ^ rxdatahs_c[34]  ^ rxdatahs_c[38]                                             ;
assign n_crc_40[13] = n_crc_32[5]  ^ n_crc_32[1]  ^ rxdatahs_c[33]  ^ rxdatahs_c[37]                                             ;
assign n_crc_40[12] = n_crc_32[4]  ^ n_crc_32[0]  ^ rxdatahs_c[32]  ^ rxdatahs_c[36]                                             ;
assign n_crc_40[11] = n_crc_32[3]  ^ rxdatahs_c[35]                                                                              ;
assign n_crc_40[10] = n_crc_32[2]  ^ rxdatahs_c[34] ^ n_crc_32[7]   ^ n_crc_32[3] ^ rxdatahs_c[35] ^ rxdatahs_c[39]              ;
assign n_crc_40[9]  = n_crc_32[1]  ^ rxdatahs_c[33] ^ n_crc_32[6]   ^ n_crc_32[2] ^ rxdatahs_c[34] ^ rxdatahs_c[38]              ;
assign n_crc_40[8]  = n_crc_32[0]  ^ rxdatahs_c[32] ^ n_crc_32[5]   ^ n_crc_32[1] ^ rxdatahs_c[33] ^ rxdatahs_c[37]              ;
assign n_crc_40[7]  = n_crc_32[15] ^ n_crc_32[4]  ^ n_crc_32[0]   ^ rxdatahs_c[32]     ^ rxdatahs_c[36]                          ;
assign n_crc_40[6]  = n_crc_32[14] ^ n_crc_32[3]  ^ rxdatahs_c[35]                                                               ;
assign n_crc_40[5]  = n_crc_32[13] ^ n_crc_32[2]  ^ rxdatahs_c[34]                                                               ;
assign n_crc_40[4]  = n_crc_32[12] ^ n_crc_32[1]  ^ rxdatahs_c[33]                                                               ;
assign n_crc_40[3]  = n_crc_32[11] ^ n_crc_32[0]  ^ rxdatahs_c[32]  ^ n_crc_32[7] ^ n_crc_32[3] ^ rxdatahs_c[35] ^ rxdatahs_c[39];
assign n_crc_40[2]  = n_crc_32[10] ^ n_crc_32[6]  ^ n_crc_32[2]   ^ rxdatahs_c[34]     ^ rxdatahs_c[38]                          ;
assign n_crc_40[1]  = n_crc_32[9]  ^ n_crc_32[5]  ^ n_crc_32[1]   ^ rxdatahs_c[33]     ^ rxdatahs_c[37]                          ;
assign n_crc_40[0]  = n_crc_32[8]  ^ n_crc_32[4]  ^ n_crc_32[0]   ^ rxdatahs_c[32]     ^ rxdatahs_c[36]                          ;
// D[47:40] CRC equations                                                                                                     
assign n_crc_48[15] = n_crc_40[7]  ^ n_crc_40[3]  ^ rxdatahs_c[43] ^ rxdatahs_c[47]                                               ;
assign n_crc_48[14] = n_crc_40[6]  ^ n_crc_40[2]  ^ rxdatahs_c[42] ^ rxdatahs_c[46]                                               ;
assign n_crc_48[13] = n_crc_40[5]  ^ n_crc_40[1]  ^ rxdatahs_c[41] ^ rxdatahs_c[45]                                               ;
assign n_crc_48[12] = n_crc_40[4]  ^ n_crc_40[0]  ^ rxdatahs_c[40] ^ rxdatahs_c[44]                                               ;
assign n_crc_48[11] = n_crc_40[3]  ^ rxdatahs_c[43]                                                                               ;
assign n_crc_48[10] = n_crc_40[2]  ^ rxdatahs_c[42] ^ n_crc_40[7]  ^ n_crc_40[3]  ^ rxdatahs_c[43]     ^ rxdatahs_c[47]           ;
assign n_crc_48[9]  = n_crc_40[1]  ^ rxdatahs_c[41] ^ n_crc_40[6]  ^ n_crc_40[2]  ^ rxdatahs_c[42]     ^ rxdatahs_c[46]           ;
assign n_crc_48[8]  = n_crc_40[0]  ^ rxdatahs_c[40] ^ n_crc_40[5]  ^ n_crc_40[1]  ^ rxdatahs_c[41]     ^ rxdatahs_c[45]           ;
assign n_crc_48[7]  = n_crc_40[15] ^ n_crc_40[4]  ^ n_crc_40[0]  ^ rxdatahs_c[40] ^ rxdatahs_c[44]                                ;
assign n_crc_48[6]  = n_crc_40[14] ^ n_crc_40[3]  ^ rxdatahs_c[43]                                                                ;
assign n_crc_48[5]  = n_crc_40[13] ^ n_crc_40[2]  ^ rxdatahs_c[42]                                                                ;
assign n_crc_48[4]  = n_crc_40[12] ^ n_crc_40[1]  ^ rxdatahs_c[41]                                                                ;
assign n_crc_48[3]  = n_crc_40[11] ^ n_crc_40[0]  ^ rxdatahs_c[40] ^ n_crc_40[7]  ^ n_crc_40[3] ^ rxdatahs_c[43] ^ rxdatahs_c[47] ;
assign n_crc_48[2]  = n_crc_40[10] ^ n_crc_40[6]  ^ n_crc_40[2]  ^ rxdatahs_c[42] ^ rxdatahs_c[46]                                ;
assign n_crc_48[1]  = n_crc_40[9]  ^ n_crc_40[5]  ^ n_crc_40[1]  ^ rxdatahs_c[41] ^ rxdatahs_c[45]                                ;
assign n_crc_48[0]  = n_crc_40[8]  ^ n_crc_40[4]  ^ n_crc_40[0]  ^ rxdatahs_c[40] ^ rxdatahs_c[44]                                ;
// D[55:48] CRC equations                                                                                                     
assign n_crc_56[15] = n_crc_48[7]  ^ n_crc_48[3]  ^ rxdatahs_c[51] ^ rxdatahs_c[55]                                               ;
assign n_crc_56[14] = n_crc_48[6]  ^ n_crc_48[2]  ^ rxdatahs_c[50] ^ rxdatahs_c[54]                                               ;
assign n_crc_56[13] = n_crc_48[5]  ^ n_crc_48[1]  ^ rxdatahs_c[49] ^ rxdatahs_c[53]                                               ;
assign n_crc_56[12] = n_crc_48[4]  ^ n_crc_48[0]  ^ rxdatahs_c[48] ^ rxdatahs_c[52]                                               ;
assign n_crc_56[11] = n_crc_48[3]  ^ rxdatahs_c[51]                                                                               ;
assign n_crc_56[10] = n_crc_48[2]  ^ rxdatahs_c[50] ^ n_crc_48[7]  ^ n_crc_48[3]  ^ rxdatahs_c[51] ^ rxdatahs_c[55]               ;
assign n_crc_56[9]  = n_crc_48[1]  ^ rxdatahs_c[49] ^ n_crc_48[6]  ^ n_crc_48[2]  ^ rxdatahs_c[50] ^ rxdatahs_c[54]               ;
assign n_crc_56[8]  = n_crc_48[0]  ^ rxdatahs_c[48] ^ n_crc_48[5]  ^ n_crc_48[1]  ^ rxdatahs_c[49] ^ rxdatahs_c[53]               ;
assign n_crc_56[7]  = n_crc_48[15] ^ n_crc_48[4]  ^ n_crc_48[0]  ^ rxdatahs_c[48] ^ rxdatahs_c[52]                                ;
assign n_crc_56[6]  = n_crc_48[14] ^ n_crc_48[3]  ^ rxdatahs_c[51]                                                                ;
assign n_crc_56[5]  = n_crc_48[13] ^ n_crc_48[2]  ^ rxdatahs_c[50]                                                                ;
assign n_crc_56[4]  = n_crc_48[12] ^ n_crc_48[1]  ^ rxdatahs_c[49]                                                                ;
assign n_crc_56[3]  = n_crc_48[11] ^ n_crc_48[0]  ^ rxdatahs_c[48] ^ n_crc_48[7]  ^ n_crc_48[3]  ^ rxdatahs_c[51] ^ rxdatahs_c[55];
assign n_crc_56[2]  = n_crc_48[10] ^ n_crc_48[6]  ^ n_crc_48[2]  ^ rxdatahs_c[50] ^ rxdatahs_c[54]                                ;
assign n_crc_56[1]  = n_crc_48[9]  ^ n_crc_48[5]  ^ n_crc_48[1]  ^ rxdatahs_c[49] ^ rxdatahs_c[53]                                ;
assign n_crc_56[0]  = n_crc_48[8]  ^ n_crc_48[4]  ^ n_crc_48[0]  ^ rxdatahs_c[48] ^ rxdatahs_c[52]                                ;
// D[63:56] CRC equations
assign n_crc_64[15] = n_crc_56[7]  ^ n_crc_56[3]  ^ rxdatahs_c[59] ^ rxdatahs_c[63]                                               ;
assign n_crc_64[14] = n_crc_56[6]  ^ n_crc_56[2]  ^ rxdatahs_c[58] ^ rxdatahs_c[62]                                               ;
assign n_crc_64[13] = n_crc_56[5]  ^ n_crc_56[1]  ^ rxdatahs_c[57] ^ rxdatahs_c[61]                                               ;
assign n_crc_64[12] = n_crc_56[4]  ^ n_crc_56[0]  ^ rxdatahs_c[56] ^ rxdatahs_c[60]                                               ;
assign n_crc_64[11] = n_crc_56[3]  ^ rxdatahs_c[59]                                                                               ;
assign n_crc_64[10] = n_crc_56[2]  ^ rxdatahs_c[58] ^ n_crc_56[7]  ^ n_crc_56[3]  ^ rxdatahs_c[59] ^ rxdatahs_c[63]               ;
assign n_crc_64[9]  = n_crc_56[1]  ^ rxdatahs_c[57] ^ n_crc_56[6]  ^ n_crc_56[2]  ^ rxdatahs_c[58] ^ rxdatahs_c[62]               ;
assign n_crc_64[8]  = n_crc_56[0]  ^ rxdatahs_c[56] ^ n_crc_56[5]  ^ n_crc_56[1]  ^ rxdatahs_c[57] ^ rxdatahs_c[61]               ;
assign n_crc_64[7]  = n_crc_56[15] ^ n_crc_56[4]  ^ n_crc_56[0]  ^ rxdatahs_c[56] ^ rxdatahs_c[60]                                ;
assign n_crc_64[6]  = n_crc_56[14] ^ n_crc_56[3]  ^ rxdatahs_c[59]                                                                ;
assign n_crc_64[5]  = n_crc_56[13] ^ n_crc_56[2]  ^ rxdatahs_c[58]                                                                ;
assign n_crc_64[4]  = n_crc_56[12] ^ n_crc_56[1]  ^ rxdatahs_c[57]                                                                ;
assign n_crc_64[3]  = n_crc_56[11] ^ n_crc_56[0]  ^ rxdatahs_c[56] ^ n_crc_56[7]  ^ n_crc_56[3]  ^ rxdatahs_c[59] ^ rxdatahs_c[63];
assign n_crc_64[2]  = n_crc_56[10] ^ n_crc_56[6]  ^ n_crc_56[2]  ^ rxdatahs_c[58] ^ rxdatahs_c[62]                                ;
assign n_crc_64[1]  = n_crc_56[9]  ^ n_crc_56[5]  ^ n_crc_56[1]  ^ rxdatahs_c[57] ^ rxdatahs_c[61]                                ;
assign n_crc_64[0]  = n_crc_56[8]  ^ n_crc_56[4]  ^ n_crc_56[0]  ^ rxdatahs_c[56] ^ rxdatahs_c[60]                                ;

//=============================================================================//
// End of CRC intermediate equations
//=============================================================================//

//=============================================================================//
// Feedback the next CRC to the next data for the calculation
// Based on the Valid bytes received, respective intermediate CRC data is
// passed
//=============================================================================// 
always@(posedge rxbyteclkhs or negedge rxbyteclkhs_rst_n)
begin
 if (rxbyteclkhs_rst_n == 1'b0)
  p_crc <= 'hFFFF;
 else if(!tinit_start)
  p_crc <= 'hFFFF;
 else if (forcetxstopmode == 1'b1)
   p_crc <= 'hFFFF;
 else if (chk_crc_en_r_d == 1'b1)
  p_crc <= 'hFFFF;
 else if (rxdatahs_vld == 1'b1 )
  case(valid_bytes)
   4'b0001 : p_crc <= n_crc_8;
   4'b0010 : p_crc <= n_crc_16;
   4'b0011 : p_crc <= n_crc_24;
   4'b0100 : p_crc <= n_crc_32;
   4'b0101 : p_crc <= n_crc_40;
   4'b0110 : p_crc <= n_crc_48;
   4'b0111 : p_crc <= n_crc_56;
   default : p_crc <= n_crc_64;
  endcase
end

assign crc = p_crc;
//=============================================================================//
// Internally register the data based on valid signal, even when the data changes
// when there is no valid. There should not be any imapct on the CRC
//=============================================================================//
always@(posedge rxbyteclkhs or negedge rxbyteclkhs_rst_n)
begin
 if (rxbyteclkhs_rst_n == 1'b0)
  rxdatahs_r <= 'b0;
 else if(!tinit_start)
  rxdatahs_r <= 'b0;
 else if (forcetxstopmode == 1'b1)
  rxdatahs_r <= 'b0;
 else if (rxdatahs_vld == 1'b1)
  rxdatahs_r <= rxdatahs;
end

assign rxdatahs_c = (rxdatahs_vld == 1'b1) ? rxdatahs : rxdatahs_r;

//==============================================================================//
// Delay the EOP by One clock to check the rxed CRC with the calculated CRC
// this delay is needed, as the p_crc is regisistered version and one clock
// delay in getting the update CRC value
//==============================================================================//
always@(posedge rxbyteclkhs or negedge rxbyteclkhs_rst_n)
begin
 if ( rxbyteclkhs_rst_n == 1'b0 ) begin
  chk_crc_en_r <= 1'b0;
  chk_crc_en_r_d <= 1'b0;
 end else if(!tinit_start) begin
  chk_crc_en_r <= 1'b0;
  chk_crc_en_r_d <= 1'b0;
 end else begin
  chk_crc_en_r <= eop;
  chk_crc_en_r_d <= chk_crc_en_r;
 end
end

assign crc_valid = chk_crc_en_r;

endmodule
