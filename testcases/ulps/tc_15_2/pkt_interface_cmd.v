task pkt_interface_cmd;

reg clk_mode;

begin
   interleave_en(35'h00000080);

`ifdef NONCONTINUOUS_CLK_MODE clk_mode = 1'b1;
`else clk_mode = 1'b0;
`endif


   pwr_rst;

   txulpsesc_val(1'b1);

   txulpsexit_val(1'b1);
 
   master_pin_sel(1'b1);

   txulpsesc_val(1'b0);

   txulpsexit_val(1'b0);

   forcetxstop_state(1'b0);

   dphy_clk_mode_val(clk_mode);

   loopack_mode(1'b0);
    
    
   txulpsesc_val(1'b1);

   txulpsexit_val(1'b1);

   //FRAME START
   send_synch_sh_pkt(16'h0001,2'b00,6'h00);
   
   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);

   txulpsesc_val(1'b1);

   txulpsexit_val(1'b1);

   // RAW DATA
   send_raw_data(16'h10,2'b00,6'h2A);

   txulpsesc_val(1'b1);

   txulpsexit_val(1'b1);
   
   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);

   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b00,6'h01);

   txulpsesc_val(1'b1);

   txulpsexit_val(1'b1);

   delay(32'hffff);

   txulpsesc_val(1'b1);

   txulpsexit_val(1'b1);

   delay(32'hffff);

   txulpsesc_val(1'b1);

   txulpsexit_val(1'b1); 


   csi_end_cmd;

end
endtask
