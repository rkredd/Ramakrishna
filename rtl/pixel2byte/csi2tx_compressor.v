/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_compressor.v
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
module csi2tx_compressor (
  input  wire                      sensor_clk,
  input  wire                      sys_rst_n,
  input  wire [4:0]                comp_scheme,
  input  wire                      enable, 
  input  wire [11:0]               pixel_data,
  input  wire                      pixel_data_valid,
  
  output wire [7:0]                enc_data, 
  output reg  [7:0]                enc_data_d1
);

  wire [11:0] dec_data;
  wire [11:0] pred_data;
  
  reg pixel_data_valid_d1;
  reg pixel_data_valid_d2;
  reg pixel_data_valid_d3;
  reg pixel_data_valid_d4;

  wire pixel1_valid = pixel_data_valid & !pixel_data_valid_d1;
  wire pixel2_valid = pixel_data_valid_d1 & !pixel_data_valid_d2;
  wire pixel3_valid = pixel_data_valid_d2 & !pixel_data_valid_d3;
  wire pixel4_valid = pixel_data_valid_d3 & !pixel_data_valid_d4;
  
  always @(posedge sensor_clk or negedge sys_rst_n)
  begin
    if(!sys_rst_n) 
     enc_data_d1 <= 8'b0;
    else if ( enable ) 
     enc_data_d1 <= enc_data;
  end

  always @(posedge sensor_clk or negedge sys_rst_n)
  begin
    if(!sys_rst_n) begin
      pixel_data_valid_d1 <= 1'b0;
      pixel_data_valid_d2 <= 1'b0;
      pixel_data_valid_d3 <= 1'b0; 
      pixel_data_valid_d4 <= 1'b0;
    end
    else if(enable)begin
      pixel_data_valid_d1 <= pixel_data_valid;
      pixel_data_valid_d2 <= pixel_data_valid_d1;
      pixel_data_valid_d3 <= pixel_data_valid_d2; 
      pixel_data_valid_d4 <= pixel_data_valid_d3;
    end
    else if(!pixel_data_valid)begin
      pixel_data_valid_d1 <= 1'b0;
      pixel_data_valid_d2 <= 1'b0;
      pixel_data_valid_d3 <= 1'b0; 
      pixel_data_valid_d4 <= 1'b0;
    end
  end

  csi2tx_encoder u_csi2tx_encoder_inst(
    //.sensor_clk(sensor_clk),
    //.sys_rst_n(sys_rst_n),
    .comp_scheme(comp_scheme),
    .enable(enable),
    .orig_data(pixel_data),
    .orig_data_valid(pixel_data_valid),
    .pred_data(pred_data),
    .pixel1_valid(pixel1_valid),
    .pixel2_valid(pixel2_valid),
   
    .enc_data(enc_data)
   );

  csi2tx_decoder u_csi2tx_decoder_inst(
    //.sensor_clk(sensor_clk),
    //.sys_rst_n(sys_rst_n),
    .comp_scheme(comp_scheme),
    .enable(enable),
    .enc_data(enc_data),
    .pred_data(pred_data),
    .pixel1_valid(pixel1_valid),
    .pixel2_valid(pixel2_valid),
  
    .dec_data(dec_data)
  );

  csi2tx_predictor u_csi2tx_predictor_inst(
    .sensor_clk(sensor_clk),
    .sys_rst_n(sys_rst_n),
    .comp_scheme(comp_scheme),
    .enable(enable),
    .dec_data(dec_data),
    .pixel1_valid(pixel1_valid),
    .pixel2_valid(pixel2_valid),
    .pixel3_valid(pixel3_valid),
    .pixel4_valid(pixel4_valid),

    .pred_data(pred_data)
);


endmodule
