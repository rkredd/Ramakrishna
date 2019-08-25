/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_predictor.v
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
module csi2tx_predictor (
  input  wire                      sensor_clk,
  input  wire                      sys_rst_n,
  input  wire [4:0]                comp_scheme,
  input  wire                      enable,
  input  wire [11:0]               dec_data,
  input  wire                      pixel1_valid,
  input  wire                      pixel2_valid,
  input  wire                      pixel3_valid,
  input  wire                      pixel4_valid,

  output reg [11:0]                pred_data
);

// Declaration of nets used in the instantiation wiring
// CM TRANSLATE OFF

wire [11:0] dec_n_min_1;
wire [11:0] dec_n_min_2;
wire [11:0] dec_n_min_3;
wire [11:0] dec_n_min_4;
wire prediction_1_en;

//-----------------------------------------------------------------------------
// Register the incoming stream for the predictor algorithm  
//-----------------------------------------------------------------------------
reg [11:0]  dec_data_d1;
reg [11:0]  dec_data_d2;
reg [11:0]  dec_data_d3;
reg [11:0]  dec_data_d4;

  wire compression_en = |comp_scheme;

always @(posedge sensor_clk or negedge sys_rst_n) begin
  if(sys_rst_n == 1'b0) begin
    dec_data_d1[11:0]  <= 'b0;
    dec_data_d2[11:0]  <= 'b0;
    dec_data_d3[11:0]  <= 'b0;
    dec_data_d4[11:0]  <= 'b0;
  end else if(~compression_en) begin
    dec_data_d1[11:0]  <= 'b0;
    dec_data_d2[11:0]  <= 'b0;
    dec_data_d3[11:0]  <= 'b0;
    dec_data_d4[11:0]  <= 'b0;
  end else if(enable) begin
      dec_data_d1[11:0] <= dec_data; 
      dec_data_d2[11:0] <= dec_data_d1; 
      dec_data_d3[11:0] <= dec_data_d2;
      dec_data_d4[11:0] <= dec_data_d3;
  end
end

// Route the appropriate z-1 decoder value for the pixel A predictor
assign dec_n_min_1 = dec_data_d1; 
assign dec_n_min_2 = dec_data_d2;
assign dec_n_min_3 = dec_data_d3;
assign dec_n_min_4 = dec_data_d4;

// Route the prediction algorithm to be used 
assign prediction_1_en = comp_scheme[3];

//-----------------------------------------------------------------------------
// Function used to predict the predictor value (predictor 2) for a given 
// set of z^-1,z^-2,z^-3,z^-4 decoder values
//-----------------------------------------------------------------------------
function [12:0] xpred;
input [11:0] xdec_n_min_1;
input [11:0] xdec_n_min_2;
input [11:0] xdec_n_min_3;
input [11:0] xdec_n_min_4;
begin
  if( ((xdec_n_min_1 <= xdec_n_min_2) && (xdec_n_min_2 <= xdec_n_min_3)) ||   
      ((xdec_n_min_1 >= xdec_n_min_2) && (xdec_n_min_2 >= xdec_n_min_3))) begin
    xpred = {1'b0,xdec_n_min_1};
  end else if(((xdec_n_min_1 <= xdec_n_min_3) && (xdec_n_min_2 <= xdec_n_min_4)) || 
              ((xdec_n_min_1 >= xdec_n_min_3) && (xdec_n_min_2 >= xdec_n_min_4)))begin
    xpred = {1'b0,xdec_n_min_2};
  end else begin  
    // To account for the overflow condition an additional bit is added 
    xpred = {1'b0,xdec_n_min_2} + {1'b0,xdec_n_min_4} + 13'd1;
    // Now right shift the prediction value 
    xpred = xpred >> 1; 
  end 
end 
endfunction

//-----------------------------------------------------------------------------
// Combinational logic to represent the next prediction value for the 
// predictor1 and predictor2 algorithm
// Note: The prediction value is one bit more to handle overflow condition  
//-----------------------------------------------------------------------------
always @(*) begin
  if(prediction_1_en & enable) begin
    if(pixel1_valid | pixel2_valid) begin
      pred_data = 12'h0;//dec_data;
    end
    else begin
      pred_data = {1'b0,dec_n_min_2}; 
    end
  end else if(enable) begin
    if(pixel1_valid) begin
      pred_data = 12'h0;//dec_data;
    end else if(pixel2_valid) begin
      pred_data = dec_n_min_1;
    end else if(pixel3_valid) begin
      pred_data = dec_n_min_2;
    end else if(pixel4_valid) begin
      if(((dec_n_min_1 <= dec_n_min_2) && (dec_n_min_2 <= dec_n_min_3)) ||  
         ((dec_n_min_1 >= dec_n_min_2) && (dec_n_min_2 >= dec_n_min_3))) begin
         pred_data = dec_n_min_1;
      end else begin
         pred_data = dec_n_min_2;
      end 
    end else begin
      pred_data = xpred(dec_n_min_1,dec_n_min_2,dec_n_min_3,dec_n_min_4);   
    end
  end else
    pred_data = 12'h0;
end


endmodule
