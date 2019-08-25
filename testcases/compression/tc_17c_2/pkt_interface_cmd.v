task pkt_interface_cmd;

 reg [2:0] lane_count;
 reg clk_mode;
 reg [2:0] vc;


begin
    interleave_en(32'hfffc0020);

`ifdef NONCONTINUOUS_CLK_MODE clk_mode = 1'b1;
`else clk_mode = 1'b0;
`endif

   pwr_rst;

   master_pin_sel(1'b1);

   txulpsesc_val(1'b0);

   txulpsexit_val(1'b0);

   forcetxstop_state(1'b0);

   dphy_clk_mode_val(clk_mode);

   loopack_mode(1'b0);
    

    //FRAME START
    send_synch_sh_pkt(16'h0001,2'b00,6'h00);
  
    //LINE START
    send_synch_sh_pkt(16'h0001,2'b00,6'h02);

    //USER_DEFINED_TYPE 
    send_comp_data_usd10(16'd30,2'b00,6'h30,2'b01,3'h2); // 10-7-10 

    //LINE END
    send_synch_sh_pkt(16'h0001,2'b00,6'h03);

    //LINE START
    send_synch_sh_pkt(16'h0001,2'b00,6'h02);

    // RAW12 DATA
    send_raw_data(16'h03,2'b00,6'h2C);

    //LINE END
    send_synch_sh_pkt(16'h0001,2'b00,6'h03);

    //LINE START
    send_synch_sh_pkt(16'h0001,2'b00,6'h02);

    // RAW14 DATA
    send_raw_data(16'h07,2'b00,6'h2D);

    //LINE END
    send_synch_sh_pkt(16'h0001,2'b00,6'h03);

    //FRAME END
    send_synch_sh_pkt(16'h0001,2'b00,6'h01);



   
csi_end_cmd;

end
endtask
