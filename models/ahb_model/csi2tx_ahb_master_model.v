/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_ahb_master_model.v
// Author      : SANDEEPA
// Version     : v1p2
// Abstract    : It initialise the ahb registers and service the interrupt which is 
//               raised by the ahb reg interface  
//                
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/

`timescale 1 ps / 1 ps
`define ns1 *1000
`define us2 *1000000
`define ms1 *1000000000

module csi2tx_ahb_master_model (
    input  wire          hclk                            , // ALL SIGNAL TIMINGS ARE RELATED TO THE RISING EDGE OF HCLK
    input  wire          hresetn                         , // AHB ACTIVE LOW RESET
    input  wire  [31:0]  hrdata                          , // READ DATA BUS TRANSFERS DATA FROM SLAVES TO MASTER DURING READ OPERATIONS
    input  wire          hready                          , // SIGNAL INDICATES THE TRANSFER HAS FINISHED ON THE BUS
    input  wire   [1:0]  hresp                           , // INDICATES THE STATUS OF THE TRANSFER
    input  wire          hgrant1                         , // INDICATES MASTER 1 IS THE HIGHEST PRIORITY MASTER

    //OUTPUTS TO BACK END INTERFACE
    output reg    [2:0]  hburst1                         ,
    output reg		 hbusreq1                        , 
    output reg		 err_status                      ,
    output wire		 end_ahb                         ,
    output wire  [15:0]	 delay_val                       ,
    output reg		 processor_rst_n                 ,
    output reg   [11:0]	 clk_csi_freq                    ,
    output reg		 hwrite1                         , // INDICATES WRITE WHEN HIGH AND READ WHEN LOW
    output reg    [1:0]	 htrans1                         , // INDICATES THE TYPE OF THE CURRENT TRANSFER
    output reg   [31:0]	 haddr1                          , // 32-BIT SYSTEM ADDR BUS
    output reg   [31:0]  hwdata1                         , // WRITE DATA BUS TRANSFERS DATA FROM MASTER 1 TO SLAVE(TARGET INTERFACE)
    output reg    [2:0]	 hsize1                          , // INDICATES THE SIZE OF THE TRANSFER
    output        [2:0]	 lane_count_out                  ,         
    output reg           test_mode                       ,         
    output reg   [31:0]  raw_image_data_type             ,
    output reg   [31:0]  yuv_image_data_type             ,
    output reg   [31:0]	 usd_data_type_reg               ,
    output reg   [31:0]	 rgb_image_data_type             ,
    output reg   [31:0]  generic_8_bit_long_pkt_data_type       
   );

  /*---------------------------------------------------------------------------
    Internal Register, Wire & Integer Declaration
  ---------------------------------------------------------------------------*/
  reg       [2:0]       lane_count                      ;
  reg                   reg_init_en                     ;
  reg                   init_enable                     ;
  reg       [2:0]       sel_hsize                       ;
  reg      [31:0]      	rec_data                        ;
  reg      [31:0]      	received_data                   ;
  reg    [75*8:0]       command                         ;             
  reg            	wr_pend                         ;
  reg                   rd_pend                         ;
  reg                   test_dbg                        ;
  reg           	interrupt                       ;
  reg           	end_file                        ;
  reg           	trim_static_chk                 ;
  reg      [31:0]     	expect_trim0_reg                ; 
  reg      [31:0]     	expect_trim1_reg                ; 
  reg      [31:0]     	expect_trim2_reg                ; 
  reg      [31:0]     	expect_trim3_reg                ; 
  reg      [31:0]     	expect_trim4_reg                ; 
  reg      [31:0]     	expect_trim5_reg                ; 
  reg      [31:0]     	expect_trim6_reg                ; 
  reg      [31:0]     	expect_trim7_reg                ; 
  reg      [31:0]     	expect_trim8_reg                ; 
  reg           	trim_reg_toggle                 ;
  reg       [7:0]       dln_hs_prepare                  ;            
  reg       [7:0]       dln_hs_zero                     ;
  reg       [7:0]       dln_hs_trial                    ;
  reg       [7:0]       dln_hs_exit                     ;
  reg       [7:0]       dln_rx_sync_cnt                 ;
  reg       [7:0]       dln_rx_cnt                      ;
  reg       [7:0]       dln_lpx                         ;
  reg       [7:0]       cln_prepare                     ;
  reg       [7:0]       cln_zero                        ;
  reg       [7:0]       cln_trial                       ;
  reg       [7:0]       cln_exit                        ;
  reg       [7:0]       cln_post                        ;
  reg       [7:0]       cln_pre                         ;
  reg                   select_ref                      ;   
  reg       [5:0]       cnta                            ;                           
  reg                   cntb                            ;
  reg       [2:0]       lane                            ;
  reg                   lane_index_en                   ;
  reg       [2:0]       lan_index                       ; 
  reg                   pre_init_test                   ;
  reg                   config_comp                     ;
  reg                   ahb_cfg_comp                    ;
  reg                   lane_rst                        ;
   
  real              	ui_ns                           ;
  real            	ddr_freq                        ;
  real                  freq                            ;
  real              	ddrclk_ns                       ;           
  real            	ui        			;   
  real                  byteclkhs_ns        	        ;
  real              	dln_total_ns                    ;
  real            	dln_prepare_min_ns              ;
  real                  dln_zero_min_ns                 ;
  real              	dln_exit_min_ns                 ;
  real            	dln_trial_min_ns                ;
  real                  dln_prepare_max_ns              ;
  real              	dln_zero_max_ns                 ;
  real            	cfg_dln_zero                    ;
  real                  dln_exit_max_ns                 ;
  real              	dln_trial_max_ns                ;
  real            	lpx                             ;
  real                  dphy_default_dln_prepare_ns     ;
  real              	dphy_default_dln_zero_ns        ;
  real            	dphy_default_dln_trail_ns       ;
  real                  dphy_default_lpx                ;
  real              	prg_dln_prepare_min             ;
  real            	prg_dln_zero_min                ;
  real                  prg_dln_trail_min               ;
  real              	prg_lpx_min                     ;
  real            	actual_dln_prepare_min_ns       ;
  real                  actual_dln_zero_min_ns          ;
  real              	actual_dln_exit_min_ns          ;
  real            	actual_dln_trail_min_ns         ;
  real                  actual_lpx_min_ns               ;
  real              	prg_dln_prepare_max             ;
  real            	prg_dln_zero_max                ;
  real                  prg_dln_trail_max               ;
  real              	actual_dln_prepare_max_ns       ;
  real            	actual_dln_zero_max_ns          ;
  real                  actual_dln_exit_max_ns          ;
  real              	actual_dln_trail_max_ns         ;
  real            	cln_total_ns                    ;
  real                  cln_prepare_min_ns              ;
  real              	cln_zero_min_ns                 ;
  real            	cln_exit_min_ns                 ;
  real                  cln_trial_min_ns                ;
  real              	cln_prepare_max_ns              ;
  real            	cln_zero_max_ns                 ;
  real                  cfg_cln_zero                    ;
  real              	cln_exit_max_ns                 ;
  real            	cln_trial_max_ns                ;
  real                  dphy_default_cln_prepare_ns     ;
  real              	dphy_default_cln_zero_ns        ;
  real            	dphy_default_cln_trail_ns       ;
  real                  prg_cln_prepare_min             ;
  real              	prg_cln_zero_min                ;
  real            	prg_cln_trail_min               ;
  real                  actual_cln_prepare_min_ns       ;
  real              	actual_cln_zero_min_ns          ;
  real            	actual_cln_exit_min_ns          ;
  real                  actual_cln_trail_min_ns         ;
  real              	prg_cln_prepare_max             ;
  real            	prg_cln_zero_max                ;
  real                  prg_cln_trail_max               ;
  real              	actual_cln_prepare_max_ns       ;
  real            	actual_cln_zero_max_ns          ;
  real                  actual_cln_exit_max_ns          ;
  real              	actual_cln_trail_max_ns         ;
  real            	Tcln_post_max                   ;
  real                  Tcln_post_min                   ;
  real              	Tcln_pre_max                    ;
  real            	Tcln_pre_min                    ;
                        
  integer               int_cou_pointer2                ; 
  integer             	k                               ;
  integer              	cfg_dln_prepare_min_cnt         ;
  integer            	cfg_dln_prepare_max_cnt         ;
  integer               cfg_dln_zero_min_cnt            ;
  integer              	cfg_dln_zero_max_cnt            ;
  integer            	cfg_dln_exit_min_cnt            ;
  integer               cfg_dln_exit_max_cnt            ;
  integer              	cfg_dln_trail_min_cnt           ;
  integer            	cfg_dln_trail_max_cnt           ;
  integer               cfg_lpx                         ;
  integer              	cfg_cln_prepare_min_cnt         ;
  integer            	cfg_cln_prepare_max_cnt         ;
  integer               cfg_cln_zero_min_cnt            ;
  integer              	cfg_cln_zero_max_cnt            ;
  integer            	cfg_cln_exit_min_cnt            ;
  integer               cfg_cln_exit_max_cnt            ;
  integer              	cfg_cln_trail_min_cnt           ;
  integer            	cfg_cln_trail_max_cnt           ;
  integer               cln_prepare_max_cnt             ;
  integer               cln_zero_max_cnt                ;
  integer              	cln_exit_max_cnt                ;
  integer               cln_trail_max_cnt               ;
  integer             	cln_prepare_min_cnt             ;
  integer               cln_zero_min_cnt                ;
  integer               cln_exit_min_cnt                ;
  integer             	cln_trail_min_cnt               ;
  integer               dln_prepare_min_cnt             ;
  integer               dln_zero_min_cnt                ;
  integer             	dln_exit_min_cnt                ;
  integer               dln_trail_min_cnt               ;
  integer               dln_lpx_cnt                     ;
  integer             	dln_prepare_max_cnt             ;
  integer               dln_zero_max_cnt                ;
  integer               dln_exit_max_cnt                ;
  integer             	dln_trail_max_cnt               ;
  integer               max_init_calib_time             ;
  integer               max_periodic_calib_time         ;
  integer               max_init_calib_cnt              ;
  integer               max_periodic_calib_cnt          ;
  integer               min_init_calib_time             ;
  integer               min_periodic_calib_time         ;
  integer               min_init_calib_cnt              ;
  integer               min_periodic_calib_cnt          ; 
                        
  /*---------------------------------------------------------------------------
    Initalization
  ---------------------------------------------------------------------------*/
  initial
    begin
      test_mode                        = 1'b0;
      init_enable                      = 1'b1;
      interrupt                        = 1'b0;
      hbusreq1             	       = 1'b0;
      trim_static_chk      	       = 1'b0;
      hwrite1                 	       = 1'b0;
      htrans1                 	       = 2'b0;
      haddr1                  	       = 32'h0;
      hwdata1                 	       = 32'b0;
      clk_csi_freq 		       = 12'h14d;
      hsize1                  	       = 3'h0;
      processor_rst_n      	       = 1'b0;
      hburst1                 	       = 3'h0;
      sel_hsize               	       = 3'b010;
      rec_data                	       = 32'h0;
      received_data           	       = 32'h0;
      err_status                       = 1'b0;
      k                       	       = 0;
      wr_pend                          = 1'b1;
      rd_pend                          = 1'b1;
      expect_trim0_reg        	       = 32'h0000;
      expect_trim1_reg        	       = 32'h00001044;
      expect_trim2_reg        	       = 32'h80A84020;
      expect_trim3_reg        	       = 32'h28454888;
      expect_trim4_reg        	       = 32'h00100285;
      expect_trim5_reg        	       = 32'h10440008;
      expect_trim6_reg        	       = 32'h00000000;
      expect_trim7_reg        	       = 32'h440882a8;
      expect_trim8_reg        	       = 32'h0000;
      trim_reg_toggle         	       = 1'b0;
      yuv_image_data_type     	       = 32'h00000000;
      rgb_image_data_type     	       = 32'h00000000;
      raw_image_data_type     	       = 32'h00000000;
      usd_data_type_reg       	       = 32'h00000000; 
      generic_8_bit_long_pkt_data_type = 32'h00000000;
      lane                             = 3'h0;                               
      lane_index_en                    = 1'b0; 
      lan_index                        = 3'b0; 
      cnta                             = 6'b0;
      cntb                             = 1'b0;
      reg_init_en                      = 1'b0;
      end_file                         = 1'b0;
      pre_init_test                    = 1'b0;
      config_comp                      = 1'b0; 
      ahb_cfg_comp                     = 1'b0; 
      lane_rst                         = 1'b0;

      wait(hresetn);
      ahb_master_cmd;
    end

  `include "../models/ahb_model/csi2tx_ahb_master_tasks.v"
  `include "ahb_master_cmd.v" 

  assign end_ahb = (end_file & !interrupt) ? 1'b1 : 1'b0;

  assign lane_count_out = lane_rst? 3'b111: lane;

   always @ (negedge hresetn)
      begin
       if(pre_init_test == 1'b0)
        begin
          initialize_csi; 
        end
      end

  always@(*)
    begin
      wait(test_env.u_csi2tx_clk_gen_inst.clk_generated == 1'b1);
      ddr_freq             = test_env.u_csi2tx_clk_gen_inst.ddr_freq;
      ddrclk_ns            = (1000/ddr_freq);
      ui                   = ddrclk_ns * 0.5;
      byteclkhs_ns         = (ddrclk_ns * 4);

    /*---------------------------------------------------------------------------
      Data Lane Calculations
    ---------------------------------------------------------------------------*/
    dln_total_ns = 145 + (10 * ui);
    dln_prepare_min_ns = 40 + (4 * ui);
    dln_prepare_max_ns = 85 + (6 * ui);
    dln_zero_min_ns = dln_total_ns - dln_prepare_max_ns;
  
    `ifdef UVC
    dln_zero_max_ns  = 2 * dln_zero_min_ns;
    `else
    dln_zero_max_ns  = 256 * ui;
    `endif
    
    // The following formula is used to meet the min requirement of dln_total
    cfg_dln_zero = dln_zero_min_ns + (dln_total_ns - dln_prepare_min_ns - dln_zero_min_ns);
  
    dln_exit_min_ns = 100;
    
    `ifdef UVC
    dln_exit_max_ns  = 2 * dln_exit_min_ns;
    `else
    dln_exit_max_ns  = 0;
    `endif
  
    dln_trial_min_ns = ((8 * ui) > (60 + (4 * ui))) ? 8 * ui : 60 + (4 * ui);
    
    `ifdef UVC
    dln_trial_max_ns = 2 * dln_trial_min_ns;
    `else
    dln_trial_max_ns = 105 + (12 * ui);
    `endif
    
    Tcln_post_min = 60 + 52*ui;
    Tcln_pre_min  = 8*ui;
    
    `ifdef UVC
    Tcln_post_max = 2 * Tcln_post_min;
    `else
    Tcln_post_max = 256*ui;
    `endif
  
    `ifdef UVC
    Tcln_pre_max  = 2 * Tcln_pre_min;
    `else
    Tcln_pre_max  = 256*ui;
    `endif
    
    lpx = 50;
    
    /*----------------------------------------------------------------------------
     By default, the DPHY takes some ns, due to the internal state machines
     while configuring, the default values are substracted and result is used for
     configuring the registers
    ----------------------------------------------------------------------------*/
    dphy_default_dln_prepare_ns = 22 * ui;
    dphy_default_dln_zero_ns    = 10 * ui;
    dphy_default_dln_trail_ns   = 14 * ui;
    dphy_default_lpx            =  8 * ui;
  
    /*----------------------------------------------------------------------------
                         Minimum Parameters  
     calculate the period to be configured to adjust the dphy default period                                   
    -----------------------------------------------------------------------------*/
     
    prg_dln_prepare_min = dln_prepare_min_ns > dphy_default_dln_prepare_ns ? (dln_prepare_min_ns - dphy_default_dln_prepare_ns) : 0; 
    prg_dln_zero_min    = cfg_dln_zero       > dphy_default_dln_zero_ns    ? (cfg_dln_zero     - dphy_default_dln_zero_ns)      : 0; 
    prg_dln_trail_min   = dln_trial_min_ns   > dphy_default_dln_trail_ns   ? (dln_trial_min_ns - dphy_default_dln_trail_ns)     : 0; 
    prg_lpx_min         = lpx                > dphy_default_lpx            ? (lpx              - dphy_default_lpx)              : 0; 
    
    dln_prepare_min_cnt = prg_dln_prepare_min/byteclkhs_ns;
    dln_zero_min_cnt    = prg_dln_zero_min/byteclkhs_ns;
    dln_exit_min_cnt    = dln_exit_min_ns/byteclkhs_ns;
    dln_trail_min_cnt   = prg_dln_trail_min/byteclkhs_ns;
    dln_lpx_cnt         = prg_lpx_min/byteclkhs_ns;
    
    //derive the value in ns that is getting programmed
    actual_dln_prepare_min_ns = dphy_default_dln_prepare_ns + (dln_prepare_min_cnt * byteclkhs_ns);
    actual_dln_zero_min_ns    = dphy_default_dln_zero_ns    + (dln_zero_min_cnt    * byteclkhs_ns);
    actual_dln_exit_min_ns    = dln_exit_min_cnt * byteclkhs_ns;
    actual_dln_trail_min_ns   = dphy_default_dln_trail_ns   + (dln_trail_min_cnt   * byteclkhs_ns);
    actual_lpx_min_ns         = dphy_default_lpx            + (dln_lpx_cnt         * byteclkhs_ns);
    
    /*-----------------------------------------------------------------------------
     Compare the derived value with the spec. This is required, so as to meet all
     minimum period. This is required to take care of fractional points. Since the
     program value is for min, any fractional part is rounded up to next integer
    -----------------------------------------------------------------------------*/
    cfg_dln_prepare_min_cnt = (actual_dln_prepare_min_ns >= dln_prepare_min_ns) ? dln_prepare_min_cnt : dln_prepare_min_cnt + 1; 
    cfg_dln_zero_min_cnt    = (actual_dln_zero_min_ns    >= dln_zero_min_ns)    ? dln_zero_min_cnt    : dln_zero_min_cnt    + 1;
    cfg_dln_exit_min_cnt    = (actual_dln_exit_min_ns    >= dln_exit_min_ns)    ? dln_exit_min_cnt    : dln_exit_min_cnt    + 1;
    cfg_dln_trail_min_cnt   = (actual_dln_trail_min_ns   >= dln_trial_min_ns)   ? dln_trail_min_cnt   : dln_trail_min_cnt   + 1;
    cfg_lpx                 = (actual_lpx_min_ns         >= lpx)                ? dln_lpx_cnt         : dln_lpx_cnt         + 1;
    
    /*----------------------------------------------------------------------------
                         Maximum Parameters 
      calculate the period to be configured to adjust the dphy default period                                        
    -----------------------------------------------------------------------------*/
    prg_dln_prepare_max = dln_prepare_max_ns > dphy_default_dln_prepare_ns ? (dln_prepare_max_ns - dphy_default_dln_prepare_ns) : 0; 
    prg_dln_zero_max    = dln_zero_max_ns    > dphy_default_dln_zero_ns    ? (dln_zero_max_ns  - dphy_default_dln_zero_ns)      : 0;
    prg_dln_trail_max   = dln_trial_max_ns   > dphy_default_dln_trail_ns   ? (dln_trial_max_ns - dphy_default_dln_trail_ns)     : 0;
    
    dln_prepare_max_cnt = prg_dln_prepare_max/byteclkhs_ns;
    dln_zero_max_cnt    = prg_dln_zero_max/byteclkhs_ns;
    dln_exit_max_cnt    = dln_exit_max_ns/byteclkhs_ns;
    dln_trail_max_cnt   = prg_dln_trail_max/byteclkhs_ns;
    
    //derive the value in ns that is getting programmed
    actual_dln_prepare_max_ns = dphy_default_dln_prepare_ns + (dln_prepare_max_cnt * byteclkhs_ns);
    actual_dln_zero_max_ns    = dphy_default_dln_zero_ns    + (dln_zero_max_cnt    * byteclkhs_ns);
    actual_dln_exit_max_ns    = dln_exit_max_cnt * byteclkhs_ns;
    actual_dln_trail_max_ns   = dphy_default_dln_trail_ns   + (dln_trail_max_cnt   * byteclkhs_ns);
   
    /*---------------------------------------------------------------------------- 
     Compare the derived value with the spec. This is required, so as to meet all
     maxperiod. This is required to take care of fractional points. Since the
     program value is for max, any fractional part is rounded down to integer
    ----------------------------------------------------------------------------*/
    cfg_dln_prepare_max_cnt = (actual_dln_prepare_max_ns > dln_prepare_max_ns) ?
                              ((dln_prepare_max_cnt > 0) ? dln_prepare_max_cnt - 1 : 0) : dln_prepare_max_cnt;
    cfg_dln_zero_max_cnt    = (actual_dln_zero_max_ns >  dln_zero_max_ns)      ? 
                              ((dln_zero_max_cnt > 0)    ? dln_zero_max_cnt    - 1 : 0) : dln_zero_max_cnt;
    cfg_dln_exit_max_cnt    = (actual_dln_exit_max_ns > dln_exit_max_ns)       ?
                              ((dln_exit_max_cnt > 0)    ? dln_exit_max_cnt    - 1 : 0) : dln_exit_max_cnt;
    cfg_dln_trail_max_cnt   = (actual_dln_trail_max_ns > dln_trial_max_ns)     ?
                              ((dln_trail_max_cnt > 0)   ? dln_trail_max_cnt   - 1 : 0) : dln_trail_max_cnt;
    

    /*-----------------------------------------------------------------------------
                         Clock Lane Calculations                                 
    -----------------------------------------------------------------------------*/
    cln_total_ns = 300;
    
    cln_prepare_min_ns = 38;
    cln_prepare_max_ns = 95;
  
    cln_zero_min_ns = cln_total_ns - cln_prepare_max_ns;
    
    `ifdef UVC
    cln_zero_max_ns  = 2 * cln_zero_min_ns;
    `else
    cln_zero_max_ns  = 256 * ui;
    `endif
    
    // The following formula is used to meet the min requirement of cln_total
    cfg_cln_zero = cln_zero_min_ns + (cln_total_ns - cln_prepare_min_ns - cln_zero_min_ns);
    
    cln_exit_min_ns = 100;
    
    `ifdef UVC
    cln_exit_max_ns  = 2 * cln_exit_min_ns;
    `else
    cln_exit_max_ns  = 256 * ui;
    `endif
    
    cln_trial_min_ns = 60;
    
    `ifdef UVC
    cln_trial_max_ns = 2 * cln_trial_min_ns;
    `else
    cln_trial_max_ns = 105 + (12 * ui);
    `endif
    
    /*-----------------------------------------------------------------------------
      By default, the DPHY takes some ns, due to the internal state machines
      while configuring, the default values are substracted and result is used for
      configuring the registers
    -----------------------------------------------------------------------------*/
    dphy_default_cln_prepare_ns =  8 * ui;
    dphy_default_cln_zero_ns    = 11 * ui;
    dphy_default_cln_trail_ns   =  6 * ui;
    
    /*-----------------------------------------------------------------------------
                         Minimum Parameters 
      calculate the period to be configured to adjust the dphy default period                                    
    -----------------------------------------------------------------------------*/
    prg_cln_prepare_min = cln_prepare_min_ns > dphy_default_cln_prepare_ns ? (cln_prepare_min_ns - dphy_default_cln_prepare_ns) : 0; 
    prg_cln_zero_min    = cfg_cln_zero       > dphy_default_cln_zero_ns    ? (cfg_cln_zero       - dphy_default_cln_zero_ns)    : 0;
    prg_cln_trail_min   = cln_trial_min_ns   > dphy_default_cln_trail_ns   ? (cln_trial_min_ns   - dphy_default_cln_trail_ns)   : 0;
    
    cln_prepare_min_cnt = prg_cln_prepare_min/byteclkhs_ns;
    cln_zero_min_cnt    = prg_cln_zero_min/byteclkhs_ns;
    cln_exit_min_cnt    = cln_exit_min_ns/byteclkhs_ns;
    cln_trail_min_cnt   = prg_cln_trail_min/byteclkhs_ns;
    
    //derive the value in ns that is getting programmed
    actual_cln_prepare_min_ns = dphy_default_cln_prepare_ns + (cln_prepare_min_cnt * byteclkhs_ns);
    actual_cln_zero_min_ns    = dphy_default_cln_zero_ns    + (cln_zero_min_cnt    * byteclkhs_ns);
    actual_cln_exit_min_ns    = cln_exit_min_cnt * byteclkhs_ns;
    actual_cln_trail_min_ns   = dphy_default_cln_trail_ns   + (cln_trail_min_cnt   * byteclkhs_ns);
  
    /*---------------------------------------------------------------------------
      Compare the derived value with the spec. This is required, so as to meet 
      all minimum period. This is required to take care of fractional points.
      Since the program value is for min, any fractional part is rounded up to
      next integer
    ---------------------------------------------------------------------------*/
    cfg_cln_prepare_min_cnt = (actual_cln_prepare_min_ns >= cln_prepare_min_ns) ? cln_prepare_min_cnt : cln_prepare_min_cnt + 1;
    cfg_cln_zero_min_cnt    = (actual_cln_zero_min_ns    >= cln_zero_min_ns)    ? cln_zero_min_cnt    : cln_zero_min_cnt    + 1;
    cfg_cln_exit_min_cnt    = (actual_cln_exit_min_ns    >= cln_exit_min_ns)    ? cln_exit_min_cnt    : cln_exit_min_cnt    + 1;
    cfg_cln_trail_min_cnt   = (actual_cln_trail_min_ns   >= cln_trial_min_ns)   ? cln_trail_min_cnt   : cln_trail_min_cnt   + 1;
  
    /*---------------------------------------------------------------------------
                        Maximum Parameters  
      calculate the period to be configured to adjust the dphy default period                                   
    ---------------------------------------------------------------------------*/
    prg_cln_prepare_max = cln_prepare_max_ns > dphy_default_cln_prepare_ns ? (cln_prepare_max_ns - dphy_default_cln_prepare_ns) : 0;
    prg_cln_zero_max    = cln_zero_max_ns    > dphy_default_cln_zero_ns    ? (cln_zero_max_ns  - dphy_default_cln_zero_ns)      : 0;
    prg_cln_trail_max   = cln_trial_max_ns   > dphy_default_cln_trail_ns   ? (cln_trial_max_ns - dphy_default_cln_trail_ns)     : 0;
  
    cln_prepare_max_cnt = prg_cln_prepare_max/byteclkhs_ns;
    cln_zero_max_cnt    = prg_cln_zero_max/byteclkhs_ns;
    cln_exit_max_cnt    = cln_exit_max_ns/byteclkhs_ns;
    cln_trail_max_cnt   = prg_cln_trail_max/byteclkhs_ns;
  
    //derive the value in ns that is getting programmed
    actual_cln_prepare_max_ns = dphy_default_cln_prepare_ns + (cln_prepare_max_cnt * byteclkhs_ns);
    actual_cln_zero_max_ns    = dphy_default_cln_zero_ns    + (cln_zero_max_cnt    * byteclkhs_ns);
    actual_cln_exit_max_ns    = cln_exit_max_cnt * byteclkhs_ns;
    actual_cln_trail_max_ns   = dphy_default_cln_trail_ns   + (cln_trail_max_cnt   * byteclkhs_ns);
  
    /*---------------------------------------------------------------------------
      Compare the derived value with the spec. This is required, so as to meet 
      all maxperiod. This is required to take care of fractional points. Since 
      the program value is for max, any fractional part is rounded down to lower 
      integer
    ---------------------------------------------------------------------------*/
    cfg_cln_prepare_max_cnt = (actual_cln_prepare_max_ns > cln_prepare_max_ns) ? 
                              ((cln_prepare_max_cnt > 0) ? cln_prepare_max_cnt - 1 : 0) : cln_prepare_max_cnt;
    cfg_cln_zero_max_cnt    = (actual_cln_zero_max_ns    > cln_zero_max_ns)    ? 
                              ((cln_zero_max_cnt > 0 )   ? cln_zero_max_cnt    - 1 : 0) : cln_zero_max_cnt;
    cfg_cln_exit_max_cnt    = (actual_cln_exit_max_ns    > cln_exit_max_ns)    ? 
                              ((cln_exit_max_cnt > 0 )   ? cln_exit_max_cnt    - 1 : 0) : cln_exit_max_cnt;
    cfg_cln_trail_max_cnt   = (actual_cln_trail_max_ns   > cln_trial_max_ns)   ? 
                              ((cln_trail_max_cnt > 0 )  ? cln_trail_max_cnt   - 1 : 0) : cln_trail_max_cnt;

    /*---------------------------------------------------------------------------
         calibration calculation

    ---------------------------------------------------------------------------*/

    max_init_calib_time = 100000; //100us so 100000 ns
    max_periodic_calib_time = 10000; //10us so 10000 ns
    
    max_init_calib_cnt = ((max_init_calib_time/ddrclk_ns)/4); //for byte_clk_cnt
    max_periodic_calib_cnt = ((max_periodic_calib_time/ddrclk_ns)/4);//for byte_clk_cnt

    min_init_calib_time = ((2**15) * ui);
    min_periodic_calib_time = ((2**12) * ui);

    min_init_calib_cnt = ((min_init_calib_time/ddrclk_ns)/4); //for byte_clk_cnt
    min_periodic_calib_cnt = ((min_periodic_calib_time/ddrclk_ns)/4);//for byte_clk_cnt

 

    // program parameters
    `ifdef DPHY_PARAM_MAX
    
     assign dln_hs_prepare  = cfg_dln_prepare_max_cnt               ;
     assign dln_hs_zero     = cfg_dln_zero_max_cnt                  ;
     assign dln_hs_trial    = cfg_dln_trail_max_cnt                 ;
     assign dln_hs_exit     = cfg_dln_exit_max_cnt                  ;
     assign dln_rx_sync_cnt = dln_hs_prepare + dln_hs_zero + 1      ;
     assign dln_rx_cnt      = dln_hs_prepare                        ;
     assign dln_lpx         = cfg_lpx                               ;
     assign cln_prepare     = cfg_cln_prepare_max_cnt               ;
     assign cln_zero        = cfg_cln_zero_max_cnt                  ;
     assign cln_trial       = cfg_cln_trail_max_cnt                 ;
     assign cln_exit        = cfg_cln_exit_max_cnt                  ;
     assign cln_post        = (Tcln_post_max/byteclkhs_ns)          ;
     assign cln_pre         = (Tcln_pre_max/byteclkhs_ns)           ;
    
    `elsif DPHY_PARAM_AVG
     assign dln_hs_prepare  = (cfg_dln_prepare_max_cnt+cfg_dln_prepare_min_cnt)/2   ; 
     assign dln_hs_zero     = (cfg_dln_zero_max_cnt+cfg_dln_zero_min_cnt)/2         ;
     assign dln_hs_trial    = (cfg_dln_trail_max_cnt+cfg_dln_trail_min_cnt)/2       ;
     assign dln_hs_exit     = (cfg_dln_exit_max_cnt+cfg_dln_exit_min_cnt)/2         ;
     assign dln_rx_sync_cnt =  dln_hs_prepare + dln_hs_zero + 1                     ;
     assign dln_rx_cnt      =  dln_hs_prepare                                       ;
     assign dln_lpx         =  cfg_lpx                                              ;
     assign cln_prepare     = (cfg_cln_prepare_max_cnt+cfg_cln_prepare_min_cnt)/2   ;
     assign cln_zero        = (cfg_cln_zero_max_cnt+cfg_cln_zero_min_cnt)/2         ;
     assign cln_trial       = (cfg_cln_trail_max_cnt+cfg_cln_trail_min_cnt)/2       ;
     assign cln_exit        = (cfg_cln_exit_max_cnt+cfg_cln_exit_min_cnt)/2         ;
     assign cln_post        = (Tcln_post_max+Tcln_post_min)/(2*byteclkhs_ns)        ;
     assign cln_pre         = (Tcln_pre_max+Tcln_pre_min)/(2*byteclkhs_ns)          ;
    `else
     assign dln_hs_prepare  = cfg_dln_prepare_min_cnt              ;
     assign dln_hs_zero     = cfg_dln_zero_min_cnt                 ;
     assign dln_hs_trial    = cfg_dln_trail_min_cnt                ;
     assign dln_hs_exit     = cfg_dln_exit_min_cnt                 ;
     assign dln_rx_sync_cnt = dln_hs_prepare + dln_hs_zero + 1     ;
     assign dln_rx_cnt      = dln_hs_prepare                       ;
     assign dln_lpx         = cfg_lpx                              ;
     assign cln_prepare     = cfg_cln_prepare_min_cnt              ;
     assign cln_zero        = cfg_cln_zero_min_cnt                 ;
     assign cln_trial       = cfg_cln_trail_min_cnt                ;
     assign cln_exit        = cfg_cln_exit_min_cnt                 ;
     assign cln_post        = Tcln_post_min/byteclkhs_ns           ;
     assign cln_pre         = Tcln_pre_min/byteclkhs_ns            ;
    `endif
    
    `ifdef ONE_LANE     lane_count = 3'b000;
    `elsif TWO_LANE     lane_count = 3'b001;
    `elsif THREE_LANE   lane_count = 3'b010;
    `elsif FOUR_LANE    lane_count = 3'b011;
    `elsif FIVE_LANE    lane_count = 3'b100;
    `elsif SIX_LANE     lane_count = 3'b101;
    `elsif SEVEN_LANE   lane_count = 3'b110;
    `elsif EIGHT_LANE   lane_count = 3'b111;
    `else               lane_count = 3'b111;
    `endif

    assign lane = lane_index_en ? lan_index : lane_count;
     
    $display ("\t\t\t====================================================\n");
    $display ("\t\t\tINFO :-\n");
    $display ("\t\t\tNumber of lanes configured is = %d\n",(lane+1));
    $display ("\t\t\tDDR clk frequency set by user = %fMHz\n",ddr_freq);
    $display ("\t\t\tDDR clk period                = %fns\n",ddrclk_ns);
    $display ("\t\t\tUnit Interval (UI)            = %fns\n",ui);
    $display ("\t\t\tByteClk period                = %fns\n",byteclkhs_ns);
    `ifdef DPHY_PARAM_MAX
    $display ("\t\t\tNOTE :- DPHY parameters are set for MAX values;\n");
    `elsif DPHY_PARAM_AVG
    $display ("\t\t\tNOTE :- DPHY parameters are set for AVG values;\n");
    `else
    $display ("\t\t\tNOTE :- DPHY parameters are set for MIN values;\n");
    `endif
    $display ("\t\t\tData Lane settings  :- \n");
    $display ("\t\t\t1. DLN_PREPARE  = %d\n",dln_hs_prepare);
    $display ("\t\t\t2. DLN_ZERO     = %d\n",dln_hs_zero);
    $display ("\t\t\t3. DLN_TRIAL    = %d\n",dln_hs_trial);
    $display ("\t\t\t4. DLN_EXIT     = %d\n",dln_hs_exit);
    $display ("\t\t\t5. RX_SYNC_CNT  = %d\n",dln_rx_sync_cnt);
    $display ("\t\t\t6. RX_CNT       = %d\n",dln_rx_cnt);
    $display ("\t\t\t7. DLN_LPX      = %d\n",dln_lpx);
    $display ("\t\t\tClock Lane settings :- \n");
    $display ("\t\t\t1. CLN_PREPARE  = %d\n",cln_prepare);
    $display ("\t\t\t2. CLN_ZERO     = %d\n",cln_zero);
    $display ("\t\t\t3. CLN_TRIAL    = %d\n",cln_trial);
    $display ("\t\t\t4. CLN_EXIT     = %d\n",cln_exit);
    $display ("\t\t\t5. CLN_POST     = %d\n",cln_post);
    $display ("\t\t\t6. CLN_PRE      = %d\n",cln_pre);
    $display ("\t\t\t====================================================\n");
    config_comp =1'b1;
  end
    
endmodule     
