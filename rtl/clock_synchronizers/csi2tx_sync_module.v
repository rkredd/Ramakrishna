/*==============================================================================*/
// This confidential and proprietary software may be used only as authorized by 
// a licensing agreement from Arasan Chip Systems Inc.                          
// IN the event of publication the following notice is applicable              
//                                                                              
// Copyright (c) 2014 Arasan Chip Systems Inc. All Rights Reserved              
//                                                                              
// The entire notice above must be reproduced on all authorized copies          
// 
// File        : csi2tx_sync_module.v
// Author      : SHYAM SUNDAR B S
// Version     : v1p2
// Abstract    :This module is used to synchronize byte    
//              clock domain signals to AHB clock domain signals and vice versa
// Modification History
// Date     By    Version                             Change Description
/*==============================================================================


================================================================================*/
//Release Name                              : Date(DD/MM/YYYY)
//RELEASE_CSI2TX_8DL_1CL_AHB_v1p3_140627    : 27/06/2014
//==============================================================================*/
`include "csi2tx_defines.v"

module csi2tx_sync_module
(
 input  wire        sysclk                                              ,
 input  wire        sysclk_rst_n                                        ,
 input  wire        txbyteclkhs                                         ,
 input  wire        txbyteclkhs_rst_n                                   ,
 input  wire        clk_csi                                             ,
 input  wire        clk_csi_rst_n                                       ,
 input  wire        txclkesc                                            ,
 input  wire        txclkesc_rst_n                                      ,
 input  wire        sensor_fifo_empty                                   ,
 output wire        sensor_fifo_empty_byteclk_sysclk                    ,
 input  wire        sensor_fifo_full                                    ,
 output wire        sensor_fifo_full_clk_csi_sysclk                     ,
 input  wire        dfe_pll_locked                                      ,
 input  wire        csi_byte_fifo_rd_empty                              ,
 output wire        csi_byte_fifo_rd_empty_sysclk                       ,
 input  wire        csi_byte_fifo_rd_full                               ,
 output wire        csi_byte_fifo_rd_full_sysclk                        ,
 input  wire        csi_byte_fifo_rd_almost_full                        ,
 output wire        csi_byte_fifo_rd_almost_full_sysclk                 ,
 output wire        tinit_start_txclkesc_byteclk_dm                     ,
 output wire        tinit_start_txclkesc_clk_csi_dm                     ,
 input  wire        txready_hs                                          ,
 output wire        txready_hs_byteclk_pulse                            ,
 input  wire        dphy_clk_mode                                       ,
 output wire        dphy_clk_mode_byteclk                               ,
 input  wire        forcetxstopmode                                     ,
 output wire        forcetxstopmode_byteclk                             ,
 output wire        forcetxstopmode_clk_csi                             ,
 input  wire [2:0]  lane_config_sysclk                                  ,
 input  wire        lane_config_wren_sysclk                             ,
 output wire [2:0]  lane_config_sysclk_byteclk                          ,
 input  wire        stopstate_clk_txclkesc                              ,
 output wire        stopstate_clk_txclkesc_byteclk                      ,
 input  wire [7:0]  stopstate_dl_txclkesc                               ,
 output wire        stopstate_dl_txclkesc_byteclk                       ,
 input  wire        txulpsesc_entry_byteclk                             ,
 output wire [7:0]  txulpsesc_entry_byteclk_txclkesc                    ,
 input  wire        txulpsesc_entry_clk_byteclk                         ,
 output wire        txulpsesc_entry_clk_byteclk_txclesc                 ,
 input  wire        txulpsesc_exit_byteclk                              ,
 output wire [7:0]  txulpsesc_exit_byteclk_txclkesc                     ,
 input  wire        txulpsesc_exit_clk_byteclk                          ,
 output wire        txulpsesc_exit_clk_byteclk_txclkesc                 ,
 input  wire        txrequestesc_byteclk                                ,
 output wire [7:0]  txrequestesc_byteclk_txclkesc                       ,
 input  wire        txulpsesc_async                                     ,
 output wire        txulpsesc_async_byteclk                             ,
 input  wire        txulpsexit_async                                    ,
 output wire        txulpsexit_async_byteclk                            ,
 input  wire        packet_incr_pulse                                   ,
 output wire        packet_incr_pulse_clk_csi_byteclk                   ,
 output wire        packet_incr_pulse_byteclk_clk_csi                   ,
 input  wire [7:0]  ulpsactivenot_n                                     ,
 input  wire        ulpsactivenot_clk_n                                 ,
 output wire        ulpsactivenot_txclkesc_txbyteclkhs                  ,
 input  wire        dphy_calib_ctrl                                     ,
 output wire        dphy_calib_ctrl_byteclk                             ,
 input  wire [7:0]  data_lane_enabled 
                                                                  
);
//------------------------------------------------------------------------------
// Internal signal declaration
reg   txready_hs_delayed                 ;
wire  stopstate_dl_txclkesc_w            ;
reg   ulpsactivenot_n_r                  ;
wire  txulpsesc_entry_byteclk_txclkesc_w ;
wire  txulpsesc_exit_byteclk_txclkesc_w  ;
wire  txrequestesc_byteclk_txclkesc_w    ; 
reg   stopstate_dl_txclkesc_r            ;



//------------------------------------------------------------------------------
csi2tx_double_flop_sync
 u_tinit_start_txclkesc_byteclk_dm
(
  .rst_n       ( txbyteclkhs_rst_n               ),
  .clk         ( txbyteclkhs                     ),
  .in_data     ( dfe_pll_locked                  ),
  .out_data    ( tinit_start_txclkesc_byteclk_dm )
);

csi2tx_double_flop_sync
 u_tinit_start_clk_csi_byteclk_dm
(
  .rst_n       ( clk_csi_rst_n                   ),
  .clk         ( clk_csi                         ),
  .in_data     ( dfe_pll_locked                  ),
  .out_data    ( tinit_start_txclkesc_clk_csi_dm )
);

//------------------------------------------------------------------------------
        
                                                          

//------------------------------------------------------------------------------
csi2tx_double_flop_sync                                  
  u_dphy_clk_mode_byteclk                            
  (                                                 
  .clk                  ( txbyteclkhs             ),
  .rst_n                ( txbyteclkhs_rst_n       ),
  .in_data              ( dphy_clk_mode           ),
  .out_data             ( dphy_clk_mode_byteclk   ) 
  ); 

//------------------------------------------------------------------------------
csi2tx_double_flop_sync                                                                                 
  u_forcetxstopmode_byteclk                              
  (                                                 
  .clk                  ( txbyteclkhs             ),
  .rst_n                ( txbyteclkhs_rst_n       ),
  .in_data              ( forcetxstopmode         ),
  .out_data             ( forcetxstopmode_byteclk ) 
  ); 

csi2tx_double_flop_sync                                                                                 
  u_forcetxstopmode_clk_csi                              
  (                                                 
  .clk                  ( clk_csi                 ),
  .rst_n                ( clk_csi_rst_n           ),
  .in_data              ( forcetxstopmode         ),
  .out_data             ( forcetxstopmode_clk_csi ) 
  );
 
csi2tx_double_flop_sync                                                                                 
  u_csi_byte_fifo_rd_empty                              
  (                                                 
  .clk                  ( sysclk                              ),
  .rst_n                ( sysclk_rst_n                        ),
  .in_data              ( csi_byte_fifo_rd_empty              ),
  .out_data             ( csi_byte_fifo_rd_empty_sysclk       ) 
  );

csi2tx_double_flop_sync                                                                                 
  u_csi_byte_fifo_rd_full                              
  (                                                 
  .clk                  ( sysclk                              ),
  .rst_n                ( sysclk_rst_n                        ),
  .in_data              ( csi_byte_fifo_rd_full               ),
  .out_data             ( csi_byte_fifo_rd_full_sysclk        ) 
  );


csi2tx_double_flop_sync                                                                                 
  u_csi_byte_fifo_rd_almost_full                              
  (                                                 
  .clk                  ( sysclk                              ),
  .rst_n                ( sysclk_rst_n                        ),
  .in_data              ( csi_byte_fifo_rd_almost_full        ),
  .out_data             ( csi_byte_fifo_rd_almost_full_sysclk ) 
  );


//-----------------------------------------------------------------------------  
csi2tx_mux_based_sync #
(
 .DATA_WIDTH     (3),
 .INIT_VALUE     (3'b111)
 )
 u_lane_config_sysclk_byteclk
  (
  .clk_src    ( sysclk                         ),
  .clk_dest   ( txbyteclkhs                    ),
  .rsta_n     ( sysclk_rst_n                   ),
  .rstb_n     ( txbyteclkhs_rst_n              ),
  .enable     ( lane_config_wren_sysclk        ),
  .in_data    ( lane_config_sysclk             ),
  .out_data   ( lane_config_sysclk_byteclk     )
  );
//-----------------------------------------------------------------------------   
 csi2tx_double_flop_sync                                                                                 
  u_stopstate_clk_txclkesc_byteclk                              
  (                                                 
  .clk                  ( txbyteclkhs                    ),
  .rst_n                ( txbyteclkhs_rst_n              ),
  .in_data              ( stopstate_clk_txclkesc         ),
  .out_data             ( stopstate_clk_txclkesc_byteclk ) 
  );

//----------------------------------------------------------------------------- 
csi2tx_double_flop_sync                                                                                 
  u_stopstate_dl_txclkesc_byteclk                              
  (                                                 
  .clk                  ( txbyteclkhs                    ),
  .rst_n                ( txbyteclkhs_rst_n              ),
  .in_data              ( stopstate_dl_txclkesc_w        ),
  .out_data             ( stopstate_dl_txclkesc_byteclk  ) 
  );
//----------------------------------------------------------------------------- 
csi2tx_double_flop_sync                                                                                 
  u_txulpsesc_entry_byteclk_txclkesc_0                              
  (                                                 
  .clk                  ( txclkesc                             ),
  .rst_n                ( txclkesc_rst_n                       ),
  .in_data              ( txulpsesc_entry_byteclk              ),
  .out_data             ( txulpsesc_entry_byteclk_txclkesc_w   ) 
  );

assign txulpsesc_entry_byteclk_txclkesc = (txulpsesc_entry_byteclk_txclkesc_w == 1'b1) ? data_lane_enabled : 8'b0;

//-----------------------------------------------------------------------------                           
csi2tx_double_flop_sync                                                      
  u_txulpsesc_entry_clk_byteclk_txclesc                             
  (                                                 
  .clk                  ( txclkesc                         ),
  .rst_n                ( txclkesc_rst_n                   ),
  .in_data              ( txulpsesc_entry_clk_byteclk      ),
  .out_data             ( txulpsesc_entry_clk_byteclk_txclesc  ) 
  );
//-----------------------------------------------------------------------------                           
csi2tx_double_flop_sync                                                      
  u_txulpsesc_exit_byteclk_txclkesc_0                              
  (                                                 
  .clk                  ( txclkesc                            ),
  .rst_n                ( txclkesc_rst_n                      ),
  .in_data              ( txulpsesc_exit_byteclk              ),
  .out_data             ( txulpsesc_exit_byteclk_txclkesc_w   ) 
  ); 

assign txulpsesc_exit_byteclk_txclkesc = (txulpsesc_exit_byteclk_txclkesc_w == 1'b1) ? data_lane_enabled : 8'b0;
      
//-----------------------------------------------------------------------------                           
csi2tx_double_flop_sync                                                      
  u_txulpsesc_exit_clk_byteclk_txclkesc                              
  (                                                 
  .clk                  ( txclkesc                             ),
  .rst_n                ( txclkesc_rst_n                       ),
  .in_data              ( txulpsesc_exit_clk_byteclk           ),
  .out_data             ( txulpsesc_exit_clk_byteclk_txclkesc  ) 
  );    
//-----------------------------------------------------------------------------                           
csi2tx_double_flop_sync                                                      
  u_txrequestesc_byteclk_txclkesc_0                              
  (                                                 
  .clk                  ( txclkesc                          ),
  .rst_n                ( txclkesc_rst_n                    ),
  .in_data              ( txrequestesc_byteclk              ),
  .out_data             ( txrequestesc_byteclk_txclkesc_w   ) 
  );    
assign txrequestesc_byteclk_txclkesc = (txrequestesc_byteclk_txclkesc_w == 1'b1) ? data_lane_enabled : 8'b0;
                  
//-----------------------------------------------------------------------------                           
csi2tx_double_flop_sync                                                      
  u_txulpsesc_async_byteclk                              
  (                                                 
  .clk                  ( txbyteclkhs                         ),
  .rst_n                ( txbyteclkhs_rst_n                   ),
  .in_data              ( txulpsesc_async                     ),
  .out_data             ( txulpsesc_async_byteclk  ) 
  );    
         
//-----------------------------------------------------------------------------                           
csi2tx_double_flop_sync                                                      
  u_txulpsexit_async_byteclk                              
  (                                                 
  .clk                  ( txbyteclkhs                         ),
  .rst_n                ( txbyteclkhs_rst_n                   ),
  .in_data              ( txulpsexit_async           ),
  .out_data             ( txulpsexit_async_byteclk  ) 
  );    
         
//-----------------------------------------------------------------------------    
//
csi2tx_sync_pulse
 u_packet_incr_pulse_w_clk_csi_byteclk
 (
  .clk_in                    ( clk_csi                                            ),
  .clk_out                   ( txbyteclkhs                                        ),
  .rsta_n                    ( clk_csi_rst_n                                      ),
  .rstb_n                    ( txbyteclkhs_rst_n                                  ),
  .in_pulse                  ( packet_incr_pulse                                  ),
  .out_pulse                 ( packet_incr_pulse_clk_csi_byteclk                  )
  );             

//-----------------------------------------------------------------------------    
//
csi2tx_sync_pulse
 u_packet_incr_pulse_byteclk_clk_csi
 (
  .clk_in                    ( txbyteclkhs                                        ),
  .clk_out                   ( clk_csi                                            ),
  .rsta_n                    ( txbyteclkhs_rst_n                                  ),
  .rstb_n                    ( clk_csi_rst_n                                      ),
  .in_pulse                  ( packet_incr_pulse_clk_csi_byteclk                  ),
  .out_pulse                 ( packet_incr_pulse_byteclk_clk_csi                  )
  );             
  
  
//---------------------------------------------------------------------------------
//

                           
csi2tx_double_flop_sync                                                      
  u_sensor_fifo_empty_byteclk_sysclk                              
  (                                                 
  .clk                  ( sysclk                                                  ),
  .rst_n                ( sysclk_rst_n                                            ),
  .in_data              ( sensor_fifo_empty                                       ),
  .out_data             ( sensor_fifo_empty_byteclk_sysclk                        ) 
  );    


//---------------------------------------------------------------------------------
//


csi2tx_double_flop_sync                                                      
  u_sensor_fifo_full_clk_csi_sysclk                              
  (                                                 
  .clk                  ( sysclk                                                  ),
  .rst_n                ( sysclk_rst_n                                            ),
  .in_data              ( sensor_fifo_full                                        ),
  .out_data             ( sensor_fifo_full_clk_csi_sysclk                         ) 
  );    


//---------------------------------------------------------------------------------
//

always@(posedge txclkesc or negedge txclkesc_rst_n) begin
  if (txclkesc_rst_n == 1'b0)
    stopstate_dl_txclkesc_r <= 1'b0;
  else
    stopstate_dl_txclkesc_r <= ( stopstate_dl_txclkesc[7] & stopstate_dl_txclkesc[6] 
                               & stopstate_dl_txclkesc[5] & stopstate_dl_txclkesc[4] 
                               & stopstate_dl_txclkesc[3] & stopstate_dl_txclkesc[2] 
                               & stopstate_dl_txclkesc[1] & stopstate_dl_txclkesc[0] );
end

assign stopstate_dl_txclkesc_w = stopstate_dl_txclkesc_r;

always@(posedge txbyteclkhs or negedge txbyteclkhs_rst_n) begin
  if (txbyteclkhs_rst_n == 1'b0)
     txready_hs_delayed <= 1'b0;
  else
    txready_hs_delayed <= txready_hs;
end
assign txready_hs_byteclk_pulse = ((~txready_hs) && txready_hs_delayed);

always@(posedge txclkesc or negedge txclkesc_rst_n) begin
  if (txclkesc_rst_n == 1'b0)
    ulpsactivenot_n_r <= 1'b0;
  else
    ulpsactivenot_n_r <= ulpsactivenot_clk_n & (|ulpsactivenot_n);
end

csi2tx_double_flop_sync                                                      
  u_ulpsactivenot_n_txclkesc_byteclkhs                              
  (                                                 
  .clk                  ( txbyteclkhs                         ),
  .rst_n                ( txbyteclkhs_rst_n                   ),
  .in_data              ( ulpsactivenot_n_r           ),
  .out_data             ( ulpsactivenot_txclkesc_txbyteclkhs  ) 
  ); 
//------------------------------------------------------------------------------
csi2tx_double_flop_sync
 u_dphy_calib_ctrl_byteclk
(
  .rst_n       ( txbyteclkhs_rst_n               ),
  .clk         ( txbyteclkhs                     ),
  .in_data     ( dphy_calib_ctrl                 ),
  .out_data    ( dphy_calib_ctrl_byteclk         )
);

endmodule                                              
