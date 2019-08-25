task ahb_master_cmd;

   begin
      post_initialize_test;

      single_burst_wr_trans;
            
      end_cmd;

   end
endtask
