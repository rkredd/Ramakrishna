/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_ahb_mux_mod.v
// Author      : SANDEEPA S M
// Version     : v1p2
// Abstract    : This model acts as write/read control signals mux and 
//               write/read data signals mux
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`timescale 1 ps / 1 ps

module csi2tx_ahb_mux_mod
    (
      //INPUTS SIGNALS
      input                        hclk                                        , // ALL SIGNAL TIMINGS ARE RELATED TO THE RISING EDGE OF HCLK
      input                        hresetn                                     , // AHB ACTIVE LOW RESET
      input                        hwrite1                                     , // WRITE ENABLE SIGNAL FROM THE BUS MASTER 1
      input          [1:0]         htrans1                                     , // TRANSATION TYPE FROM THE BUS MASTER 1
      input          [31:0]        haddr1                                      , // WRITE OR READ ADDRESS FROM THE BUS MASTER 1
      input          [31:0]        hwdata1                                     , // WRITE DATA FROM THE BUS MASTER 1
      input          [2:0]         hsize1                                      , // TRANSFER SIZE FROM THE BUS MASTER 1
      input          [2:0]         hburst1                                     , // TRANSACTION BURST SIZE FROM THE BUS MASTER 1
      input                        hgrant2                                     , // BUS MASTER 2 GRANT ENABLE SIGNAL FROM THE ARBITER
      input                        hwrite2                                     , // WRITE ENABLE SIGNAL FROM THE BUS MASTER 2
      input          [1:0]         htrans2                                     , // TRANSFER TYPE FROM THE BUS MASTER 2
      input          [31:0]        haddr2                                      , // WRITE OR READ ADDRESS FROM THE BUS MASTER 2
      input          [31:0]        hwdata2                                     , // WRITE DATA FROM THE BUS MASTER 2
      input          [2:0]         hsize2                                      , // TRANSFER SIZE FROM THE BUS MASTER 2
      input          [2:0]         hburst2                                     , // TRANSACTION BURST SIZE FROM THE BUS MASTER 2
      input                        hready1                                     , // HIGH INDICATES THE TRANSFER FINISHED ON THE BUS MASTER 1
      input          [1:0]         hresp1                                      , // STATUS INFORMATION FROM THE BUS MASTER 1
      input          [31:0]        hrdata1                                     , // READ DATA FROM THE SLAVE 1
      input                        hready2                                     , // HIGH INDICATES THE TRANSFER FINISHED ON THE BUS MASTER 2
      input          [1:0]         hresp2                                      , // STATUS INFORMATION FROM THE BUS MASTER 2
      input          [31:0]        hrdata2                                     , // READ DATA FROM THE SLAVE 2
      input                        hready3                                     , // HIGH INDICATES THE TRANSFER FINISHED ON THE BUS MASTER 3
      input          [1:0]         hresp3                                      , // STATUS INFORMATION FROM THE SLAVE 3
      input          [31:0]        hrdata3                                     , // READ DATA FROM THE SLAVE 3
      input                        hsel1                                       , // SLAVE 1 SELECT SIGNAL FROM DECODER
      input                        hsel2                                       , // SLAVE 2 SELECT SIGNAL FROM DECODER
      input          [3:0]         hmaster                                     , // MASTER SELECT SIGNAL FROM THE ARBITER

      //OUTPUTS SIGNALS
      output                       hwrite                                      , // WRITE ENABLE SIGNAL FROM THE SELECTED BUS MASTER
      output         [1:0]         htrans                                      , // TRANSACTION TYPE INFORMATION FROM THE SELECTED BUS MASTER
      output         [31:0]        haddr                                       , // READ OR WRITE ENABLE SIGNAL FROM THE SELECTED BUS MASTER
      output         [31:0]        hwdata                                      , // WRITE DATA FROM THE SELECTED BUS MASTER
      output         [2:0]         hsize                                       , // TRANSFER SIZE DEFINED BY THE SELECTED BUS MASTER
      output         [2:0]         hburst                                      , // BURST SIZE DEFINED BY THE SELECTED BUS MASTER
      output                       hready                                      , // TRANSFER STATUS SIGNAL OF THE SELECTED SLAVE
      output         [1:0]         hresp                                       , // STATUS INFORMATION FROM THE SELECTED SLAVE
      output         [31:0]        hrdata                                        // READ DATA FROM THE SELECTED SLAVE
    );
  
 //========================================================//
 //   Internal register signal declaration
 //========================================================//
      
      reg                          sig_hsel1                                   ;
      reg                          sig_hgrant2                                 ;
      reg                          sig_hsel2                                   ;
      reg            [3:0]         sig_hmaster                                 ;
 //========================================================//
 //   Process to delay the hsel1 signal
 //========================================================//

    always @(posedge hclk or negedge hresetn)
      begin
        if (!hresetn)
          sig_hsel1 <= 1'b0;
        else
          sig_hsel1 <= hsel1;
      end
 //========================================================//
 //   Process to delay the hsel2 signal
 //========================================================//  

    always @(posedge hclk or negedge hresetn)
      begin
        if (!hresetn)
          sig_hsel2 <= 1'b0;
        else
          sig_hsel2 <= hsel2;
      end
 //========================================================//
 //   Process to delay the hgrant2 signal
 //========================================================// 

    always @(posedge hclk or negedge hresetn)
      begin
        if (!hresetn)
          sig_hgrant2 <= 1'b0;
        else
          sig_hgrant2 <= hgrant2;
      end
 //========================================================//
 //   Process to delay the hmaster signal
 //========================================================//  

    always @(posedge hclk or negedge hresetn)
      begin
        if (!hresetn)
          sig_hmaster <= 4'b0000;
        else
          sig_hmaster <= hmaster;
      end
 //========================================================//
 //   Concurrent assignments
 //========================================================//  
  
    assign hwrite = (hmaster == 4'b0010 ) ? hwrite2 : hwrite1;
    
    assign htrans = (hmaster == 4'b0010 ) ? htrans2 : htrans1;
    
    assign haddr  = (hmaster == 4'b0010 ) ? haddr2 : haddr1;
    
    assign hwdata = (sig_hmaster == 4'b0010) ? hwdata2 : hwdata1;
    
    assign hsize  = (hmaster == 4'b0010 ) ? hsize2 : hsize1;
    
    assign hburst = (hmaster == 4'b0010 ) ? hburst2 : hburst1;
    
    assign hready = (hsel1 == 1'b1) ? hready1 : ( hsel2 == 1'b1) ? hready2 : hready3;
    
    assign hresp  = (hsel1 == 1'b1) ? hresp1 : (hsel2 == 1'b1) ? hresp2 : hresp3;
    
    assign hrdata = (sig_hsel1 == 1'b1) ? hrdata1 : (sig_hsel2 == 1'b1) ? hrdata2 : hrdata3;
  
endmodule
