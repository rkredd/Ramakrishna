/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_decoder.v
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
module csi2tx_decoder (
  //input  wire                      sensor_clk,
  //input  wire                      sys_rst_n,
  input  wire [4:0]                comp_scheme,
  input  wire                      enable,
  input  wire [7:0]                enc_data,
  input  wire [11:0]               pred_data,
  input  wire                      pixel1_valid,
  input  wire                      pixel2_valid,
  
  output reg  [11:0]               dec_data 
);

// Declaration of nets used in the instantiation wiring
wire prediction_1_en = comp_scheme[3];

//wire prediction_2_en = comp_scheme[4];

wire [2:0] decoder_scheme = comp_scheme[2:0];

//wire compression_scheme = |comp_scheme[2:0];

wire decode_10_bit =  ((decoder_scheme == `C_10_6_10) || (decoder_scheme == `C_10_7_10) ||
                       (decoder_scheme == `C_10_8_10)) ? enable : 1'b0;

wire decode_12_bit = ((decoder_scheme == `C_12_6_12) || (decoder_scheme == `C_12_7_12) ||
                      (decoder_scheme == `C_12_8_12)) ? enable : 1'b0;


//-----------------------------------------------------------------------------
// Function to deocode the 10 bit value without any prediction 
//-----------------------------------------------------------------------------
function [9:0] fn_decode_10bit_wo_pred;
input [2:0] decoder_scheme;
input [7:0] xenc; 
// local variables for the function
reg [9:0] xdec; 
begin
 xdec = {2'b0,xenc};
 case (decoder_scheme) 
   `C_10_8_10 : xdec = (xdec << 2) + 10'd2; 
   `C_10_7_10 : xdec = (xdec << 3) + 10'd4; 
   default    : xdec = (xdec << 4) + 10'd8; 
 endcase
 // return the without prediction value
 fn_decode_10bit_wo_pred = xdec; 
end
endfunction

//-----------------------------------------------------------------------------
// Function to deocode the 12 bit value without any prediction 
//-----------------------------------------------------------------------------
function [11:0] fn_decode_12bit_wo_pred;
input [2:0] decoder_scheme;
input [7:0] xenc; 
// local variables for the function
reg [11:0] xdec; 
begin
 xdec = {4'b0,xenc};
 case (decoder_scheme) 
   `C_12_8_12 : xdec = (xdec << 4) + 12'd8; 
   `C_12_7_12 : xdec = (xdec << 5) + 12'd16; 
   default    : xdec = (xdec << 6) + 12'd32; 
 endcase
 // return the without prediction value
 fn_decode_12bit_wo_pred = xdec;
end
endfunction


//-----------------------------------------------------------------------------
// Function that does the 10 bit decoder
// Note : An additonal bit is used to make cover the overflow condition
//-----------------------------------------------------------------------------
function [9:0] fn_decode_10bit;
input [2:0] decoder_scheme;
input [7:0] xenc; 
input [9:0] pred;
// local function variables
reg sign;
reg [10:0] value;
reg [10:0] xdec;
reg [10:0] xpred;
begin
  xdec  = {3'b0,xenc}; 
  xpred = {1'b0,pred};
  value = {3'b0,xenc}; 
  sign  = 1'b0;
  case (decoder_scheme) 
    // 10 - 8 - 10 decoder algorithm
    `C_10_8_10 : begin
      casez (xenc[7:5])
      3'b00? : begin
        // DPCM1
        sign = xenc[5];
        value = value & 11'h1f;  
        xdec = sign ? xpred - value : xpred + value;
      end 
      3'b010 : begin
        // DPCM2
        sign = xenc[4];
        value = value & 11'hf; value = (value << 1) + 11'd32; 
        xdec = sign ? xpred - value : xpred + value;
      end 
      3'b011 : begin
        // DPCM3
        sign = xenc[4];
        value = value & 11'hf; value = (value << 2) + 11'd64 + 11'd1;  
        xdec = fn_dec_10bit_inc_dcr_cof(sign,xpred,value);
      end 
      default : begin
        // PCM
        value = value & 11'h7f; value = value << 3;
        xdec = (value > xpred) ? value + 11'd3 : value + 11'd4;
      end
      endcase
    end 

    // 10 - 7 - 10 decoder algorithm
    `C_10_7_10 : begin
      casez (xenc[6:3]) 
      4'b000?: begin
        // DPCM1
        sign = xenc[3];
        value = value & 11'h7;
        xdec = sign ? xpred - value : xpred + value;
      end
      4'b0010: begin
        // DPCM2
        sign = xenc[2];
        value = value & 11'h3; value = (value << 1) + 11'd8;
        xdec = sign ? xpred - value : xpred + value;
      end
      4'b0011: begin
        // DPCM3
        sign = xenc[2];
        value = value & 11'h3; value = (value << 2) + 11'd16 + 11'd1;
        xdec = fn_dec_10bit_inc_dcr_cof(sign,xpred,value); 
      end
      4'b01??: begin
        // DPCM4
        sign = xenc[4];
        value = value & 11'hf; value = (value << 3) + 11'd32 + 11'd3;
        xdec = fn_dec_10bit_inc_dcr_cof(sign,xpred,value); 
      end
      default : begin
        // PCM
        value = value & 11'h3f; value = (value << 4);
        xdec = (value > xpred) ? value + 11'd7 : value + 11'd8;
      end
      endcase
    end

    // 10 - 6 - 10 decoder algorithm
    default : begin
      casez(xenc[5:1]) 
      4'b0000 : begin
        // DPCM1
        xdec = xpred;
      end 
      4'b0001 : begin
        // DPCM2
        sign = xenc[0];
        value = 11'h1;
        xdec = sign ? xpred - value : xpred + value; 
      end 
      4'b001? : begin
        // DPCM3
        sign = xenc[1];
        value = value & 11'h1; value = (value << 2) + 11'd3 + 11'd1;
        xdec = fn_dec_10bit_inc_dcr_cof(sign,xpred,value);
      end 
      4'b01?? : begin
        // DPCM4
        sign = xenc[2];
        value = value & 11'h3; value = (value << 3) + 11'd11 + 11'd3;
        xdec = fn_dec_10bit_inc_dcr_cof(sign,xpred,value);
      end 
      4'b1??? : begin
        // DPCM4
        sign = xenc[3];
        value = value & 11'h7; value = (value << 4) + 11'd43 + 11'd7;
        xdec = fn_dec_10bit_inc_dcr_cof(sign,xpred,value);
      end 
      default : begin
        // PCM
        value = value & 11'h1f; value = (value << 5);
        xdec = (value > xpred) ? value + 11'd15 : value + 11'd16;
      end
      endcase
    end
  endcase
  fn_decode_10bit = xdec[9:0];
end
endfunction

//-----------------------------------------------------------------------------
// Function that does the 12 bit decoder
// Note : An additonal bit is used to make cover the overflow condition
//-----------------------------------------------------------------------------
function [11:0] fn_decode_12bit; 
input [2:0] decoder_scheme;
input [7:0] xenc; 
input [11:0] pred;
// local function variables
reg sign;
reg [12:0] value;
reg [12:0] xdec; 
reg [12:0] xpred; 
begin
  xdec  = {5'b0,xenc}; 
  xpred = {1'b0,pred};
  value = {5'b0,xenc}; 
  sign  = 1'b0;
  case (decoder_scheme) 
    // 12 - 8 - 12 decoder algorithm
    `C_12_8_12 : begin
     casez (xenc[7:4]) 
     4'b0000 : begin 
       // DPCM1
       sign = xenc[3];
       value = value & 13'h7;
       xdec = sign ? xpred - value : xpred + value;
     end
     4'b011?: begin
       // DPCM2
       sign = xenc[4];
       value = value & 13'hf; value = (value << 1) + 13'd8;
       xdec = sign ? xpred - value : xpred + value;
     end
     4'b010? : begin 
       // DPCM3
       sign = xenc[4];
       value = value & 13'hf; value = (value << 2) + 13'd40 + 13'd1;
       xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value);
     end 
     4'b001? : begin
       // DPCM4
       sign = xenc[4];
       value = value & 13'hf; value = (value << 3) + 13'd104 + 13'd3;
       xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value);
     end 
     4'b0001: begin
       // DPCM5
       sign = xenc[3];
       value = value & 13'h7; value = (value << 4) + 13'd232 + 13'd7;
       xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value);
     end 
     default : begin
       // PCM 
       value = value & 13'h7f; value = (value << 5);
       xdec = (value > xpred) ? value + 13'd15 : value + 13'd16;  
     end
     endcase
    end 

    // 12 - 7 - 12 decoder algorithm
    `C_12_7_12 : begin
      casez(xenc[6:3])
      4'b0000 : begin
        // DPCM1
	sign = xenc[2]; 
	value = value & 13'h3;
	xdec = sign ? xpred - value : xpred + value;
      end 
      4'b0001 : begin
        // DPCM2
	sign = xenc[2]; 
	value = value & 13'h3; value = (value << 1) + 13'd4;
	xdec = sign ? xpred - value : xpred + value;
      end 
      4'b0010 : begin
        // DPCM3
	sign = xenc[2]; 
	value = value & 13'h3; value = (value << 2) + 13'd12 + 13'd1;
	xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value); 
      end 
      4'b010? : begin
        // DPCM4
	sign = xenc[3]; 
	value = value & 13'h7; value = (value << 3) + 13'd28 + 13'd3;
	xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value); 
      end 
      4'b011? : begin
        // DPCM5
	sign = xenc[3]; 
	value = value & 13'h7; value = (value << 4) + 13'd92 + 13'd7;
	xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value); 
      end 
      4'b0011 : begin
        // DPCM6
	sign = xenc[2];
	value = value & 13'h3; value = (value << 5) + 13'd220 + 13'd15;
	xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value); 
      end 
      default : begin
        // PCM
	value = value & 13'h3f; value = (value << 6);
	xdec = (value > xpred) ? value + 13'd31 : value + 13'd32;
      end
      endcase
    end

    // 12 - 6 - 12 decoder algorithm
    default : begin
      casez(xenc[5:2]) 
      4'b0000 : begin
        // DPCM1
        sign = xenc[1]; 
	value = value & 13'h1;
	xdec = sign ? xpred - value : xpred + value;
      end 
      4'b0001 : begin
        // DPCM3
        sign = xenc[1]; 
	value = value & 13'h1; value = (value << 2) + 13'd2 + 13'd1;
	xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value);
      end 
      4'b010? : begin
        // DPCM4
        sign = xenc[2];
	value = value & 13'h3; value = (value << 3) + 13'd10 + 13'd3;
	xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value);
      end 
      4'b0010 : begin
        // DPCM5
        sign = xenc[1]; 
	value = value & 13'h1; value = (value << 4) + 13'd42 + 13'd7;
	xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value);
      end 
      4'b011? : begin
        // DPCM6
        sign = xenc[2]; 
	value = value & 13'h3; value = (value << 5) + 13'd74 + 13'd15;
	xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value);
      end 
      4'b0011 : begin
        // DPCM7
        sign = xenc[1]; 
	value = value & 13'h1; value = (value << 6) + 13'd202 + 13'd31;
	xdec = fn_dec_12bit_inc_dcr_cof(sign,xpred,value);
      end 
      default : begin
        // PCM
        value = value & 13'h1f; value = (value << 7); 
	xdec = (value > xpred) ? value + 13'd63 : value + 13'd64;
      end
      endcase
    end
  endcase
  fn_decode_12bit = xdec[11:0];
