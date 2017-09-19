//----------------------------------------------------------------------------
// Title : Support Level Module
// Project : JESD204 PHY
//----------------------------------------------------------------------------
// File : jesd204_phy_support.v
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

(* DowngradeIPIdentifiedWarnings = "yes" *)
module jesd204_phy_0_support (
  //-----------------------------------------------------------------------------
  // AXI Lite IO
  //-----------------------------------------------------------------------------
  input               s_axi_aclk,
  input               s_axi_aresetn,

  input  [11:0]       s_axi_awaddr,
  input               s_axi_awvalid,
  output              s_axi_awready,
  input  [31:0]       s_axi_wdata,
  input               s_axi_wvalid,
  output              s_axi_wready,
  output [1:0]        s_axi_bresp,
  output              s_axi_bvalid,
  input               s_axi_bready,
  input  [11:0]       s_axi_araddr,
  input               s_axi_arvalid,
  output              s_axi_arready,
  output [31:0]       s_axi_rdata,
  output [1:0]        s_axi_rresp,
  output              s_axi_rvalid,
  input               s_axi_rready,

  // Additional GT signals for debug
  // CPLL Lock
  output [7:0]         gt_cplllock,

  // Reset Done for each GT Channel
  output [7:0]         gt_txresetdone,
  output [7:0]         gt_rxresetdone,

  // Pattern Checker ports
  input  [7:0]         gt_txprbsforceerr,

  input  [31:0]       gt_rxprbssel,
  input  [7:0]         gt_rxprbscntreset,
  output [7:0]         gt_rxprbserr,

  // RX Margin Analysis Ports
  input   [7:0]        gt_eyescantrigger,
  input   [7:0]        gt_eyescanreset,
  output  [7:0]        gt_eyescandataerror,

  // TX Reset and Initialization
  input   [7:0]        gt_txpmareset,
  input   [7:0]        gt_txpcsreset,

  // TX Buffer Ports
  output  [15:0]       gt_txbufstatus,

  // RX Reset and Initialization
  input   [7:0]        gt_rxpmareset,
  input   [7:0]        gt_rxpcsreset,
  input   [7:0]        gt_rxbufreset,
  output  [7:0]        gt_rxpmaresetdone,

  // RX CDR Ports
  input   [7:0]        gt_rxcdrhold,

  
  // RX Byte and Word Alignment Ports
  output  [7:0]        gt_rxcommadet,
  
  // RX Buffer Ports
  output  [23:0]        gt_rxbufstatus,

  // PCI Express Ports
  input  [23:0]         gt_rxrate,

  // RX Digital Monitor Ports
  output [135:0]       gt_dmonitorout,

  // System Reset Inputs for each direction
  input               tx_sys_reset,
  input               rx_sys_reset,
  
  // Reset Inputs for each direction
  input               tx_reset_gt,
  input               rx_reset_gt,

  // Reset Done for each direction
  output              tx_reset_done,
  output              rx_reset_done,

  output              gt_powergood,

  input               cpll_refclk,
  // GT Common 0 I/O
  input               qpll0_refclk,
  output              common0_qpll0_lock_out,
  output              common0_qpll0_refclk_out,
  output              common0_qpll0_clk_out,
  output              common1_qpll0_lock_out,
  output              common1_qpll0_refclk_out,
  output              common1_qpll0_clk_out,
  // GT Common 1 I/O
  input               qpll1_refclk,
  output              common0_qpll1_lock_out,
  output              common0_qpll1_refclk_out,
  output              common0_qpll1_clk_out,
  output              common1_qpll1_lock_out,
  output              common1_qpll1_refclk_out,
  output              common1_qpll1_clk_out,
 
  input               rxencommaalign,
  

  // Clocks
  output              txoutclk,
  input               tx_core_clk,

  output              rxoutclk,
  input               rx_core_clk,

  input               drpclk,

  // PRBS mode
  input    [3:0]      gt_prbssel,

  // Tx Ports
  // Lane 0
  input    [31:0]     gt0_txdata,
  input     [3:0]     gt0_txcharisk,
  
  // Lane 1
  input    [31:0]     gt1_txdata,
  input     [3:0]     gt1_txcharisk,
  
  // Lane 2
  input    [31:0]     gt2_txdata,
  input     [3:0]     gt2_txcharisk,
  
  // Lane 3
  input    [31:0]     gt3_txdata,
  input     [3:0]     gt3_txcharisk,
  
  // Lane 4
  input    [31:0]     gt4_txdata,
  input     [3:0]     gt4_txcharisk,
  
  // Lane 5
  input    [31:0]     gt5_txdata,
  input     [3:0]     gt5_txcharisk,
  
  // Lane 6
  input    [31:0]     gt6_txdata,
  input     [3:0]     gt6_txcharisk,
  
  // Lane 7
  input    [31:0]     gt7_txdata,
  input     [3:0]     gt7_txcharisk,
  
  // Rx Ports
  // Lane 0
  output   [31:0]     gt0_rxdata,
  output    [3:0]     gt0_rxcharisk,
  output    [3:0]     gt0_rxdisperr,
  output    [3:0]     gt0_rxnotintable,  

  // Lane 1
  output   [31:0]     gt1_rxdata,
  output    [3:0]     gt1_rxcharisk,
  output    [3:0]     gt1_rxdisperr,
  output    [3:0]     gt1_rxnotintable,  

  // Lane 2
  output   [31:0]     gt2_rxdata,
  output    [3:0]     gt2_rxcharisk,
  output    [3:0]     gt2_rxdisperr,
  output    [3:0]     gt2_rxnotintable,  

  // Lane 3
  output   [31:0]     gt3_rxdata,
  output    [3:0]     gt3_rxcharisk,
  output    [3:0]     gt3_rxdisperr,
  output    [3:0]     gt3_rxnotintable,  

  // Lane 4
  output   [31:0]     gt4_rxdata,
  output    [3:0]     gt4_rxcharisk,
  output    [3:0]     gt4_rxdisperr,
  output    [3:0]     gt4_rxnotintable,  

  // Lane 5
  output   [31:0]     gt5_rxdata,
  output    [3:0]     gt5_rxcharisk,
  output    [3:0]     gt5_rxdisperr,
  output    [3:0]     gt5_rxnotintable,  

  // Lane 6
  output   [31:0]     gt6_rxdata,
  output    [3:0]     gt6_rxcharisk,
  output    [3:0]     gt6_rxdisperr,
  output    [3:0]     gt6_rxnotintable,  

  // Lane 7
  output   [31:0]     gt7_rxdata,
  output    [3:0]     gt7_rxcharisk,
  output    [3:0]     gt7_rxdisperr,
  output    [3:0]     gt7_rxnotintable,  

  // Serial ports
  input      [7:0]    rxn_in,
  input      [7:0]    rxp_in,
  output     [7:0]    txn_out,
  output     [7:0]    txp_out

);

