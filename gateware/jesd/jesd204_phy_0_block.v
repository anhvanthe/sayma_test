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
`define DLY #1

//***********************************Entity Declaration************************
(* DowngradeIPIdentifiedWarnings="yes" *)
module jesd204_phy_0_block (
  //-----------------------------------------------------------------------------
  // AXI Lite IO
  //-----------------------------------------------------------------------------
  input               s_axi_aclk,
  input               s_axi_aresetn,

  input      [11:0]   s_axi_awaddr,
  input               s_axi_awvalid,
  output              s_axi_awready,
  input      [31:0]   s_axi_wdata,
  input               s_axi_wvalid,
  output              s_axi_wready,
  output     [1:0]    s_axi_bresp,
  output              s_axi_bvalid,
  input               s_axi_bready,
  input      [11:0]   s_axi_araddr,
  input               s_axi_arvalid,
  output              s_axi_arready,
  output     [31:0]   s_axi_rdata,
  output     [1:0]    s_axi_rresp,
  output              s_axi_rvalid,
  input               s_axi_rready,

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

  // Reset Done for each GT Channel
  output     [1:0]    gt_txresetdone,
  output     [1:0]    gt_rxresetdone,

  input               cpll_refclk,
  
  output              qpll0_reset_out,
  output              qpll1_reset_out,
  // GT Common I/O
  input               common0_qpll0_lock_in,
  input               common0_qpll0_refclk_in,
  input               common0_qpll0_clk_in,

  input               common0_qpll1_lock_in,
  input               common0_qpll1_refclk_in,
  input               common0_qpll1_clk_in,
  input               rxencommaalign,
  // Clocks
  input               tx_core_clk,
  output              txoutclk,

  input               rx_core_clk,
  output              rxoutclk,

  input               drpclk,

  // CPLL Lock
  output     [1:0]    gt_cplllock,

  // Common 0 DRP Ports
  output [8:0]        common0_drpaddr,
  output [15:0]       common0_drpdi,
  output              common0_drpen,
  output              common0_drpwe,
  input  [15:0]       common0_drpdo,
  input               common0_drprdy,

  // Common 0 QPLL Power Down Ports
  output              common0_qpll0_pd,
  output              common0_qpll1_pd,

  // Pattern Checker ports
  input  [3:0]        gt_prbssel,
  input      [1:0]    gt_txprbsforceerr,

  input      [7:0]    gt_rxprbssel,
  input      [1:0]    gt_rxprbscntreset,
  output     [1:0]    gt_rxprbserr,

  // TX Reset and Initialization
  input      [1:0]     gt_txpmareset,
  input      [1:0]     gt_txpcsreset,

  // RX Reset and Initialization
  input      [1:0]     gt_rxpmareset,
  input      [1:0]     gt_rxpcsreset,
  input      [1:0]     gt_rxbufreset,
  output     [1:0]     gt_rxpmaresetdone,

  // TX Buffer Ports
  output     [3:0]    gt_txbufstatus,

  // RX Buffer Ports
  output     [5:0]    gt_rxbufstatus,

  // PCI Express Ports
  input      [5:0]    gt_rxrate,

  // RX Margin Analysis Ports
  input      [1:0]     gt_eyescantrigger,
  input      [1:0]     gt_eyescanreset,
  output     [1:0]     gt_eyescandataerror,

  // RX CDR Ports
  input      [1:0]     gt_rxcdrhold,

  // RX Digital Monitor Ports
  output     [33:0]   gt_dmonitorout,

  // RX Byte and Word Alignment Ports
  output      [1:0]    gt_rxcommadet,

  // Tx Ports
  // Lane 0
  input    [31:0]    gt0_txdata,
  input     [3:0]    gt0_txcharisk,

  // Lane 1
  input    [31:0]    gt1_txdata,
  input     [3:0]    gt1_txcharisk,

  // Rx Ports
  // Lane 0
  output   [31:0]    gt0_rxdata,
  output    [3:0]    gt0_rxcharisk,
  output    [3:0]    gt0_rxdisperr,
  output    [3:0]    gt0_rxnotintable,

  // Lane 1
  output   [31:0]    gt1_rxdata,
  output    [3:0]    gt1_rxcharisk,
  output    [3:0]    gt1_rxdisperr,
  output    [3:0]    gt1_rxnotintable,

  // Serial ports
  input     [1:0]   rxn_in,
  input     [1:0]   rxp_in,
  output    [1:0]   txn_out,
  output    [1:0]   txp_out
);

  //pll_sel = 0: CPLL is in use
  //pll_sel = 1: QPLL0 is in use
  //pll_sel = 2: QPLL1 is in use
  localparam tx_pll_sel = 1;
  localparam rx_pll_sel = 1;

//************************** Register Declarations ****************************
  wire            gtpowergood_i;
  reg             txresetdone_i2;
  reg             rxresetdone_i2;
  wire            gt_txresetdone_sync;
  wire            gt_rxresetdone_sync;
  wire            txresetdone_sync;
  wire            rxresetdone_sync;

  wire            tx_rst_all;
  wire            rx_rst_all;
  wire            tx_rst_data;
  wire            rx_rst_data;
  wire            txreset_good;     // Datapath only reset
  wire            rxreset_good;
  wire            txreset_good_all; // PLL & data path resets
  wire            rxreset_good_all;
  wire            gtwiz_userclk_tx_reset_int;
  wire            gtwiz_userclk_rx_reset_int;
  (* ASYNC_REG = "TRUE" *) reg gtwiz_userclk_tx_active_meta = 1'b0;
  (* ASYNC_REG = "TRUE" *) reg gtwiz_userclk_tx_active_sync = 1'b0;
  wire            gtwiz_userclk_tx_active_out;
  (* ASYNC_REG = "TRUE" *) reg gtwiz_userclk_rx_active_meta = 1'b0;
  (* ASYNC_REG = "TRUE" *) reg gtwiz_userclk_rx_active_sync = 1'b0;
  wire            gtwiz_userclk_rx_active_out;

  wire   [17 : 0] cpll_cal_cnt_per;
  wire   [17 : 0] cpll_cal_cnt_tol;
  //----------------------------- Global Signals -----------------------------
  reg             tx_pll_lock;
  wire            tx_pll_lock_i;
  reg             rx_pll_lock;
  wire            rx_pll_lock_i;

  wire            tx_sys_reset_sync;
  wire            rx_sys_reset_sync;

  // GT Reset block signals
  wire            rxcdrlock_in;
  wire            pllreset_tx_out;
  wire            txprogdivreset_out;
  wire            gttxreset_out;
  wire            txuserrdy_out;
  wire            pllreset_rx_out;
  wire            rxprogdivreset_out;
  wire            gtrxreset_out;
  wire            rxuserrdy_out;
  wire            tx_reset_gt_sync;
  wire            rx_reset_gt_sync;
  wire  [1:0]     rxresetdone;
  wire  [1:0]     txresetdone;
  
  // Register resetdone straight from transceiver. This is a non critical path and
  // net delays on 8-12 designs can become critical
  reg   [1:0]     rxresetdone_r;
  reg   [1:0]     txresetdone_r;




  wire  [1:0]     gt_rxoshold;
  wire  [1:0]     gt_rxdfeagchold;
  wire  [1:0]     gt_rxdfelfhold;
  wire  [1:0]     gt_rxdfeuthold;
  wire  [1:0]     gt_rxdfevphold;
  wire  [1:0]     gt_rxdfetap2hold;
  wire  [1:0]     gt_rxdfetap3hold;
  wire  [1:0]     gt_rxdfetap4hold;
  wire  [1:0]     gt_rxdfetap5hold;
  wire  [1:0]     gt_rxdfetap6hold;
  wire  [1:0]     gt_rxdfetap7hold;
  wire  [1:0]     gt_rxdfetap8hold;
  wire  [1:0]     gt_rxdfetap9hold;
  wire  [1:0]     gt_rxdfetap10hold;
  wire  [1:0]     gt_rxdfetap11hold;
  wire  [1:0]     gt_rxdfetap12hold;
  wire  [1:0]     gt_rxdfetap13hold;
  wire  [1:0]     gt_rxdfetap14hold;
  wire  [1:0]     gt_rxdfetap15hold;

  wire            s_drp_reset;
  wire            tx_core_reset;
  wire            rx_core_reset;

  wire [1:0]      txsysclksel_axi;
  wire [1:0]      rxsysclksel_axi;

  wire            rx_sys_reset_axi; // AXI version of RX system reset
  wire            tx_sys_reset_axi; // AXI version of TX system reset
  
  // RX Equalizer Ports
  wire            rxdfelpmreset_axi;
  wire            rxlpmen_axi;
  wire            rxoshold_axi;
  wire            rxdfeagchold_axi;
  wire            rxdfelfhold_axi;
  wire            rxdfeuthold_axi;
  wire            rxdfevphold_axi;
  wire            rxdfetap2hold_axi;
  wire            rxdfetap3hold_axi;
  wire            rxdfetap4hold_axi;
  wire            rxdfetap5hold_axi;
  wire            rxdfetap6hold_axi;
  wire            rxdfetap7hold_axi;
  wire            rxdfetap8hold_axi;
  wire            rxdfetap9hold_axi;
  wire            rxdfetap10hold_axi;
  wire            rxdfetap11hold_axi;
  wire            rxdfetap12hold_axi;
  wire            rxdfetap13hold_axi;
  wire            rxdfetap14hold_axi;
  wire            rxdfetap15hold_axi;

  wire  [1:0]      gt_rxdfelpmreset;
  wire  [1:0]      gt_rxlpmen;

  // Loopback
  wire  [5:0]    gt_loopback;

  // Power Down
  wire  [3:0]    gt_rxpd;
  wire  [3:0]    gt_txpd;
  reg   [1:0]      gt_rxpd_r;
  wire  [1:0]      gt_rxpd_i;
  wire  [1:0]      gt_rxpd_sync;
 
  wire  [3:0]    txpllclksel_axi;
  wire  [3:0]    rxpllclksel_axi;

  // Transmit Control
  wire  [9:0]    gt_txpostcursor;
  wire  [9:0]    gt_txprecursor;
  wire  [7:0]    gt_txdiffctrl;

  wire  [1:0]     gt_txpolarity;
  wire  [1:0]     gt_rxpolarity;

  wire  [31: 0]  gt_pcsrsvdin;

  wire  [1:0]     gt_txinhibit;

  wire            cpll_pd_0;
  wire            cpll_pd_1;

  // Channel DRP Wires
  wire  [8:0]     gt0_drpaddr;
  wire  [15:0]    gt0_drpdi;
  wire            gt0_drpen;
  wire            gt0_drpwe;
  wire  [15:0]    gt0_drpdo;
  wire            gt0_drprdy;

  wire  [8:0]     gt1_drpaddr;
  wire  [15:0]    gt1_drpdi;
  wire            gt1_drpen;
  wire            gt1_drpwe;
  wire  [15:0]    gt1_drpdo;
  wire            gt1_drprdy;


  //Wire declaration for GTHE3
    wire [1 : 0] cplllock_out;
  wire [1 : 0] cpllpd_in;
  wire [1 : 0] cpllreset_in;
  wire [33 : 0] dmonitorout_out;
  wire [17 : 0] drpaddr_in;
  wire [1 : 0] drpclk_in;
  wire [31 : 0] drpdi_in;
  wire [31 : 0] drpdo_out;
  wire [1 : 0] drpen_in;
  wire [1 : 0] drprdy_out;
  wire [1 : 0] drpwe_in;
  wire [1 : 0] eyescandataerror_out;
  wire [1 : 0] eyescanreset_in;
  wire [1 : 0] eyescantrigger_in;
  wire [1 : 0] gthrxn_in;
  wire [1 : 0] gthrxp_in;
  wire [1 : 0] gthtxn_out;
  wire [1 : 0] gthtxp_out;
  wire [1 : 0] gtpowergood_out;
  wire [1 : 0] gtrefclk0_in;
  wire [1 : 0] gtrxreset_in;
  wire [1 : 0] gttxreset_in;
  wire [0 : 0] gtwiz_reset_rx_done_in;
  wire [0 : 0] gtwiz_reset_tx_done_in;
  wire [0 : 0] gtwiz_userclk_rx_active_in;
  wire [0 : 0] gtwiz_userclk_tx_active_in;
  wire [5 : 0] loopback_in;
  wire [31 : 0] pcsrsvdin_in;
  wire [1 : 0] qpll0clk_in;
  wire [1 : 0] qpll0refclk_in;
  wire [1 : 0] qpll1clk_in;
  wire [1 : 0] qpll1refclk_in;
  wire [1 : 0] rx8b10ben_in;
  wire [1 : 0] rxbufreset_in;
  wire [5 : 0] rxbufstatus_out;
  wire [1 : 0] rxbyteisaligned_out;
  wire [1 : 0] rxbyterealign_out;
  wire [1 : 0] rxcdrhold_in;
  wire [1 : 0] rxcdrlock_out;
  wire [1 : 0] rxcommadet_out;
  wire [1 : 0] rxcommadeten_in;
  wire [31 : 0] rxctrl0_out;
  wire [31 : 0] rxctrl1_out;
  wire [15 : 0] rxctrl2_out;
  wire [15 : 0] rxctrl3_out;
  wire [255 : 0] rxdata_out;
  wire [1 : 0] rxdfeagchold_in;
  wire [1 : 0] rxdfelfhold_in;
  wire [1 : 0] rxdfelpmreset_in;
  wire [1 : 0] rxdfetap10hold_in;
  wire [1 : 0] rxdfetap11hold_in;
  wire [1 : 0] rxdfetap12hold_in;
  wire [1 : 0] rxdfetap13hold_in;
  wire [1 : 0] rxdfetap14hold_in;
  wire [1 : 0] rxdfetap15hold_in;
  wire [1 : 0] rxdfetap2hold_in;
  wire [1 : 0] rxdfetap3hold_in;
  wire [1 : 0] rxdfetap4hold_in;
  wire [1 : 0] rxdfetap5hold_in;
  wire [1 : 0] rxdfetap6hold_in;
  wire [1 : 0] rxdfetap7hold_in;
  wire [1 : 0] rxdfetap8hold_in;
  wire [1 : 0] rxdfetap9hold_in;
  wire [1 : 0] rxdfeuthold_in;
  wire [1 : 0] rxdfevphold_in;
  wire [1 : 0] rxlpmen_in;
  wire [1 : 0] rxmcommaalignen_in;
  wire [1 : 0] rxoshold_in;
  wire [1 : 0] rxoutclk_out;
  wire [1 : 0] rxpcommaalignen_in;
  wire [1 : 0] rxpcsreset_in;
  wire [3 : 0] rxpd_in;
  wire [3 : 0] rxpllclksel_in;
  wire [1 : 0] rxpmareset_in;
  wire [1 : 0] rxpmaresetdone_out;
  wire [1 : 0] rxpolarity_in;
  wire [1 : 0] rxprbscntreset_in;
  wire [1 : 0] rxprbserr_out;
  wire [7 : 0] rxprbssel_in;
  wire [1 : 0] rxprogdivreset_in;
  wire [5 : 0] rxrate_in;
  wire [1 : 0] rxresetdone_out;
  wire [3 : 0] rxsysclksel_in;
  wire [1 : 0] rxuserrdy_in;
  wire [1 : 0] rxusrclk2_in;
  wire [1 : 0] rxusrclk_in;
  wire [1 : 0] tx8b10ben_in;
  wire [3 : 0] txbufstatus_out;
  wire [31 : 0] txctrl0_in;
  wire [31 : 0] txctrl1_in;
  wire [15 : 0] txctrl2_in;
  wire [255 : 0] txdata_in;
  wire [7 : 0] txdiffctrl_in;
  wire [1 : 0] txinhibit_in;
  wire [1 : 0] txoutclk_out;
  wire [1 : 0] txpcsreset_in;
  wire [3 : 0] txpd_in;
  wire [3 : 0] txpllclksel_in;
  wire [1 : 0] txpmareset_in;
  wire [1 : 0] txpmaresetdone_out;
  wire [1 : 0] txpolarity_in;
  wire [9 : 0] txpostcursor_in;
  wire [1 : 0] txprbsforceerr_in;
  wire [7 : 0] txprbssel_in;
  wire [9 : 0] txprecursor_in;
  wire [1 : 0] txprogdivreset_in;
  wire [1 : 0] txresetdone_out;
  wire [3 : 0] txsysclksel_in;
  wire [1 : 0] txuserrdy_in;
  wire [1 : 0] txusrclk2_in;
  wire [1 : 0] txusrclk_in;

  // Connect the TX data and control inputs to the GT wizard block.
  // Tie unused GT wizard inputs to 0.
  assign txctrl2_in[3:0]    = gt0_txcharisk;
  assign txdata_in[31:0]    = gt0_txdata;
  assign txctrl2_in[7:4]    = 0;
  assign txdata_in[127:32]  = 0;
  assign txctrl2_in[11:8]   = gt1_txcharisk;
  assign txdata_in[159:128] = gt1_txdata;
  assign txctrl2_in[15:12]  = 0;
  assign txdata_in[255:160] = 0;

  // Connect up the GT outputs to the received data and control outputs
  assign gt0_rxdata       = rxdata_out[31:0];
  assign gt0_rxcharisk    = rxctrl0_out[3:0];
  assign gt0_rxdisperr    = rxctrl1_out[3:0];
  assign gt0_rxnotintable = rxctrl3_out[3:0];
  assign gt1_rxdata       = rxdata_out[159:128];
  assign gt1_rxcharisk    = rxctrl0_out[19:16];
  assign gt1_rxdisperr    = rxctrl1_out[19:16];
  assign gt1_rxnotintable = rxctrl3_out[11:8];

  // Connect up the GT DRP bus to the DRP inputs and outputs.
  // Tie unused GT wizard inputs to 0.
  assign drpclk_in        = {2{drpclk}};

  assign drpaddr_in        = {gt1_drpaddr,gt0_drpaddr};
  assign drpdi_in          = {gt1_drpdi,gt0_drpdi};
  assign drpen_in          = {gt1_drpen,gt0_drpen};
  assign drpwe_in          = {gt1_drpwe,gt0_drpwe};

  assign gt0_drpdo         = drpdo_out[15:0];
  assign gt1_drpdo         = drpdo_out[31:16];

  assign gt0_drprdy        = drprdy_out[0:0];
  assign gt1_drprdy        = drprdy_out[1:1];

  //***********************************************************************//
  //                                                                       //
  //--------------------------- The GT Wrapper ----------------------------//
  //                                                                       //
  //***********************************************************************//

  jesd204_phy_0_gt jesd204_phy_0_gt_i
  (
   .cplllock_out(cplllock_out),
   .cpllpd_in(cpllpd_in),
   .cpllreset_in(cpllreset_in),
   .dmonitorout_out(dmonitorout_out),
   .drpaddr_in(drpaddr_in),
   .drpclk_in(drpclk_in),
   .drpdi_in(drpdi_in),
   .drpdo_out(drpdo_out),
   .drpen_in(drpen_in),
   .drprdy_out(drprdy_out),
   .drpwe_in(drpwe_in),
   .eyescandataerror_out(eyescandataerror_out),
   .eyescanreset_in(eyescanreset_in),
   .eyescantrigger_in(eyescantrigger_in),
   .gthrxn_in(gthrxn_in),
   .gthrxp_in(gthrxp_in),
   .gthtxn_out(gthtxn_out),
   .gthtxp_out(gthtxp_out),
   .gtpowergood_out(gtpowergood_out),
   .gtrefclk0_in(gtrefclk0_in),
   .gtrxreset_in(gtrxreset_in),
   .gttxreset_in(gttxreset_in),
   .gtwiz_reset_rx_done_in(gtwiz_reset_rx_done_in),
   .gtwiz_reset_tx_done_in(gtwiz_reset_tx_done_in),
   .gtwiz_userclk_rx_active_in(gtwiz_userclk_rx_active_in),
   .gtwiz_userclk_tx_active_in(gtwiz_userclk_tx_active_in),
   .loopback_in(loopback_in),
   .pcsrsvdin_in(pcsrsvdin_in),
   .qpll0clk_in(qpll0clk_in),
   .qpll0refclk_in(qpll0refclk_in),
   .qpll1clk_in(qpll1clk_in),
   .qpll1refclk_in(qpll1refclk_in),
   .rx8b10ben_in(rx8b10ben_in),
   .rxbufreset_in(rxbufreset_in),
   .rxbufstatus_out(rxbufstatus_out),
   .rxbyteisaligned_out(rxbyteisaligned_out),
   .rxbyterealign_out(rxbyterealign_out),
   .rxcdrhold_in(rxcdrhold_in),
   .rxcdrlock_out(rxcdrlock_out),
   .rxcommadet_out(rxcommadet_out),
   .rxcommadeten_in(rxcommadeten_in),
   .rxctrl0_out(rxctrl0_out),
   .rxctrl1_out(rxctrl1_out),
   .rxctrl2_out(rxctrl2_out),
   .rxctrl3_out(rxctrl3_out),
   .rxdata_out(rxdata_out),
   .rxdfeagchold_in(rxdfeagchold_in),
   .rxdfelfhold_in(rxdfelfhold_in),
   .rxdfelpmreset_in(rxdfelpmreset_in),
   .rxdfetap10hold_in(rxdfetap10hold_in),
   .rxdfetap11hold_in(rxdfetap11hold_in),
   .rxdfetap12hold_in(rxdfetap12hold_in),
   .rxdfetap13hold_in(rxdfetap13hold_in),
   .rxdfetap14hold_in(rxdfetap14hold_in),
   .rxdfetap15hold_in(rxdfetap15hold_in),
   .rxdfetap2hold_in(rxdfetap2hold_in),
   .rxdfetap3hold_in(rxdfetap3hold_in),
   .rxdfetap4hold_in(rxdfetap4hold_in),
   .rxdfetap5hold_in(rxdfetap5hold_in),
   .rxdfetap6hold_in(rxdfetap6hold_in),
   .rxdfetap7hold_in(rxdfetap7hold_in),
   .rxdfetap8hold_in(rxdfetap8hold_in),
   .rxdfetap9hold_in(rxdfetap9hold_in),
   .rxdfeuthold_in(rxdfeuthold_in),
   .rxdfevphold_in(rxdfevphold_in),
   .rxlpmen_in(rxlpmen_in),
   .rxmcommaalignen_in(rxmcommaalignen_in),
   .rxoshold_in(rxoshold_in),
   .rxoutclk_out(rxoutclk_out),
   .rxpcommaalignen_in(rxpcommaalignen_in),
   .rxpcsreset_in(rxpcsreset_in),
   .rxpd_in(rxpd_in),
   .rxpllclksel_in(rxpllclksel_in),
   .rxpmareset_in(rxpmareset_in),
   .rxpmaresetdone_out(rxpmaresetdone_out),
   .rxpolarity_in(rxpolarity_in),
   .rxprbscntreset_in(rxprbscntreset_in),
   .rxprbserr_out(rxprbserr_out),
   .rxprbssel_in(rxprbssel_in),
   .rxprogdivreset_in(rxprogdivreset_in),
   .rxrate_in(rxrate_in),
   .rxresetdone_out(rxresetdone_out),
   .rxsysclksel_in(rxsysclksel_in),
   .rxuserrdy_in(rxuserrdy_in),
   .rxusrclk2_in(rxusrclk2_in),
   .rxusrclk_in(rxusrclk_in),
   .tx8b10ben_in(tx8b10ben_in),
   .txbufstatus_out(txbufstatus_out),
   .txctrl0_in(txctrl0_in),
   .txctrl1_in(txctrl1_in),
   .txctrl2_in(txctrl2_in),
   .txdata_in(txdata_in),
   .txdiffctrl_in(txdiffctrl_in),
   .txinhibit_in(txinhibit_in),
   .txoutclk_out(txoutclk_out),
   .txpcsreset_in(txpcsreset_in),
   .txpd_in(txpd_in),
   .txpllclksel_in(txpllclksel_in),
   .txpmareset_in(txpmareset_in),
   .txpmaresetdone_out(txpmaresetdone_out),
   .txpolarity_in(txpolarity_in),
   .txpostcursor_in(txpostcursor_in),
   .txprbsforceerr_in(txprbsforceerr_in),
   .txprbssel_in(txprbssel_in),
   .txprecursor_in(txprecursor_in),
   .txprogdivreset_in(txprogdivreset_in),
   .txresetdone_out(txresetdone_out),
   .txsysclksel_in(txsysclksel_in),
   .txuserrdy_in(txuserrdy_in),
   .txusrclk2_in(txusrclk2_in),
   .txusrclk_in(txusrclk_in)
  );


  assign rxoutclk                           = rxoutclk_out[0];
  assign gtwiz_userclk_rx_active_in[0]      = 1'b1;
  assign rx8b10ben_in                       = {2{1'b1}};
  assign rxcommadeten_in                    = {2{1'b1}};

  assign txoutclk                           = txoutclk_out[0];
  assign txctrl0_in                         = {32{1'b0}};
  assign txctrl1_in                         = {32{1'b0}};
  assign tx8b10ben_in                       = {2{1'b1}};
  assign gtwiz_userclk_tx_active_in[0]      = 1'b1;


   
  assign  cpllpd_in[0]                      = (txpllclksel_axi[1:0] == 2'b00 && rxpllclksel_axi[1:0] == 2'b00) ? (pllreset_tx_out | pllreset_rx_out | cpll_pd_0) :
                                              (txpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_tx_out | cpll_pd_0) :
                                              (rxpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_rx_out | cpll_pd_0) : 1'b0;
  assign  cpllreset_in[0]                     = 1'b0;

  assign  cpllpd_in[1]                      = (txpllclksel_axi[1:0] == 2'b00 && rxpllclksel_axi[1:0] == 2'b00) ? (pllreset_tx_out | pllreset_rx_out | cpll_pd_1) :
                                              (txpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_tx_out | cpll_pd_1) :
                                              (rxpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_rx_out | cpll_pd_1) : 1'b0;
  assign  cpllreset_in[1]                     = 1'b0;

    
  //AND all powergood signals
  assign gtpowergood_i  = &gtpowergood_out;
  assign gt_powergood   = gtpowergood_i;

  // Gate all user reset until gtpowergood_out goes high
  assign txreset_good   = (gtpowergood_i) ? tx_rst_data : 1'b0;
  assign rxreset_good   = (gtpowergood_i) ? rx_rst_data : 1'b0;

  assign txreset_good_all   = (gtpowergood_i) ? tx_rst_all : 1'b0;
  assign rxreset_good_all   = (gtpowergood_i) ? rx_rst_all : 1'b0;

  // Drive gtwiz_userclk_tx_active_out based on PMA Reset done 
  // to ensure clock is stable before coming out of reset.
  assign gtwiz_userclk_tx_reset_int = ~(&txpmaresetdone_out);
      
  always @(posedge tx_core_clk, posedge gtwiz_userclk_tx_reset_int) begin
    if (gtwiz_userclk_tx_reset_int) begin
      gtwiz_userclk_tx_active_meta <= 1'b0;
      gtwiz_userclk_tx_active_sync <= 1'b0;
    end
    else begin
      gtwiz_userclk_tx_active_meta <= 1'b1;
      gtwiz_userclk_tx_active_sync <= gtwiz_userclk_tx_active_meta;
    end
  end
  assign gtwiz_userclk_tx_active_out = gtwiz_userclk_tx_active_sync;

  // Drive gtwiz_userclk_rx_active_out based on PMA Reset done to ensure clock
  // is stable before coming out of reset.
  assign gtwiz_userclk_rx_reset_int = ~(&rxpmaresetdone_out);

  always @(posedge rx_core_clk, posedge gtwiz_userclk_rx_reset_int) begin
    if (gtwiz_userclk_rx_reset_int) begin
      gtwiz_userclk_rx_active_meta <= 1'b0;
      gtwiz_userclk_rx_active_sync <= 1'b0;
    end
    else begin
      gtwiz_userclk_rx_active_meta <= 1'b1;
      gtwiz_userclk_rx_active_sync <= gtwiz_userclk_rx_active_meta;
    end
  end
  assign gtwiz_userclk_rx_active_out = gtwiz_userclk_rx_active_sync;

  // Instantiate reset block from the GT wizard
  gtwizard_ultrascale_v1_7_0_gtwiz_reset #(
   .P_FREERUN_FREQUENCY       (100.0),
   .P_USE_CPLL_CAL            (1),
   .P_TX_PLL_TYPE             (2),
   .P_RX_PLL_TYPE             (2),
   .P_RX_LINE_RATE            (5.0),
   .P_CDR_TIMEOUT_FREERUN_CYC ((37000 * 100.0) / 5.0)
  ) gtwiz_reset_block_i (

    .gtwiz_reset_clk_freerun_in          (drpclk),
    .gtwiz_reset_all_in                  (1'b0),
    .gtwiz_reset_tx_pll_and_datapath_in  (txreset_good_all),
    .gtwiz_reset_tx_datapath_in          (txreset_good),
    .gtwiz_reset_rx_pll_and_datapath_in  (rxreset_good_all),
    .gtwiz_reset_rx_datapath_in          (rxreset_good),
    .gtwiz_reset_rx_cdr_stable_out       (),
    .gtwiz_reset_tx_done_out             (gtwiz_reset_tx_done_in[0]),
    .gtwiz_reset_rx_done_out             (gtwiz_reset_rx_done_in[0]),
    .gtwiz_reset_userclk_tx_active_in    (gtwiz_userclk_tx_active_out),
    .gtwiz_reset_userclk_rx_active_in    (gtwiz_userclk_rx_active_out),
    .gtpowergood_in                      (gtpowergood_i),
    .txusrclk2_in                        (tx_core_clk),
    .plllock_tx_in                       (tx_pll_lock),
    .txresetdone_in                      (gt_txresetdone_sync),
    .rxusrclk2_in                        (rx_core_clk),
    .plllock_rx_in                       (rx_pll_lock),
    .rxcdrlock_in                        (rxcdrlock_in),
    .rxresetdone_in                      (gt_rxresetdone_sync),
    .pllreset_tx_out                     (pllreset_tx_out),
    .txprogdivreset_out                  (txprogdivreset_out),
    .gttxreset_out                       (gttxreset_out),
    .txuserrdy_out                       (txuserrdy_out),
    .pllreset_rx_out                     (pllreset_rx_out),
    .rxprogdivreset_out                  (rxprogdivreset_out),
    .gtrxreset_out                       (gtrxreset_out),
    .rxuserrdy_out                       (rxuserrdy_out),
    .tx_enabled_tie_in                   (1'b0),
    .rx_enabled_tie_in                   (1'b0),
    .shared_pll_tie_in                   (1'b1)
  );

  //Synchronize Transceiver Resets to drpclk domain
  jesd204_phy_0_sync_block #(
    .TYPE (1)
  ) sync_tx_reset_data 
  (
    .clk             (drpclk),
    .data_in         (tx_reset_gt),
    .data_out        (tx_reset_gt_sync)
  );

  jesd204_phy_0_sync_block #(
    .TYPE (1)
  ) sync_rx_reset_data 
  (
    .clk             (drpclk),
    .data_in         (rx_reset_gt),
    .data_out        (rx_reset_gt_sync)
  );

  jesd204_phy_0_sync_block #(
    .TYPE (1)
  ) sync_tx_reset_all
  (
    .clk             (drpclk),
    .data_in         (tx_sys_reset|tx_sys_reset_axi),
    .data_out        (tx_sys_reset_sync)
  );

  jesd204_phy_0_sync_block #(
    .TYPE (1)
  ) sync_rx_reset_all
  (
    .clk             (drpclk),
    .data_in         (rx_sys_reset|rx_sys_reset_axi),
    .data_out        (rx_sys_reset_sync)
  );

  // State machine module that controls reset inputs to transceiver
  jesd204_phy_0_reset_control jesd204_phy_reset_control_i (
    .clk             (drpclk),
    .tx_sys_rst      (tx_sys_reset_sync),
    .rx_sys_rst      (rx_sys_reset_sync),
    .tx_data_rst     (tx_reset_gt_sync),
    .rx_data_rst     (rx_reset_gt_sync),
    .tx_rst_done     (txresetdone_sync),
    .rx_rst_done     (rxresetdone_sync),
    .tx_rst_all      (tx_rst_all),
    .rx_rst_all      (rx_rst_all),
    .tx_rst_data     (tx_rst_data),
    .rx_rst_data     (rx_rst_data)
  );
  
  // Connect the clocking and control inputs and outputs to the
  // GT ports. Tie unused inputs to the GT low.
  assign  loopback_in[5:0]        = gt_loopback[5:0];
  assign  txprbssel_in[7:0]       = {2{gt_prbssel}};
  assign  txprbsforceerr_in[1:0]  = gt_txprbsforceerr;
  assign  rxprbssel_in[7:0]       = gt_rxprbssel[7:0];
  assign  rxprbscntreset_in[1:0]  = gt_rxprbscntreset;
  assign  gt_rxprbserr            = rxprbserr_out[1:0];
  assign  rxpolarity_in[1:0]      = gt_rxpolarity[1:0];
  assign  txpolarity_in[1:0]      = gt_txpolarity[1:0];
  assign  txinhibit_in[1:0]       = gt_txinhibit[1:0];
  assign  txdiffctrl_in           = gt_txdiffctrl;
  assign  txpostcursor_in[9:0]    = gt_txpostcursor;
  assign  txprecursor_in[9:0]     = gt_txprecursor;
  assign  gt_txresetdone          = txresetdone_out[1:0];
  assign  gt_rxresetdone          = rxresetdone_out[1:0];
  assign  gthrxn_in[1:0]          = rxn_in[1:0];
  assign  gthrxp_in[1:0]          = rxp_in[1:0];
  assign  txn_out[1:0]            = gthtxn_out[1:0];
  assign  txp_out[1:0]            = gthtxp_out[1:0];
  assign  txusrclk_in[1:0]        = {2{tx_core_clk}};
  assign  txusrclk2_in[1:0]       = {2{tx_core_clk}};
  assign  rxusrclk_in[1:0]        = {2{rx_core_clk}};
  assign  rxusrclk2_in[1:0]       = {2{rx_core_clk}};
  assign  rxmcommaalignen_in[1:0] = {2{rxencommaalign}};
  assign  rxpcommaalignen_in[1:0] = {2{rxencommaalign}};
  assign  rxcdrlock_in            = rxcdrlock_out[1] & rxcdrlock_out[0];
  assign  txprogdivreset_in[1:0]  = {2{txprogdivreset_out}};
  assign  rxprogdivreset_in[1:0]  = {2{rxprogdivreset_out}};
  assign  gttxreset_in[1:0]       = {2{gttxreset_out}};
  assign  gtrxreset_in[1:0]       = {2{gtrxreset_out}};
  assign  txuserrdy_in[1:0]       = {2{txuserrdy_out}};
  assign  rxuserrdy_in[1:0]       = {2{rxuserrdy_out}};
  assign  rx_pll_lock_i           = (cplllock_out[1] & cplllock_out[0]);
  assign  tx_pll_lock_i           = (cplllock_out[1] & cplllock_out[0]);
  assign  gt_cplllock             = cplllock_out[1:0];
  assign  gtrefclk0_in[1:0]       = {2{cpll_refclk}};
  assign  txsysclksel_in          = {2{txsysclksel_axi}};
  assign  rxsysclksel_in          = {2{rxsysclksel_axi}};
  assign  txpllclksel_in          = txpllclksel_axi;
  assign  rxpllclksel_in          = rxpllclksel_axi;
  assign  rxpd_in[3:0]            = gt_rxpd;
  assign  txpd_in[3:0]            = gt_txpd;
  assign  txpcsreset_in[1:0]      = gt_txpcsreset;
  assign  txpmareset_in[1:0]      = gt_txpmareset;
  assign  rxpcsreset_in[1:0]      = gt_rxpcsreset;
  assign  rxpmareset_in[1:0]      = gt_rxpmareset;
  assign  rxbufreset_in[1:0]      = gt_rxbufreset;
  assign  gt_rxpmaresetdone       = rxpmaresetdone_out[1:0];
  assign  gt_txbufstatus          = txbufstatus_out[3:0];
  assign  gt_rxbufstatus          = rxbufstatus_out[5:0];
  assign  rxrate_in[5:0]          = gt_rxrate;
  assign  eyescantrigger_in[1:0]  = gt_eyescantrigger;
  assign  eyescanreset_in[1:0]    = gt_eyescanreset;
  assign  gt_eyescandataerror     = eyescandataerror_out[1:0];
  assign  rxdfelpmreset_in[1:0]   = gt_rxdfelpmreset;
  assign  rxlpmen_in[1:0]         = gt_rxlpmen;
  assign  rxcdrhold_in[1:0]       = gt_rxcdrhold;
  assign  rxoshold_in[1:0]        = gt_rxoshold;
  assign  rxdfeagchold_in[1:0]    = gt_rxdfeagchold;
  assign  rxdfelfhold_in[1:0]     = gt_rxdfelfhold;
  assign  rxdfeuthold_in[1:0]     = gt_rxdfeuthold;
  assign  rxdfevphold_in[1:0]     = gt_rxdfevphold;
  assign  rxdfetap2hold_in[1:0]   = gt_rxdfetap2hold;
  assign  rxdfetap3hold_in[1:0]   = gt_rxdfetap3hold;
  assign  rxdfetap4hold_in[1:0]   = gt_rxdfetap4hold;
  assign  rxdfetap5hold_in[1:0]   = gt_rxdfetap5hold;
  assign  rxdfetap6hold_in[1:0]   = gt_rxdfetap6hold;
  assign  rxdfetap7hold_in[1:0]   = gt_rxdfetap7hold;
  assign  rxdfetap8hold_in[1:0]   = gt_rxdfetap8hold;
  assign  rxdfetap9hold_in[1:0]   = gt_rxdfetap9hold;
  assign  rxdfetap10hold_in[1:0]  = gt_rxdfetap10hold;
  assign  rxdfetap11hold_in[1:0]  = gt_rxdfetap11hold;
  assign  rxdfetap12hold_in[1:0]  = gt_rxdfetap12hold;
  assign  rxdfetap13hold_in[1:0]  = gt_rxdfetap13hold;
  assign  rxdfetap14hold_in[1:0]  = gt_rxdfetap14hold;
  assign  rxdfetap15hold_in[1:0]  = gt_rxdfetap15hold;
  assign  gt_dmonitorout          = dmonitorout_out;
  assign  gt_rxcommadet           = rxcommadet_out[1:0];
  assign  pcsrsvdin_in            = gt_pcsrsvdin;

  assign  qpll0clk_in[1:0]        = {2{common0_qpll0_clk_in}};
  assign  qpll0refclk_in[1:0]     = {2{common0_qpll0_refclk_in}};
  assign  qpll1clk_in[1:0]        = {2{common0_qpll1_clk_in}};
  assign  qpll1refclk_in[1:0]     = {2{common0_qpll1_refclk_in}};

  // PLL lock input to GT Reset Module
  always@(posedge drpclk)
    tx_pll_lock              <= (txpllclksel_axi[1:0] == 2'b00) ? tx_pll_lock_i :
                                (txpllclksel_axi[1:0] == 2'b11) ? common0_qpll0_lock_in :
                                (txpllclksel_axi[1:0] == 2'b10) ? common0_qpll1_lock_in : 1'b0;

  always@(posedge drpclk)
    rx_pll_lock              <= (rxpllclksel_axi[1:0] == 2'b00) ? rx_pll_lock_i :
                                (rxpllclksel_axi[1:0] == 2'b11) ? common0_qpll0_lock_in :
                                (rxpllclksel_axi[1:0] == 2'b10) ? common0_qpll1_lock_in : 1'b0;

  //Output to reset QPLL0 located in Support Block
  assign qpll0_reset_out           = (txpllclksel_axi[1:0] == 2'b11 && rxpllclksel_axi[1:0] == 2'b11) ? pllreset_tx_out || pllreset_rx_out:
                                     (txpllclksel_axi[1:0] == 2'b11) ? pllreset_tx_out :
                                     (rxpllclksel_axi[1:0] == 2'b11) ? pllreset_rx_out : 1'b0;

  //Output to reset QPLL1 located in Support Block
  assign qpll1_reset_out           = (txpllclksel_axi[1:0] == 2'b10 && rxpllclksel_axi[1:0] == 2'b10) ? pllreset_tx_out || pllreset_rx_out:
                                     (txpllclksel_axi[1:0] == 2'b10) ? pllreset_tx_out :
                                     (rxpllclksel_axi[1:0] == 2'b10) ? pllreset_rx_out : 1'b0;

  //When a lane is powered down tie resetdone of that channel to 1.
  //Power downs only have 2 valid values for non PCI Express Designs 00 and 11
  
  //Create a single bit which can be crossed over to the core clock domain.
  //Tx power downs are already in the core clock domain
  // Lane 0 Power Down
  assign gt_rxpd_i[0] = &gt_rxpd[1:0];
  
  always@(posedge s_axi_aclk)
    gt_rxpd_r[0]   <=  gt_rxpd_i[0];
  
  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_gt_rxpd_0 
  (
    .clk             (rx_core_clk),
    .data_in         (gt_rxpd_r[0]),
    .data_out        (gt_rxpd_sync[0])
  );
 
  always@(posedge rx_core_clk)
    rxresetdone_r[0]    <=  rxresetdone_out[0];

  always@(posedge tx_core_clk)
    txresetdone_r[0]    <=  txresetdone_out[0];  

  assign rxresetdone[0] = (gt_rxpd_sync[0] == 1'b0) ? rxresetdone_r[0] : 1'b1;
  assign txresetdone[0] = (gt_txpd[1:0] == 2'b00) ? txresetdone_r[0] : 1'b1;
  
  // Lane 1 Power Down
  assign gt_rxpd_i[1] = &gt_rxpd[3:2];
  
  always@(posedge s_axi_aclk)
    gt_rxpd_r[1]   <=  gt_rxpd_i[1];
  
  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_gt_rxpd_1 
  (
    .clk             (rx_core_clk),
    .data_in         (gt_rxpd_r[1]),
    .data_out        (gt_rxpd_sync[1])
  );
 
  always@(posedge rx_core_clk)
    rxresetdone_r[1]    <=  rxresetdone_out[1];

  always@(posedge tx_core_clk)
    txresetdone_r[1]    <=  txresetdone_out[1];  

  assign rxresetdone[1] = (gt_rxpd_sync[1] == 1'b0) ? rxresetdone_r[1] : 1'b1;
  assign txresetdone[1] = (gt_txpd[3:2] == 2'b00) ? txresetdone_r[1] : 1'b1;
  
  always@(posedge rx_core_clk)
    rxresetdone_i2   <=  &rxresetdone;

  always@(posedge tx_core_clk)
    txresetdone_i2   <=  &txresetdone;
    
  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_gt_txresetdone 
  (
    .clk             (drpclk),
    .data_in         (txresetdone_i2),
    .data_out        (gt_txresetdone_sync)
  );

  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_gt_rxresetdone 
  (
    .clk             (drpclk),
    .data_in         (rxresetdone_i2),
    .data_out        (gt_rxresetdone_sync)
  );

  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_rxresetdone 
  (
    .clk             (drpclk),
    .data_in         (gtwiz_reset_rx_done_in[0]),
    .data_out        (rxresetdone_sync)
  );
  assign rx_reset_done = rxresetdone_sync;

  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_txresetdone 
  (
    .clk             (drpclk),
    .data_in         (gtwiz_reset_tx_done_in[0]),
    .data_out        (txresetdone_sync)
  );
  assign tx_reset_done = txresetdone_sync;

  //---------------------------------------------------------------------------
  // PLL lock wire, axi info
  //---------------------------------------------------------------------------
  // Channel bus
  wire cpll_lock_and;
  wire cpll_lock_axi;
  wire tx_reset_done_axi;
  wire rx_reset_done_axi;
  wire qpll0_lock_axi;
  wire qpll1_lock_axi;
  wire qpll0_lock_and;
  wire qpll1_lock_and;

  //---------------------------------------------------------------------------
  // QPLL lock assignments
  //---------------------------------------------------------------------------
  assign qpll0_lock_and       = (common0_qpll0_lock_in);
  assign qpll1_lock_and       = (common0_qpll1_lock_in);

  //---------------------------------------------------------------------------
  // QPLL LOCK synchronization
  //---------------------------------------------------------------------------
  jesd204_phy_0_phyCoreCtrlInterface_sync sync_qpll0_lock_axi_i
  (
  .clk                                 (s_axi_aclk                    ),
  .data_in                             (~qpll0_lock_and               ),
  .data_out                            (qpll0_lock_axi                )
  );

  jesd204_phy_0_phyCoreCtrlInterface_sync sync_qpll1_lock_axi_i
  (
  .clk                                 (s_axi_aclk                    ),
  .data_in                             (~qpll1_lock_and               ),
  .data_out                            (qpll1_lock_axi                )
  );

  //---------------------------------------------------------------------------
  // CPLL LOCK synchronization
  //---------------------------------------------------------------------------
  assign cpll_lock_and = &cplllock_out;
  jesd204_phy_0_phyCoreCtrlInterface_sync sync_cpll_lock_axi_i
  (
  .clk                                 (s_axi_aclk                    ),
  .data_in                             (~cpll_lock_and                ),
  .data_out                            (cpll_lock_axi                 )
  );

  //---------------------------------------------------------------------------
  // Reset synchronization
  //---------------------------------------------------------------------------
  jesd204_phy_0_phyCoreCtrlInterface_sync sync_tx_reset_done_axi_i
  (
  .clk                                 (s_axi_aclk                    ),
  .data_in                             (~txresetdone_sync             ),
  .data_out                            (tx_reset_done_axi             )
  );
  jesd204_phy_0_phyCoreCtrlInterface_sync sync_rx_reset_done_axi_i
  (
  .clk                                 (s_axi_aclk                    ),
  .data_in                             (~rxresetdone_sync             ),
  .data_out                            (rx_reset_done_axi             )
  );

  //---------------------------------------------------------------------------
  // DRP reset & reserved input bus. gt_pcsrsvdin is 16 bits wide per GT
  // Note that bit 2 in every 16 is driven by the drp reset coming from the
  // AXI bank
  //---------------------------------------------------------------------------
  assign gt_pcsrsvdin[15:3] = 13'd0;
  assign gt_pcsrsvdin[1:0] = 2'd0;
  assign gt_pcsrsvdin[31:19] = 13'd0;
  assign gt_pcsrsvdin[17:16] = 2'd0;

  //---------------------------------------------------------------------------
  // Reset synchronization
  //---------------------------------------------------------------------------
  jesd204_phy_0_phyCoreCtrlInterface_sync sync_drp_reset_i
  (
  .clk                                 (drpclk                        ),
  .data_in                             (s_axi_aresetn                 ),
  .data_out                            (s_drp_reset                   )
  );

  jesd204_phy_0_phyCoreCtrlInterface_sync sync_tx_core_reset_i
  (
  .clk                                 (tx_core_clk                   ),
  .data_in                             (s_axi_aresetn                 ),
  .data_out                            (tx_core_reset                 )
  );

  jesd204_phy_0_phyCoreCtrlInterface_sync sync_rx_core_reset_i
  (
  .clk                                 (rx_core_clk                   ),
  .data_in                             (s_axi_aresetn                 ),
  .data_out                            (rx_core_reset                 )
  );

  //---------------------------------------------------------------------------
  // Local AXI wires
  //---------------------------------------------------------------------------
  wire                           timeout_enable;
  wire  [11:0]                   timeout_value;

  wire  [1:0]                    txpllclksel_axi_reg;
  wire  [1:0]                    rxpllclksel_axi_reg;

  // The PLL signals must be expanded for the full port width of the GT pll
  // select bus
  assign txpllclksel_axi = {2{txpllclksel_axi_reg}};
  assign rxpllclksel_axi = {2{rxpllclksel_axi_reg}};

  // Copy the rx equalizer setting to each lane
  assign gt_rxlpmen        = {2{rxlpmen_axi}};
  assign gt_rxdfelpmreset  = {2{rxdfelpmreset_axi}};
  assign gt_rxoshold       = {2{rxoshold_axi}};             
  assign gt_rxdfeagchold   = {2{rxdfeagchold_axi}};
  assign gt_rxdfelfhold    = {2{rxdfelfhold_axi}};
  assign gt_rxdfeuthold    = {2{rxdfeuthold_axi}};
  assign gt_rxdfevphold    = {2{rxdfevphold_axi}};
  assign gt_rxdfetap2hold  = {2{rxdfetap2hold_axi}};
  assign gt_rxdfetap3hold  = {2{rxdfetap3hold_axi}};
  assign gt_rxdfetap4hold  = {2{rxdfetap4hold_axi}};
  assign gt_rxdfetap5hold  = {2{rxdfetap5hold_axi}};
  assign gt_rxdfetap6hold  = {2{rxdfetap6hold_axi}};
  assign gt_rxdfetap7hold  = {2{rxdfetap7hold_axi}};
  assign gt_rxdfetap8hold  = {2{rxdfetap8hold_axi}};
  assign gt_rxdfetap9hold  = {2{rxdfetap9hold_axi}};
  assign gt_rxdfetap10hold = {2{rxdfetap10hold_axi}};
  assign gt_rxdfetap11hold = {2{rxdfetap11hold_axi}};
  assign gt_rxdfetap12hold = {2{rxdfetap12hold_axi}};
  assign gt_rxdfetap13hold = {2{rxdfetap13hold_axi}};
  assign gt_rxdfetap14hold = {2{rxdfetap14hold_axi}};
  assign gt_rxdfetap15hold = {2{rxdfetap15hold_axi}};

//-----------------------------------------------------------------------------
// AXI interface for PHYCore
//-----------------------------------------------------------------------------
  jesd204_phy_0_phyCoreCtrlInterface phyCoreCtrlInterface_i (
  //---------------------------------------------------------------------------
  // DRP Common mailbox. Quads = 1
  //---------------------------------------------------------------------------
  // DRP interface 0
  .cmn_drp0_addr                       (common0_drpaddr               ),
  .cmn_drp0_di                         (common0_drpdi                 ),
  .cmn_drp0_we                         (common0_drpwe                 ),
  .cmn_drp0_en                         (common0_drpen                 ),
  .cmn_drp0_rst                        (                              ),

  .cmn_drp0_do                         (common0_drpdo                 ),
  .cmn_drp0_rdy                        (common0_drprdy                ),

  //---------------------------------------------------------------------------
  // Transceivers Common mailbox for
  //---------------------------------------------------------------------------
  // Transceivers interface 0
  .gt_drp0_addr                        (gt0_drpaddr                   ),
  .gt_drp0_di                          (gt0_drpdi                     ),
  .gt_drp0_we                          (gt0_drpwe                     ),
  .gt_drp0_en                          (gt0_drpen                     ),
  .gt_drp0_rst                         (gt_pcsrsvdin[2]               ),

  .gt_drp0_do                          (gt0_drpdo                     ),
  .gt_drp0_rdy                         (gt0_drprdy                    ),
  // Transceivers interface 1
  .gt_drp1_addr                        (gt1_drpaddr                   ),
  .gt_drp1_di                          (gt1_drpdi                     ),
  .gt_drp1_we                          (gt1_drpwe                     ),
  .gt_drp1_en                          (gt1_drpen                     ),
  .gt_drp1_rst                         (gt_pcsrsvdin[18]              ),

  .gt_drp1_do                          (gt1_drpdo                     ),
  .gt_drp1_rdy                         (gt1_drprdy                    ),

  .txpllclksel                         (txpllclksel_axi_reg           ),
  .rxpllclksel                         (rxpllclksel_axi_reg           ),

  .tx_sys_reset_axi                    (tx_sys_reset_axi              ),
  .rx_sys_reset_axi                    (rx_sys_reset_axi              ),

  .cpll_cal_per                        (cpll_cal_cnt_per              ),
  .cpll_cal_tol                        (cpll_cal_cnt_tol              ),

  //---------------------------------------------------------------------------
  // Transceivers Debug interface
  //---------------------------------------------------------------------------
  // Transceivers debug interface 0
  // Async signals
  .rx_pd_0                             (gt_rxpd[1:0]                  ),
  .cpll_pd_0                           (cpll_pd_0                     ),
  .txpostcursor_0                      (gt_txpostcursor[4:0]          ),
  .txprecursor_0                       (gt_txprecursor[4:0]           ),
  .loopback_0                          (gt_loopback[2:0]              ),

  // TXUSRCLK2 domain
  .tx_pd_0                             (gt_txpd[1:0]                  ),
  .txdiffctrl_0                        (gt_txdiffctrl[3:0]            ),
  .txinihibit_0                        (gt_txinhibit[0]               ),
  .txpolarity_0                        (gt_txpolarity[0]              ),

  // RXUSRCLK2 domain
  .rxpolarity_0                        (gt_rxpolarity[0]              ),

  // Transceivers debug interface 1
  // Async signals
  .rx_pd_1                             (gt_rxpd[3:2]                  ),
  .cpll_pd_1                           (cpll_pd_1                     ),
  .txpostcursor_1                      (gt_txpostcursor[9:5]          ),
  .txprecursor_1                       (gt_txprecursor[9:5]           ),
  .loopback_1                          (gt_loopback[5:3]              ),

  // TXUSRCLK2 domain
  .tx_pd_1                             (gt_txpd[3:2]                  ),
  .txdiffctrl_1                        (gt_txdiffctrl[7:4]            ),
  .txinihibit_1                        (gt_txinhibit[1]               ),
  .txpolarity_1                        (gt_txpolarity[1]              ),

  // RXUSRCLK2 domain
  .rxpolarity_1                        (gt_rxpolarity[1]              ),

  // RXUSRCLK2 domain
  .rxlpmen                             (rxlpmen_axi                   ),
  .rxdfelpmreset                       (rxdfelpmreset_axi             ),
  .rxoshold                            (rxoshold_axi                  ),
  .rxdfeagchold                        (rxdfeagchold_axi              ),
  .rxdfelfhold                         (rxdfelfhold_axi               ),
  .rxdfeuthold                         (rxdfeuthold_axi               ),
  .rxdfevphold                         (rxdfevphold_axi               ),
  .rxdfetap2hold                       (rxdfetap2hold_axi             ),
  .rxdfetap3hold                       (rxdfetap3hold_axi             ),
  .rxdfetap4hold                       (rxdfetap4hold_axi             ),
  .rxdfetap5hold                       (rxdfetap5hold_axi             ),
  .rxdfetap6hold                       (rxdfetap6hold_axi             ),
  .rxdfetap7hold                       (rxdfetap7hold_axi             ),
  .rxdfetap8hold                       (rxdfetap8hold_axi             ),
  .rxdfetap9hold                       (rxdfetap9hold_axi             ),
  .rxdfetap10hold                      (rxdfetap10hold_axi            ),
  .rxdfetap11hold                      (rxdfetap11hold_axi            ),
  .rxdfetap12hold                      (rxdfetap12hold_axi            ),
  .rxdfetap13hold                      (rxdfetap13hold_axi            ),
  .rxdfetap14hold                      (rxdfetap14hold_axi            ),
  .rxdfetap15hold                      (rxdfetap15hold_axi            ),
  //---------------------------------------------------------------------------
  // Common Debug interface Quads = 1
  //---------------------------------------------------------------------------
  // Common debug interface 0
  .qpll0_pd_0                          (common0_qpll0_pd              ),
  .qpll1_pd_0                          (common0_qpll1_pd              ),

  .timeout_enable                      (timeout_enable                ),
  .timeout_value                       (timeout_value                 ),

  .timeout_enable_in                   (timeout_enable                ),
  .timeout_value_in                    (timeout_value                 ),

  .tx_reset_not_done                   (tx_reset_done_axi             ),
  .rx_reset_not_done                   (rx_reset_done_axi             ),

  .cpll_not_locked                     (cpll_lock_axi                 ),
  .qpll0_not_locked                    (qpll0_lock_axi                ),
  .qpll1_not_locked                    (qpll1_lock_axi                ),

  .s_axi_aclk                          (s_axi_aclk                    ),
  .s_axi_aresetn                       (s_axi_aresetn                 ),
      
  .s_drp_clk                           (drpclk                        ),
  .s_drp_reset                         (s_drp_reset                   ),
      
  .tx_core_clk                         (tx_core_clk                   ),
  .tx_core_reset                       (tx_core_reset                 ),
      
  .rx_core_clk                         (rx_core_clk                   ),
  .rx_core_reset                       (rx_core_reset                 ),
      
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
  .s_axi_rready                        (s_axi_rready                  )

  );

  // Assign sysclksel values based on pllclksel.
  assign txsysclksel_axi = (txpllclksel_axi[1:0] == 2'b00) ? 2'b00 :
                           (txpllclksel_axi[1:0] == 2'b10) ? 2'b11 :
                           (txpllclksel_axi[1:0] == 2'b11) ? 2'b10 : 2'b00;

  assign rxsysclksel_axi = (rxpllclksel_axi[1:0] == 2'b00) ? 2'b00 :
                           (rxpllclksel_axi[1:0] == 2'b10) ? 2'b11 :
                           (rxpllclksel_axi[1:0] == 2'b11) ? 2'b10 : 2'b00;

endmodule
