task pkt_interface_cmd;

reg clk_mode;

begin

   interleave_en(35'h3fff800);


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

   //
   


   //FRAME START
   send_synch_sh_pkt(16'h0001,2'b00,6'h00);
   
   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);
   
   //RAW 8
   send_raw_data(16'h0005,2'b00,6'h2A);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);


   //LINE START
   send_synch_sh_pkt(16'h0002,2'b00,6'h02);
   
   //RAW 10
   send_raw_data(16'h000A,2'b00,6'h2B);

   //LINE END
   send_synch_sh_pkt(16'h0002,2'b00,6'h03);


   //LINE START
   send_synch_sh_pkt(16'h0003,2'b00,6'h02);
   
   //RAW 12
   send_raw_data(16'h000C,2'b00,6'h2C);

   //LINE END
   send_synch_sh_pkt(16'h0003,2'b00,6'h03);



   //LINE START
   send_synch_sh_pkt(16'h0004,2'b00,6'h02);
   
   //RAW 14
   send_raw_data(16'h000E,2'b00,6'h2D);

   //LINE END
   send_synch_sh_pkt(16'h0004,2'b00,6'h03);


   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b00,6'h01);
   
   
   csi_end_cmd;



end
endtask
