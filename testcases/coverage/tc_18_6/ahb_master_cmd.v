task ahb_master_cmd;
  begin

    force_lane_index(3'b111);
   

     processor_reset;

     
    force_lane_index(3'b000);

     

    end_cmd;

  end
endtask
