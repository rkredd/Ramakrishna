task pkt_interface_cmd;

reg clk_mode;

begin

   interleave_en(35'h03fff81f);


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
   
   //YUV 422 8-bit
   send_yuv_data(16'h0004,2'b00,6'h1E);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);


   //LINE START
   send_synch_sh_pkt(16'h0002,2'b00,6'h02);
   
   //YUV 422 10-bit
   send_yuv_data(16'h0005,2'b00,6'h1F);

   //LINE END
   send_synch_sh_pkt(16'h0002,2'b00,6'h03);


   //LINE START
   send_synch_sh_pkt(16'h0003,2'b00,6'h02);
   
   //YUV 422 8-bit
   send_yuv_data(16'h0008,2'b00,6'h1E);

   //LINE END
   send_synch_sh_pkt(16'h0003,2'b00,6'h03);


   //LINE START
   send_synch_sh_pkt(16'h0004,2'b00,6'h02);
   
   //YUV 422 10-bit
   send_yuv_data(16'h000A,2'b00,6'h1F);

   //LINE END
   send_synch_sh_pkt(16'h0004,2'b00,6'h03);



   //LINE START
   send_synch_sh_pkt(16'h0005,2'b00,6'h02);
   
   //USD - 1
   send_user_def_data(16'h0001,2'b00,6'h30);

   //LINE END
   send_synch_sh_pkt(16'h0005,2'b00,6'h03);

   
   //LINE START
   send_synch_sh_pkt(16'h0006,2'b00,6'h02);
   
   //USD - 2
   send_user_def_data(16'h00C8,2'b00,6'h31);

   //LINE END
   send_synch_sh_pkt(16'h0006,2'b00,6'h03);


   //LINE START
   send_synch_sh_pkt(16'h0007,2'b00,6'h02);
   
   //USD - 3
   send_user_def_data(16'h012C,2'b00,6'h32);

   //LINE END
   send_synch_sh_pkt(16'h0007,2'b00,6'h03);


   //LINE START
   send_synch_sh_pkt(16'h0008,2'b00,6'h02);
   
   //USD - 4
   send_user_def_data(16'h0190,2'b00,6'h33);

   //LINE END
   send_synch_sh_pkt(16'h0008,2'b00,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0009,2'b00,6'h02);
   
   //USD - 5
   send_user_def_data(16'h01F4,2'b00,6'h34);

   //LINE END
   send_synch_sh_pkt(16'h0009,2'b00,6'h03);

   
   //LINE START
   send_synch_sh_pkt(16'h000A,2'b00,6'h02);
   
   //USD - 6
   send_user_def_data(16'h0258,2'b00,6'h35);

   //LINE END
   send_synch_sh_pkt(16'h000A,2'b00,6'h03);


   //LINE START
   send_synch_sh_pkt(16'h000B,2'b00,6'h02);
   
   //USD - 7
   send_user_def_data(16'h02BC,2'b00,6'h36);

   //LINE END
   send_synch_sh_pkt(16'h000B,2'b00,6'h03);


   //LINE START
   send_synch_sh_pkt(16'h000C,2'b00,6'h02);
   
   //USD - 8
   send_user_def_data(16'h0320,2'b00,6'h37);

   //LINE END
   send_synch_sh_pkt(16'h000C,2'b00,6'h03);


   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b00,6'h01);   

   csi_end_cmd;



end
endtask
