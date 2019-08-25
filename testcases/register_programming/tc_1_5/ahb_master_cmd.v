task ahb_master_cmd;
begin

pre_initialize_test;

pwr_on_rst_mipi;

ui_value(ui);

wr_rd_invalid_reg(32'h00ff00ff);


end_cmd;

end
endtask