end
endfunction

//-----------------------------------------------------------------------------
// Function to decrement or increment a value according to the sign bit 
// for 10 bit decoder
//-----------------------------------------------------------------------------
function [10:0] fn_dec_10bit_inc_dcr_cof;
input sign;
input [10:0] xpred;
input [10:0] value;
// local register value
reg [10:0] xdec;
begin
  if(sign) begin
    xdec = (xpred < value) ? 11'h0 : xpred - value; 
  end else begin
    xdec = xpred + value; 
    xdec = xdec[10] ? 11'd1023 : xdec;
  end
  fn_dec_10bit_inc_dcr_cof = xdec;
end
endfunction

//-----------------------------------------------------------------------------
// Function to decrement or increment a value according to the sign bit 
// for 12 bit decoder
//-----------------------------------------------------------------------------
function [12:0] fn_dec_12bit_inc_dcr_cof;
input sign;
input [12:0] xpred;
input [12:0] value;
// local register value
reg [12:0] xdec;
begin
  if(sign) begin
    xdec = (xpred < value) ? 13'h0 : xpred - value; 
  end else begin
    xdec = xpred + value; 
    xdec = xdec[12] ? 13'd4095 : xdec;
  end
  fn_dec_12bit_inc_dcr_cof = xdec;
end
endfunction



