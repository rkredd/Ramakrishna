/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_decoder_bfm.v
// Author      : CSI TEAM
// Version     : v1p2
// Abstract    : This model decompress the corresponding compression schemes
//               w.r.t the input configuration.
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`timescale 1ns / 1ps

module csi2rx_decoder_bfm (
    enc_data_ip,
    enc_data_vld,
    num_pxls_per_line,
    dec_data_op,
    dec_data_vld,
    config_reg
  );
  
  /*----------------------------------------------------------------------------
     Input & Output Port Declaration
  -----------------------------------------------------------------------------*/
  input  wire                  [7:0] enc_data_ip;  // input can be 6/7/8 bits
  input  wire                        enc_data_vld; // One bit qualifier for the input encoded data
  input  wire                 [15:0] num_pxls_per_line; 
  input  wire                  [4:0] config_reg;   // [4:3] Predoction Mode, [2:0] Encoding Technique
  output wire                        dec_data_vld; // One bit qualifier for the ouptut decoded data
  output reg                  [11:0] dec_data_op;  // output can be 10/12 bits
  
  /*---------------------------------------------------------------------------
     Bus Structure of config reg
    
     Bit [2:0] -> “001” -> 10-6-10 Format is selected
     Bit [2:0] -> “010” -> 10-7-10 Format is selected
     Bit [2:0] -> “011” -> 10-8-10 Format is selected
     Bit [2:0] -> “100” -> 12-6-12 Format is selected
     Bit [2:0] -> “101” -> 12-7-12 Format is selected
     Bit [2:0] -> “110” -> 12-8-12 Format is selected
     Bit   [3] -> ‘1’:  -> Prediction-1 Algorithm 
     Bit   [4] -> ‘1’   -> Prediction-2 Algorithm  
  ----------------------------------------------------------------------------*/
  /*---------------------------------------------------------------------------
     Declaration of Internal Registers & Nets
  ----------------------------------------------------------------------------*/

  reg   [11:0]                       dec_op_mem [0:4096];  
  reg   [11:0]                       pred_mode2_op;
  reg   [11:0]                       pixel;
  reg                                force_2nd_pxl_vld ;
  reg   [11:0]                       pixel_rd;
  reg   [11:0]                       pred_mode1_op; 
  wire  [11:0]                       pred_op;
  wire  [11:0]                       val_10_6_10_dpcm3;
  wire  [11:0]                       val_10_6_10_dpcm4;
  wire  [11:0]                       val_10_6_10_dpcm5;
  wire  [11:0]                       val_10_6_10_pcm;
  wire  [11:0]                       val_10_7_10_dpcm1;
  wire  [11:0]                       val_10_7_10_dpcm2;
  wire  [11:0]                       val_10_7_10_dpcm3;
  wire  [11:0]                       val_10_7_10_dpcm4;
  wire  [11:0]                       val_10_7_10_pcm; 
  wire  [11:0]                       val_10_8_10_dpcm1;
  wire  [11:0]                       val_10_8_10_dpcm2;
  wire  [11:0]                       val_10_8_10_dpcm3;
  wire  [11:0]                       val_10_8_10_pcm;
  wire  [11:0]                       val_12_6_12_dpcm1;
  wire  [11:0]                       val_12_6_12_dpcm3;
  wire  [11:0]                       val_12_6_12_dpcm4;
  wire  [11:0]                       val_12_6_12_dpcm5;
  wire  [11:0]                       val_12_6_12_dpcm6;
  wire  [11:0]                       val_12_6_12_dpcm7;
  wire  [11:0]                       val_12_6_12_pcm;
  wire  [11:0]                       val_12_7_12_dpcm1;
  wire  [11:0]                       val_12_7_12_dpcm2;
  wire  [11:0]                       val_12_7_12_dpcm3;
  wire  [11:0]                       val_12_7_12_dpcm4;
  wire  [11:0]                       val_12_7_12_dpcm5;
  wire  [11:0]                       val_12_7_12_dpcm6;
  wire  [11:0]                       val_12_7_12_pcm;
  wire  [11:0]                       val_12_8_12_dpcm1;
  wire  [11:0]                       val_12_8_12_dpcm2;
  wire  [11:0]                       val_12_8_12_dpcm3;
  wire  [11:0]                       val_12_8_12_dpcm4;
  wire  [11:0]                       val_12_8_12_dpcm5;
  wire  [11:0]                       val_12_8_12_pcm;
  wire  [12:0]                       pred_m_10_6_10_dpcm5;
  wire  [12:0]                       pred_m_10_6_10_dpcm4;
  wire  [12:0]                       pred_m_10_6_10_dpcm3;
  wire  [12:0]                       pred_m_10_7_10_dpcm4;
  wire  [12:0]                       pred_m_10_7_10_dpcm3;
  wire  [12:0]                       pred_m_10_8_10_dpcm3;
  wire  [12:0]                       pred_m_12_6_12_dpcm3;
  wire  [12:0]                       pred_m_12_6_12_dpcm4;
  wire  [12:0]                       pred_m_12_6_12_dpcm5;
  wire  [12:0]                       pred_m_12_6_12_dpcm6;
  wire  [12:0]                       pred_m_12_6_12_dpcm7;
  wire  [12:0]                       pred_m_12_7_12_dpcm3;
  wire  [12:0]                       pred_m_12_7_12_dpcm4;
  wire  [12:0]                       pred_m_12_7_12_dpcm5;
  wire  [12:0]                       pred_m_12_7_12_dpcm6;
  wire  [12:0]                       pred_m_12_8_12_dpcm3;
  wire  [12:0]                       pred_m_12_8_12_dpcm4;
  wire  [12:0]                       pred_m_12_8_12_dpcm5;

  wire                               first_pxl_vld;// First Valid pixel of the line
  wire                               scnd_pxl_vld; // Second Valid pixel of the line
  reg [20*8:1]                       mode; // For debugging

  initial
  begin
    pred_mode2_op     = 12'd0;
    pixel             = 0;
    pixel_rd          = 0;
    force_2nd_pxl_vld = 1'b0;
    dec_data_op       = 12'd0; 
  end
  assign first_pxl_vld = (pixel == 12'd0) & enc_data_vld;// First Valid pixel of the line
  assign scnd_pxl_vld  = ((pixel == 12'd1) & enc_data_vld) || force_2nd_pxl_vld ;// Second Valid pixel of the line
    

  
  // Decoded Output will be stored in a array , which can store one line of pixels
  
   always @ (negedge dec_data_vld) begin

     if ((num_pxls_per_line - 1) == pixel)
       pixel = 0 ; 
     else
       pixel = (pixel + 12'd1);
   end  
   
   always @ (posedge enc_data_vld) begin
     if ((num_pxls_per_line == 2) && (pixel_rd == 1))
       force_2nd_pxl_vld = 1'b1;
     else
       force_2nd_pxl_vld = 1'b0;
   end   

 
  
   // Generation of Prediction Output for Mode 1 and Mode 2

  always @(posedge enc_data_vld) begin
    pred_mode1_op = dec_op_mem[pixel_rd - 2];

    case (pixel_rd)
     10'd0   : pred_mode2_op = 12'd0;
     10'd1   : pred_mode2_op = dec_op_mem[pixel_rd-1];
     10'd2   : pred_mode2_op = dec_op_mem[pixel_rd-2];
     10'd3   : pred_mode2_op = (((dec_op_mem[pixel_rd-1] <= dec_op_mem[pixel_rd-2]) &  (dec_op_mem[pixel_rd-2] <= dec_op_mem[pixel_rd-3])) |
                                ((dec_op_mem[pixel_rd-1] >= dec_op_mem[pixel_rd-2]) &  (dec_op_mem[pixel_rd-2] >= dec_op_mem[pixel_rd-3]))) ?
                                  dec_op_mem[pixel_rd-1] : dec_op_mem[pixel_rd-2];
     default :  if (((dec_op_mem[pixel_rd-1] <= dec_op_mem[pixel_rd-2]) &  (dec_op_mem[pixel_rd-2] <= dec_op_mem[pixel_rd-3])) |
                    ((dec_op_mem[pixel_rd-1] >= dec_op_mem[pixel_rd-2]) &  (dec_op_mem[pixel_rd-2] >= dec_op_mem[pixel_rd-3])))
                  pred_mode2_op = dec_op_mem[pixel_rd-1];
                else if (((dec_op_mem[pixel_rd-1] <= dec_op_mem[pixel_rd-3]) &  (dec_op_mem[pixel_rd-2] <= dec_op_mem[pixel_rd-4])) |
                         ((dec_op_mem[pixel_rd-1] >= dec_op_mem[pixel_rd-3]) &  (dec_op_mem[pixel_rd-2] >= dec_op_mem[pixel_rd-4])))
                  pred_mode2_op = dec_op_mem[pixel_rd-2];
                else
                  pred_mode2_op = (dec_op_mem[pixel_rd-2] + dec_op_mem[pixel_rd-4] + 12'd1)/2;  
     endcase
  end
  always @(negedge enc_data_vld) begin

    if ((num_pxls_per_line - 1) == pixel_rd)
      pixel_rd = 0;
    else
      pixel_rd = pixel_rd + 1;
  end
     
   
   // Prediction Outputs from both the modes are muxed based on the config register
   assign pred_op  = config_reg[3] ? pred_mode1_op : pred_mode2_op;
   
   // All the adder outputs are forced to 12 bits
   // Intermediates for 10-6-10 Decoding
   assign val_10_6_10_dpcm3 = {4'd0,(enc_data_ip[5:0] &  6'h01),2'd0} + 12'd4;
   assign val_10_6_10_dpcm4 = {3'd0,(enc_data_ip[5:0] &  6'h03),3'd0} + 12'd14;
   assign val_10_6_10_dpcm5 = {2'd0,(enc_data_ip[5:0] &  6'h07),4'd0} + 12'd50; 
   assign val_10_6_10_pcm   = {1'd0,(enc_data_ip[5:0] &  6'h1F),5'd0};
   
   // Intermediates for 10-7-10 Decoding
   assign val_10_7_10_dpcm1 = {5'd0,(enc_data_ip[6:0] &  7'h07)};
   assign val_10_7_10_dpcm2 = {4'd0,(enc_data_ip[6:0] &  7'h03),1'd0} + 12'd8;
   assign val_10_7_10_dpcm3 = {3'd0,(enc_data_ip[6:0] &  7'h03),2'd0} + 12'd17;
   assign val_10_7_10_dpcm4 = {2'd0,(enc_data_ip[6:0] &  7'h0f),3'd0} + 12'd35;
   assign val_10_7_10_pcm   = {1'd0,(enc_data_ip[6:0] &  7'h3f),4'd0};
   
   // Intermediates for 10-8-10 Decoding
   assign val_10_8_10_dpcm1 = {4'd0,(enc_data_ip[7:0] &  8'h1f)};
   assign val_10_8_10_dpcm2 = {3'd0,(enc_data_ip[7:0] &  8'h0f),1'd0} + 12'd32;
   assign val_10_8_10_dpcm3 = {2'd0,(enc_data_ip[7:0] &  8'h0f),2'd0} + 12'd65;
   assign val_10_8_10_pcm   = {1'd0,(enc_data_ip[7:0] &  8'h7f),3'd0};

   // Intermediates for 12-6-12 Decoding
   assign val_12_6_12_dpcm1 = {6'd0,(enc_data_ip[5:0] &  6'h01)};
   assign val_12_6_12_dpcm3 = {4'd0,(enc_data_ip[5:0] &  6'h01),2'd0} + 12'd3;
   assign val_12_6_12_dpcm4 = {3'd0,(enc_data_ip[5:0] &  6'h03),3'd0} + 12'd13;
   assign val_12_6_12_dpcm5 = {2'd0,(enc_data_ip[5:0] &  6'h01),4'd0} + 12'd49;
   assign val_12_6_12_dpcm6 = {1'd0,(enc_data_ip[5:0] &  6'h03),5'd0} + 12'd89;
   assign val_12_6_12_dpcm7 = {(enc_data_ip[5:0] &  6'h01),6'd0} + 12'd233;
   assign val_12_6_12_pcm   = {(enc_data_ip[5:0] &  6'h1f),7'd0};
   
   // Intermediates for 12-7-12 Decoding
   assign val_12_7_12_dpcm1 = {5'd0,(enc_data_ip[6:0] &  7'h03)};
   assign val_12_7_12_dpcm2 = {4'd0,(enc_data_ip[6:0] &  7'h03),1'd0} + 12'd4;
   assign val_12_7_12_dpcm3 = {3'd0,(enc_data_ip[6:0] &  7'h03),2'd0} + 12'd13;
   assign val_12_7_12_dpcm4 = {2'd0,(enc_data_ip[6:0] &  7'h07),3'd0} + 12'd31;
   assign val_12_7_12_dpcm5 = {1'd0,(enc_data_ip[6:0] &  7'h07),4'd0} + 12'd99;
   assign val_12_7_12_dpcm6 = {(enc_data_ip[6:0] &  7'h03),5'd0} + 12'd235;
   assign val_12_7_12_pcm   = {(enc_data_ip[6:0] &  7'h3f),6'd0};

   // Intermediates for 12-8-12 Decoding
   assign val_12_8_12_dpcm1 = {4'd0,(enc_data_ip[7:0] &  8'h07)};
   assign val_12_8_12_dpcm2 = {3'd0,(enc_data_ip[7:0] &  8'h0f),1'd0} + 12'd8;
   assign val_12_8_12_dpcm3 = {2'd0,(enc_data_ip[7:0] &  8'h0f),2'd0} + 12'd41;
   assign val_12_8_12_dpcm4 = {1'd0,(enc_data_ip[7:0] &  8'h0f),3'd0} + 12'd107;
   assign val_12_8_12_dpcm5 = {(enc_data_ip[7:0] &  8'h07),4'd0} + 12'd239;
   assign val_12_8_12_pcm   = {(enc_data_ip[7:0] &  8'h7f),5'd0};

 
   // Intermediate subtrators which are used to check if the value is negative
   assign pred_m_10_6_10_dpcm5 = pred_op - val_10_6_10_dpcm5;
   assign pred_m_10_6_10_dpcm4 = pred_op - val_10_6_10_dpcm4;
   assign pred_m_10_6_10_dpcm3 = pred_op - val_10_6_10_dpcm3;

   assign pred_m_10_7_10_dpcm4 = pred_op - val_10_7_10_dpcm4;
   assign pred_m_10_7_10_dpcm3 = pred_op - val_10_7_10_dpcm3;
   
   assign pred_m_10_8_10_dpcm3 = pred_op - val_10_8_10_dpcm3;

   assign pred_m_12_6_12_dpcm3 = pred_op - val_12_6_12_dpcm3;
   assign pred_m_12_6_12_dpcm4 = pred_op - val_12_6_12_dpcm4;
   assign pred_m_12_6_12_dpcm5 = pred_op - val_12_6_12_dpcm5;
   assign pred_m_12_6_12_dpcm6 = pred_op - val_12_6_12_dpcm6;
   assign pred_m_12_6_12_dpcm7 = pred_op - val_12_6_12_dpcm7;

   assign pred_m_12_7_12_dpcm3 = pred_op - val_12_7_12_dpcm3;
   assign pred_m_12_7_12_dpcm4 = pred_op - val_12_7_12_dpcm4;
   assign pred_m_12_7_12_dpcm5 = pred_op - val_12_7_12_dpcm5;
   assign pred_m_12_7_12_dpcm6 = pred_op - val_12_7_12_dpcm6;

   assign pred_m_12_8_12_dpcm3 = pred_op - val_12_8_12_dpcm3;
   assign pred_m_12_8_12_dpcm4 = pred_op - val_12_8_12_dpcm4;
   assign pred_m_12_8_12_dpcm5 = pred_op - val_12_8_12_dpcm5;

   // Decoded Ouput Generation
   always @ (*) begin
     if (enc_data_vld) begin

         case (config_reg [2:0])                                                
           3'b001  :                                                       // 10-6-10 Decoding 
             
             if (((first_pxl_vld | scnd_pxl_vld) &  config_reg[3])|       // For the first two pixels of every line in Prediction Mode 1
                 (first_pxl_vld &  config_reg[4]))      
               begin                   // For the first pixel of every line in Prediction Mode 2
               dec_data_op = {2'd0,enc_data_ip[5:0],4'd0} + 12'd8;
               dec_op_mem[pixel] = {2'd0,enc_data_ip[5:0],4'd0} + 12'd8;
               end
             else begin                                                   // For all pixels other than P1 & P2 in every line
               
               if ((enc_data_ip[5:0] &  6'h3E) == 6'h00) begin            // DPCM1
                 dec_data_op =  pred_op;    
                 dec_op_mem[pixel] = pred_op;     
                 mode = "DPCM1";
               end else if ((enc_data_ip[5:0] &  6'h3E) == 6'h02) begin       // DPCM2
                 mode = "DPCM2";
                 
                  if ((enc_data_ip[5:0] &  6'h01) > 6'h0)
                  begin
                    dec_data_op = pred_op - 12'd1;
                    dec_op_mem[pixel] =   pred_op - 12'd1;
                  end
                  else
                  begin
                    dec_data_op = pred_op + 12'd1;
                    dec_op_mem[pixel] =  pred_op + 12'd1;                      
                  end
               end else if ((enc_data_ip[5:0] &  6'h3C) == 6'h04) begin    // DPCM3
                 mode = "DPCM3";

                 if ((enc_data_ip[5:0] &  6'h02) > 6'h0)
                 begin
                   dec_data_op = pred_m_10_6_10_dpcm3[12] ? 12'd0 : pred_m_10_6_10_dpcm3[11:0]; 
                   dec_op_mem[pixel] = pred_m_10_6_10_dpcm3[12] ? 12'd0 : pred_m_10_6_10_dpcm3[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_10_6_10_dpcm3) > 12'd1023) ? 12'd1023 : (pred_op + val_10_6_10_dpcm3);
                   dec_op_mem[pixel] = ((pred_op + val_10_6_10_dpcm3) > 12'd1023) ? 12'd1023 : (pred_op + val_10_6_10_dpcm3);
                 end

               end else if ((enc_data_ip[5:0] &  6'h38) == 6'h08) begin    // DPCM4
                 mode = "DPCM4";

                 if ((enc_data_ip[5:0] &  6'h04) > 6'h0)
                 begin
                   dec_data_op = pred_m_10_6_10_dpcm4[12] ? 12'd0 : pred_m_10_6_10_dpcm4[11:0]; 
                   dec_op_mem[pixel] = pred_m_10_6_10_dpcm4[12] ? 12'd0 : pred_m_10_6_10_dpcm4[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_10_6_10_dpcm4) > 12'd1023) ? 12'd1023 : (pred_op + val_10_6_10_dpcm4);
                   dec_op_mem[pixel] =  ((pred_op + val_10_6_10_dpcm4) > 12'd1023) ? 12'd1023 : (pred_op + val_10_6_10_dpcm4);
                 end
               end else if ((enc_data_ip[5:0] &  6'h30) == 6'h10) begin    // DPCM5
                 mode = "DPCM5";

                 if ((enc_data_ip[5:0] &  6'h08) > 6'h0)
                 begin
                   dec_data_op = pred_m_10_6_10_dpcm5[12] ? 12'd0 : pred_m_10_6_10_dpcm5[11:0]; 
                   dec_op_mem[pixel] = pred_m_10_6_10_dpcm5[12] ? 12'd0 : pred_m_10_6_10_dpcm5[11:0];
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_10_6_10_dpcm5) > 12'd1023) ? 12'd1023 : (pred_op + val_10_6_10_dpcm5);                         
                   dec_op_mem[pixel] =  ((pred_op + val_10_6_10_dpcm5) > 12'd1023) ? 12'd1023 : (pred_op + val_10_6_10_dpcm5);
                 end
               
               end else begin                                                // PCM
                 mode = "PCM";

                 dec_data_op = val_10_6_10_pcm + 12'd15 + ((val_10_6_10_pcm > pred_op) ? 12'd0 : 12'd1 );
                  dec_op_mem[pixel] = val_10_6_10_pcm + 12'd15 + ((val_10_6_10_pcm > pred_op) ? 12'd0 : 12'd1 );
               end
             end

 
           3'b010  :                                                       // 10-7-10 Decoding  

             if (((first_pxl_vld | scnd_pxl_vld) &  config_reg[3])|       // For the first two pixels of every line in Prediction Mode 1
                 (first_pxl_vld &  config_reg[4]))         
             begin                // For the first pixel of every line in Prediction Mode 2 
               dec_data_op = {2'd0,enc_data_ip[6:0],3'd0} + 12'd4;
               dec_op_mem[pixel] = {2'd0,enc_data_ip[6:0],3'd0} + 12'd4;
             end     
             else begin                                                   // For all pixels other than P1 and  P2 in every line
               if ((enc_data_ip[6:0] &  7'h70) == 7'h00) begin            // DPCM1
                 mode = "DPCM1";

                 if ((enc_data_ip[6:0] &  7'h08) > 7'h0)
                 begin
                   dec_data_op =  pred_op - val_10_7_10_dpcm1;
                   dec_op_mem[pixel] = pred_op - val_10_7_10_dpcm1;
                 end
                 else
                 begin
                   dec_data_op =  pred_op + val_10_7_10_dpcm1; 
                   dec_op_mem[pixel] = pred_op + val_10_7_10_dpcm1;
                 end
               end else if ((enc_data_ip[6:0] &  7'h78) == 7'h10) begin     // DPCM2
                  mode = "DPCM2";

                  if ((enc_data_ip[6:0] &  7'h04) > 7'h0)
                  begin
                    dec_data_op = pred_op - val_10_7_10_dpcm2; 
                    dec_op_mem[pixel] = pred_op - val_10_7_10_dpcm2; 
                  end
                  else
                  begin
                    dec_data_op = pred_op + val_10_7_10_dpcm2; 
                    dec_op_mem[pixel] = pred_op + val_10_7_10_dpcm2; 
                  end
               
               end else if ((enc_data_ip[6:0] &  7'h78) == 7'h18) begin    // DPCM3
                 mode = "DPCM3";

                 if ((enc_data_ip[6:0] &  7'h04) > 7'h0)
                 begin
                   dec_data_op = pred_m_10_7_10_dpcm3[12] ? 12'd0 : pred_m_10_7_10_dpcm3[11:0]; 
                   dec_op_mem[pixel] = pred_m_10_7_10_dpcm3[12] ? 12'd0 : pred_m_10_7_10_dpcm3[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_10_7_10_dpcm3) > 12'd1023) ? 12'd1023 : (pred_op + val_10_7_10_dpcm3);
                   dec_op_mem[pixel] = ((pred_op + val_10_7_10_dpcm3) > 12'd1023) ? 12'd1023 : (pred_op + val_10_7_10_dpcm3);
                 end

               end else if ((enc_data_ip[6:0] &  7'h60) == 7'h20) begin    // DPCM4
                 mode = "DPCM4";

                 if ((enc_data_ip[6:0] &  7'h10) > 7'h0)
                 begin
                   dec_data_op = pred_m_10_7_10_dpcm4[12] ? 12'd0 : pred_m_10_7_10_dpcm4[11:0]; 
                   dec_op_mem[pixel] = pred_m_10_7_10_dpcm4[12] ? 12'd0 : pred_m_10_7_10_dpcm4[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_10_7_10_dpcm4) > 12'd1023) ? 12'd1023 : (pred_op + val_10_7_10_dpcm4);
                   dec_op_mem[pixel] = ((pred_op + val_10_7_10_dpcm4) > 12'd1023) ? 12'd1023 : (pred_op + val_10_7_10_dpcm4);
                 end
                          
               end else begin                                                  // PCM
                 dec_data_op = val_10_7_10_pcm + 12'd7 + ((val_10_7_10_pcm > pred_op) ? 12'd0 : 12'd1 );
                 dec_op_mem[pixel] =  val_10_7_10_pcm + 12'd7 + ((val_10_7_10_pcm > pred_op) ? 12'd0 : 12'd1 );
                 mode = "PCM";

               end
             end

               
           3'b011  :                                                      // 10-8-10 Decoding

             if (((first_pxl_vld | scnd_pxl_vld) &  config_reg[3])|       // For the first two pixels of every line in Prediction Mode 1
                 (first_pxl_vld &  config_reg[4]))                        // For the first pixel of every line in Prediction Mode 2
                begin
               dec_data_op = {2'd0,enc_data_ip[7:0],2'd0} + 12'd2;
               dec_op_mem[pixel] = {2'd0,enc_data_ip[7:0],2'd0} + 12'd2;
               end
                       
             else begin                                                   // For all pixels other than P1 and P2 in every line
               
               if ((enc_data_ip[7:0] &  8'hC0) == 8'h00) begin            // DPCM1
                 if ((enc_data_ip[7:0] &  8'h20) > 8'h0)
                 begin
                   dec_data_op = pred_op - val_10_8_10_dpcm1; 
                   dec_op_mem[pixel] = pred_op - val_10_8_10_dpcm1; 
                 end
                 else
                 begin
                   dec_data_op = pred_op + val_10_8_10_dpcm1;
                   dec_op_mem[pixel] = pred_op + val_10_8_10_dpcm1;
                 end 

               end else if ((enc_data_ip[7:0] &  8'hE0) == 8'h40) begin   // DPCM2
                 if ((enc_data_ip[7:0] &  8'h10) > 8'h0)
                 begin
                   dec_data_op = pred_op - val_10_8_10_dpcm2; 
                   dec_op_mem[pixel] = pred_op - val_10_8_10_dpcm2; 
                 end
                 else
                 begin
                   dec_data_op = pred_op + val_10_8_10_dpcm2;
                   dec_op_mem[pixel] = pred_op + val_10_8_10_dpcm2;
                 end
 
               end else if ((enc_data_ip[7:0] &  8'hE0) == 8'h60) begin    // DPCM3
                 if ((enc_data_ip[7:0] &  8'h10) > 8'h0)
                 begin
                   dec_data_op = pred_m_10_8_10_dpcm3[12] ? 12'd0 : pred_m_10_8_10_dpcm3[11:0]; 
                   dec_op_mem[pixel] = pred_m_10_8_10_dpcm3[12] ? 12'd0 : pred_m_10_8_10_dpcm3[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_10_8_10_dpcm3) > 12'd1023) ? 12'd1023 : (pred_op + val_10_8_10_dpcm3);
                   dec_op_mem[pixel] = ((pred_op + val_10_8_10_dpcm3) > 12'd1023) ? 12'd1023 : (pred_op + val_10_8_10_dpcm3);
                 end

               end else                                                   // PCM
                 begin
                 dec_data_op = val_10_8_10_pcm + 12'd3 + ((val_10_8_10_pcm > pred_op) ? 12'd0 : 12'd1 );
                 dec_op_mem[pixel] = val_10_8_10_pcm + 12'd3 + ((val_10_8_10_pcm > pred_op) ? 12'd0 : 12'd1 );
                 end
             end

           3'b100  :                                                       // 12-6-12 Decoding
 
             if (((first_pxl_vld | scnd_pxl_vld) &  config_reg[3])|       // For the first two pixels of every line in Prediction Mode 1
                 (first_pxl_vld &  config_reg[4]))                         // For the first pixel of every line in Prediction Mode 2
               begin
               dec_data_op = {enc_data_ip[5:0],6'd0} + 12'd32;
               dec_op_mem[pixel] = {enc_data_ip[5:0],6'd0} + 12'd32;
               end                     
             else begin                                                   // For all pixels other than P1 and P2 in every line
               
               if ((enc_data_ip[5:0] &  6'h3C) == 6'h00) begin             // DPCM1
                 if ((enc_data_ip[5:0] &  6'h02) > 8'h0)
                 begin
                   dec_data_op = pred_op - val_12_6_12_dpcm1; 
                   dec_op_mem[pixel] = pred_op - val_12_6_12_dpcm1; 
                 end
                 else
                 begin
                   dec_data_op = pred_op + val_12_6_12_dpcm1;
                   dec_op_mem[pixel] = pred_op + val_12_6_12_dpcm1;
                 end
 
               end else if ((enc_data_ip[5:0] &  6'h3C) == 6'h04) begin    // DPCM3
                 if ((enc_data_ip[5:0] &  6'h02) > 8'h0)
                 begin
                   dec_data_op = pred_m_12_6_12_dpcm3[12] ? 12'd0 : pred_m_12_6_12_dpcm3[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_6_12_dpcm3[12] ? 12'd0 : pred_m_12_6_12_dpcm3[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_6_12_dpcm3) > 12'd4095) ? 12'd4095 : (pred_op + val_12_6_12_dpcm3);
                   dec_op_mem[pixel] = ((pred_op + val_12_6_12_dpcm3) > 12'd4095) ? 12'd4095 : (pred_op + val_12_6_12_dpcm3);
                 end
               
               end else if ((enc_data_ip[5:0] &  6'h38) == 6'h10) begin    // DPCM4
                 if ((enc_data_ip[5:0] &  6'h04) > 6'h0)
                 begin
                   dec_data_op = pred_m_12_6_12_dpcm4[12] ? 12'd0 : pred_m_12_6_12_dpcm4[11:0];
                   dec_op_mem[pixel] = pred_m_12_6_12_dpcm4[12] ? 12'd0 : pred_m_12_6_12_dpcm4[11:0];
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_6_12_dpcm4) > 12'd4095) ? 12'd4095 : (pred_op + val_12_6_12_dpcm4);
                   dec_op_mem[pixel] = ((pred_op + val_12_6_12_dpcm4) > 12'd4095) ? 12'd4095 : (pred_op + val_12_6_12_dpcm4);
                 end

               end else if ((enc_data_ip[5:0] &  6'h3C) == 6'h08) begin    // DPCM5
                 if ((enc_data_ip[5:0] &  6'h02) > 6'h0)
                 begin
                   dec_data_op = pred_m_12_6_12_dpcm5[12] ? 12'd0 : pred_m_12_6_12_dpcm5[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_6_12_dpcm5[12] ? 12'd0 : pred_m_12_6_12_dpcm5[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_6_12_dpcm5) > 12'd4095) ? 12'd4095 : (pred_op + val_12_6_12_dpcm5);
                   dec_op_mem[pixel] = ((pred_op + val_12_6_12_dpcm5) > 12'd4095) ? 12'd4095 : (pred_op + val_12_6_12_dpcm5);
                 end 
               
               end else if ((enc_data_ip[5:0] &  6'h38) == 6'h18) begin    // DPCM6
                 if ((enc_data_ip[5:0] &  6'h04) > 6'h0)
                 begin
                   dec_data_op = pred_m_12_6_12_dpcm6[12] ? 12'd0 : pred_m_12_6_12_dpcm6[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_6_12_dpcm6[12] ? 12'd0 : pred_m_12_6_12_dpcm6[11:0];
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_6_12_dpcm6) > 12'd4095) ? 12'd4095 : (pred_op + val_12_6_12_dpcm6);
                   dec_op_mem[pixel] = ((pred_op + val_12_6_12_dpcm6) > 12'd4095) ? 12'd4095 : (pred_op + val_12_6_12_dpcm6);
                 end
               
               end else if ((enc_data_ip[5:0] &  6'h3C) == 6'h0C) begin    // DPCM7
                 if ((enc_data_ip[7:0] &  8'h02) > 8'h0)
                 begin
                   dec_data_op = pred_m_12_6_12_dpcm7[12] ? 12'd0 : pred_m_12_6_12_dpcm7[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_6_12_dpcm7[12] ? 12'd0 : pred_m_12_6_12_dpcm7[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_6_12_dpcm7) > 12'd4095) ? 12'd4095 : (pred_op + val_12_6_12_dpcm7);
                   dec_op_mem[pixel] = ((pred_op + val_12_6_12_dpcm7) > 12'd4095) ? 12'd4095 : (pred_op + val_12_6_12_dpcm7);
                 end
               
               end else                                                   // PCM
                 begin
                 dec_data_op = val_12_6_12_pcm + 12'd63 + ((val_12_6_12_pcm > pred_op) ? 12'd0 : 12'd1 );
                 dec_op_mem[pixel] =  val_12_6_12_pcm + 12'd63 + ((val_12_6_12_pcm > pred_op) ? 12'd0 : 12'd1 );
                 end
             end

           3'b101  :                                                       // 12-7-12 Decoding
             if (((first_pxl_vld | scnd_pxl_vld) &  config_reg[3])|       // For the first two pixels of every line in Prediction Mode 1
                 (first_pxl_vld &  config_reg[4]))                          // For the first pixel of every line in Prediction Mode 2
                 begin
               dec_data_op = {enc_data_ip[6:0],5'd0} + 12'd16;
               dec_op_mem[pixel] = {enc_data_ip[6:0],5'd0} + 12'd16;
                 end        
             else begin                                                    // For all pixels other than P1 and P2 in every line
               
               if ((enc_data_ip[6:0] &  7'h78) == 7'h00) begin             // DPCM1
                 if ((enc_data_ip[6:0] &  7'h04) > 7'h0)
                  
                 begin
                   dec_data_op = pred_op - val_12_7_12_dpcm1;
                   dec_op_mem[pixel] = pred_op - val_12_7_12_dpcm1;
                 end 
                 else
                 begin
                   dec_data_op = pred_op + val_12_7_12_dpcm1;
                   dec_op_mem[pixel] =  pred_op + val_12_7_12_dpcm1;
                 end
 
               end else if ((enc_data_ip[6:0] &  7'h78) == 7'h08) begin    // DPCM2
                 if ((enc_data_ip[6:0] &  7'h04) > 7'h0)
                 begin
                   dec_data_op = pred_op - val_12_7_12_dpcm2; 
                   dec_op_mem[pixel] = pred_op - val_12_7_12_dpcm2; 
                 end
                 else
                 begin
                   dec_data_op = pred_op + val_12_7_12_dpcm2;
                   dec_op_mem[pixel] = pred_op + val_12_7_12_dpcm2;
                 end
 
               end else if ((enc_data_ip[6:0] &  7'h78) == 7'h10) begin    // DPCM3
                 if ((enc_data_ip[6:0] &  7'h04) > 7'h0)
                 begin
                   dec_data_op = pred_m_12_7_12_dpcm3[12] ? 12'd0 : pred_m_12_7_12_dpcm3[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_7_12_dpcm3[12] ? 12'd0 : pred_m_12_7_12_dpcm3[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_7_12_dpcm3) > 12'd4095) ? 12'd4095 : (pred_op + val_12_7_12_dpcm3);
                   dec_op_mem[pixel] = ((pred_op + val_12_7_12_dpcm3) > 12'd4095) ? 12'd4095 : (pred_op + val_12_7_12_dpcm3);
                 end
               
               end else if ((enc_data_ip[6:0] &  7'h70) == 7'h20) begin    // DPCM4
                 if ((enc_data_ip[6:0] &  7'h08) > 7'h0)
                 begin
                   dec_data_op = pred_m_12_7_12_dpcm4[12] ? 12'd0 : pred_m_12_7_12_dpcm4[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_7_12_dpcm4[12] ? 12'd0 : pred_m_12_7_12_dpcm4[11:0];
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_7_12_dpcm4) > 12'd4095) ? 12'd4095 : (pred_op + val_12_7_12_dpcm4);
                   dec_op_mem[pixel] = ((pred_op + val_12_7_12_dpcm4) > 12'd4095) ? 12'd4095 : (pred_op + val_12_7_12_dpcm4);
                 end

               end else if ((enc_data_ip[6:0] &  7'h70) == 7'h30) begin    // DPCM5
                 if ((enc_data_ip[6:0] &  7'h08) > 7'h0)
                 begin
                   dec_data_op = pred_m_12_7_12_dpcm5[12] ? 12'd0 : pred_m_12_7_12_dpcm5[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_7_12_dpcm5[12] ? 12'd0 : pred_m_12_7_12_dpcm5[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_7_12_dpcm5) > 12'd4095) ? 12'd4095 : (pred_op + val_12_7_12_dpcm5);
                   dec_op_mem[pixel] = ((pred_op + val_12_7_12_dpcm5) > 12'd4095) ? 12'd4095 : (pred_op + val_12_7_12_dpcm5);
                 end
               
               end else if ((enc_data_ip[6:0] &  7'h78) == 7'h18) begin    // DPCM6
                 if ((enc_data_ip[6:0] &  7'h04) > 7'h0)
                 begin
                   dec_data_op = pred_m_12_7_12_dpcm6[12] ? 12'd0 : pred_m_12_7_12_dpcm6[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_7_12_dpcm6[12] ? 12'd0 : pred_m_12_7_12_dpcm6[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_7_12_dpcm6) > 12'd4095) ? 12'd4095 : (pred_op + val_12_7_12_dpcm6);
                   dec_op_mem[pixel] = ((pred_op + val_12_7_12_dpcm6) > 12'd4095) ? 12'd4095 : (pred_op + val_12_7_12_dpcm6);
                 end
               end else                                        
               begin           // PCM
                 dec_data_op = val_12_7_12_pcm + 12'd31 + ((val_12_7_12_pcm > pred_op) ? 12'd0 : 12'd1 );
                 dec_op_mem[pixel] = val_12_7_12_pcm + 12'd31 + ((val_12_7_12_pcm > pred_op) ? 12'd0 : 12'd1 );
                 end
             end

           3'b110  :                                                      // 12-8-12 Decoding

             if (((first_pxl_vld | scnd_pxl_vld) &  config_reg[3])|  // For the first two pixels of every line in Prediction Mode 1
                  (first_pxl_vld &  config_reg[4]))                    // For the first pixel of every line in Prediction Mode 2
                  begin
               dec_data_op = {enc_data_ip[7:0],4'd0} + 12'd8;
               dec_op_mem[pixel] = {enc_data_ip[7:0],4'd0} + 12'd8;
                 end
                       
             else begin                                                   // For all pixels other than P1 and P2 in every line
               
               if ((enc_data_ip[7:0] &  8'hF0) == 8'h00) begin            // DPCM1
               //  $display("DPCM1");
                 if ((enc_data_ip[7:0] &  8'h08) > 8'h0)
                 begin
                   dec_data_op = pred_op - val_12_8_12_dpcm1; 
                   dec_op_mem[pixel] = pred_op - val_12_8_12_dpcm1; 
                 end
                 else
                 begin
                   dec_data_op = pred_op + val_12_8_12_dpcm1;
                   dec_op_mem[pixel] = pred_op + val_12_8_12_dpcm1;
                 end
 
               end else if ((enc_data_ip[7:0] &  8'hE0) == 8'h60) begin    // DPCM2
                //  $display("DPCM2");

                 if ((enc_data_ip[7:0] &  8'h10) > 8'h0)
                 begin
                   dec_data_op = pred_op - val_12_8_12_dpcm2; 
                   dec_op_mem[pixel] = pred_op - val_12_8_12_dpcm2;
                 end
                 else
                 begin
                   dec_data_op = pred_op + val_12_8_12_dpcm2;
                   dec_op_mem[pixel] = pred_op + val_12_8_12_dpcm2;
                 end
 
               end else if ((enc_data_ip[7:0] &  8'hE0) == 8'h40) begin    // DPCM3
                //  $display("DPCM3");

                 if ((enc_data_ip[7:0] &  8'h10) > 8'h0)
                 begin
                   dec_data_op = pred_m_12_8_12_dpcm3[12] ? 12'd0 : pred_m_12_8_12_dpcm3[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_8_12_dpcm3[12] ? 12'd0 : pred_m_12_8_12_dpcm3[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_8_12_dpcm3) > 12'd4095) ? 12'd4095 : (pred_op + val_12_8_12_dpcm3);
                   dec_op_mem[pixel] = ((pred_op + val_12_8_12_dpcm3) > 12'd4095) ? 12'd4095 : (pred_op + val_12_8_12_dpcm3);
                 end
               
               end else if ((enc_data_ip[7:0] &  8'hE0) == 8'h20) begin    // DPCM4
                //  $display("DPCM4");

                 if ((enc_data_ip[7:0] &  8'h10) > 8'h0)
                 begin
                   dec_data_op = pred_m_12_8_12_dpcm4[12] ? 12'd0 : pred_m_12_8_12_dpcm4[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_8_12_dpcm4[12] ? 12'd0 : pred_m_12_8_12_dpcm4[11:0]; 
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_8_12_dpcm4) > 12'd4095) ? 12'd4095 : (pred_op + val_12_8_12_dpcm4);
                   dec_op_mem[pixel] = ((pred_op + val_12_8_12_dpcm4) > 12'd4095) ? 12'd4095 : (pred_op + val_12_8_12_dpcm4);
                 end

               end else if ((enc_data_ip[7:0] &  8'hF0) == 8'h10) begin    // DPCM5
                //  $display("DPCM5");

                 if ((enc_data_ip[7:0] &  8'h08) > 8'h0)
                 begin
                   dec_data_op = pred_m_12_8_12_dpcm5[12] ? 12'd0 : pred_m_12_8_12_dpcm5[11:0]; 
                   dec_op_mem[pixel] = pred_m_12_8_12_dpcm5[12] ? 12'd0 : pred_m_12_8_12_dpcm5[11:0];
                 end
                 else
                 begin
                   dec_data_op = ((pred_op + val_12_8_12_dpcm5) > 12'd4095) ? 12'd4095 : (pred_op + val_12_8_12_dpcm5);
                   dec_op_mem[pixel] = ((pred_op + val_12_8_12_dpcm5) > 12'd4095) ? 12'd4095 : (pred_op + val_12_8_12_dpcm5);
                 end
                          
               end else begin                                                  // PCM
                //   $display("PCM");
                begin

                 dec_data_op = val_12_8_12_pcm + 12'd15 + ((val_12_8_12_pcm > pred_op) ? 12'd0 : 12'd1 );
                 dec_op_mem[pixel] = val_12_8_12_pcm + 12'd15 + ((val_12_8_12_pcm > pred_op) ? 12'd0 : 12'd1 );
                 end
               end
             end

           default : dec_data_op =  12'd0;
         endcase
       end  
     end
     // Generation of Output valid signal
     assign dec_data_vld = enc_data_vld;
endmodule  
     




 
