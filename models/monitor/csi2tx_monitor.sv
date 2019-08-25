/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_monitor.sv
// Author      : Mohamed Hasan Ali
// Version     : v1p2
// Abstract    : This module is used to compare the data from the packet interface and 
//               the csi receiver bfm
//                
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 21/05/2014
//==============================================================================*/

`timescale 1 ns / 1 ps

module csi2tx_monitor(
    input                 clk_csi,
    input                 reset_clk_csi_n,
    input    [1:0]        packet_vc,
    input    [5:0]        packet_dt,
    input   [15:0]        packet_wc_df,
    input   [11:0]        dec_op,
    input                 dec_op_vld,
    input    [9:0]        Xdeco10, 
    input   [11:0]        Xdeco12,
    input                 dec_10_bit,
    input                 dec_12_bit, 
    input                 comp_en,
    input                 packet_data_rdy,
    input   [31:0]        packet_data,
    input                 packet_rdy,
    input   reg           fs, 
    input   reg           ls, 
    input   reg           le, 
    input   reg           fe, 
    input                 forcetxstopmode,
    input                 drop_pkt_en,
    input   [31:0]        csi_long_pkt_data,
    input                 csi_long_pkt_data_en,
    input                 csi_header_en,
    input   [31:0]        csi_header_data,
    input                 odd_even_line,
    input   [31:0]        yuv_image_data_type,
    input   [31:0]        raw_image_data_type,
    input   [31:0]        usd_data_type_reg,
    input   [31:0]        rgb_image_data_type,
    input   [31:0]        generic_8_bit_long_pkt_data_type,
    output  reg           err_flg,
    output  reg           end_monitor
  );

  /*----------------------------------------------------------------------------
    Memory Declaration
  ----------------------------------------------------------------------------*/
  reg    [23:0]          mem_sh       [0:65535];
  reg    [31:0]          mem_lg       [0:131071];
  reg    [7:0]           mem_loopback [0:65535];


  /*----------------------------------------------------------------------------
    Internal Register, Wire, Real & Integer Declaration
  ----------------------------------------------------------------------------*/
  //reg                    err_flg;
  //reg                    end_monitor;
 // reg                    fs; 
  //reg                    ls; 
  //reg                    le; 
 // reg                    fe; 
  reg    [1:0]           packet_vc_d;
  reg    [5:0]           packet_dt_d;
  reg    [31:0]          packet_data_d;
  reg    [15:0]          packet_wc_df_d;
  reg    [15:0]          sh_wrptr;
  reg    [15:0]          sh_rdptr;
  reg    [16:0]          lg_rdptr;
  reg    [16:0]          lg_wrptr;
  reg    [15:0]          stored_cnt;
  reg    [15:0]          wc_cnt;
  reg    [23:0]           temp_data_id_vc;
  reg    [7:0]           temp_wc_0;
  reg    [7:0]           temp_wc_1;
  reg    [31:0]          temp_lg_data;
  reg                    frame_st_0_en;
  reg                    frame_st_1_en;
  reg                    frame_st_2_en;
  reg                    frame_st_3_en;
  reg                    line_st_0_en;
  reg                    line_st_1_en;
  reg                    line_st_2_en;
  reg                    line_st_3_en;
  reg                    packet_en;
  reg    [15:0]          loopback_wr_cnt;
  reg    [15:0]          loopback_rd_cnt;
  reg    [7:0]           temp_loopback_data;
  reg                    toggle;
  wire                   data_chk_en;
  
  /*---------------------------------------------------------------------------
    Initalization
  ---------------------------------------------------------------------------*/
  initial
    begin
      sh_wrptr 				    = 16'b0;
      sh_rdptr 				    = 16'b0;
      lg_rdptr 				    = 17'h0;
      lg_wrptr 				    = 17'h0;
      err_flg 				    = 1'b0;
      end_monitor 			  = 1'b1;
      wc_cnt  				    = 16'h0;
      temp_lg_data 			  = 32'h0;
      temp_wc_0 			    = 8'h0;
      temp_wc_1 			    = 8'h0;
      temp_data_id_vc 		= 24'h0;
      frame_st_0_en 			= 1'b0;
      frame_st_1_en 			= 1'b0;
      frame_st_2_en 			= 1'b0;
      frame_st_3_en 			= 1'b0;
      line_st_0_en  			= 1'b0;
      line_st_1_en  			= 1'b0;
      line_st_2_en  			= 1'b0;
      line_st_3_en  			= 1'b0;
      packet_en     			= 1'b1;
      temp_loopback_data 	= 8'h0;
      toggle 				      = 0;
    end

   
    
  always @ (negedge clk_csi or negedge reset_clk_csi_n)
    if(!reset_clk_csi_n)
      sh_wrptr = 16'h0;
    else if(forcetxstopmode && drop_pkt_en == 1'b0)
      sh_wrptr = 8'h0;
    else if((packet_rdy || fs || ls || le || fe) && ( ((packet_dt_d == 6'h18)||
            (packet_dt_d == 6'h19) || (packet_dt_d == 6'h1a) || (packet_dt_d == 6'h1c) ||
            (packet_dt_d == 6'h1d) ||(packet_dt_d == 6'h1e)  || (packet_dt_d == 6'h1f) || 
            (packet_dt_d == 6'h20) || (packet_dt_d == 6'h21) ||  (packet_dt_d == 6'h22)||
            (packet_dt_d == 6'h23) || (packet_dt_d == 6'h24) || (packet_dt_d == 6'h30) || 
            (packet_dt_d == 6'h31) || (packet_dt_d == 6'h32) || (packet_dt_d == 6'h33) || 
            (packet_dt_d == 6'h34) || (packet_dt_d == 6'h35) || (packet_dt_d == 6'h36) ||
            (packet_dt_d == 6'h37) || (packet_dt_d == 6'h28) || (packet_dt_d == 6'h29) || 
            (packet_dt_d == 6'h2a) || (packet_dt_d == 6'h2b) || (packet_dt_d == 6'h2c) || 
            (packet_dt_d == 6'h2d) || (packet_dt_d == 6'h10) || (packet_dt_d == 6'h11) || 
            (packet_dt_d == 6'h12) || (packet_dt_d == 6'h00) || (packet_dt_d == 6'h01) ||
            (packet_dt_d == 6'h02) || (packet_dt_d == 6'h03) || (packet_dt_d == 6'h08) || 
            (packet_dt_d == 6'h09) || (packet_dt_d == 6'h0a) || (packet_dt_d == 6'h0b) || 
            (packet_dt_d == 6'h0c) || (packet_dt_d == 6'h0d) || (packet_dt_d == 6'h0e) ||
            (packet_dt_d == 6'h0f) ))) begin
       mem_sh[sh_wrptr] = { packet_wc_df_d,packet_vc_d,packet_dt_d};
       sh_wrptr = sh_wrptr + 16'h1;
     end



  always @ (posedge clk_csi or negedge reset_clk_csi_n)
    begin
      if(!reset_clk_csi_n)
         stored_cnt = 16'h0;
      else if(packet_rdy)
         stored_cnt = 16'h0;       
    end


  always @ (posedge clk_csi or negedge reset_clk_csi_n)
    begin
      if(!reset_clk_csi_n)
        lg_wrptr = 16'h0;
      else if((forcetxstopmode && (drop_pkt_en == 1'b0)))
        lg_wrptr = 16'h0;
      // This Part will be enabled only when the data type is user defined and compression is enabled
      else if(comp_en && ((!packet_rdy) && packet_data_rdy && drop_pkt_en == 1'b0) && (dec_10_bit || dec_12_bit) && 
                         ((packet_dt_d == 6'h30) || (packet_dt_d == 6'h31) || (packet_dt_d == 6'h32) || (packet_dt_d == 6'h33) ||
                         (packet_dt_d == 6'h34) || (packet_dt_d == 6'h35) || (packet_dt_d == 6'h36) || (packet_dt_d == 6'h37))) begin
        mem_lg[lg_wrptr] =  dec_10_bit ? Xdeco10[9:0] : (dec_12_bit ? Xdeco12[11:0] : 32'd0 );
        lg_wrptr = lg_wrptr + 16'h1;

      end
      // This part will be enabled when compression is disabled and for all the data types
      else if (!comp_en & (((!packet_rdy) && packet_data_rdy && drop_pkt_en == 1'b0) &&
                           ((packet_dt_d == 6'h18)|| (packet_dt_d == 6'h19)|| (packet_dt_d == 6'h1a)||
                            (packet_dt_d == 6'h1c)|| (packet_dt_d == 6'h1d)|| (packet_dt_d == 6'h1e)||
                            (packet_dt_d == 6'h1f)|| (packet_dt_d == 6'h20)|| (packet_dt_d == 6'h21)||
                            (packet_dt_d == 6'h22)|| (packet_dt_d == 6'h23)|| (packet_dt_d == 6'h24)||
                            (packet_dt_d == 6'h30)|| (packet_dt_d == 6'h31)|| (packet_dt_d == 6'h32)||
                            (packet_dt_d == 6'h33)|| (packet_dt_d == 6'h34)|| (packet_dt_d == 6'h35)||
                            (packet_dt_d == 6'h36)|| (packet_dt_d == 6'h37)|| (packet_dt_d == 6'h28)||
                            (packet_dt_d == 6'h29)|| (packet_dt_d == 6'h2a)|| (packet_dt_d == 6'h2b)||
                            (packet_dt_d == 6'h2c)|| (packet_dt_d == 6'h2d)|| (packet_dt_d == 6'h10)||
                            (packet_dt_d == 6'h11)|| (packet_dt_d == 6'h12)))) begin
       ////////////////YUV 4208 BIT//////////////////////////////////
          if(packet_dt_d == 6'h18)
           begin  //for 1c and 18
              if(!odd_even_line)
                begin
                   if(yuv_image_data_type[1:0] == 2'b00)
                      begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[27:20]};
                         lg_wrptr = lg_wrptr + 16'h1;
                      end
                   else if(yuv_image_data_type[1:0] == 2'b01)
                      begin
                         if(packet_wc_df-stored_cnt>=2)
                         begin
                           mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                           lg_wrptr = lg_wrptr + 16'h1;
                           mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                           lg_wrptr = lg_wrptr + 16'h1;
                           stored_cnt=stored_cnt +16'h2;
                         end
                         else
                         begin if(packet_wc_df-stored_cnt==1)
                           mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                           lg_wrptr = lg_wrptr + 16'h1;
                           stored_cnt=stored_cnt +16'h1;
                         end
                      end
                   else if(yuv_image_data_type[1:0] == 2'b10)
                      begin
                         if(packet_wc_df-stored_cnt>=3)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h3;
                         end
                         else if(packet_wc_df-stored_cnt==2)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h2;
                         end
                         else if(packet_wc_df-stored_cnt==1)
                         begin
                           mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                           lg_wrptr = lg_wrptr + 16'h1;
                           stored_cnt=stored_cnt +16'h1;
                         end
                      end
                   else if(yuv_image_data_type[1:0] == 2'b11)
                      begin
                         if(packet_wc_df-stored_cnt>=4)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h4;
                         end
                         else if(packet_wc_df-stored_cnt==3)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h3;
                         end
                         else if(packet_wc_df-stored_cnt==2)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h2;
                         end
                         else if(packet_wc_df-stored_cnt==1)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h1;
                         end

                      end
                end
             else if(odd_even_line)
              begin
                  if(yuv_image_data_type[3:2] == 2'b00)
                    begin
                    toggle = ~toggle;
                       if(toggle )
                         begin
                            mem_lg[lg_wrptr] = {8'b0,packet_data[7:0],packet_data[27:20],packet_data[17:10]};
                            lg_wrptr = lg_wrptr + 16'h1;
                         end
                       else
                         begin
                            mem_lg[lg_wrptr] = {24'b0,packet_data[27:20]};
                            lg_wrptr = lg_wrptr + 16'h1;
                         end
                   end
                 else if(yuv_image_data_type[3:2] == 2'b01)
                   begin
                            mem_lg[lg_wrptr] = {8'b0,packet_data[23:16],packet_data[7:0],packet_data[15:8]};
                            mem_lg[lg_wrptr+1] = {24'b0,packet_data[31:24]};
                            lg_wrptr = lg_wrptr + 16'h2;
                   end
                else if((yuv_image_data_type[3:2] != 2'b01) && (yuv_image_data_type[3:2] != 2'b00)) 
                   begin
                      $display("ERROR MONITER : YUV 420 8 BIT EVEN LINE THREE/FOUR PIXEL MODE NOT SUPPORTED \n");
                   end
             end
           end // for 1c and 18

          /////////YUV 420 8 BIT CSPS///////////////////////////
          if(packet_dt_d == 6'h1c)
           begin  //for 1c and 18
              if(!odd_even_line)
                begin
                   if(yuv_image_data_type[13:12] == 2'b00)
                      begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[27:20]};
                         lg_wrptr = lg_wrptr + 16'h1;
                      end
                   else if(yuv_image_data_type[13:12] == 2'b01)
                      begin
                         if(packet_wc_df-stored_cnt>=2)
                         begin
                           mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                           lg_wrptr = lg_wrptr + 16'h1;
                           mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                           lg_wrptr = lg_wrptr + 16'h1;
                           stored_cnt=stored_cnt +16'h2;
                         end
                         else
                         begin if(packet_wc_df-stored_cnt==1)
                           mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                           lg_wrptr = lg_wrptr + 16'h1;
                           stored_cnt=stored_cnt +16'h1;
                         end
                      end
                   else if(yuv_image_data_type[13:12] == 2'b10)
                      begin
                         if(packet_wc_df-stored_cnt>=3)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h3;
                         end
                         else if(packet_wc_df-stored_cnt==2)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h2;
                         end
                         else if(packet_wc_df-stored_cnt==1)
                         begin
                           mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                           lg_wrptr = lg_wrptr + 16'h1;
                           stored_cnt=stored_cnt +16'h1;
                         end
                      end
                   else if(yuv_image_data_type[13:12] == 2'b11)
                      begin
                         if(packet_wc_df-stored_cnt>=4)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h4;
                         end
                         else if(packet_wc_df-stored_cnt==3)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h3;
                         end
                         else if(packet_wc_df-stored_cnt==2)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h2;
                         end
                         else if(packet_wc_df-stored_cnt==1)
                         begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                         lg_wrptr = lg_wrptr + 16'h1;
                         stored_cnt=stored_cnt +16'h1;
                         end
                      end
                end
             else if(odd_even_line)
              begin
                  if(yuv_image_data_type[15:14] == 2'b00)
                    begin
                    toggle = ~toggle;
                       if(toggle )
                         begin
                            mem_lg[lg_wrptr] = {8'b0,packet_data[7:0],packet_data[27:20],packet_data[17:10]};
                            lg_wrptr = lg_wrptr + 16'h1;
                         end
                       else
                         begin
                            mem_lg[lg_wrptr] = {24'b0,packet_data[27:20]};
                            lg_wrptr = lg_wrptr + 16'h1;
                         end
                   end
                 else if(yuv_image_data_type[15:14] == 2'b01)
                   begin
                            mem_lg[lg_wrptr] = {8'b0,packet_data[23:16],packet_data[7:0],packet_data[15:8]};
                            mem_lg[lg_wrptr+1] = {24'b0,packet_data[31:24]};
                            lg_wrptr = lg_wrptr + 16'h2;
                   end
                else if((yuv_image_data_type[15:14] != 2'b01) && (yuv_image_data_type[15:14] != 2'b00)) 
                   begin
                      $display("ERROR MONITER : YUV 420 8 BIT EVEN LINE THREE/FOUR PIXEL MODE NOT SUPPORTED \n");
                   end
             end
           end // for 1c and 18




          ///// YUV 420 10 BIT///////////////////
          else if(packet_dt_d == 6'h19)
           begin
            if(!odd_even_line)
             begin
               if(yuv_image_data_type[5:4] == 2'b00)
                 begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[29:20]};
                     lg_wrptr = lg_wrptr + 16'h1;
                 end
               else if(yuv_image_data_type[5:4] == 2'b01)
                begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[19:10]};
                     lg_wrptr = lg_wrptr + 16'h1;
                end
               else if(yuv_image_data_type[5:4] == 2'b10)
                begin
                     if((((packet_wc_df*8)/10)-stored_cnt)>=3)
                     begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[19:10]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[29:20]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h3;
                     end
                     else if((((packet_wc_df*8)/10)-stored_cnt)==2)
                     begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[19:10]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h2;
                     end
                     else if((((packet_wc_df*8)/10)-stored_cnt)==1)
                     begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h1;
                     end

                end
               else if(yuv_image_data_type[5:4] == 2'b11)
                begin
                     $display("ERROR MONITER : YUV 420 10 BIT ODD LINE FOUR PIXEL MODE NOT SUPPORTED \n");
                end
            end
            else if(odd_even_line)
            begin
               toggle = ~toggle;
               if(yuv_image_data_type[7:6] == 2'b00)
                 begin
                 if (toggle )
                   begin
                      mem_lg[lg_wrptr] = {2'b0,packet_data[9:0],packet_data[29:20],packet_data[19:10]};
                      lg_wrptr = lg_wrptr + 16'h1;
                   end
                else
                   begin
                      mem_lg[lg_wrptr] = {22'b0,packet_data[29:20]};
                      lg_wrptr = lg_wrptr + 16'h1;
                   end
                end
                 else if(yuv_image_data_type[7:6] != 2'b00)
                   begin
                      $display("ERROR MONITER : YUV 420 10 BIT EVEN LINE TWO/THREE/FOUR PIXEL MODE NOT SUPPORTED \n");
                   end
             end
           end



          ///// YUV 420 10 BIT CSPS ///////////////////
          else if(packet_dt_d == 6'h1d)
           begin
            if(!odd_even_line)
             begin
               if(yuv_image_data_type[17:16] == 2'b00)
                 begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[29:20]};
                     lg_wrptr = lg_wrptr + 16'h1;
                 end
               else if(yuv_image_data_type[17:16] == 2'b01)
                begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[19:10]};
                     lg_wrptr = lg_wrptr + 16'h1;
                end
               else if(yuv_image_data_type[17:16] == 2'b10)
                begin
                     if((((packet_wc_df*8)/10)-stored_cnt)>=3)
                     begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[19:10]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[29:20]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h3;
                     end
                     else if((((packet_wc_df*8)/10)-stored_cnt)==2)
                     begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[19:10]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h2;
                     end
                     else if((((packet_wc_df*8)/10)-stored_cnt)==1)
                     begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h1;
                     end
                end
               else if(yuv_image_data_type[17:16] == 2'b11)
                begin
                     $display("ERROR MONITER : YUV 420 10 BIT CSPS ODD LINE FOUR PIXEL MODE NOT SUPPORTED \n");
                end
            end
            else if(odd_even_line)
            begin
               toggle = ~toggle;
               if(yuv_image_data_type[19:18] == 2'b00)
                 begin
                 if (toggle )
                   begin
                      mem_lg[lg_wrptr] = {2'b0,packet_data[9:0],packet_data[29:20],packet_data[19:10]};
                      lg_wrptr = lg_wrptr + 16'h1;
                   end
                else
                   begin
                      mem_lg[lg_wrptr] = {22'b0,packet_data[29:20]};
                      lg_wrptr = lg_wrptr + 16'h1;
                   end
                end
                 else if(yuv_image_data_type[19:18] != 2'b00)
                   begin
                      $display("ERROR MONITER : YUV 420 10 BIT EVEN LINE TWO/THREE/FOUR PIXEL MODE NOT SUPPORTED \n");
                   end
             end
           end
        ///////////////YUV 420 LEGACY///////////////
          else if(packet_dt_d == 6'h1a)
          begin  //for 1a
            if(!odd_even_line)
            begin
                if(yuv_image_data_type[9:8] == 2'b00)
                  begin
                  toggle = ~toggle;
                    if(toggle)
                      begin
                          mem_lg[lg_wrptr] = {16'b0,packet_data[27:20],packet_data[17:10]};
                          lg_wrptr = lg_wrptr + 16'h1;
                      end
                    else 
                      begin
                         mem_lg[lg_wrptr] = {24'b0,packet_data[27:20]};
                         lg_wrptr = lg_wrptr + 16'h1;
                      end
                 end
                else if(yuv_image_data_type[9:8] == 2'b01)
                  begin
                        mem_lg[lg_wrptr] = {16'b0,packet_data[7:0],packet_data[15:8]};
                        mem_lg[lg_wrptr+1] = {24'b0,packet_data[31:24]};
                        lg_wrptr = lg_wrptr + 16'h2;
                  end
                else if((yuv_image_data_type[9:8] != 2'b01) && (yuv_image_data_type[9:8] != 2'b00))
                  begin
                    $display("ERROR : LEGACY YUV 420 8 BIT  BIT ODD LINE THREE/FOUR PIXEL MODE NOT SUPPORTED \n");
                  end
             end
          else if(odd_even_line)
          begin
                if(yuv_image_data_type[11:10] == 2'b00)
                begin
                toggle = ~toggle;
                  if(toggle)
                    begin
                        mem_lg[lg_wrptr] = {16'b0,packet_data[27:20],packet_data[7:0]};
                        lg_wrptr = lg_wrptr + 16'h1;
                    end
                  else 
                    begin
                        mem_lg[lg_wrptr] = {24'b0,packet_data[27:20]};
                        lg_wrptr = lg_wrptr + 16'h1;
                    end
                end
                else if(yuv_image_data_type[11:10] == 2'b01)
                begin
                        mem_lg[lg_wrptr] = {16'b0,packet_data[7:0],packet_data[23:16]};
                        mem_lg[lg_wrptr+1] = {24'b0,packet_data[31:24]};
                        lg_wrptr = lg_wrptr + 16'h2;
                end
                else if((yuv_image_data_type[11:10] != 2'b01) && (yuv_image_data_type[11:10] != 2'b00))
                    begin
                        $display("ERROR : LEGACY YUV 420 8 BIT  BIT EVEN LINE THREE/FOUR PIXEL MODE NOT SUPPORTED \n");
                    end
                end
          end 
       // end// for 1a
        //////////////YUV 422 8 BIT//////////////////
        else if(packet_dt_d == 6'h1e)
          begin  //for 1a
              if(yuv_image_data_type[21:20] == 2'b00)
               begin
                toggle = ~toggle;
                  if(toggle)
                   begin
                     mem_lg[lg_wrptr] = {8'b0,packet_data[7:0],packet_data[27:20],packet_data[17:10]};
                     lg_wrptr = lg_wrptr + 16'h1;
                   end
                  else 
                   begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[27:20]};
                     lg_wrptr = lg_wrptr + 16'h1;
                   end
               end
              else if(yuv_image_data_type[21:20] == 2'b01)
               begin
                     mem_lg[lg_wrptr] = {8'b0,packet_data[23:16],packet_data[7:0],packet_data[15:8]};
                     mem_lg[lg_wrptr+1] = {24'b0,packet_data[31:24]};
                     lg_wrptr = lg_wrptr + 16'h2;
               end
              else if((yuv_image_data_type[21:20] != 2'b01) && (yuv_image_data_type[21:20] != 2'b00))
                 begin
                     $display("ERROR :  YUV 422 8 BIT THREE/FOUR PIXEL MODE NOT SUPPORTED \n");
                 end
          end
        //////////////YUV 422 10 BIT//////////////////

        else if(packet_dt_d == 6'h1f)
          begin  //for 1a
              toggle = ~toggle;
                if(yuv_image_data_type[23:22] == 2'b00)
                begin
                 if(toggle)
                  begin
                     mem_lg[lg_wrptr] = {2'b0,packet_data[9:0],packet_data[29:20],packet_data[19:10]};
                     lg_wrptr = lg_wrptr + 16'h1;
                  end
                else 
                  begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[29:20]};
                     lg_wrptr = lg_wrptr + 16'h1;
                  end
                end
                else if(yuv_image_data_type[23:22] != 2'b00)
                begin
                     $display("ERROR : YUV 422 10 BIT TWO/THREE/FOUR PIXEL MODE NOT SUPPORTED \n");
                end
          end // for 1a

          else if(packet_dt_d == 6'h28) 
          begin
              if(raw_image_data_type[1:0] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[1:0] == 2'b01)
                begin 
                     mem_lg[lg_wrptr] = {26'b0,packet_data[5:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {26'b0,packet_data[11:6]};
                     lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[1:0] == 2'b10)
                begin
                     if((((packet_wc_df*8)/6)-stored_cnt)>=3)
                     begin
                     mem_lg[lg_wrptr] = {26'b0,packet_data[5:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {26'b0,packet_data[11:6]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {26'b0,packet_data[17:12]};
                     lg_wrptr = lg_wrptr + 16'h1; 
                     stored_cnt=stored_cnt+16'h3;
                     end
                     else if((((packet_wc_df*8)/6)-stored_cnt)==2)
                     begin
                     mem_lg[lg_wrptr] = {26'b0,packet_data[5:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {26'b0,packet_data[11:6]};
                     lg_wrptr = lg_wrptr + 16'h1; 
                     stored_cnt=stored_cnt+16'h2;
                     end
                     else if((((packet_wc_df*8)/6)-stored_cnt)==1)
                     begin
                     mem_lg[lg_wrptr] = {26'b0,packet_data[5:0]};
                     lg_wrptr = lg_wrptr + 16'h1; 
                     stored_cnt=stored_cnt+16'h1;
                     end
                end
              else if(raw_image_data_type[1:0] == 2'b11)
                begin 
                     mem_lg[lg_wrptr] = {26'b0,packet_data[5:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {26'b0,packet_data[11:6]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {26'b0,packet_data[17:12]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {26'b0,packet_data[23:18]};
                     lg_wrptr = lg_wrptr + 16'h1;
                end
          end
          else if(packet_dt_d == 6'h29) 
          begin
              if(raw_image_data_type[3:2] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[3:2] == 2'b01)
                begin 
                     mem_lg[lg_wrptr] = {25'b0,packet_data[6:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {25'b0,packet_data[13:7]};
                     lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[3:2] == 2'b10)
                begin
                     if((((packet_wc_df*8)/7)-stored_cnt)>=3)
                     begin
                     mem_lg[lg_wrptr] = {25'b0,packet_data[6:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {25'b0,packet_data[13:7]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {25'b0,packet_data[20:14]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h3;
                     end
                     else if((((packet_wc_df*8)/7)-stored_cnt)==2)
                     begin
                     mem_lg[lg_wrptr] = {25'b0,packet_data[6:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {25'b0,packet_data[13:7]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h2;
                     end
                     else if((((packet_wc_df*8)/7)-stored_cnt)==1)
                     begin
                     mem_lg[lg_wrptr] = {25'b0,packet_data[6:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h1;
                     end 
                end
              else if(raw_image_data_type[3:2] == 2'b11)
                begin 
                     mem_lg[lg_wrptr] = {25'b0,packet_data[6:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {25'b0,packet_data[13:7]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {25'b0,packet_data[20:14]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {25'b0,packet_data[27:21]};
                     lg_wrptr = lg_wrptr + 16'h1;
                end
          end
          else if(packet_dt_d == 6'h2a) 
          begin
              if(raw_image_data_type[5:4] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[5:4] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(raw_image_data_type[5:4] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(raw_image_data_type[5:4] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
          end
          else if(packet_dt_d == 6'h2b) 
          begin
              if(raw_image_data_type[7:6] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[7:6] == 2'b01)
                begin 
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[19:10]};
                     lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[7:6] == 2'b10)
                begin
                     if((((packet_wc_df*8)/10)-stored_cnt)>=3)
                     begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[19:10]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[29:20]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h3;
                     end
                     else if((((packet_wc_df*8)/10)-stored_cnt)==2)
                     begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {22'b0,packet_data[19:10]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h2;
                     end
                     else if((((packet_wc_df*8)/10)-stored_cnt)==1)
                     begin
                     mem_lg[lg_wrptr] = {22'b0,packet_data[9:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h1;
                     end
                end
              else if(raw_image_data_type[7:6] == 2'b11)
                begin 
                   $display("ERROR MONITOR : RAW 10 FOUR PIXEL MODE NOT SUPPORTED \n");
                end
          end
          else if(packet_dt_d == 6'h2C) 
          begin
              if(raw_image_data_type[9:8] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[9:8] == 2'b01)
                begin 
                     mem_lg[lg_wrptr] = {20'b0,packet_data[11:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {20'b0,packet_data[23:12]};
                     lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[9:8] == 2'b10)
                begin
                   $display("ERROR MONITOR : RAW 12 THREE PIXEL MODE NOT SUPPORTED \n");
 
                end
              else if(raw_image_data_type[9:8] == 2'b11)
                begin 
                   $display("ERROR MONITOR : RAW 12 FOUR PIXEL MODE NOT SUPPORTED \n");
                end
          end
          else if(packet_dt_d == 6'h2d) 
          begin
              if(raw_image_data_type[11:10] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[11:10] == 2'b01)
                begin 
                     mem_lg[lg_wrptr] = {18'b0,packet_data[13:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {18'b0,packet_data[27:14]};
                     lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(raw_image_data_type[11:10] == 2'b10)
                begin
                   $display("ERROR MONITOR : RAW 14 THREE PIXEL MODE NOT SUPPORTED \n");
 
                end
              else if(raw_image_data_type[11:10] == 2'b11)
                begin 
                   $display("ERROR MONITOR : RAW 14 FOUR PIXEL MODE NOT SUPPORTED \n");
                end
          end
          else if(packet_dt_d == 6'h20) 
          begin
              if(rgb_image_data_type[1:0] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(rgb_image_data_type[1:0] == 2'b01)
                begin
                     if((((packet_wc_df*8)/16)-stored_cnt)>=2)
                     begin 
                     mem_lg[lg_wrptr] = {20'b0,packet_data[11:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {20'b0,packet_data[23:12]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h2;
                     end
                     else if((((packet_wc_df*8)/16)-stored_cnt)==1)
                     begin 
                     mem_lg[lg_wrptr] = {20'b0,packet_data[11:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h1;
                     end
                end
              else if(rgb_image_data_type[1:0] == 2'b10)
                begin
                   $display("ERROR MONITOR : RGB 444 THREE PIXEL MODE NOT SUPPORTED \n");
 
                end
              else if(rgb_image_data_type[1:0] == 2'b11)
                begin 
                   $display("ERROR MONITOR : RGB 444 FOUR PIXEL MODE NOT SUPPORTED \n");
                end
          end
          else if(packet_dt_d == 6'h21) 
          begin
              if(rgb_image_data_type[3:2] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(rgb_image_data_type[3:2] == 2'b01)
                begin 
                     if((((packet_wc_df*8)/16)-stored_cnt)>=2)
                     begin 
                     mem_lg[lg_wrptr] = {17'b0,packet_data[14:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {17'b0,packet_data[29:15]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h2;
                     end
                     else if((((packet_wc_df*8)/16)-stored_cnt)==1)
                     begin 
                     mem_lg[lg_wrptr] = {17'b0,packet_data[14:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h1;
                     end
                end
              else if(rgb_image_data_type[3:2] == 2'b10)
                begin
                   $display("ERROR MONITOR : RGB 555 THREE PIXEL MODE NOT SUPPORTED \n");
 
                end
              else if(rgb_image_data_type[3:2] == 2'b11)
                begin 
                   $display("ERROR MONITOR : RGB 555 FOUR PIXEL MODE NOT SUPPORTED \n");
                end
          end
          else if(packet_dt_d == 6'h22) 
          begin
              if(rgb_image_data_type[5:4] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(rgb_image_data_type[5:4] == 2'b01)
                begin
                     if((((packet_wc_df*8)/16)-stored_cnt)>=2)
                     begin  
                     mem_lg[lg_wrptr] = {16'b0,packet_data[15:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {16'b0,packet_data[31:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h2;
                     end
                     else if((((packet_wc_df*8)/16)-stored_cnt)==1)
                     begin 
                     mem_lg[lg_wrptr] = {16'b0,packet_data[15:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt+16'h1;
                     end
                end
              else if(rgb_image_data_type[5:4] == 2'b10)
                begin
                   $display("ERROR MONITOR : RGB 565 THREE PIXEL MODE NOT SUPPORTED \n");
 
                end
              else if(rgb_image_data_type[5:4] == 2'b11)
                begin 
                   $display("ERROR MONITOR : RGB 565 FOUR PIXEL MODE NOT SUPPORTED \n");
                end
          end
          else if(packet_dt_d == 6'h23) 
          begin
              if(rgb_image_data_type[7:6] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(rgb_image_data_type[7:6] == 2'b01)
                begin 
                   $display("ERROR MONITOR : RGB 666 THREE PIXEL MODE NOT SUPPORTED \n");
                end
           end
          else if(packet_dt_d == 6'h24) 
          begin
              if(rgb_image_data_type[9:8] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(rgb_image_data_type[9:8] == 2'b01)
                begin 
                   $display("ERROR MONITOR : RGB 888 THREE PIXEL MODE NOT SUPPORTED \n");
                end
           end
          else if(packet_dt_d == 6'h30) 
          begin
              if(usd_data_type_reg[1:0] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(usd_data_type_reg[1:0] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(usd_data_type_reg[1:0] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(usd_data_type_reg[1:0] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end
          else if(packet_dt_d == 6'h31) 
          begin
              if(usd_data_type_reg[3:2] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(usd_data_type_reg[3:2] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(usd_data_type_reg[3:2] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(usd_data_type_reg[3:2] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end
          else if(packet_dt_d == 6'h32) 
          begin
              if(usd_data_type_reg[5:4] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(usd_data_type_reg[5:4] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(usd_data_type_reg[5:4] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(usd_data_type_reg[5:4] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end
          else if(packet_dt_d == 6'h33) 
          begin
              if(usd_data_type_reg[7:6] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(usd_data_type_reg[7:6] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(usd_data_type_reg[7:6] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(usd_data_type_reg[7:6] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end
          else if(packet_dt_d == 6'h34) 
          begin
              if(usd_data_type_reg[9:8] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(usd_data_type_reg[9:8] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(usd_data_type_reg[9:8] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(usd_data_type_reg[9:8] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end
          else if(packet_dt_d == 6'h35) 
          begin
              if(usd_data_type_reg[11:10] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(usd_data_type_reg[11:10] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(usd_data_type_reg[11:10] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(usd_data_type_reg[11:10] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end
          else if(packet_dt_d == 6'h36) 
          begin
              if(usd_data_type_reg[13:12] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(usd_data_type_reg[13:12] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(usd_data_type_reg[13:12] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(usd_data_type_reg[13:12] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end
          else if(packet_dt_d == 6'h37) 
          begin
              if(usd_data_type_reg[15:14] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(usd_data_type_reg[15:14] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(usd_data_type_reg[15:14] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(usd_data_type_reg[15:14] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end
          else if(packet_dt_d == 6'h10) 
          begin
              if(generic_8_bit_long_pkt_data_type[1:0] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(generic_8_bit_long_pkt_data_type[1:0] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(generic_8_bit_long_pkt_data_type[1:0] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(generic_8_bit_long_pkt_data_type[1:0] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end
          else if(packet_dt_d == 6'h11) 
          begin
              if(generic_8_bit_long_pkt_data_type[3:2] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(generic_8_bit_long_pkt_data_type[3:2] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(generic_8_bit_long_pkt_data_type[3:2] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(generic_8_bit_long_pkt_data_type[3:2] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end
          else if(packet_dt_d == 6'h12) 
          begin
              if(generic_8_bit_long_pkt_data_type[5:4] == 2'b00)
                begin 
                    mem_lg[lg_wrptr] = packet_data[31:0];
                    lg_wrptr = lg_wrptr + 16'h1;
                end
              else if(generic_8_bit_long_pkt_data_type[5:4] == 2'b01)
                begin 
                     if(packet_wc_df-stored_cnt>=2)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                       mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                       mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                       lg_wrptr = lg_wrptr + 16'h1;
                       stored_cnt=stored_cnt +16'h1;
                     end
                end
              else if(generic_8_bit_long_pkt_data_type[5:4] == 2'b10)
                begin
                    if(packet_wc_df-stored_cnt>=3)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h3;
                    end
                    else if(packet_wc_df-stored_cnt==2)
                    begin
                    mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                    stored_cnt=stored_cnt +16'h2;
                    end
                    else if(packet_wc_df-stored_cnt==1)
                    begin
                      mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                      lg_wrptr = lg_wrptr + 16'h1;
                      stored_cnt=stored_cnt +16'h1;
                    end
                end
              else if(generic_8_bit_long_pkt_data_type[5:4] == 2'b11)
                begin 
                     if(packet_wc_df-stored_cnt>=4)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[31:24]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h4;
                     end
                     else if(packet_wc_df-stored_cnt==3)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                    lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[23:16]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h3;
                     end
                     else if(packet_wc_df-stored_cnt==2)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     mem_lg[lg_wrptr] = {24'b0,packet_data[15:8]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h2;
                     end
                     else if(packet_wc_df-stored_cnt==1)
                     begin
                     mem_lg[lg_wrptr] = {24'b0,packet_data[7:0]};
                     lg_wrptr = lg_wrptr + 16'h1;
                     stored_cnt=stored_cnt +16'h1;
                     end
                end
           end

        end
    end



      
  always @ (posedge clk_csi)
    begin
      packet_dt_d    = packet_dt;
      packet_vc_d    = packet_vc;
      packet_wc_df_d = packet_wc_df;
      packet_data_d  = packet_data;
    end
    
  always @ (posedge csi_header_en)
    begin : bk_read
      if(csi_header_en && drop_pkt_en == 1'b0 && forcetxstopmode == 1'b0) begin
        temp_data_id_vc = mem_sh[sh_rdptr];

        if(temp_data_id_vc[7:0] != csi_header_data[7:0]) begin
          err_flg = 1'b1;
          $display($time,"\tMONITOR : ERROR OCCURED IN DATA ID-VC FIELD AT POINTER %h \n",sh_rdptr);
        end

        if(temp_data_id_vc[15:8] != csi_header_data[15:8]) begin
          err_flg = 1'b1;
          $display($time,"\tMONITOR : ERROR OCCURED IN WORD COUNT-0 FIELD AT POINTER %h\n",sh_rdptr);
        end            

        if(temp_data_id_vc[23:16] != csi_header_data[23:16]) begin
          err_flg = 1'b1;
          $display($time,"\tMONITOR : ERROR OCCURED IN WORD COUNT-1 FIELD AT POINTER %h\n",sh_rdptr);
        end

        sh_rdptr = sh_rdptr + 16'h1;
      end
    end
 
  always @ (negedge dec_op_vld)
    begin
      if(!dec_op_vld && drop_pkt_en == 1'b0 && forcetxstopmode == 1'b0 && (test_env.u_csi2rx_bfm_inst.comp_en == 1'b1)) begin
          temp_lg_data = mem_lg[lg_rdptr];
        if(temp_lg_data[11:0] == dec_op) begin
          lg_rdptr = lg_rdptr + 16'h1;
        end else begin
          err_flg = 1'b1;
          $display($time,"\tMONITOR : ERROR OCCURED IN COMPRESSION DATA AT POINTER %d\n",lg_rdptr);
          $display($time,"\tExpected Data : %h , Received Data = %h \n",temp_lg_data,dec_op );
          lg_rdptr = lg_rdptr + 16'h1;
        end
      end
    end
  
 
  always @ (posedge csi_long_pkt_data_en)
    begin
      if(csi_long_pkt_data_en && drop_pkt_en == 1'b0 && forcetxstopmode == 1'b0) begin
          temp_lg_data = mem_lg[lg_rdptr];
        if(temp_lg_data == csi_long_pkt_data) begin
          lg_rdptr = lg_rdptr + 16'h1;
        end else begin
          err_flg = 1'b1;
          $display($time,"\tMONITOR : ERROR OCCURED IN PIXEL FIELD AT POINTER %h\n",lg_rdptr);
          $display($time,"\tExpected Data : %h , Received Data = %h \n",temp_lg_data,csi_long_pkt_data );
          lg_rdptr = lg_rdptr + 16'h1;
        end
      end
    end
    
  always @ (sh_wrptr or sh_rdptr or lg_wrptr or lg_rdptr)
    begin
      if((sh_wrptr == sh_rdptr) && (lg_wrptr == lg_rdptr))
        end_monitor = 1'b1;
      else
        end_monitor = 1'b0;
    end
   
  always@(negedge reset_clk_csi_n)
   begin
     sh_wrptr = 16'h0; 
     sh_rdptr = 16'h0; 
     lg_wrptr = 17'h0; 
     lg_rdptr = 17'h0; 

   end

 
  always @ (posedge fs)
    if(reset_clk_csi_n && (!forcetxstopmode && drop_pkt_en == 1'b0))
      begin
        if(fs && (packet_dt == 6'h00))
          begin
            if(packet_vc == 2'b00)
              begin
                if(frame_st_0_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN FRAME START SYNC\n");
                  end
                  
                else
                  begin
                    frame_st_0_en = 1'b1;
                  end
              end
              
            if(packet_vc == 2'b01)
              begin
                if(frame_st_1_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN FRAME START SYNC \n");
                  end
                  
                else
                  begin
                    frame_st_1_en = 1'b1;
                  end
              end
              
            if(packet_vc == 2'b10)
              begin
                if(frame_st_2_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN FRAME START SYNC  \n");
                  end
                  
                else
                  begin
                    frame_st_2_en = 1'b1;
                  end
              end
              
            if(packet_vc == 2'b11)
              begin
                if(frame_st_3_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN FRAME START SYNC  \n");
                  end
                  
                else
                  begin
                    frame_st_3_en = 1'b1;
                  end
              end
          end
      end
    
  always @ (posedge ls)
    if(reset_clk_csi_n && (!forcetxstopmode && drop_pkt_en == 1'b0))
      begin
        if(ls && (packet_dt == 6'h02))
          begin
            if(packet_vc == 2'b00)
              begin
                if(line_st_0_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN LINE START SYNC  \n");
                  end
                  
                else
                  begin
                    line_st_0_en = 1'b1;
                  end
              end
              
            if(packet_vc == 2'b01)
              begin
                if(line_st_1_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN LINE START SYNC  \n");
                  end
                  
                else
                  begin
                    line_st_1_en = 1'b1;
                  end
              end
              
            if(packet_vc == 2'b10)
              begin
                if(line_st_2_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN LINE START SYNC  \n");
                  end
                  
                else
                  begin
                    line_st_2_en = 1'b1;
                  end
              end
              
            if(packet_vc == 2'b11)
              begin
                if(line_st_3_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN LINE START SYNC  \n");
                  end
                  
                else
                  begin
                    line_st_3_en = 1'b1;
                  end
              end
          end
      end
      
    
  always @ (posedge fe)
    if(reset_clk_csi_n && (!forcetxstopmode && drop_pkt_en == 1'b0))
      begin
        if(fe && (packet_dt == 6'h01))
          begin
            if(packet_vc == 2'b00)
              begin
                if(!frame_st_0_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN FRAME END SYNC  \n");
                  end
                  
                else
                  begin
                    frame_st_0_en = 1'b0;
                  end
              end
              
            if(packet_vc == 2'b01)
              begin
                if(!frame_st_1_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN FRAME END SYNC  \n");
                  end
                  
                else
                  begin
                    frame_st_1_en = 1'b0;
                  end
              end
              
            if(packet_vc == 2'b10)
              begin
                if(!frame_st_2_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN FRAME END SYNC  \n");
                  end
                  
                else
                  begin
                    frame_st_2_en = 1'b0;
                  end
              end
              
            if(packet_vc == 2'b11)
              begin
                if(!frame_st_3_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN FRAME END SYNC  \n");
                  end
                  
                else
                  begin
                    frame_st_3_en = 1'b0;
                  end
              end
          end
      end

    
  always @ (posedge le)
    if(reset_clk_csi_n && (!forcetxstopmode && drop_pkt_en == 1'b0))
      begin
        if(le && (packet_dt == 6'h03))
          begin
            if(packet_vc == 2'b00)
              begin
                if(!line_st_0_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN LINE END SYNC  \n");
                  end
                  
                else
                  begin
                    line_st_0_en = 1'b0;
                  end
              end
              
            if(packet_vc == 2'b01)
              begin
                if(!line_st_1_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN LINE END SYNC  \n");
                  end
                  
                else
                  begin
                    line_st_1_en = 1'b0;
                  end
              end
              
            if(packet_vc == 2'b10)
              begin
                if(!line_st_2_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN LINE END SYNC  \n");
                  end
                  
                else
                  begin
                    line_st_2_en = 1'b0;
                  end
              end
              
            if(packet_vc == 2'b11)
              begin
                if(!line_st_3_en)
                  begin
                    err_flg = 1'b1;
                    $display($time,"\tMONITOR : ERROR OCCURED IN LINE END SYNC  \n");
                  end
                  
                else
                  begin
                    line_st_3_en = 1'b0;
                  end
              end
          end
      end
      
  always @ (negedge reset_clk_csi_n or posedge forcetxstopmode)
    begin
      if((!reset_clk_csi_n) || forcetxstopmode) begin
        frame_st_0_en = 1'b0;
        frame_st_1_en = 1'b0;
        frame_st_2_en = 1'b0;
        frame_st_3_en = 1'b0;
        line_st_0_en  = 1'b0;
        line_st_1_en  = 1'b0;
        line_st_2_en  = 1'b0;
        line_st_3_en  = 1'b0;
        packet_en     = 1'b1;
	      lg_rdptr      = 17'h0;
	      sh_rdptr      = 17'h0;
        sh_wrptr = 16'b0;
        lg_wrptr = 16'h0;
        wc_cnt  = 16'h0;
        temp_lg_data = 32'h0;
        temp_wc_0 = 8'h0;
        temp_wc_1 = 8'h0;
        temp_data_id_vc = 24'h0;
        temp_loopback_data = 8'h0;
      end
    end
    
  always @ (reset_clk_csi_n)
    begin
      if((reset_clk_csi_n) || (!forcetxstopmode && drop_pkt_en == 1'b0)) begin
        if((packet_dt != 6'h0) && (packet_dt != 6'h1) && (packet_dt != 6'h2) && (packet_dt != 6'h3)) begin
          if(packet_vc == 2'b0) begin
            if(packet_dt[5] || packet_dt[4]) begin
              if((!frame_st_0_en) || (!line_st_0_en)) begin
                err_flg = 1'b1;
                $display($time,"\tMONITOR : ERROR OCCURED IN VIRTUAL CHANNEL SELECTION  \n");
              end
            end
          end
                
          if(packet_vc == 2'b1) begin
            if(packet_dt[5] || packet_dt[4]) begin
              if((!frame_st_1_en) || (!line_st_1_en)) begin
                err_flg = 1'b1;
                $display($time,"\tMONITOR : ERROR OCCURED IN VIRTUAL CHANNEL SELECTION  \n");
              end
            end
          end
                
          if(packet_vc == 2'b10) begin
            if(packet_dt[5] || packet_dt[4]) begin
              if((!frame_st_2_en) || (!line_st_2_en)) begin
                err_flg = 1'b1;
                $display($time,"\tMONITOR : ERROR OCCURED IN VIRTUAL CHANNEL SELECTION  \n");
              end
            end
          end
                
          if(packet_vc == 2'b11) begin
            if(packet_dt[5] || packet_dt[4]) begin
              if((!frame_st_3_en) || (!line_st_3_en)) begin
                err_flg = 1'b1;
                $display($time,"\tMONITOR : ERROR OCCURED IN VIRTUAL CHANNEL SELECTION  \n");
              end
            end
          end
        end
      end
    end
  

endmodule


