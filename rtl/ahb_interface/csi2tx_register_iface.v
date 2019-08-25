/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_register_iface.v
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
module csi2tx_register_iface
  (
    input  wire         clk_sys             ,
    input  wire         reset_clk_sys_n     ,
    input  wire [31:0]  csr_addr            ,
    input  wire         csr_rd              ,
    input  wire         csr_wr              ,
    input  wire         csr_cs_n            ,
    input  wire [31:0]  csr_wr_data         ,
    input  wire         sfifo_empty         ,
    input  wire         sfifo_full          ,
    input  wire         sfifo_almost_full   ,
    input  wire         asfifo_empty        ,
    input  wire         asfifo_full         ,
    input  wire         data_id_error       ,
    output wire         ready               ,           
    output wire         ahb_error_flag      ,       
    output wire [31:0]  csr_rd_data         ,
    output wire [2:0]   prog_lane_cnt       ,
    output wire         prog_lane_cnt_en    ,
    output wire [31:0]  trim_0              ,
    output wire [31:0]  trim_1              ,
    output wire [31:0]  trim_2              ,
    output wire [31:0]  trim_3              ,
    output wire [31:0]  dfe_dln_reg_0       ,
    output wire [31:0]  dfe_dln_reg_1       ,
    output wire [31:0]  dfe_cln_reg_0       ,
    output wire [31:0]  dfe_cln_reg_1       ,
    output wire [15:0]  pll_cnt_reg         ,
    output wire [7:0]   dfe_dln_lane_swap   ,
    output wire [39:0]  vc0_compression_reg ,
    output wire [39:0]  vc1_compression_reg ,
    output wire [39:0]  vc2_compression_reg ,
    output wire [39:0]  vc3_compression_reg
  );

//----------------------------------------------------------------------------//
/* Interanl signal declaration*/
//----------------------------------------------------------------------------//
reg [31:0] sig_out_data           ;
reg [31:0] afe_reg0_s             ;
reg [31:0] afe_reg1_s             ;
reg [31:0] afe_reg2_s             ;
reg [31:0] afe_reg3_s             ;
/*reg [31:0] afe_reg4_s             ;
reg [31:0] afe_reg5_s             ;
reg [31:0] afe_reg6_s             ;
reg [31:0] afe_reg7_s             ;*/
reg [31:0] dfe_dln_reg0           ;
reg [31:0] dfe_dln_reg1           ;
reg [31:0] dfe_cln_reg0           ;
reg [31:0] dfe_cln_reg1           ;
reg [31:0] pll_cnt_reg1           ;
reg [31:0]  dln_lane_swap          ;
//reg        sft_rst_reg_s        ;
reg [31:0] stat_reg               ;
reg [31:0] lane_cnt_reg           ;
reg        prog_lane_cnt_en_reg   ;
//reg [31:0] frame_blank_reg2       ;
//reg [31:0] line_tim_reg1          ;
//reg [31:0] line_tim_reg2          ;
reg [31:0] vc0_pred1              ;
reg [31:0] vc0_pred2              ;
reg [31:0] vc1_pred1              ;
reg [31:0] vc1_pred2              ;
reg [31:0] vc2_pred1              ;
reg [31:0] vc2_pred2              ;
reg [31:0] vc3_pred1              ;
reg [31:0] vc3_pred2              ;
//reg [15:0] cln_TxHS_Reg0_s        ;
//reg [15:0] cln_TxHS_Reg1_s        ;
//reg [15:0] cln_Lpx_Reg_s          ;
//reg [15:0] lane_swap_reg_s        ;
//reg [15:0] dbg_data1_rd           ;
//reg [15:0] dbg_data2_rd           ;
//reg [9:0]  dbg_data3_rd           ;
wire [31:0] csi_vc0_pred1         ;
wire [31:0] csi_vc0_pred2         ;
wire [31:0] csi_vc1_pred1         ;
wire [31:0] csi_vc1_pred2         ;
wire [31:0] csi_vc2_pred1         ;
wire [31:0] csi_vc2_pred2         ;
wire [31:0] csi_vc3_pred1         ;
wire [31:0] csi_vc3_pred2         ;
reg data_id_err;
wire        error_address_out_of_range;
wire        error_dword_align_addr    ;
wire        ahb_error_flag_c          ;
reg         ahb_error_flag_r          ;


//----------------------------------------------------------------------------//
/* This process implements the read operation for the CPU. When ever the processor
 request for the read operation of a particular register, the content of the register
 is placed on the data out but */
 //----------------------------------------------------------------------------//
