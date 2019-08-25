task pkt_interface_cmd;

 reg [2:0] lane_count;
 reg clk_mode;
 reg [15:0] word_count;
 reg  [2:0] vc;
 reg  [5:0] data_id;

begin
    interleave_en(32'h20000000);

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

    

  for (word_count = 48 ; word_count <= 1000; word_count = word_count + 48)      // 12-6-12

  begin
    for (vc = 3'd0 ; vc < 3'd4 ; vc = vc + 3'd1) 
    begin 
        
    //FRAME START
    send_synch_sh_pkt(16'h0001,vc[1:0],6'h00);
    
      for (data_id = 6'h30 ; data_id <= 6'h37 ; data_id = data_id + 6'h1) 
      begin
        //LINE START
        send_synch_sh_pkt(16'h0001,vc[1:0],6'h02);

        //USER_DEFINED_TYPE 

        send_comp_data_usd12(word_count,vc[1:0],data_id,2'b10,3'h3); // 12-6-12
 
        //LINE END
        send_synch_sh_pkt(16'h0001,vc[1:0],6'h03);
      end
    //FRAME END
    send_synch_sh_pkt(16'h0001,vc[1:0],6'h01);
    end
  end  


csi_end_cmd;

end
endtask
