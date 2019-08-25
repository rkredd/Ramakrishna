/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication, the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : test_env.v
// Author      : R DINESH KUMAR
// Version     : v1p2
// Abstract    : This top module for the verification environment  
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
`define ns *1            // *1 shall be substituted wherever ns appears
//`define SIMULATION_LEVEL
//`define TIMESCALE_NS


module test_env();
  
  parameter DATA_SIZE = 32;
  parameter RAM_SIZE  = 13;      
       wire 			reset_clk_csi_n       ;
       wire 			clk_csi               ;
       wire        		end_all               ;
       wire        		err_flg               ;
       wire        		csi_end_of_file       ;
       real  		        clk_csi_freq          ;
       wire        		ls                    ;
       wire        		le                    ;
       wire        		fs                    ;
       wire        		fe                    ;
       wire [1:0]  		packet_vc             ;
       wire [15:0] 		packet_wc_df          ;
       wire        		odd_even_line         ;
       wire [31:0]  		pixel_width           ;
       wire [2:0]  		lane_count            ;
       wire [31:0] 		packet_data           ;
       wire [5:0] 		packet_dt             ;
       wire        		err_rxbfm             ;
       wire        		rxer_end              ;
       wire        		end_monitor           ;
       wire 			txclkesc              ;
       wire 			packet_valid          ;
       wire 			txulpsesc             ;
       wire 			txulpsexit            ;
       wire 			packet_rdy            ;
       wire 			packet_data_rdy       ;
       wire 			csi_tx_pix_en         ;
       wire 			pixel_valid           ;
       wire 			err_monitor           ;
       wire 			txrequesths_clk       ;
       wire 			master_pin            ;
       wire 			loopback_sel          ;
       wire 			dphy_clk_mode         ;
       wire 			txbyteclkhs           ;
       wire 			forcetxstopmode_csi;
       wire 			test_mode;
       wire [31:0]  		yuv_image_data_type;
       wire [31:0]  		rgb_image_data_type;
       wire [31:0]  		raw_image_data_type;
       wire [31:0]  		usd_data_type_reg;
       wire [31:0]  		generic_8_bit_long_pkt_data_type;
       wire [31:0]              rxbfm_mon_headerdata;
       wire [11:0]              rxbfm_comp_data;
       wire                     rxbfm_comp_en ;
       wire [7:0]               csi1_stopstate;
       wire 			err_lp_rxer;
       wire [31:0]              rxbfm_mon_pixeldata;
       wire			processor_rst_n;
       real 			ui_ns;
       //AHB signals
       wire	 		hclk;
       wire [15:0]     	        sig_delay_val;
       wire [1:0]      	        sig_hresp2;
       wire [31:0]     	        sig_hrdata2;
       wire [31:0]     	        sig_haddr;
       wire [1:0]      	        sig_htrans;
       wire [2:0]      	        sig_hsize;
       wire [31:0]     	        sig_hwdata;
       wire            	        sig_hgrant1;
       wire [31:0]     	        sig_hrdata;
       wire            	        sig_hready_mux;
       wire [1:0]      	        sig_hresp;
       wire            	        sig_hbusreq1;
       wire            	        sig_hwrite1;
       wire [1:0]      	        sig_htrans1;
       wire [31:0]     	        sig_haddr1;
       wire [31:0]     	        sig_hwdata1;
       wire [2:0]      	        sig_hsize1;
       wire [2:0]      	        sig_hburst1;
       wire [2:0]      	        sig_hburst;
       wire [3:0]      	        sig_hmaster;
       wire            	        sig_hgrant2;
       wire            	        sig_hsel1;
       wire            	        sig_hsel2;
       wire            	        sig_hsel3;
       wire            	        err_status;
       wire            	        sig_end_file2;
       //DPHY declarations
       wire [63:0] 		rd_data_sensor_fifo;
       wire 		        cena_n_sensor_fifo;
       wire 		        wena_n_sensor_fifo;
       wire [11:0] 		wr_addr_sensor_fifo;
       wire [11:0] 		rd_addr_sensor_fifo;
       wire [63:0] 		wr_data_sensor_fifo;
       wire 		        cenb_n_sensor_fifo;
       wire 		        wenb_n_sensor_fifo;
       wire [4:0] 		comp_scheme;
       wire       		comp_en;
       wire [11:0] 		Xdeco12_2_monitor; 
       wire [9:0]  		Xdeco10_2_monitor;
       wire        		dec_2_monitor;
       wire 		        dec_10_bit;
       wire 		        dec_12_bit;
       wire 		        sig_hrst_n;
       wire                     eot_handle;
       wire                     force_control_error;

       wire [7:0]               txreadyhs;
       wire [7:0]               txulpsesc_exit;
       wire [7:0]               txulpsesc_entry;
       wire [7:0]               txrequestesc;
       wire [7:0]               txrequesths;
       wire [7:0]               csi1_rxvalidhs;
       wire [63:0]              txdatahs;
       wire [63:0]              csi1_rxdatahs;
       wire [31:0]              dfe_dln_reg_0;
       wire [31:0]              dfe_dln_reg_1;
       wire [31:0]              dfe_cln_reg_0;
       wire [31:0]              dfe_cln_reg_1;
       wire [7:0]               csi1_stopstate_s;
       wire [7:0]               cln_cnt_hs_prep                                        ;
       wire [7:0]               cln_cnt_hs_zero                                        ;
       wire [7:0]               cln_cnt_hs_trail                                       ;
       wire [7:0]               cln_cnt_hs_exit                                        ;
       wire [7:0]               cln_cnt_lpx                                            ;
       wire [7:0]               dln_cnt_hs_prep                                        ;
       wire [7:0]               dln_cnt_hs_zero                                        ;
       wire [7:0]               dln_cnt_hs_trail                                       ;
       wire [7:0]               dln_cnt_hs_exit                                        ;
       wire [7:0]               dln_cnt_lpx                                            ;
       wire [7:0]               csi1_rxdatahs_0                                        ;
       wire [7:0]               csi1_rxdatahs_1                                        ;
       wire [7:0]               csi1_rxdatahs_2                                        ;
       wire [7:0]               csi1_rxdatahs_3                                        ;
       wire [7:0]               csi1_rxdatahs_4                                        ;
       wire [7:0]               csi1_rxdatahs_5                                        ;
       wire [7:0]               csi1_rxdatahs_6                                        ;
       wire [7:0]               csi1_rxdatahs_7                                        ;
       wire                     csi1_rxvalidhs_0                                       ;
       wire                     csi1_rxvalidhs_1                                       ;
       wire                     csi1_rxvalidhs_2                                       ;
       wire                     csi1_rxvalidhs_3                                       ;
       wire                     csi1_rxvalidhs_4                                       ;
       wire                     csi1_rxvalidhs_5                                       ;
       wire                     csi1_rxvalidhs_6                                       ;
       wire                     csi1_rxvalidhs_7                                       ;
       wire  [7:0]              tx_skewcallhs                                          ;
       wire  [7:0]              ulpsactivenot_n                                        ;
       wire                     force_error_esc                                        ;
       wire                     ulpsactivenot_0_n                                      ;
       wire                     ulpsactivenot_1_n                                      ;
       wire                     ulpsactivenot_2_n                                      ;
       wire                     ulpsactivenot_3_n                                      ;
       wire                     ulpsactivenot_4_n                                      ;
       wire                     ulpsactivenot_5_n                                      ;
       wire                     ulpsactivenot_6_n                                      ;
       wire                     ulpsactivenot_7_n                                      ;
       wire             assertion_err_flg                                      ;

       integer           temp_end                                               ;


  assign ulpsactivenot_n[7:0] = {ulpsactivenot_7_n,ulpsactivenot_6_n,ulpsactivenot_5_n,
                                 ulpsactivenot_4_n,ulpsactivenot_3_n,ulpsactivenot_2_n,
                                 ulpsactivenot_1_n,ulpsactivenot_0_n};

  assign csi1_rxdatahs = {csi1_rxdatahs_7,csi1_rxdatahs_6,csi1_rxdatahs_5,csi1_rxdatahs_4,
                          csi1_rxdatahs_3,csi1_rxdatahs_2,csi1_rxdatahs_1,csi1_rxdatahs_0};
 
  assign csi1_rxvalidhs = {csi1_rxvalidhs_7,csi1_rxvalidhs_6,csi1_rxvalidhs_5,csi1_rxvalidhs_4,
                           csi1_rxvalidhs_3,csi1_rxvalidhs_2,csi1_rxvalidhs_1,csi1_rxvalidhs_0};

  assign dfe_dln_reg_0 = {dln_cnt_hs_trail,dln_cnt_hs_exit,dln_cnt_hs_prep,dln_cnt_hs_zero};

  assign dfe_cln_reg_0 = {cln_cnt_hs_trail,cln_cnt_hs_exit,cln_cnt_hs_prep,cln_cnt_hs_zero};

  assign dec_10_bit = (dec_2_monitor) && ((comp_scheme[2:0] == 3'b011) || 
                      (comp_scheme[2:0] == 3'b010) || (comp_scheme[2:0] == 3'b001));

  assign dec_12_bit = (dec_2_monitor) && ((comp_scheme[2:0] == 3'b110) ||
                      (comp_scheme[2:0] == 3'b101) || (comp_scheme[2:0] == 3'b100) );


csi2tx_mipi_top u_csi2tx_mipi_top
  (
       // Global Interface Signals
       .pwr_on_rst_n(processor_rst_n                                          ),
       .sysclk(hclk                                                           ),
       .test_mode(test_mode                                                   ),
       .txbyteclkhs(txbyteclkhs                                               ),
       .sensor_clk(clk_csi                                                    ),
       .txclkesc(txclkesc                                                     ),   
       // DPHY Interface signals
       .dfe_pll_locked(clk_generated                                          ),
       .txreadyhs(txreadyhs                                                   ),
       .stopstate(csi1_stopstate                                              ),
       .ulpsactivenot_clk_n(csi1_ulpsactivenot_clk                            ),
       .ulpsactivenot_n(ulpsactivenot_n                                       ),
       .stopstate_clk(stopstate_clk                                           ),
       .txrequesths_clk(txrequesths_clk                                       ),
       .txrequesths(txrequesths                                               ),
       .txdatahs(txdatahs                                                     ),
       .txulpsesc_entry(txulpsesc_entry                                       ),
       .txulpsesc_entry_clk(txulpsesc_entry_clk                               ),           
       .txulpsesc_exit(txulpsesc_exit                                         ),
       .txulpsesc_exit_clk(txulpsesc_exit_clk                                 ),
       .txrequestesc(txrequestesc                                             ),   
       .txskewcalhs(tx_skewcallhs                                             ), 
       // DPHY configuration interface signals
       .afe_trim_0(                                                           ),
       .afe_trim_1(                                                           ),
       .afe_trim_2(                                                           ),
       .afe_trim_3(                                                           ),
       .dfe_dln_reg_0(dfe_dln_reg_0                                           ),
       .dfe_dln_reg_1(                                                        ),
       .dfe_cln_reg_0(dfe_cln_reg_0                                           ),
       .dfe_cln_reg_1(                                                        ),
       .pll_cnt_reg(                                                          ),
       .dfe_dln_lane_swap(                                                    ),     
       // AHB Interface signals
       .hwrite(sig_hwrite1                                                    ),
       .hsel(sig_hsel2                                                        ),
       .hready_in(t_hready_in                                                 ),
       .haddr(sig_haddr1                                                      ),
       .hsize(sig_hsize1                                                      ),
       .hburst(sig_hburst1                                                    ),
       .htrans(sig_htrans1                                                    ),
       .hwdata(sig_hwdata1                                                    ),
       .hrdata(sig_hrdata                                                     ),  
       .hresp(sig_hresp2                                                      ),
       .hready(sig_hready_mux                                                 ),      
       // Camera sensor Interface signals
       .frame_start(fs                                                        ),
       .frame_end(fe                                                          ),
       .line_start(ls                                                         ),
       .line_end(le                                                           ),
       .packet_header_valid(packet_valid                                      ),
       .virtual_channel(packet_vc                                             ),
       .data_type(packet_dt                                                   ),
       .word_count(packet_wc_df                                               ),
       .pixel_data_valid(pixel_valid                                          ),
       .pixel_data(packet_data                                                ),
       .packet_header_accept(packet_rdy                                       ),
       .pixel_data_accept(packet_data_rdy                                     ),   
       // MIPI Control signals
       .forcetxstopmode(forcetxstopmode_csi                                   ),
       .txulpsesc(txulpsesc                                                   ),
       .txulpsexit(txulpsexit                                                 ),
       .dphy_clk_mode(dphy_clk_mode                                           ),
       .loopback_sel(loopback_sel                                             ), 
       .dphy_calib_ctrl(tx_skew_calib                                        ),  
       //Camera Sensor Buffer
       .rd_data_sensor_fifo(rd_data_sensor_fifo                               ),
       .cena_n_sensor_fifo(cena_n_sensor_fifo                                 ),
       .wena_n_sensor_fifo(wena_n_sensor_fifo                                 ),
       .wr_addr_sensor_fifo(wr_addr_sensor_fifo                               ),
       .rd_addr_sensor_fifo(rd_addr_sensor_fifo                               ),
       .wr_data_sensor_fifo(wr_data_sensor_fifo                               ),
       .cenb_n_sensor_fifo(cenb_n_sensor_fifo                                 ),
       .wenb_n_sensor_fifo(wenb_n_sensor_fifo                                 )       
);


 csi2tx_dphy_afe_dfe_top u_csi2tx_dphy_afe_dfe_top_inst(
     .rst_n                   (processor_rst_n                                ), 
     .txclkesc                (txclkesc                                       ),
     .txddrclkhs_i            (txddrclkhs_i                                   ),
     .txddrclkhs_q            (txddrclkhs_q                                   ),
     .forcerxmode             (1'b0                                           ),
     .forcetxstopmode         (forcetxstopmode_csi                            ),
     .turndisable_0           (1'b0                                           ),
     .txulpsexit_0            (txulpsesc_exit[0]                              ),
     .txrequesths_0           (txrequesths[0]                                 ),
     .tx_skewcallhs           (tx_skewcallhs                                  ),
     .txdatahs_0              (txdatahs[7:0]                                  ),
     .turnrequest_0           (1'b0                                           ),
     .txrequestesc_0          (txrequestesc[0]                                ),
     .txlpdtesc_0             (1'b0                                           ),
     .txulpsesc_0             (txulpsesc_entry[0]                             ),
     .txtriggeresc_0          (4'h0                                           ),
     .txdataesc_0             (8'h0                                           ),
     .txvalidesc_0            (1'b0                                           ),
     .lp_cd_d0_0              (1'b0                                           ),
     .lp_cd_d1_0              (1'b0                                           ),
     .sot_sequence            (6'b0                                           ), 
     .force_sot_error         (1'b0                                           ),  
     .force_control_error     (force_control_error                            ),
     .force_error_esc         (force_error_esc                                ),
     .turndisable_1           (1'b0                                           ),
     .txulpsexit_1            (txulpsesc_exit[1]                              ),
     .txrequesths_1           (txrequesths[1]                                 ),
     .txdatahs_1              (txdatahs[15:8]                                 ),
     .turnrequest_1           (1'b0                                           ),
     .txrequestesc_1          (txrequestesc[1]                                ),
     .txlpdtesc_1             (1'b0                                           ),
     .txulpsesc_1             (txulpsesc_entry[1]                             ),
     .txtriggeresc_1          (4'h0                                           ),
     .txdataesc_1             (8'h0                                           ),
     .txvalidesc_1            (1'b0                                           ),
     .lp_cd_d0_1              (1'b0                                           ),
     .lp_cd_d1_1              (1'b0                                           ),
     
     .turndisable_2           (1'b0                                           ),
     .txulpsexit_2            (txulpsesc_exit[2]                              ),
     .txrequesths_2           (txrequesths[2]                                 ),
     .txdatahs_2              (txdatahs[23:16]                                ),
     .turnrequest_2           (1'b0                                           ),
     .txrequestesc_2          (txrequestesc[2]                                ),
     .txlpdtesc_2             (1'b0                                           ),
     .txulpsesc_2             (txulpsesc_entry[2]                             ),
     .txtriggeresc_2          (4'h0                                           ),
     .txdataesc_2             (8'h0                                           ),
     .txvalidesc_2            (1'b0                                           ),
     .lp_cd_d0_2              (1'b0                                           ),
     .lp_cd_d1_2              (1'b0                                           ),
     
     .turndisable_3           (1'b0                                           ),
     .txulpsexit_3            (txulpsesc_exit[3]                              ),
     .txrequesths_3           (txrequesths[3]                                 ),
     .txdatahs_3              (txdatahs[31:24]                                ),
     .turnrequest_3           (1'b0                                           ),
     .txrequestesc_3          (txrequestesc[3]                                ),
     .txlpdtesc_3             (1'b0                                           ),
     .txulpsesc_3             (txulpsesc_entry[3]                             ),
     .txtriggeresc_3          (4'h0                                           ),
     .txdataesc_3             (8'h0                                           ),
     .txvalidesc_3            (1'b0                                           ),
     .lp_cd_d0_3              (1'b0                                           ),
     .lp_cd_d1_3              (1'b0                                           ),
   
     .turndisable_4           (1'b0                                           ),
     .txulpsexit_4            (txulpsesc_exit[4]                              ),
     .txrequesths_4           (txrequesths[4]                                 ),
     .txdatahs_4              (txdatahs[39:32]                                ),
     .turnrequest_4           (1'b0                                           ),
     .txrequestesc_4          (txrequestesc[4]                                ),
     .txlpdtesc_4             (1'b0                                           ),
     .txulpsesc_4             (txulpsesc_entry[4]                             ),
     .txtriggeresc_4          (4'h0                                           ),
     .txdataesc_4             (8'h0                                           ),
     .txvalidesc_4            (1'b0                                           ),
     .lp_cd_d0_4              (1'b0                                           ),
     .lp_cd_d1_4              (1'b0                                           ),

     .turndisable_5           (1'b0                                           ),
     .txulpsexit_5            (txulpsesc_exit[5]                              ),
     .txrequesths_5           (txrequesths[5]                                 ),
     .txdatahs_5              (txdatahs[47:40]                                ),
     .turnrequest_5           (1'b0                                           ),
     .txrequestesc_5          (txrequestesc[5]                                ),
     .txlpdtesc_5             (1'b0                                           ),
     .txulpsesc_5             (txulpsesc_entry[5]                             ),
     .txtriggeresc_5          (4'h0                                           ),
     .txdataesc_5             (8'h0                                           ),
     .txvalidesc_5            (1'b0                                           ),
     .lp_cd_d0_5              (1'b0                                           ),
     .lp_cd_d1_5              (1'b0                                           ),

     .turndisable_6           (1'b0                                           ),
     .txulpsexit_6            (txulpsesc_exit[6]                              ),
     .txrequesths_6           (txrequesths[6]                                 ),
     .txdatahs_6              (txdatahs[55:48]                                ),
     .turnrequest_6           (1'b0                                           ),
     .txrequestesc_6          (txrequestesc[6]                                ),
     .txlpdtesc_6             (1'b0                                           ),
     .txulpsesc_6             (txulpsesc_entry[6]                             ),
     .txtriggeresc_6          (4'h0                                           ),
     .txdataesc_6             (8'h0                                           ),
     .txvalidesc_6            (1'b0                                           ),
     .lp_cd_d0_6              (1'b0                                           ),
     .lp_cd_d1_6              (1'b0                                           ),

     .turndisable_7           (1'b0                                           ),
     .txulpsexit_7            (txulpsesc_exit[7]                              ),
     .txrequesths_7           (txrequesths[7]                                 ),
     .txdatahs_7              (txdatahs[63:56]                                ),
     .turnrequest_7           (1'b0                                           ),
     .txrequestesc_7          (txrequestesc[7]                                ),
     .txlpdtesc_7             (1'b0                                           ),
     .txulpsesc_7             (txulpsesc_entry[7]                             ),
     .txtriggeresc_7          (4'h0                                           ),
     .txdataesc_7             (8'h0                                           ),
     .txvalidesc_7            (1'b0                                           ),
     .lp_cd_d0_7              (1'b0                                           ),
     .lp_cd_d1_7              (1'b0                                           ),
 
     .txulpsexit_clk          (txulpsesc_exit_clk                             ),
     .txrequesths_clk         (txrequesths_clk                                ),
     .txulpsclk               (txulpsesc_entry_clk                            ),
     .eot_handle_proc         (eot_handle                                     ),
     .cln_cnt_hs_prep         (dfe_cln_reg_0[15:8]                            ),
     .cln_cnt_hs_zero         (dfe_cln_reg_0[7:0]                             ),
     .cln_cnt_hs_trail        (dfe_cln_reg_0[31:24]                           ),
     .cln_cnt_hs_exit         (dfe_cln_reg_0[23:16]                           ),
     .cln_cnt_lpx             (dfe_cln_reg_1[7:0]                             ),
     .dln_cnt_hs_prep         (dfe_dln_reg_0[15:8]                            ),
     .dln_cnt_hs_zero         (dfe_dln_reg_0[7:0]                             ),
     .dln_cnt_hs_trail        (dfe_dln_reg_0[31:24]                           ),
     .dln_cnt_hs_exit         (dfe_dln_reg_0[23:16]                           ),
     .dln_cnt_lpx             (dfe_dln_reg_1[7:0]                             ),
     .txreadyhs_0             (txreadyhs[0]                                   ),
     .txreadyesc_0            (                                               ),
     .direction_0             (                                               ),
     .errcontentionlp0_0      (                                               ),
     .errcontentionlp1_0      (                                               ),
     .rxactivehs_0            (csi1_rxactivehs_0                              ),
     .rxdatahs_0              (csi1_rxdatahs_0                                ),
     .rxvalidhs_0             (csi1_rxvalidhs_0                               ),
     .rxsynchs_0              (csi1_rxsynchs_0                                ),
     .rxskewcallhs_0          (csi1_rxskewcallhs_0                            ),
     .rxdataesc_0             (                                               ),
     .rxvalidesc_0            (                                               ),
     .rxtriggeresc_0          (                                               ),
     .rxulpsesc_0             (csi1_rxulpsesc_0                               ),
     .rxlpdtesc_0             (csi1_rxlpdtesc_0                               ),
     .errsoths_0              (csi1_errsoths_0                                ),
     .errsotsynchs_0          (csi1_errsotsynchs_0                            ),
     .erresc_0                (csi1_erresc_0                                  ),
     .errsyncesc_0            (                                               ),
     .errcontrol_0            (csi1_errcontrol_0                              ),
     .ulpsactivenot_0_n       (ulpsactivenot_0_n                              ),
                                                                              
     .txreadyhs_1             (txreadyhs[1]                                   ),
     .txreadyesc_1            (                                               ),
     .direction_1             (                                               ),
     .errcontentionlp0_1      (                                               ),
     .errcontentionlp1_1      (                                               ),
     .rxactivehs_1            (csi1_rxactivehs_1                              ),
     .rxdatahs_1              (csi1_rxdatahs_1                                ),
     .rxvalidhs_1             (csi1_rxvalidhs_1                               ),
     .rxsynchs_1              (csi1_rxsynchs_1                                ),
     .rxskewcallhs_1          (csi1_rxskewcallhs_1                            ),
     .rxdataesc_1             (                                               ),
     .rxvalidesc_1            (                                               ),
     .rxtriggeresc_1          (                                               ),
     .rxulpsesc_1             (csi1_rxulpsesc_1                               ),
     .rxlpdtesc_1             (csi1_rxlpdtesc_1                               ),
     .errsoths_1              (csi1_errsoths_1                                ),
     .errsotsynchs_1          (csi1_errsotsynchs_1                            ),
     .erresc_1                (csi1_erresc_1                                  ),
     .errsyncesc_1            (                                               ),
     .errcontrol_1            (csi1_errcontrol_1                              ),
     .ulpsactivenot_1_n       (ulpsactivenot_1_n                              ),
     
     .txreadyhs_2             (txreadyhs[2]                                   ),
     .txreadyesc_2            (                                               ),
     .direction_2             (                                               ),
     .errcontentionlp0_2      (                                               ),
     .errcontentionlp1_2      (                                               ),
     .rxactivehs_2            (csi1_rxactivehs_2                              ),
     .rxdatahs_2              (csi1_rxdatahs_2                                ),
     .rxvalidhs_2             (csi1_rxvalidhs_2                               ),
     .rxsynchs_2              (csi1_rxsynchs_2                                ),
     .rxskewcallhs_2          (csi1_rxskewcallhs_2                            ),
     .rxdataesc_2             (                                               ),
     .rxvalidesc_2            (                                               ),
     .rxtriggeresc_2          (                                               ),
     .rxulpsesc_2             (csi1_rxulpsesc_2                               ),
     .rxlpdtesc_2             (csi1_rxlpdtesc_2                               ),
     .errsoths_2              (csi1_errsoths_2                                ),
     .errsotsynchs_2          (csi1_errsotsynchs_2                            ),
     .erresc_2                (csi1_erresc_2                                  ),
     .errsyncesc_2            (                                               ),
     .errcontrol_2            (csi1_errcontrol_2                              ),
     .ulpsactivenot_2_n       (ulpsactivenot_2_n                              ),
   
     .txreadyhs_3             (txreadyhs[3]                                   ),
     .txreadyesc_3            (                                               ),
     .direction_3             (                                               ),
     .errcontentionlp0_3      (                                               ),
     .errcontentionlp1_3      (                                               ),
     .rxactivehs_3            (csi1_rxactivehs_3                              ),
     .rxdatahs_3              (csi1_rxdatahs_3                                ),
     .rxvalidhs_3             (csi1_rxvalidhs_3                               ),
     .rxsynchs_3              (csi1_rxsynchs_3                                ),                                             
     .rxskewcallhs_3          (csi1_rxskewcallhs_3                            ),
     .rxdataesc_3             (                                               ),
     .rxvalidesc_3            (                                               ),
     .rxtriggeresc_3          (                                               ),
     .rxulpsesc_3             (csi1_rxulpsesc_3                               ),
     .rxlpdtesc_3             (csi1_rxlpdtesc_3                               ),
     .errsoths_3              (csi1_errsoths_3                                ),
     .errsotsynchs_3          (csi1_errsotsynchs_3                            ),
     .erresc_3                (csi1_erresc_3                                  ),
     .errsyncesc_3            (                                               ),
     .errcontrol_3            (csi1_errcontrol_3                              ),
     .ulpsactivenot_3_n       (ulpsactivenot_3_n                              ),

     .txreadyhs_4             (txreadyhs[4]                                   ),
     .txreadyesc_4            (                                               ),
     .direction_4             (                                               ),
     .errcontentionlp0_4      (                                               ),
     .errcontentionlp1_4      (                                               ),
     .rxactivehs_4            (csi1_rxactivehs_4                              ),
     .rxdatahs_4              (csi1_rxdatahs_4                                ),
     .rxvalidhs_4             (csi1_rxvalidhs_4                               ),
     .rxsynchs_4              (csi1_rxsynchs_4                                ),
     .rxskewcallhs_4          (csi1_rxskewcallhs_4                            ),
     .rxdataesc_4             (                                               ),
     .rxvalidesc_4            (                                               ),
     .rxtriggeresc_4          (                                               ),
     .rxulpsesc_4             (csi1_rxulpsesc_4                               ),
     .rxlpdtesc_4             (csi1_rxlpdtesc_4                               ),
     .errsoths_4              (csi1_errsoths_4                                ),
     .errsotsynchs_4          (csi1_errsotsynchs_4                            ),
     .erresc_4                (csi1_erresc_4                                  ),
     .errsyncesc_4            (                                               ),
     .errcontrol_4            (csi1_errcontrol_4                              ),
     .ulpsactivenot_4_n       (ulpsactivenot_4_n                              ),

     .txreadyhs_5             (txreadyhs[5]                                   ),
     .txreadyesc_5            (                                               ),
     .direction_5             (                                               ),
     .errcontentionlp0_5      (                                               ),
     .errcontentionlp1_5      (                                               ),
     .rxactivehs_5            (csi1_rxactivehs_5                              ),
     .rxdatahs_5              (csi1_rxdatahs_5                                ),
     .rxvalidhs_5             (csi1_rxvalidhs_5                               ),
     .rxsynchs_5              (csi1_rxsynchs_5                                ),
     .rxskewcallhs_5          (csi1_rxskewcallhs_5                            ),
     .rxdataesc_5             (                                               ),
     .rxvalidesc_5            (                                               ),
     .rxtriggeresc_5          (                                               ),
     .rxulpsesc_5             (csi1_rxulpsesc_5                               ),
     .rxlpdtesc_5             (csi1_rxlpdtesc_5                               ),
     .errsoths_5              (csi1_errsoths_5                                ),
     .errsotsynchs_5          (csi1_errsotsynchs_5                            ),
     .erresc_5                (csi1_erresc_5                                  ),
     .errsyncesc_5            (                                               ),
     .errcontrol_5            (csi1_errcontrol_5                              ),
     .ulpsactivenot_5_n       (ulpsactivenot_5_n                              ),

     .txreadyhs_6             (txreadyhs[6]                                   ),
     .txreadyesc_6            (                                               ),
     .direction_6             (                                               ),
     .errcontentionlp0_6      (                                               ),
     .errcontentionlp1_6      (                                               ),
     .rxactivehs_6            (csi1_rxactivehs_6                              ),
     .rxdatahs_6              (csi1_rxdatahs_6                                ),
     .rxvalidhs_6             (csi1_rxvalidhs_6                               ),
     .rxsynchs_6              (csi1_rxsynchs_6                                ),
     .rxskewcallhs_6          (csi1_rxskewcallhs_6                            ),
     .rxdataesc_6             (                                               ),
     .rxvalidesc_6            (                                               ),
     .rxtriggeresc_6          (                                               ),
     .rxulpsesc_6             (csi1_rxulpsesc_6                               ),
     .rxlpdtesc_6             (csi1_rxlpdtesc_6                               ),
     .errsoths_6              (csi1_errsoths_6                                ),
     .errsotsynchs_6          (csi1_errsotsynchs_6                            ),
     .erresc_6                (csi1_erresc_6                                  ),
     .errsyncesc_6            (                                               ),
     .errcontrol_6            (csi1_errcontrol_6                              ),
     .ulpsactivenot_6_n       (ulpsactivenot_6_n                              ),

     .txreadyhs_7             (txreadyhs[7]                                   ),
     .txreadyesc_7            (                                               ),
     .direction_7             (                                               ),
     .errcontentionlp0_7      (                                               ),
     .errcontentionlp1_7      (                                               ),
     .rxactivehs_7            (csi1_rxactivehs_7                              ),
     .rxdatahs_7              (csi1_rxdatahs_7                                ),
     .rxvalidhs_7             (csi1_rxvalidhs_7                               ),
     .rxsynchs_7              (csi1_rxsynchs_7                                ),
     .rxskewcallhs_7          (csi1_rxskewcallhs_7                            ),
     .rxdataesc_7             (                                               ),
     .rxvalidesc_7            (                                               ),
     .rxtriggeresc_7          (                                               ),
     .rxulpsesc_7             (csi1_rxulpsesc_7                               ),
     .rxlpdtesc_7             (csi1_rxlpdtesc_7                               ),
     .errsoths_7              (csi1_errsoths_7                                ),
     .errsotsynchs_7          (csi1_errsotsynchs_7                            ),
     .erresc_7                (csi1_erresc_7                                  ),
     .errsyncesc_7            (                                               ),
     .errcontrol_7            (csi1_errcontrol_7                              ),
     .ulpsactivenot_7_n       (ulpsactivenot_7_n                              ),

     .csi1_stopstate_m        (csi1_stopstate                                 ),
     .csi1_stopstate_s        (csi1_stopstate_s                               ),
 
     .rxclkactivehs           (                                               ),
     .rxclkesc                (rxclkesc                                       ),
     .rxulpsclknot_n          (csi1_rxulpsclknot                              ),
     .ulpsactivenot_clk_n     (csi1_ulpsactivenot_clk                         ),
     .stopstate_clk           (stopstate_clk                                  ),
     .rxbyteclkhs             (csi1_rxbyteclkhs_n                             ),
     .txbyteclkhs             (txbyteclkhs                                    )
    
    
    );


    csi2tx_RA2SD1024x64 u_csi2tx_RA2SD1024x64
    (
       .QA(/* open*/                                                          ),
       .CLKA(clk_csi                                                          ),
       .CENA_N(cena_n_sensor_fifo                                             ),
       .WENA_N(wena_n_sensor_fifo                                             ),
       .AA(wr_addr_sensor_fifo                                                ),
       .DA(wr_data_sensor_fifo                                                ),
       .QB(rd_data_sensor_fifo                                                ),
       .CLKB(txbyteclkhs                                                      ),
       .CENB_N(cenb_n_sensor_fifo                                             ),
       .WENB_N(wenb_n_sensor_fifo                                             ),
       .AB(rd_addr_sensor_fifo                                                ),
       .DB(64'b0                                                              )
 
      );


  csi2tx_pkt_interface_bfm u_csi2tx_pkt_interface_bfm_inst
  (
    .clk_csi            (clk_csi                                             ),
    .reset_clk_csi_n    (processor_rst_n                                  ),
    .packet_rdy         (packet_rdy                                          ),
    .packet_data_rdy    (packet_data_rdy                                     ), 
    .packet_valid       (packet_valid                                        ),
    .packet_vc          (packet_vc                                           ),
    .packet_dt          (packet_dt                                           ),
    .packet_data_valid  (pixel_valid                                         ),
    .packet_wc_df       (packet_wc_df                                        ),
    .csi_tx_pix_en      (csi_tx_pix_en                                       ),
    .reg_lane_cnt       (lane_count                                          ),
    .csi_end_of_file    (csi_end_of_file                                     ),
    .raw_data_out       (packet_data                                         ),
    .stopstate_dat_0    (csi1_stopstate[0]                                   ),
    .forcetxstopmode    (forcetxstopmode_csi                                 ),
    .txulpsesc          (txulpsesc                                           ),
    .dphy_clk_mode      (dphy_clk_mode                                       ),
    .loopack_sel        (loopback_sel                                        ),
    .txulpsexit         (txulpsexit                                          ),
    .master_pin         (master_pin                                          ),
    .pkt_drop_en        (pkt_drop_en                                         ),
    .pkt_sent           (pkt_sent                                            ),
    .odd_even_line      (odd_even_line                                       ),
    .tx_skewcallhs           (tx_skew_calib                                  ),
    .fs                 (fs                                                  ),
    .fe                 (fe                                                  ),
    .ls                 (ls                                                  ),
    .le                 (le                                                  ),
    .pixel_width        (pixel_width                                         ),
    .Xdeco10_2_monitor  (Xdeco10_2_monitor                                   ),
    .Xdeco12_2_monitor  (Xdeco12_2_monitor                                   ),
    .dec_2_monitor      (dec_2_monitor                                       ),
    .test_mode          (/*test_mode*/                                       ),
    .compression_en     (comp_en                                             ),
    .csi_clk_freq       (clk_csi_freq                                        ),
    .raw_image_data_type(raw_image_data_type                                 ),
    .rgb_image_data_type(rgb_image_data_type                                 ),
    .usd_data_type_reg(usd_data_type_reg                                     ),
    .generic_8_bit_long_pkt_data_type(generic_8_bit_long_pkt_data_type       ),
    .yuv_image_data_type(yuv_image_data_type                                 ),
    .comp_scheme        (comp_scheme                                         )
   );
         

    csi2tx_clk_gen u_csi2tx_clk_gen_inst(
    .pixel_width(pixel_width                                                 ),
    .ahb_hrst_n(reset_clk_csi_n                                              ),
    .ci_clk(clk_csi                                                          ),
    .hclk(hclk                                                               ),
    .txclkesc(txclkesc                                                       ),
    .txddr_clk_q(txddrclkhs_q                                                ),
    .txddr_clk_i(txddrclkhs_i                                                ),
    .clk_generated(clk_generated                                             ),
    .ci_clk_time(                                                            ),
    .ddr_clk_time(                                                           )
    );


csi2tx_ahb_master_model u_csi2tx_ahb_master_model_inst(
    .hclk(hclk                                                               ),
    .processor_rst_n(processor_rst_n                                   ),
    .hresetn(reset_clk_csi_n                                                      ),
    .hrdata(sig_hrdata                                                       ),
    .hready(t_hready_in                                                      ),
    .hgrant1(sig_hgrant1                                                     ),
    .hresp(sig_hresp                                                         ),
    .hbusreq1(sig_hbusreq1                                                   ),
    .hwrite1(sig_hwrite1                                                     ),
    .htrans1(sig_htrans1                                                     ),
    .haddr1(sig_haddr1                                                       ),
    .hwdata1(sig_hwdata1                                                     ),
    .test_mode(test_mode                                                     ),
    .hsize1(sig_hsize1                                                       ),
    .lane_count_out(lane_count                                               ),
    .clk_csi_freq(                                                           ),
    .hburst1(sig_hburst1                                                     ),
    .delay_val(sig_delay_val                                                 ),
    .err_status(err_status                                                   ),
    .raw_image_data_type(raw_image_data_type                                 ),
    .rgb_image_data_type(rgb_image_data_type                                 ),
    .usd_data_type_reg(usd_data_type_reg                                     ),
    .generic_8_bit_long_pkt_data_type(generic_8_bit_long_pkt_data_type       ),
    .yuv_image_data_type(yuv_image_data_type                                 ),
    .end_ahb(sig_end_file2                                                   )
);



  //ahb decoder model
  csi2tx_ahb_decoder u_csi2tx_ahb_decoder_inst
    (
    .haddr(sig_haddr1                                                        ),
    .hsel1(sig_hsel1                                                         ),
    .hsel2(sig_hsel2                                                         ),
    .hsel3(sig_hsel3                                                         )

    );


  //ahb arbiter model
  csi2tx_ahb_arbiter_model u_csi2tx_ahb_arbiter_inst
    (
    //INPUTS
    .hclk(hclk                                                               ),
    .hresetn(reset_clk_csi_n                                                      ),
    .hbusreq1(sig_hbusreq1                                                   ),
    .hbusreq2(1'b0                                                           ),
    .haddr(sig_haddr                                                         ),
    .hlock2(1'b0                                                             ),
    .hready(t_hready_in                                                      ),
    .hburst(sig_hburst                                                       ),
    .hsize(sig_hsize                                                         ),
    .htrans(sig_htrans                                                       ),
    .delay_val(sig_delay_val                                                 ),
    .trans_no(8'h0                                                           ),
    .error_type(2'h0                                                         ),
    //OUTPUTS
    .hgrant1 (sig_hgrant1                                                    ),
    .hgrant2(sig_hgrant2                                                     ),
    .hmaster(sig_hmaster                                                     )

    );


   // AHB multiplexer model
  csi2tx_ahb_mux_mod u_csi2tx_ahb_mux_mod_inst
    (
    //INPUTS
    .hclk(hclk                                                               ),
    .hresetn(reset_clk_csi_n                                                      ),
    .hwrite1(sig_hwrite1                                                     ),
    .htrans1(sig_htrans1                                                     ),
    .haddr1(sig_haddr1                                                       ),
    .hwdata1(sig_hwdata1                                                     ),
    .hsize1(3'b0                                                             ),
    .hburst1(sig_hburst1                                                     ),
    .hgrant2(sig_hgrant2                                                     ),
    .hwrite2(1'b0                                                            ),
    .htrans2(2'b0                                                            ),
    .haddr2(32'b0                                                            ),
    .hwdata2(32'b0                                                           ),
    .hsize2(sig_hsize1                                                       ),
    .hburst2(3'b0                                                            ),
    .hready1(1'b1                                                            ),
    .hresp1(2'b0                                                             ),
    .hrdata1(32'b0                                                           ),
    .hready2(sig_hready_mux                                                  ),
    .hresp2(sig_hresp2                                                       ),
    .hrdata2(sig_hrdata2                                                     ),
    .hready3(1'b1                                                            ),
    .hresp3(2'b0                                                             ),
    .hrdata3(32'b0                                                           ),
    .hsel1(1'b0                                                              ),
    .hsel2(sig_hsel2                                                         ),
    .hmaster(sig_hmaster                                                     ),
    //OUTPUTS
    .hwrite (sig_hwrite                                                      ),
    .htrans(sig_htrans                                                       ),
    .haddr (sig_haddr                                                        ),
    .hwdata(sig_hwdata                                                       ),
    .hsize(sig_hsize                                                         ),
    .hburst(sig_hburst                                                       ),
    .hready(t_hready_in                                                      ),
    .hresp(sig_hresp                                                         ),
    .hrdata(sig_hrdata                                                       )
    );

 csi2tx_monitor u_csi2tx_monitor_inst(   
    .clk_csi(clk_csi                                                         ),
    .drop_pkt_en(pkt_drop_en                                                 ),
    .reset_clk_csi_n(processor_rst_n & ~pkt_drop_en                          ),
    .packet_vc(packet_vc                                                     ),
    .packet_dt(packet_dt                                                     ),
    .packet_wc_df(packet_wc_df                                               ),
    .odd_even_line(odd_even_line                                             ),
    .packet_data_rdy(packet_data_rdy                                         ),
    .packet_rdy(packet_rdy                                                   ),
    .packet_data(packet_data                                                 ),
    .fs(fs                                                                   ),
    .fe(fe                                                                   ),
    .ls(ls                                                                   ),
    .le(le                                                                   ), 
    .forcetxstopmode(forcetxstopmode_csi                                     ),

    .Xdeco10             (Xdeco10_2_monitor                                  ),
    .Xdeco12             (Xdeco12_2_monitor                                  ),   
    .comp_en             (comp_en                                            ),
    .dec_10_bit          (dec_10_bit                                         ),
    .dec_12_bit          (dec_12_bit                                         ),
    .dec_op              (rxbfm_comp_data                                    ),
    .dec_op_vld          (rxbfm_comp_en                                      ),

    .csi_long_pkt_data(rxbfm_mon_pixeldata                                   ),
    .csi_long_pkt_data_en(rxbfm_mon_pixelen                                  ),
    .csi_header_en(rxbfm_mon_headeren                                        ),
    .csi_header_data(rxbfm_mon_headerdata                                    ),
    .yuv_image_data_type(yuv_image_data_type                                 ),
    .raw_image_data_type(raw_image_data_type                                 ),
    .usd_data_type_reg(usd_data_type_reg                                     ),
    .rgb_image_data_type(rgb_image_data_type                                 ),
    .generic_8_bit_long_pkt_data_type(generic_8_bit_long_pkt_data_type       ),  
     //PRIMARY OUTPUTS
    .err_flg(err_monitor                                                     ),
    .end_monitor(end_monitor                                                 )
   );



csi2rx_bfm u_csi2rx_bfm_inst(
    // input signals
    .byteclkhs(csi1_rxbyteclkhs_n                                            ), 
    .byteclkhs_rst_n(processor_rst_n                                         ), 
    .rxdphy_rxbfm_validhs(csi1_rxvalidhs                                     ), 
    .rxdphy_rxbfm_datahs(csi1_rxdatahs                                       ), 
    .ahb_rxbfm_lane_cnt(lane_count                                           ), 
    .ahb_rxbfm_pixel_mode(                                                   ),  
    // output signals
    .rxbfm_mon_pixeldata(rxbfm_mon_pixeldata                                 ), 
    .rxbfm_mon_pixelen(rxbfm_mon_pixelen                                     ), 
    .rxbfm_mon_headerdata(rxbfm_mon_headerdata                               ), 
    .rxbfm_mon_headeren(rxbfm_mon_headeren                                   ),
    .rxbfm_comp_data(rxbfm_comp_data                                         ), 
    .rxbfm_comp_en(rxbfm_comp_en                                             ),  
    .error_rxbfm(err_rxbfm                                                   ),               
    .end_rxbfm(rxer_end                                                      )                       
   );

  csi2tx_assertion u_csi2tx_assertion_inst           (
            .assertion_err_flg         (assertion_err_flg                      )
            );

   assign end_all = (csi_end_of_file && rxer_end && end_monitor && sig_end_file2 );
  
 `ifdef MON_DIS 
    assign err_flg =  loopback_sel ? (err_lp_rxer) : (err_phy_1 || err_phy_2 || err_phy_3 || err_phy_4);
  `else
    assign err_flg =  loopback_sel ? (err_lp_rxer || err_monitor) : (err_rxbfm || err_monitor || err_status || assertion_err_flg);
  `endif
  


  always @(csi_end_of_file or rxer_end or end_all)
    begin
      if(csi_end_of_file && rxer_end && end_all) begin
        `ifdef TIMESCALE_NS
        #10000;
        `else
        #10000000;
        `endif
        
        if(!err_flg) begin
          $display("TEST PASSED");
        end else begin
          $display("TEST FAILED");
        end
          
        `ifdef TIMESCALE_NS
        #100;
        `else
        #100000;
        `endif
        $finish;
      end
    end

   always@(err_flg)
     begin
       #100000;
       if(err_flg) begin
         $display("\n TEST FAILED \n");
         $finish;
       end
     end
 
  initial
    begin
    `ifdef VCD_EN
      $dumpfile("csi_tx.vcd");
      $dumpvars(0,test_env);
    `endif
   `ifdef DUMP_EN
      $dumpvars;
   `endif
    end

  always@(*)
    begin
      for(temp_end = 0; temp_end < 32'd100000; temp_end = temp_end + 1) begin
        if(txrequesths[0] == 1) begin 
          temp_end = 0;
          @(posedge txbyteclkhs);
        end else begin
          @(posedge txbyteclkhs);
        end
      end
      $display("\n TEST HANGED \n");
      $finish;
    end

endmodule

