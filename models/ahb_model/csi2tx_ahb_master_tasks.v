/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_ahb_master_tasks.v
// Author      : SANDEEPA
// Version     : v1p2
// Abstract    : This module has the tasks which is used by the master model
//              
//                
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/

  /*---------------------------------------------------------------------------
    TASK FOR AHB WRITE OPERATION
  ---------------------------------------------------------------------------*/
  task mem_write;
    input [3:0]  byte_en;
    input [31:0] sig_haddr;
    input [31:0] wr_data;
    input [2:0]  sig_hsize;
    begin
      wr_pend   = 1'b0;
      @(posedge hclk);
      hbusreq1 <= 1'b1;
      wait(hgrant1);
      wait(hready);
      @(posedge hclk);
      if(sig_hsize == 3'b000) begin                 // 8-bit word size transfer
        if(byte_en == 4'b1111) begin
          for(k = 0; k < 4; k = k + 1) begin
            wait(hready);
            haddr1 <= sig_haddr;
           if(k == 0)
             htrans1 <= 2'b10;         // 2'b10  - non-seq transfer
           else
             htrans1 <= 2'b11;           // 2'b11  - sequential transfer
             hburst1 <= 3'b000;          // 3'b000 - single transfer
             hwrite1 <= 1'b1;
            hsize1  <= sig_hsize;       // 8-bit word size transfer
            @(posedge hclk);
            if(k == 0)
              hwdata1 <= {24'h0,wr_data[7:0]};
            if(k == 1)
              hwdata1 <= {16'h0,wr_data[15:8],8'h0};
            if(k == 2)
              hwdata1 <= {8'h0,wr_data[23:16],16'h0};
            if(k == 3)
              hwdata1 <= {wr_data[31:24],24'h0};
            if(!hready) begin
              htrans1 <= 2'b00;   // 2'b00  - idle transfer
              hwrite1 <= 1'b0;
            end else begin
              haddr1  <= 32'h0;
              htrans1 <= 2'b00;   // 2'b00  - idle transfer
              hwrite1 <= 1'b0;
            end
          end
        end else if(byte_en == 4'b0011) begin
          for(k = 0; k < 2; k = k + 1) begin
            wait(hready);
            haddr1 <= sig_haddr;
            if(k == 0)
              htrans1 <= 2'b10;      // 2'b10  - non-seq transfer
            else
              htrans1 <= 2'b11;        // 2'b11  - sequential transfer
              hburst1 <= 3'b000;       // 3'b000 - single transfer
              hwrite1 <= 1'b1;
              hsize1  <= sig_hsize;    // 8-bit word size transfer
            @(posedge hclk);
            if(k == 0)
              hwdata1 <= {24'h0,wr_data[7:0]};
            if(k == 1)
              hwdata1 <= {16'h0,wr_data[15:8],8'h0};
            if(!hready) begin
              htrans1 <= 2'b00;    // 2'b00  - idle transfer
              hwrite1 <= 1'b0;
            end else begin
              haddr1  <= 32'h0;
              htrans1 <= 2'b00;    // 2'b00  - idle transfer
              hwrite1 <= 1'b0;
            end
          end
        end else if(byte_en == 4'b0001) begin
          wait(hready);
          haddr1  <= sig_haddr;
          htrans1 <= 2'b10;            // 2'b00  - non-sequential transfer
          hburst1 <= 3'b000;           // 3'b000  - single transfer
          hwrite1 <= 1'b1;
          hsize1  <= sig_hsize;        // 8-bit word size transfer
          @(posedge hclk);
          hwdata1 <= wr_data;
          if(!hready) begin
            htrans1 <= 2'b00;        // 2'b00  - idle transfer
            hwrite1 <= 1'b0;
          end else begin
            haddr1  <= 32'h0;
            htrans1 <= 2'b00;        // 2'b00  - idle transfer
            hwrite1 <= 1'b0;
          end
        end
      end else if(sig_hsize == 3'b001) begin         // 8-bit word size transfer
        if(byte_en == 4'b1111) begin
          for(k = 0; k < 2; k = k + 1) begin
            wait(hready);
            haddr1 <= sig_haddr;
            if(k == 0)
              htrans1 <= 2'b10;       // 2'b10  - non-seq transfer
            else
              htrans1 <= 2'b11;       // 2'b00   - seq transfer
              hburst1 <= 3'b000;        // 3'b000  - single transfer
              hwrite1 <= 1'b1;
              hsize1 <= sig_hsize;      // 16-bit word size transfer
              @(posedge hclk);
              if(k == 0)
                hwdata1 <= {16'h0,wr_data[15:0]};
              if(k == 1)
                hwdata1 <= {wr_data[31:16],16'h0};
              if(!hready) begin
                htrans1 <= 2'b00;     // 2'b00  - idle transfer
                hwrite1 <= 1'b0;
              end else begin
                haddr1  <= 32'h0;
                htrans1 <= 2'b00;     // 2'b00  - idle transfer
                hwrite1 <= 1'b0;
            end
          end
        end else if(byte_en == 4'b0011) begin
          wait(hready);
          haddr1  <= sig_haddr;
          htrans1 <= 2'b10;             // 2'b10  - non-seq transfer
          hburst1 <= 3'b000;            // 3'b000  - single transfer
          hwrite1 <= 1'b1;
          hsize1  <= sig_hsize;         // 16-bit word size transfer
          @(posedge hclk);
          hwdata1 <= {16'h0,wr_data[15:0]};
          if(!hready) begin
            htrans1 <= 2'b00;      // 2'b00  - idle transfer
            hwrite1 <= 1'b0;
          end else begin
            haddr1  <= 32'h0;
            htrans1 <= 2'b00;      // 2'b00  - idle transfer
            hwrite1 <= 1'b0;
          end
        end
      end else if(sig_hsize == 3'b010) begin   // 3'b010 - 32-bit word size transfer
        wait(hready);
        haddr1  <= sig_haddr;
        htrans1 <= 2'b10;         // 2'b10   - non-seq transfer
        hburst1 <= 3'b000;        // 3'b000  - single transfer
        hwrite1 <= 1'b1;
        hsize1  <= sig_hsize;     // 32-bit word size transfer
        @(posedge hclk);
        hwdata1 <= wr_data;
        if(!hready) begin
          htrans1 <= 2'b00;      // 2'b00  - idle transfer
          hwrite1 <= 1'b0;
        end else begin
          htrans1 <= 2'b00;      // 2'b00  - idle transfer
          hwrite1 <= 1'b0;
        end
      end
      @(posedge hclk);
      wr_pend   = 1'b1;
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK FOR AHB READ OPERATION
  ---------------------------------------------------------------------------*/
  task mem_read;
    input [3:0]byte_en;
    input [31:0] sig_haddr;
    input [2:0] sig_hsize;
    begin
      rd_pend   = 1'b0;
      @(posedge hclk);
      wait(hready);
      @(posedge hclk);
      if(sig_hsize == 3'b000) begin
        if(byte_en == 4'b1111) begin
          rec_data <= 32'h0;
            for(k = 0; k < 4; k = k + 1) begin
              haddr1  <= sig_haddr;
              htrans1 <= 2'b10;
              hburst1 <= 3'b000;
              hwrite1 <= 1'b0;
              hsize1  <= sig_hsize;
              sig_haddr = sig_haddr + 1;
              if(k == 0) begin
                htrans1 <= 2'b11;
                wait(hready);
                #1;
                rec_data[7:0]   = hrdata[7:0];
              end
              if(k == 1) begin
                htrans1 <= 2'b11;
                wait(hready);
                #1;
                rec_data[15:8]  = hrdata[15:8];
              end
              if(k == 2) begin
                htrans1 <= 2'b11;
                wait(hready);
                #1;
                rec_data[23:16] = hrdata[23:16];
              end
              if(k == 3) begin
                @(posedge hclk);
                htrans1 <= 2'b00;
                haddr1  <= 32'h00;
                hburst1 <= 3'b000;
                hsize1  <= 2'b00;
                wait(hready);
                #1;
                rec_data[31:24] = hrdata[31:24];
              end
            end
        end else if(byte_en == 4'b0011) begin
          for(k = 0; k < 2; k = k + 1) begin
            haddr1  <= sig_haddr;
            htrans1 <= 2'b10;
            hburst1 <= 3'b000;
            hwrite1 <= 1'b0;
            hsize1  <= sig_hsize;
            sig_haddr = sig_haddr + 1;
            if(k == 0) begin
              htrans1 <= 2'b11;
              wait(hready);
              #1;
              rec_data[7:0]   = hrdata[7:0];
            end
            if(k == 1) begin
              @(posedge hclk);
              htrans1 <= 2'b00;
              haddr1  <= 32'h00;
              hburst1 <= 3'b000;
              hsize1 <= 2'b00;
              wait(hready);
              #1;
              rec_data[15:8] = hrdata[15:8];
            end
          end
        end else if(byte_en == 4'b0001) begin
          haddr1  <= sig_haddr;
          htrans1 <= 2'b10;
          hburst1 <= 3'b000;
          hwrite1 <= 1'b0;
          hsize1  <= sig_hsize;
          @(posedge hclk);
          htrans1 <= 2'b00;
          haddr1  <= 32'h00;
          hburst1 <= 3'b000;
          hsize1  <= 2'b00;
          wait(hready);
          #1;
          rec_data = hrdata;
        end
      end else if(sig_hsize == 3'b001) begin
        if(byte_en == 4'b1111) begin
          for(k = 0; k < 2; k = k + 1) begin
            haddr1  <= sig_haddr;
            htrans1 <= 2'b10;
            hburst1 <= 3'b000;
            hwrite1 <= 1'b0;
            hsize1 <= sig_hsize;
            sig_haddr = sig_haddr + 2;
            if(k == 0) begin
              htrans1 <= 2'b10;
              wait(hready);
              #1;
              rec_data[15:0] = hrdata[15:0];
            end
            if(k == 1) begin
              @(posedge hclk);
              htrans1 <= 2'b11;
              haddr1  <= 32'h00;
              hburst1 <= 3'b000;
              hsize1 <= 2'b00;
              wait(hready);
              #1;
              rec_data[31:16] = hrdata[31:16];
            end
          end
        end else if(byte_en == 4'b0011) begin
          haddr1  <= sig_haddr;
          htrans1 <= 2'b10;
          hburst1 <= 3'b000;
          hwrite1 <= 1'b0;
          hsize1 <= sig_hsize;
          @(posedge hclk);
          htrans1 <= 2'b00;
          hburst1 <= 3'b000;
          hsize1 <= 2'b00;
          wait(hready);
          #1;
          rec_data[15:0] = hrdata[15:0];
        end
      end else if(sig_hsize == 3'b010) begin
        haddr1  <= sig_haddr;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b0;
        hsize1  <= sig_hsize;
        @(posedge hclk);
        htrans1 <= 2'b00;
        hburst1 <= 3'b000;
        hsize1  <= 2'b00;
        #1;
        wait(hready);
        #1;
        rec_data = hrdata;
      end
      @(posedge hclk);
      hbusreq1 <= 1'b0;
      rd_pend  <= 1'b1;
      test_dbg =1'b0;
    end
  endtask


  /*---------------------------------------------------------------------------
    UNIT INTERVAL 
  ---------------------------------------------------------------------------*/
  task ui_value;
    input real UI;
    begin
      ui_ns = UI;
    end
  endtask

  /*---------------------------------------------------------------------------
    AHB INITIALIZATION
  ---------------------------------------------------------------------------*/

   task initialize_csi;
     begin
       wait(test_env.u_csi2tx_clk_gen_inst.clk_generated == 1'b1);
       command = "initialize_csi";
       $display($time,"\tAHB MASTER : NOTE ====> CSI INITIALIZATION COMMAND ISSUED \n");
       if(reg_init_en)
         wait(!reg_init_en);
          init_enable = 1'b1;
           begin
              pwr_on_rst_mipi;
              #10000;
              ui_value(ui);
              lane_prog_reg;
              wr_trim_reg_0(32'h0e80341d);
              wr_trim_reg_1({{24'h6db538,1'b0,cntb,cnta[5:0]}});
              wr_trim_reg_2(32'h10000000);
              wr_trim_reg_3(32'h02404000);
              wr_dphy_dfe_dln_reg_0({dln_hs_trial,dln_hs_exit,dln_hs_prepare,dln_hs_zero});
              wr_dphy_dfe_dln_reg_1({8'b00000000,dln_lpx,dln_rx_sync_cnt,dln_rx_cnt});
              wr_dphy_dfe_cln_reg_0({cln_trial,cln_exit,cln_prepare,cln_zero});
              wr_dphy_dfe_cln_reg_1({8'b00000000,cln_post,cln_pre,dln_lpx});
              wr_dphy_ln_pol_swap_reg(32'h00000000);
              wr_pll_cnt_reg(32'h00000000);
              wr_vc0_comp_pred_reg_1(32'h00000000);
              wr_vc0_cmp_pred_reg_2(32'h00000000);
              wr_vc1_cmp_pred_reg_1(32'h00000000);
              wr_vc1_cmp_pred_reg_2(32'h00000000);
              wr_vc2_cmp_pred_reg_1(32'h00000000);
              wr_vc2_cmp_pred_reg_2(32'h00000000);
              wr_vc3_cmp_pred_reg_1(32'h00000000);
              wr_vc3_cmp_pred_reg_2(32'h00000000);
           end
          //pwr_on_rst_mipi;
          init_enable              = 1'b0;
     end
   endtask

  /*---------------------------------------------------------------------------
    POWER ON RESET MIPI
  ---------------------------------------------------------------------------*/
  task pwr_on_rst_mipi;
    begin
		  command = "pwr_on_rst_mipi";
		  @(posedge hclk);
                 // ahb_cfg_comp = 1'b1;
		  wait(hready);
		  processor_rst_n = 1'b0;
                  trim_static_chk  = 1'b1;
		  @(posedge hclk);
		  @(posedge hclk);
	  	  @(posedge hclk);
		  @(posedge hclk);
		  @(posedge hclk);
		  processor_rst_n = 1'b1;
                  lane_rst  = 1'b1;
    end
  endtask
 



  task processor_reset;
   begin
    wait(!init_enable);
    ahb_cfg_comp = 1'b1;
    wait(test_env.u_csi2tx_pkt_interface_bfm_inst.sync_en == 1'b1); 
    pwr_on_rst_mipi;
   end
  endtask

 
  /*---------------------------------------------------------------------------
    FREQUENCY VALUE
  ---------------------------------------------------------------------------*/
  task freq_value;
    input [11:0] frequency;
    begin
      clk_csi_freq = frequency;
    end
  endtask

  /*---------------------------------------------------------------------------
    DEASSERT TRIM STATIC CHKECKING
  ---------------------------------------------------------------------------*/
  task deassert_trim_static_chk;
    begin
      trim_static_chk  = 1'b0;
    end
  endtask

  /*---------------------------------------------------------------------------
    TRIM REGISTER TOGGLE CHKECKING
  ---------------------------------------------------------------------------*/
  task trim_reg_toggle_chk;
    begin
      trim_reg_toggle = 1'b1;
	    @(posedge hclk);
      trim_reg_toggle = 1'b0;
    end
  endtask

  /*---------------------------------------------------------------------------
    DELAY COMMAND TASK
  ---------------------------------------------------------------------------*/
  task delay;
    input [31:0]delay_count;
    begin
      for(int_cou_pointer2 = 0; int_cou_pointer2 < delay_count;
          int_cou_pointer2 = int_cou_pointer2+1) begin
        @(posedge hclk);
      end
    end
  endtask

  /*----------------------------------------------------------------------------
     TASK FOR LANE CONFIGURATION THROUGH AHB COMMAND 
  ----------------------------------------------------------------------------*/
  task force_lane_index;
    input [2:0] temp_lane_index;
     begin
      lan_index     =   temp_lane_index;
      lane_index_en =   1'b1;
     end
   endtask

  /*---------------------------------------------------------------------------
    TASK TO INDICATE THE END OF MASTER COMMAND FILE
  ---------------------------------------------------------------------------*/
  task end_cmd;
    begin
     command = "end_cmd";
     ahb_cfg_comp = 1'b1;
     if(pre_init_test == 1'b0)
      begin
      wait((wr_pend || rd_pend) && !init_enable );
      end
      init_enable = 1'b0;
      wait(test_env.csi_end_of_file == 1'b1 && test_env.rxer_end == 1'b1 && test_env.end_monitor == 1'b1 );
      end_file = 1'b1;
      wait(end_ahb);
      $display($time,"\tAHB MASTER : NOTE ---> END OF FILE REACHED IN MASTER COMMAND\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO TRIM REGISTER 0
  ---------------------------------------------------------------------------*/
  task wr_trim_reg_0 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_trim_reg_0";
      sig_haddr       = 32'h00000000;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO TRIM REGISTER 0 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO TRIM REGISTER 1
  ---------------------------------------------------------------------------*/
  task wr_trim_reg_1 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_trim_reg_1";
      sig_haddr       = 32'h00000004;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO TRIM REGISTER 1 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO TRIM REGISTER 2
  ---------------------------------------------------------------------------*/
  task wr_trim_reg_2 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_trim_reg_2";
      sig_haddr       = 32'h00000008;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO TRIM REGISTER 2 COMPLETED SUCCESSFULLY\n");
    end
  endtask
  
  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO TRIM REGISTER 3
  ---------------------------------------------------------------------------*/
  task wr_trim_reg_3 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_trim_reg_3";
      sig_haddr       = 32'h0000000C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO TRIM REGISTER 3 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO DPHY DFE DATA LANE REGISTER 0
  ---------------------------------------------------------------------------*/
  task wr_dphy_dfe_dln_reg_0 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_dphy_dfe_dln_reg_0";
      sig_haddr       = 32'h00000020;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO DPHY DFE DATA LANE REGISTER 0 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO DPHY DFE DATA LANE REGISTER 1
  ---------------------------------------------------------------------------*/
  task wr_dphy_dfe_dln_reg_1 ;
    input [31:0] wr_data; 
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_dphy_dfe_dln_reg_1";
      sig_haddr       = 32'h00000024;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO DPHY DFE DATA LANE REGISTER 1 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO DPHY DFE CLOCK LANE REGISTER 0
  ---------------------------------------------------------------------------*/
  task wr_dphy_dfe_cln_reg_0 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_dphy_dfe_cln_reg_0";
      sig_haddr       = 32'h00000028;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO  DPHY DFE CLOCK LANE REGISTER 0 COMPLETED SUCCESSFULLY\n");
    end
  endtask
  
  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO DPHY DFE CLOCK LANE REGISTER 1
  ---------------------------------------------------------------------------*/
  task wr_dphy_dfe_cln_reg_1 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_dphy_dfe_cln_reg_1";
      sig_haddr       = 32'h0000002C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO DPHY DFE CLOCK LANE REGISTER 1 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO DPHY LANE POLARITY SWAP REGISTER
  ---------------------------------------------------------------------------*/ 
  task wr_dphy_ln_pol_swap_reg ;
    input [31:0] wr_data; 
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_dphy_ln_pol_swap_reg";
      sig_haddr       = 32'h00000030;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO  DPHY LANE POLARITY SWAP REGISTER COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO FIFO STATUS REGISTER
  ---------------------------------------------------------------------------*/
  task wr_fifo_status_reg;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_fifo_status_reg";
      sig_haddr       = 32'h00000038;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO FIFO STATUS REGISTER COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO PROGRAM LANE COUNT
  ---------------------------------------------------------------------------*/
  task  lane_prog_reg;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "lane_prog_reg";
      wait(config_comp ==1'b1);
      lane_rst        = 1'b0; 
      sig_haddr       = 32'h0000003C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,{29'h0,lane},sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO LANE PROGRAM REGISTER VALUE %h COMPLETED SUCCESSFULLY\n",lane+1);
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 1
  ---------------------------------------------------------------------------*/
  task wr_vc0_comp_pred_reg_1 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_vc0_comp_pred_reg_1";
      sig_haddr       = 32'h0000004C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 1 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 2
  ---------------------------------------------------------------------------*/ 
  task wr_vc0_cmp_pred_reg_2 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_vc0_cmp_pred_reg_2";
      sig_haddr       = 32'h00000050;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 2 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 1
  ---------------------------------------------------------------------------*/
  task wr_vc1_cmp_pred_reg_1 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_vc1_cmp_pred_reg_1";
      sig_haddr       = 32'h00000054;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 1 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 2
  ---------------------------------------------------------------------------*/ 
  task wr_vc1_cmp_pred_reg_2 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_vc1_cmp_pred_reg_2";
      sig_haddr       = 32'h00000058;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 2 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 1
  ---------------------------------------------------------------------------*/ 
  task wr_vc2_cmp_pred_reg_1 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_vc2_cmp_pred_reg_1";
      sig_haddr       = 32'h0000005C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 1 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 2
  ---------------------------------------------------------------------------*/
  task wr_vc2_cmp_pred_reg_2 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_vc2_cmp_pred_reg_2";
      sig_haddr       = 32'h0000060;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 2 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION REGISTER 1
  ---------------------------------------------------------------------------*/ 
  task wr_vc3_cmp_pred_reg_1 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_vc3_cmp_pred_reg_1";
      sig_haddr       = 32'h00000064;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION  REGISTER 1 COMPLETED SUCCESSFULLY\n");
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION REGISTER 2
  ---------------------------------------------------------------------------*/
  task  wr_vc3_cmp_pred_reg_2 ;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_vc3_cmp_pred_reg_2";
      sig_haddr       = 32'h00000068;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION  REGISTER 2 COMPLETED SUCCESSFULLY\n");
    end
  endtask
   
  /*---------------------------------------------------------------------------
    TASK TO WRITE INTO PLL COUNT REGISTER
  ---------------------------------------------------------------------------*/
  task  wr_pll_cnt_reg;
    input [31:0] wr_data;
    reg   [2:0]  sig_hsize;
    reg   [31:0] sig_haddr;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "wr_pll_cnt_reg";
      sig_haddr       = 32'h0000006C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_write(sig_byte_en1,sig_haddr,wr_data,sig_hsize);
      $display($time,"\tAHB MASTER : WRITE TO PLL COUNT REGISTER COMPLETED SUCCESSFULLY\n");
    end
  endtask
   
  /*---------------------------------------------------------------------------
    TASK TO READ LANE PROGRAM REGISTER
  ---------------------------------------------------------------------------*/
  task rd_lane_prog_reg;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_trim_reg_0";
      sig_haddr       = 32'h000003c;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      #1;
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED LANE PROGRAM REGISTER VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED LANE PROGRAM REGISTER VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED LANE PROGRAM REGISTER VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED LANE PROGRAM REGISTER VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO TRIM REGISTER 0
  ---------------------------------------------------------------------------*/
  task rd_trim_reg_0;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_trim_reg_0";
      sig_haddr       = 32'h0000000;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      #1;
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED TRIM REGISTER 0 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED TRIM REGISTER 0 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED TRIM REGISTER 0 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED TRIM REGISTER 0 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO TRIM REGISTER 1
  ---------------------------------------------------------------------------*/
  task rd_trim_reg_1;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      
      command         = "rd_trim_reg_1";
      sig_haddr       = 32'h0000004;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED TRIM REGISTER 1 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED TRIM REGISTER 1 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED TRIM REGISTER 1 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED TRIM REGISTER 1 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO TRIM REGISTER 2
  ---------------------------------------------------------------------------*/
  task rd_trim_reg_2;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_trim_reg_2";
      sig_haddr       = 32'h0000008;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data = rec_data;
      if(received_data== expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED TRIM REGISTER 2 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED TRIM REGISTER 2 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED TRIM REGISTER 2 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED TRIM REGISTER 2 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO TRIM REGISTER 3
  ---------------------------------------------------------------------------*/
  task rd_trim_reg_3;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_trim_reg_3";
      sig_haddr       = 32'h000000C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data = rec_data;
      if(received_data== expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED TRIM REGISTER 3 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED TRIM REGISTER 3 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED TRIM REGISTER 3 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED TRIM REGISTER 3 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO DPHY DFE DATA LANE REGISTER 0
  ---------------------------------------------------------------------------*/
  task rd_dphy_dfe_dln_reg_0;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_dphy_dfe_dln_reg_0";
      sig_haddr       = 32'h0000020;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED DPHY DFE DATA LANE REGISTER 0 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED DPHY DFE DATA LANE REGISTER 0 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED DPHY DFE DATA LANE REGISTER 0 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED DPHY DFE DATA LANE REGISTER 0 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO DPHY DFE DATA LANE REGISTER 1
  ---------------------------------------------------------------------------*/
  task rd_dphy_dfe_dln_reg_1;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_dphy_dfe_dln_reg_1";
      sig_haddr       = 32'h0000024;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED DPHY DFE DATA LANE REGISTER 1 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED DPHY DFE DATA LANE REGISTER 1 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED DPHY DFE DATA LANE REGISTER 1 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED DPHY DFE DATA LANE REGISTER 1 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO DPHY DFE CLOCK LANE REGISTER 0
  ---------------------------------------------------------------------------*/
  task rd_dphy_dfe_cln_reg_0;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_dphy_dfe_cln_reg_0";
      sig_haddr       = 32'h0000028;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED DPHY DFE CLOCK LANE REGISTER 0 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED DPHY DFE CLOCK LANE REGISTER 0 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED DPHY DFE CLOCK LANE REGISTER 0 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED DPHY DFE CLOCK LANE REGISTER 0 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO DPHY DFE CLOCK LANE REGISTER 1
  ---------------------------------------------------------------------------*/ 
  task rd_dphy_dfe_cln_reg_1;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_dphy_dfe_cln_reg_1";
      sig_haddr       = 32'h000002C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED DPHY DFE CLOCK LANE REGISTER 1 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED DPHY DFE CLOCK LANE REGISTER 1 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED DPHY DFE CLOCK LANE REGISTER 1 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED DPHY DFE CLOCK LANE REGISTER 1 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO DPHY LANE POLARITY SWAP REGISTER
  ---------------------------------------------------------------------------*/
  task rd_dphy_ln_pol_swap_reg;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_dphy_ln_pol_swap_reg";
      sig_haddr       = 32'h0000030;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED DPHY LANE POLARITY SWAP REGISTER VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED DPHY LANE POLARITY SWAP REGISTER  VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED DPHY LANE POLARITY SWAP REGISTER  VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED DPHY LANE POLARITY SWAP REGISTER  VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO FIFO STATUS REGISTER
  ---------------------------------------------------------------------------*/
  task rd_fifo_status_reg ;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
        command = "rd_fifo_status_reg";
        sig_haddr       = 32'h0000038;
        sig_hsize       = sel_hsize;
        sig_byte_en1    = 4'b1111;
        mem_read(sig_byte_en1,sig_haddr,sig_hsize);
        received_data   = rec_data;
      if(received_data == expected_data)
        begin
          $display($time,"\tAHB MASTER : EXPECTED FIFO STATUS REGISTER VALUE %h IS RECEIVED\n",received_data);
        end
      else
        begin
          err_status = 1'b1;
          $display($time,"\tAHB MASTER : ERROR --> EXPECTED FIFO STATUS REGISTER  VALUE NOT RECEIVED");
          $display($time,"\tAHB MASTER : EXPECTED FIFO STATUS REGISTER  VALUE -- %h ",expected_data);
          $display($time,"\tAHB MASTER : RECEIVED FIFO STATUS REGISTER  VALUE -- %h \n",received_data);
        end
      if(expected_data[5]) begin
        if(rec_data[5] == 1'b1) begin
          $display($time,"\tAHB MASTER :DATA ID ERROR RECEIVED\n");
          wr_fifo_status_reg(32'h00000020);
          $display($time,"\tAHB MASTER : WRITE TO STATUS REGISTER COMPLETED SUCCESSFULLY\n");
        end else begin
          err_status = 1'b1;
          $display($time,"\tAHB MASTER : ERROR --> EXPECTED DATA ID ERROR NOT RECEIVED");
        end
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION 
    REGISTER 1
  ---------------------------------------------------------------------------*/
  task rd_vc0_comp_pred_reg_1  ;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_vc0_comp_pred_reg_1";
      sig_haddr       = 32'h000004C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data   = rec_data;
      if(received_data== expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 1 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 1 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 1 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 1 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 2
  ---------------------------------------------------------------------------*/
  task rd_vc0_comp_pred_reg_2  ;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_vc0_comp_pred_reg_2";
      sig_haddr       = 32'h0000050;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 2 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 2 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 2 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED VIRTUAL CHANNEL 0 COMPRESSION/PREDICTION REGISTER 2 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION 
    REGISTER 1
  ---------------------------------------------------------------------------*/
  task rd_vc1_comp_pred_reg_1  ;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_vc1_comp_pred_reg_1";
      sig_haddr       = 32'h0000054;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 1 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 1 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 1 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 1 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION
    REGISTER 2
  ---------------------------------------------------------------------------*/
  task rd_vc1_comp_pred_reg_2  ;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_vc1_comp_pred_reg_2";
      sig_haddr       = 32'h0000058;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 2 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 2 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 2 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED VIRTUAL CHANNEL 1 COMPRESSION/PREDICTION REGISTER 2 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION 
    REGISTER 1
  ---------------------------------------------------------------------------*/ 
  task rd_vc2_comp_pred_reg_1  ;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_vc2_comp_pred_reg_1";
      sig_haddr       = 32'h000005C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 1 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 1 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 1 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 1 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION 
    REGISTER 2
  ---------------------------------------------------------------------------*/ 
  task rd_vc2_comp_pred_reg_2  ;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_vc2_comp_pred_reg_2";
      sig_haddr       = 32'h0000060;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 2 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 2 VALUE NOT RECEIVED");
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 2 VALUE -- %h ",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED VIRTUAL CHANNEL 2 COMPRESSION/PREDICTION REGISTER 2 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION 
    REGISTER 1
  ---------------------------------------------------------------------------*/
  task rd_vc3_comp_pred_reg_1  ;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_vc3_comp_pred_reg_1";
      sig_haddr       = 32'h0000064;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data   = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION REGISTER 1 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION REGISTER 1 VALUE NOT RECEIVED\n");
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION REGISTER 1 VALUE -- %h \n",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION REGISTER 1 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION 
    REGISTER 2
  ---------------------------------------------------------------------------*/
  task rd_vc3_comp_pred_reg_2  ;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_vc3_comp_pred_reg_2";
      sig_haddr       = 32'h0000068;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data  = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION REGISTER 2 VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION REGISTER 2 VALUE NOT RECEIVED\n");
        $display($time,"\tAHB MASTER : EXPECTED VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION REGISTER 2 VALUE -- %h \n",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED VIRTUAL CHANNEL 3 COMPRESSION/PREDICTION REGISTER 2 VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO RECEIVE DATA INTO PLL COUNT REGISTER
  ---------------------------------------------------------------------------*/
  task rd_pll_cnt_reg;
    input [31:0] expected_data;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      command         = "rd_pll_cnt_reg";
      sig_haddr       = 32'h000006C;
      sig_hsize       = sel_hsize;
      sig_byte_en1    = 4'b1111;
      mem_read(sig_byte_en1,sig_haddr,sig_hsize);
      received_data  = rec_data;
      if(received_data == expected_data) begin
        $display($time,"\tAHB MASTER : EXPECTED PLL COUNT REGISTER VALUE %h IS RECEIVED\n",received_data);
      end else begin
        err_status = 1'b1;
        $display($time,"\tAHB MASTER : ERROR --> EXPECTED PLL COUNT REGISTER VALUE NOT RECEIVED\n");
        $display($time,"\tAHB MASTER : EXPECTED PLL COUNT REGISTER VALUE -- %h \n",expected_data);
        $display($time,"\tAHB MASTER : RECEIVED PLL COUNT REGISTER VALUE -- %h \n",received_data);
      end
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO 
  ---------------------------------------------------------------------------*/
  task cont_wr_rd1;
    begin
      wait(!init_enable);
      reg_init_en = 1'b1;
      command   = "cont_wr_rd1";
      @(posedge hclk);
      hbusreq1 <= 1'b1;
      wait(hgrant1);
      wait(hready);
      @(posedge hclk);
      haddr1 <= 32'h0000100;
      htrans1 <= 2'b10;
      hburst1 <= 3'b000;
      hwrite1 <= 1'b1;
      hsize1  <= 3'h2;
      @(posedge hclk);
      hwdata1 = 32'h01;
      haddr1 <= 32'h0000108;
      htrans1 <= 2'b10;
      hburst1 <= 3'b000;
      hwrite1 <= 1'b0;
      hsize1  <= 3'h2;
      wait(hready);
      rec_data = hrdata;
      @(posedge hclk);
      haddr1 <= 32'h0000100;
      htrans1 <= 2'b01;
      hburst1 <= 3'b000;
      hwrite1 <= 1'b0;
      hsize1  <= 3'h2;
      wait(hready);
      rec_data = hrdata;
      @(posedge hclk);
      htrans1 <= 2'b0;
      hburst1 <= 3'b000;
      hwrite1 <= 1'b0;
      hsize1  <= 3'h0;
      reg_init_en = 1'b0;
    end
  endtask

  /*---------------------------------------------------------------------------
    TASK TO hselect deassert 
  ---------------------------------------------------------------------------*/
  task hsel_deassert;
    reg   [31:0] sig_haddr;
    reg   [2:0]  sig_hsize;
    reg   [3:0]  sig_byte_en1;
    begin
      sig_byte_en1    = 4'b1111;
       wait(!init_enable);
      reg_init_en = 1'b1;
      command   = "hsel_deassert";
      @(posedge hclk);
      hbusreq1 <= 1'b1;
      wait(hgrant1);
      wait(hready);
      @(posedge hclk);
      haddr1 <= 32'h0000100;
      htrans1 <= 2'b10;
      hburst1 <= 3'b000;
      hwrite1 <= 1'b1;
      hsize1  <= 3'h2;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000100;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h1;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000100;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h0;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000100;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h3;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000101;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h1;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000101;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h0;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000102;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h2;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000102;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h1;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000102;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h0;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000103;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h1;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000103;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h0;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h00003004;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h2;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h0000100;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h2;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'hffffffff;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h2;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'h00000000;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h2;
      mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        @(posedge hclk);
        haddr1 <= 32'hffffffff;
        htrans1 <= 2'b10;
        hburst1 <= 3'b000;
        hwrite1 <= 1'b1;
        hsize1  <= 3'h2;
        mem_write(sig_byte_en1,haddr1,32'hffffffff,hsize1);
        reg_init_en = 1'b0;
    end
  endtask
   task wr_rd_invalid_reg;
     input [31:0] wr_data;
     reg   [2:0]  sig_hsize;
     reg   [31:0] sig_haddr;
     reg   [3:0]  sig_byte_en1;
     begin
       wait(!init_enable || pre_init_test);
       reg_init_en = 1'b1;
       command         = "wr_rd_invalid_reg";
       sig_haddr       = 32'h0000004c;// lane prg reg
       sig_hsize       = sel_hsize;
       sig_byte_en1    = 4'b1111;
       @(posedge hclk);
       hbusreq1 <= 1'b1;
       wait(hgrant1);
       wait(hready);
       @(posedge hclk);
       haddr1 <= sig_haddr;
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= 32'h00000080; // greater than address range 6c
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= sig_haddr;
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= 32'h00000070; // within the range invalid address
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= 32'h00000074;// within the range invalid address
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);

     haddr1 <= 32'h00000078;// within the range invalid address
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= 3'b1;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);

       haddr1 <= 32'h000007c;// within the range invalid address
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= sig_haddr;
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= 32'h0000004d; // within the range internal 00 to 03
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= sig_haddr;
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= 32'h0000004e; 
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= sig_haddr;
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;


       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= 32'h0000004f;
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
       haddr1 <= sig_haddr;
       htrans1 <= 2'b10;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b1;
       hsize1  <= sig_hsize;
       @(posedge hclk);
       hwdata1 <= wr_data;
       htrans1 <= 2'b0;
       hburst1 <= 3'b000;
       hwrite1 <= 1'b0;
       hsize1  <= 3'b0;

       reg_init_en = 1'b0;
     end
   endtask

  /*----------------------------------------------------------------------------
    TASK FOR PRE INITIALIZATION 
  ----------------------------------------------------------------------------*/
   task pre_initialize_test;
    begin
      pre_init_test = 1'b1;
    end
   endtask

  /*----------------------------------------------------------------------------
    TASK FOR POST INITIALIZATION 
  ----------------------------------------------------------------------------*/
   task post_initialize_test;
    begin
      wait(!init_enable);
    end
   endtask

  /*----------------------------------------------------------------------------
    TASK FOR SINGLE BURST WRITE TRANSFER 
  ----------------------------------------------------------------------------*/

   task single_burst_wr_trans;
     reg   [31:0] sig_haddr;
     reg   [2:0]  sig_hsize;
     reg   [3:0]  sig_byte_en1;
     begin
       wait(!init_enable);
       wait(wr_pend & rd_pend);
       command   = "single_burst_wr_trans";       
       $display($time,"\tAHB MASTER : NOTE ====> CSI SINGLE BURST WRITE TRANSFER COMMAND ISSUED \n");
       @(posedge hclk);
       hbusreq1 <= 1'b1;
       wait(hgrant1);
       wait(hready);
       @(posedge hclk);
       haddr1 <= 32'h00000000;// trim reg 0
       hwdata1 = 32'hffffffff;
       htrans1 <= 2'b10;      // non sequential single transfer
       hburst1 <= 3'b000;     // single transfer
       hwrite1 <= 1'b1;       // WRITE data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       $display($time,"\tAHB MASTER : WRITE TO TRIM REGISTER 0 VALUE %h COMPLETED SUCCESSFULLY\n",hwdata1);   
       @(posedge hclk);
       hwdata1 = 32'hf0f0f0f0;
       haddr1 <= 32'h0000020; // DPHY DFE DLN Register-0
       htrans1 <= 2'b01;      // bus busy
       hwrite1 <= 1'b1;       // WRITE data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       $display($time,"\tAHB MASTER : WRITE TO DPHY DFE DLN REGISTER 0 VALUE %h COMPLETED SUCCESSFULLY\n",hwdata1);   
       @(posedge hclk);
       htrans1 <= 2'b11;      // write sequential
       hwrite1 <= 1'b1;       // WRITE data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       @(posedge hclk);
       hwdata1 = 32'h0A0D0716;
       haddr1 <= 32'h000004c; // VC0 Compression/Prediction Register-1
       htrans1 <= 2'b11;      // write sequential
       hwrite1 <= 1'b1;       // WRITE data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       $display($time,"\tAHB MASTER : WRITE TO VC0 Compression/Prediction Register-1 VALUE %h COMPLETED SUCCESSFULLY\n",hwdata1);   
       @(posedge hclk);
       hwdata1 = 32'hff00ff00;
       haddr1 <= 32'h0000050; // VC0 Compression/Prediction Register-2
       htrans1 <= 2'b11;      // write sequential
       hwrite1 <= 1'b1;       // WRITE data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       $display($time,"\tAHB MASTER : WRITE TO VC0 Compression/Prediction Register-2 VALUE %h COMPLETED SUCCESSFULLY\n",hwdata1);   
       @(posedge hclk);
       hwdata1 = 32'hff;
       htrans1 <= 2'b11;      // write sequential
       hwrite1 <= 1'b1;       // WRITE data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       haddr1 <= 32'h000006c; // PLL Count Register
       htrans1 <= 2'b00;      // IDLE 
       hburst1 <= 3'b000;     // single transfer
       hwrite1 <= 1'b0;       // READ data
       hsize1  <= 3'h0;       // transfer size 8 bit encoding
       $display($time,"\tAHB MASTER : WRITE TO PLL COUNT REGISTER VALUE %h COMPLETED SUCCESSFULLY\n",hwdata1);
   end
   endtask

  /*----------------------------------------------------------------------------
     TASK FOR SINGLE BURST READ TRANSFER
  ----------------------------------------------------------------------------*/   
   
   task single_burst_rd_trans;
     reg   [31:0] sig_haddr;
     reg   [2:0]  sig_hsize;
     reg   [3:0]  sig_byte_en1;
     begin
       wait(!init_enable);
       wait(wr_pend & rd_pend);
       command   = "single_burst_rd_trans";       
       $display($time,"\tAHB MASTER : NOTE ====> CSI SINGLE BURST READ TRANSFER COMMAND ISSUED \n");
       @(posedge hclk);
       hbusreq1 <= 1'b1;
       wait(hgrant1);
       wait(hready);
       @(posedge hclk);
       haddr1 <= 32'h00000000;// trim reg 0
       hwdata1 = 32'hffffffff; 
       htrans1 <= 2'b10;      // non sequential single transfer
       hburst1 <= 3'b000;     // single transfer
       hwrite1 <= 1'b0;       // READ data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       wait(hready);
       rec_data = hrdata;
       $display($time,"\tAHB MASTER : READ FROM TRIM REGISTER 0 VALUE %h COMPLETED SUCCESSFULLY\n",rec_data);   
       @(posedge hclk);
       hwdata1 = 32'hf0f0f0f0;
       haddr1 <= 32'h0000020; // DPHY DFE DLN Register-0
       htrans1 <= 2'b01;      // bus busy
       hwrite1 <= 1'b0;       // READ data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       wait(hready);
       rec_data = hrdata;
      @(posedge hclk);
       htrans1 <= 2'b11;      // read sequential
       hwrite1 <= 1'b0;       // READ data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       wait(hready);
       rec_data = hrdata;
       $display($time,"\tAHB MASTER : READ FROM DFE DLN REGISTER 0 VALUE %h COMPLETED SUCCESSFULLY\n",rec_data);   
       @(posedge hclk);
       haddr1 <= 32'h000004c; // VC0 Compression/Prediction Register-1
       htrans1 <= 2'b11;      // read sequential
       hwrite1 <= 1'b0;       // READ data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       wait(hready);
       rec_data = hrdata;
       $display($time,"\tAHB MASTER : READ FROM VC0 Compression/Prediction Register-1 VALUE %h COMPLETED SUCCESSFULLY\n",rec_data);   
       @(posedge hclk);
       hwdata1 = 32'hff00ff00;
       haddr1 <= 32'h0000050; // VC0 Compression/Prediction Register-2
       htrans1 <= 2'b11;      // read sequential
       hwrite1 <= 1'b0;       // READ data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       wait(hready);
       rec_data = hrdata;
       $display($time,"\tAHB MASTER : READ FROM VC0 Compression/Prediction Register-2 VALUE %h COMPLETED SUCCESSFULLY\n",rec_data);   
       @(posedge hclk);
       hwdata1 = 32'h02;
       htrans1 <= 2'b11;      // read sequential
       hwrite1 <= 1'b0;       // READ data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       wait(hready);
       rec_data = hrdata;
       $display($time,"\tAHB MASTER : READ FROM PLL COUNT REGISTER VALUE %h COMPLETED SUCCESSFULLY\n",rec_data);   
       haddr1 <= 32'h000006c; // PLL Count Register
       htrans1 <= 2'b00;      // IDLE
       hburst1 <= 3'b000;     // single transfer
       hwrite1 <= 1'b0;       // READ data
       hsize1  <= 3'h0;       // transfer size 8 bit encoding   
     end
   endtask

  /*----------------------------------------------------------------------------
     TRANSFER SIZE TASK FOR COVERAGE
  ----------------------------------------------------------------------------*/
   task transfer_size;
     reg   [31:0] sig_haddr;
     reg   [2:0]  sig_hsize;
     reg   [3:0]  sig_byte_en1;
      begin
       wait(!init_enable);
       wait(wr_pend & rd_pend);
       command   = "transfer_size";       
       @(posedge hclk);
       hbusreq1 <= 1'b1;
       wait(hgrant1);
       wait(hready);
       @(posedge hclk);
       haddr1 <= 32'h00000000;// trim reg 0
       htrans1 <= 2'b10;      // non sequential single transfer
       hburst1 <= 3'b000;     // single transfer
       hwrite1 <= 1'b1;       // WRITE data
       hsize1  <= 3'h0;       // transfer size 8 bit encoding
       @(posedge hclk);
       hwdata1 = 32'hf0f0f0f0;
       haddr1 <= 32'h0000020; // DPHY DFE DLN Register-0
       htrans1 <= 2'b01;      // bus busy
       hwrite1 <= 1'b1;       // WRITE data
       hsize1  <= 3'h1;       // transfer size 16 bit encoding
       @(posedge hclk);
       hwdata1 = 32'h0A0D0716;
       haddr1 <= 32'h000004c; // VC0 Compression/Prediction Register-1
       htrans1 <= 2'b11;      // write sequential
       hwrite1 <= 1'b1;       // WRITE data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       @(posedge hclk);
       hwdata1 = 32'h00000d0d;
       htrans1 <= 2'b11;      // write sequential
       hwrite1 <= 1'b1;       // WRITE data
       hsize1  <= 3'h2;       // transfer size 32 bit encoding
       @(posedge hclk);
       htrans1 <= 2'b00;      // IDLE
       hburst1 <= 3'b000;     // single transfer
       hwrite1 <= 1'b0;       // READ data
       hsize1  <= 3'h0;      // transfer size 8 bit encoding
      end
   endtask

  /*----------------------------------------------------------------------------
     TRANSFER SIZE TASK FOR COVERAGE -- FOR MAX address
  ----------------------------------------------------------------------------*/
   task ahb_write_process;
       input [31:0] wr_data;
       input [31:0] h_addr;
       reg   [2:0]  sig_hsize;
       reg   [31:0] sig_haddr;
       reg   [3:0]  sig_byte_en1;
       reg   [31:0] reg_1;
        begin
         wait(!init_enable);
         wait(wr_pend & rd_pend);
         command         = "ahb_write_process";
         sig_haddr       = h_addr;
         sig_hsize       = sel_hsize;
         sig_byte_en1    = 4'b1111;
         hwdata1 = wr_data;
         mem_write(sig_byte_en1,sig_haddr,hwdata1,sig_hsize);
         reg_1     = wr_data;
         $display($time,"\tAHB MASTER : WRITE TO REGISTER %h WITH DATA VALUE %h COMPLETED SUCCESSFULLY\n",h_addr,reg_1);
        end
   endtask

  /*----------------------------------------------------------------------------
     TASK FOR TRIM BIT REGISTERS VALUE CHECK
  ----------------------------------------------------------------------------*/

   task test_mode_enable;
    begin
     test_mode = 1'b1;
     $display($time,"\tAHB MASTER : NOTE ====> TEST MODE COMMAND ISSUED \n");
     repeat(1000)
     @(posedge hclk);
     test_mode = 1'b0;
    end
   endtask
