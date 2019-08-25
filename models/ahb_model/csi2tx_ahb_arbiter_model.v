/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_ahb_arbiter_model.v
// Author      : SANDEEPA S M
// Version     : v1p2
// Abstract    : This model gives the bus grant signal which is required by 
//               the bus masters based on the priority
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
   `timescale 1 ps / 1 ps
   `define mas_dis_time2 if(show_time==1) $display("Note - AHB:****** Display Time****** :-->  ",$time);

module csi2tx_ahb_arbiter_model
    (
        //INPUT SIGNALS
        input    wire           hclk           ,  //ALL SIGNAL TIMINGS ARE RELATED TO THE RISING EDGE OF HCLK
        input    wire           hresetn        ,  //AHB ACTIVE LOW RESET
        input    wire           hbusreq1       ,  //BUS REQUEST SIGNAL FROM THE SELECTED BUS MASTER
        input    wire           hbusreq2       ,  //BUS REQUEST SIGNAL FROM THE SELECTED BUS MASTER
        input    wire [31:0]    haddr          ,  //32-BIT SYSTEM ADDR BUS
        input    wire           hlock2         ,  //REQUEST FOR LOCKED ACCESS FROM BUS MASTER 2
        input    wire           hready         ,  //HIGH INDICATES THE TRANSFER FINISHED ON THE BUS
        input    wire [2:0]     hburst         ,  //INDICATES 8/16 OR 32BIT BURST SUPPORTED FROM THE SELECTED BUS MASTER
        input    wire [2:0]     hsize          ,  //INDICATES THE SIZE OF THE TRANSFER
        input    wire [1:0]     htrans         ,  //INDICATES THE TYPE OF THE CURRENT TRANSFER
        input    wire [15:0]    delay_val      ,  //DELAY VALUE FROM THE SELECTED BUS MASTER
        input    wire [7:0]     trans_no       ,  //TRANSACTION NUMBER FROM THE SELECTED BUS MASTER
        input    wire [1:0]     error_type     ,  //ERROR TYPE INFORMATION FROM THE SELECTED BUS MASTER

        //OUTPUT SIGNALS
        output   reg            hgrant1        ,  //INDICATES MASTER 1 IS THE HIGHEST PRIORITY MASTER
        output   reg            hgrant2        ,  //INDICATES MASTER 2 IS THE HIGHEST PRIORITY MASTER
        output   reg  [3:0]     hmaster           //MASTER SELECTION SIGNAL TO MULTIPLEXER
    );
 //=================================================================//
 //   Internal register signal declaration
 //=================================================================//

        wire                    hlock1          ;
        wire                    sig_grant_enable;
        reg                     grant_enable    ;
        reg    [31:0]           sig_haddr       ;
        reg    [7:0]            grant2_no       ;
        reg    [1:0]            htrans_d        ;
        reg    [2:0]            hsize_d         ;
        reg    [15:0]           no_of_clks      ;
        reg                     grant_preempt   ;
        reg    [7:0]            t_no            ;
        reg                     ini             ;
        reg    [4:0]            present_state   ;
        reg    [4:0]            next_state      ;
        integer                 i               ;
        integer                 j               ;
        integer                 show_time       ;
 //=================================================================//
 //   Declaration of each state as a parameter
 //=================================================================//

        parameter idle            = 5'b00000;
        parameter master1grant    = 5'b00001;
        parameter master2grant    = 5'b00010;
        parameter master1         = 5'b00011;
        parameter master2         = 5'b00100;
        parameter master2_4_16    = 5'b00101;
        parameter master2_4_16_d  = 5'b00110;
        parameter master2_4_32    = 5'b00111;
        parameter master2_4_32_d  = 5'b01000;
        parameter master2_8_16    = 5'b01001;
        parameter master2_8_16_d  = 5'b01010;
        parameter master2_8_32    = 5'b01011;
        parameter master2_8_32_d  = 5'b01100;
        parameter master2_16_16   = 5'b01101;
        parameter master2_16_16_d = 5'b01110;
        parameter master2_16_32   = 5'b01111;
        parameter master2_16_32_d = 5'b10000;
 //=================================================================//
 //   CONCURRENT ASSIGNMENTS
 //=================================================================//  
  
   assign sig_grant_enable = grant_enable;
   
   initial
     begin
       grant2_no = 8'b0;
       grant_enable = 1'b0;
       no_of_clks = 16'b0;
       ini = 1'b0;
       grant_preempt = 1'b0;
       show_time = 1'b1;
     end
  
 //=================================================================//
 //      STATE MACHINE 
 //=================================================================//

   assign hlock1 = 1'b 0;
   
   always @(present_state or hbusreq1 or hbusreq2 or hlock1 or hlock2 or hburst or htrans_d or hsize_d or haddr or sig_haddr
     or grant_enable or grant_preempt)
     begin
       hgrant1 <= 1'b0;
       hgrant2 <= 1'b0;
       case (present_state)
         idle :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b0;
             if (hbusreq2 == 1'b1 && hlock2 == 1'b0 && grant_preempt == 1'b0 )
               begin
                 grant2_no <= grant2_no + 1;
                 next_state <= master2grant;
               end
             
             else if (hbusreq1 == 1'b1 && hlock1 == 1'b0)
               begin
                 next_state <= master1grant;
               end
             else
               next_state <= idle;
           end
         
         master1grant :
           begin
             hgrant1 <= 1'b1;
             hgrant2 <= 1'b0;
             next_state <= master1;
           end
         
         master1 :
           begin
             hgrant1 <= 1'b1;
             hgrant2 <= 1'b0;
             if (hbusreq2 == 1'b1)
               next_state <= master2grant;
             else if (hbusreq1 == 1'b1 )
               next_state <= master1;
             else
               next_state <= idle;
           end
         
         master2grant :
           begin
             if (grant_enable == 1'b1)
               begin
                 hgrant1 <= 1'b0;
                 hgrant2 <= 1'b1;
                 next_state <= master2;
               end
             else
               next_state <= master2grant;
           end
         
         
         master2 :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b1;
             if (hbusreq2 == 1'b1 && (grant_preempt == 1'b1  ))
               next_state <= idle;
             else if (hbusreq2 == 1'b1)
               next_state <= master2;
             else if ((hburst == 3'b011) && (htrans_d == 2'b10 || htrans_d == 2'b11)&& (hsize_d == 3'b001))
               next_state <= master2_4_16 ;
             
             else if ((hburst == 3'b011) && (htrans_d == 2'b10 || htrans_d == 2'b11)&& (hsize_d == 3'b010))
               next_state <= master2_4_32 ;
             
             else if ((hburst == 3'b101) && (htrans_d == 2'b10 || htrans_d == 2'b11)&& (hsize_d == 3'b001))
               next_state <= master2_8_16 ;
             
             else if ((hburst == 3'b101) && (htrans_d == 2'b10 || htrans_d == 2'b11)&& (hsize_d == 3'b010))
               next_state <= master2_8_32 ;
             
             else if ((hburst == 3'b111) && (htrans_d == 2'b10 || htrans_d == 2'b11)&& (hsize_d == 3'b001))
               next_state <= master2_16_16 ;
             
             else if ((hburst == 3'b111) && (htrans_d == 2'b10 || htrans_d == 2'b11)&& (hsize_d == 3'b010))
               next_state <= master2_16_32 ;
             
             else if(htrans_d == 2'b00)
               next_state <= idle;
           end
         
         master2_4_16 :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b1;
             if (haddr != sig_haddr + 4'h4)
               begin
                 next_state <= master2_4_16;
               end
             else
               next_state <= master2_4_16_d;
           end
         
         master2_4_16_d :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b0;
             next_state <= idle;
           end
         
         master2_4_32 :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b1;
             if (haddr != sig_haddr + 4'h8)
               next_state <= master2_4_32;
             else
               next_state <= master2_4_32_d;
           end
         
         master2_4_32_d :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b0;
             next_state <= idle;
           end
         
         master2_8_16 :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b1;
             if (haddr != sig_haddr + 4'hc)
               next_state <= master2_8_16;
             else
               next_state <= master2_8_16_d;
           end
         
         master2_8_16_d :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b0;
             next_state <= idle;
           end
         
         master2_8_32 :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b1;
             if (haddr != sig_haddr + 8'h18)
               next_state <= master2_8_32;
             else
               next_state <= master2_8_32_d;
           end
         
         master2_8_32_d :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b0;
             next_state <= idle;
           end
         
         master2_16_16 :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b1;
             if (haddr != sig_haddr + 8'h1c)
               next_state <= master2_16_16;
             else
               next_state <= master2_16_16_d;
           end
         
         master2_16_16_d :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b0;
             next_state <= idle;
           end
         
         master2_16_32 :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b1;
             if (haddr != sig_haddr + 8'h38)
               next_state <= master2_16_32;
             else
               next_state <= master2_16_32_d;
           end
         
         master2_16_32_d :
           begin
             hgrant1 <= 1'b0;
             hgrant2 <= 1'b0;
             next_state <= idle;
           end
         
         default :
           begin
             next_state <= master1;
           end
       endcase
    end
 //=================================================================//
 //   Process to latch the address
 //=================================================================//  

   always @(negedge hresetn or  posedge hclk )
     begin
       if (!hresetn)
         sig_haddr <= 32'b0;
       else
         begin
           if (htrans == 2'b10)
             sig_haddr <= haddr;
           else
             sig_haddr <= sig_haddr;
         end
     end
 //=================================================================//
 //   Process for state assignment
 //=================================================================//  

   always @(negedge hresetn or  posedge hclk )
     begin
       if (hresetn == 1'b0)
         present_state <= idle;
       else
         present_state <= next_state;
     end
 //=================================================================//
 //   Process for calculating the delay
 //=================================================================//  

   always @(delay_val or trans_no or grant2_no or error_type[0])
     begin
       if (trans_no == 8'hff || t_no == 8'hff)
         begin
           if (ini == 1'b0)
             begin
               t_no = trans_no;
               ini = 1'b1;
             end
           grant_enable = 1'b0;
           `mas_dis_time2
           for (i=0;i<delay_val;i=i+1)
             @(posedge hclk);
           grant_enable = 1'b1;
           `mas_dis_time2
         end
       else if (trans_no == grant2_no )
         begin
           if (error_type[0] == 1'b1)
             begin
               if (delay_val == 16'hffff)
                 begin
                   grant_enable = 1'b0;
                   @(posedge hclk);
                 end
               else
                 begin
                   grant_enable = 1'b0;
                   for (i=0;i<delay_val;i=i+1)
                     @(posedge hclk);
                   grant_enable = 1'b1;
                 end
             end
         end
       else
         grant_enable = 1'b1;
     end
  
  // calculate for preempt
   always @(error_type[1] or delay_val or no_of_clks or trans_no or grant2_no)
     begin
       if (trans_no == grant2_no )
         begin
           if (error_type[1] == 1'b1)
             begin
               if (no_of_clks == 16'h1)
                 begin
                   grant_preempt = 1'b1;
                   for (j=0;j<delay_val;j=j+1)
                     @(posedge hclk);
                   grant_preempt = 1'b0;
                 end
             end
         end
       else
         grant_preempt = 1'b0;
       
     end
   
   // calculating the no of clocks the grant is given for core master
   always @(negedge hresetn or  posedge hclk )
     begin
       if (present_state == 5'b00010 || present_state == 5'b00100)
         no_of_clks <= no_of_clks +1;
       else if (present_state == 5'b00000)
         no_of_clks <= 16'b0;
     end
   
   always @(negedge hresetn or  posedge hclk )
     begin
       if (!hresetn)
         hmaster <= 4'b0000;
       
       else
         if (hgrant1 == 1'b1 && hgrant2 == 1'b0 && hready == 1'b1 )
           hmaster <= 4'b0001;
         else if (hgrant2 == 1'b1 && hgrant1 == 1'b0 && hready == 1'b1)
           hmaster <= 4'b0010;
         else if (hready == 1'b0)
           hmaster <= hmaster;
         else
           hmaster <= 4'b0;
     end
   
   always  @(grant_enable)
     begin
       if (grant_enable == 1'b0 && hbusreq2 == 1'b1)
         begin
           `mas_dis_time2
           $display("NOTE - AHB ARBITER:  GRANT IS DELAYED BY  %h h CLOCK CYCLES\n", delay_val);
           
         end
       else  if  (grant_enable == 1'b1 && hbusreq2 == 1'b1)
         begin
           `mas_dis_time2
           $display("NOTE - AHB ARBITER:  AHB BUS IS GRANTED TO THE CORE MASTER\n");
           
         end
     end
   
   always @(grant_preempt)
     begin
       if (grant_preempt == 1'b1 && hbusreq2 == 1'b1)
         begin
           `mas_dis_time2
           $display("NOTE - AHB ARBITER:  GRANT IS PRE-EMPTED TILL %h h CLOCK CYCLES\n",delay_val );
           
         end
       else if (grant_preempt == 1'b0 && hbusreq2 == 1'b1)
         begin
           `mas_dis_time2
           $display("NOTE - AHB ARBITER:  BUS GRANTED AFTER PRE-EMPT PERIOD\n");
           
         end
     end
   
   always @(posedge hclk or negedge hresetn)
     begin
       if(!hresetn)
         htrans_d <= 2'b00;
       else if(hready && hgrant2)
         htrans_d <= htrans;
     end
   
   always @(posedge hclk or negedge hresetn)
     begin
       if(!hresetn)
         hsize_d <= 3'b000;
       else if(hready && hgrant2)
         hsize_d <= hsize;
     end

endmodule