always @(*)
  begin:read_sel_csi
    case(csr_addr)
      32'h0000 : sig_out_data = afe_reg0_s;
      32'h0004 : sig_out_data = afe_reg1_s;
      32'h0008 : sig_out_data = afe_reg2_s;
      32'h000C : sig_out_data = afe_reg3_s;
      /*32'h0010 : sig_out_data = afe_reg4_s;
      32'h0014 : sig_out_data = afe_reg5_s;
      32'h0018 : sig_out_data = afe_reg6_s;
      32'h001c : sig_out_data = afe_reg7_s;*/
      32'h0020 : sig_out_data = dfe_dln_reg0;
      32'h0024 : sig_out_data = dfe_dln_reg1;
      32'h0028 : sig_out_data = dfe_cln_reg0;
      32'h002c : sig_out_data = dfe_cln_reg1;
      32'h0030 : sig_out_data = {24'h0,dln_lane_swap[7:0]};
      //32'h0034 : sig_out_data = {31'h0,sft_rst_reg_s};
      32'h0038 : sig_out_data = stat_reg;
      32'h003c : sig_out_data = {29'h0,lane_cnt_reg[2:0]};
      //32'h0040 : sig_out_data = frame_blank_reg2;
      //32'h0044 : sig_out_data = line_tim_reg1;
      //32'h0048 : sig_out_data = line_tim_reg2;
      32'h004c : sig_out_data = vc0_pred1;
      32'h0050 : sig_out_data = vc0_pred2;
      32'h0054 : sig_out_data = vc1_pred1;
      32'h0058 : sig_out_data = vc1_pred2;
      32'h005c : sig_out_data = vc2_pred1;
      32'h0060 : sig_out_data = vc2_pred2;
      32'h0064 : sig_out_data = vc3_pred1;
      32'h0068 : sig_out_data = vc3_pred2;
      32'h006c : sig_out_data = {16'h0,pll_cnt_reg1[15:0]};
      default: sig_out_data = 32'h0;
    endcase
  end



//============================================================================//
// AHB error flag generation logic for unexpected range
// two-cycle response is required for an error condition
//===========================================================================//


assign error_address_out_of_range = (csr_cs_n == 1'b1) ? (((csr_addr >= 32'h0000_0000) && (csr_addr <= 32'h0000_006c)) ? 1'b0 : 1'b1):1'b0;


 assign error_dword_align_addr = (csr_cs_n == 1'b1) ? ((csr_addr[1:0] != 2'b00) ? 1'b1 :1'b0):1'b0;


 assign ahb_error_flag_c = (error_address_out_of_range | error_dword_align_addr);

 assign ahb_error_flag = (ahb_error_flag_r | ahb_error_flag_c);

 assign ready = ahb_error_flag_c ? 1'b0 :1'b1;

  always@(posedge clk_sys or negedge reset_clk_sys_n)
    begin
     if(!reset_clk_sys_n)
       ahb_error_flag_r <= 1'b0;
     else 
       ahb_error_flag_r <= ahb_error_flag_c;
  end


//----------------------------------------------------------------------------//
/* Registering the Internal read data bus on the external processor data bus */
//----------------------------------------------------------------------------//
/*always @ (posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    csr_rd_data <= 32'b0;
  else if(csr_rd && (csr_cs_n))
    csr_rd_data <= sig_out_data;
end*/

assign csr_rd_data = sig_out_data;