//*******************************************
// Wire Declarations
//*******************************************
  // GT Common I/O
  wire          common0_qpll0_lock_i;
  wire          common0_qpll0_refclk_i;
  wire          common0_qpll0_clk_i;

  wire          common1_qpll0_lock_i;
  wire          common1_qpll0_refclk_i;
  wire          common1_qpll0_clk_i;

  wire          qpll0_reset_i;
  wire          qpll1_reset_i;
  wire  [8:0]   common0_drpaddr;
  wire  [15:0]  common0_drpdi;
  wire          common0_drpen;
  wire          common0_drpwe;
  wire  [15:0]  common0_drpdo;
  wire          common0_drprdy;

  wire          common0_qpll0_pd;
  wire          common0_qpll1_pd;

  wire  [8:0]   common1_drpaddr;
  wire  [15:0]  common1_drpdi;
  wire          common1_drpen;
  wire          common1_drpwe;
  wire  [15:0]  common1_drpdo;
  wire          common1_drprdy;

  wire          common1_qpll0_pd;
  wire          common1_qpll1_pd;


  wire          txoutclk_i;
  assign txoutclk  = txoutclk_i;
  
  wire          rxoutclk_i;
  assign rxoutclk  =  rxoutclk_i;

//*******************************************
// JESD204 PHY Core
//*******************************************
jesd204_phy_0_block
jesd204_phy_block_i
 (
  // Reset Done for each GT Channel
  .gt_txresetdone          (gt_txresetdone),
  .gt_rxresetdone          (gt_rxresetdone),

  // CPLL Lock for each GT Channel
  .gt_cplllock             (gt_cplllock),

  // Pattern Checker ports
  .gt_txprbsforceerr       (gt_txprbsforceerr),

  .gt_rxprbssel            (gt_rxprbssel),
  .gt_rxprbscntreset       (gt_rxprbscntreset),
  .gt_rxprbserr            (gt_rxprbserr),

  // TX Reset and Initialization
  .gt_txpcsreset           (gt_txpcsreset),
  .gt_txpmareset           (gt_txpmareset),

  // RX Reset and Initialization
  .gt_rxpcsreset           (gt_rxpcsreset),
  .gt_rxpmareset           (gt_rxpmareset),
  .gt_rxbufreset           (gt_rxbufreset),
  .gt_rxpmaresetdone       (gt_rxpmaresetdone),

  // TX Buffer Ports
  .gt_txbufstatus          (gt_txbufstatus),

  // RX Buffer Ports
  .gt_rxbufstatus          (gt_rxbufstatus),

  // PCI Express Ports
  .gt_rxrate               (gt_rxrate),

  // RX Margin Analysis Ports
  .gt_eyescantrigger       (gt_eyescantrigger),
  .gt_eyescanreset         (gt_eyescanreset),
  .gt_eyescandataerror     (gt_eyescandataerror),

  // RX CDR Ports
  .gt_rxcdrhold            (gt_rxcdrhold),

  // RX Digital Monitor Ports
  .gt_dmonitorout          (gt_dmonitorout),

  // RX Byte and Word Alignment Ports
  .gt_rxcommadet           (gt_rxcommadet),
  
  // Common 0 DRP Ports
  .common0_drpaddr         (common0_drpaddr),
  .common0_drpdi           (common0_drpdi),
  .common0_drpen           (common0_drpen),
  .common0_drpwe           (common0_drpwe),
  .common0_drpdo           (common0_drpdo),
  .common0_drprdy          (common0_drprdy),

  // Common 0 QPLL Power Down Ports
  .common0_qpll0_pd        (common0_qpll0_pd),
  .common0_qpll1_pd        (common0_qpll1_pd),

  // Common 1 DRP Ports
  .common1_drpaddr         (common1_drpaddr),
  .common1_drpdi           (common1_drpdi),
  .common1_drpen           (common1_drpen),
  .common1_drpwe           (common1_drpwe),
  .common1_drpdo           (common1_drpdo),
  .common1_drprdy          (common1_drprdy),

  // Common 1 QPLL Power Down Ports
  .common1_qpll0_pd        (common1_qpll0_pd),
  .common1_qpll1_pd        (common1_qpll1_pd),

  // System Reset Inputs for each direction
  .tx_sys_reset            (tx_sys_reset),
  .rx_sys_reset            (rx_sys_reset),
  
  // Reset Inputs for each direction
  .tx_reset_gt             (tx_reset_gt),
  .rx_reset_gt             (rx_reset_gt),

  // Reset Done for each direction
  .tx_reset_done           (tx_reset_done),
  .rx_reset_done           (rx_reset_done),

  .gt_powergood            (gt_powergood),

  .cpll_refclk             (cpll_refclk),
  
  .qpll0_reset_out         (qpll0_reset_i),
  .qpll1_reset_out         (qpll1_reset_i),
  // GT Common I/O
  .common0_qpll0_lock_in   (common0_qpll0_lock_i),
  .common0_qpll0_refclk_in (common0_qpll0_refclk_i),
  .common0_qpll0_clk_in    (common0_qpll0_clk_i),
  .common1_qpll0_lock_in   (common1_qpll0_lock_i),
  .common1_qpll0_refclk_in (common1_qpll0_refclk_i),
  .common1_qpll0_clk_in    (common1_qpll0_clk_i),
  .common0_qpll1_lock_in   (common0_qpll1_lock_i),
  .common0_qpll1_refclk_in (common0_qpll1_refclk_i),
  .common0_qpll1_clk_in    (common0_qpll1_clk_i),
  .common1_qpll1_lock_in   (common1_qpll1_lock_i),
  .common1_qpll1_refclk_in (common1_qpll1_refclk_i),
  .common1_qpll1_clk_in    (common1_qpll1_clk_i),
 
  .rxencommaalign          (rxencommaalign),
  
  // Clocks
  .tx_core_clk             (tx_core_clk),
  .txoutclk                (txoutclk_i),

  .rx_core_clk             (rx_core_clk),  
  .rxoutclk                (rxoutclk_i),

  .drpclk                  (drpclk),

  .gt_prbssel              (gt_prbssel),

  // Tx Ports
  // Lane 0
  .gt0_txdata              (gt0_txdata),
  .gt0_txcharisk           (gt0_txcharisk),

  // Lane 1
  .gt1_txdata              (gt1_txdata),
  .gt1_txcharisk           (gt1_txcharisk),

  // Lane 2
  .gt2_txdata              (gt2_txdata),
  .gt2_txcharisk           (gt2_txcharisk),

  // Lane 3
  .gt3_txdata              (gt3_txdata),
  .gt3_txcharisk           (gt3_txcharisk),

  // Lane 4
  .gt4_txdata              (gt4_txdata),
  .gt4_txcharisk           (gt4_txcharisk),

  // Lane 5
  .gt5_txdata              (gt5_txdata),
  .gt5_txcharisk           (gt5_txcharisk),

  // Lane 6
  .gt6_txdata              (gt6_txdata),
  .gt6_txcharisk           (gt6_txcharisk),

  // Lane 7
  .gt7_txdata              (gt7_txdata),
  .gt7_txcharisk           (gt7_txcharisk),

  // Rx Ports
  // Lane 0
  .gt0_rxdata              (gt0_rxdata),
  .gt0_rxcharisk           (gt0_rxcharisk),
  .gt0_rxdisperr           (gt0_rxdisperr),
  .gt0_rxnotintable        (gt0_rxnotintable),

  // Lane 1
  .gt1_rxdata              (gt1_rxdata),
  .gt1_rxcharisk           (gt1_rxcharisk),
  .gt1_rxdisperr           (gt1_rxdisperr),
  .gt1_rxnotintable        (gt1_rxnotintable),

  // Lane 2
  .gt2_rxdata              (gt2_rxdata),
  .gt2_rxcharisk           (gt2_rxcharisk),
  .gt2_rxdisperr           (gt2_rxdisperr),
  .gt2_rxnotintable        (gt2_rxnotintable),

  // Lane 3
  .gt3_rxdata              (gt3_rxdata),
  .gt3_rxcharisk           (gt3_rxcharisk),
  .gt3_rxdisperr           (gt3_rxdisperr),
  .gt3_rxnotintable        (gt3_rxnotintable),

  // Lane 4
  .gt4_rxdata              (gt4_rxdata),
  .gt4_rxcharisk           (gt4_rxcharisk),
  .gt4_rxdisperr           (gt4_rxdisperr),
  .gt4_rxnotintable        (gt4_rxnotintable),

  // Lane 5
  .gt5_rxdata              (gt5_rxdata),
  .gt5_rxcharisk           (gt5_rxcharisk),
  .gt5_rxdisperr           (gt5_rxdisperr),
  .gt5_rxnotintable        (gt5_rxnotintable),

  // Lane 6
  .gt6_rxdata              (gt6_rxdata),
  .gt6_rxcharisk           (gt6_rxcharisk),
  .gt6_rxdisperr           (gt6_rxdisperr),
  .gt6_rxnotintable        (gt6_rxnotintable),

  // Lane 7
  .gt7_rxdata              (gt7_rxdata),
  .gt7_rxcharisk           (gt7_rxcharisk),
  .gt7_rxdisperr           (gt7_rxdisperr),
  .gt7_rxnotintable        (gt7_rxnotintable),

//-----------------------------------------------------------------------------
// AXI interface for PHYCore
//-----------------------------------------------------------------------------
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

  // Serial ports
  .rxn_in                  (rxn_in),
  .rxp_in                  (rxp_in),
  .txn_out                 (txn_out),
  .txp_out                 (txp_out)
  );

