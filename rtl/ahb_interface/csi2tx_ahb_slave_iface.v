/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_ahb_slave_iface.v
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

//`define BKND_RDY_LOW
`define ADDR_NO_INC
//`define SOFT_RST

module csi2tx_ahb_slave_iface(
  clk_ahb,
  rstahb_n,
  `ifdef SOFT_RST
  soft_reset,
  `endif

  //Inputs from AHB 
  t_htrans,
  `ifdef ADDR_NO_INC
  t_hburst,   
   `endif
  t_hwrite,
  t_hsel,
  t_hwdata,
  t_haddr,
  t_hsize,
  t_hready_in,

  //Outputs to AHB
  t_hready,
  t_hrdata,
  t_hresp,

  //Local bus control control register interface
  lb_rdyh,
  ahb_error_flag,
  lb_din,

  lb_cs,
  lb_adsm,
  lb_wrout,
  lb_beout,
  lb_aout,
  lb_dout,
  lb_burst_addr_incr
);

  parameter ADRDAT = 32;     //for HSI
  parameter HTRESP = 2;
  parameter BHSIZE = 3;
  parameter ADDSIZ = 32;
  parameter DATSIZ = 32;


  input clk_ahb;
  input rstahb_n;
  `ifdef SOFT_RST
  input soft_reset;
  `endif

  input [HTRESP -1:0]t_htrans;        // Nonseq or Seq transaction from AHB master
  `ifdef ADDR_NO_INC
  input [2:0] t_hburst;               // INCR Burst not supported 
  `endif
  input t_hwrite;                     // Read/Write from AHB master
  input t_hsel;                       // Select signal from AHB master
  input [DATSIZ -1:0]t_hwdata;        // Write data from AHB master
  input [ADRDAT -1:0]t_haddr;         // Address from AHB master
  input [BHSIZE -1:0]t_hsize;         // Indicate byte/halfw/doublew from AHB master
  input t_hready_in;                  // Ready signal from AHB 
  input [DATSIZ -1:0]lb_din;
  input lb_rdyh;
  input wire ahb_error_flag;
  input	 lb_burst_addr_incr;

  output t_hready;                    // Ready signal from AHB Slave
  output [DATSIZ -1:0] t_hrdata;      // read Data
  output [HTRESP -1:0] t_hresp;       // Transfer response from AHB Slave

  output lb_cs;                       // Active high Chip select signal to Backend 
  output lb_adsm;                     // Active high Adress storbe signal to Backend 
  output lb_wrout;                    // Active high write signal to Backend 
  output [3:0] lb_beout;              // Active high byte lanes to backend
  output [ADDSIZ -1 : 0] lb_aout;
  output [DATSIZ -1 : 0] lb_dout;

  reg lb_cs;
  reg lb_adsm;
  reg lb_wrout;
 // `ifdef ADDR_NO_INC
 // wire [ADDSIZ -1:0] lb_aout;
 // `else
  reg [ADDSIZ -1:0] lb_aout;
 //  `endif
  reg [3:0] sig_cbe_tar;

  wire sig_t_hready;
  wire [HTRESP -1:0] t_hresp;
  wire t_hready;

  `ifdef ADDR_NO_INC
  reg [ADDSIZ -1:0] var_aout;
  reg [ADDSIZ -1:0] fixed_aout;
  `endif

  assign sig_t_hready = lb_rdyh;
  
  // Slave response -- OKAY RESPONSE
  assign t_hresp = ahb_error_flag ? 2'b01: 2'b00;

  // Slave Response ready
  assign t_hready = lb_rdyh;

  // Slave Read data
  assign t_hrdata = (lb_rdyh) ? lb_din : 32'h0;

  // Active low Byte enables
  assign lb_beout = sig_cbe_tar;

  // Wdite data in Local bus
  assign lb_dout = t_hwdata;

  //Asserted for sequential/Non sequential type of AHB transfer indicating
  //write/read in localbus
  always @(posedge clk_ahb or negedge rstahb_n)
    if(!rstahb_n)
      lb_cs <= 1'b0;
    `ifdef SOFT_RST
    else if(soft_reset)
      lb_cs <= 1'b0;
    `endif
    else if(((t_htrans == 2'b10) || (t_htrans == 2'b11)) && t_hsel && t_hready_in )
      lb_cs <= 1'b1;
    else 
      lb_cs <= 1'b0;

  //Asserted for sequential/Non sequential type of AHB transfer indicating
  //write/read in localbus
  always @(posedge clk_ahb or negedge rstahb_n)
    if(!rstahb_n)
      lb_adsm <= 1'b0;
    `ifdef SOFT_RST
    else if(soft_reset)
      lb_adsm <= 1'b0;
    `endif
    else if(((t_htrans == 2'b10) || (t_htrans == 2'b11)) && t_hsel && t_hready_in && (!t_hwrite))
      lb_adsm <= 1'b1;
    else 
      lb_adsm <= 1'b0;

  //Asserted for sequential/Non sequential type of AHB transfer indicating
  //write in localbus
  always @(posedge clk_ahb or negedge rstahb_n)
    if(!rstahb_n)
      lb_wrout <= 1'b0;
    `ifdef SOFT_RST
    else if(soft_reset)
      lb_wrout <= 1'b0;
    `endif
    else if(((t_htrans == 2'b10) || (t_htrans == 2'b11)) && t_hwrite && t_hsel && t_hready_in )
      lb_wrout <= 1'b1;
    else 
      lb_wrout <= 1'b0; 

  // byte enable for ahb target
  always @(posedge clk_ahb or negedge rstahb_n)
    if(!rstahb_n)
      sig_cbe_tar <= 4'b0000;
    `ifdef SOFT_RST
    else if(soft_reset)
      sig_cbe_tar <= 4'b0000;
    `endif
    else if (t_hsel & t_hready_in )
      case(t_haddr[1:0]) 
        2'b00:
          case(t_hsize)
            3'd2 : sig_cbe_tar <= 4'b1111;
            3'd1 : sig_cbe_tar <= 4'b0011;
            3'd0 : sig_cbe_tar <= 4'b0001;
            default : sig_cbe_tar <= 4'b0000;
          endcase
        2'b01:
          case(t_hsize)
            3'd0 : sig_cbe_tar <= 4'b0010;
            default : sig_cbe_tar <= 4'b0000;
          endcase
        2'b10: 
          case(t_hsize)
            3'd1 : sig_cbe_tar <= 4'b1100;
            3'd0 : sig_cbe_tar <= 4'b0100;
            default : sig_cbe_tar <= 4'b0000;
          endcase   
        2'b11:
          case(t_hsize)
            3'd0 : sig_cbe_tar <= 4'b1000;
            default : sig_cbe_tar <= 4'b0000;
          endcase
      endcase


  `ifdef ADDR_NO_INC
  // address to local bus for write/read
  always @(posedge clk_ahb or negedge rstahb_n)
    if(!rstahb_n)
      var_aout <= 32'b0;
    `ifdef SOFT_RST
    else if(soft_reset)
      var_aout <= 32'b0;
    `endif
    else if (t_hsel & t_hready_in )
      var_aout <= t_haddr;  
    `endif
