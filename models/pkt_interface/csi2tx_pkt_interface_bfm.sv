/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_dphy_afe_dfe_top.v
// Author      : R DINESH KUMAR
// Version     : v1p2
// Abstract    : The image sensor bfm for the different data types  
//                
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 21/05/2014
//==============================================================================*/

`timescale 1 ps / 1 ps
`define data_size 32
`define wc_size 16
`define data_type_size 6
`define comp_size12 12
`define dmp_array_size 65536
`define display_time $display("\tPKT INTERFACE : **** Display Time **** ",$time);
`define FIXED_SEED
`define TIMING_REG 4'd2

module  csi2tx_pkt_interface_bfm (
    input                 clk_csi,
    input		              packet_rdy,
    input		              packet_data_rdy,
    input		              stopstate_dat_0,
    input  reg  [31:0]	  raw_image_data_type,
    input  reg  [31:0]	  yuv_image_data_type,
    input  reg  [31:0]	  usd_data_type_reg,
    input  reg  [31:0]	  rgb_image_data_type,
    input  reg  [31:0]	  generic_8_bit_long_pkt_data_type,
    input  reg   [2:0]    reg_lane_cnt,
    input  wire	          reset_clk_csi_n,
    output reg 	          fs,
    output reg	          fe,
    output reg	          le,
    output reg	          ls,
    output reg            packet_valid,
    output reg   [1:0]    packet_vc,                
    output reg            csi_end_of_file,
    output reg  [15:0]    packet_wc_df,
    output reg            csi_tx_pix_en,
    output reg   [5:0]    packet_dt,
    output reg	          packet_data_valid,
    output reg            forcetxstopmode,
    output reg	          txulpsexit,
    output reg	          dphy_clk_mode,
    output reg 	          loopack_sel,
    output reg  [31:0]    raw_data_out,
    output reg 	          txulpsesc,
    output reg	          master_pin,
    output reg	          pkt_drop_en,
    output reg	          pkt_sent,
    output reg 	          odd_even_line,
    output reg	          test_mode,
    output reg   [4:0]    comp_scheme,
    output reg   [9:0]    Xdeco10_2_monitor,
    output reg  [11:0]    Xdeco12_2_monitor,
    output reg	          dec_2_monitor,
  output reg           tx_skewcallhs,
    output reg  [31:0]    pixel_width,
    output real 	        csi_clk_freq,
    output reg		        compression_en
   );

  /*----------------------------------------------------------------------------
    Memory Declaration
  ----------------------------------------------------------------------------*/
  reg     [`data_size - 1:0]        mem_generic                 [0:65535];
  reg     [`data_size - 1:0]        mem_user                    [0:65535];
  reg                 [31:0]        usd_def_typ1      [0:`dmp_array_size];
  reg                  [9:0]        Xpred10                     [1:65536];
  reg                 [14:0]        Xdeco10                     [1:65536];
  reg                 [11:0]        Xpred12                     [1:65536];
  reg                 [16:0]        Xdeco12                     [1:65536];
  reg                  [7:0]        Xenco8                      [1:65536];
  reg                  [6:0]        Xenco7                      [1:65536];
  reg                  [5:0]        Xenco6                      [1:65536];
  reg                  [9:0]        Xdiff10                     [1:65536];
  reg                  [9:0]        Xorig10                     [1:65536];
  reg                 [11:0]        Xdiff12                     [1:65536];
  reg                 [11:0]        Xorig12                     [1:65536];
  reg                 [11:0]        compression_data            [0:24999]; 
  reg     [`data_size - 1:0]        short_reg                       [0:3];
  reg                 [39:0]        time_val                        [1:0];

  /*----------------------------------------------------------------------------
    Internal Register, Wire, Real & Integer Declaration
  ----------------------------------------------------------------------------*/
  reg                   [20*8:1]    command                                    ;
  reg                   [20*8:1]    command1                                   ;
  reg           [`wc_size - 1:0]    actual_pkt_size                            ;
  reg                      [1:0]    vir_channel                                ;
  reg      [`data_type_size-1:0]    data_type                                  ;
  reg                     [15:0]    byte_count_new                             ;
  reg                      [7:0]    shft_tx_data                               ;
  reg                               gen_long_pkt_en                            ;
  reg                               user_def_pkt_en                            ;
  reg                               gen_def_pkt_en                             ;
  reg                               rgb_pak_en                                 ; 
  reg                               yuv_pak_en                                 ;
  reg                               raw_pak_en                                 ;
  reg         [`data_size - 1:0]    csi_data_tx                                ;
  reg                               long_packet_en                             ;
  reg                     [31:0]    tx_cnt                                     ;
  //reg [16:0]                    no_of_bytes;
  reg                     [31:0]    packet_data                                ;
  reg                     [31:0]    shft_tx_data1                              ;
  reg                               short_packet_en                            ;
  reg                               gen_sht_pkt_en                             ;
  reg                     [17:0]    gen_data_tx                                ;
  reg                      [1:0]    temp_prediction                            ;
  reg                               encoder_sign                               ;
  reg                      [7:0]    decoder_sign                               ;
  reg                               Xdiff_grt_than_0                           ;
  reg                               Xdiff_les_than_0                           ;
  reg                               Xdiff_equal_to_0                           ;
  reg                     [10:0]    temp_val                                   ;
  reg                     [12:0]    temp_val2                                  ;
  reg                      [9:0]    value10                                    ;
  reg                     [11:0]    value12                                    ;
  reg                               dec_10_bit                                 ;
  reg                               dec_12_bit                                 ;
  reg                     [15:0]    sig_pixel_count                            ;
  reg                               fixed_seed_en                              ;
  reg                               random_en                                  ;
  reg                     [31:0]    rand_seed                                  ;
  reg                     [39:0]    rand_seed_in                               ;
  reg                     [15:0]    rand_wc                                    ;
  reg                     [15:0]    rand_wc_op                                 ;
  reg                     [31:0]    min_val_wc                                 ;
  reg                     [31:0]    max_val_wc                                 ;
  reg                     [15:0]    rand_wc_comp                               ;
  reg                     [15:0]    rand_wc_op_comp                            ;
  reg                     [31:0]    min_val_wc_comp                            ;
  reg                               device_ready_t                             ;
  reg                               long_packet_en_d                           ;
  reg                               wait_pak_en                                ;
  reg                      [3:0]    yuv420_8b_odd_even_line                    ; 
  reg                      [3:0]    yuv420_10b_odd_even_line                   ; 
  reg                      [3:0]    lyuv420_8b_odd_even_line                   ; 
  reg                      [3:0]    csps_yuv420_8b_odd_even_line               ;
  reg                      [3:0]    csps_yuv420_10b_odd_even_line              ;
  reg                      [3:0]    yuv422_8b_odd_even_line                    ; 
  reg                      [3:0]    yuv422_10b_odd_even_line                   ; 
  reg                     [31:0]    rand_data                                  ;
  reg                      [7:0]    rand_data1                                 ;
  reg                      [7:0]    rand_data2                                 ;
  reg                      [7:0]    rand_data3                                 ;
  reg                      [7:0]    rand_data4                                 ;
  reg                               pixel_width_calc                           ;
  reg                               rgb444_en                                  ;
  reg                               rgb555_en                                  ;
  reg                               rgb565_en                                  ;
  reg                               rgb666_en                                  ;
  reg                               rgb888_en                                  ;
  reg                               raw6_en                                    ;
  reg                               raw7_en                                    ;
  reg                               raw8_en                                    ;
  reg                               gen_null                                   ;
  reg                               gen_blank                                  ;
  reg                               gen_emb                                    ;
  reg                               raw10_en                                   ;
  reg                               raw12_en                                   ;
  reg                               raw14_en                                   ;
  reg                               yuv422_8b_en                               ;
  reg                               yuv422_10b_en                              ;
  reg                               yuv420_8b_en                               ;
  reg                               yuv420_10b_en                              ;
  reg                               leg_yuv420_8b_en                           ;
  reg                               yuv420_8b_csps                             ;
  reg                               yuv420_10b_csps                            ;
  reg                               usd_8b_dt1_en                              ;
  reg                               usd_8b_dt2_en                              ;
  reg                               usd_8b_dt3_en                              ;
  reg                               usd_8b_dt4_en                              ;
  reg                               usd_8b_dt5_en                              ;
  reg                               usd_8b_dt6_en                              ;
  reg                               usd_8b_dt7_en                              ;
  reg                               usd_8b_dt8_en                              ;
  reg                               comp_10_6_10                               ;
  reg                               comp_10_7_10                               ;
  reg                               comp_10_8_10                               ;
  reg                               comp_12_6_12                               ;
  reg                               comp_12_7_12                               ;
  reg                               comp_12_8_12                               ;
  reg                     [31:0]    csi_clk_freq_s                             ;
  reg                     [31:0]    pixel_format                               ;
  reg			                          bandwidth_2k_enable                        ;
  reg			                          bandwidth_4k_enable                        ;
  reg			                          bandwidth_8k_enable                        ;
  reg			                          bandwidth_16k_enable                       ;
  reg			                          bandwidth_32k_enable                       ;
  reg			                          bandwidth_64k_enable                       ;
  reg                               clk_freq_chk                               ;
  reg                               error_flag                                 ;
  reg                      [2:0]    lan_index                                  ;
  reg                               lane_index_en                              ; 
  reg                               data_fill_enable                           ;
  reg                               data_ff_fill_enable                        ;
  reg                               data_oo_fill_enable                        ;
  reg                               data_toggle_fill_enable                    ;
  reg                               toggle_data                                ;
  reg                     [31:0]    data_val                                   ;
  reg                               sync_en                                    ;

 
  wire                     [2:0]    lane_index                                 ; 

  real                              t                                          ;
  real                              t1                                         ;
  real                              t2                                         ;
  real                              freq_chk                                   ;
  real                              byteclk_freq                               ;

  integer                           min_byte                                   ;
  integer                           odd_even_cnt                               ;
  integer                           count                                      ;
  integer                           data_count                                 ;
  integer                           pixel_count                                ;
  integer                           pixel_count1                               ;
  integer                           rand_data_seed                             ;
  integer                           generic_long_cnt                           ;
  //integer                           yuv_cnt                                    ;
  //integer                           rgb_cnt                                    ;
  //integer                      user_cnt;
  integer                           gen_cnt                                    ;
  integer                           gen_dmp_cnt                                ;
  integer                           int_cou_pointer2                           ;
  integer                           n                                          ;
  integer                           i_mem                                      ;
  integer                           compress_cnt                               ;
  integer                           timing_register                            ;

  /*---------------------------------------------------------------------------
    Initalization
  ---------------------------------------------------------------------------*/
  initial
    begin
      odd_even_cnt              		  = 0;
      odd_even_line             		  = 1'b0;
      yuv420_8b_odd_even_line  		    = 4'd0; 
      yuv420_10b_odd_even_line 		    = 4'd0; 
      lyuv420_8b_odd_even_line 		    = 4'd0; 
      csps_yuv420_8b_odd_even_line 	  = 4'd0;
      csps_yuv420_10b_odd_even_line 	= 4'd0;
      yuv422_8b_odd_even_line 		    = 4'd0; 
      yuv422_10b_odd_even_line 		    = 4'd0; 
      rand_data_seed            	    = 32'h87654321;
      packet_wc_df              	    = 16'b0;
      actual_pkt_size          		    = 16'b0;
      sig_pixel_count           	    = 16'd0;
      vir_channel               	    = 2'b0;
      data_type                 	    = 6'b0;
      gen_long_pkt_en           	    = 1'b0;
      generic_long_cnt         	 	    = 1'b0;
      csi_tx_pix_en         		      = 1'b0;
      //yuv_cnt                   	    = 1'b0;
      //rgb_cnt                   	    = 1'b0;
      //user_cnt                  	= 1'b0;
      user_def_pkt_en          	 	    = 1'b0;
      gen_def_pkt_en           		    = 1'b0;
      pkt_drop_en           	        = 1'b0;
      yuv_pak_en           		        = 1'b0;
      rgb_pak_en           		        = 1'b0;
      raw_pak_en           		        = 1'b0;
      compression_en            	    = 1'b0;
      dec_10_bit                	    = 1'b0;
      dec_12_bit                	    = 1'b0;
      Xdeco12_2_monitor         	    = 12'd0;
      Xdeco10_2_monitor         	    = 10'd0;
      csi_data_tx               	    = 8'b0;
      long_packet_en            	    = 1'b0;
      //no_of_bytes              	     	= 16'h0;
      random_en                		    = 1'b0;
      rand_wc                   	    = 16'd0;
      rand_wc_op                	    = 16'd0;
      min_val_wc                	    = 40'd0;
     tx_skewcallhs                      = 1'b0;
      max_val_wc                	    = 40'd0;
      rand_wc_comp              	    = 16'd0;
      rand_wc_op_comp           	    = 16'd0;
      min_val_wc_comp           	    = 40'd0;
      n                         	    = 32'd0;
      i_mem                     	    = 32'd0;
      dec_2_monitor             	    = 1'b0;
      rand_data                	 	    = 1'b0;
      count                     	    = 0;
      data_count                      = 1;
      pixel_count               	    = 1'b0;
      pixel_count1              	    = 1'b0;
      packet_data              		    = 32'h0;
      raw_data_out             	      = 32'h0;
      shft_tx_data1             	    = 32'h0;
      short_packet_en           	    = 1'b0;
      gen_sht_pkt_en           		    = 1'b0;
      gen_dmp_cnt               	    = 1'b0;
      gen_data_tx              		    = 18'h0;
      csi_end_of_file           	    = 1'b0;
      packet_valid              	    = 1'b0;
      fs                     		      = 1'b0;
      fe                     		      = 1'b0;
      ls                     		      = 1'b0;
      le                     		      = 1'b0;
      packet_data_valid     		      = 1'b0;
      packet_vc           		        = 2'b0;
      packet_dt              		      = 6'h0;
      shft_tx_data             	 	    = 8'h0;
      wait_pak_en               	    = 1'b0;
      forcetxstopmode           	    = 1'b0;
      txulpsexit               		    = 1'b0;
      dphy_clk_mode             	    = 1'b0;
      loopack_sel               	    = 1'b0;
      txulpsesc              		      = 1'b0;
      master_pin               		    = 1'b1;
      test_mode                		    = 1'b0;
      temp_prediction           	    = 2'd0;
      tx_cnt 				                  = 0;
      pixel_width_calc 			          = 0;
      rgb444_en 			 			 			    = 0;
      rgb555_en 			 			 			    = 0;
      rgb565_en 			 			 			    = 0;
      rgb666_en 			 			 			    = 0;
      rgb888_en 			 			 			    = 0;
      raw6_en 			 				 			    = 0;
      raw7_en 			 				 			    = 0;
      raw8_en 			 				 			    = 0;
      gen_null 			 				 			    = 0;
      gen_blank			 				 			    = 0;
      gen_emb 				 			 			    = 0;
      raw10_en 				 			 			    = 0;
      raw12_en 				 			 			    = 0;
      raw14_en 				 			 			    = 0;  
      yuv422_8b_en		 			 			    = 0;
      yuv422_10b_en 			 			      = 0;
      yuv420_8b_en 			   			      = 0;
      yuv420_10b_en 			 			      = 0;
      leg_yuv420_8b_en 		 				    = 0;
      yuv420_8b_csps 			 			      = 0;
      yuv420_10b_csps 			 			    = 0;
      usd_8b_dt1_en     		 			    = 0;
      usd_8b_dt2_en     		 			    = 0;
      usd_8b_dt3_en     		 			    = 0;
      usd_8b_dt4_en 			 			      = 0;
      usd_8b_dt5_en 			 			      = 0;
      usd_8b_dt6_en 			 			      = 0;
      usd_8b_dt7_en 			 			      = 0;
      usd_8b_dt8_en 			 			      = 0;
      comp_10_6_10  			 			      = 0;
      comp_10_7_10  			 			      = 0;
      comp_10_8_10  			 			      = 0;
      comp_12_6_12  			 			      = 0;
      comp_12_7_12  			 			      = 0;
      comp_12_8_12  			 			      = 0;
      pixel_width 			   			      = 8;
      pixel_format 			   			      = 1;
      bandwidth_2k_enable  			      = 0;
      bandwidth_4k_enable  			      = 0;
      bandwidth_8k_enable             = 0;
      bandwidth_16k_enable            = 0;
      bandwidth_32k_enable            = 0;
      bandwidth_64k_enable            = 0;
      error_flag                      = 0;
      lan_index                       = 3'h0;
      lane_index_en                   = 1'b0;
      data_fill_enable                = 1'b0;
      data_ff_fill_enable             = 1'b0;
      data_oo_fill_enable             = 1'b0;
      data_toggle_fill_enable         = 1'b0;
      toggle_data                     = 1'b0;
      data_val                        = 32'hffff;
      sync_en                         = 1'b0;
      pkt_interface_cmd;
    end


  `include "pkt_interface_cmd.v"


  `ifdef RANDOM_TIMING
    assign   timing_register =  $random % 10; 
  `else 
    assign   timing_register = `TIMING_REG ;
  `endif 

  /*---------------------------------------------------------------------------
    BLOCK TO INFORM WHICH PIXEL MODE IS ENABLED FOR THE PATICULAR DATA TYPE 
  ---------------------------------------------------------------------------*/
  always@(*)
    begin
      if(raw6_en) begin
        if(raw_image_data_type[1:0] == 2'b00)
          pixel_format = 1;
        else if(raw_image_data_type[1:0] == 2'b01)
          pixel_format = 2;
        else if(raw_image_data_type[1:0] == 2'b10)
          pixel_format = 3;
        else if(raw_image_data_type[1:0] == 2'b11)
          pixel_format = 4;
 
        $display ($time,"\tCSI2 PKT INTERFACE BFM : RAW6 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(raw7_en) begin
        if(raw_image_data_type[3:2] == 2'b00)
          pixel_format = 1;
        else if(raw_image_data_type[3:2] == 2'b01)
          pixel_format = 2;
        else if(raw_image_data_type[3:2] == 2'b10)
          pixel_format = 3;
        else if(raw_image_data_type[3:2] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : RAW7 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(raw8_en) begin
         if(raw_image_data_type[5:4] == 2'b00)
           pixel_format = 1;
         else if(raw_image_data_type[5:4] == 2'b01)
           pixel_format = 2;
         else if(raw_image_data_type[5:4] == 2'b10)
           pixel_format = 3;
         else if(raw_image_data_type[5:4] == 2'b11)
           pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : RAW8 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(raw10_en) begin
        if(raw_image_data_type[7:6] == 2'b00)
          pixel_format = 1;
        else if(raw_image_data_type[7:6] == 2'b01)
          pixel_format = 2;
        else if(raw_image_data_type[7:6] == 2'b10)
          pixel_format = 3;
        else if(raw_image_data_type[7:6] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : RAW10 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(raw12_en) begin
        if(raw_image_data_type[9:8] == 2'b00)
          pixel_format = 1;
        else if(raw_image_data_type[9:8] == 2'b01)
          pixel_format = 2;
        else if(raw_image_data_type[9:8] == 2'b10)
          pixel_format = 3;
        else if(raw_image_data_type[9:8] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : RAW12 PIXEL FORMAT = %d\n",pixel_format);
      end
        
      if(raw14_en) begin
         if(raw_image_data_type[11:10] == 2'b00)
           pixel_format = 1;
         else if(raw_image_data_type[11:10] == 2'b01)
           pixel_format = 2;
         else if(raw_image_data_type[11:10] == 2'b10)
           pixel_format = 3;
         else if(raw_image_data_type[11:10] == 2'b11)
           pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : RAW14 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(rgb444_en) begin
        if(rgb_image_data_type[1:0] == 2'b00)
          pixel_format = 1;
        else if(rgb_image_data_type[1:0] == 2'b01)
          pixel_format = 2;
        else if(rgb_image_data_type[1:0] == 2'b10)
          pixel_format = 3;
        else if(rgb_image_data_type[1:0] == 2'b11)
          pixel_format = 4;
 
        $display ($time,"\tCSI2 PKT INTERFACE BFM : RGB444 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(rgb555_en) begin
        if(rgb_image_data_type[3:2] == 2'b00)
          pixel_format = 1;
        else if(rgb_image_data_type[3:2] == 2'b01)
          pixel_format = 2;
        else if(rgb_image_data_type[3:2] == 2'b10)
          pixel_format = 3;
        else if(rgb_image_data_type[3:2] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : RGB555 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(rgb565_en) begin
        if(rgb_image_data_type[5:4] == 2'b00)
          pixel_format = 1;
        else if(rgb_image_data_type[5:4] == 2'b01)
          pixel_format = 2;
        else if(rgb_image_data_type[5:4] == 2'b10)
          pixel_format = 3;
        else if(rgb_image_data_type[5:4] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : RGB565 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(rgb666_en) begin
        if(rgb_image_data_type[7:6] == 2'b00)
          pixel_format = 1;
        else if(rgb_image_data_type[7:6] == 2'b01)
          pixel_format = 2;
        else if(rgb_image_data_type[7:6] == 2'b10)
          pixel_format = 3;
        else if(rgb_image_data_type[7:6] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : RGB666 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(rgb888_en) begin
        if(rgb_image_data_type[9:8] == 2'b00)
          pixel_format = 1;
        else if(rgb_image_data_type[9:8] == 2'b01)
          pixel_format = 2;
        else if(rgb_image_data_type[9:8] == 2'b10)
          pixel_format = 3;
        else if(rgb_image_data_type[9:8] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : RGB888 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(yuv420_8b_en) begin
        if(yuv_image_data_type[1:0] == 2'b00)
          pixel_format = 1;
        else if(yuv_image_data_type[1:0] == 2'b01)
          pixel_format = 2;
        else if(yuv_image_data_type[1:0] == 2'b10)
          pixel_format = 3;
        else if(yuv_image_data_type[1:0] == 2'b11)
          pixel_format = 4;
 
        $display ($time,"\tCSI2 PKT INTERFACE BFM : YUV420 8-bit ODD PIXEL FORMAT = %d\n",pixel_format);
      end

      if(yuv420_8b_en) begin
        if(yuv_image_data_type[3:2] == 2'b00)
          pixel_format = 1;
        else if(yuv_image_data_type[3:2] == 2'b01)
          pixel_format = 2;
        else if(yuv_image_data_type[3:2] == 2'b10)
          pixel_format = 3;
        else if(yuv_image_data_type[3:2] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : YUV420 8-bit EVEN PIXEL FORMAT = %d\n",pixel_format);
      end

      if(yuv420_10b_en) begin
        if(yuv_image_data_type[5:4] == 2'b00)
          pixel_format = 1;
        else if(yuv_image_data_type[5:4] == 2'b01)
          pixel_format = 2;
        else if(yuv_image_data_type[5:4] == 2'b10)
          pixel_format = 3;
        else if(yuv_image_data_type[5:4] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : YUV420 10-bit ODD PIXEL FORMAT = %d\n",pixel_format);
      end

      if(yuv420_10b_en) begin
        if(yuv_image_data_type[7:6] == 2'b00)
          pixel_format = 1;
        else if(yuv_image_data_type[7:6] == 2'b01)
          pixel_format = 2;
        else if(yuv_image_data_type[7:6] == 2'b10)
          pixel_format = 3;
        else if(yuv_image_data_type[7:6] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : YUV420 10-EVEN PIXEL FORMAT = %d\n",pixel_format);
      end

      if(leg_yuv420_8b_en) begin
        if(yuv_image_data_type[9:8] == 2'b00)
          pixel_format = 1;
        else if(yuv_image_data_type[9:8] == 2'b01)
          pixel_format = 2;
        else if(yuv_image_data_type[9:8] == 2'b10)
          pixel_format = 3;
        else if(yuv_image_data_type[9:8] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : LEGACY YUV420 8-bit ODD PIXEL FORMAT = %d\n",pixel_format);
      end

      if(leg_yuv420_8b_en) begin
        if(yuv_image_data_type[11:10] == 2'b00)
          pixel_format = 1;
        else if(yuv_image_data_type[11:10] == 2'b01)
          pixel_format = 2;
        else if(yuv_image_data_type[11:10] == 2'b10)
          pixel_format = 3;
        else if(yuv_image_data_type[11:10] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : LEGACY YUV420 8-bit EVEN PIXEL FORMAT = %d\n",pixel_format);
      end


      if(yuv420_8b_csps) begin
         if(yuv_image_data_type[13:12] == 2'b00)
           pixel_format = 1;
         else if(yuv_image_data_type[13:12] == 2'b01)
           pixel_format = 2;
         else if(yuv_image_data_type[13:12] == 2'b10)
           pixel_format = 3;
         else if(yuv_image_data_type[13:12] == 2'b11)
           pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : YUV420 8-bit CSPS ODD PIXEL FORMAT = %d\n",pixel_format);
      end

      if(yuv420_8b_csps) begin
         if(yuv_image_data_type[15:14] == 2'b00)
           pixel_format = 1;
         else if(yuv_image_data_type[15:14] == 2'b01)
           pixel_format = 2;
         else if(yuv_image_data_type[15:14] == 2'b10)
           pixel_format = 3;
         else if(yuv_image_data_type[15:14] == 2'b11)
           pixel_format = 4;

         $display ($time,"\tCSI2 PKT INTERFACE BFM : YUV420 8-bit CSPS EVEN PIXEL FORMAT = %d\n",pixel_format);
      end


      if(yuv420_10b_csps) begin
         if(yuv_image_data_type[17:16] == 2'b00)
           pixel_format = 1;
         else if(yuv_image_data_type[17:16] == 2'b01)
           pixel_format = 2;
         else if(yuv_image_data_type[17:16] == 2'b10)
           pixel_format = 3;
         else if(yuv_image_data_type[17:16] == 2'b11)
           pixel_format = 4;

         $display ($time,"\tCSI2 PKT INTERFACE BFM :YUV420 10-bit CSPS ODD PIXEL FORMAT = %d\n",pixel_format);
      end

      if(yuv420_10b_csps) begin
         if(yuv_image_data_type[19:18] == 2'b00)
           pixel_format = 1;
         else if(yuv_image_data_type[19:18] == 2'b01)
           pixel_format = 2;
         else if(yuv_image_data_type[19:18] == 2'b10)
           pixel_format = 3;
         else if(yuv_image_data_type[19:18] == 2'b11)
           pixel_format = 4;

         $display ($time,"\tCSI2 PKT INTERFACE BFM : YUV420 10-bit CSPS EVEN PIXEL FORMAT = %d\n",pixel_format);
      end


      if(yuv422_8b_en) begin
         if(yuv_image_data_type[21:20] == 2'b00)
           pixel_format = 1;
         else if(yuv_image_data_type[21:20] == 2'b01)
           pixel_format = 2;
         else if(yuv_image_data_type[21:20] == 2'b10)
           pixel_format = 3;
         else if(yuv_image_data_type[21:20] == 2'b11)
           pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : YUV422 8-bit PIXEL FORMAT = %d\n",pixel_format);
      end

      if(yuv422_10b_en) begin
         if(yuv_image_data_type[23:22] == 2'b00)
           pixel_format = 1;
         else if(yuv_image_data_type[23:22] == 2'b01)
           pixel_format = 2;
         else if(yuv_image_data_type[23:22] == 2'b10)
           pixel_format = 3;
         else if(yuv_image_data_type[23:22] == 2'b11)
           pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : YUV422 10-bit PIXEL FORMAT = %d\n",pixel_format);
      end

      if(usd_8b_dt1_en) begin
         if(usd_data_type_reg[1:0] == 2'b00)
           pixel_format = 1;
         else if(usd_data_type_reg[1:0] == 2'b01)
           pixel_format = 2;
         else if(usd_data_type_reg[1:0] == 2'b10)
           pixel_format = 3;
         else if(usd_data_type_reg[1:0] == 2'b11)
           pixel_format = 4;
 
        $display ($time,"\tCSI2 PKT INTERFACE BFM : USER DEFINED DATA TYPE1 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(usd_8b_dt2_en) begin
        if(usd_data_type_reg[3:2] == 2'b00)
          pixel_format = 1;
        else if(usd_data_type_reg[3:2] == 2'b01)
          pixel_format = 2;
        else if(usd_data_type_reg[3:2] == 2'b10)
          pixel_format = 3;
        else if(usd_data_type_reg[3:2] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM :USER DEFINED DATA TYPE2 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(usd_8b_dt3_en) begin
        if(usd_data_type_reg[5:4] == 2'b00)
          pixel_format = 1;
        else if(usd_data_type_reg[5:4] == 2'b01)
          pixel_format = 2;
        else if(usd_data_type_reg[5:4] == 2'b10)
          pixel_format = 3;
        else if(usd_data_type_reg[5:4] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : USER DEFINED DATA TYPE3 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(usd_8b_dt4_en) begin
        if(usd_data_type_reg[7:6] == 2'b00)
          pixel_format = 1;
        else if(usd_data_type_reg[7:6] == 2'b01)
          pixel_format = 2;
        else if(usd_data_type_reg[7:6] == 2'b10)
          pixel_format = 3;
        else if(usd_data_type_reg[7:6] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : USER DEFINED DATA TYPE4 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(usd_8b_dt5_en) begin
         if(usd_data_type_reg[9:8] == 2'b00)
           pixel_format = 1;
         else if(usd_data_type_reg[9:8] == 2'b01)
           pixel_format = 2;
         else if(usd_data_type_reg[9:8] == 2'b10)
           pixel_format = 3;
         else if(usd_data_type_reg[9:8] == 2'b11)
           pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : USER DEFINED DATA TYPE5 PIXEL FORMAT = %d\n",pixel_format);
      end
        
      if(usd_8b_dt6_en) begin
        if(usd_data_type_reg[11:10] == 2'b00)
          pixel_format = 1;
        else if(usd_data_type_reg[11:10] == 2'b01)
          pixel_format = 2;
        else if(usd_data_type_reg[11:10] == 2'b10)
          pixel_format = 3;
        else if(usd_data_type_reg[11:10] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : USER DEFINED DATA TYPE6 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(usd_8b_dt7_en) begin
        if(usd_data_type_reg[13:12] == 2'b00)
          pixel_format = 1;
        else if(usd_data_type_reg[13:12] == 2'b01)
          pixel_format = 2;
        else if(usd_data_type_reg[13:12] == 2'b10)
          pixel_format = 3;
        else if(usd_data_type_reg[13:12] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : USER DEFINED DATA TYPE7 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(usd_8b_dt8_en) begin
         if(usd_data_type_reg[15:14] == 2'b00)
           pixel_format = 1;
         else if(usd_data_type_reg[15:14] == 2'b01)
           pixel_format = 2;
         else if(usd_data_type_reg[15:14] == 2'b10)
           pixel_format = 3;
         else if(usd_data_type_reg[15:14] == 2'b11)
           pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : USER DEFINED DATA TYPE8 PIXEL FORMAT = %d\n",pixel_format);
      end

      if(gen_null) begin
        if(generic_8_bit_long_pkt_data_type[1:0] == 2'b00)
          pixel_format = 1;
        else if(generic_8_bit_long_pkt_data_type[1:0] == 2'b01)
          pixel_format = 2;
        else if(generic_8_bit_long_pkt_data_type[1:0] == 2'b10)
          pixel_format = 3;
        else if(generic_8_bit_long_pkt_data_type[1:0] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM :GENERIC NULL PIXEL FORMAT = %d\n",pixel_format);
      end

      if(gen_blank) begin
        if(generic_8_bit_long_pkt_data_type[3:2] == 2'b00)
          pixel_format = 1;
        else if(generic_8_bit_long_pkt_data_type[3:2] == 2'b01)
          pixel_format = 2;
        else if(generic_8_bit_long_pkt_data_type[3:2] == 2'b10)
          pixel_format = 3;
        else if(generic_8_bit_long_pkt_data_type[3:2] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : GENERIC BLANK PIXEL FORMAT = %d\n",pixel_format);
      end

      if(gen_emb) begin
        if(generic_8_bit_long_pkt_data_type[5:4] == 2'b00)
          pixel_format = 1;
        else if(generic_8_bit_long_pkt_data_type[5:4] == 2'b01)
          pixel_format = 2;
        else if(generic_8_bit_long_pkt_data_type[5:4] == 2'b10)
          pixel_format = 3;
        else if(generic_8_bit_long_pkt_data_type[5:4] == 2'b11)
          pixel_format = 4;

        $display ($time,"\tCSI2 PKT INTERFACE BFM : GENERIC EMBEDEDD PIXEL FORMAT = %d\n",pixel_format);
      end 
    end

  always@(packet_rdy or packet_data_rdy)
    begin
      if(packet_rdy || packet_data_rdy)
        wait_pak_en = 1'b1;
    end

  always@(posedge clk_csi)
    begin
      @(posedge clk_csi);
      t1 = $time;

      @(posedge clk_csi);
      t2 = $time;
      t = t2 -t1;
      freq_chk = 1000/t;

      @(posedge clk_csi);
      clk_freq_chk = 1'b0;
    end

  always@(negedge clk_freq_chk)
    begin
      if (packet_rdy) begin
        if(freq_chk == csi_clk_freq)
          $display($time,"\tCSI2 PKT INTERFACE BFM : TIMING CLK FREQUENCY IN CLK1 CLK2 %t",freq_chk);
        else begin
          error_flag =1'b1;
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - TIMING CLK FREQUENCY IN CLK1 CLK2 %t",freq_chk);
        end
      end
    end

  /*----------------------------------------------------------------------------
     POWER ON RESET
  ----------------------------------------------------------------------------*/
  task pwr_rst;
    begin:power_on_reset
      command = "power_on_reset";
      device_ready_t =1'b0;
			wait(!reset_clk_csi_n);
			wait(reset_clk_csi_n);
      
      $display ($time,"\tCSI2 PKT INTERFACE BFM : POWER ON RESET IS ISSUED\n"); 

      device_ready_t =1'b1;
     
      wait(test_env.u_csi2tx_ahb_master_model_inst.init_enable == 1'b0 || test_env.u_csi2tx_ahb_master_model_inst.pre_init_test == 1'b1);
      
      wait(test_env.u_csi2tx_ahb_master_model_inst.ahb_cfg_comp == 1'b1);

      #100000;
 
      `ifdef TIMESCALE_NS
        #1000;
      `else
        #100000;
      `endif
    end
  endtask

  /*----------------------------------------------------------------------------
     FORCETXSTOP STATE
  ----------------------------------------------------------------------------*/
  task forcetxstop_state;
    input sig_forcetxstopmode;
    begin
      command = "forcetxstop_state";
      forcetxstopmode = sig_forcetxstopmode;
   
    if(forcetxstopmode)
      begin
        disable send_synch_sh_pkt;
        disable send_user_def_data;
    	  wait(stopstate_dat_0);
        @(posedge test_env.u_csi2tx_mipi_top.txbyteclkhs);
        @(posedge test_env.u_csi2tx_mipi_top.txbyteclkhs);
        @(posedge test_env.u_csi2tx_mipi_top.txbyteclkhs);
        forcetxstopmode = 1'b0;
      wait(test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_lane_distribution_top.forcetxstopmode == 1'b0);
      end
    end
  endtask

  //DELAY COMMAND TASK
  task delay;
    input [31:0]delay_count;
    begin
      for(int_cou_pointer2 = 0 ; int_cou_pointer2 < delay_count ;
        int_cou_pointer2 = int_cou_pointer2+1)
      begin
        @(posedge clk_csi);
      end
    end
  endtask


  task master_pin_sel;
    input sig_master_pin;
    begin
      command = "mater_pin_sel";
      master_pin = sig_master_pin;
    end
  endtask

  /*----------------------------------------------------------------------------
     TXULPSESC VALUE TASK
  ----------------------------------------------------------------------------*/
  task txulpsesc_val;
    input txulps;
    begin
      command = "txulpsesc_val";
      wait(stopstate_dat_0);
      @(posedge test_env.txclkesc)
      txulpsesc = txulps;
    end
  endtask

  /*----------------------------------------------------------------------------
     TXULPSEXIT VALUE TASK
  ----------------------------------------------------------------------------*/
  task txulpsexit_val;
    input ulpsexit;
    begin
      @(posedge test_env.txclkesc)
      if(txulpsesc) begin
        `ifdef TIMESCALE_EN
        #100000;
        `else
        #1000000;
        `endif
      end
        txulpsexit = ulpsexit;
     if(txulpsesc) begin
        `ifdef TIMESCALE_EN
        #10000;
        `else
        #1000000;
        `endif
      end
       @(posedge test_env.txclkesc)
        txulpsesc = 1'b0;
        txulpsexit = 1'b0;
    end
  endtask


  /*----------------------------------------------------------------------------
     DPHY CLOCK MODE VALUE TASK
  ----------------------------------------------------------------------------*/
  task dphy_clk_mode_val;
    input clk_mode;
    begin
      command = "dphy_clk_mode_val";
      dphy_clk_mode = clk_mode;
    end
  endtask
 
  /*----------------------------------------------------------------------------
     LOOPACK MODE TASK
  ----------------------------------------------------------------------------*/
  task loopack_mode;
    input loopack;
    begin
      command = "loopack";
      loopack_sel = loopack;
    end
  endtask


  always@(*)
    begin
      ////RAW DATA TYPE////////
      if(data_type == 6'h28 && packet_data_rdy) begin
        if(raw_image_data_type[1:0] == 2'b00) begin
           raw_data_out <= {26'b0,packet_data[5:0]};
           actual_pkt_size <= (packet_wc_df*8)/6;
        end else if (raw_image_data_type[1:0] == 2'b01) begin
          raw_data_out <= {20'b0,packet_data[11:0]};
          actual_pkt_size <= (packet_wc_df*8)/12;
        end else if (raw_image_data_type[1:0] == 2'b10) begin
          if(((packet_wc_df*8)%18) == 0) begin
            raw_data_out <= {14'b0,packet_data[17:0]};
            actual_pkt_size <= (packet_wc_df*8)/18;
          end else if(((packet_wc_df*8)%18) != 0) begin
            raw_data_out <= {14'b0,packet_data[17:0]};
            actual_pkt_size <= ((packet_wc_df*8)/18) + 1;
          end
         end
        else if (raw_image_data_type[1:0] == 2'b11)
         begin
           raw_data_out <= {8'b0,packet_data[23:0]};
           actual_pkt_size <= (packet_wc_df*8)/24;
         end
       end
    else if(data_type == 6'h29 && packet_data_rdy)
      begin
        if(raw_image_data_type[3:2] == 2'b00)
         begin
            raw_data_out <= {25'b0,packet_data[6:0]};        
            actual_pkt_size <= (packet_wc_df*8)/7;
         end
        else if (raw_image_data_type[3:2] == 2'b01)
         begin
           raw_data_out <= {18'b0,packet_data[13:0]};
           actual_pkt_size <= (packet_wc_df*8)/14;
         end
        else if (raw_image_data_type[3:2] == 2'b10)
         begin
            if(((packet_wc_df*8)%21) == 0)
            begin
            raw_data_out <= {11'b0,packet_data[20:0]};
            actual_pkt_size <= (packet_wc_df*8)/21;
            end
            else if(((packet_wc_df*8)%21) != 0)
            begin
            raw_data_out <= {11'b0,packet_data[20:0]};
            actual_pkt_size <= ((packet_wc_df*8)/21) + 1;
            end
         end
        else if (raw_image_data_type[3:2] == 2'b11)
         begin
           raw_data_out <= {4'b0,packet_data[27:0]};
           actual_pkt_size <= (packet_wc_df*8)/28;
         end
       end
   else if(data_type == 6'h2a && packet_data_rdy)
      begin
        if(raw_image_data_type[5:4] == 2'b00)
         begin
           raw_data_out <= {24'b0,packet_data[7:0]};      
           actual_pkt_size <= (packet_wc_df*8)/8;
         end
        else if (raw_image_data_type[5:4] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
         end
        else if (raw_image_data_type[5:4] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
         end
        else if (raw_image_data_type[5:4] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
         end
       end 
  else if(data_type == 6'h2b && packet_data_rdy)
      begin
        if(raw_image_data_type[7:6] == 2'b00)
         begin
           raw_data_out <= {22'b0,packet_data[9:0]};      
           actual_pkt_size <= (packet_wc_df*8)/10;
         end
        else if (raw_image_data_type[7:6] == 2'b01)
         begin
           raw_data_out <= {12'b0,packet_data[19:0]};
           actual_pkt_size <= (packet_wc_df*8)/20;
         end
        else if (raw_image_data_type[7:6] == 2'b10)
         begin
            if(((packet_wc_df*8)%30) == 0)
            begin
            raw_data_out <= {2'b0,packet_data[29:0]};
            actual_pkt_size <= (packet_wc_df*8)/30;
            end
            else if(((packet_wc_df*8)%30) != 0)
            begin
            raw_data_out <= {2'b0,packet_data[29:0]};
            actual_pkt_size <= ((packet_wc_df*8)/30) + 1;
            end
         end
        else if (raw_image_data_type[7:6] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RAW 10 FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end
    else if(data_type == 6'h2c && packet_data_rdy)
      begin
        if(raw_image_data_type[9:8] == 2'b00)
         begin
           raw_data_out <= {20'b0,packet_data[11:0]};      
           actual_pkt_size <= (packet_wc_df*8)/12;
         end
        else if (raw_image_data_type[9:8] == 2'b01)
         begin
           raw_data_out <= {8'b0,packet_data[23:0]};
           actual_pkt_size <= (packet_wc_df*8)/24;
         end
        else if (raw_image_data_type[9:8] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RAW 12 THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (raw_image_data_type[9:8] == 2'b11)
         begin
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RAW 12 FOUR PIXEL MODE NOT SUPPORTED \n");
         end
    end

   else if(data_type == 6'h2d && packet_data_rdy)
      begin
        if(raw_image_data_type[11:10] == 2'b00)
         begin
           raw_data_out <= {18'b0,packet_data[13:0]};      
           actual_pkt_size <= (packet_wc_df*8)/14;
         end
        else if (raw_image_data_type[11:10] == 2'b01)
         begin
           raw_data_out <= {4'b0,packet_data[27:0]};      
           actual_pkt_size <= (packet_wc_df*8)/28;
         end
        else if (raw_image_data_type[11:10] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RAW 14 THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (raw_image_data_type[11:10] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RAW 14 FOUR PIXEL MODE NOT SUPPORTED \n");
         end
   end 

   ////RGB DATA TYPES//////////////////

   else if(data_type == 6'h20 && packet_data_rdy)
      begin
        if(rgb_image_data_type[1:0] == 2'b00)
         begin
           raw_data_out <= {20'b0,packet_data[11:0]};
           actual_pkt_size <= (packet_wc_df*6)/12;
         end
        else if (rgb_image_data_type[1:0] == 2'b01)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
         end
        else if (rgb_image_data_type[1:0] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 444 THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (rgb_image_data_type[1:0] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 444 FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end
    else if(data_type == 6'h21 && packet_data_rdy)
      begin
        if(rgb_image_data_type[3:2] == 2'b00)
         begin
           raw_data_out <= {17'b0,packet_data[14:0]};
           actual_pkt_size <= (packet_wc_df*7.5)/15;
         end
        else if (rgb_image_data_type[3:2] == 2'b01)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {2'b0,packet_data[29:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {2'b0,packet_data[29:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
         end
        else if (rgb_image_data_type[3:2] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 555 THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (rgb_image_data_type[3:2] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 555 FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end
   else if(data_type == 6'h22 && packet_data_rdy)
      begin
        if(rgb_image_data_type[5:4] == 2'b00)
         begin
           raw_data_out <= {16'b0,packet_data[15:0]};
           actual_pkt_size <= (packet_wc_df*8)/16;
         end
        else if (rgb_image_data_type[5:4] == 2'b01)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
         end
        else if (rgb_image_data_type[5:4] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 565 THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (rgb_image_data_type[5:4] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 565 FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end 
  else if(data_type == 6'h23 && packet_data_rdy)
      begin
        if(rgb_image_data_type[7:6] == 2'b00)
         begin
           raw_data_out <= {6'b0,packet_data[17:0]};
           actual_pkt_size <= (packet_wc_df*8)/18;
         end
        else if (rgb_image_data_type[7:6] == 2'b01)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 666 THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (rgb_image_data_type[7:6] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 666 THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (rgb_image_data_type[7:6] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 666 FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end
    else if(data_type == 6'h24 && packet_data_rdy)
      begin
        if(rgb_image_data_type[9:8] == 2'b00)
         begin
           raw_data_out <= {7'b0,packet_data[23:0]};
           actual_pkt_size <= (packet_wc_df*8)/24;
         end
        else if (rgb_image_data_type[9:8] == 2'b01)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 888 THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (rgb_image_data_type[9:8] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 888 THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (rgb_image_data_type[9:8] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - RGB 888 FOUR PIXEL MODE NOT SUPPORTED \n");
         end
    end

 
   ////YUV DATA TYPE////////
  ///////////YUV-420 8 BIT/////////////////////
  else if(data_type == 6'h18 && packet_data_rdy)
      begin
     if(!odd_even_line) 			// 0- for odd line, 1- for even line
      begin
        if(yuv_image_data_type[1:0] == 2'b00)
         begin
          raw_data_out <= {24'b0,packet_data[7:0]};
          actual_pkt_size <= (packet_wc_df*8)/8;
         end
        else if (yuv_image_data_type[1:0] == 2'b01)
         begin
          raw_data_out <= {16'b0,packet_data[15:0]};
          actual_pkt_size <= (packet_wc_df*8)/16;
         end
        else if (yuv_image_data_type[1:0] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
         end
        else if (yuv_image_data_type[1:0] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
         end
       end
    else if(odd_even_line)
      begin
        if(yuv_image_data_type[3:2] == 2'b00)
         begin
           raw_data_out <= {8'b0,packet_data[23:16],packet_data[15:8],packet_data[7:0]};
           actual_pkt_size <= (packet_wc_df*8)/16;
         end
        else if (yuv_image_data_type[3:2] == 2'b01)
         begin
          raw_data_out <= packet_data[31:0];
          actual_pkt_size <= (packet_wc_df*8)/32;
         end
        else if (yuv_image_data_type[3:2] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 8 BIT AND YUV 420 8 BIT CHROMA EVEN LINE THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (yuv_image_data_type[3:2] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 8 BIT AND YUV 420 8 BIT CHROMA EVEN LINE FOUR PIXEL MODE NOT SUPPORTED \n");
         end

       end
    end

  ///////////YUV-420 10 BIT/////////////////////
    else if(data_type == 6'h19 && packet_data_rdy)
      begin
     if(!odd_even_line) 			// 0- for odd line, 1- for even line
      begin
        if(yuv_image_data_type[5:4]  == 2'b00)
         begin
          raw_data_out <= {22'b0,packet_data[9:0]};
          actual_pkt_size <= (packet_wc_df*8)/10;
         end
        else if (yuv_image_data_type[5:4]  == 2'b01)
         begin
          raw_data_out <= {12'b0,packet_data[19:0]};
          actual_pkt_size <= (packet_wc_df*8)/20;
         end
        else if (yuv_image_data_type[5:4]  == 2'b10)
         begin
            if(((packet_wc_df*8)%30) == 0)
            begin
            raw_data_out <= {2'b0,packet_data[29:0]};
            actual_pkt_size <= (packet_wc_df*8)/30;
            end
            else if(((packet_wc_df*8)%30) != 0)
            begin
            raw_data_out <= {2'b0,packet_data[29:0]};
            actual_pkt_size <= ((packet_wc_df*8)/30) + 1;
            end
         end
        else if (yuv_image_data_type[5:4]  == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 10 BIT AND YUV 420 8 BIT CHROMA ODD LINE FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end
    else if(odd_even_line)
      begin
        if(yuv_image_data_type[7:6] == 2'b00)
         begin
           raw_data_out <= {2'b0,packet_data[29:20],packet_data[19:10],packet_data[9:0]};
           actual_pkt_size <= (packet_wc_df*8)/20;
         end
       else if (yuv_image_data_type[7:6] == 2'b01)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 10 BIT AND YUV 420 8 BIT CHROMA EVEN LINE TWO PIXEL MODE NOT SUPPORTED \n");
         end
       else if (yuv_image_data_type[7:6] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 10 BIT AND YUV 420 8 BIT CHROMA EVEN LINE THREE PIXEL MODE NOT SUPPORTED \n");
         end
       else if (yuv_image_data_type[7:6] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 10 BIT AND YUV 420 8 BIT CHROMA EVEN LINE FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end
    end

  ///////////YUV-420 10 BIT/////////////////////
   else if(data_type == 6'h1a && packet_data_rdy)
      begin
     if(!odd_even_line) 			// 0- for odd line, 1- for even line
       begin
        if(yuv_image_data_type[9:8] == 2'b00)
         begin
           raw_data_out <= {8'b0,packet_data[23:16],packet_data[15:8],packet_data[7:0]};
           actual_pkt_size <= (packet_wc_df*8)/12;
         end
       else if(yuv_image_data_type[9:8] == 2'b01)
         begin
           raw_data_out <=  packet_data[31:0];
           actual_pkt_size <= (packet_wc_df*8)/24;
         end
       else if(yuv_image_data_type[9:8] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - LEGACY YUV 420 8 BIT  BIT ODD LINE THREE PIXEL MODE NOT SUPPORTED \n");
         end
       else if(yuv_image_data_type[9:8] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - LEGACY YUV 420 8 BIT  BIT ODD LINE FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end
    else if(odd_even_line)
      begin
         if(yuv_image_data_type[11:10] == 2'b00)
         begin
           raw_data_out <= {8'b0,packet_data[23:16],packet_data[15:8],packet_data[7:0]};
           actual_pkt_size <= (packet_wc_df*8)/12;
         end
       else if(yuv_image_data_type[11:10] == 2'b01)
         begin
           raw_data_out <=  packet_data[31:0];
           actual_pkt_size <= (packet_wc_df*8)/24;
         end
       else if(yuv_image_data_type[11:10] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - LEGACY YUV 420 8 BIT  BIT ODD LINE THREE PIXEL MODE NOT SUPPORTED \n");
         end
       else if(yuv_image_data_type[11:10] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - LEGACY YUV 420 8 BIT  BIT ODD LINE FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end
    end
 /////////YUV420 8-bit CSPS///////////////////////
  else if(data_type == 6'h1c && packet_data_rdy)
      begin
     if(!odd_even_line) 			// 0- for odd line, 1- for even line
      begin
        if(yuv_image_data_type[13:12] == 2'b00)
         begin
          raw_data_out <= {24'b0,packet_data[7:0]};
          actual_pkt_size <= (packet_wc_df*8)/8;
         end
        else if (yuv_image_data_type[13:12] == 2'b01)
         begin
          raw_data_out <= {16'b0,packet_data[15:0]};
          actual_pkt_size <= (packet_wc_df*8)/16;
         end
        else if (yuv_image_data_type[13:12] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
         end
        else if (yuv_image_data_type[13:12] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
         end
       end
    else if(odd_even_line)
      begin
        if(yuv_image_data_type[15:14] == 2'b00)
         begin
           raw_data_out <= {8'b0,packet_data[23:16],packet_data[15:8],packet_data[7:0]};
           actual_pkt_size <= (packet_wc_df*8)/16;
         end
        else if (yuv_image_data_type[15:14] == 2'b01)
         begin
          raw_data_out <= packet_data[31:0];
          actual_pkt_size <= (packet_wc_df*8)/32;
         end
        else if (yuv_image_data_type[15:14] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 8 BIT AND YUV 420 8 BIT CHROMA EVEN LINE THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if (yuv_image_data_type[15:14] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 8 BIT AND YUV 420 8 BIT CHROMA EVEN LINE FOUR PIXEL MODE NOT SUPPORTED \n");
         end

       end
    end

 /////////YUV420 10-bit CSPS///////////////////////
    else if(data_type == 6'h1d && packet_data_rdy)
      begin
     if(!odd_even_line) 			// 0- for odd line, 1- for even line
      begin
        if(yuv_image_data_type[17:16]  == 2'b00)
         begin
          raw_data_out <= {22'b0,packet_data[9:0]};
          actual_pkt_size <= (packet_wc_df*8)/10;
         end
        else if (yuv_image_data_type[17:16]  == 2'b01)
         begin
          raw_data_out <= {12'b0,packet_data[19:0]};
          actual_pkt_size <= (packet_wc_df*8)/20;
         end
        else if (yuv_image_data_type[17:16]  == 2'b10)
         begin
            if(((packet_wc_df*8)%30) == 0)
            begin
            raw_data_out <= {2'b0,packet_data[29:0]};
            actual_pkt_size <= (packet_wc_df*8)/30;
            end
            else if(((packet_wc_df*8)%30) != 0)
            begin
            raw_data_out <= {2'b0,packet_data[29:0]};
            actual_pkt_size <= ((packet_wc_df*8)/30) + 1;
            end
         end
        else if (yuv_image_data_type[17:16]  == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 10 BIT AND YUV 420 8 BIT CHROMA ODD LINE FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end
    else if(odd_even_line)
      begin
        if(yuv_image_data_type[19:18] == 2'b00)
         begin
           raw_data_out <= {2'b0,packet_data[29:20],packet_data[19:10],packet_data[9:0]};
           actual_pkt_size <= (packet_wc_df*8)/20;
         end
       else if (yuv_image_data_type[19:18] == 2'b01)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 10 BIT AND YUV 420 8 BIT CHROMA EVEN LINE TWO PIXEL MODE NOT SUPPORTED \n");
         end
       else if (yuv_image_data_type[19:18] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 10 BIT AND YUV 420 8 BIT CHROMA EVEN LINE THREE PIXEL MODE NOT SUPPORTED \n");
         end
       else if (yuv_image_data_type[19:18] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 420 10 BIT AND YUV 420 8 BIT CHROMA EVEN LINE FOUR PIXEL MODE NOT SUPPORTED \n");
         end
       end
    end



 /////////YUV422 8-bit ///////////////////////
   else if(data_type == 6'h1e && packet_data_rdy)
      begin
         if(yuv_image_data_type[21:20] == 2'b00)
         begin
           raw_data_out <= {8'b0,packet_data[23:16],packet_data[15:8],packet_data[7:0]};
           actual_pkt_size <= (packet_wc_df*8)/16;
         end
        else if(yuv_image_data_type[21:20] == 2'b01)
         begin
            raw_data_out <= packet_data[31:0];
            actual_pkt_size <= (packet_wc_df*8)/32;
         end
        else if(yuv_image_data_type[21:20] == 2'b10)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 422 8 BIT  BIT ODD LINE THREE PIXEL MODE NOT SUPPORTED \n");
         end
        else if(yuv_image_data_type[21:20] == 2'b11)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 422 8 BIT  BIT ODD LINE FOUR PIXEL MODE NOT SUPPORTED \n");
         end

   end 

 /////////YUV422 10-bit ///////////////////////
   else if(data_type == 6'h1f && packet_data_rdy)
      begin
         if(yuv_image_data_type[23:22]  == 2'b00)
         begin
            raw_data_out <= {3'b0,packet_data[29:0]};
            actual_pkt_size <= (packet_wc_df*8)/20;
         end
        else if(yuv_image_data_type[23:22]  != 2'b00)
         begin
          `display_time
          $display($time,"\tCSI2 PKT INTERFACE BFM : ERROR - YUV 422 10 BIT  BIT ODD LINE TWO/THREE/FOUR PIXEL MODE NOT SUPPORTED \n");
         end
      end

   ////USER DEFINED DATA TYPE////////

   else if (data_type == 6'h30 && packet_data_rdy && (!compression_en))
   begin
      if(usd_data_type_reg [1:0] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(usd_data_type_reg [1:0] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(usd_data_type_reg [1:0] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(usd_data_type_reg [1:0] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end
   else if (data_type == 6'h31 && packet_data_rdy && (!compression_en))
   begin
      if(usd_data_type_reg [3:2] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(usd_data_type_reg[3:2] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(usd_data_type_reg [3:2] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(usd_data_type_reg[3:2] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end

   else if (data_type == 6'h32 && packet_data_rdy && (!compression_en))
   begin
      if(usd_data_type_reg [5:4] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(usd_data_type_reg[5:4] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(usd_data_type_reg[5:4] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(usd_data_type_reg[5:4] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end


   else if (data_type == 6'h33 && packet_data_rdy && (!compression_en))
   begin
      if(usd_data_type_reg [7:6] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(usd_data_type_reg[7:6] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(usd_data_type_reg [7:6] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(usd_data_type_reg[7:6] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end

   else if (data_type == 6'h34 && packet_data_rdy && (!compression_en))
   begin
      if(usd_data_type_reg[9:8] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(usd_data_type_reg[9:8] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(usd_data_type_reg [9:8] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(usd_data_type_reg[9:8] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end

   else if (data_type == 6'h35 && packet_data_rdy && (!compression_en))
   begin
      if(usd_data_type_reg[11:10] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(usd_data_type_reg[11:10] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(usd_data_type_reg[11:10] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(usd_data_type_reg[11:10] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end

   else if (data_type == 6'h36 && packet_data_rdy && (!compression_en))
   begin
      if(usd_data_type_reg [13:12] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(usd_data_type_reg[13:12] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(usd_data_type_reg[13:12] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(usd_data_type_reg[13:12] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end

   else if (data_type == 6'h37 && packet_data_rdy && (!compression_en))
   begin
      if(usd_data_type_reg[15:14] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(usd_data_type_reg[15:14] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(usd_data_type_reg[15:14] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(usd_data_type_reg[15:14] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end

   else if (data_type == 6'h10 && packet_data_rdy)
   begin
      if(generic_8_bit_long_pkt_data_type[1:0] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(generic_8_bit_long_pkt_data_type[1:0] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(generic_8_bit_long_pkt_data_type[1:0] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(generic_8_bit_long_pkt_data_type[1:0] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end

   else if (data_type == 6'h11 && packet_data_rdy)
   begin
      if(generic_8_bit_long_pkt_data_type[3:2] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(generic_8_bit_long_pkt_data_type[3:2] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(generic_8_bit_long_pkt_data_type[3:2] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(generic_8_bit_long_pkt_data_type[3:2] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end

   else if (data_type == 6'h12 && packet_data_rdy)
   begin
      if(generic_8_bit_long_pkt_data_type[5:4] == 2'b00)
         begin
       raw_data_out <= {24'b0,packet_data[7:0]};
       actual_pkt_size <= (packet_wc_df*8)/8;
        end
      else if(generic_8_bit_long_pkt_data_type[5:4] == 2'b01)
         begin
            if(((packet_wc_df*8)%16) == 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= (packet_wc_df*8)/16;
            end
            else if(((packet_wc_df*8)%16) != 0)
            begin
            raw_data_out <= {16'b0,packet_data[15:0]};
            actual_pkt_size <= ((packet_wc_df*8)/16) + 1;
            end
        end
      else if(generic_8_bit_long_pkt_data_type[5:4] == 2'b10)
         begin
            if(((packet_wc_df*8)%24) == 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= (packet_wc_df*8)/24;
            end
            else if(((packet_wc_df*8)%24) != 0)
            begin
            raw_data_out <= {8'b0,packet_data[23:0]};
            actual_pkt_size <= ((packet_wc_df*8)/24) + 1;
            end
        end
     else if(generic_8_bit_long_pkt_data_type[5:4] == 2'b11)
         begin
            if(((packet_wc_df*8)%32) == 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= (packet_wc_df*8)/32;
            end
            else if(((packet_wc_df*8)%32) != 0)
            begin
            raw_data_out <= {packet_data[31:0]};
            actual_pkt_size <= ((packet_wc_df*8)/32) + 1;
            end
        end
    end

    else if((data_type == 6'h30 && packet_data_rdy) ||
            (data_type == 6'h31 && packet_data_rdy) ||
            (data_type == 6'h32 && packet_data_rdy) ||
            (data_type == 6'h33 && packet_data_rdy) ||
            (data_type == 6'h34 && packet_data_rdy) ||
            (data_type == 6'h35 && packet_data_rdy) ||
            (data_type == 6'h36 && packet_data_rdy) ||
            (data_type == 6'h37 && packet_data_rdy) ||
            (data_type == 6'h10 && packet_data_rdy) ||
            (data_type == 6'h11 && packet_data_rdy) ||
             (data_type == 6'h12 && packet_data_rdy)) 
      begin
         if (compression_en == 1 && dec_10_bit == 1)
         begin
          raw_data_out <= {22'd0,packet_data[9:0]};
          actual_pkt_size <= sig_pixel_count;
        end
        else if (compression_en == 1 && dec_12_bit == 1)
        begin
          raw_data_out <= {20'd0,packet_data[11:0]};
          actual_pkt_size <= sig_pixel_count;
        end
      end
   
  else if(data_type == 6'h1b && packet_data_rdy)
      begin
        raw_data_out <= {24'b0,packet_data[7:0]};

        actual_pkt_size <= (packet_wc_df*8)/8;
       end 
  end

  task send_synch_sh_pkt;
    input [`wc_size - 1 : 0 ] frame_line_cnt;
    input [1:0] temp_vc;
    input [5:0] temp_data_type;
    begin
       packet_vc       = temp_vc;
       command     = "send_synch_sh_pkt";
       packet_wc_df  = frame_line_cnt;
       vir_channel = temp_vc;
       data_type   = temp_data_type;
       packet_dt   = data_type;
       @(posedge clk_csi);
       case(temp_data_type)
         6'h00:
           begin
             fs = 1'b1;
             @(posedge clk_csi);
             $display($time,"\tCSI2 PKT INTERFACE BFM :FRAME START FOR FRAME NO:%d WITH VIRTUAL CHANNEL NO: %d IS TRANSMITTED SUCCESSFULLY\n",frame_line_cnt,temp_vc );
             fs = 1'b0;
             repeat (timing_register -1 ) begin
               @(posedge clk_csi);
             end
           end

         6'h01:
           begin
             fe = 1'b1;
             @(posedge clk_csi);
             $display($time,"\tCSI2 PKT INTERFACE BFM :FRAME END FOR FRAME NO:%d WITH VIRTUAL CHANNEL NO:  %d IS TRANSMITTED SUCCESSFULLY\n",frame_line_cnt,temp_vc );
             fe = 1'b0;
             repeat (timing_register -1 ) begin
               @(posedge clk_csi);
             end
           end
                
         6'h02:
           begin
             ls = 1'b1;
             @(posedge clk_csi);
             $display($time,"\tCSI2 PKT INTERFACE BFM :LINE START FOR LINE NO:%d WITH VIRTUAL CHANNEL NO:  %d IS TRANSMITTED SUCCESSFULLY\n",frame_line_cnt,temp_vc );
             ls = 1'b0; 
             repeat (timing_register -1 ) begin
               @(posedge clk_csi);
             end
           end

         6'h03:
           begin
             le = 1'b1;
             @(posedge clk_csi);
             $display($time,"\tCSI2 PKT INTERFACE BFM :LINE END FOR LINE NO:%d WITH VIRTUAL CHANNEL NO:  %d IS TRANSMITTED SUCCESSFULLY\n",frame_line_cnt,temp_vc );
             le = 1'b0;
             repeat (timing_register -1 ) begin
               @(posedge clk_csi);
             end
           end

         default:
           $display($time,"\tCSI2 PKT INTERFACE BFM :SYNCHRONIZATION SHORT PACKET OF RESERVED DATA TYPE %d WITH VIRTUAL CHANNEL NO:  %h IS TRANSMITTED SUCCESSFULLY\n",temp_data_type,temp_vc );
       endcase
     end
   endtask
 
 
  task send_comp_data_usd10;
    input [15 : 0] byte_count;        //16'h001
    input    [1:0] temp_vc;           //2'b00
    input    [5:0] temp_sec_data_type;//6'h30
    input   [1 :0] prediction;
    input   [2 :0] compress_type;
    begin
    /////////////////////////////////////////////////////////////////////////////////////////////////
             
       @(posedge clk_csi);

      data_type           = temp_sec_data_type;
      vir_channel         = temp_vc;
      packet_dt           = data_type;
      command             = "send_comp_data_usd10";
      packet_vc           = vir_channel;
      temp_prediction     = prediction;
      user_def_pkt_en     = 1'b1;
     
     //////////////////////////////////////////////////////////////////////////////
     
      if ((data_type >= 6'h30) && (data_type <= 6'h37))
      begin
      compression_en      = 1'b1;
      dec_10_bit          = 1'b1;
      dec_12_bit          = 1'b0;
        case (temp_prediction)
          2'b01   : $display("CSI2 PKT INTERFACE BFM : NOTE - PREDICTION MODE 1  IS SELECTED");
          2'b10   : $display("CSI2 PKT INTERFACE BFM : NOTE - PREDICTION MODE 2  IS SELECTED");
          default : $display("CSI2 PKT INTERFACE BFM : ERROR NOTE - NOT A VALID PREDICTION MODE");
        endcase
       
        if (random_en) begin
          rand_wc_gen_comp(compress_type,dec_10_bit,dec_12_bit); 
        end
        
        byte_count_new = random_en ?  rand_wc_op_comp : byte_count;
         
        case (compress_type)
          3'h1 : begin 
                   sig_pixel_count = (byte_count_new * 8)/10;
                   packet_wc_df    = (sig_pixel_count * 8)/8  ;
                   comp_scheme     = {temp_prediction,3'b011};
                   $display("CSI2 PKT INTERFACE BFM : NOTE - COMPRESSION SCHEME 10_8_10 IS SELECTED");
                 end
          3'h2 : begin
                   sig_pixel_count = (byte_count_new * 8)/10;
                   packet_wc_df    = (sig_pixel_count * 7)/8  ;
                   comp_scheme     = {temp_prediction,3'b010};
                   $display("CSI2 PKT INTERFACE BFM : NOTE - COMPRESSION SCHEME 10_7_10 IS SELECTED");
                 end
          3'h3 : begin 
                   sig_pixel_count = (byte_count_new * 8)/10;
                   packet_wc_df    = (sig_pixel_count * 6)/8  ;
                   comp_scheme     = {temp_prediction,3'b001};
                   $display("CSI2 PKT INTERFACE BFM : NOTE - COMPRESSION SCHEME 10_6_10 IS SELECTED");
                 end
          3'h4 : $display("CSI2 PKT INTERFACE BFM : ERROR NOTE - NOT A VALID COMPRESSION SCHEME"); 
        endcase
      end
      else
      begin 
        $display("CSI2 PKT INTERFACE BFM : ERROR NOTE - NOT A VALID USERDEFINED DATA TYPE");
      end    
  
      for (n = 1;n <= sig_pixel_count;n = n+1) 
      begin : USD10_TEN_X_TEN
        rand_data            = $dist_uniform(rand_data_seed,0,1023);
        Xorig10[n]       = rand_data[9:0];
      
        case (compress_type)
          3'h1 : ten_8_ten;
          3'h2 : ten_7_ten;
          3'h3 : ten_6_ten;
          3'h4 : $display("CSI2 PKT INTERFACE BFM : ERROR NOTE - NOT A VALID COMPRESSION SCHEME");
        endcase
 
      end

      long_packet_gen;
      //dec_data_xfer_2_monitor;
      user_def_pkt_en =1'b0;  
      compression_en      = 1'b0;
      dec_10_bit          = 1'b0;

     $display("CSI2 PKT INTERFACE BFM : NOTE - USER DEFINED DATA OF %h BYTES \n WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",sig_pixel_count,packet_vc );

   end
     
  endtask

  task send_comp_data_usd12;
    input [15 : 0] byte_count;        //16'h001
    input    [1:0] temp_vc;           //2'b00
    input    [5:0] temp_sec_data_type;//6'h30
    input   [1 :0] prediction;
    input   [2 :0] compress_type;


    /////////////////////////////////////////////////////////////////////////////////////////////////
      command             = "send_comp_data_usd12";
      data_type           = temp_sec_data_type;
      vir_channel         = temp_vc;
      packet_dt           = data_type;
      temp_prediction     = prediction;
      packet_vc           = vir_channel;
      user_def_pkt_en     = 1'b1;
     //////////////////////////////////////////////////////////////////////////////
     //////////////////////////////////////////////////////////////////////////////
     
      if ((data_type >= 6'h30) && (data_type <= 6'h37))
      begin
      compression_en      = 1'b1;
      dec_12_bit          = 1'b1;
      dec_10_bit          = 1'b0;
        case (temp_prediction)
          2'b01   : $display("CSI2 PKT INTERFACE BFM : NOTE - PREDICTION MODE 1  IS SELECTED");
          2'b10   : $display("CSI2 PKT INTERFACE BFM : NOTE - PREDICTION MODE 2  IS SELECTED");
          default : $display("CSI2 PKT INTERFACE BFM : ERROR NOTE - NOT A VALID PREDICTION MODE");
        endcase

        if (random_en) begin
          rand_wc_gen_comp(compress_type,dec_10_bit,dec_12_bit); 
        end
         
        byte_count_new = random_en ?  rand_wc_op_comp : byte_count;
        
        case (compress_type)
          3'h1 : begin 
                   sig_pixel_count = (byte_count_new * 8)/12;
                   packet_wc_df    = (sig_pixel_count * 8)/8  ;
                   comp_scheme     = {temp_prediction,3'b110};
                   $display("CSI2 PKT INTERFACE BFM : NOTE - COMPRESSION SCHEME 12_8_12 IS SELECTED");
                 end
          3'h2 : begin
                   sig_pixel_count = (byte_count_new * 8)/12;
                   packet_wc_df    = (sig_pixel_count * 7)/8  ;
                   comp_scheme     = {temp_prediction,3'b101};
                   $display("CSI2 PKT INTERFACE BFM : NOTE - COMPRESSION SCHEME 12_7_12 IS SELECTED");
                 end
          3'h3 : begin 
                   sig_pixel_count = (byte_count_new * 8)/12;
                   packet_wc_df    = (sig_pixel_count * 6)/8  ;
                   comp_scheme     = {temp_prediction,3'b100};
                   $display("CSI2 PKT INTERFACE BFM : NOTE - COMPRESSION SCHEME 12_6_12 IS SELECTED");
                 end
          3'h4 : $display("CSI2 PKT INTERFACE BFM : ERROR NOTE - NOT A VALID COMPRESSION SCHEME"); 
        endcase
      end
      else 
        $display("CSI2 PKT INTERFACE BFM : ERROR NOTE - NOT A VALID USERDEFINED DATA TYPE");
            
           
  
      for (n = 1;n <= sig_pixel_count;n = n+1)
      begin : USD12
        rand_data            = $dist_uniform(rand_data_seed,0,1023);
        Xorig12[n]       = rand_data[11:0];
        case (compress_type)
          3'h1 : tw_8_tw;
          3'h2 : tw_7_tw;
          3'h3 : tw_6_tw;
          3'h4 : $display("CSI2 PKT INTERFACE BFM : ERROR NOTE - NOT A VALID COMPRESSION SCHEME");
        endcase
       
      end
      long_packet_gen;
      //dec_data12_xfer_2_monitor;
      user_def_pkt_en     = 1'b0;
      compression_en      = 1'b0;
      dec_12_bit          = 1'b0;
      
     $display($time,"\tCSI2 PKT INTERFACE BFM : NOTE - USER DEFINED DATA OF %h BYTES \n WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",sig_pixel_count,packet_vc);
  endtask


  task send_raw_data;
    input [`wc_size - 1 : 0 ] byte_count;
    input [1:0] temp_vc;
    input [5:0] temp_data_type;
     if (random_en) begin
        rand_wc_gen(temp_data_type);
      end
      if(temp_data_type == 6'h28 || temp_data_type == 6'h2c)
        min_byte = 3;
      else if(temp_data_type == 6'h29 || temp_data_type == 6'h2d)
        min_byte = 7;
      else if(temp_data_type == 6'h2a)
        min_byte = 1;
      else if(temp_data_type == 6'h2b)
        min_byte = 5;
        packet_vc       = temp_vc;
        command     = "send_raw_data";
        if(bandwidth_2k_enable)
        begin
          if(byte_count > 16'd2049)         
          packet_wc_df = (16'd2048-(16'd2048 %min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd2049)? (16'd2048-(16'd2048 %min_byte)) : rand_wc_op) : byte_count;    
        end
        else if(bandwidth_4k_enable)
        begin
          if(byte_count > 16'd4097)         
          packet_wc_df = (16'd4096-(16'd4096 % min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd4097)? (16'd4096-(16'd4096 % min_byte)) : rand_wc_op) : byte_count;    
        end
        else if(bandwidth_8k_enable) begin
          if(byte_count > 16'd8193)         
            packet_wc_df = (16'd8192-(16'd8192%min_byte));
          else
            packet_wc_df  = random_en ? ((rand_wc_op > 16'd8193)? (16'd8192-(16'd8192%min_byte)) : rand_wc_op) : byte_count;    
        end else if(bandwidth_16k_enable) begin
          if(byte_count > 16'd16385)         
            packet_wc_df = (16'd16384-(16'd16384%min_byte));
          else
            packet_wc_df  = random_en ? ((rand_wc_op > 16'd16385)? (16'd16384-(16'd16384%min_byte)) : rand_wc_op) : byte_count;    

        end else if(bandwidth_32k_enable) begin
          if(byte_count > 16'd32769)         
            packet_wc_df = (16'd32768-(16'd32768%min_byte));
          else
            packet_wc_df  = random_en ? ((rand_wc_op > 16'd32769)? (16'd32768-(16'd32768%min_byte)) : rand_wc_op) : byte_count;    

        end else if(bandwidth_64k_enable) begin
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd32769)? (16'd65535 -(16'd65535%min_byte)) : rand_wc_op) : byte_count;    

        end else begin
          packet_wc_df  = random_en ? rand_wc_op : byte_count;
        end
          vir_channel = temp_vc;
          data_type   = temp_data_type;
          packet_dt   = data_type;
          send_data;
          raw_pak_en =1'b1;
          long_packet_gen;

        case(temp_data_type)
          6'h28: 
              $display($time,"\tCSI2 PKT INTERFACE BFM :RAW6 DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h29:  
              $display($time,"\tCSI2 PKT INTERFACE BFM :RAW7 DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h2a:  
              $display($time,"\tCSI2 PKT INTERFACE BFM :RAW8 DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h2b:  
              $display($time,"\tCSI2 PKT INTERFACE BFM :RAW10 DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h2c:  
              $display($time,"\tCSI2 PKT INTERFACE BFM :RAW12 DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h2d:  
              $display($time,"\tCSI2 PKT INTERFACE BFM :RAW14 DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          default:
                $display($time,"\tCSI2 PKT INTERFACE BFM :RESERVED DATA TYPE %h with %d BYTES WITH VIRTUAL CHANNEL NO:  %h IS SENT SUCCESSFULLY\n",temp_data_type,packet_wc_df,temp_vc );
        endcase

      raw_pak_en =1'b0;

  endtask



//YUV DATA
 task send_yuv_data;
    input [`wc_size - 1 : 0 ] byte_count;
    input [1:0] temp_vc;
    input [5:0] temp_data_type;
     if (random_en) begin
        rand_wc_gen(temp_data_type);
      end
      if(temp_data_type == 6'h19 || temp_data_type == 6'h1d || temp_data_type == 6'h1f )
        min_byte = 10;
      else if(temp_data_type == 6'h1a)
        min_byte = 3;
        packet_vc       = temp_vc;
        command     = "send_yuv_data";
        if(bandwidth_2k_enable)
        begin
          if(byte_count > 16'd2049)         
          packet_wc_df = (16'd2048-(16'd2048 %min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd2049)? (16'd2048-(16'd2048 %min_byte)) : rand_wc_op) : byte_count;    
        end
        else if(bandwidth_4k_enable)
        begin
          if(byte_count > 16'd4097)         
          packet_wc_df = (16'd4096-(16'd4096 % min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd4097)? (16'd4096-(16'd4096 % min_byte)) : rand_wc_op) : byte_count;    
        end
        else if(bandwidth_8k_enable)
        begin
          if(byte_count > 16'd8193)         
          packet_wc_df = (16'd8192-(16'd8192%min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd8193)? (16'd8192-(16'd8192%min_byte)) : rand_wc_op) : byte_count;    

        end
        else if(bandwidth_16k_enable)
        begin
         if(byte_count > 16'd16385)         
          packet_wc_df = (16'd16384-(16'd16384%min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd16385)? (16'd16384-(16'd16384%min_byte)) : rand_wc_op) : byte_count;    

        end
        else if(bandwidth_32k_enable)
        begin
         if(byte_count > 16'd32769)         
          packet_wc_df = (16'd32768-(16'd32768%min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd32769)? (16'd32768-(16'd32768%min_byte)) : rand_wc_op) : byte_count;    

        end
        else if(bandwidth_64k_enable)
        begin
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd32769)? (16'd65535 -(16'd65535%min_byte)) : rand_wc_op) : byte_count;    

        end
        else
        begin
        packet_wc_df  = random_en ? rand_wc_op : byte_count;
        end

        vir_channel = temp_vc;
        data_type   = temp_data_type;
        packet_dt   = data_type;
        send_data;
        yuv_pak_en =1'b1;
        long_packet_gen;

        case(temp_data_type)
          6'h18: 
            $display($time,"\tCSI2 PKT INTERFACE BFM :YUV420 8-BIT DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h19:  
            $display($time,"\tCSI2 PKT INTERFACE BFM :YUV420 10-BIT DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h1a:  
            $display($time,"\tCSI2 PKT INTERFACE BFM :LEGACY YUV420 8-BIT DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h1c:  
            $display($time,"\tCSI2 PKT INTERFACE BFM :YUV420 8-BIT CHROMA DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h1d:  
            $display($time,"\tCSI2 PKT INTERFACE BFM :YUV420 10-BIT CHROMA DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h1e:  
            $display($time,"\tCSI2 PKT INTERFACE BFM :YUV422 8-BIT DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
          6'h1f:  
            $display($time,"\tCSI2 PKT INTERFACE BFM :YUV422 10-BIT DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc ); 
             
          default:
            $display($time,"\tCSI2 PKT INTERFACE BFM :RESERVED DATA TYPE %h with %d BYTES \nWITH VIRTUAL CHANNEL NO:  %h IS SENT SUCCESSFULLY\n",temp_data_type,packet_wc_df,temp_vc );
        endcase
       
      yuv_pak_en =1'b0;
      actual_pkt_size = 16'h0;

          case(temp_data_type)
          6'h18 : case (temp_vc)
                    2'b00 : yuv420_8b_odd_even_line[0] = ~ yuv420_8b_odd_even_line[0];
                    2'b01 : yuv420_8b_odd_even_line[1] = ~ yuv420_8b_odd_even_line[1];
                    2'b10 : yuv420_8b_odd_even_line[2] = ~ yuv420_8b_odd_even_line[2];
                    2'b11 : yuv420_8b_odd_even_line[3] = ~ yuv420_8b_odd_even_line[3];
                  endcase
          6'h19 : case (temp_vc) 
                    2'b00 : yuv420_10b_odd_even_line[0] = ~ yuv420_10b_odd_even_line[0];
                    2'b01 : yuv420_10b_odd_even_line[1] = ~ yuv420_10b_odd_even_line[1];
                    2'b10 : yuv420_10b_odd_even_line[2] = ~ yuv420_10b_odd_even_line[2];
                    2'b11 : yuv420_10b_odd_even_line[3] = ~ yuv420_10b_odd_even_line[3];
                  endcase
 
          6'h1a : case (temp_vc) 
                    2'b00 : lyuv420_8b_odd_even_line[0]      = ~ lyuv420_8b_odd_even_line[0];
                    2'b01 : lyuv420_8b_odd_even_line[1]      = ~ lyuv420_8b_odd_even_line[1];
                    2'b10 : lyuv420_8b_odd_even_line[2]      = ~ lyuv420_8b_odd_even_line[2];
                    2'b11 : lyuv420_8b_odd_even_line[3]      = ~ lyuv420_8b_odd_even_line[3];
                  endcase  
          6'h1c : case (temp_vc)
                    2'b00 : csps_yuv420_8b_odd_even_line[0]  = ~ csps_yuv420_8b_odd_even_line[0];
                    2'b01 : csps_yuv420_8b_odd_even_line[1]  = ~ csps_yuv420_8b_odd_even_line[1];
                    2'b10 : csps_yuv420_8b_odd_even_line[2]  = ~ csps_yuv420_8b_odd_even_line[2];
                    2'b11 : csps_yuv420_8b_odd_even_line[3]  = ~ csps_yuv420_8b_odd_even_line[3];
                  endcase 
          6'h1d : case (temp_vc)
                    2'b00 : csps_yuv420_10b_odd_even_line[0] = ~ csps_yuv420_10b_odd_even_line[0];
                    2'b01 : csps_yuv420_10b_odd_even_line[1] = ~ csps_yuv420_10b_odd_even_line[1];
                    2'b10 : csps_yuv420_10b_odd_even_line[2] = ~ csps_yuv420_10b_odd_even_line[2];
                    2'b11 : csps_yuv420_10b_odd_even_line[3] = ~ csps_yuv420_10b_odd_even_line[3];
                  endcase 
          6'h1e : case (temp_vc)
                    2'b00 : yuv422_8b_odd_even_line[0]       =  yuv422_8b_odd_even_line[0];
                    2'b01 : yuv422_8b_odd_even_line[1]       =  yuv422_8b_odd_even_line[1];
                    2'b10 : yuv422_8b_odd_even_line[2]       =  yuv422_8b_odd_even_line[2];
                    2'b11 : yuv422_8b_odd_even_line[3]       =  yuv422_8b_odd_even_line[3];
                  endcase 
          6'h1f : case (temp_vc)
                    2'b00 : yuv422_10b_odd_even_line[0]      =  yuv422_10b_odd_even_line[0];
                    2'b01 : yuv422_10b_odd_even_line[1]      =  yuv422_10b_odd_even_line[1];
                    2'b10 : yuv422_10b_odd_even_line[2]      =  yuv422_10b_odd_even_line[2];
                    2'b11 : yuv422_10b_odd_even_line[3]      =  yuv422_10b_odd_even_line[3];
                  endcase 
       endcase
  endtask


  always@(*)
    begin
      case(data_type)
        6'h18 : case (vir_channel)
                  2'b00 : odd_even_line = yuv420_8b_odd_even_line[0];
                  2'b01 : odd_even_line = yuv420_8b_odd_even_line[1];
                  2'b10 : odd_even_line = yuv420_8b_odd_even_line[2];
                  2'b11 : odd_even_line = yuv420_8b_odd_even_line[3];
                endcase 
        6'h19 : case (vir_channel) 
                  2'b00 : odd_even_line = yuv420_10b_odd_even_line[0]; 
                  2'b01 : odd_even_line = yuv420_10b_odd_even_line[1]; 
                  2'b10 : odd_even_line = yuv420_10b_odd_even_line[2]; 
                  2'b11 : odd_even_line = yuv420_10b_odd_even_line[3];
                endcase 
 
        6'h1a : case (vir_channel) 
                  2'b00 : odd_even_line = lyuv420_8b_odd_even_line[0]; 
                  2'b01 : odd_even_line = lyuv420_8b_odd_even_line[1]; 
                  2'b10 : odd_even_line = lyuv420_8b_odd_even_line[2]; 
                  2'b11 : odd_even_line = lyuv420_8b_odd_even_line[3]; 
                endcase 

        6'h1c : case (vir_channel) 
                  2'b00 : odd_even_line = csps_yuv420_8b_odd_even_line[0]; 
                  2'b01 : odd_even_line = csps_yuv420_8b_odd_even_line[1]; 
                  2'b10 : odd_even_line = csps_yuv420_8b_odd_even_line[2]; 
                  2'b11 : odd_even_line = csps_yuv420_8b_odd_even_line[3];
                endcase 
 
        6'h1d : case (vir_channel) 
                  2'b00 : odd_even_line = csps_yuv420_10b_odd_even_line[0]; 
                  2'b01 : odd_even_line = csps_yuv420_10b_odd_even_line[1]; 
                  2'b10 : odd_even_line = csps_yuv420_10b_odd_even_line[2]; 
                  2'b11 : odd_even_line = csps_yuv420_10b_odd_even_line[3];
                endcase 
 
        6'h1e : case (vir_channel) 
                  2'b00 : odd_even_line = yuv422_8b_odd_even_line[0]; 
                  2'b01 : odd_even_line = yuv422_8b_odd_even_line[1]; 
                  2'b10 : odd_even_line = yuv422_8b_odd_even_line[2]; 
                  2'b11 : odd_even_line = yuv422_8b_odd_even_line[3];
                endcase 

        6'h1f : case (vir_channel) 
                  2'b00 : odd_even_line = yuv422_10b_odd_even_line[0]; 
                  2'b01 : odd_even_line = yuv422_10b_odd_even_line[1]; 
                  2'b10 : odd_even_line = yuv422_10b_odd_even_line[2]; 
                  2'b11 : odd_even_line = yuv422_10b_odd_even_line[3];
                endcase 
    endcase
  end

  task pwr_rst_pkt_drop_assert;
    begin
      #980;
      pkt_drop_en =1'b1;
    end 
  endtask


  task pwr_rst_pkt_drop_deassert;
    begin
      pkt_drop_en =1'b0;
    end 
  endtask


  //USER DEFINED DATA COMMAND
  task send_user_def_data;
    input [`wc_size - 1 : 0 ] byte_count;
    input [1:0] temp_vc;
    input [5:0] temp_data_type;
    begin

      if (random_en) begin
        rand_wc_gen(temp_data_type);
      end
        packet_vc       = temp_vc;
        command         = "send_user_def_data";
      if(bandwidth_2k_enable)
        begin
          if(byte_count > 16'd2049)         
          packet_wc_df = 16'd2048;
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd2049)? 16'd2048 : rand_wc_op) : byte_count;    
        end
        else if(bandwidth_4k_enable)
        begin
          if(byte_count > 16'd4097)         
          packet_wc_df = 16'd4096;
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd4097)? 16'd4098: rand_wc_op) : byte_count;    
        end
        else if(bandwidth_8k_enable)
        begin
          if(byte_count > 16'd8193)         
          packet_wc_df = 16'd8192;
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd8193)? 16'd8192: rand_wc_op) : byte_count;    

        end
        else if(bandwidth_16k_enable)
        begin
         if(byte_count > 16'd16385)         
          packet_wc_df = 16'd16384;
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd16385)? 16'd16385: rand_wc_op) : byte_count;    

        end
        else if(bandwidth_32k_enable)
        begin
         if(byte_count > 16'd32769)         
          packet_wc_df = (16'd32768-(16'd32768%min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd32769)? (16'd32768-(16'd32768%min_byte)) : rand_wc_op) : byte_count;    

        end
        else if(bandwidth_64k_enable)
        begin
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd32769)? (16'd65535 -(16'd65535%min_byte)) : rand_wc_op) : byte_count;    

        end
        else
        begin
        packet_wc_df  = random_en ? rand_wc_op : byte_count;
        end
        vir_channel     = temp_vc;
        data_type       = temp_data_type;
        packet_dt       = data_type;
        send_data;
        user_def_pkt_en =1'b1;
        long_packet_gen;
          case(temp_data_type)
            6'h30:                                      
              $display($time,"\tCSI2 PKT INTERFACE BFM :USD DATA Type 1 with %d BYTES is sent through VIRTUAL CHANNEL %d SUCCESSFULLY\n",packet_wc_df,temp_vc );
            6'h31:
              $display($time,"\tCSI2 PKT INTERFACE BFM :USD DATA Type 2 with %d BYTES is sent through VIRTUAL CHANNEL %d SUCCESSFULLY\n",packet_wc_df,temp_vc );
            6'h32:
              $display($time,"\tCSI2 PKT INTERFACE BFM :USD DATA Type 3 with %d BYTES is sent through VIRTUAL CHANNEL %d SUCCESSFULLY\n",packet_wc_df,temp_vc );
            6'h33:
              $display($time,"\tCSI2 PKT INTERFACE BFM :USD DATA Type 4 with %d BYTES is sent through VIRTUAL CHANNEL %d SUCCESSFULLY\n",packet_wc_df,temp_vc );
            6'h34:
              $display($time,"\tCSI2 PKT INTERFACE BFM :USD DATA Type 5 with %d BYTES is sent through VIRTUAL CHANNEL %d SUCCESSFULLY\n",packet_wc_df,temp_vc );
            6'h35:
              $display($time,"\tCSI2 PKT INTERFACE BFM :USD DATA Type 6 with %d BYTES is sent through VIRTUAL CHANNEL %d SUCCESSFULLY\n",packet_wc_df,temp_vc );
            6'h36:
              $display($time,"\tCSI2 PKT INTERFACE BFM :USD DATA Type 7 with %d BYTES is sent through VIRTUAL CHANNEL %d SUCCESSFULLY\n",packet_wc_df,temp_vc );
            6'h37:
              $display($time,"\tCSI2 PKT INTERFACE BFM :USD DATA Type 8 with %d BYTES is sent through VIRTUAL CHANNEL %d SUCCESSFULLY\n",packet_wc_df,temp_vc );
            default:
              $display($time,"\tCSI2 PKT INTERFACE BFM :RESERVED DATA TYPE %h with %d BYTES WITH VIRTUAL CHANNEL NO:  %d IS SENT SUCCESSFULLY\n",temp_data_type,packet_wc_df,temp_vc );
          endcase
      user_def_pkt_en =1'b0;
    end
  endtask

  //GENERIC DATA COMMAND
  task send_generic_long_pkt;
    input [`wc_size - 1 : 0 ] byte_count;
    input [1:0] temp_vc;
    input [5:0] temp_data_type;
    begin
      if(random_en) begin
        rand_wc_gen(temp_data_type);
      end
        packet_vc       = temp_vc;
        command     = "send_generic_data";
        packet_wc_df  = random_en ? rand_wc_op : byte_count;
        vir_channel = temp_vc;
        data_type   = temp_data_type;
        packet_dt   = data_type;
        send_data;
        gen_def_pkt_en =1'b1;
        long_packet_gen;
          case(temp_data_type)
            6'h10:
              $display($time,"\tCSI2 PKT INTERFACE BFM :NULL DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %d IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc );
            6'h11:
              $display($time,"\tCSI2 PKT INTERFACE BFM :BLANKING DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %d IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc );
            6'h12:
              $display($time,"\tCSI2 PKT INTERFACE BFM :EMBEDDED DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %d IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc );
            default:
              $display($time,"\tCSI2 PKT INTERFACE BFM :RESERVED DATA TYPE %h with %d BYTES WITH VIRTUAL CHANNEL NO:  %d IS SENT SUCCESSFULLY\n",temp_data_type,packet_wc_df,temp_vc );
          
          endcase

      gen_def_pkt_en = 1'b0;
    end
  endtask


  //GENERIC SHORT PACKET COMMAND
  task send_generic_sh_pkt;
    input [`wc_size - 1 : 0 ] byte_count;
    input [1:0] temp_vc;
    input [5:0] temp_data_type;
    begin

        if (random_en)
         begin
          rand_wc_gen(temp_data_type);
        end
        packet_vc       = temp_vc;
        command     = "send_generic_sh_pkt";
        packet_wc_df  = random_en ? rand_wc_op : byte_count;
        vir_channel = temp_vc;
        data_type   = temp_data_type;
        packet_dt   = data_type;
        gen_sht_pkt_en = 1'b1;
        short_packet_gen;
        gen_sht_pkt_en = 1'b0;
        $display($time,"\tCSI2 PKT INTERFACE BFM :GENERIC SHORT PACKET WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc );

    end
  endtask

  //RGB DEFINED DATA COMMAND
  task send_rgb_data;
    input [`wc_size - 1 : 0 ] byte_count;
    input [1:0] temp_vc;
    input [5:0] temp_data_type;
    begin
       if (random_en) begin
        rand_wc_gen(temp_data_type);
      end
      if(temp_data_type == 6'h20 || temp_data_type == 6'h21 || temp_data_type == 6'h22)
       min_byte = 2;
      else if(temp_data_type == 6'h23)
        min_byte = 9;
      else if(temp_data_type == 6'h24)
        min_byte = 3;
        packet_vc       = temp_vc;
        command     = "send_rgb_data";
        if(bandwidth_2k_enable)
        begin
          if(byte_count > 16'd2049)         
          packet_wc_df = (16'd2048-(16'd2048 %min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd2049)? (16'd2048-(16'd2048 %min_byte)) : rand_wc_op) : byte_count;    
        end
        else if(bandwidth_4k_enable)
        begin
          if(byte_count > 16'd4097)         
          packet_wc_df = (16'd4096-(16'd4096 %min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd4097)? (16'd4096-(16'd4096 % min_byte)) : rand_wc_op) : byte_count;    
        end
        else if(bandwidth_8k_enable)
        begin
          if(byte_count > 16'd8193)         
          packet_wc_df = (16'd8192-(16'd8192%min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd8193)? (16'd8192-(16'd8192%min_byte)) : rand_wc_op) : byte_count;    

        end
        else if(bandwidth_16k_enable)
        begin
         if(byte_count > 16'd16385)         
          packet_wc_df = (16'd16384-(16'd16384%min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd16385)? (16'd16384-(16'd16384%min_byte)) : rand_wc_op) : byte_count;    

        end
        else if(bandwidth_32k_enable)
        begin
         if(byte_count > 16'd32769)         
          packet_wc_df = (16'd32768-(16'd32768%min_byte));
          else
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd32769)? (16'd32768-(16'd32768%min_byte)) : rand_wc_op) : byte_count;    

        end
        else if(bandwidth_64k_enable)
        begin
          packet_wc_df  = random_en ? ((rand_wc_op > 16'd32769)? (16'd65535 -(16'd65535%min_byte)) : rand_wc_op) : byte_count;    

        end

        else
        begin
        packet_wc_df  = random_en ? rand_wc_op : byte_count;
        end
        vir_channel = temp_vc;
        data_type   = temp_data_type;
        packet_dt   = data_type;
        send_data;
        rgb_pak_en =1'b1;
        long_packet_gen;
        case(temp_data_type)
          6'h20:
            $display($time,"\tCSI2 PKT INTERFACE BFM :RGB 444 DATA TYPE  with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc );
          6'h21:
            $display($time,"\tCSI2 PKT INTERFACE BFM :RGB 555 DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc );
          6'h22:
            $display($time,"\tCSI2 PKT INTERFACE BFM :RGB 565 DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc );
          6'h23:
            $display($time,"\tCSI2 PKT INTERFACE BFM :RGB 666 DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc );
          6'h24:
            $display($time,"\tCSI2 PKT INTERFACE BFM :RGB 888 DATA TYPE with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",packet_wc_df,temp_vc );
          default:
            $display($time,"\tCSI2 PKT INTERFACE BFM : NOTE - RESERVED DATA TYPE %h with %d BYTES WITH VIRTUAL CHANNEL NO: %h IS SENT SUCCESSFULLY\n",temp_data_type,packet_wc_df,temp_vc );
              
        endcase
      rgb_pak_en=1'b0;
    end
  endtask

  /*----------------------------------------------------------------------------
          Task to fill data into fifo in increasing order starting from 1  
  -----------------------------------------------------------------------------*/
  task data_fill;
    begin
      data_fill_enable = 1'b1;
    end
  endtask

  /*----------------------------------------------------------------------------
          Task to fill all 1's into fifo  
  -----------------------------------------------------------------------------*/
  task data_ff_fill;
    begin
      data_ff_fill_enable = 1'b1;
    end
  endtask

  /*----------------------------------------------------------------------------
          Task to fill all 0's into fifo  
  -----------------------------------------------------------------------------*/
  task data_oo_fill;
    begin
      data_oo_fill_enable = 1'b1;
    end
  endtask
 
  /*----------------------------------------------------------------------------
      Task to fill all location of fifo with 1's & 0's
  -----------------------------------------------------------------------------*/
  task data_toggle_fill;
    begin
      data_toggle_fill_enable = 1'b1;
    end
  endtask
 

  task send_data;
    begin
      if(data_fill_enable) begin
        for (i_mem = 0;i_mem <= 17300;i_mem = i_mem+1) begin
          mem_user[i_mem] = data_count;
          data_count = data_count + 1;
        end
      end else if(data_ff_fill_enable) begin
        for (i_mem = 0;i_mem <= 17300;i_mem = i_mem+1) begin
          mem_user[i_mem] = 32'hffff;
        end
      end else if(data_oo_fill_enable) begin
        for (i_mem = 0;i_mem <= 17300;i_mem = i_mem+1) begin
          mem_user[i_mem] = 32'h0;
        end
      end else if(data_toggle_fill_enable ) begin
        for (i_mem = 0;i_mem <= 17300;i_mem = i_mem+1) begin
          if(toggle_data == 1)
            data_val = 32'hffff;
          else
            data_val = 32'h00;

            mem_user[i_mem] = data_val;
            toggle_data     = ~toggle_data; 
        end
      end else begin
        for (i_mem = 0;i_mem <= packet_wc_df + 6300;i_mem = i_mem+1) begin
          rand_data1 = $dist_uniform(rand_data_seed,0,255);
          rand_data2 = $dist_uniform(rand_data_seed,0,255);
          rand_data3 = $dist_uniform(rand_data_seed,0,255);
          rand_data4 = $dist_uniform(rand_data_seed,0,255);
          rand_data = {rand_data4,rand_data3,rand_data2,rand_data1};
          mem_user[i_mem]= rand_data[31:0];
        end 
      end
    end
  endtask

  /*----------------------------------------------------------------------------
          CSI END COMMAND  
  -----------------------------------------------------------------------------*/
  task csi_end_cmd;
    begin:blockend
      command     = "csi_end_cmd";
      $display($time,"\tCSI2 PKT INTERFACE BFM : END OF FILE HAS BEEN REACHED \n");
      @(posedge clk_csi);
      @(posedge clk_csi);
      csi_end_of_file = 1'b1;
    end
  endtask

  /*----------------------------------------------------------------------------
       TASK TO GENERATE PACKET
  -----------------------------------------------------------------------------*/
  task long_packet_gen;
    begin
      short_packet_en = 1'b1;
      long_packet_en = 1'b1;
      packet_tx;
      long_packet_en = 1'b0;
      short_packet_en = 1'b0;
    end
  endtask

  always @(lane_index)
    begin
      //rgb_cnt=0;
      //yuv_cnt=0;
      generic_long_cnt=0;
      //user_cnt =0;
    end

  /*----------------------------------------------------------------------------
       TASK TO DUMP LONG PACKET ON TO OUTPUT BUS
  -----------------------------------------------------------------------------*/
  task lng_pkt_dump;
    begin
      tx_cnt =32'h0;
      packet_data_valid =1'b1;
      dec_2_monitor = 1'b1;
    
      while(tx_cnt < actual_pkt_size) begin
        if(gen_long_pkt_en)
          shft_tx_data = mem_generic[generic_long_cnt+ tx_cnt];
        else if(user_def_pkt_en || yuv_pak_en || raw_pak_en || rgb_pak_en || gen_def_pkt_en) begin
          Xdeco12_2_monitor = Xdeco12[1+tx_cnt]; 
          Xdeco10_2_monitor = Xdeco10[1+tx_cnt]; 
          if(dec_10_bit & compression_en)
            shft_tx_data1 = Xorig10[1+/*user_cnt+*/tx_cnt ];
          else if(dec_12_bit & compression_en)
            shft_tx_data1 = Xorig12[1/*+user_cnt*/+tx_cnt ];
          else 
            shft_tx_data1 = mem_user[/*user_cnt+*/tx_cnt];        
                 
            csi_tx_pix_en = 1'b1;
            csi_tx_pix_en = 1'b0;
            tx_cnt = tx_cnt+1;
          end

        packet_data = shft_tx_data1;
        #1;
        wait(packet_data_rdy);
        @(posedge clk_csi);
      end

      if(gen_long_pkt_en)
        generic_long_cnt = generic_long_cnt; //+ no_of_bytes;
      else if(user_def_pkt_en || yuv_pak_en || raw_pak_en || rgb_pak_en || gen_def_pkt_en)
        //user_cnt = user_cnt + no_of_bytes;
        packet_data_valid =1'b0;
        dec_2_monitor = 1'b0;
    end
  endtask

  /*----------------------------------------------------------------------------
       TASK FOR SHORT PACKET GENERATION
  -----------------------------------------------------------------------------*/
  task short_packet_gen;
    begin
          short_reg[0] = {vir_channel,data_type};
          short_reg[1] = packet_wc_df[7:0];
          short_reg[2] = packet_wc_df[15:8];
          short_reg[3] = 8'b0;
      short_packet_en = 1'b1;
      packet_tx;
      short_packet_en = 1'b0;
      #0;
    end
  endtask

  /*----------------------------------------------------------------------------
       TASK FOR PACKET TRANSMISSION
  -----------------------------------------------------------------------------*/ 
  task packet_tx;
    begin:pkt_lp
      if(short_packet_en) begin
        @(posedge clk_csi);
        `ifdef TIMESCALE_NS
          #1ps;
        `else
          #1;
        `endif

        packet_valid = 1'b1;
        if(!long_packet_en)
          wait(packet_rdy);
        else if(long_packet_en)
          wait (packet_rdy && packet_data_rdy);
          @(posedge clk_csi);
          packet_valid = 1'b0;
        end
 
        if(long_packet_en) begin
          lng_pkt_dump;
          wait(packet_data_rdy);
        end
    end
  endtask

  /*----------------------------------------------------------------------------
       TASK TO DUMP SHORT PACKET
  -----------------------------------------------------------------------------*/
  task sht_pkt_dump;
    begin
      tx_cnt =32'h000 ;
      while(tx_cnt <4) begin
        @(posedge clk_csi);
        shft_tx_data = short_reg[tx_cnt];
        tx_cnt=tx_cnt+lane_index;
      end
      
      if(gen_sht_pkt_en) begin
        gen_data_tx = {vir_channel,packet_wc_df};
        for(gen_cnt = 0; gen_cnt <= 2; gen_cnt=gen_cnt+1) begin
          if(gen_cnt ==0)
            csi_data_tx = gen_data_tx[7:0];
          else if(gen_cnt ==1)
            csi_data_tx = gen_data_tx[15:8];
          else if(gen_cnt ==2)
            csi_data_tx = {6'h0,gen_data_tx[17:16]};
        end
      end
    end
  endtask


  always @(posedge clk_csi)
    begin
      if(!reset_clk_csi_n)
        long_packet_en_d = 1'b0;
      else
        long_packet_en_d = long_packet_en;
    end

  /*----------------------------------------------------------------------------
    This is to control the task execution in other command files
    This is requires so that we assert the soft reset onlu in HS/ULPS
  ----------------------------------------------------------------------------*/
  always@(posedge clk_csi or negedge reset_clk_csi_n)
    begin
      if( reset_clk_csi_n == 1'b0)
        pkt_sent <= 1'b0;
      else if (pkt_drop_en)
        pkt_sent <= 1'b1;
    end

   /*----------------------------------------------------------------------------
      Encoder and Decoder BFM
   ----------------------------------------------------------------------------*/
  reg [7:0]tttt;
  task ten_8_ten;
    begin
         //////////////////predictor//////////////
      if(temp_prediction == 2'b01)
        begin
          if(n > 2)
            begin
              predictor1_10;
            end
        end
      else if(temp_prediction == 2'b10)
        begin
          if(n > 1)
            begin
              predictor2_10;
            end
        end
      //////////////////predictor//////////////

      //////////////////encoder//////////////////
      //Encoders
      //Coder for 10810 Data Compression

      //Pixels without prediction are encoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xenco8[n] = (Xorig10[n] / 10'h4);
          //To avoid a full-zero encoded value, the following check is performed:
          if (Xenco8[n] == 0)
            begin
              Xenco8[n] = 1;
            end
        end
      else
        begin
          Xdiff10_tsk;

          //Pixels with prediction are encoded using the following formula:
          if (Xdiff10[n] < 32)
            DPCM1_for_10_8_10_coder;//DPCM1;
          else if (Xdiff10[n] < 64)
            DPCM2_for_10_8_10_coder;//DPCM2;
          else if (Xdiff10[n] < 128)
            DPCM3_for_10_8_10_coder;//DPCM3;
          else
            PCM_for_10_8_10_coder;//PCM;
        end
      //////////////////encoder//////////////////

      //////////////decoder/////////////
      // Pixels without prediction are decoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          command1 = "WITHOUT PREDICTION";
          Xdeco10[n] = 4 * Xenco8[n] + 2;
          //ten_eit_ten = 1'b1;
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;

        end
      else
        begin
          //Pixels with prediction are decoded using the following formula:
          if ((Xenco8[n] & 8'hc0) == 8'h00)
            begin
              tttt = (Xenco8[n] & 8'hc0);
              DPCM1_for_10_8_10_decoder;
             // $display("DPCM1");
            end
          else if ((Xenco8[n] & 8'he0) == 8'h40)
            begin
              tttt = (Xenco8[n] & 8'he0);
              DPCM2_for_10_8_10_decoder;
             // $display("DPCM2");
            end
          else if ((Xenco8[n] & 8'he0) == 8'h60)
            begin
              tttt = (Xenco8[n] & 8'he0);
              DPCM3_for_10_8_10_decoder;
            //  $display("DPCM3");

            end
          else
            begin
              tttt = (Xenco8[n] & 8'he0);
              PCM_for_10_8_10_decoder;
            //  $display("PCM");

            end
        end
      //////////////decoder/////////////

    end
  endtask

  task DPCM1_for_10_8_10_coder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 00 s xxxxx
      //where,
      //00 is the code word
      //s is the sign bit
      //xxxxx is the five bit value field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1 || Xdiff_equal_to_0 == 1'b1))
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value10 = Xdiff10[n];

      Xenco8[n] = {2'b00,encoder_sign,value10[4:0]};
    end
  endtask


  task DPCM1_for_10_8_10_decoder;
    begin
      command1 = "DPCM1_for_10_8_10_decoder";
      //Xenco8[n] has the following format:
      //Xenco8[n] = 00 s xxxxx
      //where,
      //00 is the code word
      //s is the sign bit
      //xxxxx is the five bit value10 field

      //The coder equation is described as follows:
      decoder_sign = Xenco8[n] & 8'h20;
      value10 = Xenco8[n] & 8'h1f;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end

  endtask


  task DPCM2_for_10_8_10_coder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 010 s xxxx
      //where,
      //010 is the code word
      //s is the sign bit
      //xxxx is the four bit value10 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value10 = (Xdiff10[n] - 32) / 2;

      Xenco8[n] = {3'b010,encoder_sign,value10[3:0]};
    end
  endtask

  task DPCM2_for_10_8_10_decoder;
    begin
      command1 = "DPCM2_for_10_8_10_decoder";
      //Xenco8[n] has the following format:
      //Xenco8[n] = 010 s xxxx
      //where,
      //010 is the code word
      //s is the sign bit
      //xxxx is the four bit value10 field

      //The decoder equation is described as follows:
      decoder_sign = Xenco8[n] & 8'h10;
      value10 = 2 * (Xenco8[n] & 8'hf) + 32;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask


  task DPCM3_for_10_8_10_coder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 011 s xxxx
      //where,
      //010 is the code word
      //s is the sign bit
      //xxxx is the four bit value10 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value10 = (Xdiff10[n] - 64) / 4;

      Xenco8[n] = {3'b011,encoder_sign,value10[3:0]};
    end
  endtask

  task DPCM3_for_10_8_10_decoder;
    begin
      command1 = "DPCM3_for_10_8_10_decoder";
      //Xenco8[n] has the following format:
      //Xenco8[n] = 011 s xxxx
      //where,
      //010 is the code word
      //s is the sign bit
      //xxxx is the four bit value10 field

      //The decoder equa tion is described as follows:
      decoder_sign = Xenco8[n] & 8'h10;
      value10 = 4 * (Xenco8[n] & 8'hf) + 64 + 1;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;

          if ((Xpred10[n] + 1024) - value10 < 1024)
            begin
              Xdeco10[n] = 0;
            end
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;

          if (Xdeco10[n] > 1023)
            begin
              Xdeco10[n] = 1023;
            end
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask


  task PCM_for_10_8_10_coder;
    begin
      command1 = "PCM_for_10_8_10_coder";
      //Xenco8[n] has the following format:
      //Xenco8[n] = 1 xxxxxxx
      //where,
      //1 is the code word
      //the sign bit is not used
      //xxxxxxx is the seven bit value10 field

      //The coder equation is described as follows:
      value10 = Xorig10[n] / 8;


      Xenco8[n] = {1'b1,value10[6:0]};
    end
  endtask


  task PCM_for_10_8_10_decoder;
    begin
      command1 = "PCM_for_10_8_10_decoder";
      //Xenco8[n] has the following format:
      //Xenco8[n] = 1 xxxxxxx
      //where,
      //1 is the code word
      //the sign bit is not used
      //xxxxxxx is the seven bit value10 field

      //The codec equation is described as follows:
      value10 = 8 * (Xenco8[n] & 8'h7f);
      
    //  $display( "PCM value10 = %d " ,value10);
           if (value10 > Xpred10[n])
        begin
          Xdeco10[n] = value10 + 3;
        end
      else
        begin
          Xdeco10[n] = value10 + 4;
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

  task ten_7_ten;
    begin
      //////////////////predictor//////////////
      if(temp_prediction == 2'b01)
        begin
          if(n > 2)
            begin
              predictor1_10;
            end
        end
      else if(temp_prediction == 2'b10)
        begin
          if(n > 1)
            begin
              predictor2_10;
            end
        end
      //////////////////predictor//////////////

      //Encoders
      //Coder for 10810 Data Compression

      //Pixels without prediction are encoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xenco7[n] = Xorig10[n] / 8;
          //To avoid a full-zero encoded value10, the following check is performed:
          if (Xenco7[n] == 0)
            begin
              Xenco7[n] = 1;
            end
        end
      else
        begin
          Xdiff10_tsk;

          //Pixels with prediction are encoded using the following formula:
          if (Xdiff10[n] < 8)
            DPCM1_for_10_7_10_coder;//DPCM1;
          else if (Xdiff10[n] < 16)
            DPCM2_for_10_7_10_coder;//DPCM2;
          else if (Xdiff10[n] < 32)
            DPCM3_for_10_7_10_coder;//DPCM3;
          else if (Xdiff10[n] < 160)
            DPCM4_for_10_7_10_coder;//DPCM4;
          else
            PCM_for_10_7_10_coder;//PCM;
        end

      //////////////decoder/////////////
      // Pixels without prediction are decoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xdeco10[n] = 8 * Xenco7[n] + 4;
          //ten_sev_ten = 1'b1;
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
        end
      else
        begin
          //Pixels with prediction are decoded using the following formula:
          if ((Xenco7[n] & 7'h70) == 7'h00)
            DPCM1_for_10_7_10_decoder;
          else if ((Xenco7[n] & 7'h78) == 7'h10)
            DPCM2_for_10_7_10_decoder;
          else if ((Xenco7[n] & 7'h78) == 7'h18)
            DPCM3_for_10_7_10_decoder;
          else if ((Xenco7[n] & 7'h60) == 7'h20)
            DPCM4_for_10_7_10_decoder;
          else
            PCM_for_10_7_10_decoder;
        end
      //////////////decoder/////////////


    end
  endtask

  task DPCM1_for_10_7_10_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 000 s xxx
      //where,
      //000 is the code word
      //s is the sign bit
      //xxx is the three bit value10 field

      //The coder e quation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1 || Xdiff_equal_to_0 == 1'b1))
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value10 = Xdiff10[n];

      Xenco7[n] = {3'b000,encoder_sign,value10[2:0]};
    end
  endtask

  task DPCM1_for_10_7_10_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 000 s xxx
      //where,
      //000 is the code word
      //s is the sign bit
      //xxx is the three bit value10 field

      //The codec equation is described as follows:
      decoder_sign = Xenco7[n] & 7'h8;
      value10 = Xenco7[n] & 7'h7;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM2_for_10_7_10_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0010 s xx
      //where,
      //0010 is the code word
      //s is the sign bit
      //xx is the two bit value10 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value10 = (Xdiff10[n] - 8) / 2;

      Xenco7[n] = {4'b0010,encoder_sign,value10[1:0]};
    end
  endtask

  task DPCM2_for_10_7_10_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0010 s xx
      //where,
      //0010 is the code word
      //s is the sign bit
      //xx is the two bit value10 field

      //The codec equation is described as follows:
      decoder_sign = Xenco7[n] & 7'h4;
      value10 = 2 * (Xenco7[n] & 7'h3) + 8;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM3_for_10_7_10_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0011 s xx
      //where,
      //0011 is the code word
      //s is the sign bit
      //xx is the two bit value10 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value10 = (Xdiff10[n] - 16) / 4;

      Xenco7[n] = {4'b0011,encoder_sign,value10[1:0]};
    end
  endtask

  task DPCM3_for_10_7_10_decoder;
    begin
      command1 = "DPCM3_for_10_7_10_decoder";
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0011 s xx
      //where,
      //0011 is the code word
      //s is the sign bit
      //xx is the two bit value10 field

      //The codec equation is described as follows:
      decoder_sign = Xenco7[n] & 7'h4;
      value10 = 4 * (Xenco7[n] & 7'h3) + 16 + 1;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;
          if ((Xpred10[n] + 1024) - value10 < 1024)
            begin
              Xdeco10[n] = 0;
            end
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;
          if (Xdeco10[n] > 1023)
            begin
              Xdeco10[n] = 1023;
            end
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask


  task DPCM4_for_10_7_10_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 01 s xxxx
      //where,
      //01 is the code word
      //s is the sign bit
      //xxxx is the four bit value10 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value10 = (Xdiff10[n] - 32) / 8;

      Xenco7[n] = {2'b01,encoder_sign,value10[3:0]};
    end
  endtask

  task DPCM4_for_10_7_10_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 01 s xxxx
      //where,
      //01 is the code word
      //s is the sign bit
      //xxxx is the four bit value10 field

      //  The codec equation is described as follows:
      decoder_sign = Xenco7[n] & 7'h10;
      value10 = 8 * (Xenco7[n] & 7'hf) + 32 + 3;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;
          if ((Xpred10[n] + 1024) - value10 < 1024)
            begin
              Xdeco10[n] = 0;
            end
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;
          if (Xdeco10[n] > 1023)
            begin
              Xdeco10[n] = 1023;
            end
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask


  task PCM_for_10_7_10_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 1 xxxxxx
      //where,
      //1 is the code word
      //the sign bit is not used
      //xxxxxx is the six bit value10 field

      //The coder equation is described as follows:
      value10 = Xorig10[n] / 16;

      Xenco7[n] = {1'b1,value10[5:0]};
    end
  endtask

  task PCM_for_10_7_10_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 1 xxxxxx
      //where,
      //1 is the code word
      //the sign bit is not used
      //xxxxxx is the six bit value10 field

      //    The codec equation is described as follows:
      value10 = 16 * (Xenco7[n] & 7'h3f);
      if (value10 > Xpred10[n])
        begin
          Xdeco10[n] = value10 + 7;
        end
      else
        begin
          Xdeco10[n] = value10 + 8;
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

  task ten_6_ten;
    begin
      //////////////////predictor//////////////
      if(temp_prediction == 2'b01)
        begin
          if(n > 2)
            begin
              predictor1_10;
            end
        end
      else if(temp_prediction == 2'b10)
        begin
          if(n > 1)
            begin
              predictor2_10;
            end
        end
      //////////////////predictor//////////////
      //Encoders
      //Coder for 10610 Data Compression
      //Pixels without prediction are encoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xenco6[n] = Xorig10[n] / 16;
          //To avoid a full-zero encoded value10, the following check is performed:
          if (Xenco6[n] == 0)
            begin
              Xenco6[n] = 1;
            end
        end
      else
        begin
          Xdiff10_tsk;

          //Pixels with prediction are encoded using the following formula:
          if (Xdiff10[n] < 1)
            DPCM1_for_10_6_10_coder;//DPCM1;
          else if (Xdiff10[n] < 3)
            DPCM2_for_10_6_10_coder;//DPCM2;
          else if (Xdiff10[n] < 11)
            DPCM3_for_10_6_10_coder;//DPCM3;
          else if (Xdiff10[n] < 43)
            DPCM4_for_10_6_10_coder;//DPCM4;
          else if (Xdiff10[n] < 171)
            DPCM5_for_10_6_10_coder;//DPCM5;
          else
            PCM_for_10_6_10_coder;//PCM;
        end
      //////////////////encoder//////////////////

      //////////////decoder/////////////
      // Pixels without prediction are decoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xdeco10[n] = 16 * Xenco6[n] + 8;
          //ten_six_ten = 1'b1;
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
        end
      else
        begin
          //Pixels with prediction are decoded using the following formula:
          if ((Xenco6[n] & 6'h3e) == 6'h00)
            DPCM1_for_10_6_10_decoder;
          else if ((Xenco6[n] & 6'h3e) == 6'h02)
            DPCM2_for_10_6_10_decoder;
          else if ((Xenco6[n] & 6'h3c) == 6'h04)
            DPCM3_for_10_6_10_decoder;
          else if ((Xenco6[n] & 6'h38) == 6'h08)
            DPCM4_for_10_6_10_decoder;
          else if ((Xenco6[n] & 6'h30) == 6'h10)
            DPCM5_for_10_6_10_decoder;
          else
            PCM_for_10_6_10_decoder;
        end
      //////////////decoder/////////////



    end
  endtask

  task DPCM1_for_10_6_10_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 00000 s
      //where,
      //00000 is the code word
      //s is the sign bit
      //the value10 field is not used
      //The coder equation is described as follows:
      encoder_sign = 1'b1;

      Xenco6[n] = {5'b00000,encoder_sign};
    end
  endtask

  task DPCM1_for_10_6_10_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 00000 s
      //where,
      //00000 is the code word
      //s is the sign bit
      //the value10 field is not used

      //The codec equation is described as follows:
      Xdeco10[n] = Xpred10[n];
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask


  task DPCM2_for_10_6_10_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 00001 s
      //where,
      //00001 is the code word
      //s is the sign bit
      //the value10 field is not used

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      Xenco6[n] = {5'b00001,encoder_sign};
    end
  endtask

  task DPCM2_for_10_6_10_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 00001 s
      //where,
      //00001 is the code word
      //s is the sign bit
      //the value10 field is not used

      //    The codec equation is described as follows:
      decoder_sign = Xenco6[n] & 6'h1;
      value10 = 1;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM3_for_10_6_10_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 0001 s x
      //where,
      //0001 is the code word
      //s is the sign bit
      //x is the one bit value10 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value10 = (Xdiff10[n] - 3) / 4;

      Xenco6[n] = {4'b0001,encoder_sign,value10[0]};
    end
  endtask

  task DPCM3_for_10_6_10_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 0001 s x
      //where,
      //0001 is the code word
      //s is the sign bit
      //x is the one bit value10 field

      //  The codec equation is described as follows:
      decoder_sign = Xenco6[n] & 6'h2;
      value10 = 4 * (Xenco6[n] & 6'h1) + 3 + 1;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;
          if ((Xpred10[n] + 1024) - value10 < 1024)
            begin
              Xdeco10[n] = 0;
            end
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;
          if (Xdeco10[n] > 1023)
            begin
              Xdeco10[n] = 1023;
            end
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM4_for_10_6_10_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 001 s xx
      //where,
      //001 is the code word
      //s is the sign bit
      //xx is the two bit value10 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value10 = (Xdiff10[n] - 11) / 8;

      Xenco6[n] = {3'b001,encoder_sign,value10[1:0]};
    end
  endtask

  task DPCM4_for_10_6_10_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 001 s xx
      //where,
      //001 is the code word
      //s is the sign bit
      //xx is the two bit value10 field

      //The codec equation is described as follows:
      decoder_sign = Xenco6[n] & 6'h4;
      value10 = 8 * (Xenco6[n] & 6'h3) + 11 + 3;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;
          if ((Xpred10[n] + 1024) - value10 < 1024)
            begin
              Xdeco10[n] = 0;
            end
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;
          if (Xdeco10[n] > 1023)
            begin
              Xdeco10[n] = 1023;
            end
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM5_for_10_6_10_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 01 s xx
      //where,
      //01 is the code word
      //s is the sign bit
      //xxx is the three bit value10 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value10 = (Xdiff10[n] - 43) / 16;

      Xenco6[n] = {2'b01,encoder_sign,value10[2:0]};
    end
  endtask

  task DPCM5_for_10_6_10_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 01 s xx
      //where,
      //01 is the code word
      //s is the sign bit
      //xxx is the three bit value10 field

      //The codec equation is described as follows:
      decoder_sign = Xenco6[n] & 6'h8;
      value10 = 16 * (Xenco6[n] & 6'h7) + 43 + 7;
      if (decoder_sign > 8'h0)
        begin
          Xdeco10[n] = Xpred10[n] - value10;
          if ((Xpred10[n] + 1024) - value10 < 1024)
            begin
              Xdeco10[n] = 0;
            end
        end
      else
        begin
          Xdeco10[n] = Xpred10[n] + value10;
          if (Xdeco10[n] > 1023)
            begin
              Xdeco10[n] = 1023;
            end
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task PCM_for_10_6_10_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 1 xxxxx
      //where,
      //1 is the code word
      //the sign bit is not used
      //xxxxxx is the five bit value10 field

      //The coder equation is described as follows:
      value10 = Xorig10[n] / 32;

      Xenco6[n] = {1'b1,value10[4:0]};
    end
  endtask


  task PCM_for_10_6_10_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 1 xxxxx
      //where,
      //1 is the code word
      //the sign bit is not used
      //xxxxxx is the five bit value10 field
      //
      //The codec equation is described as follows:
      value10 = 32 * (Xenco6[n] & 6'h1f);
      if (value10 > Xpred10[n])
        begin
          Xdeco10[n] = value10 + 15;
        end
      else
        begin
          Xdeco10[n] = value10 + 16;
        end
          compression_data[compress_cnt] = Xdeco10[n][9:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task tw_8_tw;
    begin
      //////////////////predictor//////////////
      if(temp_prediction == 2'b01)
        begin
          if(n > 2)
            begin
              predictor1_12;
            end
        end
      else if(temp_prediction == 2'b10)
        begin
          if(n > 1)
            begin
              predictor2_12;
            end
        end
      //////////////////predictor//////////////
      //////////////////encoder//////////////////
      //Encoders
      //Coder for 12812 Data Compression

      //Pixels without prediction are encoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xenco8[n] = Xorig12[n] / 16;
          //To avoid a full-zero encoded value12, the following check is performed:
          if (Xenco8[n] == 0)
            begin
              Xenco8[n] = 1;
            end
        end
      else
        begin
          Xdiff12_tsk;

          //Pixels with prediction are encoded using the following formula:
          if (Xdiff12[n] < 8)
            DPCM1_for_12_8_12_coder;//DPCM1;
           // $display ("DPCM1");
          else if (Xdiff12[n] < 40)
            DPCM2_for_12_8_12_coder;//DPCM2;
          //  $display ("DPCM1");
          else if (Xdiff12[n] < 104)
            DPCM3_for_12_8_12_coder;//DPCM3;
           // $display ("DPCM1");
          else if (Xdiff12[n] < 232)
            DPCM4_for_12_8_12_coder;//DPCM4;
           // $display ("DPCM1");
          else if (Xdiff12[n] < 360)
            DPCM5_for_12_8_12_coder;//DPCM5;
           // $display ("DPCM1");
          else
            PCM_for_12_8_12_coder;//PCM;
        end
      //////////////////encoder//////////////////

      //////////////decoder/////////////
      // Pixels without prediction are decoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xdeco12[n] = 16 * Xenco8[n] + 8;
          //tw_six_tw = 1'b1;
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
        end
      else
        begin
          //Pixels with prediction are decoded using the following formula:
          if ((Xenco8[n] & 8'hf0) == 8'h00) begin
           // $display ("DPCM1");
            DPCM1_for_12_8_12_decoder;
          end else if ((Xenco8[n] & 8'he0) == 8'h60) begin
          //  $display ("DPCM2");
            DPCM2_for_12_8_12_decoder;
          end else if ((Xenco8[n] & 8'he0) == 8'h40) begin
           // $display ("DPCM3");
            DPCM3_for_12_8_12_decoder;
          end else if ((Xenco8[n] & 8'he0) == 8'h20)begin
           // $display ("DPCM4");
            DPCM4_for_12_8_12_decoder;
          end else if ((Xenco8[n] & 8'hf0) == 8'h10)begin
           // $display ("DPCM5");
            DPCM5_for_12_8_12_decoder;
          end else begin
           // $display ("PCM");
            PCM_for_12_8_12_decoder;
          end
        end
      //////////////decoder/////////////


    end
  endtask

  task DPCM1_for_12_8_12_coder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 0000 s xxx
      //where,
      //0000 is the code word
      //s is the sign bit
      //xxx is the three bit value12 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1 || Xdiff_equal_to_0 == 1'b1))
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = Xdiff12[n];

      Xenco8[n] = {4'b0000,encoder_sign,value12[2:0]};
    end
  endtask


  task DPCM1_for_12_8_12_decoder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 0000 s xxx
      //where,
      //0000 is the code word
      //s is the sign bit
      //xxx is the three bit value12 field

      //The coder equation is described as follows:
      decoder_sign = Xenco8[n] & 8'h08;
      value12 = Xenco8[n] & 8'h07;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask


  task DPCM2_for_12_8_12_coder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 011 s xxxx
      //where,
      //011 is the code word
      //s is the sign bit
      //xxxx is the four bit value12 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 8) / 2;

      Xenco8[n] = {3'b011,encoder_sign,value12[3:0]};
    end
  endtask

  task DPCM2_for_12_8_12_decoder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 011 s xxxx
      //where,
      //011 is the code word
      //s is the sign bit
      //xxxx is the four bit value12 field

      //The decoder equation is described as follows:
      decoder_sign = Xenco8[n] & 8'h10;
      value12 = 2 * (Xenco8[n] & 8'hf) + 8;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask


  task DPCM3_for_12_8_12_coder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 010 s xxxx
      //where,
      //010 is the code word
      //s is the sign bit
      //xxxx is the four bit value12 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 40) / 4;

      Xenco8[n] = {3'b010,encoder_sign,value12[3:0]};

    end
  endtask

  task DPCM3_for_12_8_12_decoder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 010 s xxxx
      //where,
      //010 is the code word
      //s is the sign bit
      //xxxx is the four bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco8[n] & 8'h10;
      value12 = 4 * (Xenco8[n] & 8'hf) + 40 + 1;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM4_for_12_8_12_coder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 001 s xxxx
      //where,
      //001 is the code word
      //s is the sign bit
      //xxxx is the four bit value12 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 104) / 8;

      Xenco8[n] = {3'b001,encoder_sign,value12[3:0]};
    end
  endtask

  task DPCM4_for_12_8_12_decoder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 001 s xxxx
      //where,
      //001 is the code word
      //s is the sign bit
      //xxxx is the four bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco8[n] & 8'h10;
      value12 = 8 * (Xenco8[n] & 8'hf) + 104 + 3;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM5_for_12_8_12_coder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 0001 s xxx
      //where,
      //0001 is the code word
      //s is the sign bit
      //xxx is the three bit value12 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 232) / 16;

      Xenco8[n] = {4'b0001,encoder_sign,value12[2:0]};
    end
  endtask

  task DPCM5_for_12_8_12_decoder;
    begin
      //    //Xenco8[n] has the following format:
      //    //Xenco8[n] = 001 s xxxx
      //    //where,
      //    //001 is the code word
      //    //s is the sign bit
      //    //xxxx is the four bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco8[n] & 8'h08;
      value12 = 16 * (Xenco8[n] & 8'h7) + 232 + 7;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task PCM_for_12_8_12_coder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 1 xxxxxxx
      //where,
      //1 is the code word
      //the sign bit is not used
      //xxxxxxx is the seven bit value12 field

      //The coder equation is described as follows:
      value12 = Xorig12[n] / 32;

      Xenco8[n] = {1'b1,value12[6:0]};
    end
  endtask


  task PCM_for_12_8_12_decoder;
    begin
      //Xenco8[n] has the following format:
      //Xenco8[n] = 1 xxxxxxx
      //where,
      //1 is the code word
      //the sign bit is not used
      //xxxxxxx is the seven bit value12 field

      //The codec equation is described as follows:
      value12 = 32 * (Xenco8[n] & 8'h7f);
      if (value12 > Xpred12[n])
        begin
          Xdeco12[n] = value12 + 15;
        end
      else
        begin
          Xdeco12[n] = value12 + 16;
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

  task tw_7_tw;
    begin
      //////////////////predictor//////////////
      if(temp_prediction == 2'b01)
        begin
          if(n > 2)
            begin
              predictor1_12;
            end
        end
      else if(temp_prediction == 2'b10)
        begin
          if(n > 1)
            begin
              predictor2_12;
            end
        end
      //////////////////predictor//////////////
      //////////////////encoder//////////////////
      //Encoders
      //Coder for 12712 Data Compression

      //Pixels without prediction are encoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xenco7[n] = Xorig12[n] / 32;
          //To avoid a full-zero encoded value12, the following check is performed:
          if (Xenco7[n] == 0)
            begin
              Xenco7[n] = 1;
            end

        end
      else
        begin
          Xdiff12_tsk;

          //Pixels with prediction are encoded using the following formula:
          if (Xdiff12[n] < 4)
            DPCM1_for_12_7_12_coder;//DPCM1;
          else if (Xdiff12[n] < 12)
            DPCM2_for_12_7_12_coder;//DPCM2;
          else if (Xdiff12[n] < 28)
            DPCM3_for_12_7_12_coder;//DPCM3;
          else if (Xdiff12[n] < 92)
            DPCM4_for_12_7_12_coder;//DPCM4;
          else if (Xdiff12[n] < 220)
            DPCM5_for_12_7_12_coder;//DPCM5;
          else if (Xdiff12[n] < 348)
            DPCM6_for_12_7_12_coder;//DPCM6;
          else
            PCM_for_12_7_12_coder;//PCM;
        end
      //////////////////encoder//////////////////

      //////////////decoder/////////////
      // Pixels without temp_prediction are decoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xdeco12[n] = 32 * Xenco7[n] + 16;
          //tw_sev_tw = 1'b1;
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
        end
      else
        begin
          //Pixels with temp_prediction are decoded using the following formula:
          if ((Xenco7[n] & 7'h78) == 8'h00)
            DPCM1_for_12_7_12_decoder;
          else if ((Xenco7[n] & 8'h78) == 8'h08)
            DPCM2_for_12_7_12_decoder;
          else if ((Xenco7[n] & 8'h78) == 8'h10)
            DPCM3_for_12_7_12_decoder;
          else if ((Xenco7[n] & 8'h70) == 8'h20)
            DPCM4_for_12_7_12_decoder;
          else if ((Xenco7[n] & 8'h70) == 8'h30)
            DPCM5_for_12_7_12_decoder;
          else if ((Xenco7[n] & 8'h78) == 8'h18)
            DPCM6_for_12_7_12_decoder;
          else
            PCM_for_12_7_12_decoder;
        end
      //////////////decoder/////////////


    end
  endtask

  task DPCM1_for_12_7_12_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0000 s xx
      //where,
      //0000 is the code word
      //s is the sign bit
      //xx is the two bit value12 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1 || Xdiff_equal_to_0 == 1'b1))
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = Xdiff12[n];

      Xenco7[n] = {4'b0000,encoder_sign,value12[1:0]};
    end
  endtask


  task DPCM1_for_12_7_12_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0000 s xx
      //where,
      //0000 is the code word
      //s is the sign bit
      //xx is the two bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco7[n] & 8'h04;
      value12 = Xenco7[n] & 8'h03;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask


  task DPCM2_for_12_7_12_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0001 s xx
      //where,
      //0001 is the code word
      //s is the sign bit
      //xx is the two bit value12 field

      //The coder equation is described as follows:
      //if (Xdiff12[n] < 0)
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 4) / 2;

      Xenco7[n] = {4'b0001,encoder_sign,value12[1:0]};
    end
  endtask

  task DPCM2_for_12_7_12_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0001 s xx
      //where,
      //0001 is the code word
      //s is the sign bit
      //xx is the two bit value12 field

      //The decoder equation is described as follows:
      decoder_sign = Xenco7[n] & 8'h4;
      value12 = 2 * (Xenco7[n] & 8'h3) + 4;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask


  task DPCM3_for_12_7_12_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0010 s xx
      //where,
      //0010 is the code word
      //s is the sign bit
      //xx is the two bit value12 field

      //The coder equation is described as follows:
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 12) / 4;

      Xenco7[n] = {4'b0010,encoder_sign,value12[1:0]};
    end
  endtask

  task DPCM3_for_12_7_12_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0010 s xx
      //where,
      //0010 is the code word
      //s is the sign bit
      //xx is the two bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco7[n] & 8'h4;
      value12 = 4 * (Xenco7[n] & 8'h3) + 12 + 1;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM4_for_12_7_12_coder;
    begin
      //Xenco7[n] = 010 s xxx
      //where,
      //010 is the code word
      //s is the sign bit
      //xxx is the three bit value12 field

      //The coder equation is described as follows:
      //if (Xdiff12[n] < 0)
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 28) / 8;

      Xenco7[n] = {3'b010,encoder_sign,value12[2:0]};
    end
  endtask

  task DPCM4_for_12_7_12_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 010 s xxx
      //where,
      //010 is the code word
      //s is the sign bit
      //xxx is the three bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco7[n] & 8'h8;
      value12 = 8 * (Xenco7[n] & 8'h7) + 28 + 3;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM5_for_12_7_12_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 011 s xxx
      //where,
      //011 is the code word
      //s is the sign bit
      //xxx is the three bit value12 field

      //The coder equation is described as follows:
      //if (Xdiff12[n] < 0)
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 92) / 16;

      Xenco7[n] = {3'b011,encoder_sign,value12[2:0]};
    end
  endtask

  task DPCM5_for_12_7_12_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 011 s xxx
      //where,
      //011 is the code word
      //s is the sign bit
      //xxx is the three bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco7[n] & 8'h08;
      value12 = 16 * (Xenco7[n] & 8'h7) + 92 + 7;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM6_for_12_7_12_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0011 s xx
      //where,
      //0011 is the code word
      //s is the sign bit
      //xx is the two bit value12 field

      //The coder equation is described as follows:
      //if (Xdiff12[n] < 0)
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 220) / 32;

      Xenco7[n] = {4'b0011,encoder_sign,value12[1:0]};
    end
  endtask

  task DPCM6_for_12_7_12_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 0011 s xx
      //where,
      //0011 is the code word
      //s is the sign bit
      //xx is the two bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco7[n] & 8'h4;
      value12 = 32 * (Xenco7[n] & 8'h3) + 220 + 15;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task PCM_for_12_7_12_coder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 1 xxxxxx
      //where,
      //1 is the code word
      //the sign bit is not used
      //xxxxxx is the six bit value12 field

      //The coder equation is described as follows:
      value12 = Xorig12[n] / 64;

      Xenco7[n] = {1'b1,value12[5:0]};
    end
  endtask


  task PCM_for_12_7_12_decoder;
    begin
      //Xenco7[n] has the following format:
      //Xenco7[n] = 1 xxxxxxx
      //where,
      //1 is the code word
      //the sign bit is not used
      //xxxxxxx is the seven bit value12 field

      //The codec equation is described as follows:
      value12 = 64 * (Xenco7[n] & 8'h3f);
      if (value12 > Xpred12[n])
        begin
          Xdeco12[n] = value12 + 31;
        end
      else
        begin
          Xdeco12[n] = value12 + 32;
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

  task tw_6_tw;
    begin
      //////////////////predictor//////////////
      if(temp_prediction == 2'b01)
        begin
          if(n > 2)
            begin
              predictor1_12;
            end
        end
      else if(temp_prediction == 2'b10)
        begin
          if(n > 1)
            begin
              predictor2_12;
            end
        end
      //////////////////predictor//////////////
      //////////////////encoder//////////////////
      //Encoders
      //Coder for 12-7-12 Data Compression

      //Pixels without temp_prediction are encoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xenco6[n] = Xorig12[n] / 64;
          //To avoid a full-zero encoded value12, the following check is performed:
          if (Xenco6[n] == 0)
            begin
              Xenco6[n] = 1;
            end
        end
      else
        begin
          Xdiff12_tsk;

          //Pixels with temp_prediction are encoded using the following formula:
          if (Xdiff12[n] < 2)
            DPCM1_for_12_6_12_coder;//DPCM1;
          else if (Xdiff12[n] < 10)
            DPCM3_for_12_6_12_coder;//DPCM3;
          else if (Xdiff12[n] < 42)
            DPCM4_for_12_6_12_coder;//DPCM4;
          else if (Xdiff12[n] < 74)
            DPCM5_for_12_6_12_coder;//DPCM5;
          else if (Xdiff12[n] < 202)
            DPCM6_for_12_6_12_coder;//DPCM6;
          else if (Xdiff12[n] < 330)
            DPCM7_for_12_6_12_coder;//DPCM7;
          else
            PCM_for_12_6_12_coder;//PCM;
        end
      //////////////////encoder//////////////////

      //////////////decoder/////////////
      // Pixels without temp_prediction are decoded using the following formula:
      if((temp_prediction == 2'b01 && (n == 1 || n == 2)) || (temp_prediction == 2'b10 && n == 1))
        begin
          Xdeco12[n] = 64 * Xenco6[n] + 32;
          //tw_eit_tw = 1'b1;
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
        end
      else
        begin
          //Pixels with temp_prediction are decoded using the following formula:
          if ((Xenco6[n] & 7'h3c) == 8'h00)
            DPCM1_for_12_6_12_decoder;
          else if ((Xenco6[n] & 8'h3c) == 8'h04)
            DPCM3_for_12_6_12_decoder;
          else if ((Xenco6[n] & 8'h38) == 8'h10)
            DPCM4_for_12_6_12_decoder;
          else if ((Xenco6[n] & 8'h3c) == 8'h08)
            DPCM5_for_12_6_12_decoder;
          else if ((Xenco6[n] & 8'h38) == 8'h18)
            DPCM6_for_12_6_12_decoder;
          else if ((Xenco6[n] & 8'h3c) == 8'h0c)
            DPCM7_for_12_6_12_decoder;
          else
            PCM_for_12_6_12_decoder;
        end
      //////////////decoder/////////////


    end
  endtask

  task DPCM1_for_12_6_12_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 0000 s x
      //where,
      //0000 is the code word
      //s is the sign bit
      //x is the one bit value12 field
      //
      //The coder equation is described as follows:
      //if (Xdiff12[n] <= 0)
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1 || Xdiff_equal_to_0 == 1'b1))
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = Xdiff12[n];

      Xenco6[n] = {4'b0000,encoder_sign,value12[0]};
    end
  endtask


  task DPCM1_for_12_6_12_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 0000 s x
      //where,
      //0000 is the code word
      //s is the sign bit
      //x is the one bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco6[n] & 8'h02;
      value12 = Xenco6[n] & 8'h01;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask


  task DPCM3_for_12_6_12_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 0001 s x
      //where,
      //0001 is the code word
      //s is the sign bit
      //x is the one bit value12 field

      //The coder equation is described as follows:
      //if (Xdiff12[n] < 0)
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 2) / 4;

      Xenco6[n] = {4'b0001,encoder_sign,value12[0]};
    end
  endtask

  task DPCM3_for_12_6_12_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 0001 s x
      //where,
      //0001 is the code word
      //s is the sign bit
      //x is the one bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco6[n] & 8'h2;
      value12 = 4 * (Xenco6[n] & 8'h1) + 2 + 1;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM4_for_12_6_12_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 010 s xx
      //where,
      //010 is the code word
      //s is the sign bit
      //xx is the two bit value12 field

      //The coder equation is described as follows:
      //if (Xdiff12[n] < 0)
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 10) / 8;

      Xenco6[n] = {3'b010,encoder_sign,value12[1:0]};
    end
  endtask

  task DPCM4_for_12_6_12_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 010 s xx
      //where,
      //010 is the code word
      //s is the sign bit
      //xx is the two bit value12 field

      //The codec equation is described as follows:
      decoder_sign = Xenco6[n] & 8'h4;
      value12 = 8 * (Xenco6[n] & 8'h3) + 10 + 3;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM5_for_12_6_12_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 0010 s x
      //where,
      //0010 is the code word
      //s is the sign bit
      //x is the one bit value12 field

      //The coder equation is described as follows:
      //if (Xdiff12[n] < 0)
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 42) / 16;

      Xenco6[n] = {4'b0010,encoder_sign,value12[0]};
    end
  endtask

  task DPCM5_for_12_6_12_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 0010 s x

      //The codec equation is described as follows:
      decoder_sign = Xenco6[n] & 8'h02;
      value12 = 16 * (Xenco6[n] & 8'h1) + 42 + 7;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM6_for_12_6_12_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 011 s xx

      //The coder equation is described as follows:
      //if (Xdiff12[n] < 0)
      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 74) / 32;

      Xenco6[n] = {3'b011,encoder_sign,value12[1:0]};
    end
  endtask

  task DPCM6_for_12_6_12_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 011 s xx

      //The codec equation is described as follows:
      decoder_sign = Xenco6[n] & 8'h4;
      value12 = 32 * (Xenco6[n] & 8'h3) + 74 + 15;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task DPCM7_for_12_6_12_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 0011 s x

      if(Xdiff_grt_than_0 == 1'b0 && (Xdiff_les_than_0 == 1'b1) && Xdiff_equal_to_0 == 1'b0)
        begin
          encoder_sign = 1'b1;
        end
      else
        begin
          encoder_sign = 1'b0;
        end
      value12 = (Xdiff12[n] - 202) / 64;

      Xenco6[n] = {4'b0011,encoder_sign,value12[0]};
    end
  endtask

  task DPCM7_for_12_6_12_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 0011 s x

      //The codec equation is described as follows:
      decoder_sign = Xenco6[n] & 8'h2;
      value12 = 64 * (Xenco6[n] & 8'h1) + 202 + 31;
      if (decoder_sign > 8'h0)
        begin
          Xdeco12[n] = Xpred12[n] - value12;

          if ((Xpred12[n] + 4096) - value12 < 4096)
            begin
              Xdeco12[n] = 0;
            end
        end
      else
        begin
          Xdeco12[n] = Xpred12[n] + value12;

          if (Xdeco12[n] > 4095)
            begin
              Xdeco12[n] = 4095;
            end
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  task PCM_for_12_6_12_coder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 1 xxxxx

      //The coder equation is described as follows:
      value12 = Xorig12[n] / 128;

      Xenco6[n] = {1'b1,value12[4:0]};
    end
  endtask


  task PCM_for_12_6_12_decoder;
    begin
      //Xenco6[n] has the following format:
      //Xenco6[n] = 1 xxxxx

      //The codec equation is described as follows:
      value12 = 128 * (Xenco6[n] & 8'h1f);
      if (value12 > Xpred12[n])
        begin
          Xdeco12[n] = value12 + 63;
        end
      else
        begin
          Xdeco12[n] = value12 + 64;
        end
          compression_data[compress_cnt] = Xdeco12[n][11:0];
          compress_cnt = compress_cnt + 1;
    end
  endtask

  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

  task Xdiff10_tsk;
    begin
      Xdiff_grt_than_0 = 1'b0;
      Xdiff_les_than_0 = 1'b0;
      Xdiff_equal_to_0 = 1'b0;

      if(Xorig10[n] > Xpred10[n])
        begin
          Xdiff10[n] = (Xorig10[n] - Xpred10[n]);
          Xdiff_grt_than_0 = 1'b1;
          Xdiff_les_than_0 = 1'b0;
          Xdiff_equal_to_0 = 1'b0;
        end
      else if(Xorig10[n] < Xpred10[n])
        begin
          Xdiff10[n] = (Xpred10[n] - Xorig10[n]);
          Xdiff_grt_than_0 = 1'b0;
          Xdiff_les_than_0 = 1'b1;
          Xdiff_equal_to_0 = 1'b0;
        end
      else if(Xorig10[n] == Xpred10[n])
        begin
          Xdiff10[n] = (Xpred10[n] - Xorig10[n]);
          Xdiff_grt_than_0 = 1'b0;
          Xdiff_les_than_0 = 1'b0;
          Xdiff_equal_to_0 = 1'b1;
        end

    end
  endtask

  task Xdiff12_tsk;
    begin
      Xdiff_grt_than_0 = 1'b0;
      Xdiff_les_than_0 = 1'b0;
      Xdiff_equal_to_0 = 1'b0;

      if(Xorig12[n] > Xpred12[n])
        begin
          Xdiff12[n] = (Xorig12[n] - Xpred12[n]);
          Xdiff_grt_than_0 = 1'b1;
          Xdiff_les_than_0 = 1'b0;
          Xdiff_equal_to_0 = 1'b0;
        end
      else if(Xorig12[n] < Xpred12[n])
        begin
          Xdiff12[n] = (Xpred12[n] - Xorig12[n]);
          Xdiff_grt_than_0 = 1'b0;
          Xdiff_les_than_0 = 1'b1;
          Xdiff_equal_to_0 = 1'b0;
        end
      else if(Xorig12[n] == Xpred12[n])
        begin
          Xdiff12[n] = (Xpred12[n] - Xorig12[n]);
          Xdiff_grt_than_0 = 1'b0;
          Xdiff_les_than_0 = 1'b0;
          Xdiff_equal_to_0 = 1'b1;
        end
    end
  endtask


  task predictor1_10;
    begin
      //Predictor1 uses only the previous same color component value as the prediction value. Therefore, only a
      //two-pixel deep memory is required.
      //The first two pixels (C00, C11 / C20, C31 or as in example G0, R1 / B0, G1) in a line are encoded without
      //prediction.

      //The prediction values for the remaining pixels in the line are calculated using the previous same color
      //decoded value, Xdeco. Therefore, the predictor equation can be written as follows:
      Xpred10[n] = Xdeco10[n-2];
    end
  endtask

  task predictor1_12;
    begin
      //Predictor1 uses only the previous same color component value as the prediction value. Therefore, only a
      //two-pixel deep memory is required.
      //The first two pixels (C00, C11 / C20, C31 or as in example G0, R1 / B0, G1) in a line are encoded without
      //prediction.

      //The prediction values for the remaining pixels in the line are calculated using the previous same color
      //decoded value, Xdeco. Therefore, the predictor equation can be written as follows:
      Xpred12[n] = Xdeco12[n-2];
    end
  endtask

  task predictor2_10;
    begin

      //The second pixel (C11 / C31 or as in example R1 / G1) in a line is predicted using the previous decoded
      //different color value as a prediction value. The predictor equation for the second pixel is shown below:
      if(n == 2)
        begin
          Xpred10[n] = Xdeco10[n-1];
        end

      //The third pixel (C02 / C22 or as in example G2 / B2) in a line is predicted using the previous decoded same
      //color value as a prediction value. The predictor equation for the third pixel is shown below:
      else if(n == 3)
        begin
          Xpred10[n] = Xdeco10[n-2];
        end

      //The fourth pixel (C13 / C33 or as in example R3 / G3) in a line is predicted using the following equation:
      else if(n == 4)
        begin
          if ((Xdeco10[n-1] <= Xdeco10[n-2] && Xdeco10[n-2] <= Xdeco10[n-3]) ||
            (Xdeco10[n-1] >= Xdeco10[n-2] && Xdeco10[n-2] >= Xdeco10[n-3]))
            begin
              Xpred10[n] = Xdeco10[n-1];
            end
          else
            begin
              Xpred10[n] = Xdeco10[n-2];
            end
        end

      //Other pixels in all lines are predicted using the equation:
      else
        begin
          if ((Xdeco10[n-1] <= Xdeco10[n-2] && Xdeco10[n-2] <= Xdeco10[n-3]) ||
            (Xdeco10[n-1] >= Xdeco10[n-2] && Xdeco10[n-2] >= Xdeco10[n-3]))
            begin
              Xpred10[n] = Xdeco10[n-1];
            end

          else if ((Xdeco10[n-1] <= Xdeco10[n-3] && Xdeco10[n-2] <= Xdeco10[n-4]) ||
            (Xdeco10[n-1] >= Xdeco10[n-3] && Xdeco10[n-2] >= Xdeco10[n-4]))
            begin
              Xpred10[n] = Xdeco10[n-2];
            end
          else
            begin
              temp_val = (Xdeco10[n-2] + Xdeco10[n-4] + 10'h1);
              Xpred10[n] = temp_val / 10'h2;
            end
        end
    end
  endtask

  task predictor2_12;
    begin

      //The second pixel (C11 / C31 or as in example R1 / G1) in a line is predicted using the previous decoded
      //different color value as a prediction value. The predictor equation for the second pixel is shown below:
      if(n == 2)
        begin
          Xpred12[n] = Xdeco12[n-1];
        end

      //The third pixel (C02 / C22 or as in example G2 / B2) in a line is predicted using the previous decoded same
      //color value as a prediction value. The predictor equation for the third pixel is shown below:
      else if(n == 3)
        begin
          Xpred12[n] = Xdeco12[n-2];
        end

      //The fourth pixel (C13 / C33 or as in example R3 / G3) in a line is predicted using the following equation:
      else if(n == 4)
        begin
          if ((Xdeco12[n-1] <= Xdeco12[n-2] && Xdeco12[n-2] <= Xdeco12[n-3]) ||
            (Xdeco12[n-1] >= Xdeco12[n-2] && Xdeco12[n-2] >= Xdeco12[n-3]))
            begin
              Xpred12[n] = Xdeco12[n-1];
            end
          else
            begin
              Xpred12[n] = Xdeco12[n-2];
            end
        end

      //Other pixels in all lines are predicted using the equation:
      else
        begin
          if ((Xdeco12[n-1] <= Xdeco12[n-2] && Xdeco12[n-2] <= Xdeco12[n-3]) ||
            (Xdeco12[n-1] >= Xdeco12[n-2] && Xdeco12[n-2] >= Xdeco12[n-3]))
            begin
              Xpred12[n] = Xdeco12[n-1];
            end

          else if ((Xdeco12[n-1] <= Xdeco12[n-3] && Xdeco12[n-2] <= Xdeco12[n-4]) ||
            (Xdeco12[n-1] >= Xdeco12[n-3] && Xdeco12[n-2] >= Xdeco12[n-4]))
            begin
              Xpred12[n] = Xdeco12[n-2];
            end
          else
            begin
              temp_val2 = (Xdeco12[n-2] + Xdeco12[n-4] + 12'h1);
              Xpred12[n] =  temp_val2 /12'h2;
            end
        end
    end
  endtask

//////////////////////////////////////////////////////////////////////
// Randomization
//////////////////////////////////////////////////////////////////////
 task random_test;
   input random_en_ip;     // Enables randomization process
   input [15:0]time_in1;   // Random seed first value
   input [23:0]time_in2;   // Random seed second value
   begin
     `ifdef FIXED_SEED
     fixed_seed_en = 1'b1;
     rand_seed_in = {time_in1,time_in2};
     `else
     fixed_seed_en = 1'b0;
     `endif
     random_en = random_en_ip;
     $display($time,"\tCSI2 PKT INTERFACE BFM : random_enable");
     rand_seed_gen;
   end
 endtask

 task rand_seed_gen;
 begin
   `ifdef FIXED_SEED
   `else
   $readmemh("time.txt",time_val);
   `endif
   if (fixed_seed_en)
   begin
     rand_seed = rand_seed_in;
     $display ($time,"\tCSI2 PKT INTERFACE BFM : Random Seed value source is pkt_interface_cmd.v\n");
   end  
   else
   begin
     rand_seed = time_val[0];
     $display ($time,"\tCSI2 PKT INTERFACE BFM : Random Seed value source is time.txt\n");
   end
   #1;
   $display($time,"\tCSI2 PKT INTERFACE BFM : NOTE - The rand seed value(Hex) is %h\n",rand_seed);
 end
 endtask
 
    task multiple;
    input [5:0] temp_data_type;
    begin
     

    end
  endtask

  task rand_wc_gen;
    input [5:0] temp_data_type;
    begin
      case(temp_data_type)

        6'h10,6'h11,6'h12,6'h13,
        6'h14,6'h15,6'h16,6'h17,
        6'h2a,6'h30,6'h31,6'h32,
        6'h33,6'h34,6'h35,6'h36,
        6'h37:                    min_val_wc = 40'h1;
        6'h18,6'h22,6'h1c :       min_val_wc = 40'h2;
        6'h24,6'h28,6'h2c,6'h1a : min_val_wc = 40'h3;
        6'h1e,6'h20:              min_val_wc = 40'h4;
        6'h19,6'h2b,6'h1d,6'h1f:  min_val_wc = 40'h5;
        6'h29,6'h2d:              min_val_wc = 40'h7;
        6'h23:                    min_val_wc = 40'h9;
        6'h21:                    min_val_wc = 40'h10;
        default:                  min_val_wc = 40'h1;

      endcase
      case(temp_data_type)
        default     : max_val_wc = 40'd4000;
      endcase
      rand_wc     = $dist_uniform(rand_seed,min_val_wc,max_val_wc);

      rand_wc_op  =  rand_wc - (rand_wc % min_val_wc);
    end
  endtask
    task rand_wc_gen_comp;

    input [2:0] comp_type;
    input       dec_10_bit;
    input       dec_12_bit;
    begin
      if (dec_10_bit)
      begin
        case (comp_type)
          3'd1:min_val_wc_comp = 40'd5  ; //10-8-10 
          3'd2:min_val_wc_comp = 40'd70 ; //10-7-10
          3'd3:min_val_wc_comp = 40'd15 ; //10-6-10
          //default :
        endcase
      end
      else if (dec_12_bit)
      begin
      begin
        case (comp_type)
          3'd1:min_val_wc_comp = 40'd3;  //8'd3;  //12-8-12
          3'd2:min_val_wc_comp = 40'd84; //12-7-12
          3'd3:min_val_wc_comp = 40'd6;  //12-6-12
          //default :
        endcase
      end

      end
      rand_wc_comp     = $dist_uniform(rand_seed,min_val_wc_comp,4000);
      rand_wc_op_comp  =  rand_wc_comp - (rand_wc_comp % min_val_wc_comp);
    end

  endtask

  /*----------------------------------------------------------------------------
    INITIALIZE THE ENABLES OF DATA FORMATS
  ----------------------------------------------------------------------------*/
  task initialize;
    begin
      rgb444_en 	 	 	 = 0;
      rgb555_en 	 	 	 = 0;      
      rgb565_en 	 	 	 = 0;
      rgb666_en 	 	 	 = 0;       
      rgb888_en 	 	 	 = 0;  
      raw6_en   	 	 	 = 0; 
      raw7_en   	 	 	 = 0;          
      raw8_en   	 	 	 = 0;          
      gen_null  	 	 	 = 0;          
      gen_blank  	     = 0;          
      gen_emb  	       = 0;          
      raw10_en  	     = 0;         
      raw12_en  	     = 0;         
      raw14_en  	     = 0;         
      yuv422_8b_en     = 0;     
      yuv422_10b_en    = 0;    
      yuv420_8b_en     = 0;     
      yuv420_10b_en    = 0;    
      leg_yuv420_8b_en = 0;
      yuv420_8b_csps   = 0;   
      yuv420_10b_csps  = 0;  
      usd_8b_dt1_en    = 0;    
      usd_8b_dt2_en    = 0;    
      usd_8b_dt3_en    = 0;    
      usd_8b_dt4_en    = 0;    
      usd_8b_dt5_en    = 0;    
      usd_8b_dt6_en    = 0;    
      usd_8b_dt7_en    = 0;
      usd_8b_dt8_en    = 0;
      comp_10_6_10     = 0;
      comp_10_7_10     = 0;
      comp_10_8_10     = 0;
      comp_12_6_12     = 0;
      comp_12_7_12     = 0;
      comp_12_8_12     = 0;
      pixel_width_calc = 0;
    end
  endtask

  /*----------------------------------------------------------------------------
    TASK TO CALCULATE PIXEL WIDTH
  ----------------------------------------------------------------------------*/
  task interleave_en;
    input [34:0] inter_format;
    begin
      initialize;
      if((|inter_format) !=0) begin
        rgb444_en 			 = inter_format[0];
        rgb555_en 			 = inter_format[1];      
        rgb565_en 			 = inter_format[2];
        rgb666_en 			 = inter_format[3];       
        rgb888_en 			 = inter_format[4];  
        raw6_en   			 = inter_format[5]; 
        raw7_en   			 = inter_format[6];          
        raw8_en   			 = inter_format[7];          
        raw10_en  			 = inter_format[8];         
        raw12_en  			 = inter_format[9];         
        raw14_en  			 = inter_format[10];         
        yuv422_8b_en     = inter_format[11];     
        yuv422_10b_en    = inter_format[12];    
        yuv420_8b_en     = inter_format[13];     
        yuv420_10b_en    = inter_format[14];    
        leg_yuv420_8b_en = inter_format[15];
        yuv420_8b_csps   = inter_format[16];   
        yuv420_10b_csps  = inter_format[17];  
        usd_8b_dt1_en    = inter_format[18];    
        usd_8b_dt2_en    = inter_format[19];    
        usd_8b_dt3_en    = inter_format[20];    
        usd_8b_dt4_en    = inter_format[21];    
        usd_8b_dt5_en    = inter_format[22];    
        usd_8b_dt6_en    = inter_format[23];    
        usd_8b_dt7_en    = inter_format[24];
        usd_8b_dt8_en    = inter_format[25];
        comp_10_6_10     = inter_format[26];
        comp_10_7_10     = inter_format[27];
        comp_10_8_10     = inter_format[28];
        comp_12_6_12     = inter_format[29];
        comp_12_7_12     = inter_format[30];
        comp_12_8_12     = inter_format[31];
        gen_null         = inter_format[32];
        gen_blank        = inter_format[33];
        gen_emb          = inter_format[34];
        pixel_width_calc = 1;
      end
    end
  endtask

integer cali_cnt;
  /*----------------------------------------------------------------------------
                  Task for DPHY calibration
  -----------------------------------------------------------------------------*/
  task initial_calibration;
   input [31:0]delay_val;
    integer delay_val;
    begin
      wait(reset_clk_csi_n);
      wait(stopstate_dat_0);
      
      if(delay_val>= test_env.u_csi2tx_ahb_master_model_inst.max_init_calib_cnt)
       begin
        cali_cnt = test_env.u_csi2tx_ahb_master_model_inst.max_init_calib_cnt;
       end
      else if(delay_val < test_env.u_csi2tx_ahb_master_model_inst.min_init_calib_cnt)
       begin
        cali_cnt = test_env.u_csi2tx_ahb_master_model_inst.min_init_calib_cnt;
       end
      else
        cali_cnt = delay_val;
      
   
      @(posedge test_env.u_csi2tx_dphy_afe_dfe_top_inst.txbyteclkhs);
      tx_skewcallhs = 1'b1;
      for(int_cou_pointer2 = 0 ; int_cou_pointer2 < cali_cnt ;
        int_cou_pointer2 = int_cou_pointer2+1) 
      @(posedge test_env.u_csi2tx_dphy_afe_dfe_top_inst.txbyteclkhs);
      tx_skewcallhs = 1'b0; 
      wait(stopstate_dat_0 != 1'b1);
      wait(test_env.u_csi2tx_mipi_top.stopstate == 8'hff);
    end
  endtask



  task periodic_calibration;
   input [31:0]delay_val;
    integer delay_val;
    begin
      wait(reset_clk_csi_n);
      wait(stopstate_dat_0);
      
      if(delay_val>= test_env.u_csi2tx_ahb_master_model_inst.max_periodic_calib_cnt)
       begin
        cali_cnt = test_env.u_csi2tx_ahb_master_model_inst.max_periodic_calib_cnt;
       end
      else if(delay_val < test_env.u_csi2tx_ahb_master_model_inst.min_periodic_calib_cnt)
       begin
        cali_cnt = test_env.u_csi2tx_ahb_master_model_inst.min_periodic_calib_cnt;
       end
      else
        cali_cnt = delay_val;
      
   
      @(posedge test_env.u_csi2tx_dphy_afe_dfe_top_inst.txbyteclkhs);
      tx_skewcallhs = 1'b1;
      for(int_cou_pointer2 = 0 ; int_cou_pointer2 < cali_cnt ;
        int_cou_pointer2 = int_cou_pointer2+1) 
      @(posedge test_env.u_csi2tx_dphy_afe_dfe_top_inst.txbyteclkhs);
      tx_skewcallhs = 1'b0; 
      wait(stopstate_dat_0 != 1'b1);
      wait(test_env.u_csi2tx_mipi_top.stopstate == 8'hff);
    end
  endtask
  
  
  /*----------------------------------------------------------------------------
    TASK TO ASSIGN PIXEL WIDTH VALUE 
  ----------------------------------------------------------------------------*/
  
  always@(*)
    begin
      if(pixel_width_calc) begin
        if((raw6_en && raw_image_data_type[1:0] == 2'b00) || comp_10_6_10 || comp_12_6_12)
          pixel_width = 6;

        else if((raw7_en && raw_image_data_type[3:2] == 2'b00)|| comp_10_7_10 || comp_12_7_12)
          pixel_width = 7;

        else if((raw8_en && raw_image_data_type[5:4] == 2'b00) || (usd_8b_dt1_en && usd_data_type_reg [1:0] == 2'b00) || 
                (usd_8b_dt2_en && usd_data_type_reg [3:2] == 2'b00) || (usd_8b_dt3_en && usd_data_type_reg [5:4] == 2'b00) ||
                (usd_8b_dt4_en && usd_data_type_reg [7:6] == 2'b00) || (usd_8b_dt5_en && usd_data_type_reg[9:8] == 2'b00)  ||
                (usd_8b_dt6_en && usd_data_type_reg[11:10] == 2'b00) || (usd_8b_dt7_en && usd_data_type_reg [13:12] == 2'b00) ||
                (usd_8b_dt8_en && usd_data_type_reg[15:14] == 2'b00)  || comp_10_8_10 || comp_12_8_12 || 
                (yuv420_8b_en && yuv_image_data_type[1:0] == 2'b00) || (yuv420_8b_csps && yuv_image_data_type[3:2] == 2'b00) || 
                (gen_null && generic_8_bit_long_pkt_data_type[1:0] == 2'b00) || (gen_blank && generic_8_bit_long_pkt_data_type[3:2] == 2'b00) ||
                (gen_emb &&  generic_8_bit_long_pkt_data_type[5:4] == 2'b00))
          pixel_width = 8;

        else if((raw10_en &&raw_image_data_type[7:6] == 2'b00)  ||  (yuv420_10b_en && yuv_image_data_type[9:8]  == 2'b00)|| 
                (yuv420_10b_csps && yuv_image_data_type[11:10] == 2'b00))
          pixel_width = 10;

        else if((raw12_en && raw_image_data_type[9:8] == 2'b00) || (raw6_en && raw_image_data_type[1:0] == 2'b01) ||
                (leg_yuv420_8b_en && yuv_image_data_type[7:6] == 2'b00))
          pixel_width = 12;
 
        else if((raw14_en && raw_image_data_type[11:10] == 2'b00) || (raw7_en && raw_image_data_type[3:2] == 2'b01))
          pixel_width = 14;

        else if((rgb565_en && rgb_image_data_type[5:4] == 2'b00)|| (rgb444_en && rgb_image_data_type[1:0] == 2'b00) ||
                (rgb555_en && rgb_image_data_type[3:2] == 2'b00) || (raw8_en && raw_image_data_type[1:0] == 2'b01) || 
                (yuv420_8b_en && raw_image_data_type[1:0] == 2'b01) || (yuv420_8b_csps && yuv_image_data_type[3:2] == 2'b01) || 
                (yuv422_8b_en && yuv_image_data_type[13:12] == 2'b00) || (usd_8b_dt1_en && usd_data_type_reg [1:0] == 2'b01) ||
                (usd_8b_dt2_en && usd_data_type_reg [3:2] == 2'b01) || (usd_8b_dt3_en && usd_data_type_reg [5:4] == 2'b01) ||
                (usd_8b_dt4_en && usd_data_type_reg [7:6] == 2'b01) || (usd_8b_dt5_en && usd_data_type_reg[9:8] == 2'b01)  || 
                (usd_8b_dt6_en && usd_data_type_reg[11:10] == 2'b01) || (usd_8b_dt7_en && usd_data_type_reg [13:12] == 2'b01) || 
                (usd_8b_dt8_en && usd_data_type_reg[15:14] == 2'b01) || (gen_null && generic_8_bit_long_pkt_data_type[1:0] == 2'b01) ||
                (gen_blank && generic_8_bit_long_pkt_data_type[3:2] == 2'b01) || (gen_emb &&  generic_8_bit_long_pkt_data_type[5:4] == 2'b01))
          pixel_width = 16;
 
        else if((rgb666_en && rgb_image_data_type[7:6] == 2'b00) || (raw6_en && raw_image_data_type[1:0] == 2'b10))
          pixel_width = 18;
 
        else if((raw10_en && raw_image_data_type[7:6] == 2'b01) || (yuv420_10b_en && yuv_image_data_type[9:8]  == 2'b01) || 
                (yuv422_10b_en && yuv_image_data_type[15:14]  == 2'b00) || (yuv420_10b_csps && yuv_image_data_type[11:10] == 2'b01)) 
          pixel_width =20;

        else if(raw7_en && raw_image_data_type[3:2] == 2'b10) 
          pixel_width =21;

        else if((raw6_en && raw_image_data_type[1:0] == 2'b11) || (raw8_en && raw_image_data_type[1:0] == 2'b10) ||
                (rgb888_en && rgb_image_data_type[9:8] == 2'b00) ||  (yuv420_8b_en && yuv_image_data_type[1:0] == 2'b10) ||
                (yuv420_8b_csps && yuv_image_data_type[3:2] == 2'b10) || (leg_yuv420_8b_en && yuv_image_data_type[7:6] == 2'b01) ||
                (raw12_en && raw_image_data_type[9:8] == 2'b01) || (usd_8b_dt1_en && usd_data_type_reg [1:0] == 2'b10) ||
                (usd_8b_dt2_en && usd_data_type_reg [3:2] == 2'b10) || (usd_8b_dt3_en && usd_data_type_reg [5:4] == 2'b10) || 
                (usd_8b_dt4_en && usd_data_type_reg [7:6] == 2'b10) || (usd_8b_dt5_en && usd_data_type_reg[9:8] == 2'b10)  ||
                (usd_8b_dt6_en && usd_data_type_reg[11:10] == 2'b10) || (usd_8b_dt7_en && usd_data_type_reg [13:12] == 2'b10) || 
                (usd_8b_dt8_en && usd_data_type_reg[15:14] == 2'b10) || (gen_null && generic_8_bit_long_pkt_data_type[1:0] == 2'b10) ||
                (gen_blank && generic_8_bit_long_pkt_data_type[3:2] == 2'b10) || (gen_emb &&  generic_8_bit_long_pkt_data_type[5:4] == 2'b10))
          pixel_width =24;

        else if((raw7_en && raw_image_data_type[3:2] == 2'b11) || (raw14_en &&  raw_image_data_type[11:10] == 2'b01))
          pixel_width =28;

        else if((raw10_en && raw_image_data_type[7:6] == 2'b10) || (yuv420_10b_en && yuv_image_data_type[9:8]  == 2'b10) || 
                (yuv420_10b_csps && yuv_image_data_type[11:10] == 2'b10))
          pixel_width =30;
 
        else if((raw8_en && raw_image_data_type[1:0] == 2'b11) ||  (yuv420_8b_en && yuv_image_data_type[1:0] == 2'b11) ||
                (yuv420_8b_csps && yuv_image_data_type[3:2] == 2'b11) || (yuv422_8b_en &&  yuv_image_data_type[13:12] == 2'b01) ||
                (rgb444_en &&  rgb_image_data_type[1:0] == 2'b01) || (rgb555_en && rgb_image_data_type[3:2] == 2'b01) || 
                (rgb565_en && rgb_image_data_type[5:4] == 2'b01) || (usd_8b_dt1_en && usd_data_type_reg [1:0] == 2'b11) || 
                (usd_8b_dt2_en && usd_data_type_reg [3:2] == 2'b11) || (usd_8b_dt3_en && usd_data_type_reg [5:4] == 2'b11) ||
                (usd_8b_dt4_en && usd_data_type_reg [7:6] == 2'b11) || (usd_8b_dt5_en && usd_data_type_reg[9:8] == 2'b11)  || 
                (usd_8b_dt6_en && usd_data_type_reg[11:10] == 2'b11) || (usd_8b_dt7_en && usd_data_type_reg [13:12] == 2'b11) ||
                (usd_8b_dt8_en && usd_data_type_reg[15:14] == 2'b11) || (gen_null && generic_8_bit_long_pkt_data_type[1:0] == 2'b11) || 
                (gen_blank && generic_8_bit_long_pkt_data_type[3:2] == 2'b11) || (gen_emb &&  generic_8_bit_long_pkt_data_type[5:4] == 2'b11)) 
          pixel_width =32;
    end
  end

  /*----------------------------------------------------------------------------
    Task forces lane_index through testcase, which overrides the lane index
    forced through command line 
  -----------------------------------------------------------------------------*/
  task force_lane_index;
    input [2:0] temp_lane_index;
    begin
      lan_index     =   temp_lane_index;
      lane_index_en =   1'b1;
    end
  endtask

  /*----------------------------------------------------------------------------
    Selects between 
      lane index configured through command line 
                  (or)
      lane index forced through testcase
  -----------------------------------------------------------------------------*/
  assign lane_index = lane_index_en ? lan_index : reg_lane_cnt;


  task sync_with_ahb;
   begin
    sync_en = 1'b1;
    wait(!reset_clk_csi_n);
    wait(reset_clk_csi_n);
    wait(test_env.u_csi2tx_mipi_top.u_csi2tx_reset_sync.txbyteclk_rst_n == 1'b1);
    sync_en = 1'b0;
    end
  endtask




endmodule
