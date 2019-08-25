/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_RA2SD1024x64.v
// Author      : R.Dinesh Kumar
// Version     : v1p2
// Abstract    : This is module is used to get the 64k output from the 2 32k RAM      
//              
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
//

`timescale 1 ps / 1 ps
`celldefine
`include "csi2tx_defines.v"
//RAM MODEL
module csi2tx_RA2SD1024x32 (
  QA,
  CLKA,
  CENA_N,
  WENA_N,
  AA,
  DA,
  QB,
  QB_valid,
  CLKB,
  CENB_N,
  WENB_N,
  AB,
  DB
  );
  parameter       BITS = 32;
  parameter       word_depth = (2**`SENSOR_FIFO_ADDR_WIDTH);
  parameter       addr_width = `SENSOR_FIFO_ADDR_WIDTH;
  parameter       wordx = {BITS{1'bx}};
  parameter       addrx = {addr_width{1'bx}};
  
  output [31:0] QA;
  input CLKA;
  input CENA_N;
  input WENA_N;
  input [addr_width-1:0] AA;
  input [31:0] DA;
  output [31:0] QB;
  output QB_valid;
  input CLKB;
  input CENB_N;
  input WENB_N;
  input [addr_width-1:0] AB;
  input [31:0] DB;
  
  reg [BITS-1:0]     mem [word_depth-1:0];
  reg                     NOT_CONTA;
  reg                     NOT_CONTB;
  
  reg         NOT_CENA_N;
  reg         NOT_WENA_N;
  
  reg         NOT_AA0;
  reg         NOT_AA1;
  reg         NOT_AA2;
  reg         NOT_AA3;
  reg         NOT_AA4;
  reg         NOT_AA5;
  reg         NOT_AA6;
  reg         NOT_AA7;
  reg         NOT_AA8;
  reg         NOT_AA9;
  reg [addr_width-1:0]     NOT_AA;
  reg         NOT_DA0;
  reg         NOT_DA1;
  reg         NOT_DA2;
  reg         NOT_DA3;
  reg         NOT_DA4;
  reg         NOT_DA5;
  reg         NOT_DA6;
  reg         NOT_DA7;
  reg         NOT_DA8;
  reg         NOT_DA9;
  reg         NOT_DA10;
  reg         NOT_DA11;
  reg         NOT_DA12;
  reg         NOT_DA13;
  reg         NOT_DA14;
  reg         NOT_DA15;
  reg         NOT_DA16;
  reg         NOT_DA17;
  reg         NOT_DA18;
  reg         NOT_DA19;
  reg         NOT_DA20;
  reg         NOT_DA21;
  reg         NOT_DA22;
  reg         NOT_DA23;
  reg         NOT_DA24;
  reg         NOT_DA25;
  reg         NOT_DA26;
  reg         NOT_DA27;
  reg         NOT_DA28;
  reg         NOT_DA29;
  reg         NOT_DA30;
  reg         NOT_DA31;
  reg         NOT_DA32;
  reg         NOT_DA33;
  reg [BITS-1:0]     NOT_DA;
  reg         NOT_CLKA_PER;
  reg         NOT_CLKA_MINH;
  reg         NOT_CLKA_MINL;
  reg         NOT_CENB_N;
  reg         NOT_WENB_N;
  
  reg         NOT_AB0;
  reg         NOT_AB1;
  reg         NOT_AB2;
  reg         NOT_AB3;
  reg         NOT_AB4;
  reg         NOT_AB5;
  reg         NOT_AB6;
  reg         NOT_AB7;
  reg         NOT_AB8;
  reg         NOT_AB9;
  reg [addr_width-1:0]     NOT_AB;
  reg         NOT_DB0;
  reg         NOT_DB1;
  reg         NOT_DB2;
  reg         NOT_DB3;
  reg         NOT_DB4;
  reg         NOT_DB5;
  reg         NOT_DB6;
  reg         NOT_DB7;
  reg         NOT_DB8;
  reg         NOT_DB9;
  reg         NOT_DB10;
  reg         NOT_DB11;
  reg         NOT_DB12;
  reg         NOT_DB13;
  reg         NOT_DB14;
  reg         NOT_DB15;
  reg         NOT_DB16;
  reg         NOT_DB17;
  reg         NOT_DB18;
  reg         NOT_DB19;
  reg         NOT_DB20;
  reg         NOT_DB21;
  reg         NOT_DB22;
  reg         NOT_DB23;
  reg         NOT_DB24;
  reg         NOT_DB25;
  reg         NOT_DB26;
  reg         NOT_DB27;
  reg         NOT_DB28;
  reg         NOT_DB29;
  reg         NOT_DB30;
  reg         NOT_DB31;
  reg [BITS-1:0]     NOT_DB;
  reg         NOT_CLKB_PER;
  reg         NOT_CLKB_MINH;
  reg         NOT_CLKB_MINL;
  
  reg         LAST_NOT_CENA_N;
  reg         LAST_NOT_WENA_N;
  reg [addr_width-1:0]     LAST_NOT_AA;
  reg [BITS-1:0]     LAST_NOT_DA;
  reg         LAST_NOT_CLKA_PER;
  reg         LAST_NOT_CLKA_MINH;
  reg         LAST_NOT_CLKA_MINL;
  reg         LAST_NOT_CENB_N;
  reg         LAST_NOT_WENB_N;
  reg [addr_width-1:0]     LAST_NOT_AB;
  reg [BITS-1:0]     LAST_NOT_DB;
  reg         LAST_NOT_CLKB_PER;
  reg         LAST_NOT_CLKB_MINH;
  reg         LAST_NOT_CLKB_MINL;
  
  reg                     LAST_NOT_CONTA;
  reg                     LAST_NOT_CONTB;
  wire                    contA_flag;
  wire                    contB_flag;
  wire                    cont_flag;
  
  wire [BITS-1:0]   _QA;
  wire [addr_width-1:0]   _AA;
  wire         _CLKA;
  wire         _CENA_N;
  wire                    _WENA_N;
  
  wire [BITS-1:0]   _DA;
  wire                    re_flagA;
  wire                    re_data_flagA;
  
  wire [BITS-1:0]   _QB;
  wire [addr_width-1:0]   _AB;
  wire         _CLKB;
  wire         _CENB_N;
  wire                    _WENB_N;
  
  wire [BITS-1:0]   _DB;
  wire                    re_flagB;
  wire                    re_data_flagB;
  
  
  reg         LATCHED_CENA_N;
  reg                    LATCHED_WENA_N;
  reg [addr_width-1:0]     LATCHED_AA;
  reg [BITS-1:0]     LATCHED_DA;
  reg         LATCHED_CENB_N;
  reg                    LATCHED_WENB_N;
  reg [addr_width-1:0]     LATCHED_AB;
  reg [BITS-1:0]     LATCHED_DB;
  
  reg         CENA_Ni;
  reg                WENA_Ni;
  reg [addr_width-1:0]     AAi;
  reg [BITS-1:0]     DAi;
  reg [BITS-1:0]     QAi;
  reg [BITS-1:0]     LAST_QAi;
  reg         CENB_Ni;
  reg                WENB_Ni;
  reg [addr_width-1:0]     ABi;
  reg [BITS-1:0]     DBi;
  reg [BITS-1:0]     QBi;
  reg [BITS-1:0]     LAST_QBi;
  reg QB_valid;
  reg QB_validi;
  
  
  reg         LAST_CLKA;
  reg         LAST_CLKB;
  
  
  
  reg                     valid_cycleA;
  reg                     valid_cycleB;
  
  
  task update_Anotifier_buses;
    begin
      NOT_AA = {
      NOT_AA9,
      NOT_AA8,
      NOT_AA7,
      NOT_AA6,
      NOT_AA5,
      NOT_AA4,
      NOT_AA3,
      NOT_AA2,
      NOT_AA1,
      NOT_AA0};
      NOT_DA = {
      NOT_DA31,
      NOT_DA30,
      NOT_DA29,
      NOT_DA28,
      NOT_DA27,
      NOT_DA26,
      NOT_DA25,
      NOT_DA24,
      NOT_DA23,
      NOT_DA22,
      NOT_DA21,
      NOT_DA20,
      NOT_DA19,
      NOT_DA18,
      NOT_DA17,
      NOT_DA16,
      NOT_DA15,
      NOT_DA14,
      NOT_DA13,
      NOT_DA12,
      NOT_DA11,
      NOT_DA10,
      NOT_DA9,
      NOT_DA8,
      NOT_DA7,
      NOT_DA6,
      NOT_DA5,
      NOT_DA4,
      NOT_DA3,
      NOT_DA2,
      NOT_DA1,
      NOT_DA0};
    end
  endtask
  task update_Bnotifier_buses;
    begin
      NOT_AB = {
      NOT_AB9,
      NOT_AB8,
      NOT_AB7,
      NOT_AB6,
      NOT_AB5,
      NOT_AB4,
      NOT_AB3,
      NOT_AB2,
      NOT_AB1,
      NOT_AB0};
      NOT_DB = {
      NOT_DB31,
      NOT_DB30,
      NOT_DB29,
      NOT_DB28,
      NOT_DB27,
      NOT_DB26,
      NOT_DB25,
      NOT_DB24,
      NOT_DB23,
      NOT_DB22,
      NOT_DB21,
      NOT_DB20,
      NOT_DB19,
      NOT_DB18,
      NOT_DB17,
      NOT_DB16,
      NOT_DB15,
      NOT_DB14,
      NOT_DB13,
      NOT_DB12,
      NOT_DB11,
      NOT_DB10,
      NOT_DB9,
      NOT_DB8,
      NOT_DB7,
      NOT_DB6,
      NOT_DB5,
      NOT_DB4,
      NOT_DB3,
      NOT_DB2,
      NOT_DB1,
      NOT_DB0};
    end
  endtask
  
  task mem_cycleA;
    begin
      valid_cycleA = 1'bx;
      casez({WENA_Ni,CENA_Ni})
        
        2'b10: begin
            valid_cycleA = 1;
            read_memA(1,0);
          end
        2'b00: begin
            valid_cycleA = 0;
            write_mem(AAi,DAi);
            read_memA(0,0);
          end
        2'b?1: ;
        2'b1x: begin
            valid_cycleA = 1;
            read_memA(0,1);
          end
        2'bx0: begin
            valid_cycleA = 0;
            write_mem_x(AAi);
            read_memA(0,1);
          end
        2'b0x,
          2'bxx: begin
            valid_cycleA = 0;
            write_mem_x(AAi);
            read_memA(0,1);
          end
      endcase
    end
  endtask
  task mem_cycleB;
    begin
      valid_cycleB = 1'bx;
      casez({WENB_Ni,CENB_Ni})
        
        2'b10: begin
            valid_cycleB = 1;
            read_memB(1,0);
          end
        2'b00: begin
            valid_cycleB = 0;
            write_mem(ABi,DBi);
            read_memB(0,0);
          end
        2'b?1: ;
        2'b1x: begin
            valid_cycleB = 1;
            read_memB(0,1);
          end
        2'bx0: begin
            valid_cycleB = 0;
            write_mem_x(ABi);
            read_memB(0,1);
          end
        2'b0x,
          2'bxx: begin
            valid_cycleB = 0;
            write_mem_x(ABi);
            read_memB(0,1);
          end
      endcase
    end
  endtask
  
  task contentionA;
    begin
      casez({valid_cycleB,WENA_Ni})
        2'bx?: ;
        2'b00,
          2'b0x:begin
            write_mem_x(AAi);
          end
        2'b10,
          2'b1x:begin
            write_mem_x(AAi);
            read_memB(0,1);
          end
        2'b01:begin
            write_mem_x(AAi);
            read_memA(0,1);
          end
        2'b11: ;
      endcase
    end
  endtask
  
  task contentionB;
    begin
      casez({valid_cycleA,WENB_Ni})
        2'bx?: ;
        2'b00,
          2'b0x:begin
            write_mem_x(ABi);
          end
        2'b10,
          2'b1x:begin
            write_mem_x(ABi);
            read_memA(0,1);
          end
        2'b01:begin
            write_mem_x(ABi);
            read_memB(0,1);
          end
        2'b11: ;
      endcase
    end
  endtask
  
  task update_Alast_notifiers;
    begin
      LAST_NOT_AA = NOT_AA;
      LAST_NOT_DA = NOT_DA;
      LAST_NOT_WENA_N = NOT_WENA_N;
      LAST_NOT_CENA_N = NOT_CENA_N;
      LAST_NOT_CLKA_PER = NOT_CLKA_PER;
      LAST_NOT_CLKA_MINH = NOT_CLKA_MINH;
      LAST_NOT_CLKA_MINL = NOT_CLKA_MINL;
      LAST_NOT_CONTA = NOT_CONTA;
    end
  endtask
  task update_Blast_notifiers;
    begin
      LAST_NOT_AB = NOT_AB;
      LAST_NOT_DB = NOT_DB;
      LAST_NOT_WENB_N = NOT_WENB_N;
      LAST_NOT_CENB_N = NOT_CENB_N;
      LAST_NOT_CLKB_PER = NOT_CLKB_PER;
      LAST_NOT_CLKB_MINH = NOT_CLKB_MINH;
      LAST_NOT_CLKB_MINL = NOT_CLKB_MINL;
      LAST_NOT_CONTB = NOT_CONTB;
    end
  endtask
  
  task latch_Ainputs;
    begin
      LATCHED_AA = _AA ;
      LATCHED_DA = _DA ;
      LATCHED_WENA_N = _WENA_N ;
      LATCHED_CENA_N = _CENA_N ;
      LAST_QAi = QAi;
    end
  endtask
  task latch_Binputs;
    begin
      LATCHED_AB = _AB ;
      LATCHED_DB = _DB ;
      LATCHED_WENB_N = _WENB_N ;
      LATCHED_CENB_N = _CENB_N ;
      LAST_QBi = QBi;
    end
  endtask
  
  
  task update_Alogic;
    begin
      CENA_Ni = LATCHED_CENA_N;
      WENA_Ni = LATCHED_WENA_N;
      AAi = LATCHED_AA;
      DAi = LATCHED_DA;
    end
  endtask
  task update_Blogic;
    begin
      CENB_Ni = LATCHED_CENB_N;
      WENB_Ni = LATCHED_WENB_N;
      ABi = LATCHED_AB;
      DBi = LATCHED_DB;
    end
  endtask
  
  
  
  task x_Ainputs;
    integer n;
    begin
      for (n=0; n<addr_width; n=n+1)
        begin
          LATCHED_AA[n] = (NOT_AA[n]!==LAST_NOT_AA[n]) ? 1'bx : LATCHED_AA[n] ;
        end
      for (n=0; n<BITS; n=n+1)
        begin
          LATCHED_DA[n] = (NOT_DA[n]!==LAST_NOT_DA[n]) ? 1'bx : LATCHED_DA[n] ;
        end
      LATCHED_WENA_N = (NOT_WENA_N!==LAST_NOT_WENA_N) ? 1'bx : LATCHED_WENA_N ;
      
      LATCHED_CENA_N = (NOT_CENA_N!==LAST_NOT_CENA_N) ? 1'bx : LATCHED_CENA_N ;
    end
  endtask
  task x_Binputs;
    integer n;
    begin
      for (n=0; n<addr_width; n=n+1)
        begin
          LATCHED_AB[n] = (NOT_AB[n]!==LAST_NOT_AB[n]) ? 1'bx : LATCHED_AB[n] ;
        end
      for (n=0; n<BITS; n=n+1)
        begin
          LATCHED_DB[n] = (NOT_DB[n]!==LAST_NOT_DB[n]) ? 1'bx : LATCHED_DB[n] ;
        end
      LATCHED_WENB_N = (NOT_WENB_N!==LAST_NOT_WENB_N) ? 1'bx : LATCHED_WENB_N ;
      
      LATCHED_CENB_N = (NOT_CENB_N!==LAST_NOT_CENB_N) ? 1'bx : LATCHED_CENB_N ;
    end
  endtask
  
  task read_memA;
    input r_wb;
    input xflag;
    begin
      if (r_wb)
        begin
          if (valid_address(AAi))
            begin
              QAi=mem[AAi];
            end
          else
            begin
              x_mem;
              QAi=wordx;
            end
        end
      else
        begin
          if (xflag)
            begin
              QAi=wordx;
            end
          else
            begin
              QAi=DAi;
            end
        end
    end
  endtask
  task read_memB;
    input r_wb;
    input xflag;
    begin
      if (r_wb)
        begin
          if (valid_address(ABi))
            begin
              QBi=mem[ABi];
            end
          else
            begin
              x_mem;
              QBi=wordx;
            end
        end
      else
        begin
          if (xflag)
            begin
              QBi=wordx;
            end
          else
            begin
              QBi=DBi;
            end
        end
    end
  endtask
  
  task write_mem;
    input [addr_width-1:0] a;
    input [BITS-1:0] d;
    
    begin
      casez({valid_address(a)})
        1'b0:
          x_mem;
        1'b1: mem[a]=d;
      endcase
    end
  endtask
  
  task write_mem_x;
    input [addr_width-1:0] a;
    begin
      casez({valid_address(a)})
        1'b0:
          x_mem;
        1'b1: mem[a]=wordx;
      endcase
    end
  endtask
  
  task x_mem;
    integer n;
    begin
      for (n=0; n<word_depth; n=n+1)
        mem[n]=wordx;
    end
  endtask
  
  task process_violationsA;
    begin
      if ((NOT_CLKA_PER!==LAST_NOT_CLKA_PER) ||
        (NOT_CLKA_MINH!==LAST_NOT_CLKA_MINH) ||
        (NOT_CLKA_MINL!==LAST_NOT_CLKA_MINL))
        begin
          if (CENA_Ni !== 1'b1)
            begin
              x_mem;
              read_memA(0,1);
            end
        end
      else
        begin
          update_Anotifier_buses;
          x_Ainputs;
          update_Alogic;
          if (NOT_CONTA!==LAST_NOT_CONTA)
            begin
              contentionA;
            end
          else
            begin
              mem_cycleA;
            end
        end
      update_Alast_notifiers;
    end
  endtask
  
  task process_violationsB;
    begin
      if ((NOT_CLKB_PER!==LAST_NOT_CLKB_PER) ||
        (NOT_CLKB_MINH!==LAST_NOT_CLKB_MINH) ||
        (NOT_CLKB_MINL!==LAST_NOT_CLKB_MINL))
        begin
          if (CENB_Ni !== 1'b1)
            begin
              x_mem;
              read_memB(0,1);
            end
        end
      else
        begin
          update_Bnotifier_buses;
          x_Binputs;
          update_Blogic;
          if (NOT_CONTB!==LAST_NOT_CONTB)
            begin
              contentionB;
            end
          else
            begin
              mem_cycleB;
            end
        end
      update_Blast_notifiers;
    end
  endtask
  
  function valid_address;
    input [addr_width-1:0] a;
    begin
      valid_address = (^(a) !== 1'bx);
    end
  endfunction
  
  
  buf (QA[0], _QA[0]);
  buf (QA[1], _QA[1]);
  buf (QA[2], _QA[2]);
  buf (QA[3], _QA[3]);
  buf (QA[4], _QA[4]);
  buf (QA[5], _QA[5]);
  buf (QA[6], _QA[6]);
  buf (QA[7], _QA[7]);
  buf (QA[8], _QA[8]);
  buf (QA[9], _QA[9]);
  buf (QA[10], _QA[10]);
  buf (QA[11], _QA[11]);
  buf (QA[12], _QA[12]);
  buf (QA[13], _QA[13]);
  buf (QA[14], _QA[14]);
  buf (QA[15], _QA[15]);
  buf (QA[16], _QA[16]);
  buf (QA[17], _QA[17]);
  buf (QA[18], _QA[18]);
  buf (QA[19], _QA[19]);
  buf (QA[20], _QA[20]);
  buf (QA[21], _QA[21]);
  buf (QA[22], _QA[22]);
  buf (QA[23], _QA[23]);
  buf (QA[24], _QA[24]);
  buf (QA[25], _QA[25]);
  buf (QA[26], _QA[26]);
  buf (QA[27], _QA[27]);
  buf (QA[28], _QA[28]);
  buf (QA[29], _QA[29]);
  buf (QA[30], _QA[30]);
  buf (QA[31], _QA[31]);
  buf (_DA[0], DA[0]);
  buf (_DA[1], DA[1]);
  buf (_DA[2], DA[2]);
  buf (_DA[3], DA[3]);
  buf (_DA[4], DA[4]);
  buf (_DA[5], DA[5]);
  buf (_DA[6], DA[6]);
  buf (_DA[7], DA[7]);
  buf (_DA[8], DA[8]);
  buf (_DA[9], DA[9]);
  buf (_DA[10], DA[10]);
  buf (_DA[11], DA[11]);
  buf (_DA[12], DA[12]);
  buf (_DA[13], DA[13]);
  buf (_DA[14], DA[14]);
  buf (_DA[15], DA[15]);
  buf (_DA[16], DA[16]);
  buf (_DA[17], DA[17]);
  buf (_DA[18], DA[18]);
  buf (_DA[19], DA[19]);
  buf (_DA[20], DA[20]);
  buf (_DA[21], DA[21]);
  buf (_DA[22], DA[22]);
  buf (_DA[23], DA[23]);
  buf (_DA[24], DA[24]);
  buf (_DA[25], DA[25]);
  buf (_DA[26], DA[26]);
  buf (_DA[27], DA[27]);
  buf (_DA[28], DA[28]);
  buf (_DA[29], DA[29]);
  buf (_DA[30], DA[30]);
  buf (_DA[31], DA[31]);
//  buf (_AA[0], AA[0]);
//  buf (_AA[1], AA[1]);
//  buf (_AA[2], AA[2]);
//  buf (_AA[3], AA[3]);
//  buf (_AA[4], AA[4]);
//  buf (_AA[5], AA[5]);
//  buf (_AA[6], AA[6]);
//  buf (_AA[7], AA[7]);
//  buf (_AA[8], AA[8]);
//  buf (_AA[9], AA[9]);
  genvar porta_addrs_bus;
  generate 
   for (porta_addrs_bus=0;porta_addrs_bus <`SENSOR_FIFO_ADDR_WIDTH; porta_addrs_bus=porta_addrs_bus+1)
   begin: U_PORTA_GEN_ADDRS_BUS
     buf
      u_buf
      (_AA[porta_addrs_bus], AA[porta_addrs_bus]);
      
   end
 endgenerate
  buf (_CLKA, CLKA);
  buf (_WENA_N, WENA_N);
  buf (_CENA_N, CENA_N);
  buf (QB[0], _QB[0]);
  buf (QB[1], _QB[1]);
  buf (QB[2], _QB[2]);
  buf (QB[3], _QB[3]);
  buf (QB[4], _QB[4]);
  buf (QB[5], _QB[5]);
  buf (QB[6], _QB[6]);
  buf (QB[7], _QB[7]);
  buf (QB[8], _QB[8]);
  buf (QB[9], _QB[9]);
  buf (QB[10], _QB[10]);
  buf (QB[11], _QB[11]);
  buf (QB[12], _QB[12]);
  buf (QB[13], _QB[13]);
  buf (QB[14], _QB[14]);
  buf (QB[15], _QB[15]);
  buf (QB[16], _QB[16]);
  buf (QB[17], _QB[17]);
  buf (QB[18], _QB[18]);
  buf (QB[19], _QB[19]);
  buf (QB[20], _QB[20]);
  buf (QB[21], _QB[21]);
  buf (QB[22], _QB[22]);
  buf (QB[23], _QB[23]);
  buf (QB[24], _QB[24]);
  buf (QB[25], _QB[25]);
  buf (QB[26], _QB[26]);
  buf (QB[27], _QB[27]);
  buf (QB[28], _QB[28]);
  buf (QB[29], _QB[29]);
  buf (QB[30], _QB[30]);
  buf (QB[31], _QB[31]);
  buf (_DB[0], DB[0]);
  buf (_DB[1], DB[1]);
  buf (_DB[2], DB[2]);
  buf (_DB[3], DB[3]);
  buf (_DB[4], DB[4]);
  buf (_DB[5], DB[5]);
  buf (_DB[6], DB[6]);
  buf (_DB[7], DB[7]);
  buf (_DB[8], DB[8]);
  buf (_DB[9], DB[9]);
  buf (_DB[10], DB[10]);
  buf (_DB[11], DB[11]);
  buf (_DB[12], DB[12]);
  buf (_DB[13], DB[13]);
  buf (_DB[14], DB[14]);
  buf (_DB[15], DB[15]);
  buf (_DB[16], DB[16]);
  buf (_DB[17], DB[17]);
  buf (_DB[18], DB[18]);
  buf (_DB[19], DB[19]);
  buf (_DB[20], DB[20]);
  buf (_DB[21], DB[21]);
  buf (_DB[22], DB[22]);
  buf (_DB[23], DB[23]);
  buf (_DB[24], DB[24]);
  buf (_DB[25], DB[25]);
  buf (_DB[26], DB[26]);
  buf (_DB[27], DB[27]);
  buf (_DB[28], DB[28]);
  buf (_DB[29], DB[29]);
  buf (_DB[30], DB[30]);
  buf (_DB[31], DB[31]);
