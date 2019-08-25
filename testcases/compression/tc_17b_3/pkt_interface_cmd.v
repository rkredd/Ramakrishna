task pkt_interface_cmd;

 reg [2:0] lane_count;
 reg clk_mode;
 reg [15:0] word_count;

begin
    interleave_en(32'h10000000);

`ifdef ONE_LANE   lane_count = 3'b001;
`elsif TWO_LANE   lane_count = 3'b010;
`elsif THREE_LANE lane_count = 3'b011;
`else             lane_count = 3'b100;
`endif

`ifdef NONCONTINUOUS_CLK_MODE clk_mode = 1'b1;
`else clk_mode = 1'b0;
`endif

   pwr_rst;

   master_pin_sel(1'b1);

   txulpsesc_val(1'b0);

   txulpsexit_val(1'b0);

   forcetxstop_state(1'b0);

   dphy_clk_mode_val(clk_mode);

   //prepare_count_val(5'ha);

   //exit_zero_count_val(6'hf);

   //clk_zero_count_val(8'h1c);

   //trail_count_val(5'hc);

   loopack_mode(1'b0);

   //gpio_sel_mode(1'b0);

   ////gpio_sel_val(10'h0);

    
    
  for (word_count = 40 ; word_count <= 1000 ; word_count = word_count + 40)
  begin
   //FRAME START
   send_synch_sh_pkt(16'h0001,2'b00,6'h00);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);

   //USER_DEFINED_TYPE1
   send_comp_data_usd10(word_count,2'b00,6'h30,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);
   
   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);

   //USER_DEFINED_TYPE2
   send_comp_data_usd10(word_count,2'b00,6'h31,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);
 
   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);

   //USER_DEFINED_TYPE3
   send_comp_data_usd10(word_count,2'b00,6'h32,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);

   //USER_DEFINED_TYPE4
   send_comp_data_usd10(word_count,2'b00,6'h33,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);
  
   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);
 
   //USER_DEFINED_TYPE5
   send_comp_data_usd10(word_count,2'b00,6'h34,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);

   //USER_DEFINED_TYPE6
   send_comp_data_usd10(word_count,2'b00,6'h35,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);

   //USER_DEFINED_TYPE7
   send_comp_data_usd10(word_count,2'b00,6'h36,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b00,6'h02);

   //USER_DEFINED_TYPE8
   send_comp_data_usd10(word_count,2'b00,6'h37,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b00,6'h03);
   
   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b00,6'h01);
   
//////////SECOND FRAME//////////////////////
  //FRAME START
   send_synch_sh_pkt(16'h0001,2'b01,6'h00);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b01,6'h02);

   //USER_DEFINED_TYPE1
   send_comp_data_usd10(word_count,2'b01,6'h30,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b01,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b01,6'h02);

   //USER_DEFINED_TYPE2
   send_comp_data_usd10(word_count,2'b01,6'h31,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b01,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b01,6'h02);

   //USER_DEFINED_TYPE3
   send_comp_data_usd10(word_count,2'b01,6'h32,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b01,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b01,6'h02);

   //USER_DEFINED_TYPE4
   send_comp_data_usd10(word_count,2'b01,6'h33,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b01,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b01,6'h02);


   //USER_DEFINED_TYPE5
   send_comp_data_usd10(word_count,2'b01,6'h34,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b01,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b01,6'h02);

   //USER_DEFINED_TYPE6
   send_comp_data_usd10(word_count,2'b01,6'h35,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b01,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b01,6'h02);

   //USER_DEFINED_TYPE7
   send_comp_data_usd10(word_count,2'b01,6'h36,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b01,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b01,6'h02);

   //USER_DEFINED_TYPE8
   send_comp_data_usd10(word_count,2'b01,6'h37,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b01,6'h03);
 
   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b01,6'h01);
 
////////THIRD FRAME////////////////////
 
 //FRAME START
   send_synch_sh_pkt(16'h0001,2'b10,6'h00);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b10,6'h02);

   //USER_DEFINED_TYPE1
   send_comp_data_usd10(word_count,2'b10,6'h30,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b10,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b10,6'h02);

   //USER_DEFINED_TYPE2
   send_comp_data_usd10(word_count,2'b10,6'h31,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b10,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b10,6'h02);

   //USER_DEFINED_TYPE3
   send_comp_data_usd10(word_count,2'b10,6'h32,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b10,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b10,6'h02);

   //USER_DEFINED_TYPE4
   send_comp_data_usd10(word_count,2'b10,6'h33,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b10,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b10,6'h02);

   //USER_DEFINED_TYPE5
   send_comp_data_usd10(word_count,2'b10,6'h34,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b10,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b10,6'h02);

   //USER_DEFINED_TYPE6
   send_comp_data_usd10(word_count,2'b10,6'h35,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b10,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b10,6'h02);

   //USER_DEFINED_TYPE7
   send_comp_data_usd10(word_count,2'b10,6'h36,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b10,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b10,6'h02);

   //USER_DEFINED_TYPE8
   send_comp_data_usd10(word_count,2'b10,6'h37,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b10,6'h03);

   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b10,6'h01);
 
//////////////////////FOURTH FRAME//////////////////
 //FRAME START
   send_synch_sh_pkt(16'h0001,2'b11,6'h00);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b11,6'h02);

   //USER_DEFINED_TYPE1
   send_comp_data_usd10(word_count,2'b11,6'h30,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b11,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b11,6'h02);

   //USER_DEFINED_TYPE2
   send_comp_data_usd10(word_count,2'b11,6'h31,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b11,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b11,6'h02);

   //USER_DEFINED_TYPE3
   send_comp_data_usd10(word_count,2'b11,6'h32,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b11,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b11,6'h02);

   //USER_DEFINED_TYPE4
   send_comp_data_usd10(word_count,2'b11,6'h33,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b11,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b11,6'h02);

   //USER_DEFINED_TYPE5
   send_comp_data_usd10(word_count,2'b11,6'h34,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b11,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b11,6'h02);

   //USER_DEFINED_TYPE6
   send_comp_data_usd10(word_count,2'b11,6'h35,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b11,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b11,6'h02);

   //USER_DEFINED_TYPE7
   send_comp_data_usd10(word_count,2'b11,6'h36,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b11,6'h03);

   //LINE START
   send_synch_sh_pkt(16'h0001,2'b11,6'h02);

   //USER_DEFINED_TYPE8
   send_comp_data_usd10(word_count,2'b11,6'h37,2'b10,3'h1);

   //LINE END
   send_synch_sh_pkt(16'h0001,2'b11,6'h03);

   //FRAME END
   send_synch_sh_pkt(16'h0001,2'b11,6'h01);
  
   end;
csi_end_cmd;

end
endtask
