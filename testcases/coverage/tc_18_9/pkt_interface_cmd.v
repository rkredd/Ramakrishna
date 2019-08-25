task pkt_interface_cmd;
reg [2:0] lane_count;
reg clk_mode;

begin

interleave_en(35'h00000080);

`ifdef NONCONTINUOUS_CLK_MODE clk_mode = 1'b1;
`else clk_mode = 1'b0;
`endif

   pwr_rst;

   master_pin_sel(1'b1);

   txulpsesc_val(1'b0);

   txulpsexit_val(1'b0);

   forcetxstop_state(1'b0);

   dphy_clk_mode_val(1'b0);

   loopack_mode(1'b0);

   

   initial_calibration(32'd1000);

  
   //FRAME START
   send_synch_sh_pkt(16'h0001,2'b00,6'h00);
   
   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);
   
   // RAW8 DATA
   send_raw_data(16'h0a,2'b00,6'h2A);
   
   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);

   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b00,6'h01);

    sync_with_ahb;


   periodic_calibration(32'd1000);


   csi_end_cmd;

end
endtask