//  buf (_AB[0], AB[0]);
//  buf (_AB[1], AB[1]);
//  buf (_AB[2], AB[2]);
//  buf (_AB[3], AB[3]);
//  buf (_AB[4], AB[4]);
//  buf (_AB[5], AB[5]);
//  buf (_AB[6], AB[6]);
//  buf (_AB[7], AB[7]);
//  buf (_AB[8], AB[8]);
//  buf (_AB[9], AB[9]);
  genvar portb_addrs_bus;
  generate 
   for (portb_addrs_bus=0;portb_addrs_bus <`SENSOR_FIFO_ADDR_WIDTH; portb_addrs_bus=portb_addrs_bus+1)
   begin: U_PORTB_GEN_ADDRS_BUS
     buf
      u_buf
       (_AB[portb_addrs_bus],AB[portb_addrs_bus]);
   end
 endgenerate

  buf (_CLKB, CLKB);
  buf (_WENB_N, WENB_N);
  buf (_CENB_N, CENB_N);
  
  
  assign _QA = QAi;
  assign re_flagA = !(_CENA_N);
  assign re_data_flagA = !(_CENA_N || _WENA_N);
  assign _QB = QBi;
  assign re_flagB = !(_CENB_N);
  assign re_data_flagB = !(_CENB_N || _WENB_N);
  
  assign contA_flag =
    (_AA === ABi) &&
    !((_WENA_N === 1'b1) && (WENB_Ni === 1'b1)) &&
    (_CENA_N !== 1'b1) &&
    (CENB_Ni !== 1'b1);
  
  assign contB_flag =
    (_AB === AAi) &&
    !((_WENB_N === 1'b1) && (WENA_Ni === 1'b1)) &&
    (_CENB_N !== 1'b1) &&
    (CENA_Ni !== 1'b1);
  
  assign cont_flag =
    (_AB === _AA) &&
    !((_WENB_N === 1'b1) && (_WENA_N === 1'b1)) &&
    (_CENB_N !== 1'b1) &&
    (_CENA_N !== 1'b1);
  
  always @(
    NOT_AA0 or
    NOT_AA1 or
    NOT_AA2 or
    NOT_AA3 or
    NOT_AA4 or
    NOT_AA5 or
    NOT_AA6 or
    NOT_AA7 or
    NOT_AA8 or
    NOT_AA9 or
    NOT_DA0 or
    NOT_DA1 or
    NOT_DA2 or
    NOT_DA3 or
    NOT_DA4 or
    NOT_DA5 or
    NOT_DA6 or
    NOT_DA7 or
    NOT_DA8 or
    NOT_DA9 or
    NOT_DA10 or
    NOT_DA11 or
    NOT_DA12 or
    NOT_DA13 or
    NOT_DA14 or
    NOT_DA15 or
    NOT_DA16 or
    NOT_DA17 or
    NOT_DA18 or
    NOT_DA19 or
    NOT_DA20 or
    NOT_DA21 or
    NOT_DA22 or
    NOT_DA23 or
    NOT_DA24 or
    NOT_DA25 or
    NOT_DA26 or
    NOT_DA27 or
    NOT_DA28 or
    NOT_DA29 or
    NOT_DA30 or
    NOT_DA31 or
    NOT_WENA_N or
    NOT_CENA_N or
    NOT_CONTA or
    NOT_CLKA_PER or
    NOT_CLKA_MINH or
    NOT_CLKA_MINL
    )
    begin
      process_violationsA;
    end
  always @(
    NOT_AB0 or
    NOT_AB1 or
    NOT_AB2 or
    NOT_AB3 or
    NOT_AB4 or
    NOT_AB5 or
    NOT_AB6 or
    NOT_AB7 or
    NOT_AB8 or
    NOT_AB9 or
    NOT_DB0 or
    NOT_DB1 or
    NOT_DB2 or
    NOT_DB3 or
    NOT_DB4 or
    NOT_DB5 or
    NOT_DB6 or
    NOT_DB7 or
    NOT_DB8 or
    NOT_DB9 or
    NOT_DB10 or
    NOT_DB11 or
    NOT_DB12 or
    NOT_DB13 or
    NOT_DB14 or
    NOT_DB15 or
    NOT_DB16 or
    NOT_DB17 or
    NOT_DB18 or
    NOT_DB19 or
    NOT_DB20 or
    NOT_DB21 or
    NOT_DB22 or
    NOT_DB23 or
    NOT_DB24 or
    NOT_DB25 or
    NOT_DB26 or
    NOT_DB27 or
    NOT_DB28 or
    NOT_DB29 or
    NOT_DB30 or
    NOT_DB31 or
    NOT_WENB_N or
    NOT_CENB_N or
    NOT_CONTB or
    NOT_CLKB_PER or
    NOT_CLKB_MINH or
    NOT_CLKB_MINL
    )
    begin
      process_violationsB;
    end
  
  always @( _CLKA )
    begin
      casez({LAST_CLKA,_CLKA})
        2'b01: begin
            latch_Ainputs;
            update_Alogic;
            mem_cycleA;
          end
        
        2'b10,
          2'bx?,
          2'b00,
          2'b11: ;
        
        2'b?x: begin
            x_mem;
            read_memA(0,1);
          end
        
      endcase
      LAST_CLKA = _CLKA;
    end
  always @( _CLKB )
    begin
      casez({LAST_CLKB,_CLKB})
        2'b01: begin
            latch_Binputs;
            update_Blogic;
            mem_cycleB;
          end
        
        2'b10,
          2'bx?,
          2'b00,
          2'b11: ;
        
        2'b?x: begin
            x_mem;
            read_memB(0,1);
          end
        
      endcase
      LAST_CLKB = _CLKB;
    end

  always @( _CLKB )
    begin
       QB_validi <= re_flagA;
       QB_valid <= QB_validi;
    end
  /*
  specify
  $setuphold(posedge CLKA, posedge CENA_N, 1.000, 0.500, NOT_CENA_N);
  $setuphold(posedge CLKA, negedge CENA_N, 1.000, 0.500, NOT_CENA_N);
  $setuphold(posedge CLKA &&& re_flagA, posedge WENA_N, 1.000, 0.500, NOT_WENA_N);
  $setuphold(posedge CLKA &&& re_flagA, negedge WENA_N, 1.000, 0.500, NOT_WENA_N);
  $setuphold(posedge CLKA &&& re_flagA, posedge AA[0], 1.000, 0.500, NOT_AA0);
  $setuphold(posedge CLKA &&& re_flagA, negedge AA[0], 1.000, 0.500, NOT_AA0);
  $setuphold(posedge CLKA &&& re_flagA, posedge AA[1], 1.000, 0.500, NOT_AA1);
  $setuphold(posedge CLKA &&& re_flagA, negedge AA[1], 1.000, 0.500, NOT_AA1);
  $setuphold(posedge CLKA &&& re_flagA, posedge AA[2], 1.000, 0.500, NOT_AA2);
  $setuphold(posedge CLKA &&& re_flagA, negedge AA[2], 1.000, 0.500, NOT_AA2);
  $setuphold(posedge CLKA &&& re_flagA, posedge AA[3], 1.000, 0.500, NOT_AA3);
  $setuphold(posedge CLKA &&& re_flagA, negedge AA[3], 1.000, 0.500, NOT_AA3);
  $setuphold(posedge CLKA &&& re_flagA, posedge AA[4], 1.000, 0.500, NOT_AA4);
  $setuphold(posedge CLKA &&& re_flagA, negedge AA[4], 1.000, 0.500, NOT_AA4);
  $setuphold(posedge CLKA &&& re_flagA, posedge AA[5], 1.000, 0.500, NOT_AA5);
  $setuphold(posedge CLKA &&& re_flagA, negedge AA[5], 1.000, 0.500, NOT_AA5);
  //   $setuphold(posedge CLKA &&& re_flagA, posedge AA[6], 1.000, 0.500, NOT_AA6);
  //   $setuphold(posedge CLKA &&& re_flagA, negedge AA[6], 1.000, 0.500, NOT_AA6);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[0], 1.000, 0.500, NOT_DA0);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[0], 1.000, 0.500, NOT_DA0);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[1], 1.000, 0.500, NOT_DA1);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[1], 1.000, 0.500, NOT_DA1);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[2], 1.000, 0.500, NOT_DA2);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[2], 1.000, 0.500, NOT_DA2);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[3], 1.000, 0.500, NOT_DA3);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[3], 1.000, 0.500, NOT_DA3);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[4], 1.000, 0.500, NOT_DA4);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[4], 1.000, 0.500, NOT_DA4);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[5], 1.000, 0.500, NOT_DA5);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[5], 1.000, 0.500, NOT_DA5);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[6], 1.000, 0.500, NOT_DA6);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[6], 1.000, 0.500, NOT_DA6);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[7], 1.000, 0.500, NOT_DA7);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[7], 1.000, 0.500, NOT_DA7);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[8], 1.000, 0.500, NOT_DA8);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[8], 1.000, 0.500, NOT_DA8);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[9], 1.000, 0.500, NOT_DA9);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[9], 1.000, 0.500, NOT_DA9);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[10], 1.000, 0.500, NOT_DA10);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[10], 1.000, 0.500, NOT_DA10);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[11], 1.000, 0.500, NOT_DA11);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[11], 1.000, 0.500, NOT_DA11);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[12], 1.000, 0.500, NOT_DA12);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[12], 1.000, 0.500, NOT_DA12);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[13], 1.000, 0.500, NOT_DA13);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[13], 1.000, 0.500, NOT_DA13);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[14], 1.000, 0.500, NOT_DA14);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[14], 1.000, 0.500, NOT_DA14);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[15], 1.000, 0.500, NOT_DA15);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[15], 1.000, 0.500, NOT_DA15);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[16], 1.000, 0.500, NOT_DA16);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[16], 1.000, 0.500, NOT_DA16);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[17], 1.000, 0.500, NOT_DA17);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[17], 1.000, 0.500, NOT_DA17);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[18], 1.000, 0.500, NOT_DA18);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[18], 1.000, 0.500, NOT_DA18);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[19], 1.000, 0.500, NOT_DA19);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[19], 1.000, 0.500, NOT_DA19);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[20], 1.000, 0.500, NOT_DA20);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[20], 1.000, 0.500, NOT_DA20);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[21], 1.000, 0.500, NOT_DA21);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[21], 1.000, 0.500, NOT_DA21);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[22], 1.000, 0.500, NOT_DA22);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[22], 1.000, 0.500, NOT_DA22);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[23], 1.000, 0.500, NOT_DA23);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[23], 1.000, 0.500, NOT_DA23);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[24], 1.000, 0.500, NOT_DA24);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[24], 1.000, 0.500, NOT_DA24);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[25], 1.000, 0.500, NOT_DA25);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[25], 1.000, 0.500, NOT_DA25);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[26], 1.000, 0.500, NOT_DA26);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[26], 1.000, 0.500, NOT_DA26);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[27], 1.000, 0.500, NOT_DA27);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[27], 1.000, 0.500, NOT_DA27);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[28], 1.000, 0.500, NOT_DA28);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[28], 1.000, 0.500, NOT_DA28);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[29], 1.000, 0.500, NOT_DA29);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[29], 1.000, 0.500, NOT_DA29);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[30], 1.000, 0.500, NOT_DA30);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[30], 1.000, 0.500, NOT_DA30);
  $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[31], 1.000, 0.500, NOT_DA31);
  $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[31], 1.000, 0.500, NOT_DA31);
  $setuphold(posedge CLKB, posedge CENB_N, 1.000, 0.500, NOT_CENB_N);
  $setuphold(posedge CLKB, negedge CENB_N, 1.000, 0.500, NOT_CENB_N);
  $setuphold(posedge CLKB &&& re_flagB, posedge WENB_N, 1.000, 0.500, NOT_WENB_N);
  $setuphold(posedge CLKB &&& re_flagB, negedge WENB_N, 1.000, 0.500, NOT_WENB_N);
  $setuphold(posedge CLKB &&& re_flagB, posedge AB[0], 1.000, 0.500, NOT_AB0);
  $setuphold(posedge CLKB &&& re_flagB, negedge AB[0], 1.000, 0.500, NOT_AB0);
  $setuphold(posedge CLKB &&& re_flagB, posedge AB[1], 1.000, 0.500, NOT_AB1);
  $setuphold(posedge CLKB &&& re_flagB, negedge AB[1], 1.000, 0.500, NOT_AB1);
  $setuphold(posedge CLKB &&& re_flagB, posedge AB[2], 1.000, 0.500, NOT_AB2);
  $setuphold(posedge CLKB &&& re_flagB, negedge AB[2], 1.000, 0.500, NOT_AB2);
  $setuphold(posedge CLKB &&& re_flagB, posedge AB[3], 1.000, 0.500, NOT_AB3);
  $setuphold(posedge CLKB &&& re_flagB, negedge AB[3], 1.000, 0.500, NOT_AB3);
  $setuphold(posedge CLKB &&& re_flagB, posedge AB[4], 1.000, 0.500, NOT_AB4);
  $setuphold(posedge CLKB &&& re_flagB, negedge AB[4], 1.000, 0.500, NOT_AB4);
  $setuphold(posedge CLKB &&& re_flagB, posedge AB[5], 1.000, 0.500, NOT_AB5);
  $setuphold(posedge CLKB &&& re_flagB, negedge AB[5], 1.000, 0.500, NOT_AB5);
  //  $setuphold(posedge CLKB &&& re_flagB, posedge AB[6], 1.000, 0.500, NOT_AB6);
  //  $setuphold(posedge CLKB &&& re_flagB, negedge AB[6], 1.000, 0.500, NOT_AB6);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[0], 1.000, 0.500, NOT_DB0);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[0], 1.000, 0.500, NOT_DB0);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[1], 1.000, 0.500, NOT_DB1);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[1], 1.000, 0.500, NOT_DB1);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[2], 1.000, 0.500, NOT_DB2);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[2], 1.000, 0.500, NOT_DB2);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[3], 1.000, 0.500, NOT_DB3);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[3], 1.000, 0.500, NOT_DB3);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[4], 1.000, 0.500, NOT_DB4);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[4], 1.000, 0.500, NOT_DB4);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[5], 1.000, 0.500, NOT_DB5);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[5], 1.000, 0.500, NOT_DB5);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[6], 1.000, 0.500, NOT_DB6);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[6], 1.000, 0.500, NOT_DB6);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[7], 1.000, 0.500, NOT_DB7);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[7], 1.000, 0.500, NOT_DB7);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[8], 1.000, 0.500, NOT_DB8);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[8], 1.000, 0.500, NOT_DB8);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[9], 1.000, 0.500, NOT_DB9);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[9], 1.000, 0.500, NOT_DB9);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[10], 1.000, 0.500, NOT_DB10);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[10], 1.000, 0.500, NOT_DB10);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[11], 1.000, 0.500, NOT_DB11);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[11], 1.000, 0.500, NOT_DB11);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[12], 1.000, 0.500, NOT_DB12);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[12], 1.000, 0.500, NOT_DB12);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[13], 1.000, 0.500, NOT_DB13);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[13], 1.000, 0.500, NOT_DB13);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[14], 1.000, 0.500, NOT_DB14);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[14], 1.000, 0.500, NOT_DB14);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[15], 1.000, 0.500, NOT_DB15);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[15], 1.000, 0.500, NOT_DB15);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[16], 1.000, 0.500, NOT_DB16);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[16], 1.000, 0.500, NOT_DB16);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[17], 1.000, 0.500, NOT_DB17);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[17], 1.000, 0.500, NOT_DB17);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[18], 1.000, 0.500, NOT_DB18);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[18], 1.000, 0.500, NOT_DB18);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[19], 1.000, 0.500, NOT_DB19);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[19], 1.000, 0.500, NOT_DB19);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[20], 1.000, 0.500, NOT_DB20);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[20], 1.000, 0.500, NOT_DB20);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[21], 1.000, 0.500, NOT_DB21);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[21], 1.000, 0.500, NOT_DB21);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[22], 1.000, 0.500, NOT_DB22);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[22], 1.000, 0.500, NOT_DB22);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[23], 1.000, 0.500, NOT_DB23);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[23], 1.000, 0.500, NOT_DB23);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[24], 1.000, 0.500, NOT_DB24);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[24], 1.000, 0.500, NOT_DB24);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[25], 1.000, 0.500, NOT_DB25);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[25], 1.000, 0.500, NOT_DB25);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[26], 1.000, 0.500, NOT_DB26);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[26], 1.000, 0.500, NOT_DB26);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[27], 1.000, 0.500, NOT_DB27);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[27], 1.000, 0.500, NOT_DB27);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[28], 1.000, 0.500, NOT_DB28);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[28], 1.000, 0.500, NOT_DB28);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[29], 1.000, 0.500, NOT_DB29);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[29], 1.000, 0.500, NOT_DB29);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[30], 1.000, 0.500, NOT_DB30);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[30], 1.000, 0.500, NOT_DB30);
  $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[31], 1.000, 0.500, NOT_DB31);
  $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[31], 1.000, 0.500, NOT_DB31);
  $setup(posedge CLKA, posedge CLKB &&& contB_flag, 3.000, NOT_CONTB);
  $setup(posedge CLKB, posedge CLKA &&& contA_flag, 3.000, NOT_CONTA);
  $hold(posedge CLKA, posedge CLKB &&& cont_flag, 0.001, NOT_CONTB);
  
  $period(posedge CLKA, 3.000, NOT_CLKA_PER);
  $width(posedge CLKA, 1.000, 0, NOT_CLKA_MINH);
  $width(negedge CLKA, 1.000, 0, NOT_CLKA_MINL);
  $period(posedge CLKB, 3.000, NOT_CLKB_PER);
  $width(posedge CLKB, 1.000, 0, NOT_CLKB_MINH);
  $width(negedge CLKB, 1.000, 0, NOT_CLKB_MINL);
  
  (CLKA => QA[0])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[1])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[2])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[3])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[4])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[5])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[6])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[7])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[8])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[9])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[10])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[11])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[12])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[13])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[14])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[15])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[16])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[17])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[18])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[19])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[20])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[21])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[22])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[23])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[24])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[25])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[26])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[27])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[28])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[29])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[30])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKA => QA[31])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[0])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[1])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[2])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[3])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[4])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[5])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[6])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[7])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[8])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[9])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[10])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[11])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[12])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[13])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[14])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[15])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[16])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[17])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[18])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[19])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[20])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[21])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[22])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[23])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[24])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[25])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[26])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[27])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[28])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[29])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[30])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  (CLKB => QB[31])=(1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
  endspecify*/
  
endmodule
`endcelldefine
