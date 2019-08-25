task ahb_master_cmd;

   begin

     // post_initialize_test;

      test_mode_enable;

      single_burst_rd_trans;

      test_mode_enable;

      single_burst_wr_trans;
            
      end_cmd;

   end
endtask
