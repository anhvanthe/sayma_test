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
  output     [7:0]    gt_txresetdone,
  output     [7:0]    gt_rxresetdone,

  input               cpll_refclk,
  
  output              qpll0_reset_out,
  output              qpll1_reset_out,
  // GT Common I/O
  input               common0_qpll0_lock_in,
  input               common0_qpll0_refclk_in,
  input               common0_qpll0_clk_in,
  input               common1_qpll0_lock_in,
  input               common1_qpll0_refclk_in,
  input               common1_qpll0_clk_in,

  input               common0_qpll1_lock_in,
  input               common0_qpll1_refclk_in,
  input               common0_qpll1_clk_in,
  input               common1_qpll1_lock_in,
  input               common1_qpll1_refclk_in,
  input               common1_qpll1_clk_in,
  input               rxencommaalign,
  // Clocks
  input               tx_core_clk,
  output              txoutclk,

  input               rx_core_clk,
  output              rxoutclk,

  input               drpclk,

  // CPLL Lock
  output     [7:0]    gt_cplllock,

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

  // Common 1 DRP Ports
  output [8:0]        common1_drpaddr,
  output [15:0]       common1_drpdi,
  output              common1_drpen,
  output              common1_drpwe,
  input  [15:0]       common1_drpdo,
  input               common1_drprdy,

  // Common 1 QPLL Power Down Ports
  output              common1_qpll0_pd,
  output              common1_qpll1_pd,

  // Pattern Checker ports
  input  [3:0]        gt_prbssel,
  input      [7:0]    gt_txprbsforceerr,

  input      [31:0]    gt_rxprbssel,
  input      [7:0]    gt_rxprbscntreset,
  output     [7:0]    gt_rxprbserr,

  // TX Reset and Initialization
  input      [7:0]     gt_txpmareset,
  input      [7:0]     gt_txpcsreset,

  // RX Reset and Initialization
  input      [7:0]     gt_rxpmareset,
  input      [7:0]     gt_rxpcsreset,
  input      [7:0]     gt_rxbufreset,
  output     [7:0]     gt_rxpmaresetdone,

  // TX Buffer Ports
  output     [15:0]    gt_txbufstatus,

  // RX Buffer Ports
  output     [23:0]    gt_rxbufstatus,

  // PCI Express Ports
  input      [23:0]    gt_rxrate,

  // RX Margin Analysis Ports
  input      [7:0]     gt_eyescantrigger,
  input      [7:0]     gt_eyescanreset,
  output     [7:0]     gt_eyescandataerror,

  // RX CDR Ports
  input      [7:0]     gt_rxcdrhold,

  // RX Digital Monitor Ports
  output     [135:0]   gt_dmonitorout,

  // RX Byte and Word Alignment Ports
  output      [7:0]    gt_rxcommadet,

  // Tx Ports
  // Lane 0
  input    [31:0]    gt0_txdata,
  input     [3:0]    gt0_txcharisk,

  // Lane 1
  input    [31:0]    gt1_txdata,
  input     [3:0]    gt1_txcharisk,

  // Lane 2
  input    [31:0]    gt2_txdata,
  input     [3:0]    gt2_txcharisk,

  // Lane 3
  input    [31:0]    gt3_txdata,
  input     [3:0]    gt3_txcharisk,

  // Lane 4
  input    [31:0]    gt4_txdata,
  input     [3:0]    gt4_txcharisk,

  // Lane 5
  input    [31:0]    gt5_txdata,
  input     [3:0]    gt5_txcharisk,

  // Lane 6
  input    [31:0]    gt6_txdata,
  input     [3:0]    gt6_txcharisk,

  // Lane 7
  input    [31:0]    gt7_txdata,
  input     [3:0]    gt7_txcharisk,

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

  // Lane 2
  output   [31:0]    gt2_rxdata,
  output    [3:0]    gt2_rxcharisk,
  output    [3:0]    gt2_rxdisperr,
  output    [3:0]    gt2_rxnotintable,

  // Lane 3
  output   [31:0]    gt3_rxdata,
  output    [3:0]    gt3_rxcharisk,
  output    [3:0]    gt3_rxdisperr,
  output    [3:0]    gt3_rxnotintable,

  // Lane 4
  output   [31:0]    gt4_rxdata,
  output    [3:0]    gt4_rxcharisk,
  output    [3:0]    gt4_rxdisperr,
  output    [3:0]    gt4_rxnotintable,

  // Lane 5
  output   [31:0]    gt5_rxdata,
  output    [3:0]    gt5_rxcharisk,
  output    [3:0]    gt5_rxdisperr,
  output    [3:0]    gt5_rxnotintable,

  // Lane 6
  output   [31:0]    gt6_rxdata,
  output    [3:0]    gt6_rxcharisk,
  output    [3:0]    gt6_rxdisperr,
  output    [3:0]    gt6_rxnotintable,

  // Lane 7
  output   [31:0]    gt7_rxdata,
  output    [3:0]    gt7_rxcharisk,
  output    [3:0]    gt7_rxdisperr,
  output    [3:0]    gt7_rxnotintable,

  // Serial ports
  input     [7:0]   rxn_in,
  input     [7:0]   rxp_in,
  output    [7:0]   txn_out,
  output    [7:0]   txp_out
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
  wire  [7:0]     rxresetdone;
  wire  [7:0]     txresetdone;
  
  // Register resetdone straight from transceiver. This is a non critical path and
  // net delays on 8-12 designs can become critical
  reg   [7:0]     rxresetdone_r;
  reg   [7:0]     txresetdone_r;




  wire  [7:0]     gt_rxoshold;
  wire  [7:0]     gt_rxdfeagchold;
  wire  [7:0]     gt_rxdfelfhold;
  wire  [7:0]     gt_rxdfeuthold;
  wire  [7:0]     gt_rxdfevphold;
  wire  [7:0]     gt_rxdfetap2hold;
  wire  [7:0]     gt_rxdfetap3hold;
  wire  [7:0]     gt_rxdfetap4hold;
  wire  [7:0]     gt_rxdfetap5hold;
  wire  [7:0]     gt_rxdfetap6hold;
  wire  [7:0]     gt_rxdfetap7hold;
  wire  [7:0]     gt_rxdfetap8hold;
  wire  [7:0]     gt_rxdfetap9hold;
  wire  [7:0]     gt_rxdfetap10hold;
  wire  [7:0]     gt_rxdfetap11hold;
  wire  [7:0]     gt_rxdfetap12hold;
  wire  [7:0]     gt_rxdfetap13hold;
  wire  [7:0]     gt_rxdfetap14hold;
  wire  [7:0]     gt_rxdfetap15hold;

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

  wire  [7:0]      gt_rxdfelpmreset;
  wire  [7:0]      gt_rxlpmen;

  // Loopback
  wire  [23:0]    gt_loopback;

  // Power Down
  wire  [15:0]    gt_rxpd;
  wire  [15:0]    gt_txpd;
  reg   [7:0]      gt_rxpd_r;
  wire  [7:0]      gt_rxpd_i;
  wire  [7:0]      gt_rxpd_sync;
 
  wire  [15:0]    txpllclksel_axi;
  wire  [15:0]    rxpllclksel_axi;

  // Transmit Control
  wire  [39:0]    gt_txpostcursor;
  wire  [39:0]    gt_txprecursor;
  wire  [31:0]    gt_txdiffctrl;

  wire  [7:0]     gt_txpolarity;
  wire  [7:0]     gt_rxpolarity;

  wire  [127: 0]  gt_pcsrsvdin;

  wire  [7:0]     gt_txinhibit;

  wire            cpll_pd_0;
  wire            cpll_pd_1;
  wire            cpll_pd_2;
  wire            cpll_pd_3;
  wire            cpll_pd_4;
  wire            cpll_pd_5;
  wire            cpll_pd_6;
  wire            cpll_pd_7;

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

  wire  [8:0]     gt2_drpaddr;
  wire  [15:0]    gt2_drpdi;
  wire            gt2_drpen;
  wire            gt2_drpwe;
  wire  [15:0]    gt2_drpdo;
  wire            gt2_drprdy;

  wire  [8:0]     gt3_drpaddr;
  wire  [15:0]    gt3_drpdi;
  wire            gt3_drpen;
  wire            gt3_drpwe;
  wire  [15:0]    gt3_drpdo;
  wire            gt3_drprdy;

  wire  [8:0]     gt4_drpaddr;
  wire  [15:0]    gt4_drpdi;
  wire            gt4_drpen;
  wire            gt4_drpwe;
  wire  [15:0]    gt4_drpdo;
  wire            gt4_drprdy;

  wire  [8:0]     gt5_drpaddr;
  wire  [15:0]    gt5_drpdi;
  wire            gt5_drpen;
  wire            gt5_drpwe;
  wire  [15:0]    gt5_drpdo;
  wire            gt5_drprdy;

  wire  [8:0]     gt6_drpaddr;
  wire  [15:0]    gt6_drpdi;
  wire            gt6_drpen;
  wire            gt6_drpwe;
  wire  [15:0]    gt6_drpdo;
  wire            gt6_drprdy;

  wire  [8:0]     gt7_drpaddr;
  wire  [15:0]    gt7_drpdi;
  wire            gt7_drpen;
  wire            gt7_drpwe;
  wire  [15:0]    gt7_drpdo;
  wire            gt7_drprdy;


  //Wire declaration for GTHE3
    wire [7 : 0] cplllock_out;
  wire [7 : 0] cpllpd_in;
  wire [7 : 0] cpllreset_in;
  wire [135 : 0] dmonitorout_out;
  wire [71 : 0] drpaddr_in;
  wire [7 : 0] drpclk_in;
  wire [127 : 0] drpdi_in;
  wire [127 : 0] drpdo_out;
  wire [7 : 0] drpen_in;
  wire [7 : 0] drprdy_out;
  wire [7 : 0] drpwe_in;
  wire [7 : 0] eyescandataerror_out;
  wire [7 : 0] eyescanreset_in;
  wire [7 : 0] eyescantrigger_in;
  wire [7 : 0] gthrxn_in;
  wire [7 : 0] gthrxp_in;
  wire [7 : 0] gthtxn_out;
  wire [7 : 0] gthtxp_out;
  wire [7 : 0] gtpowergood_out;
  wire [7 : 0] gtrefclk0_in;
  wire [7 : 0] gtrxreset_in;
  wire [7 : 0] gttxreset_in;
  wire [0 : 0] gtwiz_reset_rx_done_in;
  wire [0 : 0] gtwiz_reset_tx_done_in;
  wire [0 : 0] gtwiz_userclk_rx_active_in;
  wire [0 : 0] gtwiz_userclk_tx_active_in;
  wire [23 : 0] loopback_in;
  wire [127 : 0] pcsrsvdin_in;
  wire [7 : 0] qpll0clk_in;
  wire [7 : 0] qpll0refclk_in;
  wire [7 : 0] qpll1clk_in;
  wire [7 : 0] qpll1refclk_in;
  wire [7 : 0] rx8b10ben_in;
  wire [7 : 0] rxbufreset_in;
  wire [23 : 0] rxbufstatus_out;
  wire [7 : 0] rxbyteisaligned_out;
  wire [7 : 0] rxbyterealign_out;
  wire [7 : 0] rxcdrhold_in;
  wire [7 : 0] rxcdrlock_out;
  wire [7 : 0] rxcommadet_out;
  wire [7 : 0] rxcommadeten_in;
  wire [127 : 0] rxctrl0_out;
  wire [127 : 0] rxctrl1_out;
  wire [63 : 0] rxctrl2_out;
  wire [63 : 0] rxctrl3_out;
  wire [1023 : 0] rxdata_out;
  wire [7 : 0] rxdfeagchold_in;
  wire [7 : 0] rxdfelfhold_in;
  wire [7 : 0] rxdfelpmreset_in;
  wire [7 : 0] rxdfetap10hold_in;
  wire [7 : 0] rxdfetap11hold_in;
  wire [7 : 0] rxdfetap12hold_in;
  wire [7 : 0] rxdfetap13hold_in;
  wire [7 : 0] rxdfetap14hold_in;
  wire [7 : 0] rxdfetap15hold_in;
  wire [7 : 0] rxdfetap2hold_in;
  wire [7 : 0] rxdfetap3hold_in;
  wire [7 : 0] rxdfetap4hold_in;
  wire [7 : 0] rxdfetap5hold_in;
  wire [7 : 0] rxdfetap6hold_in;
  wire [7 : 0] rxdfetap7hold_in;
  wire [7 : 0] rxdfetap8hold_in;
  wire [7 : 0] rxdfetap9hold_in;
  wire [7 : 0] rxdfeuthold_in;
  wire [7 : 0] rxdfevphold_in;
  wire [7 : 0] rxlpmen_in;
  wire [7 : 0] rxmcommaalignen_in;
  wire [7 : 0] rxoshold_in;
  wire [7 : 0] rxoutclk_out;
  wire [7 : 0] rxpcommaalignen_in;
  wire [7 : 0] rxpcsreset_in;
  wire [15 : 0] rxpd_in;
  wire [15 : 0] rxpllclksel_in;
  wire [7 : 0] rxpmareset_in;
  wire [7 : 0] rxpmaresetdone_out;
  wire [7 : 0] rxpolarity_in;
  wire [7 : 0] rxprbscntreset_in;
  wire [7 : 0] rxprbserr_out;
  wire [31 : 0] rxprbssel_in;
  wire [7 : 0] rxprogdivreset_in;
  wire [23 : 0] rxrate_in;
  wire [7 : 0] rxresetdone_out;
  wire [15 : 0] rxsysclksel_in;
  wire [7 : 0] rxuserrdy_in;
  wire [7 : 0] rxusrclk2_in;
  wire [7 : 0] rxusrclk_in;
  wire [7 : 0] tx8b10ben_in;
  wire [15 : 0] txbufstatus_out;
  wire [127 : 0] txctrl0_in;
  wire [127 : 0] txctrl1_in;
  wire [63 : 0] txctrl2_in;
  wire [1023 : 0] txdata_in;
  wire [31 : 0] txdiffctrl_in;
  wire [7 : 0] txinhibit_in;
  wire [7 : 0] txoutclk_out;
  wire [7 : 0] txpcsreset_in;
  wire [15 : 0] txpd_in;
  wire [15 : 0] txpllclksel_in;
  wire [7 : 0] txpmareset_in;
  wire [7 : 0] txpmaresetdone_out;
  wire [7 : 0] txpolarity_in;
  wire [39 : 0] txpostcursor_in;
  wire [7 : 0] txprbsforceerr_in;
  wire [31 : 0] txprbssel_in;
  wire [39 : 0] txprecursor_in;
  wire [7 : 0] txprogdivreset_in;
  wire [7 : 0] txresetdone_out;
  wire [15 : 0] txsysclksel_in;
  wire [7 : 0] txuserrdy_in;
  wire [7 : 0] txusrclk2_in;
  wire [7 : 0] txusrclk_in;

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
  assign txctrl2_in[19:16]  = gt2_txcharisk;
  assign txdata_in[287:256] = gt2_txdata;
  assign txctrl2_in[23:20]  = 0;
  assign txdata_in[383:288] = 0;
  assign txctrl2_in[27:24]  = gt3_txcharisk;
  assign txdata_in[415:384] = gt3_txdata;
  assign txctrl2_in[31:28]  = 0;
  assign txdata_in[511:416] = 0;
  assign txctrl2_in[35:32]  = gt4_txcharisk;
  assign txdata_in[543:512] = gt4_txdata;
  assign txctrl2_in[39:36]  = 0;
  assign txdata_in[639:544] = 0;
  assign txctrl2_in[43:40]  = gt5_txcharisk;
  assign txdata_in[671:640] = gt5_txdata;
  assign txctrl2_in[47:44]  = 0;
  assign txdata_in[767:672] = 0;
  assign txctrl2_in[51:48]  = gt6_txcharisk;
  assign txdata_in[799:768] = gt6_txdata;
  assign txctrl2_in[55:52]  = 0;
  assign txdata_in[895:800] = 0;
  assign txctrl2_in[59:56]   = gt7_txcharisk;
  assign txdata_in[927:896]  = gt7_txdata;
  assign txctrl2_in[63:60]   = 0;
  assign txdata_in[1023:928] = 0;

  // Connect up the GT outputs to the received data and control outputs
  assign gt0_rxdata       = rxdata_out[31:0];
  assign gt0_rxcharisk    = rxctrl0_out[3:0];
  assign gt0_rxdisperr    = rxctrl1_out[3:0];
  assign gt0_rxnotintable = rxctrl3_out[3:0];
  assign gt1_rxdata       = rxdata_out[159:128];
  assign gt1_rxcharisk    = rxctrl0_out[19:16];
  assign gt1_rxdisperr    = rxctrl1_out[19:16];
  assign gt1_rxnotintable = rxctrl3_out[11:8];
  assign gt2_rxdata       = rxdata_out[287:256];
  assign gt2_rxcharisk    = rxctrl0_out[35:32];
  assign gt2_rxdisperr    = rxctrl1_out[35:32];
  assign gt2_rxnotintable = rxctrl3_out[19:16];
  assign gt3_rxdata       = rxdata_out[415:384];
  assign gt3_rxcharisk    = rxctrl0_out[51:48];
  assign gt3_rxdisperr    = rxctrl1_out[51:48];
  assign gt3_rxnotintable = rxctrl3_out[27:24];
  assign gt4_rxdata       = rxdata_out[543:512];
  assign gt4_rxcharisk    = rxctrl0_out[67:64];
  assign gt4_rxdisperr    = rxctrl1_out[67:64];
  assign gt4_rxnotintable = rxctrl3_out[35:32];
  assign gt5_rxdata       = rxdata_out[671:640];
  assign gt5_rxcharisk    = rxctrl0_out[83:80];
  assign gt5_rxdisperr    = rxctrl1_out[83:80];
  assign gt5_rxnotintable = rxctrl3_out[43:40];
  assign gt6_rxdata       = rxdata_out[799:768];
  assign gt6_rxcharisk    = rxctrl0_out[99:96];
  assign gt6_rxdisperr    = rxctrl1_out[99:96];
  assign gt6_rxnotintable = rxctrl3_out[51:48];
  assign gt7_rxdata       = rxdata_out[927:896];
  assign gt7_rxcharisk    = rxctrl0_out[115:112];
  assign gt7_rxdisperr    = rxctrl1_out[115:112];
  assign gt7_rxnotintable = rxctrl3_out[59:56];

  // Connect up the GT DRP bus to the DRP inputs and outputs.
  // Tie unused GT wizard inputs to 0.
  assign drpclk_in        = {8{drpclk}};

  assign drpaddr_in        = {gt7_drpaddr,gt6_drpaddr,gt5_drpaddr,gt4_drpaddr,gt3_drpaddr,gt2_drpaddr,gt1_drpaddr,gt0_drpaddr};
  assign drpdi_in          = {gt7_drpdi,gt6_drpdi,gt5_drpdi,gt4_drpdi,gt3_drpdi,gt2_drpdi,gt1_drpdi,gt0_drpdi};
  assign drpen_in          = {gt7_drpen,gt6_drpen,gt5_drpen,gt4_drpen,gt3_drpen,gt2_drpen,gt1_drpen,gt0_drpen};
  assign drpwe_in          = {gt7_drpwe,gt6_drpwe,gt5_drpwe,gt4_drpwe,gt3_drpwe,gt2_drpwe,gt1_drpwe,gt0_drpwe};

  assign gt0_drpdo         = drpdo_out[15:0];
  assign gt1_drpdo         = drpdo_out[31:16];
  assign gt2_drpdo         = drpdo_out[47:32];
  assign gt3_drpdo         = drpdo_out[63:48];
  assign gt4_drpdo         = drpdo_out[79:64];
  assign gt5_drpdo         = drpdo_out[95:80];
  assign gt6_drpdo         = drpdo_out[111:96];
  assign gt7_drpdo         = drpdo_out[127:112];

  assign gt0_drprdy        = drprdy_out[0:0];
  assign gt1_drprdy        = drprdy_out[1:1];
  assign gt2_drprdy        = drprdy_out[2:2];
  assign gt3_drprdy        = drprdy_out[3:3];
  assign gt4_drprdy        = drprdy_out[4:4];
  assign gt5_drprdy        = drprdy_out[5:5];
  assign gt6_drprdy        = drprdy_out[6:6];
  assign gt7_drprdy        = drprdy_out[7:7];

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
  assign rx8b10ben_in                       = {8{1'b1}};
  assign rxcommadeten_in                    = {8{1'b1}};

  assign txoutclk                           = txoutclk_out[0];
  assign txctrl0_in                         = {128{1'b0}};
  assign txctrl1_in                         = {128{1'b0}};
  assign tx8b10ben_in                       = {8{1'b1}};
  assign gtwiz_userclk_tx_active_in[0]      = 1'b1;


   
  assign  cpllpd_in[0]                      = (txpllclksel_axi[1:0] == 2'b00 && rxpllclksel_axi[1:0] == 2'b00) ? (pllreset_tx_out | pllreset_rx_out | cpll_pd_0) :
                                              (txpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_tx_out | cpll_pd_0) :
                                              (rxpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_rx_out | cpll_pd_0) : 1'b0;
  assign  cpllreset_in[0]                     = 1'b0;

  assign  cpllpd_in[1]                      = (txpllclksel_axi[1:0] == 2'b00 && rxpllclksel_axi[1:0] == 2'b00) ? (pllreset_tx_out | pllreset_rx_out | cpll_pd_1) :
                                              (txpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_tx_out | cpll_pd_1) :
                                              (rxpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_rx_out | cpll_pd_1) : 1'b0;
  assign  cpllreset_in[1]                     = 1'b0;

  assign  cpllpd_in[2]                      = (txpllclksel_axi[1:0] == 2'b00 && rxpllclksel_axi[1:0] == 2'b00) ? (pllreset_tx_out | pllreset_rx_out | cpll_pd_2) :
                                              (txpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_tx_out | cpll_pd_2) :
                                              (rxpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_rx_out | cpll_pd_2) : 1'b0;
  assign  cpllreset_in[2]                     = 1'b0;

  assign  cpllpd_in[3]                      = (txpllclksel_axi[1:0] == 2'b00 && rxpllclksel_axi[1:0] == 2'b00) ? (pllreset_tx_out | pllreset_rx_out | cpll_pd_3) :
                                              (txpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_tx_out | cpll_pd_3) :
                                              (rxpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_rx_out | cpll_pd_3) : 1'b0;
  assign  cpllreset_in[3]                     = 1'b0;

  assign  cpllpd_in[4]                      = (txpllclksel_axi[1:0] == 2'b00 && rxpllclksel_axi[1:0] == 2'b00) ? (pllreset_tx_out | pllreset_rx_out | cpll_pd_4) :
                                              (txpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_tx_out | cpll_pd_4) :
                                              (rxpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_rx_out | cpll_pd_4) : 1'b0;
  assign  cpllreset_in[4]                     = 1'b0;

  assign  cpllpd_in[5]                      = (txpllclksel_axi[1:0] == 2'b00 && rxpllclksel_axi[1:0] == 2'b00) ? (pllreset_tx_out | pllreset_rx_out | cpll_pd_5) :
                                              (txpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_tx_out | cpll_pd_5) :
                                              (rxpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_rx_out | cpll_pd_5) : 1'b0;
  assign  cpllreset_in[5]                     = 1'b0;

  assign  cpllpd_in[6]                      = (txpllclksel_axi[1:0] == 2'b00 && rxpllclksel_axi[1:0] == 2'b00) ? (pllreset_tx_out | pllreset_rx_out | cpll_pd_6) :
                                              (txpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_tx_out | cpll_pd_6) :
                                              (rxpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_rx_out | cpll_pd_6) : 1'b0;
  assign  cpllreset_in[6]                     = 1'b0;

  assign  cpllpd_in[7]                      = (txpllclksel_axi[1:0] == 2'b00 && rxpllclksel_axi[1:0] == 2'b00) ? (pllreset_tx_out | pllreset_rx_out | cpll_pd_7) :
                                              (txpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_tx_out | cpll_pd_7) :
                                              (rxpllclksel_axi[1:0] == 2'b00)                    ? (pllreset_rx_out | cpll_pd_7) : 1'b0;
  assign  cpllreset_in[7]                     = 1'b0;

    
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
  assign  loopback_in[23:0]       = gt_loopback[23:0];
  assign  txprbssel_in[31:0]      = {8{gt_prbssel}};
  assign  txprbsforceerr_in[7:0]  = gt_txprbsforceerr;
  assign  rxprbssel_in[31:0]      = gt_rxprbssel[31:0];
  assign  rxprbscntreset_in[7:0]  = gt_rxprbscntreset;
  assign  gt_rxprbserr            = rxprbserr_out[7:0];
  assign  rxpolarity_in[7:0]      = gt_rxpolarity[7:0];
  assign  txpolarity_in[7:0]      = gt_txpolarity[7:0];
  assign  txinhibit_in[7:0]       = gt_txinhibit[7:0];
  assign  txn_out[7:0]            = gthtxn_out[7:0];
  assign  txp_out[7:0]            = gthtxp_out[7:0];
  assign  txdiffctrl_in           = gt_txdiffctrl;
  assign  txpostcursor_in[39:0]   = gt_txpostcursor;
  assign  txprecursor_in[39:0]    = gt_txprecursor;
  assign  gt_txresetdone          = txresetdone_out[7:0];
  assign  gt_rxresetdone          = rxresetdone_out[7:0];
  assign  gthrxn_in[7:0]          = rxn_in[7:0];
  assign  gthrxp_in[7:0]          = rxp_in[7:0];
  assign  txusrclk_in[7:0]        = {8{tx_core_clk}};
  assign  txusrclk2_in[7:0]       = {8{tx_core_clk}};
  assign  rxusrclk_in[7:0]        = {8{rx_core_clk}};
  assign  rxusrclk2_in[7:0]       = {8{rx_core_clk}};
  assign  rxmcommaalignen_in[7:0] = {8{rxencommaalign}};
  assign  rxpcommaalignen_in[7:0] = {8{rxencommaalign}};
  assign  rxcdrlock_in            = rxcdrlock_out[7] & rxcdrlock_out[6] & rxcdrlock_out[5] & rxcdrlock_out[4] &
                                    rxcdrlock_out[3] & rxcdrlock_out[2] & rxcdrlock_out[1] & rxcdrlock_out[0];
  assign  txprogdivreset_in[7:0]  = {8{txprogdivreset_out}};
  assign  rxprogdivreset_in[7:0]  = {8{rxprogdivreset_out}};
  assign  gttxreset_in[7:0]       = {8{gttxreset_out}};
  assign  gtrxreset_in[7:0]       = {8{gtrxreset_out}};
  assign  txuserrdy_in[7:0]       = {8{txuserrdy_out}};
  assign  rxuserrdy_in[7:0]       = {8{rxuserrdy_out}};
  assign  rx_pll_lock_i           = (cplllock_out[7] & cplllock_out[6] & cplllock_out[5] & cplllock_out[4] & cplllock_out[3] & cplllock_out[2] & cplllock_out[1] & cplllock_out[0]);
  assign  tx_pll_lock_i           = (cplllock_out[7] & cplllock_out[6] & cplllock_out[5] & cplllock_out[4] & cplllock_out[3] & cplllock_out[2] & cplllock_out[1] & cplllock_out[0]);
  assign  gt_cplllock             = cplllock_out[7:0];
  assign  gtrefclk0_in[7:0]       = {8{cpll_refclk}};
  assign  txsysclksel_in          = {8{txsysclksel_axi}};
  assign  rxsysclksel_in          = {8{rxsysclksel_axi}};
  assign  txpllclksel_in          = txpllclksel_axi;
  assign  rxpllclksel_in          = rxpllclksel_axi;
  assign  rxpd_in[15:0]           = gt_rxpd;
  assign  txpd_in[15:0]           = gt_txpd;
  assign  txpcsreset_in[7:0]      = gt_txpcsreset;
  assign  txpmareset_in[7:0]      = gt_txpmareset;
  assign  rxpcsreset_in[7:0]      = gt_rxpcsreset;
  assign  rxpmareset_in[7:0]      = gt_rxpmareset;
  assign  rxbufreset_in[7:0]      = gt_rxbufreset;
  assign  gt_rxpmaresetdone       = rxpmaresetdone_out[7:0];
  assign  gt_txbufstatus          = txbufstatus_out[15:0];
  assign  gt_rxbufstatus          = rxbufstatus_out[23:0];
  assign  rxrate_in[23:0]         = gt_rxrate;
  assign  eyescantrigger_in[7:0]  = gt_eyescantrigger;
  assign  eyescanreset_in[7:0]    = gt_eyescanreset;
  assign  gt_eyescandataerror     = eyescandataerror_out[7:0];
  assign  rxdfelpmreset_in[7:0]   = gt_rxdfelpmreset;
  assign  rxlpmen_in[7:0]         = gt_rxlpmen;
  assign  rxcdrhold_in[7:0]       = gt_rxcdrhold;
  assign  rxoshold_in[7:0]        = gt_rxoshold;
  assign  rxdfeagchold_in[7:0]    = gt_rxdfeagchold;
  assign  rxdfelfhold_in[7:0]     = gt_rxdfelfhold;
  assign  rxdfeuthold_in[7:0]     = gt_rxdfeuthold;
  assign  rxdfevphold_in[7:0]     = gt_rxdfevphold;
  assign  rxdfetap2hold_in[7:0]   = gt_rxdfetap2hold;
  assign  rxdfetap3hold_in[7:0]   = gt_rxdfetap3hold;
  assign  rxdfetap4hold_in[7:0]   = gt_rxdfetap4hold;
  assign  rxdfetap5hold_in[7:0]   = gt_rxdfetap5hold;
  assign  rxdfetap6hold_in[7:0]   = gt_rxdfetap6hold;
  assign  rxdfetap7hold_in[7:0]   = gt_rxdfetap7hold;
  assign  rxdfetap8hold_in[7:0]   = gt_rxdfetap8hold;
  assign  rxdfetap9hold_in[7:0]   = gt_rxdfetap9hold;
  assign  rxdfetap10hold_in[7:0]  = gt_rxdfetap10hold;
  assign  rxdfetap11hold_in[7:0]  = gt_rxdfetap11hold;
  assign  rxdfetap12hold_in[7:0]  = gt_rxdfetap12hold;
  assign  rxdfetap13hold_in[7:0]  = gt_rxdfetap13hold;
  assign  rxdfetap14hold_in[7:0]  = gt_rxdfetap14hold;
  assign  rxdfetap15hold_in[7:0]  = gt_rxdfetap15hold;
  assign  gt_dmonitorout          = dmonitorout_out;
  assign  gt_rxcommadet           = rxcommadet_out[7:0];
  assign  pcsrsvdin_in            = gt_pcsrsvdin;

  assign  qpll0clk_in[7:0]        = {{4{common1_qpll0_clk_in}}, {4{common0_qpll0_clk_in}}};
  assign  qpll0refclk_in[7:0]     = {{4{common1_qpll0_refclk_in}}, {4{common0_qpll0_refclk_in}}};
  assign  qpll1clk_in[7:0]        = {{4{common1_qpll1_clk_in}}, {4{common0_qpll1_clk_in}}};
  assign  qpll1refclk_in[7:0]     = {{4{common1_qpll1_refclk_in}}, {4{common0_qpll1_refclk_in}}};

  // PLL lock input to GT Reset Module
  always@(posedge drpclk)
    tx_pll_lock              <= (txpllclksel_axi[1:0] == 2'b00) ? tx_pll_lock_i :
                                (txpllclksel_axi[1:0] == 2'b11) ? common0_qpll0_lock_in & common1_qpll0_lock_in :
                                (txpllclksel_axi[1:0] == 2'b10) ? common0_qpll1_lock_in & common1_qpll1_lock_in : 1'b0;

  always@(posedge drpclk)
    rx_pll_lock              <= (rxpllclksel_axi[1:0] == 2'b00) ? rx_pll_lock_i :
                                (rxpllclksel_axi[1:0] == 2'b11) ? common0_qpll0_lock_in & common1_qpll0_lock_in :
                                (rxpllclksel_axi[1:0] == 2'b10) ? common0_qpll1_lock_in & common1_qpll1_lock_in : 1'b0;

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
  
  // Lane 2 Power Down
  assign gt_rxpd_i[2] = &gt_rxpd[5:4];
  
  always@(posedge s_axi_aclk)
    gt_rxpd_r[2]   <=  gt_rxpd_i[2];
  
  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_gt_rxpd_2 
  (
    .clk             (rx_core_clk),
    .data_in         (gt_rxpd_r[2]),
    .data_out        (gt_rxpd_sync[2])
  );
 
  always@(posedge rx_core_clk)
    rxresetdone_r[2]    <=  rxresetdone_out[2];

  always@(posedge tx_core_clk)
    txresetdone_r[2]    <=  txresetdone_out[2];  

  assign rxresetdone[2] = (gt_rxpd_sync[2] == 1'b0) ? rxresetdone_r[2] : 1'b1;
  assign txresetdone[2] = (gt_txpd[5:4] == 2'b00) ? txresetdone_r[2] : 1'b1;
  
  // Lane 3 Power Down
  assign gt_rxpd_i[3] = &gt_rxpd[7:6];
  
  always@(posedge s_axi_aclk)
    gt_rxpd_r[3]   <=  gt_rxpd_i[3];
  
  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_gt_rxpd_3 
  (
    .clk             (rx_core_clk),
    .data_in         (gt_rxpd_r[3]),
    .data_out        (gt_rxpd_sync[3])
  );
 
  always@(posedge rx_core_clk)
    rxresetdone_r[3]    <=  rxresetdone_out[3];

  always@(posedge tx_core_clk)
    txresetdone_r[3]    <=  txresetdone_out[3];  

  assign rxresetdone[3] = (gt_rxpd_sync[3] == 1'b0) ? rxresetdone_r[3] : 1'b1;
  assign txresetdone[3] = (gt_txpd[7:6] == 2'b00) ? txresetdone_r[3] : 1'b1;
  
  // Lane 4 Power Down
  assign gt_rxpd_i[4] = &gt_rxpd[9:8];
  
  always@(posedge s_axi_aclk)
    gt_rxpd_r[4]   <=  gt_rxpd_i[4];
  
  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_gt_rxpd_4 
  (
    .clk             (rx_core_clk),
    .data_in         (gt_rxpd_r[4]),
    .data_out        (gt_rxpd_sync[4])
  );
 
  always@(posedge rx_core_clk)
    rxresetdone_r[4]    <=  rxresetdone_out[4];

  always@(posedge tx_core_clk)
    txresetdone_r[4]    <=  txresetdone_out[4];  

  assign rxresetdone[4] = (gt_rxpd_sync[4] == 1'b0) ? rxresetdone_r[4] : 1'b1;
  assign txresetdone[4] = (gt_txpd[9:8] == 2'b00) ? txresetdone_r[4] : 1'b1;
  
  // Lane 5 Power Down
  assign gt_rxpd_i[5] = &gt_rxpd[11:10];
  
  always@(posedge s_axi_aclk)
    gt_rxpd_r[5]   <=  gt_rxpd_i[5];
  
  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_gt_rxpd_5 
  (
    .clk             (rx_core_clk),
    .data_in         (gt_rxpd_r[5]),
    .data_out        (gt_rxpd_sync[5])
  );
 
  always@(posedge rx_core_clk)
    rxresetdone_r[5]    <=  rxresetdone_out[5];

  always@(posedge tx_core_clk)
    txresetdone_r[5]    <=  txresetdone_out[5];  

  assign rxresetdone[5] = (gt_rxpd_sync[5] == 1'b0) ? rxresetdone_r[5] : 1'b1;
  assign txresetdone[5] = (gt_txpd[11:10] == 2'b00) ? txresetdone_r[5] : 1'b1;
  
  // Lane 6 Power Down
  assign gt_rxpd_i[6] = &gt_rxpd[13:12];
  
  always@(posedge s_axi_aclk)
    gt_rxpd_r[6]   <=  gt_rxpd_i[6];
  
  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_gt_rxpd_6 
  (
    .clk             (rx_core_clk),
    .data_in         (gt_rxpd_r[6]),
    .data_out        (gt_rxpd_sync[6])
  );
 
  always@(posedge rx_core_clk)
    rxresetdone_r[6]    <=  rxresetdone_out[6];

  always@(posedge tx_core_clk)
    txresetdone_r[6]    <=  txresetdone_out[6];  

  assign rxresetdone[6] = (gt_rxpd_sync[6] == 1'b0) ? rxresetdone_r[6] : 1'b1;
  assign txresetdone[6] = (gt_txpd[13:12] == 2'b00) ? txresetdone_r[6] : 1'b1;
  
  // Lane 7 Power Down
  assign gt_rxpd_i[7] = &gt_rxpd[15:14];
  
  always@(posedge s_axi_aclk)
    gt_rxpd_r[7]   <=  gt_rxpd_i[7];
  
  jesd204_phy_0_sync_block #(
    .TYPE (0)
  ) sync_gt_rxpd_7 
  (
    .clk             (rx_core_clk),
    .data_in         (gt_rxpd_r[7]),
    .data_out        (gt_rxpd_sync[7])
  );
 
  always@(posedge rx_core_clk)
    rxresetdone_r[7]    <=  rxresetdone_out[7];

  always@(posedge tx_core_clk)
    txresetdone_r[7]    <=  txresetdone_out[7];  

  assign rxresetdone[7] = (gt_rxpd_sync[7] == 1'b0) ? rxresetdone_r[7] : 1'b1;
  assign txresetdone[7] = (gt_txpd[15:14] == 2'b00) ? txresetdone_r[7] : 1'b1;
  
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
  assign qpll0_lock_and       = (common0_qpll0_lock_in && common1_qpll0_lock_in);
  assign qpll1_lock_and       = (common0_qpll1_lock_in && common1_qpll1_lock_in);

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
  assign gt_pcsrsvdin[47:35] = 13'd0;
  assign gt_pcsrsvdin[33:32] = 2'd0;
  assign gt_pcsrsvdin[63:51] = 13'd0;
  assign gt_pcsrsvdin[49:48] = 2'd0;
  assign gt_pcsrsvdin[79:67] = 13'd0;
  assign gt_pcsrsvdin[65:64] = 2'd0;
  assign gt_pcsrsvdin[95:83] = 13'd0;
  assign gt_pcsrsvdin[81:80] = 2'd0;
  assign gt_pcsrsvdin[111:99] = 13'd0;
  assign gt_pcsrsvdin[97:96] = 2'd0;
  assign gt_pcsrsvdin[127:115] = 13'd0;
  assign gt_pcsrsvdin[113:112] = 2'd0;

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
  assign txpllclksel_axi = {8{txpllclksel_axi_reg}};
  assign rxpllclksel_axi = {8{rxpllclksel_axi_reg}};

  // Copy the rx equalizer setting to each lane
  assign gt_rxlpmen        = {8{rxlpmen_axi}};
  assign gt_rxdfelpmreset  = {8{rxdfelpmreset_axi}};
  assign gt_rxoshold       = {8{rxoshold_axi}};             
  assign gt_rxdfeagchold   = {8{rxdfeagchold_axi}};
  assign gt_rxdfelfhold    = {8{rxdfelfhold_axi}};
  assign gt_rxdfeuthold    = {8{rxdfeuthold_axi}};
  assign gt_rxdfevphold    = {8{rxdfevphold_axi}};
  assign gt_rxdfetap2hold  = {8{rxdfetap2hold_axi}};
  assign gt_rxdfetap3hold  = {8{rxdfetap3hold_axi}};
  assign gt_rxdfetap4hold  = {8{rxdfetap4hold_axi}};
  assign gt_rxdfetap5hold  = {8{rxdfetap5hold_axi}};
  assign gt_rxdfetap6hold  = {8{rxdfetap6hold_axi}};
  assign gt_rxdfetap7hold  = {8{rxdfetap7hold_axi}};
  assign gt_rxdfetap8hold  = {8{rxdfetap8hold_axi}};
  assign gt_rxdfetap9hold  = {8{rxdfetap9hold_axi}};
  assign gt_rxdfetap10hold = {8{rxdfetap10hold_axi}};
  assign gt_rxdfetap11hold = {8{rxdfetap11hold_axi}};
  assign gt_rxdfetap12hold = {8{rxdfetap12hold_axi}};
  assign gt_rxdfetap13hold = {8{rxdfetap13hold_axi}};
  assign gt_rxdfetap14hold = {8{rxdfetap14hold_axi}};
  assign gt_rxdfetap15hold = {8{rxdfetap15hold_axi}};

//-----------------------------------------------------------------------------
// AXI interface for PHYCore
//-----------------------------------------------------------------------------
  jesd204_phy_0_phyCoreCtrlInterface phyCoreCtrlInterface_i (
  //---------------------------------------------------------------------------
  // DRP Common mailbox. Quads = 2
  //---------------------------------------------------------------------------
  // DRP interface 0
  .cmn_drp0_addr                       (common0_drpaddr               ),
  .cmn_drp0_di                         (common0_drpdi                 ),
  .cmn_drp0_we                         (common0_drpwe                 ),
  .cmn_drp0_en                         (common0_drpen                 ),
  .cmn_drp0_rst                        (                              ),

  .cmn_drp0_do                         (common0_drpdo                 ),
  .cmn_drp0_rdy                        (common0_drprdy                ),

  // DRP interface 1
  .cmn_drp1_addr                       (common1_drpaddr               ),
  .cmn_drp1_di                         (common1_drpdi                 ),
  .cmn_drp1_we                         (common1_drpwe                 ),
  .cmn_drp1_en                         (common1_drpen                 ),
  .cmn_drp1_rst                        (                              ),

  .cmn_drp1_do                         (common1_drpdo                 ),
  .cmn_drp1_rdy                        (common1_drprdy                ),

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
  // Transceivers interface 2
  .gt_drp2_addr                        (gt2_drpaddr                   ),
  .gt_drp2_di                          (gt2_drpdi                     ),
  .gt_drp2_we                          (gt2_drpwe                     ),
  .gt_drp2_en                          (gt2_drpen                     ),
  .gt_drp2_rst                         (gt_pcsrsvdin[34]              ),

  .gt_drp2_do                          (gt2_drpdo                     ),
  .gt_drp2_rdy                         (gt2_drprdy                    ),
  // Transceivers interface 3
  .gt_drp3_addr                        (gt3_drpaddr                   ),
  .gt_drp3_di                          (gt3_drpdi                     ),
  .gt_drp3_we                          (gt3_drpwe                     ),
  .gt_drp3_en                          (gt3_drpen                     ),
  .gt_drp3_rst                         (gt_pcsrsvdin[50]              ),

  .gt_drp3_do                          (gt3_drpdo                     ),
  .gt_drp3_rdy                         (gt3_drprdy                    ),
  // Transceivers interface 4
  .gt_drp4_addr                        (gt4_drpaddr                   ),
  .gt_drp4_di                          (gt4_drpdi                     ),
  .gt_drp4_we                          (gt4_drpwe                     ),
  .gt_drp4_en                          (gt4_drpen                     ),
  .gt_drp4_rst                         (gt_pcsrsvdin[66]              ),

  .gt_drp4_do                          (gt4_drpdo                     ),
  .gt_drp4_rdy                         (gt4_drprdy                    ),
  // Transceivers interface 5
  .gt_drp5_addr                        (gt5_drpaddr                   ),
  .gt_drp5_di                          (gt5_drpdi                     ),
  .gt_drp5_we                          (gt5_drpwe                     ),
  .gt_drp5_en                          (gt5_drpen                     ),
  .gt_drp5_rst                         (gt_pcsrsvdin[82]              ),

  .gt_drp5_do                          (gt5_drpdo                     ),
  .gt_drp5_rdy                         (gt5_drprdy                    ),
  // Transceivers interface 6
  .gt_drp6_addr                        (gt6_drpaddr                   ),
  .gt_drp6_di                          (gt6_drpdi                     ),
  .gt_drp6_we                          (gt6_drpwe                     ),
  .gt_drp6_en                          (gt6_drpen                     ),
  .gt_drp6_rst                         (gt_pcsrsvdin[98]              ),

  .gt_drp6_do                          (gt6_drpdo                     ),
  .gt_drp6_rdy                         (gt6_drprdy                    ),
  // Transceivers interface 7
  .gt_drp7_addr                        (gt7_drpaddr                   ),
  .gt_drp7_di                          (gt7_drpdi                     ),
  .gt_drp7_we                          (gt7_drpwe                     ),
  .gt_drp7_en                          (gt7_drpen                     ),
  .gt_drp7_rst                         (gt_pcsrsvdin[114]             ),

  .gt_drp7_do                          (gt7_drpdo                     ),
  .gt_drp7_rdy                         (gt7_drprdy                    ),

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

  // Transceivers debug interface 2
  // Async signals
  .rx_pd_2                             (gt_rxpd[5:4]                  ),
  .cpll_pd_2                           (cpll_pd_2                     ),
  .txpostcursor_2                      (gt_txpostcursor[14:10]        ),
  .txprecursor_2                       (gt_txprecursor[14:10]         ),
  .loopback_2                          (gt_loopback[8:6]              ),

  // TXUSRCLK2 domain
  .tx_pd_2                             (gt_txpd[5:4]                  ),
  .txdiffctrl_2                        (gt_txdiffctrl[11:8]           ),
  .txinihibit_2                        (gt_txinhibit[2]               ),
  .txpolarity_2                        (gt_txpolarity[2]              ),

  // RXUSRCLK2 domain
  .rxpolarity_2                        (gt_rxpolarity[2]              ),

  // Transceivers debug interface 3
  // Async signals
  .rx_pd_3                             (gt_rxpd[7:6]                  ),
  .cpll_pd_3                           (cpll_pd_3                     ),
  .txpostcursor_3                      (gt_txpostcursor[19:15]        ),
  .txprecursor_3                       (gt_txprecursor[19:15]         ),
  .loopback_3                          (gt_loopback[11:9]             ),

  // TXUSRCLK2 domain
  .tx_pd_3                             (gt_txpd[7:6]                  ),
  .txdiffctrl_3                        (gt_txdiffctrl[15:12]          ),
  .txinihibit_3                        (gt_txinhibit[3]               ),
  .txpolarity_3                        (gt_txpolarity[3]              ),

  // RXUSRCLK2 domain
  .rxpolarity_3                        (gt_rxpolarity[3]              ),

  // Transceivers debug interface 4
  // Async signals
  .rx_pd_4                             (gt_rxpd[9:8]                  ),
  .cpll_pd_4                           (cpll_pd_4                     ),
  .txpostcursor_4                      (gt_txpostcursor[24:20]        ),
  .txprecursor_4                       (gt_txprecursor[24:20]         ),
  .loopback_4                          (gt_loopback[14:12]            ),

  // TXUSRCLK2 domain
  .tx_pd_4                             (gt_txpd[9:8]                  ),
  .txdiffctrl_4                        (gt_txdiffctrl[19:16]          ),
  .txinihibit_4                        (gt_txinhibit[4]               ),
  .txpolarity_4                        (gt_txpolarity[4]              ),

  // RXUSRCLK2 domain
  .rxpolarity_4                        (gt_rxpolarity[4]              ),

  // Transceivers debug interface 5
  // Async signals
  .rx_pd_5                             (gt_rxpd[11:10]                ),
  .cpll_pd_5                           (cpll_pd_5                     ),
  .txpostcursor_5                      (gt_txpostcursor[29:25]        ),
  .txprecursor_5                       (gt_txprecursor[29:25]         ),
  .loopback_5                          (gt_loopback[17:15]            ),

  // TXUSRCLK2 domain
  .tx_pd_5                             (gt_txpd[11:10]                ),
  .txdiffctrl_5                        (gt_txdiffctrl[23:20]          ),
  .txinihibit_5                        (gt_txinhibit[5]               ),
  .txpolarity_5                        (gt_txpolarity[5]              ),

  // RXUSRCLK2 domain
  .rxpolarity_5                        (gt_rxpolarity[5]              ),

  // Transceivers debug interface 6
  // Async signals
  .rx_pd_6                             (gt_rxpd[13:12]                ),
  .cpll_pd_6                           (cpll_pd_6                     ),
  .txpostcursor_6                      (gt_txpostcursor[34:30]        ),
  .txprecursor_6                       (gt_txprecursor[34:30]         ),
  .loopback_6                          (gt_loopback[20:18]            ),

  // TXUSRCLK2 domain
  .tx_pd_6                             (gt_txpd[13:12]                ),
  .txdiffctrl_6                        (gt_txdiffctrl[27:24]          ),
  .txinihibit_6                        (gt_txinhibit[6]               ),
  .txpolarity_6                        (gt_txpolarity[6]              ),

  // RXUSRCLK2 domain
  .rxpolarity_6                        (gt_rxpolarity[6]              ),

  // Transceivers debug interface 7
  // Async signals
  .rx_pd_7                             (gt_rxpd[15:14]                ),
  .cpll_pd_7                           (cpll_pd_7                     ),
  .txpostcursor_7                      (gt_txpostcursor[39:35]        ),
  .txprecursor_7                       (gt_txprecursor[39:35]         ),
  .loopback_7                          (gt_loopback[23:21]            ),

  // TXUSRCLK2 domain
  .tx_pd_7                             (gt_txpd[15:14]                ),
  .txdiffctrl_7                        (gt_txdiffctrl[31:28]          ),
  .txinihibit_7                        (gt_txinhibit[7]               ),
  .txpolarity_7                        (gt_txpolarity[7]              ),

  // RXUSRCLK2 domain
  .rxpolarity_7                        (gt_rxpolarity[7]              ),

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
  // Common Debug interface Quads = 2
  //---------------------------------------------------------------------------
  // Common debug interface 0
  .qpll0_pd_0                          (common0_qpll0_pd              ),
  .qpll1_pd_0                          (common0_qpll1_pd              ),
  // Common debug interface 1
  .qpll0_pd_1                          (common1_qpll0_pd              ),
  .qpll1_pd_1                          (common1_qpll1_pd              ),

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
