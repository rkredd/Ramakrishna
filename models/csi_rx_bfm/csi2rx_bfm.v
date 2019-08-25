/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2rx_bfm.v
// Author      : CSI TEAM
// Version     : v1p2
// Abstract    : This model packs the received byte data from tx bfm into pixels 
//               for the corresponding data types and send it to scoreboard
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
  `timescale 1 ps / 1 ps
 module csi2rx_bfm
  (
    // input signals
    input wire           byteclkhs                     , // clock singal
    input wire           byteclkhs_rst_n               , // Reset signal
    input wire [7:0]     rxdphy_rxbfm_validhs          , // Valid signal indicating No: of valid bytes
    input wire [63:0]    rxdphy_rxbfm_datahs           , // Byte data input
    input wire [2:0]     ahb_rxbfm_lane_cnt            , // No: of Lanes configured
    input wire [2:0]     ahb_rxbfm_pixel_mode          , // Pixel Mode cofigured 

    // output signals
    output reg  [31:0]   rxbfm_mon_pixeldata           , // converted pixel data
    output reg           rxbfm_mon_pixelen             , // pixel enable for pixel data comparision
    output reg  [31:0]   rxbfm_mon_headerdata          , // Header data for Sh & Lng packets
    output reg           rxbfm_mon_headeren            , // Header en for Header data comparision
    output      [11:0]   rxbfm_comp_data               , // Compression pixel Data
    output               rxbfm_comp_en                 , // Compression pixel enable
    output reg           error_rxbfm                   , // Error signal              
    output reg           end_rxbfm                        // Indicates End of rxbfm

  );

  /*----------------------------------------------------------------------------
    Internal register signal declaration
  ----------------------------------------------------------------------------*/

   reg      [31:0]           scorbd_headr_mem [0:15]        ;
   reg      [31:0]           scorbd_pix_mem   [0:65535]     ;
   reg      [7:0]            byte_mem       [0:15]          ;
   reg      [3:0]            scorbd_headr_wr_cnt            ;
   reg      [3:0]            scorbd_headr_rd_cnt            ;
   reg      [15:0]           scorbd_pix_wr_cnt              ;
   reg      [15:0]           scorbd_pix_rd_cnt              ;
   reg      [3:0]            byte_mem_wr_cnt                ;
   reg      [3:0]            byte_mem_rd_cnt                ;
   reg      [5:0]            data_type                      ;
   reg      [15:0]           word_count                     ;
   reg      [15:0]           byte_counter                   ;
   reg      [31:0]           pkt_reg                        ;
   reg      [1:0]            byte_sel                       ;
   reg      [1:0]            vc_no                          ;
   reg      [7:0]            crc_data                       ;
   reg                       packet_en                      ;
   reg                       cntrl_packing                  ;
   reg                       packet_indi                    ;
   reg                       sh_lg_pac_en                   ;
   reg      [7:0]            reg1                           ;
   reg      [7:0]            reg2                           ;
   reg      [7:0]            reg3                           ;
   reg      [7:0]            reg4                           ;
   reg      [7:0]            reg5                           ;
   reg      [7:0]            reg6                           ;
   reg      [7:0]            reg7                           ;
   reg      [7:0]            reg8                           ;
   reg      [7:0]            reg9                           ;
   reg      [7:0]            reg10                          ;
   reg      [7:0]            rxdphy_rxbfm_validhs_d         ;
   reg                       resrvd_data_id_err             ;
   reg                       unsup_data_err                 ;
   reg                       less_not_mul_err               ;
   reg     [23:0]            ecc_data                       ;
   reg     [7:0]             ecc_parity_value               ;
   integer                   i                              ;
   integer                   i1                             ;
   integer                   j                              ;
   reg                       parity_0                       ;
   reg                       parity_1                       ;
   reg                       parity_2                       ;
   reg                       parity_3                       ;
   reg                       parity_4                       ;
   reg                       parity_5                       ;
   reg                       pkt_cmplt                      ;
   reg    [15:0]             p_crc                          ;                                          
   reg    [15:0]             x1                             ;                                          
   reg    [15:0]             n_crc                          ;     
   reg    [15:0]             temp_crc                       ;  
   reg    [2:0]              lan_index                      ;
   wire   [2:0]              lane_index                     ;
   reg                       lane_index_en                  ; 
   reg                       yuv_420_8_odd_even_line        ;
   reg                       yuv_420_10_odd_even_line       ;
   reg                      comp_en                        ;
   reg    [4:0]              comp_scheme                    ;
   reg    [15:0]             pixel_cnt                      ;
   reg    [7:0]              enc_data                       ;
   reg                       enc_data_vld                   ;
   reg                       comp_en_0                      ;
   reg                       comp_en_1                      ;
   reg                       comp_en_2                      ;
   reg                       comp_en_3                      ;
   reg    [4:0]              comp_schm_0_0                  ;
   reg    [4:0]              comp_schm_0_1                  ;
   reg    [4:0]              comp_schm_0_2                  ;
   reg    [4:0]              comp_schm_0_3                  ;
   reg    [4:0]              comp_schm_0_4                  ;
   reg    [4:0]              comp_schm_0_5                  ;
   reg    [4:0]              comp_schm_0_6                  ;
   reg    [4:0]              comp_schm_0_7                  ;
   reg    [4:0]              comp_schm_1_0                  ;
   reg    [4:0]              comp_schm_1_1                  ;
   reg    [4:0]              comp_schm_1_2                  ;
   reg    [4:0]              comp_schm_1_3                  ;
   reg    [4:0]              comp_schm_1_4                  ;
   reg    [4:0]              comp_schm_1_5                  ;
   reg    [4:0]              comp_schm_1_6                  ;
   reg    [4:0]              comp_schm_1_7                  ;
   reg    [4:0]              comp_schm_2_0                  ;
   reg    [4:0]              comp_schm_2_1                  ;
   reg    [4:0]              comp_schm_2_2                  ;
   reg    [4:0]              comp_schm_2_3                  ;
   reg    [4:0]              comp_schm_2_4                  ;
   reg    [4:0]              comp_schm_2_5                  ;
   reg    [4:0]              comp_schm_2_6                  ;
   reg    [4:0]              comp_schm_2_7                  ;
   reg    [4:0]              comp_schm_3_0                  ;
   reg    [4:0]              comp_schm_3_1                  ;
   reg    [4:0]              comp_schm_3_2                  ;
   reg    [4:0]              comp_schm_3_3                  ;
   reg    [4:0]              comp_schm_3_4                  ;
   reg    [4:0]              comp_schm_3_5                  ;
   reg    [4:0]              comp_schm_3_6                  ;
   reg    [4:0]              comp_schm_3_7                  ;

  `include "./csi_rx_bfm/csi2rx_bfm_defines.v"
  `include "csi_rx_cmd.v"


  //Initial Block
  initial 
   begin
    scorbd_pix_wr_cnt    = 0;
    scorbd_pix_rd_cnt    = 0;
    scorbd_headr_wr_cnt  = 0;
    scorbd_headr_rd_cnt  = 0;
    byte_mem_wr_cnt      = 0;
    byte_mem_rd_cnt      = 0;
    end_rxbfm            = 1'b0;
    byte_counter         = 16'h0;
    cntrl_packing        = 1'b0;
    parity_0             = 1'b0;
    parity_1             = 1'b0;
    parity_2             = 1'b0;
    parity_3             = 1'b0;
    parity_4             = 1'b0;
    parity_5             = 1'b0;
    p_crc                = 16'hffff;
    n_crc                = 16'd0;
    temp_crc             = 16'd0;
    resrvd_data_id_err   = 1'b0;
    less_not_mul_err     = 1'b0;
    j =0;
    i =0;
    i1 =0;
    rxbfm_mon_pixeldata =  31'h0;
    rxbfm_mon_pixelen   = 1'b0;
    rxbfm_mon_headerdata =  31'h0;
    rxbfm_mon_headeren   = 1'b0;
    pkt_cmplt = 1'b0;
    lane_index_en = 1'b0;
    comp_en_0 = 1'b0 ;
    comp_en_1 = 1'b0 ;
    comp_en_2 = 1'b0 ;
    comp_en_3 = 1'b0 ;
    yuv_420_8_odd_even_line =1'b1; //signifies first is odd line for yuv 420 8 bit
    yuv_420_10_odd_even_line =1'b1; //signifies first is odd line for yuv 420 10 bit
    csi_rx_cmd;
   end


csi2rx_decoder_bfm
     u_csi2rx_decoder_bfm 
     (
     .enc_data_ip         (enc_data            ),
     .enc_data_vld        (enc_data_vld        ),
     .num_pxls_per_line   (pixel_cnt           ),
     .dec_data_op         (rxbfm_comp_data     ),
     .dec_data_vld        (rxbfm_comp_en       ),
     .config_reg          (comp_scheme         )
     );


   /*----------------------------------------------------------------------------
    Selects between 
      lane index configured through command line 
                  (or)
      lane index forced through testcase
  -----------------------------------------------------------------------------*/

  assign lane_index =  ahb_rxbfm_lane_cnt; 

 

  /*----------------------------------------------------------------------------
   This always block is to delay the valid valid signal
   so as to detect the edege  
  -----------------------------------------------------------------------------*/
  always@(posedge byteclkhs or negedge byteclkhs_rst_n) 
    begin
      if(!byteclkhs_rst_n) 
        rxdphy_rxbfm_validhs_d <=  8'h0;
      else 
        rxdphy_rxbfm_validhs_d <= rxdphy_rxbfm_validhs;
    end

  /*-----------------------------------------------------------------------------
   This always block is to detect the Packet type & Store the Short packeets {FS,LS,LE,FE},
   Generic Short packet,
   It enables the corresponding Byte to Pixel Task for pixel data conversion. 
  -----------------------------------------------------------------------------*/  

  always @( posedge byteclkhs or negedge byteclkhs_rst_n) begin
   if(!byteclkhs_rst_n) begin
     data_type  = 6'h0;
     vc_no      = 6'h0;
     word_count = 16'h0;
     pkt_reg    = 32'h0; 
     packet_en  = 1'b0;
     byte_sel   = 2'b00;
     packet_indi =1'b0;
     sh_lg_pac_en = 1'b0;
     unsup_data_err = 1'b0;
     error_rxbfm  = 1'b0;
     ecc_data  = 24'h0;
     ecc_parity_value = 8'h0;
   end else begin
    if(((rxdphy_rxbfm_validhs_d[0] == 1'b0) && (rxdphy_rxbfm_validhs[0] == 1'b1) ) || packet_en) begin //1
      sh_lg_pac_en   = 1'b0;
      less_not_mul_err  = 1'b0;
      unsup_data_err = 1'b0;
      resrvd_data_id_err =1'b0;
     for(i1=0; i1<=lane_index; i1=i1+1) begin 

       if(rxdphy_rxbfm_validhs[i1] == 1'b1) begin
       /*----------------------------------------------------------------------
        This if is to check wether it is long/Short packet.
        And if it's long pkt the value of the signal(sh_ln_pac_en) will be 1.
       ----------------------------------------------------------------------*/
        if(sh_lg_pac_en == 1'b0)begin 
         packet_en =1'b1;                                                      
         case (byte_sel)
          2'b00 : begin 
                  pkt_reg[7:0] =  rxdphy_rxbfm_datahs[(8*i1) +: 8]; 
                  byte_sel = byte_sel +1'b1;
                  end              
          2'b01 : begin 
                  pkt_reg[15:8] =  rxdphy_rxbfm_datahs[(8*i1) +: 8]; 
                  byte_sel = byte_sel +1'b1;
                  end    
          2'b10 : begin 
                  pkt_reg[23:16] =  rxdphy_rxbfm_datahs[(8*i1) +: 8]; 
                  byte_sel = byte_sel +1'b1;
                  end    
          2'b11 : begin 
                  pkt_reg[31:24] =  rxdphy_rxbfm_datahs[(8*i1) +: 8]; 
                  packet_en =1'b0;                                                      
                  packet_indi =1'b1;
                  byte_sel = 2'b00;
                  sh_lg_pac_en = 1'b1;
                  end  
          default:pkt_reg =  32'h0; 
         endcase
        end //(sh_lg_pac_en)
       end //(valid[i])
     end // for loop
    end //1
    
    if(packet_indi == 1'b1) begin

     //For Short packet 
     if((pkt_reg[5:0] == `FRAME_START) || (pkt_reg[5:0] == `LINE_START) ||
        (pkt_reg[5:0] == `LINE_END)    || (pkt_reg[5:0] == `FRAME_END)) begin
        
         ecc_data = pkt_reg[23:0];
         ecc_computation(ecc_data); // for calculating the ecc 

         if(pkt_reg[31:24] == ecc_parity_value)begin
          scorbd_headr_mem[scorbd_headr_wr_cnt] = {8'b0,pkt_reg[23:0]}; // Excluding ECC
          scorbd_headr_wr_cnt           = scorbd_headr_wr_cnt + 1'b1;

          if(pkt_reg[5:0] == `FRAME_START)begin
          $display($time,"\tCSI2 RX BFM : FRAME START FOR FRAME NO : %d with VIRTUAL CHANNEL NO: %d is RECEIVED SUCCESSFULLY \n",pkt_reg[23:8],pkt_reg[7:6]);
          yuv_420_8_odd_even_line =1'b1;//odd Line
          yuv_420_10_odd_even_line =1'b1;//odd Line
          end
          if(pkt_reg[5:0] == `LINE_START)begin
          $display($time,"\tCSI2 RX BFM : LINE START FOR LINE NO : %d with VIRTUAL CHANNEL NO: %d is RECEIVED SUCCESSFULLY \n",pkt_reg[23:8],pkt_reg[7:6]);
          end
          if(pkt_reg[5:0] == `LINE_END)begin
          $display($time,"\tCSI2 RX BFM : LINE END FOR LINE NO : %d with VIRTUAL CHANNEL NO: %d is RECEIVED SUCCESSFULLY \n",pkt_reg[23:8],pkt_reg[7:6]);
          end
          if(pkt_reg[5:0] == `FRAME_END)begin
          $display($time,"\tCSI2 RX BFM : FRAME END FOR FRAME NO : %d with VIRTUAL CHANNEL NO: %d is RECEIVED SUCCESSFULLY \n",pkt_reg[23:8],pkt_reg[7:6]);
          end
          packet_indi =1'b0;
          sh_lg_pac_en = 1'b0;

         end else begin 
          $display($time,"\tERROR-CSI2 RX BFM : ECC MISMATCH OCCURED IN SHORT PACKET HEADER DATA \n");
          error_rxbfm  = 1'b1;
         end

     //For Generic Short Packet
     end else if((pkt_reg[5:0] == `GEN_SH_PKT1) ||(pkt_reg[5:0] == `GEN_SH_PKT2) || 
         (pkt_reg[5:0] == `GEN_SH_PKT3) ||(pkt_reg[5:0] == `GEN_SH_PKT4) ||
         (pkt_reg[5:0] == `GEN_SH_PKT5) ||(pkt_reg[5:0] == `GEN_SH_PKT6) ||
         (pkt_reg[5:0] == `GEN_SH_PKT7) ||(pkt_reg[5:0] == `GEN_SH_PKT8)) begin

          scorbd_headr_mem[scorbd_headr_wr_cnt] = {8'b0,pkt_reg[23:0]};  
          scorbd_headr_wr_cnt           = scorbd_headr_wr_cnt + 1'b1;
          packet_indi =1'b0;
      
     // For Unsupported Data -Id in the Packet Header
   /*  end else if((pkt_reg[5:0] == 6'h20)|| (pkt_reg[5:0] == 6'h21)|| (pkt_reg[5:0] == 6'h22)|| 
         (pkt_reg[5:0] == 6'h23)|| (pkt_reg[5:0] == 6'h24)|| (pkt_reg[5:0] == 6'h28)||
         (pkt_reg[5:0] == 6'h29)|| (pkt_reg[5:0] == 6'h18)|| (pkt_reg[5:0] == 6'h19)||
         (pkt_reg[5:0] == 6'h1a)|| (pkt_reg[5:0] == 6'h1c)|| (pkt_reg[5:0] == 6'h1d))begin
          packet_en =1'b0;
          unsup_data_err = 1'b1;
          error_rxbfm  = 1'b1;
          packet_indi =1'b0;  
          $display($time,"\tCSI2 RX BFM : ERROR - UNSUPPORTED DATA TYPE %h HAS BEEN RECEIVED\n",pkt_reg[5:0]);   */


     // For Reserverd Data -Id in the Packet Header
     end else if(((pkt_reg[5:0] >= 6'h04) && (pkt_reg[5:0] <= 6'h07)) ||
         ((pkt_reg[5:0] >= 6'h13) && (pkt_reg[5:0] <= 6'h17)) ||
         (pkt_reg[5:0]  == 6'h1B) ||
         ((pkt_reg[5:0] >= 6'h25) && (pkt_reg[5:0] <= 6'h27)) ||
         ((pkt_reg[5:0] >= 6'h2E) && (pkt_reg[5:0] <= 6'h2F)) ||
         ((pkt_reg[5:0] >= 6'h38) && (pkt_reg[5:0] <= 6'h3F)))begin

          packet_en =1'b0;
          error_rxbfm  = 1'b1;
          resrvd_data_id_err = 1'b1;
          packet_indi =1'b0;  
          $display($time,"\tERROR-CSI2 RX BFM : ERROR - RESERVED DATA TYPE %h HAS BEEN RECEIVED\n",pkt_reg[5:0]);   

     end else begin //---->
          data_type  = pkt_reg[5:0];
          vc_no      = pkt_reg[1:0];
          word_count = pkt_reg[23:8];

       //This if is to just enable the compression enabble if its valid or else it will assign zero. 
       if( (data_type == `USD_TYPE1) || (data_type == `USD_TYPE2)     ||
           (data_type == `USD_TYPE3) || (data_type == `USD_TYPE4)     ||
           (data_type == `USD_TYPE5) || (data_type == `USD_TYPE6)     ||
           (data_type == `USD_TYPE7) || (data_type == `USD_TYPE8)   )
        begin
         comp_en= (comp_en_0 || comp_en_1 || comp_en_2 || comp_en_3);
        end else begin
         comp_en= 1'b0;
        end

          ecc_data = pkt_reg[23:0];
          ecc_computation(ecc_data); // for calculating the ecc 

          if(pkt_reg[31:24] == ecc_parity_value)begin
           packet_size_error_detection;

           if(less_not_mul_err == 1'b0)begin // If There is no Error in the Packet Header then only it will
                                     // go for byte to pixel conversion. 

            scorbd_headr_mem[scorbd_headr_wr_cnt] = {8'b0,pkt_reg[23:0]}; // Excluding ECC
            scorbd_headr_wr_cnt           = scorbd_headr_wr_cnt + 1'b1;

            if(((data_type == `RAW8)     || (data_type == `NULL_PKT)      ||
               (data_type == `BLK_DATA)  || (data_type == `EMBEDDED_DATA) ||
               (data_type == `USD_TYPE1) || (data_type == `USD_TYPE2)     ||
               (data_type == `USD_TYPE3) || (data_type == `USD_TYPE4)     ||
               (data_type == `USD_TYPE5) || (data_type == `USD_TYPE6)     ||
               (data_type == `USD_TYPE7) || (data_type == `USD_TYPE8)   ) && (comp_en == 1'b0) )begin    
               byte_pix_raw8_all_usd(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
            else if(( (data_type == `USD_TYPE1) || (data_type == `USD_TYPE2)     ||
                     (data_type == `USD_TYPE3) || (data_type == `USD_TYPE4)     ||
                     (data_type == `USD_TYPE5) || (data_type == `USD_TYPE6)     ||
                     (data_type == `USD_TYPE7) || (data_type == `USD_TYPE8)   ) && (comp_en == 1'b1) )begin  

               if( (pkt_reg[7:6] == 2'b00) && comp_en_0 ==1'b1)begin // "0"

                    if((data_type == `USD_TYPE1) && (comp_schm_0_0 != 5'h0))begin
                       comp_scheme = comp_schm_0_0;
                    end else if((data_type == `USD_TYPE2) && (comp_schm_0_1 != 5'h0))begin
                       comp_scheme = comp_schm_0_1;
                    end else if((data_type == `USD_TYPE3) && (comp_schm_0_2 != 5'h0))begin
                       comp_scheme = comp_schm_0_2;
                    end else if((data_type == `USD_TYPE4) && (comp_schm_0_3 != 5'h0))begin
                       comp_scheme = comp_schm_0_3;
                    end else if((data_type == `USD_TYPE5) && (comp_schm_0_4 != 5'h0))begin
                       comp_scheme = comp_schm_0_4;
                    end else if((data_type == `USD_TYPE6) && (comp_schm_0_5 != 5'h0))begin
                       comp_scheme = comp_schm_0_5;
                    end else if((data_type == `USD_TYPE7) && (comp_schm_0_6 != 5'h0))begin
                       comp_scheme = comp_schm_0_6;
                    end else if((data_type == `USD_TYPE8) && (comp_schm_0_7 != 5'h0))begin
                       comp_scheme = comp_schm_0_7;
                    end

                 if( (comp_scheme[2:0] == `C_10_6_10) || (comp_scheme[2:0] == `C_12_6_12))begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/6); 
                   byte_pix_raw6(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
                else if((comp_scheme[2:0] == `C_10_7_10) || (comp_scheme[2:0] == `C_12_7_12) )begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/7); 
                   byte_pix_raw7(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
                else if((comp_scheme[2:0] == `C_10_8_10)|| (comp_scheme[2:0] == `C_12_8_12) )begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/8); 
                   byte_pix_raw8_all_usd(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
               end // "0"
               else if( (pkt_reg[7:6] == 2'b01) && comp_en_1 ==1'b1)begin // "1"



                    if((data_type == `USD_TYPE1) && (comp_schm_1_0 != 5'h0))begin
                       comp_scheme = comp_schm_1_0;
                    end else if((data_type == `USD_TYPE2) && (comp_schm_1_1 != 5'h0))begin
                       comp_scheme = comp_schm_1_1;
                    end else if((data_type == `USD_TYPE3) && (comp_schm_1_2 != 5'h0))begin
                       comp_scheme = comp_schm_1_2;
                    end else if((data_type == `USD_TYPE4) && (comp_schm_1_3 != 5'h0))begin
                       comp_scheme = comp_schm_1_3;
                    end else if((data_type == `USD_TYPE5) && (comp_schm_1_4 != 5'h0))begin
                       comp_scheme = comp_schm_1_4;
                    end else if((data_type == `USD_TYPE6) && (comp_schm_1_5 != 5'h0))begin
                       comp_scheme = comp_schm_1_5;
                    end else if((data_type == `USD_TYPE7) && (comp_schm_1_6 != 5'h0))begin
                       comp_scheme = comp_schm_1_6;
                    end else if((data_type == `USD_TYPE8) && (comp_schm_1_7 != 5'h0))begin
                       comp_scheme = comp_schm_1_7;
                    end


                 if( (comp_scheme[2:0] == `C_10_6_10) || (comp_scheme[2:0] == `C_12_6_12))begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/6); 
                   byte_pix_raw6(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
                else if((comp_scheme[2:0] == `C_10_7_10) || (comp_scheme[2:0] == `C_12_7_12) )begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/7); 
                   byte_pix_raw7(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
                else if((comp_scheme[2:0] == `C_10_8_10)|| (comp_scheme[2:0] == `C_12_8_12) )begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/8); 
                   byte_pix_raw8_all_usd(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
               end // "1"
               else if( (pkt_reg[7:6] == 2'b10) && comp_en_2 ==1'b1)begin // "2"


                    if((data_type == `USD_TYPE1) && (comp_schm_2_0 != 5'h0))begin
                       comp_scheme = comp_schm_2_0;
                    end else if((data_type == `USD_TYPE2) && (comp_schm_2_1 != 5'h0))begin
                       comp_scheme = comp_schm_2_1;
                    end else if((data_type == `USD_TYPE3) && (comp_schm_2_2 != 5'h0))begin
                       comp_scheme = comp_schm_2_2;
                    end else if((data_type == `USD_TYPE4) && (comp_schm_2_3 != 5'h0))begin
                       comp_scheme = comp_schm_2_3;
                    end else if((data_type == `USD_TYPE5) && (comp_schm_2_4 != 5'h0))begin
                       comp_scheme = comp_schm_2_4;
                    end else if((data_type == `USD_TYPE6) && (comp_schm_2_5 != 5'h0))begin
                       comp_scheme = comp_schm_2_5;
                    end else if((data_type == `USD_TYPE7) && (comp_schm_2_6 != 5'h0))begin
                       comp_scheme = comp_schm_2_6;
                    end else if((data_type == `USD_TYPE8) && (comp_schm_2_7 != 5'h0))begin
                       comp_scheme = comp_schm_2_7;
                    end



                 if( (comp_scheme[2:0] == `C_10_6_10) || (comp_scheme[2:0] == `C_12_6_12))begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/6); 
                   byte_pix_raw6(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
                else if((comp_scheme[2:0] == `C_10_7_10) || (comp_scheme[2:0] == `C_12_7_12) )begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/7); 
                   byte_pix_raw7(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
                else if((comp_scheme[2:0] == `C_10_8_10)|| (comp_scheme[2:0] == `C_12_8_12) )begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/8); 
                   byte_pix_raw8_all_usd(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
               end // "2"
               else if( (pkt_reg[7:6] == 2'b11) && comp_en_3 ==1'b1)begin // "3"


                    if((data_type == `USD_TYPE1) && (comp_schm_3_0 != 5'h0))begin
                       comp_scheme = comp_schm_3_0;
                    end else if((data_type == `USD_TYPE2) && (comp_schm_3_1 != 5'h0))begin
                       comp_scheme = comp_schm_3_1;
                    end else if((data_type == `USD_TYPE3) && (comp_schm_3_2 != 5'h0))begin
                       comp_scheme = comp_schm_3_2;
                    end else if((data_type == `USD_TYPE4) && (comp_schm_3_3 != 5'h0))begin
                       comp_scheme = comp_schm_3_3;
                    end else if((data_type == `USD_TYPE5) && (comp_schm_3_4 != 5'h0))begin
                       comp_scheme = comp_schm_3_4;
                    end else if((data_type == `USD_TYPE6) && (comp_schm_3_5 != 5'h0))begin
                       comp_scheme = comp_schm_3_5;
                    end else if((data_type == `USD_TYPE7) && (comp_schm_3_6 != 5'h0))begin
                       comp_scheme = comp_schm_3_6;
                    end else if((data_type == `USD_TYPE8) && (comp_schm_3_7 != 5'h0))begin
                       comp_scheme = comp_schm_3_7;
                    end


                 if( (comp_scheme[2:0] == `C_10_6_10) || (comp_scheme[2:0] == `C_12_6_12))begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/6); 
                   byte_pix_raw6(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
                else if((comp_scheme[2:0] == `C_10_7_10) || (comp_scheme[2:0] == `C_12_7_12) )begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/7); 
                   byte_pix_raw7(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
                else if((comp_scheme[2:0] == `C_10_8_10)|| (comp_scheme[2:0] == `C_12_8_12) )begin
                   x1 = pkt_reg[23:8];
                   pixel_cnt = ((x1*8)/8); 
                   byte_pix_raw8_all_usd(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
                   cntrl_packing = 1'b0;
                   sh_lg_pac_en = 1'b0;
                   pkt_cmplt = 1'b0;
                end
               end // "3"
            end
           else if(data_type == `RAW10 )begin    
               byte_pix_raw10(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if(data_type == `RAW12 )begin    
               byte_pix_raw12(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if(data_type == `RAW14 )begin    
               byte_pix_raw14(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if(data_type == `YUV422_8B )begin   
               byte_pix_yuv_422_8bit(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if(data_type == `YUV422_10B )begin    
               byte_pix_yuv_422_10bit(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if((data_type == `YUV420_8B) || (data_type == `YUV420_8B_CSPS))begin    
               byte_pix_yuv_420_8bit(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               yuv_420_8_odd_even_line = ~yuv_420_8_odd_even_line;
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if((data_type == `YUV420_10B) || (data_type == `YUV420_10B_CSPS))begin    
               byte_pix_yuv_420_10bit(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               yuv_420_10_odd_even_line = ~yuv_420_10_odd_even_line;
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if((data_type == `LYUV420_8B))begin    
               byte_pix_lyuv_420_8bit(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if((data_type == `RGB444) || (data_type == `RGB555) || (data_type ==`RGB565))begin    
               byte_pix_rgb_444_555_565(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if(data_type == `RGB666 )begin    
               byte_pix_rgb_666(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if(data_type == `RGB888 )begin    
               byte_pix_rgb_888(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if(data_type == `RAW7 )begin    
               byte_pix_raw7(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           else if(data_type == `RAW6 )begin    
               byte_pix_raw6(pkt_reg[23:8],lane_index); // Task for Converting byte-to-pixel 
               cntrl_packing = 1'b0;
               sh_lg_pac_en = 1'b0;
               pkt_cmplt = 1'b0;
            end
           end
          end else begin
          $display($time,"\tERROR-CSI2 RX BFM : ECC MISMATCH OCCURED IN LONG PACKET HEADER DATA \n");
          error_rxbfm  = 1'b1;
         end

     end // ---->
    end // (packet_indi)
   end // reset else
  end //always



  // This always block is for Generating the read enable for the pixel data 
  // so as to compare the pixel data.
  always@(posedge byteclkhs) begin
    if(!byteclkhs_rst_n) begin
      rxbfm_mon_pixeldata =  31'h0;
      rxbfm_mon_pixelen   = 1'b0;
      enc_data_vld = 1'b0;
      scorbd_pix_rd_cnt   = 13'b0;
    end else begin

     while (scorbd_pix_rd_cnt !== scorbd_pix_wr_cnt ) begin
            if(comp_en == 1'b0)begin
            rxbfm_mon_pixeldata = scorbd_pix_mem[scorbd_pix_rd_cnt];
            rxbfm_mon_pixelen = 1'b1;
            scorbd_pix_rd_cnt  = scorbd_pix_rd_cnt + 1'b1;
            end
            else if(comp_en == 1'b1)begin
            enc_data = scorbd_pix_mem[scorbd_pix_rd_cnt][7:0];
            enc_data_vld = 1'b1;
            scorbd_pix_rd_cnt  = scorbd_pix_rd_cnt + 1'b1;
            end
            #0.5;
            rxbfm_mon_pixeldata = 31'h0;
            enc_data_vld = 1'b0;
            enc_data = 7'b0;
            rxbfm_mon_pixelen = 1'b0;
            #0.5;
           end
         end
       end
  
  // This always block is for Generating the read enable for the Header data 
  // so as to compare the Header data.
  always@(posedge byteclkhs) begin
    if(!byteclkhs_rst_n) begin
      rxbfm_mon_headerdata =  31'h0;
      rxbfm_mon_headeren   = 1'b0;
      scorbd_headr_rd_cnt   = 13'b0;
    end else begin

     while (scorbd_headr_wr_cnt !== scorbd_headr_rd_cnt ) begin
            rxbfm_mon_headerdata = scorbd_headr_mem[scorbd_headr_rd_cnt];
            rxbfm_mon_headeren = 1'b1;
            scorbd_headr_rd_cnt  = scorbd_headr_rd_cnt + 1'b1;
            #0.5;
            rxbfm_mon_headerdata = 31'h0;
            rxbfm_mon_headeren = 1'b0;
            #0.5;
           end
         end
       end



  // This always block is for Generating the End of rxbfm
  always@(*)
    begin
      if((scorbd_pix_wr_cnt == scorbd_pix_rd_cnt) && (scorbd_headr_wr_cnt == scorbd_headr_rd_cnt ) )
        begin
        if(rxdphy_rxbfm_validhs != 8'b0)
         wait(rxdphy_rxbfm_validhs == 8'h0);
         end_rxbfm = 1;
        end
      else
         end_rxbfm = 0;  
    end


  /*------------------------------------------------------------------------------------
    Task asserts the compression scheme corresponding to Virtual channel-0 & an enable
  ------------------------------------------------------------------------------------*/

  task vc0_compression;
   input  en_vc0;
   input [4:0] comp_schm_vc0_7;
   input [4:0] comp_schm_vc0_6;
   input [4:0] comp_schm_vc0_5;
   input [4:0] comp_schm_vc0_4;
   input [4:0] comp_schm_vc0_3;
   input [4:0] comp_schm_vc0_2;
   input [4:0] comp_schm_vc0_1;
   input [4:0] comp_schm_vc0_0;
    begin
     comp_en_0 = en_vc0;
     comp_schm_0_7 = comp_schm_vc0_7;    
     comp_schm_0_6 = comp_schm_vc0_6;
     comp_schm_0_5 = comp_schm_vc0_5;
     comp_schm_0_4 = comp_schm_vc0_4;
     comp_schm_0_3 = comp_schm_vc0_3;
     comp_schm_0_2 = comp_schm_vc0_2;
     comp_schm_0_1 = comp_schm_vc0_1;
     comp_schm_0_0 = comp_schm_vc0_0;
    end
  endtask
  /*------------------------------------------------------------------------------------
    Task asserts the compression scheme corresponding to Virtual channel-1 & an enable
  ------------------------------------------------------------------------------------*/

  task vc1_compression;
   input  en_vc1;
   input [4:0] comp_schm_vc1_7;
   input [4:0] comp_schm_vc1_6;
   input [4:0] comp_schm_vc1_5;
   input [4:0] comp_schm_vc1_4;
   input [4:0] comp_schm_vc1_3;
   input [4:0] comp_schm_vc1_2;
   input [4:0] comp_schm_vc1_1;
   input [4:0] comp_schm_vc1_0;
    begin
     comp_en_1 = en_vc1;
     comp_schm_1_7 = comp_schm_vc1_7;    
     comp_schm_1_6 = comp_schm_vc1_6;
     comp_schm_1_5 = comp_schm_vc1_5;
     comp_schm_1_4 = comp_schm_vc1_4;
     comp_schm_1_3 = comp_schm_vc1_3;
     comp_schm_1_2 = comp_schm_vc1_2;
     comp_schm_1_1 = comp_schm_vc1_1;
     comp_schm_1_0 = comp_schm_vc1_0;
    end
  endtask
  /*------------------------------------------------------------------------------------
    Task asserts the compression scheme corresponding to Virtual channel-2 & an enable
  ------------------------------------------------------------------------------------*/

  task vc2_compression;
   input  en_vc2;
   input [4:0] comp_schm_vc2_7;
   input [4:0] comp_schm_vc2_6;
   input [4:0] comp_schm_vc2_5;
   input [4:0] comp_schm_vc2_4;
   input [4:0] comp_schm_vc2_3;
   input [4:0] comp_schm_vc2_2;
   input [4:0] comp_schm_vc2_1;
   input [4:0] comp_schm_vc2_0;
    begin
     comp_en_2 = en_vc2;
     comp_schm_2_7 = comp_schm_vc2_7;    
     comp_schm_2_6 = comp_schm_vc2_6;
     comp_schm_2_5 = comp_schm_vc2_5;
     comp_schm_2_4 = comp_schm_vc2_4;
     comp_schm_2_3 = comp_schm_vc2_3;
     comp_schm_2_2 = comp_schm_vc2_2;
     comp_schm_2_1 = comp_schm_vc2_1;
     comp_schm_2_0 = comp_schm_vc2_0;
    end
  endtask
  /*------------------------------------------------------------------------------------
    Task asserts the compression scheme corresponding to Virtual channel-3 & an enable
  ------------------------------------------------------------------------------------*/

  task vc3_compression;
   input  en_vc3;
   input [4:0] comp_schm_vc3_7;
   input [4:0] comp_schm_vc3_6;
   input [4:0] comp_schm_vc3_5;
   input [4:0] comp_schm_vc3_4;
   input [4:0] comp_schm_vc3_3;
   input [4:0] comp_schm_vc3_2;
   input [4:0] comp_schm_vc3_1;
   input [4:0] comp_schm_vc3_0;
    begin
     comp_en_3 = en_vc3;
     comp_schm_3_7 = comp_schm_vc3_7;    
     comp_schm_3_6 = comp_schm_vc3_6;
     comp_schm_3_5 = comp_schm_vc3_5;
     comp_schm_3_4 = comp_schm_vc3_4;
     comp_schm_3_3 = comp_schm_vc3_3;
     comp_schm_3_2 = comp_schm_vc3_2;
     comp_schm_3_1 = comp_schm_vc3_1;
     comp_schm_3_0 = comp_schm_vc3_0;
    end
  endtask


  /*----------------------------------------------------------------------------
    Task forces lane_index through testcase, which overrides the lane index
    forced through command line 
  -----------------------------------------------------------------------------
  task force_lane_index;
    input [2:0] temp_lane_index;
    begin
      lan_index     =   temp_lane_index;
      lane_index_en =   1'b1;
    end
  endtask */

  /*----------------------------------------------------------------------------
      Task that Computes the CRC for the Long packet Pixel data 
  -----------------------------------------------------------------------------*/

  task crc_computation;
    input   [7:0] data_crc;
    input  [15:0] p_crc;
    output [15:0] n_crc; 
    begin
      n_crc[15] = data_crc[3] ^ data_crc[7] ^ p_crc[7] ^ p_crc[3];
      n_crc[14] = data_crc[2] ^ data_crc[6] ^ p_crc[6] ^ p_crc[2];
      n_crc[13] = data_crc[1] ^ data_crc[5] ^ p_crc[5] ^ p_crc[1];
      n_crc[12] = data_crc[0] ^ data_crc[4] ^ p_crc[4] ^ p_crc[0];
      n_crc[11] = data_crc[3] ^ p_crc[3];
      n_crc[10] = data_crc[2] ^ data_crc[3] ^ data_crc[7] ^ p_crc[7] ^ p_crc[3] ^ p_crc[2];
      n_crc[9]  = data_crc[1] ^ data_crc[2] ^ data_crc[6] ^ p_crc[6] ^ p_crc[2] ^ p_crc[1];
      n_crc[8]  = data_crc[0] ^ data_crc[1] ^ data_crc[5] ^ p_crc[5] ^ p_crc[1] ^ p_crc[0];
      n_crc[7]  = data_crc[0] ^ data_crc[4] ^ p_crc[15]   ^ p_crc[4] ^ p_crc[0];
      n_crc[6]  = data_crc[3] ^ p_crc[14]   ^ p_crc[3];
      n_crc[5]  = data_crc[2] ^ p_crc[13]   ^ p_crc[2];
      n_crc[4]  = data_crc[1] ^ p_crc[12]   ^ p_crc[1];
      n_crc[3]  = data_crc[0] ^ data_crc[3] ^ data_crc[7] ^ p_crc[11] ^ p_crc[7] ^ p_crc[3] ^ p_crc[0];
      n_crc[2]  = data_crc[2] ^ data_crc[6] ^ p_crc[10]   ^ p_crc[6]  ^ p_crc[2];
      n_crc[1]  = data_crc[1] ^ data_crc[5] ^ p_crc[9]    ^ p_crc[5]  ^ p_crc[1];
      n_crc[0]  = data_crc[0] ^ data_crc[4] ^ p_crc[8]    ^ p_crc[4]  ^ p_crc[0];
    end
  endtask


  /*----------------------------------------------------------------------------
      Task that Computes the ECC for the Packet Header in Short & Long Packet's 
  -----------------------------------------------------------------------------*/

  task ecc_computation;
   input [23:0] temp_ecc_data;
    begin

      parity_0 =  temp_ecc_data[0]  ^ temp_ecc_data[1]  ^ temp_ecc_data[2]  ^ temp_ecc_data[4]  ^
                  temp_ecc_data[5]  ^ temp_ecc_data[7]  ^ temp_ecc_data[10] ^ temp_ecc_data[11] ^
                  temp_ecc_data[13] ^ temp_ecc_data[16] ^ temp_ecc_data[20] ^ temp_ecc_data[21] ^
                  temp_ecc_data[22] ^ temp_ecc_data[23];

      parity_1 =  temp_ecc_data[0]  ^ temp_ecc_data[1]  ^ temp_ecc_data[3]  ^ temp_ecc_data[4]  ^
                  temp_ecc_data[6]  ^ temp_ecc_data[8]  ^ temp_ecc_data[10] ^ temp_ecc_data[12] ^
                  temp_ecc_data[14] ^ temp_ecc_data[17] ^ temp_ecc_data[20] ^ temp_ecc_data[21] ^
                  temp_ecc_data[22] ^ temp_ecc_data[23];

      parity_2 =  temp_ecc_data[0]  ^ temp_ecc_data[2]  ^ temp_ecc_data[3]  ^ temp_ecc_data[5]  ^
                  temp_ecc_data[6]  ^ temp_ecc_data[9]  ^ temp_ecc_data[11] ^ temp_ecc_data[12] ^
                  temp_ecc_data[15] ^ temp_ecc_data[18] ^ temp_ecc_data[20] ^ temp_ecc_data[21] ^
                  temp_ecc_data[22];

      parity_3 =  temp_ecc_data[1]  ^ temp_ecc_data[2]  ^ temp_ecc_data[3]  ^ temp_ecc_data[7]  ^
                  temp_ecc_data[8]  ^ temp_ecc_data[9]  ^ temp_ecc_data[13] ^ temp_ecc_data[14] ^
                  temp_ecc_data[15] ^ temp_ecc_data[19] ^ temp_ecc_data[20] ^ temp_ecc_data[21] ^
                  temp_ecc_data[23];

      parity_4 =  temp_ecc_data[4]  ^ temp_ecc_data[5]  ^ temp_ecc_data[6]  ^ temp_ecc_data[7]  ^
                  temp_ecc_data[8]  ^ temp_ecc_data[9]  ^ temp_ecc_data[16] ^ temp_ecc_data[17] ^
                  temp_ecc_data[18] ^ temp_ecc_data[19] ^ temp_ecc_data[20] ^ temp_ecc_data[22] ^
                  temp_ecc_data[23];

      parity_5 =  temp_ecc_data[10] ^ temp_ecc_data[11] ^ temp_ecc_data[12] ^ temp_ecc_data[13] ^
                  temp_ecc_data[14] ^ temp_ecc_data[15] ^ temp_ecc_data[16] ^ temp_ecc_data[17] ^
                  temp_ecc_data[18] ^ temp_ecc_data[19] ^ temp_ecc_data[21] ^ temp_ecc_data[22] ^
                  temp_ecc_data[23];

      ecc_parity_value = {2'b00,parity_5,parity_4,parity_3,parity_2,parity_1,parity_0};
    end
  endtask


  // Task for detecting whether the Wordcount sent is correct or not 

  task packet_size_error_detection;
   begin
    if(((data_type == `RAW8)      || (data_type == `USD_TYPE1) || // 1
        (data_type == `USD_TYPE2) || (data_type == `USD_TYPE3) ||
        (data_type == `USD_TYPE4) || (data_type == `USD_TYPE5) || 
        (data_type == `USD_TYPE6) || (data_type == `USD_TYPE7) ||
        (data_type == `USD_TYPE8)) && (word_count < 1)) begin
     if(word_count < 1) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end                    
    end //  1
    else if(((data_type == `RAW12 ) && word_count < 3) || ((data_type == `RAW12 ) && word_count % 3 != 0)) begin //  2

     if(word_count < 3) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 3\n",data_type);
     end
    end // 2
    else if ((data_type == `YUV422_8B && word_count < 4) || (data_type == `YUV422_8B && word_count % 4 != 0)) begin // 3 
     if(word_count < 4) begin                                                                                         
        less_not_mul_err = 1'b1;                                                                                         
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE 0x%h DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT \n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE 0x%h PACKET SIZE IS NOT IN MULTIPLES OF 4 ",data_type);
     end
    end //  3
    else if (((data_type == `YUV422_10B || data_type == `RAW10) && word_count < 5) || 
             ((data_type == `YUV422_10B || data_type == `RAW10) && word_count % 5 != 0)) begin //  4
     if(word_count < 5) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE 0x%h DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT \n",data_type); 
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display ($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE 0x%h PACKET SIZE IS NOT IN MULTIPLES OF 5\n",data_type);
     end
    end //  4 
    else if (((data_type == `RAW14)&& word_count < 7) || ((data_type == `RAW14)&& word_count % 7 != 0)) begin // 5
     if(word_count < 7) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 7\n",data_type);
     end              
    end//5

    else if(((data_type == `RAW6 ) && word_count < 3) || ((data_type == `RAW6 ) && word_count % 3 != 0)) begin //  -->

     if(word_count < 3) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 3\n",data_type);
     end
    end // -->

    else if (((data_type == `RAW7)&& word_count < 7) || ((data_type == `RAW7)&& word_count % 7 != 0)) begin // &&
     if(word_count < 7) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 7\n",data_type);
     end              
    end// &&

    else if ( ( ( (data_type == `YUV420_8B) || (data_type == `YUV420_8B_CSPS)) && (yuv_420_8_odd_even_line == 1'b1) && ((word_count < 2) ||(word_count % 2 != 0) ) )
            ||( ( (data_type == `YUV420_8B) || (data_type == `YUV420_8B_CSPS)) && (yuv_420_8_odd_even_line == 1'b0) && ((word_count < 4) ||(word_count % 4 != 0) ) ) ) begin//6
     if( (yuv_420_8_odd_even_line == 1'b1) && word_count < 2) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 2\n",data_type);
     end          
     if( (yuv_420_8_odd_even_line == 1'b0) && word_count < 4) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 4\n",data_type);
     end    
    end //6

    else if ( ( ( (data_type == `YUV420_10B) || (data_type == `YUV420_10B_CSPS)) && (yuv_420_10_odd_even_line == 1'b1) && ((word_count < 5) ||(word_count % 5 != 0) ) )
            ||( ( (data_type == `YUV420_10B) || (data_type == `YUV420_10B_CSPS)) && (yuv_420_10_odd_even_line == 1'b0) && ((word_count < 10) ||(word_count % 10 != 0) ) ) ) begin//7
     if( (yuv_420_10_odd_even_line == 1'b1) && word_count < 5) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 5\n",data_type);
     end          
     if( (yuv_420_10_odd_even_line == 1'b0) && word_count < 10) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 10\n",data_type);
     end    
    end //7

    else if (( ( (data_type == `RGB444) || (data_type == `RGB555) || (data_type == `RGB565) )&& word_count < 2) ||
               ( ((data_type == `RGB444) || (data_type == `RGB555) || (data_type == `RGB565))&& word_count % 2 != 0)) begin // 8
     if(word_count < 2) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 2\n",data_type);
     end              
    end//8
    else if (((data_type == `RGB666)&& word_count < 9) || ((data_type == `RGB666)&& word_count % 9 != 0)) begin // 9
     if(word_count < 7) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 9\n",data_type);
     end              
    end//9
    else if(((data_type == `RGB888 ) && word_count < 3) || ((data_type == `RGB888 ) && word_count % 3 != 0)) begin //  10

     if(word_count < 3) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 3\n",data_type);
     end
    end // 10

    else if(((data_type == `LYUV420_8B ) && word_count < 3) || ((data_type == `LYUV420_8B ) && word_count % 3 != 0)) begin // 11
     if(word_count < 3) begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET DOES NOT MEET THE MINIMUM PACKET SIZE REQUIREMENT\n",data_type);
     end else begin
        less_not_mul_err = 1'b1;
        error_rxbfm  = 1'b1;
        $display($time,"\tCSI2 RX BFM : ERROR - RECEIVED DATA TYPE %h PACKET SIZE IS NOT IN MULTIPLES OF 3\n",data_type);
     end
    end // 11
    else    // This else is for the IF which checks for the Valid Word count.
     begin  //  So if the word count is valid then it is nothing but Long packet    
      packet_indi =1'b0;
      less_not_mul_err = 1'b0;
     end
end
endtask


  task byte_pix_raw6;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
           
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg1[5:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg2[3:0],reg1[7:6]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg3[1:0],reg2[7:4]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg3[7:2]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
            end

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg1[5:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg2[3:0],reg1[7:6]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg3[1:0],reg2[7:4]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg3[7:2]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
            end
           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
           
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg1[5:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg2[3:0],reg1[7:6]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg3[1:0],reg2[7:4]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {26'b0,reg3[7:2]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
        end
        end
       end else if(pkt_cmplt == 1'b0) begin //2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j =0 ;
           pkt_cmplt = 1'b1;
         end

       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop
      cntrl_packing = 0;
  end //task begin
  endtask


  task byte_pix_raw7;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0111) begin // min bytes 7
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
               reg4= byte_mem[3];
               reg5= byte_mem[4];
               reg6= byte_mem[5];
               reg7= byte_mem[6];
          
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {25'b0,reg1[6:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {25'b0,reg2[5:0],reg1[7]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {25'b0,reg3[4:0],reg2[7:6]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {25'b0,reg4[3:0],reg3[7:5]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {25'b0,reg5[2:0],reg4[7:4]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {25'b0,reg6[1:0],reg5[7:3]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {25'b0,reg7[0],reg6[7:2]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {25'b0,reg7[7:1]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;

               byte_mem_wr_cnt=4'd0;
        end
        end
       end else if(pkt_cmplt == 1'b0) begin // 2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j = 0;
           pkt_cmplt = 1'b1;
         end
       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop

  end //task begin
  endtask


  // Task for converting Byte to pixel for RAW8 & All Supported USD Data Types
  // & also Generic Long Packets

  task byte_pix_raw8_all_usd;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1) && (byte_counter < wccount) )begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 

          if(byte_mem_wr_cnt == 4'b0001) begin // min bytes 1
           scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,byte_mem[byte_mem_wr_cnt -1]};
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
           byte_mem_wr_cnt=5'd0;
          end 
        end

       end else if(pkt_cmplt == 1'b0) begin // 2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j = 0;
           pkt_cmplt = 1'b1;
         end
       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop

  end //task begin
  endtask

  task byte_pix_raw10;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0101) begin // min bytes 5
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
               reg4= byte_mem[3];
               reg5= byte_mem[4];
          
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg1[7:0],reg5[1:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg2[7:0],reg5[3:2]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg3[7:0],reg5[5:4]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg4[7:0],reg5[7:6]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
        end
        end
       end else if(pkt_cmplt == 1'b0) begin // 2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j = 0;
           pkt_cmplt = 1'b1;
         end
       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop

  end //task begin
  endtask

  task byte_pix_raw12;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
           
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg1[7:0],reg3[3:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg2[7:0],reg3[7:4]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
            end

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
           
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg1[7:0],reg3[3:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg2[7:0],reg3[7:4]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
            end
           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
           
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg1[7:0],reg3[3:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg2[7:0],reg3[7:4]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
        end
        end
       end else if(pkt_cmplt == 1'b0) begin //2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j =0 ;
           pkt_cmplt = 1'b1;
         end

       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop
      cntrl_packing = 0;
  end //task begin
  endtask


  task byte_pix_raw14;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0111) begin // min bytes 7
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
               reg4= byte_mem[3];
               reg5= byte_mem[4];
               reg6= byte_mem[5];
               reg7= byte_mem[6];
          
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {18'b0,reg1[7:0],reg5[5:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {18'b0,reg2[7:0],reg6[3:0],reg5[7:6]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg3[7:0],reg7[1:0],reg6[7:4]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {18'b0,reg4[7:0],reg7[7:2]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
        end
        end
       end else if(pkt_cmplt == 1'b0) begin // 2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j = 0;
           pkt_cmplt = 1'b1;
         end
       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop

  end //task begin
  endtask

  task byte_pix_yuv_422_8bit;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt +1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc;
          if(byte_mem_wr_cnt == 4'b0100) begin // min bytes 4
             reg1= byte_mem[0];
             reg2= byte_mem[1];
             reg3= byte_mem[2];
             reg4= byte_mem[3];
             
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {8'b0,reg3[7:0],reg2[7:0],reg1[7:0]}; //V1Y1U1
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg4[7:0]}; //Y2
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             byte_mem_wr_cnt=4'd0;
          end
           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
              if(byte_mem_wr_cnt == 4'b0100) begin // min bytes 4
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
               reg4= byte_mem[3];

               scorbd_pix_mem[scorbd_pix_wr_cnt] = {8'b0,reg3[7:0],reg2[7:0],reg1[7:0]}; //V1Y1U1
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg4[7:0]}; //Y2
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
        end
        end
       end else if(pkt_cmplt == 1'b0) begin // 2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j = 0;
           pkt_cmplt = 1'b1;
         end
       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop

  end //task begin
  endtask

  task byte_pix_yuv_422_10bit;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
              if(byte_mem_wr_cnt == 4'b0101) begin // min bytes 5
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
               reg4= byte_mem[3];
               reg5= byte_mem[4];

               scorbd_pix_mem[scorbd_pix_wr_cnt] = {2'b0,reg3[7:0],reg5[5:4], //V1
                                                         reg2[7:0],reg5[3:2], //Y1
                                                         reg1[7:0],reg5[1:0]};//U1
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg4[7:0],reg5[7:6]}; //Y2
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
        end
        end
       end else if(pkt_cmplt == 1'b0) begin // 2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j = 0;
           pkt_cmplt = 1'b1;
         end
       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop

  end //task begin
  endtask

  task byte_pix_yuv_420_8bit;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if(yuv_420_8_odd_even_line ==  1'b1) begin //Inicates odd Line
            if(byte_mem_wr_cnt == 4'b0010) begin // min bytes 2
             reg1= byte_mem[0];
             reg2= byte_mem[1];
             
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg1[7:0]}; //Y1
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg2[7:0]}; //Y2
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             byte_mem_wr_cnt=4'd0;
            end
           end
          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if(yuv_420_8_odd_even_line ==  1'b1) begin //Inicates odd Line
            if(byte_mem_wr_cnt == 4'b0010) begin // min bytes 2
             reg1= byte_mem[0];
             reg2= byte_mem[1];
             
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg1[7:0]}; //Y1
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg2[7:0]}; //Y2
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             byte_mem_wr_cnt=4'd0;
            end
           end

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if(yuv_420_8_odd_even_line ==  1'b1) begin //Inicates odd Line
            if(byte_mem_wr_cnt == 4'b0010) begin // min bytes 2
             reg1= byte_mem[0];
             reg2= byte_mem[1];
             
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg1[7:0]}; //Y1
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg2[7:0]}; //Y2
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             byte_mem_wr_cnt=4'd0;
            end
           end

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin//Delete 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt +1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc;

         if(yuv_420_8_odd_even_line ==  1'b1) begin //Inicates odd Line
          if(byte_mem_wr_cnt == 4'b0010) begin // min bytes 2
             reg1= byte_mem[0];
             reg2= byte_mem[1];
             
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg1[7:0]}; //Y1
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg2[7:0]}; //Y2
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             byte_mem_wr_cnt=4'd0;
          end
         end else if(yuv_420_8_odd_even_line ==  1'b0)begin //Indicates Even Line
          if(byte_mem_wr_cnt == 4'b0100) begin // min bytes 4
             reg1= byte_mem[0];
             reg2= byte_mem[1];
             reg3= byte_mem[2];
             reg4= byte_mem[3];
             
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {8'b0,reg3[7:0],reg2[7:0],reg1[7:0]}; //V1Y1U1
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg4[7:0]}; //Y2
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             byte_mem_wr_cnt=4'd0;
          end
         end
           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end //Delete
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 

         if(yuv_420_8_odd_even_line ==  1'b1) begin //Inicates odd Line
          if(byte_mem_wr_cnt == 4'b0010) begin // min bytes 2
             reg1= byte_mem[0];
             reg2= byte_mem[1];
             
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg1[7:0]}; //Y1
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg2[7:0]}; //Y2
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             byte_mem_wr_cnt=4'd0;
          end
         end else if(yuv_420_8_odd_even_line ==  1'b0)begin //Indicates Even Line
          if(byte_mem_wr_cnt == 4'b0100) begin // min bytes 4
             reg1= byte_mem[0];
             reg2= byte_mem[1];
             reg3= byte_mem[2];
             reg4= byte_mem[3];
             
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {8'b0,reg3[7:0],reg2[7:0],reg1[7:0]}; //V1Y1U1
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg4[7:0]}; //Y2
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             byte_mem_wr_cnt=4'd0;
          end
        end
       end
       end else if(pkt_cmplt == 1'b0) begin // 2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j = 0;
           pkt_cmplt = 1'b1;
         end
       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop

  end //task begin
  endtask

  task byte_pix_yuv_420_10bit;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 


         if(yuv_420_10_odd_even_line ==  1'b1) begin //Inicates odd Line
          if(byte_mem_wr_cnt == 4'b0101) begin // min bytes 5
           reg1= byte_mem[0];
           reg2= byte_mem[1];
           reg3= byte_mem[2];
           reg4= byte_mem[3];
           reg5= byte_mem[4];

           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg1[7:0],reg5[1:0]};//Y1
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;


           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg2[7:0],reg5[3:2]}; //Y2
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;



           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg3[7:0],reg5[5:4]}; //Y3
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;


           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg4[7:0],reg5[7:6]}; //Y4
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
           byte_mem_wr_cnt=4'd0;
          end
         end else if(yuv_420_10_odd_even_line ==  1'b0)begin //Indicates Even Line
          if(byte_mem_wr_cnt == 4'b1010) begin // min bytes 5
           reg1= byte_mem[0];
           reg2= byte_mem[1];
           reg3= byte_mem[2];
           reg4= byte_mem[3];
           reg5= byte_mem[4];
           reg6= byte_mem[5];
           reg7= byte_mem[6];
           reg8= byte_mem[7];
           reg9= byte_mem[8];
           reg10= byte_mem[9];
           
           scorbd_pix_mem[scorbd_pix_wr_cnt] = {2'b0,reg3[7:0],reg5[5:4], //V1
                                                     reg2[7:0],reg5[3:2], //Y1
                                                     reg1[7:0],reg5[1:0]};//U1
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;

           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg4[7:0],reg5[7:6]}; //Y2
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;

           scorbd_pix_mem[scorbd_pix_wr_cnt] = {2'b0,reg8[7:0],reg10[5:4], //V3
                                                     reg7[7:0],reg10[3:2], //Y3
                                                     reg6[7:0],reg10[1:0]};//U3
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;

           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg9[7:0],reg10[7:6]}; //Y4
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
           byte_mem_wr_cnt=4'd0;
          end
        end

           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
         if(yuv_420_10_odd_even_line ==  1'b1) begin //Inicates odd Line
          if(byte_mem_wr_cnt == 4'b0101) begin // min bytes 5
           reg1= byte_mem[0];
           reg2= byte_mem[1];
           reg3= byte_mem[2];
           reg4= byte_mem[3];
           reg5= byte_mem[4];


           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg1[7:0],reg5[1:0]};//Y1
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;


           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg2[7:0],reg5[3:2]};//Y2
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;



           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg3[7:0],reg5[5:4]}; //Y3
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;


           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg4[7:0],reg5[7:6]}; //Y4
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
           byte_mem_wr_cnt=4'd0;
          end
         end else if(yuv_420_10_odd_even_line ==  1'b0)begin //Indicates Even Line
          if(byte_mem_wr_cnt == 4'b1010) begin // min bytes 5
           reg1= byte_mem[0];
           reg2= byte_mem[1];
           reg3= byte_mem[2];
           reg4= byte_mem[3];
           reg5= byte_mem[4];
           reg6= byte_mem[5];
           reg7= byte_mem[6];
           reg8= byte_mem[7];
           reg9= byte_mem[8];
           reg10= byte_mem[9];
           scorbd_pix_mem[scorbd_pix_wr_cnt] = {2'b0,reg3[7:0],reg5[5:4], //V1
                                                     reg2[7:0],reg5[3:2], //Y1
                                                     reg1[7:0],reg5[1:0]};//U1
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;

           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg4[7:0],reg5[7:6]}; //Y2
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;

           scorbd_pix_mem[scorbd_pix_wr_cnt] = {2'b0,reg8[7:0],reg10[5:4], //V3
                                                     reg7[7:0],reg10[3:2], //Y3
                                                     reg6[7:0],reg10[1:0]};//U3
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;

           scorbd_pix_mem[scorbd_pix_wr_cnt] = {22'b0,reg9[7:0],reg10[7:6]}; //Y4
           scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
           byte_mem_wr_cnt=4'd0;
          end
        end
        end
       end else if(pkt_cmplt == 1'b0) begin // 2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j = 0;
           pkt_cmplt = 1'b1;
         end
       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop

  end //task begin
  endtask

  task byte_pix_rgb_444_555_565;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

            if(byte_mem_wr_cnt == 4'b0010) begin // min bytes 2
             reg1= byte_mem[0];
             reg2= byte_mem[1];

             if(data_type == `RGB444)begin
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg2[7:4],reg2[2:0],reg1[7],reg1[4:1]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end else if(data_type == `RGB555)begin
              scorbd_pix_mem[scorbd_pix_wr_cnt] = {17'b0,reg2[7:3],reg2[2:0],reg1[7:6],reg1[4:0]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end else if(data_type == `RGB565)begin
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {16'b0,reg2[7:3],reg2[2:0],reg1[7:5],reg1[4:0]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end

             byte_mem_wr_cnt=4'd0;
            end
          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

            if(byte_mem_wr_cnt == 4'b0010) begin // min bytes 2
             reg1= byte_mem[0];
             reg2= byte_mem[1];

             if(data_type == `RGB444)begin
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg2[7:4],reg2[2:0],reg1[7],reg1[4:1]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end else if(data_type == `RGB555)begin
              scorbd_pix_mem[scorbd_pix_wr_cnt] = {17'b0,reg2[7:3],reg2[2:0],reg1[7:6],reg1[4:0]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end else if(data_type == `RGB565)begin
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {16'b0,reg2[7:3],reg2[2:0],reg1[7:5],reg1[4:0]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end

             byte_mem_wr_cnt=4'd0;
            end

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

            if(byte_mem_wr_cnt == 4'b0010) begin // min bytes 2
             reg1= byte_mem[0];
             reg2= byte_mem[1];

             if(data_type == `RGB444)begin
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg2[7:4],reg2[2:0],reg1[7],reg1[4:1]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end else if(data_type == `RGB555)begin
              scorbd_pix_mem[scorbd_pix_wr_cnt] = {17'b0,reg2[7:3],reg2[2:0],reg1[7:6],reg1[4:0]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end else if(data_type == `RGB565)begin
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {16'b0,reg2[7:3],reg2[2:0],reg1[7:5],reg1[4:0]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end

             byte_mem_wr_cnt=4'd0;
            end
    
           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt +1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc;

          if(byte_mem_wr_cnt == 4'b0010) begin // min bytes 2
             reg1= byte_mem[0];
             reg2= byte_mem[1];

             if(data_type == `RGB444)begin
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg2[7:4],reg2[2:0],reg1[7],reg1[4:1]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end else if(data_type == `RGB555)begin
              scorbd_pix_mem[scorbd_pix_wr_cnt] = {17'b0,reg2[7:3],reg2[2:0],reg1[7:6],reg1[4:0]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end else if(data_type == `RGB565)begin
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {16'b0,reg2[7:3],reg2[2:0],reg1[7:5],reg1[4:0]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end

             byte_mem_wr_cnt=4'd0;
          end

           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end 
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 

          if(byte_mem_wr_cnt == 4'b0010) begin // min bytes 2

             reg1= byte_mem[0];
             reg2= byte_mem[1];

             if(data_type == `RGB444)begin
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {20'b0,reg2[7:4],reg2[2:0],reg1[7],reg1[4:1]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end else if(data_type == `RGB555)begin
              scorbd_pix_mem[scorbd_pix_wr_cnt] = {17'b0,reg2[7:3],reg2[2:0],reg1[7:6],reg1[4:0]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end else if(data_type == `RGB565)begin
             scorbd_pix_mem[scorbd_pix_wr_cnt] = {16'b0,reg2[7:3],reg2[2:0],reg1[7:5],reg1[4:0]}; //RGB
             scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
             end

             byte_mem_wr_cnt=4'd0;
          end
       end
       end else if(pkt_cmplt == 1'b0) begin // 2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j = 0;
           pkt_cmplt = 1'b1;
         end
       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop

  end //task begin
  endtask

task byte_pix_rgb_666;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b1001) begin // min bytes 9
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
               reg4= byte_mem[3];
               reg5= byte_mem[4];
               reg6= byte_mem[5];
               reg7= byte_mem[6];
               reg8= byte_mem[7];
               reg9= byte_mem[8];
          
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {14'b0,reg3[1:0],reg2[7:4],reg2[3:0],reg1[7:6],reg1[5:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {14'b0,reg5[3:0],reg4[7:6],reg4[5:0],reg3[7:2]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {14'b0,reg7[5:0],reg6[7:2],reg6[1:0],reg5[7:4]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {14'b0,reg9[7:2],reg9[1:0],reg8[7:4],reg8[3:0],reg7[7:6]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
        end
        end
       end else if(pkt_cmplt == 1'b0) begin // 2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j = 0;
           pkt_cmplt = 1'b1;
         end
       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop

  end //task begin
  endtask


task byte_pix_rgb_888;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
           
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {8'b0,reg3[7:0],reg2[7:0],reg1[7:0]};//RGB
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
            end

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
           
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {8'b0,reg3[7:0],reg2[7:0],reg1[7:0]};//RGB
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;

               byte_mem_wr_cnt=4'd0;
            end
           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
           
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {8'b0,reg3[7:0],reg2[7:0],reg1[7:0]};//RGB
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
  
               byte_mem_wr_cnt=4'd0;
        end
        end
       end else if(pkt_cmplt == 1'b0) begin //2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j =0 ;
           pkt_cmplt = 1'b1;
         end

       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop
      cntrl_packing = 0;
  end //task begin
  endtask

task byte_pix_lyuv_420_8bit;
   input [15:0] wccount;
   input [2:0]  temp_lanecount;
  begin
   byte_counter = 16'h0;
   cntrl_packing = 1'b0;
   j=0;
   p_crc = 16'hffff;
    while(byte_counter < wccount + 2) // For CRC Calculation
     begin
     for (i=0 ; i<=lane_index; i=i+1)
      begin
       if(rxdphy_rxbfm_validhs[i] == 1'b1) begin


       if(byte_counter < wccount) begin// 2


        if(cntrl_packing == 1'b0)begin

         // Lane 3
         if((temp_lanecount == 3'b010) &&( i == 1 || i ==2))begin         
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 2)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 5
         else if((temp_lanecount == 3'b100) && ( i == 4))begin        
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 4)) begin
            cntrl_packing = 1'b1;
          end
         end

         // Lane 6 
         else if((temp_lanecount == 3'b101) && ( i == 4 || i == 5))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

          if((byte_counter == wccount) || (i == 5)) begin
            cntrl_packing = 1'b1;
          end
         end 

         // Lane 7 
         else if((temp_lanecount == 3'b110) && ( i == 4 || i == 5  || i == 6))begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 

            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
           
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {16'b0,reg2[7:0],reg1[7:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg3[7:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
            end

           if((byte_counter == wccount) || (i == 6)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // Lane 8 
         else if((temp_lanecount == 3'b111)&& ( i == 4 || i == 5  || i == 6) || i == 7)begin 
            byte_mem[byte_mem_wr_cnt] = {24'b0,rxdphy_rxbfm_datahs[(8*i) +: 8]};
            byte_mem_wr_cnt = byte_mem_wr_cnt + 1'b1;
            byte_counter = byte_counter +1;

            // Crc computation
            crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
            crc_computation(crc_data,p_crc,n_crc);      
            p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {16'b0,reg2[7:0],reg1[7:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg3[7:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
            end
           if((byte_counter == wccount) || (i == 7)) begin
            cntrl_packing = 1'b1;
          end
         end
 
         // lane 1 
         else if((temp_lanecount == 3'b000))begin        
            cntrl_packing = 1'b1;
         end

         // lane 2 
         else if((temp_lanecount == 3'b001) && ( i == 1))begin
            cntrl_packing = 1'b1;
         end

         // lane 4 
         else if((temp_lanecount == 3'b011) && ( i == 3))begin
            cntrl_packing = 1'b1;
         end

       end else if((cntrl_packing == 1'b1))begin
         byte_mem[byte_mem_wr_cnt] = rxdphy_rxbfm_datahs[(8*i) +: 8];
         byte_counter = byte_counter +1;
         byte_mem_wr_cnt = byte_mem_wr_cnt +1;

         // Crc computation
         crc_data      = rxdphy_rxbfm_datahs[(8*i) +: 8];
         crc_computation(crc_data,p_crc,n_crc);      
         p_crc     = n_crc; 
            if(byte_mem_wr_cnt == 4'b0011) begin // min bytes 3
               reg1= byte_mem[0];
               reg2= byte_mem[1];
               reg3= byte_mem[2];
           
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {16'b0,reg2[7:0],reg1[7:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               scorbd_pix_mem[scorbd_pix_wr_cnt] = {24'b0,reg3[7:0]};
               scorbd_pix_wr_cnt = scorbd_pix_wr_cnt + 1'b1;
               byte_mem_wr_cnt=4'd0;
        end
        end
       end else if(pkt_cmplt == 1'b0) begin //2
        temp_crc[(8*j) +:8] = rxdphy_rxbfm_datahs[(8*i) +: 8];
        j= j+1;
        byte_counter = byte_counter +1;
         if((j == 2) && (temp_crc !== n_crc))begin
           error_rxbfm  = 1'b1;
           pkt_cmplt = 1'b1;
           $display($time,"\tCSI2 RX BFM : ERROR - CRC MISMATCH IN THE LONG PACKET\n");
         end else if((j == 2 )&& (temp_crc == n_crc))begin
           j =0 ;
           pkt_cmplt = 1'b1;
         end

       end
       end
       end //for looop
      @(posedge byteclkhs);
     end //while loop
      cntrl_packing = 0;
  end //task begin
  endtask


endmodule
