/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_sensor_fifo_ctrl.v
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
module csi2tx_sensor_fifo_ctrl #
  (
  parameter RAM_SIZE  = 13
  )
  (

  input   wire                 clk_wr           ,
  input   wire                 clk_rd           ,
  input   wire                 rst_wr_n         ,
  input   wire                 rst_rd_n         ,
  input   wire                 tinit_start_byteclk,
  input   wire                 tinit_start_csi_clk,
  input   wire                 wr_en            ,
  input   wire                 rd_en            ,
  input   wire                 fifo_wr_clr      ,
  input   wire                 fifo_rd_clr      ,
  output  wire                 fifo_empty_rd_dm ,
  output  wire                 fifo_full_wr_dm  ,
  output  wire                 almost_full      ,
  output wire                  wena_n           ,
  output wire                  cena_n           ,
  output  wire [RAM_SIZE-1:0]  wr_addr          ,
  output  wire [RAM_SIZE-1:0]  rd_addr          ,
  output wire                  wenb_n           ,
  output wire                  cenb_n           

  );

parameter FIFO_DEPTH = (2**(RAM_SIZE));
parameter ALMOST_THRESHOLD = FIFO_DEPTH - 8;

//This is added only for the intention of YUV420 8b/10b
parameter NXT_ALMOST_THRESHOLD = FIFO_DEPTH - 4;

reg [RAM_SIZE : 0] wr_ptr_bin;
reg [RAM_SIZE : 0] rd_ptr_bin;
reg [RAM_SIZE : 0] wr_ptr_gray;
reg [RAM_SIZE : 0] rd_ptr_gray;
reg [RAM_SIZE : 0] m_wr_ptr_gray_rd_dm;
reg [RAM_SIZE : 0] m_rd_ptr_gray_wr_dm;
wire [RAM_SIZE : 0] nxt_wr_ptr_bin;
wire [RAM_SIZE : 0] nxt_wr_ptr_bin_shift;
wire [RAM_SIZE : 0] nxt_rd_ptr_bin;
wire [RAM_SIZE : 0] nxt_rd_ptr_bin_shift;
wire [RAM_SIZE : 0] nxt_wr_ptr_gray;
wire [RAM_SIZE : 0] nxt_rd_ptr_gray;


reg [RAM_SIZE-1:0] rd_ptr_g2b;
reg  [RAM_SIZE:0] ptr_diff;
reg [RAM_SIZE : 0] s_wr_ptr_gray_rd_dm;
reg [RAM_SIZE-1:0] rd_ptr_g2b_reg;
wire almost_full_s;
wire almost_full_nxt;
reg [RAM_SIZE : 0] s_rd_ptr_gray_wr_dm;
integer i;

//-----------------> Write pointer clock doamin <-----------------------------//

