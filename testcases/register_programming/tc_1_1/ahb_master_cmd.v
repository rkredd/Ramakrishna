task ahb_master_cmd;

   begin
      pre_initialize_test;
      
      pwr_on_rst_mipi;
      
      ui_value(ui);
      rd_lane_prog_reg(32'h00000007);
      rd_trim_reg_0(32'h00000C19);
      rd_trim_reg_1(32'h0935384C);
      rd_trim_reg_2(32'h00000000);
      rd_trim_reg_3(32'h02FC0000);
      rd_dphy_dfe_dln_reg_0(32'h0A0D0716);
      rd_dphy_dfe_dln_reg_1(32'h00061E07);
      rd_dphy_dfe_cln_reg_0(32'h080D0521);
      rd_dphy_dfe_cln_reg_1(32'h00000006);
      rd_dphy_ln_pol_swap_reg(32'h00000000);
      rd_pll_cnt_reg(32'h00000000);
      rd_fifo_status_reg(32'h00000009);
      rd_vc0_comp_pred_reg_1(32'h00000000);
      rd_vc0_comp_pred_reg_2(32'h00000000);
      rd_vc1_comp_pred_reg_1(32'h00000000);
      rd_vc1_comp_pred_reg_2(32'h00000000);
      rd_vc2_comp_pred_reg_1(32'h00000000);
      rd_vc2_comp_pred_reg_2(32'h00000000);
      rd_vc3_comp_pred_reg_1(32'h00000000);
      rd_vc3_comp_pred_reg_2(32'h00000000);
      
      end_cmd;

   end
endtask
