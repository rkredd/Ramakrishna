/*--------------------------------------------------------------------
     Intellectual propery of Arasan Chip Systems Inc. 
----------------------------------------------------------------------
     (c) 2010 Arasan Chip Systems Inc. 
----------------------------------------------------------------------
File    : csi2tx_phy_afe_buf.v
Project : DPHY
Author  : aruls
----------------------------------------------------------------------
Desc    : 
  This module provides the Buffer interface for
  the DPHY Analog Front End 
  The below table summarises the strength level 
  High speed 1 --> Weak 1   , High speed 0 --> Medium 0 
  Low  speed 1 --> Supply 1 , Low  speed 0 --> Strong 0  
  The contention detector has restricted modeling, since
  it is difficult to detect contention, when both the 
  lines transmit '1's with same drive strength on the line.
-------------------------------------------------------------------*/
`timescale 1 ps / 1 ps
module csi2tx_phy_afe_buf (
  input  wire                      hs_tx_en                 , //  High speed data transmit enable 
  input  wire                      hs_tx_data               , //  High speed transmit data 
  input  wire                      lp_tx_en                 , //  Low power mode Transmit enable 
  input  wire                      lp_tx_dp                 , //  Low power mode Transmit data DP 
  input  wire                      lp_tx_dn                 , //  Low power mode Transmit data DN 
  input  wire                      hs_rx_en                 , //  High speed Rx enable 
  output wire                      hs_rcv_data              , //  High speed serial receive data 
  output wire                      lp_rcv_dp                , //  Low power mode receive data DP 
  output wire                      lp_rcv_dn                , //  Low power mode receive data DN 
  output reg                       lp_cd_low                 , //  Contention detector 
  output reg                       lp_cd_high                 , //  Contention detector 
  inout  wire                      dp                       , //  Differential pair line DP 
  inout  wire                      dn                         //  Differential pair line DN 
);

// Declaration of nets used in the instantiation wiring
// CM TRANSLATE OFF

// A Strong 1 is driven in the case of '1' 
//bufif1 (supply0, supply1) (supply_0,1'b0,1'b1);
bufif1 (weak0, weak1) (weak_0,1'b0,1'b1);
bufif1 (strong0, strong1) (strong_0,1'b0,1'b1);

//------------------------------------------------------------------
// Low speed transmiter
//------------------------------------------------------------------
// The transmiter has a Strong1 in case of 1 and a 
// reduced strength level in the case of zero 
bufif1 (weak0,weak1) (dp,1'b1,lp_tx_en & lp_tx_dp);
nmos   (dp,weak_0,lp_tx_en & ~lp_tx_dp);

bufif1 (weak0,weak1) (dn,1'b1,lp_tx_en & lp_tx_dn);
nmos   (dn,weak_0,lp_tx_en & ~lp_tx_dn);

//------------------------------------------------------------------
// High speed transmiter
//------------------------------------------------------------------
// The transmiter has weak1 in case of 1 and a
// reduced strength level in the case of zero
bufif1 (strong1,strong0) (dp,1'b1,(hs_tx_en & hs_tx_data));
nmos   (dp,strong_0,(hs_tx_en & ~hs_tx_data));

bufif1 (strong1,strong0) (dn,1'b1,(hs_tx_en & ~hs_tx_data));
nmos   (dn,strong_0,(hs_tx_en & hs_tx_data));

//------------------------------------------------------------------
// Receiver logic for the LP lines 
//------------------------------------------------------------------
// Comparator for a strong 1 
bufif1 (strong0, strong1) (strong_1_cmp_dp,1'b0,1'b1);
bufif1 (strong0, strong1) (strong_1_cmp_dn,1'b0,1'b1);

// Reduce the signal strength of the dp and dn lines 
nmos(weak_1_cmp_dp,dp,1'b1);
nmos(weak_1_cmp_dn,dn,1'b1);

// An x is seen when the strength level matches
assign lp_rcv_dp = (weak_1_cmp_dp === 1'bx) & (!(lp_cd_low | lp_cd_high)) ? 1'b1 : 1'b0;
assign lp_rcv_dn = (weak_1_cmp_dn === 1'bx) & (!(lp_cd_low | lp_cd_high)) ? 1'b1 : 1'b0;

//------------------------------------------------------------------
// Receiver logic for the high speed lines  
//------------------------------------------------------------------

// Get the reduced strength for dp and dn lines
bufif1 (weak0, weak1) (weak_1_cmp_dp,1'b0,1'b1);
bufif1 (weak0, weak1) (weak_1_cmp_dn,1'b0,1'b1);

// Reduce the signal strength of the dp and dn lines 
nmos (strong_1_cmp_dp,dp,1'b1);
nmos (strong_1_cmp_dn,dn,1'b1);

assign hs_rcv_data = (strong_1_cmp_dp === 1'bx && strong_1_cmp_dn !== 1'bx) ? hs_rx_en : 1'b0;

   wire cd0_en =  lp_tx_en;

   wire cdlow0_dp  = cd0_en & (lp_tx_dp == 1'b0) & (dp !== lp_tx_dp & dp!==1'bz);
   wire cdhigh0_dp = cd0_en & (lp_tx_dp == 1'b1) & (dp !== lp_tx_dp & dp!==1'bz);

   wire cdlow0_dn  = cd0_en & (lp_tx_dn == 1'b0) & (dn !== lp_tx_dn & dn!==1'bz);
   wire cdhigh0_dn = cd0_en & (lp_tx_dn == 1'b1) & (dn !== lp_tx_dn & dn!==1'bz);


   wire sig_cdlow0  = cdlow0_dp | cdlow0_dn;
   wire sig_cdhigh0 = cdhigh0_dp | cdhigh0_dn;


  always@( sig_cdlow0 )      
//     #20000   lp_cd_low=sig_cdlow0;  
     lp_cd_low=sig_cdlow0;  


  always@(  sig_cdhigh0 )
//     #20000    lp_cd_high=sig_cdhigh0;
     lp_cd_high=sig_cdhigh0;

   //------------------------------------------------------------------
// Logic for collision detection 
//------------------------------------------------------------------
/*always @(*) begin
  lp_cont = 1'b0;
  // Both dp and dn line cann have 1 
  if(weak_1_cmp_dp === 1'bx && weak_1_cmp_dn == 1'bx) begin
    lp_cont = 1'b1;
  end else if(hs_tx_en) begin
    // During high speed transmit the low power data lines
    // cannot drive
    if(strong_1_cmp_dp === 1'bx || strong_1_cmp_dn) begin
      lp_cont = 1'b1;
    // Transmiting data 0 on the high speed line   
    end else if (hs_tx_data) begin
       // Dp line is not 1 when driving '1'
       if(weak_1_cmp_dp !== 1'bx) begin
         lp_cont = 1'b1;
       // If the Dn line is driven to 1
       end else if (weak_1_cmp_dn === 1'bx) begin 
         lp_cont = 1'b1;
       end
    // Transmiting data 1 on the high speed line
    end else begin
       // Dn line is not 1 when driving '1'
       if(weak_1_cmp_dn !== 1'bx) begin
         lp_cont = 1'b1;
       // If the Dp line is driven to 1
       end else if (weak_1_cmp_dp === 1'bx) begin 
         lp_cont = 1'b1;
       end
    end 
  // During Low speed transmision
  end else if(lp_tx_en) begin
    if(lp_tx_dp == 1'b1 && strong_1_cmp_dp !== 1'bx) begin 
      lp_cont = 1'b1;
    end else if(lp_tx_dp == 1'b0 && strong_1_cmp_dp === 1'bx) begin
      lp_cont = 1'b1;
    end else if(lp_tx_dn == 1'b1 && strong_1_cmp_dn !== 1'bx) begin
      lp_cont = 1'b1;
    end else if(lp_tx_dn == 1'b0 && strong_1_cmp_dn === 1'bx) begin
      lp_cont = 1'b1;
    end
  end 
end
*/

endmodule