//----------------------------------------------------------------------------//
/* The write command of CPU to reg0 is captured */
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    afe_reg0_s <= 32'h00000C19;
  else if((csr_addr == 32'h0000) && csr_wr && (csr_cs_n))
    afe_reg0_s <= csr_wr_data;
end

assign trim_0 = afe_reg0_s;
//----------------------------------------------------------------------------//
/* The write command of CPU to afe reg1 is captured */
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    afe_reg1_s <= 32'h0935384C;
  else if((csr_addr == 32'h0004) && csr_wr && (csr_cs_n))
    afe_reg1_s <= csr_wr_data;
end

assign trim_1 = afe_reg1_s;
//----------------------------------------------------------------------------//
/* The write command of CPU to afe reg2 is captured */
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    afe_reg2_s <= 32'h00000000;
  else if((csr_addr == 32'h0008) && csr_wr && (csr_cs_n))
    afe_reg2_s <= csr_wr_data;
end

assign trim_2 = afe_reg2_s;
//----------------------------------------------------------------------------//
/* The write command of CPU to afe reg3 is captured */
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    afe_reg3_s <= 32'h02FC0000;
  else if((csr_addr == 32'h000C) && csr_wr && (csr_cs_n))
    afe_reg3_s <= csr_wr_data;
end

assign trim_3 = afe_reg3_s;
//----------------------------------------------------------------------------//
/* The write command of CPU to afe reg4 is captured */
//----------------------------------------------------------------------------//
/*always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    afe_reg4_s <= 32'h00100285;
  else if(csr_addr == 32'h0010 && csr_wr && (csr_cs_n))
    afe_reg4_s <= csr_wr_data;
end

assign trim_4 = afe_reg4_s;*/
//----------------------------------------------------------------------------//
/* The write command of CPU to afe reg5 is captured */
//----------------------------------------------------------------------------//
/*always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    afe_reg5_s <= 32'h10440008;
  else if(csr_addr == 32'h0014 && csr_wr && (csr_cs_n))
    afe_reg5_s <= csr_wr_data;
end

assign trim_5 = afe_reg5_s;*/
//----------------------------------------------------------------------------//
/* The write command of CPU to afe reg6 is captured */
//----------------------------------------------------------------------------//
/*always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    afe_reg6_s <= 32'h00000000;
  else if(csr_addr == 32'h0018 && csr_wr && (csr_cs_n))
    afe_reg6_s <= csr_wr_data;
end

assign trim_6 = afe_reg6_s;*/
//----------------------------------------------------------------------------//
/* The write command of CPU to afe reg7 is captured */
//----------------------------------------------------------------------------//
/*always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    afe_reg7_s <= 32'h440882A8;
  else if(csr_addr == 32'h001c && csr_wr && (csr_cs_n))
    afe_reg7_s <= csr_wr_data;
end

assign trim_7 = afe_reg7_s;*/

//----------------------------------------------------------------------------//
/* The write command of CPU to dfe data lane reg0 is captured */
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    dfe_dln_reg0 <= 32'h0A0D0716;
  else if((csr_addr == 32'h0020) && csr_wr && (csr_cs_n))
    dfe_dln_reg0<= csr_wr_data;
end

assign dfe_dln_reg_0 = dfe_dln_reg0;


/* The write command of CPU to dfe data lane reg1 is captured */
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    dfe_dln_reg1 <= 32'h00061E07;
  else if((csr_addr == 32'h0024) && csr_wr && (csr_cs_n))
    dfe_dln_reg1 <= csr_wr_data;
end

assign dfe_dln_reg_1 = dfe_dln_reg1;

//----------------------------------------------------------------------------//
/* The write command of CPU to dfe clk lane reg0 is captured */
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    dfe_cln_reg0 <= 32'h080D0521;
  else if((csr_addr == 32'h0028) && csr_wr && (csr_cs_n))
    dfe_cln_reg0<= csr_wr_data;
end

assign dfe_cln_reg_0 = dfe_cln_reg0;


/* The write command of CPU to dfe clk lane reg1 is captured */
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    dfe_cln_reg1 <= 32'h00000006;
  else if((csr_addr == 32'h002c) && csr_wr && (csr_cs_n))
    dfe_cln_reg1 <= csr_wr_data;
end

assign dfe_cln_reg_1 = dfe_cln_reg1;

always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    pll_cnt_reg1 <= 32'h00000000;
  else if((csr_addr == 32'h006c) && csr_wr && (csr_cs_n))
    pll_cnt_reg1 <= csr_wr_data;
end

assign pll_cnt_reg = pll_cnt_reg1[15:0];

//----------------------------------------------------------------------------//
// wite command to dfe lane swap register
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    dln_lane_swap <= 32'h00000000;
  else if((csr_addr == 32'h0030) && csr_wr && (csr_cs_n))
    dln_lane_swap <= csr_wr_data;
end

assign  dfe_dln_lane_swap = dln_lane_swap[7:0];



//----------------------------------------------------------------------------//
// wite command to soft reset register
//----------------------------------------------------------------------------//
/*always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    sft_rst_reg_s <= 1'b0;
  else if(csr_addr == 32'h0034 && csr_wr && (csr_cs_n))
    sft_rst_reg_s <= csr_wr_data;
end

assign  dfe_sft_rst_reg = sft_rst_reg_s;*/


//----------------------------------------------------------------------------//
// wite command to fifo status register
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    stat_reg <= 32'h00000000;
  else if((csr_addr == 32'h0038) && csr_wr && (csr_cs_n))
    stat_reg <= csr_wr_data;
  else
    stat_reg <= {26'h0,data_id_err,asfifo_full,asfifo_empty,sfifo_full,sfifo_almost_full,sfifo_empty};
end

always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
    data_id_err <= 1'b0;
  else if((csr_addr == 32'h0038) && csr_wr && (csr_cs_n) && csr_wr_data[5])
    data_id_err <= 1'b0;
  else if(data_id_error)
    data_id_err <= 1'b1;
end

//assign  status_reg = stat_reg ;

//----------------------------------------------------------------------------//
// wite command to  lane count  register 
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   lane_cnt_reg <= 32'h00000007;
  else if((csr_addr == 32'h003c) && csr_wr && (csr_cs_n))
    lane_cnt_reg <= csr_wr_data;
end

assign  prog_lane_cnt = lane_cnt_reg[2:0];

always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   prog_lane_cnt_en_reg <= 1'b0;
  else if((csr_addr == 32'h003c) && csr_wr && (csr_cs_n))
    prog_lane_cnt_en_reg <= 1'b1;
  else
    prog_lane_cnt_en_reg <= 1'b0;
end

assign  prog_lane_cnt_en = prog_lane_cnt_en_reg;

//----------------------------------------------------------------------------//
// wite command to  frame blanking register 2
//----------------------------------------------------------------------------//
/*always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   frame_blank_reg2 <= 32'h00000000;
  else if(csr_addr == 32'h0040 && csr_wr && (csr_cs_n))
    frame_blank_reg2 <= csr_wr_data;
end

assign  frame_blank_reg_2 = frame_blank_reg2;*/



//----------------------------------------------------------------------------//
// wite command to  line timing register 1
//----------------------------------------------------------------------------//
/*always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   line_tim_reg1 <= 32'h00000000;
  else if(csr_addr == 32'h0044 && csr_wr && (csr_cs_n))
    line_tim_reg1 <= csr_wr_data;
end

assign line_blank_reg1 = line_tim_reg1;*/


//----------------------------------------------------------------------------//
// wite command to  line timing register 2
//----------------------------------------------------------------------------//
/*always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   line_tim_reg2 <= 32'h00000000;
  else if(csr_addr == 32'h0048 && csr_wr && (csr_cs_n))
    line_tim_reg2 <= csr_wr_data;
end

assign line_blank_reg2 = line_tim_reg2;*/



//----------------------------------------------------------------------------//
// wite command to  virtual channel 0 with prediction 1
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   vc0_pred1 <= 32'h00000000;
  else if((csr_addr == 32'h004c) && csr_wr && (csr_cs_n))
    vc0_pred1 <= csr_wr_data;
end

assign csi_vc0_pred1 = vc0_pred1;

//----------------------------------------------------------------------------//
// wite command to  virtual channel 0 with prediction 2
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   vc0_pred2 <= 32'h00000000;
  else if((csr_addr == 32'h0050) && csr_wr && (csr_cs_n))
    vc0_pred2 <= csr_wr_data;
end

assign csi_vc0_pred2 = vc0_pred2;



//----------------------------------------------------------------------------//
// wite command to  virtual channel 1 with prediction 1
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   vc1_pred1 <= 32'h00000000;
  else if((csr_addr == 32'h0054) && csr_wr && (csr_cs_n))
    vc1_pred1 <= csr_wr_data;
end

assign csi_vc1_pred1 = vc1_pred1;

//----------------------------------------------------------------------------//
// wite command to  virtual channel 1 with prediction 2
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   vc1_pred2 <= 32'h00000000;
  else if((csr_addr == 32'h0058) && csr_wr && (csr_cs_n))
    vc1_pred2 <= csr_wr_data;
end

assign csi_vc1_pred2 = vc1_pred2;

//----------------------------------------------------------------------------//
// wite command to  virtual channel 2 with prediction 1
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   vc2_pred1 <= 32'h00000000;
  else if((csr_addr == 32'h005c) && csr_wr && (csr_cs_n))
    vc2_pred1 <= csr_wr_data;
end

assign csi_vc2_pred1 = vc2_pred1;

//----------------------------------------------------------------------------//
// wite command to  virtual channel 2 with prediction 2
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   vc2_pred2 <= 32'h00000000;
  else if((csr_addr == 32'h0060) && csr_wr && (csr_cs_n))
    vc2_pred2 <= csr_wr_data;
end

assign csi_vc2_pred2 = vc2_pred2;


//----------------------------------------------------------------------------//
// wite command to  virtual channel 3 with prediction 1
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   vc3_pred1 <= 32'h00000000;
  else if((csr_addr == 32'h0064) && csr_wr && (csr_cs_n))
    vc3_pred1 <= csr_wr_data;
end

assign csi_vc3_pred1 = vc3_pred1;

//----------------------------------------------------------------------------//
// wite command to  virtual channel 3 with prediction 2
//----------------------------------------------------------------------------//
always@(posedge clk_sys or negedge reset_clk_sys_n)
begin
  if(!reset_clk_sys_n)
   vc3_pred2 <= 32'h00000000;
  else if((csr_addr == 32'h0068) && csr_wr && (csr_cs_n))
    vc3_pred2 <= csr_wr_data;
end

assign csi_vc3_pred2 = vc3_pred2;

assign vc0_compression_reg = ({csi_vc0_pred2[9:0],csi_vc0_pred1[29:0]});
assign vc1_compression_reg = ({csi_vc1_pred2[9:0],csi_vc1_pred1[29:0]});
assign vc2_compression_reg = ({csi_vc2_pred2[9:0],csi_vc2_pred1[29:0]});
assign vc3_compression_reg = ({csi_vc3_pred2[9:0],csi_vc3_pred1[29:0]});

endmodule
