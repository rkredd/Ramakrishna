task ahb_master_cmd;
begin

   pre_initialize_test;

   pwr_on_rst_mipi;

   ui_value(ui);
   
   wr_fifo_status_reg(32'hffffffff);
   rd_fifo_status_reg(32'h00000009);
   wr_fifo_status_reg(32'h0000001f);
   rd_fifo_status_reg(32'h00000009);
   wr_fifo_status_reg(32'h00000000);
   rd_fifo_status_reg(32'h00000009);
   wr_fifo_status_reg(32'hffffffff);
   rd_fifo_status_reg(32'h00000009);
   
   wr_trim_reg_0(32'hffffffff);
   wr_trim_reg_1(32'hffffffff);
   wr_trim_reg_2(32'hffffffff);
   wr_trim_reg_3(32'hffffffff);
   rd_trim_reg_0(32'hffffffff);
   rd_trim_reg_1(32'hffffffff);
   rd_trim_reg_2(32'hffffffff);
   rd_trim_reg_3(32'hffffffff);
   
   wr_trim_reg_0(32'h00000000);
   wr_trim_reg_1(32'h00000000);
   wr_trim_reg_2(32'h00000000);
   wr_trim_reg_3(32'h00000000);
   rd_trim_reg_0(32'h00000000);
   rd_trim_reg_1(32'h00000000);
   rd_trim_reg_2(32'h00000000);
   rd_trim_reg_3(32'h00000000);
   
   wr_trim_reg_0(32'hffffffff);
   wr_trim_reg_1(32'hffffffff);
   wr_trim_reg_2(32'hffffffff);
   wr_trim_reg_3(32'hffffffff);
   rd_trim_reg_0(32'hffffffff);
   rd_trim_reg_1(32'hffffffff);
   rd_trim_reg_2(32'hffffffff);
   rd_trim_reg_3(32'hffffffff);
   
   wr_dphy_dfe_dln_reg_0(32'hffffffff);
   wr_dphy_dfe_dln_reg_1(32'hffffffff);
   wr_dphy_dfe_cln_reg_0(32'hffffffff);
   wr_dphy_dfe_cln_reg_1(32'hffffffff);
   rd_dphy_dfe_dln_reg_0(32'hffffffff);
   rd_dphy_dfe_dln_reg_1(32'hffffffff);
   rd_dphy_dfe_cln_reg_0(32'hffffffff);
   rd_dphy_dfe_cln_reg_1(32'hffffffff);
   
   wr_dphy_dfe_dln_reg_0(32'h00000000);
   wr_dphy_dfe_dln_reg_1(32'h00000000);
   wr_dphy_dfe_cln_reg_0(32'h00000000);
   wr_dphy_dfe_cln_reg_1(32'h00000000);
   rd_dphy_dfe_dln_reg_0(32'h00000000);
   rd_dphy_dfe_dln_reg_1(32'h00000000);
   rd_dphy_dfe_cln_reg_0(32'h00000000);
   rd_dphy_dfe_cln_reg_1(32'h00000000);
   
   wr_dphy_dfe_dln_reg_0(32'hffffffff);
   wr_dphy_dfe_dln_reg_1(32'hffffffff);
   wr_dphy_dfe_cln_reg_0(32'hffffffff);
   wr_dphy_dfe_cln_reg_1(32'hffffffff);
   rd_dphy_dfe_dln_reg_0(32'hffffffff);
   rd_dphy_dfe_dln_reg_1(32'hffffffff);
   rd_dphy_dfe_cln_reg_0(32'hffffffff);
   rd_dphy_dfe_cln_reg_1(32'hffffffff);
   
   wr_dphy_ln_pol_swap_reg(32'hffffffff);
   rd_dphy_ln_pol_swap_reg(32'h000000ff);
   wr_dphy_ln_pol_swap_reg(32'h00000000);
   rd_dphy_ln_pol_swap_reg(32'h00000000);
   wr_dphy_ln_pol_swap_reg(32'hffffffff);
   rd_dphy_ln_pol_swap_reg(32'h000000ff);
   
   wr_pll_cnt_reg(32'hffffffff);
   rd_pll_cnt_reg(32'h0000ffff);
   wr_pll_cnt_reg(32'h00000000);
   rd_pll_cnt_reg(32'h00000000);
   wr_pll_cnt_reg(32'hffffffff);
   rd_pll_cnt_reg(32'h0000ffff);
   
   wr_vc0_comp_pred_reg_1(32'hffffffff);
   wr_vc0_cmp_pred_reg_2(32'hffffffff);
   wr_vc1_cmp_pred_reg_1(32'hffffffff);
   wr_vc1_cmp_pred_reg_2(32'hffffffff);
   wr_vc2_cmp_pred_reg_1(32'hffffffff);
   wr_vc2_cmp_pred_reg_2(32'hffffffff);
   wr_vc3_cmp_pred_reg_1(32'hffffffff);
   wr_vc3_cmp_pred_reg_2(32'hffffffff);
   rd_vc0_comp_pred_reg_1(32'hffffffff);
   rd_vc0_comp_pred_reg_2(32'hffffffff);
   rd_vc1_comp_pred_reg_1(32'hffffffff);
   rd_vc1_comp_pred_reg_2(32'hffffffff);
   rd_vc2_comp_pred_reg_1(32'hffffffff);
   rd_vc2_comp_pred_reg_2(32'hffffffff);
   rd_vc3_comp_pred_reg_1(32'hffffffff);
   rd_vc3_comp_pred_reg_2(32'hffffffff);
   
   wr_vc0_comp_pred_reg_1(32'h00000000);
   wr_vc0_cmp_pred_reg_2(32'h00000000);
   wr_vc1_cmp_pred_reg_1(32'h00000000);
   wr_vc1_cmp_pred_reg_2(32'h00000000);
   wr_vc2_cmp_pred_reg_1(32'h00000000);
   wr_vc2_cmp_pred_reg_2(32'h00000000);
   wr_vc3_cmp_pred_reg_1(32'h00000000);
   wr_vc3_cmp_pred_reg_2(32'h00000000);
   rd_vc0_comp_pred_reg_1(32'h00000000);
   rd_vc0_comp_pred_reg_2(32'h00000000);
   rd_vc1_comp_pred_reg_1(32'h00000000);
   rd_vc1_comp_pred_reg_2(32'h00000000);
   rd_vc2_comp_pred_reg_1(32'h00000000);
   rd_vc2_comp_pred_reg_2(32'h00000000);
   rd_vc3_comp_pred_reg_1(32'h00000000);
   rd_vc3_comp_pred_reg_2(32'h00000000);
   
   wr_vc0_comp_pred_reg_1(32'hffffffff);
   wr_vc0_cmp_pred_reg_2(32'hffffffff);
   wr_vc1_cmp_pred_reg_1(32'hffffffff);
   wr_vc1_cmp_pred_reg_2(32'hffffffff);
   wr_vc2_cmp_pred_reg_1(32'hffffffff);
   wr_vc2_cmp_pred_reg_2(32'hffffffff);
   wr_vc3_cmp_pred_reg_1(32'hffffffff);
   wr_vc3_cmp_pred_reg_2(32'hffffffff);
   rd_vc0_comp_pred_reg_1(32'hffffffff);
   rd_vc0_comp_pred_reg_2(32'hffffffff);
   rd_vc1_comp_pred_reg_1(32'hffffffff);
   rd_vc1_comp_pred_reg_2(32'hffffffff);
   rd_vc2_comp_pred_reg_1(32'hffffffff);
   rd_vc2_comp_pred_reg_2(32'hffffffff);
   rd_vc3_comp_pred_reg_1(32'hffffffff);
   rd_vc3_comp_pred_reg_2(32'hffffffff);
   
   end_cmd;

end
endtask
