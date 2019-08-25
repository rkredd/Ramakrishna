task ahb_master_cmd;

   begin
      post_initialize_test;

      single_burst_rd_trans;
            
      end_cmd;

   end
endtask