//-----------------------------------------------------------------------------
// Combinational logic to represent the final decoded value 
//-----------------------------------------------------------------------------
always @(*) begin
  // Decode 10 bit 
  if(decode_10_bit) begin
    dec_data[11:9] = 3'b0;

    // Prediction 1 algorithm
    if(prediction_1_en) begin
      // The first two pixels are decoded without any prediction 
      if(pixel1_valid | pixel2_valid) begin
        dec_data[9:0] = fn_decode_10bit_wo_pred(decoder_scheme,enc_data);
      end else begin
        dec_data[9:0] = fn_decode_10bit(decoder_scheme,enc_data,pred_data[9:0]);
      end 
    // Prediction 2 algorithm
    end else begin
      // Only the first pixel is decoded with out any prediction
      if(pixel1_valid) begin
        dec_data[9:0] = fn_decode_10bit_wo_pred(decoder_scheme,enc_data);
      end else begin
        dec_data[9:0] = fn_decode_10bit(decoder_scheme,enc_data,pred_data[9:0]);
      end 
    end 

  // Decode 12 bit 
  end else begin
    // Prediction 1 algorithm
    if(prediction_1_en) begin
      // The first two pixels are decoded without any prediction 
      if(pixel1_valid | pixel2_valid) begin
        dec_data[11:0] = fn_decode_12bit_wo_pred(decoder_scheme,enc_data);
      end else begin
        dec_data[11:0] = fn_decode_12bit(decoder_scheme,enc_data,pred_data[11:0]);
      end 
    // Prediction 2 algorithm
    end else begin
      // Only the first pixel is decoded with out any prediction
      if(pixel1_valid) begin
        dec_data[11:0] = fn_decode_12bit_wo_pred(decoder_scheme,enc_data);
      end else begin
        dec_data[11:0] = fn_decode_12bit(decoder_scheme,enc_data,pred_data[11:0]);
      end 
    end 
  end 
end 

endmodule