//*******************************************
//Instantiate Common GT Module
//*******************************************
jesd204_phy_0_gt_common_wrapper
jesd204_phy_gt_common_0_i
  (
  //DRP Ports
  .common_drpclk           (drpclk),
  .common_drpaddr          (common0_drpaddr),
  .common_drpdi            (common0_drpdi),
  .common_drpen            (common0_drpen),
  .common_drpwe            (common0_drpwe),
  .common_drpdo            (common0_drpdo),
  .common_drprdy           (common0_drprdy),

  //QPLL0 Ports
  .common_gtrefclk0        (qpll0_refclk),
  .common_qpll0_reset      (qpll0_reset_i),
  .common_qpll0_lock       (common0_qpll0_lock_i),
  .common_qpll0_outrefclk  (common0_qpll0_refclk_i),
  .common_qpll0_outclk     (common0_qpll0_clk_i),
  .common_qpll0_pd         (common0_qpll0_pd),

  //QPLL1 Ports
  .common_gtrefclk1        (qpll1_refclk),
  .common_qpll1_reset      (qpll1_reset_i),
  .common_qpll1_lock       (common0_qpll1_lock_i),
  .common_qpll1_outrefclk  (common0_qpll1_refclk_i),
  .common_qpll1_outclk     (common0_qpll1_clk_i),
  .common_qpll1_pd         (common0_qpll1_pd)

  );

