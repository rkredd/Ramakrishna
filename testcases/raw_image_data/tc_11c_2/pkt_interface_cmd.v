task pkt_interface_cmd;
integer i;
reg clk_mode;

begin

    interleave_en(35'h00000040);


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

    
    

   for(i=1; i <= 1170; i=i+1) begin 
    
   //FRAME START
   send_synch_sh_pkt(i,2'b00,6'h00);
  
   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);
      
   // RAW7 DATA
   send_raw_data(i*7,2'b00,6'h29);
   
   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);
      
   //FRAME END
   send_synch_sh_pkt(i,2'b00,6'h01);

   end 

   csi_end_cmd;



end
endtask
