task ahb_master_cmd;
begin



wait(!init_enable);

// 12-6-12 Prediction mode 1
wr_vc0_comp_pred_reg_1({2'b00,5'b01100,5'b01100,5'b01100,5'b01100,5'b01100,5'b01100});
wr_vc0_cmp_pred_reg_2({22'd0,5'b01100,5'b01100});
wr_vc1_cmp_pred_reg_1({2'b00,5'b01100,5'b01100,5'b01100,5'b01100,5'b01100,5'b01100});
wr_vc1_cmp_pred_reg_2({22'd0,5'b01100,5'b01100});
wr_vc2_cmp_pred_reg_1({2'b00,5'b01100,5'b01100,5'b01100,5'b01100,5'b01100,5'b01100});
wr_vc2_cmp_pred_reg_2({22'd0,5'b01100,5'b01100});
wr_vc3_cmp_pred_reg_1({2'b00,5'b01100,5'b01100,5'b01100,5'b01100,5'b01100,5'b01100});
wr_vc3_cmp_pred_reg_2({22'd0,5'b01100,5'b01100});


end_cmd;

end
endtask
