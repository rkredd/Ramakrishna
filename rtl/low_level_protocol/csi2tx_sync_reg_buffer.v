/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_sync_reg_buffer.v
// Author      : SHYAM SUNDAR B. S
// Version     : v1p2
// Abstract    :        
//              
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`include "csi2tx_defines.v"
module csi2tx_sync_reg_buffer #
 (
 parameter FIFO_ADDR_WIDTH = 3,
 parameter DATA_SIZE       = 64
 )
 (
 input  wire                       clk             ,
 input  wire                       rst_n           ,
 input  wire                       wren            ,
 input  wire                       rden            ,
 input  wire [DATA_SIZE-1:0]       wrdata          ,
 output wire [DATA_SIZE-1:0]       rddata          ,
 output wire                       rddata_vld      ,
 input  wire                       clr_buffer      ,
 output wire [FIFO_ADDR_WIDTH-1:0] wraddr          ,
 output wire [FIFO_ADDR_WIDTH-1:0] rdaddr          ,
 output wire                       full            ,
 output wire                       empty           ,
 output wire                       almostfull      ,
 output wire                       almostempty     ,
 output wire [FIFO_ADDR_WIDTH:0]   spacefilled     ,
 output wire [FIFO_ADDR_WIDTH:0]   spaceempty
 );
 
 parameter FIFO_DEPTH = (2**(FIFO_ADDR_WIDTH));
 parameter ALMOST_FULL_THRESHOLD = (FIFO_DEPTH - 4); // worstcase there will be two additional writes can happen header + CRC
 
 reg [FIFO_ADDR_WIDTH:0] ptr_diff;
 reg [FIFO_ADDR_WIDTH:0] wraddr_r;
 reg [FIFO_ADDR_WIDTH:0] rdaddr_r;
 reg                     rddata_vld_r;
 reg [DATA_SIZE-1:0]     rddata_r;
 
 //Memory is implemented as FLOPs
 reg [DATA_SIZE-1:0] ram [FIFO_DEPTH-1:0];
 integer i;
 
 //-----------------------------------------------------------------------------
 // Write into memory
 always@(posedge clk or negedge rst_n)
 begin
  if (rst_n == 1'b0)
   for (i=0; i < FIFO_DEPTH; i=i+1)
    ram[i] <= 'b0;
  else if (clr_buffer == 1'b1)
   for (i=0; i < FIFO_DEPTH; i=i+1)
    ram[i] <= 'b0;
  else if (wren == 1'b1)
   ram[wraddr_r[FIFO_ADDR_WIDTH-1:0]] <= wrdata;   
 end
 
 //-----------------------------------------------------------------------------
 // write pointe logic
 always@(posedge clk or negedge rst_n)
 begin
  if (rst_n == 1'b0)
   wraddr_r[FIFO_ADDR_WIDTH:0] <= 'b0;
  else if (clr_buffer == 1'b1)
   wraddr_r[FIFO_ADDR_WIDTH:0] <= 'b0;
  else if ((wren == 1'b1) && (full == 1'b0))
   wraddr_r[FIFO_ADDR_WIDTH:0] <= wraddr_r[FIFO_ADDR_WIDTH:0] + 'b1;
 end
 
 //-----------------------------------------------------------------------------
 // read address
 always@(posedge clk or negedge rst_n)
 begin
  if ( rst_n == 1'b0)
   rdaddr_r[FIFO_ADDR_WIDTH:0] <= 'b0;
  else if (clr_buffer == 1'b1)
   rdaddr_r[FIFO_ADDR_WIDTH:0] <= 'b0;
  else if ( (rden == 1'b1) && (empty == 1'b0))
   rdaddr_r[FIFO_ADDR_WIDTH:0] <= rdaddr_r[FIFO_ADDR_WIDTH:0] + 'b1;   
 end
 
 //----------------------------------------------------------------------------
 // Registered output for better timing
 always@(posedge clk or negedge rst_n)
 begin
  if (rst_n == 1'b0)
   rddata_r <= 'b0;
  else if (clr_buffer == 1'b1)
   rddata_r <= 'b0;
  else if ( (rden == 1'b1) && (empty == 1'b0)) 
   rddata_r <= ram[rdaddr_r[FIFO_ADDR_WIDTH-1:0]];
 end
 
 //-----------------------------------------------------------------------------
 // Read data valid..Latency of 1
 always@(posedge clk or negedge rst_n)
 begin
  if (rst_n == 1'b0)
   rddata_vld_r <= 'b0;
  else if (clr_buffer == 1'b1)
   rddata_vld_r <= 'b0;
  else if ((rden == 1'b1) && (empty == 1'b0))
   rddata_vld_r <= 'b1;
  else
   rddata_vld_r <= 'b0;
 end
 
 //-----------------------------------------------------------------------------
 // Pointer difference
 always@(*)
 begin
  if (wraddr_r[FIFO_ADDR_WIDTH-1:0] > rdaddr_r[FIFO_ADDR_WIDTH-1:0])
   ptr_diff = wraddr_r[FIFO_ADDR_WIDTH-1:0] - rdaddr_r[FIFO_ADDR_WIDTH-1:0];
  else if (wraddr_r[FIFO_ADDR_WIDTH-1:0] < rdaddr_r[FIFO_ADDR_WIDTH-1:0])
   ptr_diff = ((FIFO_DEPTH-rdaddr_r[FIFO_ADDR_WIDTH-1:0]) + wraddr_r[FIFO_ADDR_WIDTH-1:0]);
  else if (full)
   ptr_diff = FIFO_DEPTH;
  else
   ptr_diff = 'b0;
 end
 
 //-----------------------------------------------------------------------------
 // output port assignment
 assign wraddr      = wraddr_r[FIFO_ADDR_WIDTH-1:0];
 assign rdaddr      = rdaddr_r[FIFO_ADDR_WIDTH-1:0];
 assign full        = (wraddr_r[FIFO_ADDR_WIDTH-1:0] == rdaddr_r[FIFO_ADDR_WIDTH-1:0]) ? wraddr_r[FIFO_ADDR_WIDTH] ^ rdaddr_r[FIFO_ADDR_WIDTH] : 'b0;
 assign empty       = (wraddr_r == rdaddr_r) ? 1'b1 : 1'b0;
 assign almostfull  = (ptr_diff >= ALMOST_FULL_THRESHOLD) ? 1'b1 : 1'b0;
 assign almostempty = 1'b0;
 assign spacefilled = ptr_diff;
 assign spaceempty  = (FIFO_DEPTH-ptr_diff);
 assign rddata_vld  = rddata_vld_r;
 assign rddata      = rddata_r;
 
endmodule
