task pkt_interface_cmd;

reg clk_mode;

begin


`ifdef NONCONTINUOUS_CLK_MODE clk_mode = 1'b1;
`else clk_mode = 1'b0;
`endif

   pwr_rst;

   csi_end_cmd;



end
endtask