jesd204_phy_0_gt_common_wrapper
jesd204_phy_gt_common_1_i
  (
  //DRP Ports
  .common_drpclk           (drpclk),
  .common_drpaddr          (common1_drpaddr),
  .common_drpdi            (common1_drpdi),
  .common_drpen            (common1_drpen),
  .common_drpwe            (common1_drpwe),
  .common_drpdo            (common1_drpdo),
  .common_drprdy           (common1_drprdy),

  //QPLL0 Ports
  .common_gtrefclk0        (qpll0_refclk),
  .common_qpll0_reset      (qpll0_reset_i),
  .common_qpll0_lock       (common1_qpll0_lock_i),
  .common_qpll0_outrefclk  (common1_qpll0_refclk_i),
  .common_qpll0_outclk     (common1_qpll0_clk_i),
  .common_qpll0_pd         (common1_qpll0_pd),

  //QPLL1 Ports
  .common_gtrefclk1        (qpll1_refclk),
  .common_qpll1_reset      (qpll1_reset_i),
  .common_qpll1_lock       (common1_qpll1_lock_i),
  .common_qpll1_outrefclk  (common1_qpll1_refclk_i),
  .common_qpll1_outclk     (common1_qpll1_clk_i),
  .common_qpll1_pd         (common1_qpll1_pd)
  );

  // Assign QPLL0 Common Output Ports
  assign common0_qpll0_lock_out    =  common0_qpll0_lock_i;
  assign common0_qpll0_refclk_out  =  common0_qpll0_refclk_i;
  assign common0_qpll0_clk_out     =  common0_qpll0_clk_i;
  assign common1_qpll0_lock_out    =  common1_qpll0_lock_i;
  assign common1_qpll0_refclk_out  =  common1_qpll0_refclk_i;
  assign common1_qpll0_clk_out     =  common1_qpll0_clk_i;

  // Assign QPLL1 Common Output Ports
  assign common0_qpll1_lock_out    =  common0_qpll1_lock_i;
  assign common0_qpll1_refclk_out  =  common0_qpll1_refclk_i;
  assign common0_qpll1_clk_out     =  common0_qpll1_clk_i;
  assign common1_qpll1_lock_out    =  common1_qpll1_lock_i;
  assign common1_qpll1_refclk_out  =  common1_qpll1_refclk_i;
  assign common1_qpll1_clk_out     =  common1_qpll1_clk_i;

endmodule
