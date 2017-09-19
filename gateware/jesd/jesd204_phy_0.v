//----------------------------------------------------------------------------
// Title : JESD204 PHY Wrapper
// Project : JESD204 PHY
//----------------------------------------------------------------------------
// File : jesd204_phy_0.v
//----------------------------------------------------------------------------
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

`timescale 1ns / 1ps

(* CORE_GENERATION_INFO = "jesd204_phy_0,jesd204_phy_v3_4_0,{x_ipProduct=Vivado 2017.2,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=jesd204_phy,x_ipVersion=3.4,x_ipCoreRevision=0,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_COMPONENT_NAME=jesd204_phy_0,C_FAMILY=kintexu,C_SILICON_REVISION=,C_LANES=2,C_SPEEDGRADE=-2,C_SupportLevel=1,C_TransceiverControl=false,c_sub_core_name=jesd204_phy_0_gt,C_GT_Line_Rate=5.0,C_GT_REFCLK_FREQ=125,C_DRPCLK_FREQ=100.0,C_PLL_SELECTION=1,C_RX_GT_Line_Rate=5.0,C_RX_GT_REFCLK_FREQ=125,C_RX_PLL_SELECTION=1,C_QPLL_FBDIV=40,C_QPLL_REFCLKDIV=1,C_PLL0_FBDIV=1,C_PLL0_FBDIV_45=4,C_PLL0_REFCLKDIV=1,C_PLL1_FBDIV=1,C_PLL1_FBDIV_45=4,C_PLL1_REFCLKDIV=1,C_Axi_Lite=true,C_AXICLK_FREQ=100.0,C_Transceiver=GTHE3,C_GT_Loc=X0Y0,C_gt_val_extended_timeout=false,C_Tx_use_64b=0,C_Rx_use_64b=0,C_CHANNEL_POS=0,C_QUADS=1,C_Equalization_Mode=0,C_Rx_MasterChan=1,C_Tx_MasterChan=1,C_Ins_Loss=12,C_Config_Type=0,C_Min_Line_Rate=5.0,C_Max_Line_Rate=5.0,C_GT_ENUM=5}" *)
(* X_CORE_INFO = "jesd204_phy_v3_4_0,Vivado 2017.2" *)

//***********************************Entity Declaration************************
(* DowngradeIPIdentifiedWarnings="yes" *)
module jesd204_phy_0 (
  //---------------------------------------------------------------------------
  // AXI Lite IO
  //---------------------------------------------------------------------------
  input          s_axi_aclk,
  input          s_axi_aresetn,

  input  [11:0]  s_axi_awaddr,
  input          s_axi_awvalid,
  output         s_axi_awready,
  input  [31:0]  s_axi_wdata,
  input          s_axi_wvalid,
  output         s_axi_wready,
  output [1:0]   s_axi_bresp,
  output         s_axi_bvalid,
  input          s_axi_bready,
  input  [11:0]  s_axi_araddr,
  input          s_axi_arvalid,
  output         s_axi_arready,
  output [31:0]  s_axi_rdata,
  output [1:0]   s_axi_rresp,
  output         s_axi_rvalid,
  input          s_axi_rready,

  // System Reset Inputs for each direction
  input          tx_sys_reset,
  input          rx_sys_reset,

  // Reset Inputs for each direction
  input          tx_reset_gt,
  input          rx_reset_gt,

  // Reset Done for each direction
  output         tx_reset_done,
  output         rx_reset_done,

  output         gt_powergood,

  input          cpll_refclk,
  // GT Common I/O
  input          qpll0_refclk,
  output         common0_qpll0_lock_out,
  output         common0_qpll0_refclk_out,
  output         common0_qpll0_clk_out,

  input          qpll1_refclk,
  output         common0_qpll1_lock_out,
  output         common0_qpll1_refclk_out,
  output         common0_qpll1_clk_out,

  input          rxencommaalign,

  // Clocks
  input          tx_core_clk,
  output         txoutclk,

  input          rx_core_clk,
  output         rxoutclk,

  input          drpclk,

  // PRBS mode
  input  [3:0]   gt_prbssel,

  // Tx Ports
  // Lane 0
  input  [31:0]  gt0_txdata,
  input  [3:0]   gt0_txcharisk,

  // Lane 1
  input  [31:0]  gt1_txdata,
  input  [3:0]   gt1_txcharisk,

  // Rx Ports
  // Lane 0
  output [31:0]  gt0_rxdata,
  output [3:0]   gt0_rxcharisk,
  output [3:0]   gt0_rxdisperr,
  output [3:0]   gt0_rxnotintable,

  // Lane 1
  output [31:0]  gt1_rxdata,
  output [3:0]   gt1_rxcharisk,
  output [3:0]   gt1_rxdisperr,
  output [3:0]   gt1_rxnotintable,

  // Serial ports
  input  [1:0]   rxn_in,
  input  [1:0]   rxp_in,
  output [1:0]   txn_out,
  output [1:0]   txp_out
);

//------------------------------------------------------------
// Instantiate the JESD204 PHY core
//------------------------------------------------------------
jesd204_phy_0_support
inst(
  .s_axi_aclk                          (s_axi_aclk                    ),
  .s_axi_aresetn                       (s_axi_aresetn                 ),

  .s_axi_awaddr                        (s_axi_awaddr                  ),
  .s_axi_awvalid                       (s_axi_awvalid                 ),
  .s_axi_awready                       (s_axi_awready                 ),

  .s_axi_wdata                         (s_axi_wdata                   ),
  .s_axi_wvalid                        (s_axi_wvalid                  ),
  .s_axi_wready                        (s_axi_wready                  ),

  .s_axi_bresp                         (s_axi_bresp                   ),
  .s_axi_bvalid                        (s_axi_bvalid                  ),
  .s_axi_bready                        (s_axi_bready                  ),

  .s_axi_araddr                        (s_axi_araddr                  ),
  .s_axi_arvalid                       (s_axi_arvalid                 ),
  .s_axi_arready                       (s_axi_arready                 ),

  .s_axi_rdata                         (s_axi_rdata                   ),
  .s_axi_rresp                         (s_axi_rresp                   ),
  .s_axi_rvalid                        (s_axi_rvalid                  ),
  .s_axi_rready                        (s_axi_rready                  ),

  // Reset Done for each GT Channel
  .gt_txresetdone                      (                              ),
  .gt_rxresetdone                      (                              ),

  // CPLL Lock
  .gt_cplllock                         (                              ),

  .gt_txprbsforceerr                   (2'b0                          ),

  .gt_rxprbssel                        (8'b0                          ),
  .gt_rxprbscntreset                   (2'b0                          ),
  .gt_rxprbserr                        (                              ),

  // TX Reset and Initialization
  .gt_txpcsreset                       (2'b0                          ),
  .gt_txpmareset                       (2'b0                          ),

  // RX Reset and Initialization
  .gt_rxpcsreset                       (2'b0                          ),
  .gt_rxpmareset                       (2'b0                          ),
  .gt_rxbufreset                       (2'b0                          ),
  .gt_rxpmaresetdone                   (                              ),

  // TX Buffer Ports
  .gt_txbufstatus                      (                              ),

  // RX Buffer Ports
  .gt_rxbufstatus                      (                              ),

  // PCI Express Ports
  .gt_rxrate                           (6'b0                          ),

  // RX Margin Analysis Ports
  .gt_eyescantrigger                   (2'b0                          ),
  .gt_eyescanreset                     (2'b0                          ),
  .gt_eyescandataerror                 (                              ),

  // RX CDR Ports
  .gt_rxcdrhold                        (2'b0                          ),

  // RX Digital Monitor Ports
  .gt_dmonitorout                      (                              ),

  // RX Byte and Word Alignment Ports
  .gt_rxcommadet                       (                              ),

  // System Reset Inputs for each direction
  .tx_sys_reset                        (tx_sys_reset                  ),
  .rx_sys_reset                        (rx_sys_reset                  ),

  // Reset Inputs for each direction
  .tx_reset_gt                         (tx_reset_gt                   ),
  .rx_reset_gt                         (rx_reset_gt                   ),

  // Reset Done for each direction
  .tx_reset_done                       (tx_reset_done                 ),
  .rx_reset_done                       (rx_reset_done                 ),

  .gt_powergood                        (gt_powergood                  ),

  .cpll_refclk                         (cpll_refclk                   ),
  // GT Common I/O
  .qpll0_refclk                        (qpll0_refclk                  ),

  .common0_qpll0_lock_out              (common0_qpll0_lock_out        ),
  .common0_qpll0_refclk_out            (common0_qpll0_refclk_out      ),
  .common0_qpll0_clk_out               (common0_qpll0_clk_out         ),

  .qpll1_refclk                        (qpll1_refclk                  ),

  .common0_qpll1_lock_out              (common0_qpll1_lock_out        ),
  .common0_qpll1_refclk_out            (common0_qpll1_refclk_out      ),
  .common0_qpll1_clk_out               (common0_qpll1_clk_out         ),

  .rxencommaalign                      (rxencommaalign                ),

  // Clocks
  .tx_core_clk                         (tx_core_clk                   ),
  .txoutclk                            (txoutclk                      ),

  .rx_core_clk                         (rx_core_clk                   ),
  .rxoutclk                            (rxoutclk                      ),

  .drpclk                              (drpclk                        ),

  .gt_prbssel                          (gt_prbssel                    ),

  // Tx Ports
  // Lane 0
  .gt0_txdata                          (gt0_txdata                    ),
  .gt0_txcharisk                       (gt0_txcharisk                 ),

  // Lane 1
  .gt1_txdata                          (gt1_txdata                    ),
  .gt1_txcharisk                       (gt1_txcharisk                 ),

  // Rx Ports
  // Lane 0
  .gt0_rxdata                          (gt0_rxdata                    ),
  .gt0_rxcharisk                       (gt0_rxcharisk                 ),
  .gt0_rxdisperr                       (gt0_rxdisperr                 ),
  .gt0_rxnotintable                    (gt0_rxnotintable              ),

  // Lane 1
  .gt1_rxdata                          (gt1_rxdata                    ),
  .gt1_rxcharisk                       (gt1_rxcharisk                 ),
  .gt1_rxdisperr                       (gt1_rxdisperr                 ),
  .gt1_rxnotintable                    (gt1_rxnotintable              ),

  // Serial ports
  .rxn_in                              (rxn_in                        ),
  .rxp_in                              (rxp_in                        ),
  .txn_out                             (txn_out                       ),
  .txp_out                             (txp_out                       )
);

endmodule
