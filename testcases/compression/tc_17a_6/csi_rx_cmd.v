task csi_rx_cmd;

  begin

vc0_compression(1'b1,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110);
vc1_compression(1'b1,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110);
vc2_compression(1'b1,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110);
vc3_compression(1'b1,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110,5'b01110);
  end
endtask