///////////////////////////////////////////////////////////////////////////////////

`ifdef ADDR_NO_INC
wire start_burst = (t_htrans==2'b10) && ( (t_hburst != 3'b001) || (t_hburst != 3'b000));
`endif
`ifdef ADDR_NO_INC
wire burst_valid = ( (t_hburst != 3'b001) || (t_hburst != 3'b000)) &&  ((t_htrans != 2'b00) || ( t_htrans != 2'b01));
`endif

  `ifdef ADDR_NO_INC
  always @(posedge clk_ahb or negedge rstahb_n)
    if(!rstahb_n)
	fixed_aout<='h0;
    `ifdef SOFT_RST
    else if(soft_reset)
	fixed_aout<='h0;
    `endif
    else if (start_burst && t_hsel && t_hready_in)
	fixed_aout <= t_haddr;
    `endif
	    
 // `ifdef ADDR_NO_INC
//  assign lb_aout = (lb_burst_addr_incr)?var_aout:((burst_valid)?fixed_aout:var_aout);
//  `else
  // address to local bus for write/read
  always @(posedge clk_ahb or negedge rstahb_n)
    if(!rstahb_n)
      lb_aout <= 32'b0;
    `ifdef SOFT_RST
    else if(soft_reset)
      lb_aout <= 32'b0;
    `endif
    else if (t_hsel & t_hready_in )
      lb_aout <= t_haddr;  
    //`endif

endmodule
