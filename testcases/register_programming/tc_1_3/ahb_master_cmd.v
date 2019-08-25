task ahb_master_cmd;
begin

pre_initialize_test;

pwr_on_rst_mipi;

ui_value(ui);

wr_trim_reg_0(32'hfffffff0);
wr_trim_reg_1(32'h0fffffff);
wr_trim_reg_2(32'hffffff00);
wr_trim_reg_3(32'h00ffffff);
wr_dphy_dfe_dln_reg_0(32'hfffff000);
wr_dphy_dfe_dln_reg_1(32'h000fffff);
wr_dphy_dfe_cln_reg_0(32'hffff0000);
wr_dphy_dfe_cln_reg_1(32'h0000ffff);
wr_dphy_ln_pol_swap_reg(32'h00000fff);
wr_pll_cnt_reg(32'hffffffff);

rd_trim_reg_0(32'hfffffff0);
rd_trim_reg_1(32'h0fffffff);
rd_trim_reg_2(32'hffffff00);
rd_trim_reg_3(32'h00ffffff);
rd_dphy_dfe_dln_reg_0(32'hfffff000);
rd_dphy_dfe_dln_reg_1(32'h000fffff);
rd_dphy_dfe_cln_reg_0(32'hffff0000);
rd_dphy_dfe_cln_reg_1(32'h0000ffff);
rd_dphy_ln_pol_swap_reg(32'h000000ff);
rd_pll_cnt_reg(32'h0000ffff);


end_cmd;

end
endtask
