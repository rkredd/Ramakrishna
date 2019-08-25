task ahb_master_cmd;

   begin

      post_initialize_test;

     //max _address write
     ahb_write_process(32'hffff,32'h100);
     ahb_write_process(32'hffff,32'h5f);
     ahb_write_process(32'hffff,32'h100);
            
      end_cmd;

   end
endtask
