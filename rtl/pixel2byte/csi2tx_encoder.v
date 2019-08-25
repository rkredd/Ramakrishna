/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_encoder.v
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
module csi2tx_encoder (
  input  wire [4:0]                comp_scheme, 
  input  wire                      enable,
  input  wire [11:0]               orig_data,
  input  wire                      orig_data_valid,
  input  wire [11:0]               pred_data,
  input  wire                      pixel1_valid,
  input  wire                      pixel2_valid,
  
  output reg  [7:0]                enc_data 
);

wire prediction_1_en = comp_scheme[3];

wire [2:0] encoder_scheme = comp_scheme[2:0];



wire encode_10_bit =  ((encoder_scheme == `C_10_6_10) || (encoder_scheme == `C_10_7_10) ||
                       (encoder_scheme == `C_10_8_10)) ? enable : 1'b0;

wire encode_12_bit = ((encoder_scheme == `C_12_6_12) || (encoder_scheme == `C_12_7_12) ||
                      (encoder_scheme == `C_12_8_12)) ? enable : 1'b0;
//-----------------------------------------------------------------------------
// Function to encode the 10 bit value without any prediction 
//-----------------------------------------------------------------------------
function [9:0] fn_encode_10bit_wo_pred;
input [2:0] encoder_scheme;
input [9:0] orig_data; 
// local variables for the function
reg [9:0] xenc;
reg [9:0] xorig;
begin
 xorig = orig_data;
 case (encoder_scheme) 
   `C_10_8_10 : xenc = ((xorig >> 2) == 10'b0) ? 10'b1 : (xorig >> 2); 
   `C_10_7_10 : xenc = ((xorig >> 3) == 10'b0) ? 10'b1 : (xorig >> 3); 
   default    : xenc = ((xorig >> 4) == 10'b0) ? 10'b1 : (xorig >> 4); 
 endcase
 // return the without prediction value
 fn_encode_10bit_wo_pred = xenc; 
end
endfunction

//-----------------------------------------------------------------------------
// Function to deocode the 12 bit value without any prediction 
//-----------------------------------------------------------------------------
function [11:0] fn_encode_12bit_wo_pred;
input [2:0] encoder_scheme;
input [11:0] orig_data; 
// local variables for the function
reg [11:0] xenc;
reg [11:0] xorig; 
begin
 xorig = orig_data;
 case (encoder_scheme) 
   `C_12_8_12 : xenc = ((xorig >> 4) == 10'b0) ? 10'b1 : (xorig >> 4); 
   `C_12_7_12 : xenc = ((xorig >> 5) == 10'b0) ? 10'b1 : (xorig >> 5); 
   default    : xenc = ((xorig >> 6) == 10'b0) ? 10'b1 : (xorig >> 6); 
 endcase
 // return the without prediction value
 fn_encode_12bit_wo_pred = xenc;
end
endfunction

function [10:0] fn_abs_xdiff_10bit;
input [9:0] orig_data; 
input [9:0] pred_data;
reg [9:0]  xorig;
reg [9:0]  xpred;
reg [10:0] xdiff;
reg [9:0] xdiff_ones_complement;
reg [9:0] abs_xdiff;
begin
  xorig = orig_data;
  xpred = pred_data;
  xdiff = xorig - xpred;
  if(xdiff[10])
    begin
      xdiff_ones_complement = ~xdiff[9:0];
      abs_xdiff = xdiff_ones_complement + 1'b1;
    end
  else
    abs_xdiff = xdiff[9:0];

  fn_abs_xdiff_10bit = {xdiff[10],abs_xdiff};
end
endfunction

//-----------------------------------------------------------------------------
// Function that does the encoder of 10bit data
//-----------------------------------------------------------------------------
function [7:0] fn_encode_10bit;
input [2:0] encoder_scheme;
input [9:0] orig_data; 
input [9:0] pred_data;
// local function variables
reg sign;
reg [9:0] xorig;
reg [9:0] value;
reg [9:0] xenc;
reg [10:0] xdiff;
begin
  xenc  = 8'b0; 
  value = 10'b0; 
  xorig = orig_data;
  xdiff = fn_abs_xdiff_10bit(orig_data,pred_data);
  sign  = xdiff[10];
  case (encoder_scheme) 
    // 10 - 8 - 10 encoder algorithm
    `C_10_8_10 : begin
      if(xdiff[9:0] < 10'h20)
        begin
          // DPCM1
          value = xdiff[4:0];  
          if(xdiff == 11'h0)
            sign = 1'b1;
            xenc = {2'b00,sign,value[4:0]};
        end 
      else if(xdiff[9:0] < 10'h40)
        begin
          // DPCM2
          value = (xdiff[9:0] - 10'h20) >> 1; 
          xenc = {3'b010,sign,value[3:0]};
        end 
      else if(xdiff[9:0] < 10'h80)
        begin
          // DPCM3
          value = (xdiff[9:0] - 10'h40) >> 2;  
          xenc = {3'b011,sign,value[3:0]};
        end 
      else
        begin
          // PCM
	  value = xorig[9:0] >> 3;
	  xenc = {1'b1,value[6:0]};
        end
   end 

    // 10 - 7 - 10 encoder algorithm
    `C_10_7_10 : begin
      if(xdiff[9:0] < 10'h8)
        begin
          // DPCM1
	  value = xdiff[2:0];  
          if(xdiff == 11'h0)
            sign = 1'b1;
	  xenc = {3'b000,sign,value[2:0]};
        end 
      else if(xdiff[9:0] < 10'h10)
        begin
          // DPCM2
	  value = (xdiff[9:0] - 10'h8) >> 1; 
	  xenc = {4'b0010,sign,value[1:0]};
        end 
      else if(xdiff[9:0] < 10'h20)
        begin
          // DPCM3
	  value = (xdiff[9:0] - 10'h10) >> 2;  
	  xenc = {4'b0011,sign,value[1:0]};
        end 
      else if(xdiff[9:0] < 10'hA0)
        begin
          // DPCM4
	  value = (xdiff[9:0] - 10'h20) >> 3;  
	  xenc = {2'b01,sign,value[3:0]};
        end 
      else
        begin
          // PCM
	  value = xorig[9:0] >> 4;
	  xenc = {1'b1,value[5:0]};
        end
    end

    // 10 - 6 - 10 encoder algorithm
    `C_10_6_10 : begin
      if(xdiff[9:0] < 10'h1)
        begin
          sign = 1'b1;
          // DPCM1
	  xenc = {5'b00000,sign};
        end 
      else if(xdiff[9:0] < 10'h3)
        begin
          // DPCM2
	  xenc = {5'b00001,sign};
        end 
      else if(xdiff[9:0] < 10'hB)
        begin
          // DPCM3
	  value = (xdiff[9:0] - 10'h3) >> 2;  
	  xenc = {4'b0001,sign,value[0]};
        end 
      else if(xdiff[9:0] < 10'h2B)
        begin
          // DPCM4
	  value = (xdiff[9:0] - 10'hB) >> 3;  
	  xenc = {3'b001,sign,value[1:0]};
        end 
      else if(xdiff[9:0] < 10'hAB)
        begin
          // DPCM4
	  value = (xdiff[9:0] - 10'h2B) >> 4;  
	  xenc = {2'b01,sign,value[2:0]};
        end 
        else
        begin
          // PCM
	  value = xorig[9:0] >> 5;
	  xenc = {1'b1,value[4:0]};
        end
    end
  endcase
  fn_encode_10bit = xenc[7:0];
end
endfunction

function [12:0] fn_abs_xdiff_12bit;
input [11:0] orig_data; 
input [11:0] pred_data;
reg [11:0]  xorig;
reg [11:0]  xpred;
reg [12:0] xdiff;
reg [11:0] xdiff_ones_complement;
reg [11:0] abs_xdiff;
begin
  xorig = orig_data;
  xpred = pred_data;
  xdiff = xorig - xpred;
  if(xdiff[12])
    begin
      xdiff_ones_complement = ~xdiff[11:0];
      abs_xdiff = xdiff_ones_complement + 1'b1;
    end
  else
    abs_xdiff = xdiff;

  fn_abs_xdiff_12bit = {xdiff[12],abs_xdiff};
end
endfunction


//-----------------------------------------------------------------------------
// Function that does the encoding of 12bit data
//-----------------------------------------------------------------------------
function [7:0] fn_encode_12bit; 
input [2:0] encoder_scheme;
input [11:0] orig_data; 
input [11:0] pred_data;
// local function variables
reg sign;
reg [11:0] xorig;
reg [11:0] value;
reg [7:0] xenc;
reg [12:0] xdiff;
begin
  xenc  = 8'b0; 
  value = 10'b0; 
  xorig = orig_data;
  xdiff = fn_abs_xdiff_12bit(orig_data,pred_data);
  sign  = xdiff[12];
  case (encoder_scheme) 
    // 12 - 8 - 12 decoder algorithm
    `C_12_8_12 : begin
      if(xdiff[11:0] < 11'h8)
        begin
          // DPCM1
	  value = xdiff[2:0];  
          if(xdiff == 13'h0)
            sign = 1'b1;
	  xenc = {4'b0000,sign,value[2:0]};
        end 
      else if(xdiff[11:0] < 11'h28)
        begin
          // DPCM2
	  value = (xdiff[11:0] - 10'h8) >> 1; 
	  xenc = {3'b011,sign,value[3:0]};
        end 
      else if(xdiff[11:0] < 11'h68)
        begin
          // DPCM3
	  value = (xdiff[11:0] - 10'h28) >> 2;  
	  xenc = {3'b010,sign,value[3:0]};
        end 
      else if(xdiff[11:0] < 11'hE8)
        begin
          // DPCM4
	  value = (xdiff[11:0] - 10'h68) >> 3;  
	  xenc = {3'b001,sign,value[3:0]};
        end 
      else if(xdiff[11:0] < 11'h168)
        begin
          // DPCM5
	  value = (xdiff[11:0] - 10'hE8) >> 4;  
	  xenc = {4'b0001,sign,value[2:0]};
        end 
        else
        begin
          // PCM
	  value = xorig[11:0] >> 5;
	  xenc = {1'b1,value[6:0]};
        end
    end 

    // 12 - 7 - 12 decoder algorithm
    `C_12_7_12 : begin
      if(xdiff[11:0] < 11'h4)
        begin
          // DPCM1
	  value = xdiff[1:0];  
          if(xdiff == 13'h0)
            sign = 1'b1;
	  xenc = {4'b0000,sign,value[1:0]};
        end 
      else if(xdiff[11:0] < 11'hC)
        begin
          // DPCM2
	  value = (xdiff[11:0] - 10'h4) >> 1; 
	  xenc = {4'b0001,sign,value[1:0]};
        end 
      else if(xdiff[11:0] < 11'h1C)
        begin
          // DPCM3
	  value = (xdiff[11:0] - 10'hC) >> 2;  
	  xenc = {4'b0010,sign,value[1:0]};
        end 
      else if(xdiff[11:0] < 11'h5C)
        begin
          // DPCM4
	  value = (xdiff[11:0] - 10'h1C) >> 3;  
	  xenc = {3'b010,sign,value[2:0]};
        end 
      else if(xdiff[11:0] < 11'hDC)
        begin
          // DPCM5
	  value = (xdiff[11:0] - 10'h5C) >> 4;  
	  xenc = {3'b011,sign,value[2:0]};
        end 
      else if(xdiff[11:0] < 11'h15C)
        begin
          // DPCM6
	  value = (xdiff[11:0] - 10'hDC) >> 5;  
	  xenc = {4'b0011,sign,value[1:0]};
        end 
         else
        begin
          // PCM
	  value = xorig[11:0] >> 6;
	  xenc = {1'b1,value[5:0]};
        end
     end

    // 12 - 6 - 12 decoder algorithm
    `C_12_6_12 : begin
      if(xdiff[11:0] < 11'h2)
        begin
          // DPCM1
	  value = xdiff[0];  
          if(xdiff == 13'h0)
            sign = 1'b1;
	  xenc = {4'b0000,sign,value[0]};
        end 
      else if(xdiff[11:0] < 11'hA)
        begin
          // DPCM3
	  value = (xdiff[11:0] - 10'h2) >> 2; 
	  xenc = {4'b0001,sign,value[0]};
        end 
      else if(xdiff[11:0] < 11'h2A)
        begin
          // DPCM4
	  value = (xdiff[11:0] - 10'hA) >> 3;  
	  xenc = {3'b010,sign,value[1:0]};
        end 
      else if(xdiff[11:0] < 11'h4A)
        begin
          // DPCM5
	  value = (xdiff[11:0] - 10'h2A) >> 4;  
	  xenc = {4'b0010,sign,value[0]};
        end 
      else if(xdiff[11:0] < 11'hCA)
        begin
          // DPCM6
	  value = (xdiff[11:0] - 10'h4A) >> 5;  
	  xenc = {3'b011,sign,value[1:0]};
        end 
      else if(xdiff[11:0] < 11'h14A)
        begin
          // DPCM7
	  value = (xdiff[11:0] - 10'hCA) >> 6;  
	  xenc = {4'b0011,sign,value[0]};
        end 
         else
        begin
          // PCM
	  value = xorig[11:0] >> 7;
	  xenc = {1'b1,value[4:0]};
        end
    end
  endcase
  fn_encode_12bit = xenc[7:0];
end
endfunction

always @(*) begin
  if(encode_10_bit) begin
    if(prediction_1_en) begin
      if(pixel1_valid | pixel2_valid)
        enc_data = fn_encode_10bit_wo_pred(encoder_scheme,orig_data[9:0]);
      else
        enc_data = fn_encode_10bit(encoder_scheme,orig_data[9:0],pred_data[9:0]);
    end
    else begin
      if(pixel1_valid)
        enc_data = fn_encode_10bit_wo_pred(encoder_scheme,orig_data[9:0]);
      else
        enc_data = fn_encode_10bit(encoder_scheme,orig_data[9:0],pred_data[9:0]);
    end
  end
  else begin
    if(prediction_1_en) begin
      if(pixel1_valid | pixel2_valid)
        enc_data = fn_encode_12bit_wo_pred(encoder_scheme,orig_data);
      else
        enc_data = fn_encode_12bit(encoder_scheme,orig_data,pred_data);
    end
    else begin
      if(pixel1_valid)
        enc_data = fn_encode_12bit_wo_pred(encoder_scheme,orig_data);
      else
        enc_data = fn_encode_12bit(encoder_scheme,orig_data,pred_data);
    end
  end
end


endmodule