// Write pointer in the write clock domain
always @(posedge clk_wr or negedge rst_wr_n)
begin
  if(rst_wr_n == 1'b0)
    begin
      wr_ptr_bin <= 'b0;
    end
  else if (tinit_start_csi_clk == 1'b0)
    wr_ptr_bin <= 'b0;
  else if(fifo_wr_clr)
    begin
      wr_ptr_bin <= 'b0;
    end
  else
    begin
      wr_ptr_bin <= nxt_wr_ptr_bin;
    end
end

//----------------------------------------------------------------------------//
// Increment write pointer only during wr_en.
// Fifo write during full is prohibited
//----------------------------------------------------------------------------//
assign nxt_wr_ptr_bin = (wr_en)? (wr_ptr_bin + 1'b1) : wr_ptr_bin;


//----------------------------------------------------------------------------//
// Gray counter value for the next binary ptr
//----------------------------------------------------------------------------//
assign nxt_wr_ptr_bin_shift = nxt_wr_ptr_bin >> 1;
assign nxt_wr_ptr_gray      = nxt_wr_ptr_bin_shift ^ nxt_wr_ptr_bin;

//----------------------------------------------------------------------------//
// Create a gray counter, which will be used for
// empty and full condition
//----------------------------------------------------------------------------//
always @(posedge clk_wr or negedge rst_wr_n)
begin
  if(rst_wr_n == 1'b0)
    begin
      wr_ptr_gray <= 'b0;
    end
  else if (tinit_start_csi_clk == 1'b0)
    wr_ptr_gray <= 'b0;
  else if(fifo_wr_clr)
    begin
      wr_ptr_gray <= 'b0;
    end
  else
    begin
      wr_ptr_gray <= nxt_wr_ptr_gray;
    end
end

//----------------------------------------------------------------------------//
// Synchronized rd_ptr_gray in write clock domain
//----------------------------------------------------------------------------//

always @(posedge clk_wr or negedge rst_wr_n)
begin
  if(rst_wr_n == 1'b0)
    begin
      m_rd_ptr_gray_wr_dm <= 'b0;
      s_rd_ptr_gray_wr_dm <= 'b0;
    end
  else if (tinit_start_csi_clk == 1'b0)
    begin
      m_rd_ptr_gray_wr_dm <= 'b0;
      s_rd_ptr_gray_wr_dm <= 'b0;
    end
  else if(fifo_wr_clr)
    begin
      m_rd_ptr_gray_wr_dm <= 'b0;
      s_rd_ptr_gray_wr_dm <= 'b0;
    end
  else
    begin
      m_rd_ptr_gray_wr_dm <= rd_ptr_gray;
      s_rd_ptr_gray_wr_dm <= m_rd_ptr_gray_wr_dm;
    end
end


assign fifo_full_wr_dm =( ((s_rd_ptr_gray_wr_dm[RAM_SIZE]    )  != (wr_ptr_gray[RAM_SIZE]     )) &&
                          ((s_rd_ptr_gray_wr_dm[RAM_SIZE-1]  )  != (wr_ptr_gray[RAM_SIZE-1]   )) &&
                          ((s_rd_ptr_gray_wr_dm[RAM_SIZE-2:0])  == (wr_ptr_gray[RAM_SIZE-2:0] )) )? 1'b1 : 1'b0;
                         

// assign rd_ptr_g2b[10] = s_rd_ptr_gray_wr_dm[10];                        
// assign rd_ptr_g2b[9]  = rd_ptr_g2b[10] ^ s_rd_ptr_gray_wr_dm[9];
// assign rd_ptr_g2b[8]  = rd_ptr_g2b[9] ^ s_rd_ptr_gray_wr_dm[8];
// assign rd_ptr_g2b[7]  = rd_ptr_g2b[8] ^ s_rd_ptr_gray_wr_dm[7];
// assign rd_ptr_g2b[6]  = rd_ptr_g2b[7] ^ s_rd_ptr_gray_wr_dm[6];
// assign rd_ptr_g2b[5]  = rd_ptr_g2b[6] ^ s_rd_ptr_gray_wr_dm[5];
// assign rd_ptr_g2b[4]  = rd_ptr_g2b[5] ^ s_rd_ptr_gray_wr_dm[4];
// assign rd_ptr_g2b[3]  = rd_ptr_g2b[4] ^ s_rd_ptr_gray_wr_dm[3];
// assign rd_ptr_g2b[2]  = rd_ptr_g2b[3] ^ s_rd_ptr_gray_wr_dm[2];
// assign rd_ptr_g2b[1]  = rd_ptr_g2b[2] ^ s_rd_ptr_gray_wr_dm[1];
// assign rd_ptr_g2b[0]  = rd_ptr_g2b[1] ^ s_rd_ptr_gray_wr_dm[0];


always@(s_rd_ptr_gray_wr_dm)
begin
  for ( i=0; i < RAM_SIZE; i=i+1)
   rd_ptr_g2b[i] = ^ (s_rd_ptr_gray_wr_dm >> i);
end

always@(posedge clk_wr or negedge rst_wr_n)
begin
 if ( rst_wr_n == 1'b0 )
  rd_ptr_g2b_reg <= 'b0;
 else if (tinit_start_csi_clk == 1'b0)
  rd_ptr_g2b_reg <= 'b0;
 else if (fifo_wr_clr)
  rd_ptr_g2b_reg <= 'b0;
 else
  rd_ptr_g2b_reg <= rd_ptr_g2b;

end
  
always@(*)
begin
 if (wr_addr > rd_ptr_g2b_reg[RAM_SIZE-1:0])
    ptr_diff = wr_addr - rd_ptr_g2b[RAM_SIZE-1:0];
 else if(wr_addr < rd_ptr_g2b_reg[RAM_SIZE-1:0])
    ptr_diff = ((FIFO_DEPTH - rd_ptr_g2b_reg[RAM_SIZE-1:0]) + wr_addr);
 else
    ptr_diff = 'b0;
end

assign almost_full_s = (ptr_diff >= ALMOST_THRESHOLD) ? 1'b1 : 1'b0; 

assign almost_full_nxt = ( ptr_diff >= NXT_ALMOST_THRESHOLD ) ? 1'b1 : 1'b0;

assign almost_full = almost_full_s | almost_full_nxt;


//----------------------------------------------------------------------------//
// Write address is a split version of the write pointer
//----------------------------------------------------------------------------//
assign wr_addr = wr_ptr_bin[RAM_SIZE-1:0];



//----------------------------------------------------------------------------//
//-----------------> Read pointer clock doamin <-----------------------
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Binary read pointer
//----------------------------------------------------------------------------//
always @(posedge clk_rd or negedge rst_rd_n)
begin
  if(rst_rd_n == 1'b0)
    begin
      rd_ptr_bin <= 'b0;
    end
  else if (tinit_start_byteclk == 1'b0)
    begin
      rd_ptr_bin <= 'b0;
    end
  else if(fifo_rd_clr)
    begin
      rd_ptr_bin <= 'b0;
    end
  else
    begin
      rd_ptr_bin <= nxt_rd_ptr_bin;
    end
end

//----------------------------------------------------------------------------//
// Read address for the RAM
//----------------------------------------------------------------------------//
assign rd_addr = rd_ptr_bin[RAM_SIZE-1:0];

//----------------------------------------------------------------------------//
// Binary next read pointer logic
//----------------------------------------------------------------------------//
assign nxt_rd_ptr_bin = rd_en ? (rd_ptr_bin + 1'b1) : rd_ptr_bin;

//----------------------------------------------------------------------------//
// Gray counter value for the next binary ptr
//----------------------------------------------------------------------------//
assign nxt_rd_ptr_bin_shift = nxt_rd_ptr_bin >> 1;
assign nxt_rd_ptr_gray = nxt_rd_ptr_bin_shift ^ nxt_rd_ptr_bin;

//----------------------------------------------------------------------------//
// Create a gray counter, which will be used for
// empty and full condition
//----------------------------------------------------------------------------//
always @(posedge clk_rd or negedge rst_rd_n)
begin
  if(rst_rd_n == 1'b0)
    begin
      rd_ptr_gray <='b0;
    end
  else if (tinit_start_byteclk == 1'b0)
    begin
      rd_ptr_gray <= 'b0;
    end
  else if(fifo_rd_clr)
    begin
      rd_ptr_gray <= 'b0;
    end
  else
    begin
      rd_ptr_gray <= nxt_rd_ptr_gray;
    end
end

//----------------------------------------------------------------------------//
// Synchronized wr_ptr_gray in read clock domain
//----------------------------------------------------------------------------//

always @(posedge clk_rd or negedge rst_rd_n)
begin
  if(rst_rd_n == 1'b0)
    begin
      m_wr_ptr_gray_rd_dm <= 'b0;
      s_wr_ptr_gray_rd_dm <= 'b0;
    end
  else if (tinit_start_byteclk == 1'b0)
    begin
      m_wr_ptr_gray_rd_dm <= 'b0;
      s_wr_ptr_gray_rd_dm <= 'b0;
    end
  else if(fifo_rd_clr)
    begin
      m_wr_ptr_gray_rd_dm <= 'b0;
      s_wr_ptr_gray_rd_dm <= 'b0;
    end
  else
    begin
      m_wr_ptr_gray_rd_dm <= wr_ptr_gray;
      s_wr_ptr_gray_rd_dm <= m_wr_ptr_gray_rd_dm;
    end
end


//----------------------------------------------------------------------------//
// FIFO empty conditio in read domain
//----------------------------------------------------------------------------//
assign fifo_empty_rd_dm = (s_wr_ptr_gray_rd_dm [RAM_SIZE:0] == rd_ptr_gray[RAM_SIZE:0]) ? 1'b1 : 1'b0;

assign wena_n = ~wr_en;
assign cena_n = ~wr_en;
assign wenb_n = rd_en;
assign cenb_n = ~rd_en;

endmodule
