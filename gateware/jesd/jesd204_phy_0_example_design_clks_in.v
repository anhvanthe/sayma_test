//----------------------------------------------------------------------------
// Title : Example Design Top Level
// Project : JESD204_phy
//----------------------------------------------------------------------------
// File : jesd204_phy_0_example_design_clks_in.v
//----------------------------------------------------------------------------
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 
//
//----------------------------------------------------------------------------

`timescale 1ns / 1ps

module jesd204_phy_0_example_design_clks_in (

  output   tx_coreclk,

  output   rx_coreclk,
  
  input    drpclk_in,
  
  input    refclk_common_p,
  input    refclk_common_n,
  output   refclk_common_out,
                        
  output   drpclk       
                       
  );

//*********************************Wire Declarations**********************************
  wire            tied_to_ground_i;
  wire            tied_to_vcc_i;

  wire            tx_coreclk_pad;

  wire            rx_coreclk_pad;

  wire            core_clk;

//*********************************** Beginning of Code *******************************

  //  Static signal Assignments
  assign tied_to_ground_i    = 1'b0;
  assign tied_to_vcc_i       = 1'b1;


  assign tx_coreclk = core_clk_bufg;
  assign rx_coreclk = core_clk_bufg; 

  BUFG_GT i_coreclk_tx_ibufg
  (
    .O (core_clk_bufg),
    .I (core_clk)
  );

  IBUFDS_GTE3 #( 
  .REFCLK_HROW_CK_SEL(2'd0)
  ) i_refclk_common (
    .I  (refclk_common_p),
    .IB (refclk_common_n),
    .ODIV2           (core_clk),
    .CEB             (tied_to_ground_i),
    .O  (refclk_common_out)
  );

  BUFG i_coreclk_drp_ibufg
  (
    .O (drpclk),
    .I (drpclk_in)
  );
endmodule
