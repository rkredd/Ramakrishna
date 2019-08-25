/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi_tx_assertion.sv
// Author      : Pramod Kumar B R
// Version     : v1p2
// Abstract    : This module is used for protocol checking 
//
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/

`timescale 1 ps / 1 ps
module csi2tx_assertion(
    output reg assertion_err_flg
   );

  /*----------------------------------------------------------------------------
    Internal register declaration
  ----------------------------------------------------------------------------*/
  wire           assert_txrequesths                                            ;
  wire           assert_txrequestesc                                           ;
  wire           assert_sensor_fifo_full                                       ;
  wire           assert_sensor_fifo_empty                                      ;
  wire           assert_sensor_fifo_wr_en                                      ;
  wire           assert_sensor_fifo_rd_en                                      ;
  
  /*----------------------------------------------------------------------------
    Intialization
  ----------------------------------------------------------------------------*/ 
  initial
    begin
      assertion_err_flg = 1'b0;
    end

  assign assert_txrequesths = (test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequesths_0 ||
                               test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequesths_1 ||
                               test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequesths_2 ||
                               test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequesths_3 ||
                               test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequesths_4 ||
                               test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequesths_5 ||
                               test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequesths_6 ||
                               test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequesths_7 );

  assign assert_txrequestesc = (test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequestesc_0 || 
                                test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequestesc_1 ||
                                test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequestesc_2 ||
                                test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequestesc_3 ||
                                test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequestesc_4 ||
                                test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequestesc_5 ||
                                test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequestesc_6 ||
                                test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txrequestesc_7 );


  assign assert_sensor_fifo_full  = test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_sensor_fifo_ctrl.fifo_full_wr_dm; 
  assign assert_sensor_fifo_wr_en = test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_sensor_fifo_ctrl.wr_en; 
  
  assign assert_sensor_fifo_empty = test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_sensor_fifo_ctrl.fifo_empty_rd_dm;
  assign assert_sensor_fifo_rd_en = test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_sensor_fifo_ctrl.rd_en;

  /*----------------------------------------------------------------------------
    Sensor FIFO FULL 
  ----------------------------------------------------------------------------*/
  property SENSOR_FIFO_FULL;
    @(posedge test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_sensor_fifo_ctrl.clk_wr)
    test_env.u_csi2tx_ahb_master_model_inst.init_enable == 1'b0 |-> 
    test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_sensor_fifo_ctrl.rst_wr_n |-> 
    assert_sensor_fifo_full != 1;
  endproperty

  SENSOR_FIFO_NEVER_FULL : assert property (SENSOR_FIFO_FULL)
    begin
      assertion_err_flg = 1'b0;
    end else begin
      $error($time,"\tASSERTION FAILED: SENSOR FIFO FULL\n");
      assertion_err_flg = 1'b1;
    end

  /*----------------------------------------------------------------------------
    Sensor FIFO OVERFLOW 
  ----------------------------------------------------------------------------*/
  property SENSOR_FIFO_OVERFLOW;
    @(posedge test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_sensor_fifo_ctrl.clk_wr)
    test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_sensor_fifo_ctrl.rst_wr_n |-> 
    test_env.u_csi2tx_ahb_master_model_inst.init_enable == 1'b0 |-> 
    ((assert_sensor_fifo_full != 0 && assert_sensor_fifo_wr_en != 1'b1) ||
     (assert_sensor_fifo_full != 1 && assert_sensor_fifo_wr_en != 1'b0) ||   
     (assert_sensor_fifo_full != 1 && assert_sensor_fifo_wr_en != 1'b1) );
  endproperty

  SENSOR_FIFO_NEVER_OVERFLOW : assert property (SENSOR_FIFO_OVERFLOW)
    begin
      assertion_err_flg = 1'b0;
    end else begin
      $error ($time,"\tASSERTION FAILED: SENSOR FIFO HAS HIT OVERFLOW CONDITION\n");
      assertion_err_flg = 1'b1;
    end

  /*----------------------------------------------------------------------------
    Sensor FIFO UNDERFLOW 
  ----------------------------------------------------------------------------*/
  property SENSOR_FIFO_UNDERFLOW;
    @(posedge test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_sensor_fifo_ctrl.clk_rd)
    test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_sensor_fifo_ctrl.rst_rd_n |->
    test_env.u_csi2tx_ahb_master_model_inst.init_enable == 1'b0 |->
    ((assert_sensor_fifo_empty != 1'b1 && assert_sensor_fifo_rd_en != 1'b0) ||
     (assert_sensor_fifo_empty != 1'b0 && assert_sensor_fifo_rd_en != 1'b1) ||
     (assert_sensor_fifo_empty != 1'b1 && assert_sensor_fifo_rd_en != 1'b1) );
  endproperty

  SENSOR_FIFO_NEVER_UNDERFLOW : assert property (SENSOR_FIFO_UNDERFLOW)
    begin
      assertion_err_flg = 1'b0;
    end else begin 
      assertion_err_flg = 1'b1;    
      $error ($time,"\tASSERTION FAILED: SENSOR FIFO HAS HIT UNDERFLOW CONDITION\n");
    end

  /*----------------------------------------------------------------------------
    Synchronous Register Buffer FULL
  ----------------------------------------------------------------------------*/
  property SYNC_REG_BUFF_FULL;
    @(posedge test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_llp_top.u_csi2tx_sync_reg_buffer.clk)
    test_env.u_csi2tx_ahb_master_model_inst.init_enable == 1'b0 |-> 
    test_env.u_csi2tx_mipi_top.u_csi2tx.u_csi2tx_llp_top.u_csi2tx_sync_reg_buffer.full != 1;
  endproperty

  SYNC_REG_BUFF_NEVER_FULL : assert property (SYNC_REG_BUFF_FULL)
    begin
      assertion_err_flg = 1'b0;
    end else begin
      assertion_err_flg = 1'b1;
      $error ($time,"\tASSERTION FAILED: SYNCHRONOUS REGISTER BUFFER FULL\n");
    end

  /*----------------------------------------------------------------------------
    TXREQUESTESC and TXREQUESTHS should not be high at same time
  ----------------------------------------------------------------------------*/
  property REQUESTESC_REQUESTHS;
    @(posedge test_env.u_csi2tx_dphy_afe_dfe_top_inst.u_csi2tx_dphy_tx_top_inst.txclkesc)
    test_env.u_csi2tx_ahb_master_model_inst.init_enable == 1'b0 |-> 
    ((assert_txrequesths == 1'b0 && assert_txrequestesc == 1'b0) || 
     (assert_txrequesths == 1'b1 && assert_txrequestesc == 1'b0) || 
     (assert_txrequesths == 1'b0 && assert_txrequestesc == 1'b1));
  endproperty

  REQUESTESC_REQUESTHS_NEVER_HIGH_SAME_TIME : assert property (REQUESTESC_REQUESTHS)
    begin
      assertion_err_flg = 1'b0;
    end else begin 
      assertion_err_flg = 1'b1;
      $error ($time,"\tASSERTION FAILED: TXREQUESTESC and TXREQUESTHS are high at same time\n");
    end


endmodule 
