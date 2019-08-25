task pkt_interface_cmd;
 
integer i,j,k,l,d;

reg clk_mode;

begin

   interleave_en(35'h00008000);


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
   
   //YUV 422 8 bit
   send_raw_data(16'h0190,2'b00,6'h1E);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);


   //FRAME START
   send_synch_sh_pkt(16'h0001,2'b01,6'h00);

   //LINE START
   send_synch_sh_pkt(16'h0002,2'b01,6'h02);
   
   //YUV 422 8 bit
   send_raw_data(16'h0190,2'b01,6'h1E);

   //LINE END
   send_synch_sh_pkt(16'h0002,2'b01,6'h03);


  
   //FRAME START
   send_synch_sh_pkt(16'h0001,2'b10,6'h00);

   //LINE START
   send_synch_sh_pkt(16'h0002,2'b10,6'h02);
   
   //YUV 422 8 bit
   send_raw_data(16'h0190,2'b10,6'h1E);

   //LINE END
   send_synch_sh_pkt(16'h0002,2'b10,6'h03);


   //FRAME START
   send_synch_sh_pkt(16'h0001,2'b11,6'h00);

   //LINE START
   send_synch_sh_pkt(16'h0002,2'b11,6'h02);
   
   //YUV 422 8 bit
   send_raw_data(16'h0190,2'b11,6'h1E);


   //LINE END
   send_synch_sh_pkt(16'h0002,2'b11,6'h03);


   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b11,6'h01);

   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b10,6'h01);

   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b01,6'h01);

   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b00,6'h01);


csi_end_cmd;

end
endtask
