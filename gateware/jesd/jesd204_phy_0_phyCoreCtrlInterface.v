//-----------------------------------------------------------------------------
// Title      : phyCoreCtrlInterface
// Project    : NA
//-----------------------------------------------------------------------------
// File       : phyCoreCtrlInterface.v
// Author     : Xilinx Inc.
//-----------------------------------------------------------------------------
// (c) Copyright 2017 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE 'AS IS' AND
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
// (individually and collectively, 'Critical
// Applications'). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module jesd204_phy_0_phyCoreCtrlInterface #(
 parameter integer  C_S_AXI_ADDR_WIDTH             = 12,
 parameter integer  BANK_DECODE_HIGH_BIT           = 11,
 parameter integer  BANK_DECODE_HIGH_LOW           = 8,
 parameter integer  CMN_C_S_DRP_ADDR_WIDTH         = 9,
 parameter integer  GT_C_S_DRP_ADDR_WIDTH          = 9,
 parameter integer  C_S_TIMEOUT_WIDTH              = 12
) (
 
//-----------------------------------------------------------------------------
// Signal declarations for BANK phyAxiConfig
//-----------------------------------------------------------------------------
   output                                 timeout_enable,
   output      [11:0]                     timeout_value,
   input                                  tx_reset_not_done,
   input                                  rx_reset_not_done,
   input                                  cpll_not_locked,
   input                                  qpll0_not_locked,
   input                                  qpll1_not_locked,

 
//-----------------------------------------------------------------------------
// Signal declarations for BANK commonDbgCtrl
//-----------------------------------------------------------------------------
   output                                 qpll0_pd_0,
   output                                 qpll1_pd_0,

   output                                 qpll0_pd_1,
   output                                 qpll1_pd_1,

//-----------------------------------------------------------------------------
// Signal declarations for BANK transDbgCtrl_async
//-----------------------------------------------------------------------------
   output      [1:0]                      rx_pd_0,
   output                                 cpll_pd_0,
   output      [1:0]                      txpllclksel,
   output      [1:0]                      rxpllclksel,
   output      [4:0]                      txpostcursor_0,
   output      [4:0]                      txprecursor_0,
   output      [2:0]                      loopback_0,
   output                                 tx_sys_reset_axi,
   output                                 rx_sys_reset_axi,
   output      [17:0]                     cpll_cal_per,
   output      [17:0]                     cpll_cal_tol,

   output      [1:0]                      rx_pd_1,
   output                                 cpll_pd_1,
   output      [4:0]                      txpostcursor_1,
   output      [4:0]                      txprecursor_1,
   output      [2:0]                      loopback_1,

   output      [1:0]                      rx_pd_2,
   output                                 cpll_pd_2,
   output      [4:0]                      txpostcursor_2,
   output      [4:0]                      txprecursor_2,
   output      [2:0]                      loopback_2,

   output      [1:0]                      rx_pd_3,
   output                                 cpll_pd_3,
   output      [4:0]                      txpostcursor_3,
   output      [4:0]                      txprecursor_3,
   output      [2:0]                      loopback_3,

   output      [1:0]                      rx_pd_4,
   output                                 cpll_pd_4,
   output      [4:0]                      txpostcursor_4,
   output      [4:0]                      txprecursor_4,
   output      [2:0]                      loopback_4,

   output      [1:0]                      rx_pd_5,
   output                                 cpll_pd_5,
   output      [4:0]                      txpostcursor_5,
   output      [4:0]                      txprecursor_5,
   output      [2:0]                      loopback_5,

   output      [1:0]                      rx_pd_6,
   output                                 cpll_pd_6,
   output      [4:0]                      txpostcursor_6,
   output      [4:0]                      txprecursor_6,
   output      [2:0]                      loopback_6,

   output      [1:0]                      rx_pd_7,
   output                                 cpll_pd_7,
   output      [4:0]                      txpostcursor_7,
   output      [4:0]                      txprecursor_7,
   output      [2:0]                      loopback_7,

//-----------------------------------------------------------------------------
// Signal declarations for BANK transDbgCtrl_tx
//-----------------------------------------------------------------------------
   output      [1:0]                      tx_pd_0,
   output      [3:0]                      txdiffctrl_0,
   output                                 txinihibit_0,
   output                                 txpolarity_0,

   output      [1:0]                      tx_pd_1,
   output      [3:0]                      txdiffctrl_1,
   output                                 txinihibit_1,
   output                                 txpolarity_1,

   output      [1:0]                      tx_pd_2,
   output      [3:0]                      txdiffctrl_2,
   output                                 txinihibit_2,
   output                                 txpolarity_2,

   output      [1:0]                      tx_pd_3,
   output      [3:0]                      txdiffctrl_3,
   output                                 txinihibit_3,
   output                                 txpolarity_3,

   output      [1:0]                      tx_pd_4,
   output      [3:0]                      txdiffctrl_4,
   output                                 txinihibit_4,
   output                                 txpolarity_4,

   output      [1:0]                      tx_pd_5,
   output      [3:0]                      txdiffctrl_5,
   output                                 txinihibit_5,
   output                                 txpolarity_5,

   output      [1:0]                      tx_pd_6,
   output      [3:0]                      txdiffctrl_6,
   output                                 txinihibit_6,
   output                                 txpolarity_6,

   output      [1:0]                      tx_pd_7,
   output      [3:0]                      txdiffctrl_7,
   output                                 txinihibit_7,
   output                                 txpolarity_7,

//-----------------------------------------------------------------------------
// Signal declarations for BANK transDbgCtrl_rx
//-----------------------------------------------------------------------------
   output                                 rxpolarity_0,
   output                                 rxlpmen,
   output                                 rxdfelpmreset,
   output                                 rxdfetap2hold,
   output                                 rxdfetap3hold,
   output                                 rxdfetap4hold,
   output                                 rxdfetap5hold,
   output                                 rxdfetap6hold,
   output                                 rxdfetap7hold,
   output                                 rxdfetap8hold,
   output                                 rxdfetap9hold,
   output                                 rxdfetap10hold,
   output                                 rxdfetap11hold,
   output                                 rxdfetap12hold,
   output                                 rxdfetap13hold,
   output                                 rxdfetap14hold,
   output                                 rxdfetap15hold,
   output                                 rxoshold,
   output                                 rxdfeagchold,
   output                                 rxdfelfhold,
   output                                 rxdfeuthold,
   output                                 rxdfevphold,

   output                                 rxpolarity_1,

   output                                 rxpolarity_2,

   output                                 rxpolarity_3,

   output                                 rxpolarity_4,

   output                                 rxpolarity_5,

   output                                 rxpolarity_6,

   output                                 rxpolarity_7,

 
//-----------------------------------------------------------------------------
// DRP mailbox for prefix cmn_ connected to bank drpCommonMailbox
//-----------------------------------------------------------------------------
// DRP interface 0
   output      [CMN_C_S_DRP_ADDR_WIDTH-1:0] cmn_drp0_addr,
   output      [15:0]                     cmn_drp0_di,
   output                                 cmn_drp0_we,
   output                                 cmn_drp0_en,
   output                                 cmn_drp0_rst,

   input       [15:0]                     cmn_drp0_do,
   input                                  cmn_drp0_rdy,
  
// DRP interface 1
   output      [CMN_C_S_DRP_ADDR_WIDTH-1:0] cmn_drp1_addr,
   output      [15:0]                     cmn_drp1_di,
   output                                 cmn_drp1_we,
   output                                 cmn_drp1_en,
   output                                 cmn_drp1_rst,

   input       [15:0]                     cmn_drp1_do,
   input                                  cmn_drp1_rdy,
  
//-----------------------------------------------------------------------------
// DRP mailbox for prefix gt_ connected to bank drpChannelMailbox
//-----------------------------------------------------------------------------
// DRP interface 0
   output      [GT_C_S_DRP_ADDR_WIDTH-1:0] gt_drp0_addr,
   output      [15:0]                     gt_drp0_di,
   output                                 gt_drp0_we,
   output                                 gt_drp0_en,
   output                                 gt_drp0_rst,

   input       [15:0]                     gt_drp0_do,
   input                                  gt_drp0_rdy,
  
// DRP interface 1
   output      [GT_C_S_DRP_ADDR_WIDTH-1:0] gt_drp1_addr,
   output      [15:0]                     gt_drp1_di,
   output                                 gt_drp1_we,
   output                                 gt_drp1_en,
   output                                 gt_drp1_rst,

   input       [15:0]                     gt_drp1_do,
   input                                  gt_drp1_rdy,
  
// DRP interface 2
   output      [GT_C_S_DRP_ADDR_WIDTH-1:0] gt_drp2_addr,
   output      [15:0]                     gt_drp2_di,
   output                                 gt_drp2_we,
   output                                 gt_drp2_en,
   output                                 gt_drp2_rst,

   input       [15:0]                     gt_drp2_do,
   input                                  gt_drp2_rdy,
  
// DRP interface 3
   output      [GT_C_S_DRP_ADDR_WIDTH-1:0] gt_drp3_addr,
   output      [15:0]                     gt_drp3_di,
   output                                 gt_drp3_we,
   output                                 gt_drp3_en,
   output                                 gt_drp3_rst,

   input       [15:0]                     gt_drp3_do,
   input                                  gt_drp3_rdy,
  
// DRP interface 4
   output      [GT_C_S_DRP_ADDR_WIDTH-1:0] gt_drp4_addr,
   output      [15:0]                     gt_drp4_di,
   output                                 gt_drp4_we,
   output                                 gt_drp4_en,
   output                                 gt_drp4_rst,

   input       [15:0]                     gt_drp4_do,
   input                                  gt_drp4_rdy,
  
// DRP interface 5
   output      [GT_C_S_DRP_ADDR_WIDTH-1:0] gt_drp5_addr,
   output      [15:0]                     gt_drp5_di,
   output                                 gt_drp5_we,
   output                                 gt_drp5_en,
   output                                 gt_drp5_rst,

   input       [15:0]                     gt_drp5_do,
   input                                  gt_drp5_rdy,
  
// DRP interface 6
   output      [GT_C_S_DRP_ADDR_WIDTH-1:0] gt_drp6_addr,
   output      [15:0]                     gt_drp6_di,
   output                                 gt_drp6_we,
   output                                 gt_drp6_en,
   output                                 gt_drp6_rst,

   input       [15:0]                     gt_drp6_do,
   input                                  gt_drp6_rdy,
  
// DRP interface 7
   output      [GT_C_S_DRP_ADDR_WIDTH-1:0] gt_drp7_addr,
   output      [15:0]                     gt_drp7_di,
   output                                 gt_drp7_we,
   output                                 gt_drp7_en,
   output                                 gt_drp7_rst,

   input       [15:0]                     gt_drp7_do,
   input                                  gt_drp7_rdy,
  
//-----------------------------------------------------------------------------
// Other clock domain IO
//-----------------------------------------------------------------------------
   input                                  s_drp_clk,
   input                                  s_drp_reset,
 
// Secondary clock domain tx_core_clk
   input                                  tx_core_clk,
   input                                  tx_core_reset,

// Secondary clock domain rx_core_clk
   input                                  rx_core_clk,
   input                                  rx_core_reset,

//-----------------------------------------------------------------------------
// Time out connections in
//-----------------------------------------------------------------------------
   input                                  timeout_enable_in,
   input       [C_S_TIMEOUT_WIDTH-1:0]    timeout_value_in,

//-----------------------------------------------------------------------------
// AXI Lite IO
//-----------------------------------------------------------------------------
   input                                  s_axi_aclk,
   input                                  s_axi_aresetn,
   input       [C_S_AXI_ADDR_WIDTH-1:0]   s_axi_awaddr,
   input                                  s_axi_awvalid,
   output                                 s_axi_awready,
   input       [31:0]                     s_axi_wdata,
   input                                  s_axi_wvalid,
   output                                 s_axi_wready,
   output      [1:0]                      s_axi_bresp,
   output                                 s_axi_bvalid,
   input                                  s_axi_bready,
   input       [C_S_AXI_ADDR_WIDTH-1:0]   s_axi_araddr,
   input                                  s_axi_arvalid,
   output                                 s_axi_arready,
   output      [31:0]                     s_axi_rdata,
   output      [1:0]                      s_axi_rresp,
   output                                 s_axi_rvalid,
   input                                  s_axi_rready

);

//-----------------------------------------------------------------------------
// internal register strobe declarations
//-----------------------------------------------------------------------------
   wire        [BANK_DECODE_HIGH_LOW-1:2] slv_addr;
   wire        [31:0]                     slv_wdata;   
   wire                                   slv_reg_rden;

   wire        [31:0]                     phy1_slv_rdata;
   wire                                   phy1_slv_wren;
   wire                                   phy1_slv_rden;
   wire                                   phy1_slv_wr_done;
   wire                                   phy1_slv_rd_done;
  
   wire        [31:0]                     cmn_slv_rdata;
   wire                                   cmn_slv_wren;
   wire                                   cmn_slv_rden;
   wire                                   cmn_slv_wr_done;
   wire                                   cmn_slv_rd_done;
  
   wire        [31:0]                     gt_slv_rdata;
   wire                                   gt_slv_wren;
   wire                                   gt_slv_rden;
   wire                                   gt_slv_wr_done;
   wire                                   gt_slv_rd_done;
  
   wire        [31:0]                     cmn_dbg_slv_rdata;
   wire                                   cmn_dbg_slv_wren;
   wire                                   cmn_dbg_slv_rden;
   wire                                   cmn_dbg_slv_wr_done;
   wire                                   cmn_dbg_slv_rd_done;
  
   wire        [31:0]                     chan_async_slv_rdata;
   wire                                   chan_async_slv_wren;
   wire                                   chan_async_slv_rden;
   wire                                   chan_async_slv_wr_done;
   wire                                   chan_async_slv_rd_done;
  
   wire        [31:0]                     chan_tx_slv_rdata;
   wire                                   chan_tx_slv_wren;
   wire                                   chan_tx_slv_rden;
   wire                                   chan_tx_slv_wr_done;
   wire                                   chan_tx_slv_rd_done;
  
   wire        [31:0]                     chan_rx_slv_rdata;
   wire                                   chan_rx_slv_wren;
   wire                                   chan_rx_slv_rden;
   wire                                   chan_rx_slv_wr_done;
   wire                                   chan_rx_slv_rd_done;
  
//-----------------------------------------------------------------------------
// Internal signal wire declarations
//-----------------------------------------------------------------------------
   wire        [7:0]                      cmm_interface_sel;
   wire        [7:0]                      gt_interface_sel;

//-----------------------------------------------------------------------------
// Main AXI interface
//-----------------------------------------------------------------------------
jesd204_phy_0_phyCoreCtrlInterface_axi #(
.C_S_AXI_ADDR_WIDTH           (C_S_AXI_ADDR_WIDTH),
.BANK_DECODE_HIGH_BIT         (BANK_DECODE_HIGH_BIT),
.BANK_DECODE_HIGH_LOW         (BANK_DECODE_HIGH_LOW),
.C_S_TIMEOUT_WIDTH            (C_S_TIMEOUT_WIDTH)
) axi_register_if_i (

  .slv_reg_rden                        (slv_reg_rden                  ),
  .slv_addr                            (slv_addr                      ),
  .slv_wdata                           (slv_wdata                     ),

  .phy1_slv_rdata                      (phy1_slv_rdata                ),
  .phy1_slv_wren                       (phy1_slv_wren                 ),
  .phy1_slv_rden                       (phy1_slv_rden                 ),
  .phy1_slv_rd_done                    (phy1_slv_rd_done              ),
  .phy1_slv_wr_done                    (phy1_slv_wr_done              ),

  .cmn_slv_rdata                       (cmn_slv_rdata                 ),
  .cmn_slv_wren                        (cmn_slv_wren                  ),
  .cmn_slv_rden                        (cmn_slv_rden                  ),
  .cmn_slv_rd_done                     (cmn_slv_rd_done               ),
  .cmn_slv_wr_done                     (cmn_slv_wr_done               ),

  .gt_slv_rdata                        (gt_slv_rdata                  ),
  .gt_slv_wren                         (gt_slv_wren                   ),
  .gt_slv_rden                         (gt_slv_rden                   ),
  .gt_slv_rd_done                      (gt_slv_rd_done                ),
  .gt_slv_wr_done                      (gt_slv_wr_done                ),

  .cmn_dbg_slv_rdata                   (cmn_dbg_slv_rdata             ),
  .cmn_dbg_slv_wren                    (cmn_dbg_slv_wren              ),
  .cmn_dbg_slv_rden                    (cmn_dbg_slv_rden              ),
  .cmn_dbg_slv_rd_done                 (cmn_dbg_slv_rd_done           ),
  .cmn_dbg_slv_wr_done                 (cmn_dbg_slv_wr_done           ),

  .chan_async_slv_rdata                (chan_async_slv_rdata          ),
  .chan_async_slv_wren                 (chan_async_slv_wren           ),
  .chan_async_slv_rden                 (chan_async_slv_rden           ),
  .chan_async_slv_rd_done              (chan_async_slv_rd_done        ),
  .chan_async_slv_wr_done              (chan_async_slv_wr_done        ),

  .chan_tx_slv_rdata                   (chan_tx_slv_rdata             ),
  .chan_tx_slv_wren                    (chan_tx_slv_wren              ),
  .chan_tx_slv_rden                    (chan_tx_slv_rden              ),
  .chan_tx_slv_rd_done                 (chan_tx_slv_rd_done           ),
  .chan_tx_slv_wr_done                 (chan_tx_slv_wr_done           ),

  .chan_rx_slv_rdata                   (chan_rx_slv_rdata             ),
  .chan_rx_slv_wren                    (chan_rx_slv_wren              ),
  .chan_rx_slv_rden                    (chan_rx_slv_rden              ),
  .chan_rx_slv_rd_done                 (chan_rx_slv_rd_done           ),
  .chan_rx_slv_wr_done                 (chan_rx_slv_wr_done           ),

  .timeout_enable_in                   (timeout_enable_in             ),
  .timeout_value_in                    (timeout_value_in              ),
 
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
  .s_axi_rready                        (s_axi_rready                  )

);

//-----------------------------------------------------------------------------
// jesd204_phy_0_phyAxiConfig register bank
//-----------------------------------------------------------------------------
jesd204_phy_0_phyAxiConfig #(
   .C_S_AXI_ADDR_WIDTH           (BANK_DECODE_HIGH_LOW)
) jesd204_phy_0_phyAxiConfig_i (

  .timeout_enable                      (timeout_enable                ),
  .timeout_value                       (timeout_value                 ),
  .tx_reset_not_done                   (tx_reset_not_done             ),
  .rx_reset_not_done                   (rx_reset_not_done             ),
  .cpll_not_locked                     (cpll_not_locked               ),
  .qpll0_not_locked                    (qpll0_not_locked              ),
  .qpll1_not_locked                    (qpll1_not_locked              ),

  .cmm_interface_sel                   (cmm_interface_sel             ),
  .gt_interface_sel                    (gt_interface_sel              ),

  .slv_addr                            (slv_addr                      ),
  .slv_wdata                           (slv_wdata                     ),
  .slv_rden                            (phy1_slv_rden                 ),
  .slv_wren                            (phy1_slv_wren                 ),

  .slv_wr_done                         (phy1_slv_wr_done              ),
  .slv_rd_done                         (phy1_slv_rd_done              ),
  .slv_rdata                           (phy1_slv_rdata                ),

  .s_axi_aclk                          (s_axi_aclk                    ),
  .s_axi_aresetn                       (s_axi_aresetn                 )

);
//-----------------------------------------------------------------------------
// jesd204_phy_0_drpCommonMailbox DRP mailbox bank ExtSel=1
//-----------------------------------------------------------------------------
jesd204_phy_0_drpCommonMailbox #(
.C_S_AXI_ADDR_WIDTH    (BANK_DECODE_HIGH_LOW),
.C_S_DRP_ADDR_WIDTH    (CMN_C_S_DRP_ADDR_WIDTH),
.C_S_DRP_TIMEOUT_WIDTH (C_S_TIMEOUT_WIDTH)
) jesd204_phy_0_drpCommonMailbox_i (

  .drp0_addr                           (cmn_drp0_addr                 ),
  .drp0_di                             (cmn_drp0_di                   ),
  .drp0_we                             (cmn_drp0_we                   ),
  .drp0_en                             (cmn_drp0_en                   ),
  .drp0_rst                            (cmn_drp0_rst                  ),

  .drp0_do                             (cmn_drp0_do                   ),
  .drp0_rdy                            (cmn_drp0_rdy                  ),

  .drp1_addr                           (cmn_drp1_addr                 ),
  .drp1_di                             (cmn_drp1_di                   ),
  .drp1_we                             (cmn_drp1_we                   ),
  .drp1_en                             (cmn_drp1_en                   ),
  .drp1_rst                            (cmn_drp1_rst                  ),

  .drp1_do                             (cmn_drp1_do                   ),
  .drp1_rdy                            (cmn_drp1_rdy                  ),

  .cmm_interface_sel                   (cmm_interface_sel             ),

  .slv_wdata                           (slv_wdata                     ),
  .slv_addr                            (slv_addr                      ),
  .slv_rden                            (cmn_slv_rden                  ),
  .slv_wren                            (cmn_slv_wren                  ),

  .slv_wr_done                         (cmn_slv_wr_done               ),
  .slv_rd_done                         (cmn_slv_rd_done               ),
  .slv_rdata                           (cmn_slv_rdata                 ),

  .s_drp_clk                           (s_drp_clk                     ),
  .s_drp_reset                         (s_drp_reset                   ),
                                                                                
  .s_axi_aclk                          (s_axi_aclk                    ),
  .s_axi_aresetn                       (s_axi_aresetn                 )

);

//-----------------------------------------------------------------------------
// jesd204_phy_0_drpChannelMailbox DRP mailbox bank ExtSel=1
//-----------------------------------------------------------------------------
jesd204_phy_0_drpChannelMailbox #(
.C_S_AXI_ADDR_WIDTH    (BANK_DECODE_HIGH_LOW),
.C_S_DRP_ADDR_WIDTH    (GT_C_S_DRP_ADDR_WIDTH),
.C_S_DRP_TIMEOUT_WIDTH (C_S_TIMEOUT_WIDTH)
) jesd204_phy_0_drpChannelMailbox_i (

  .drp0_addr                           (gt_drp0_addr                  ),
  .drp0_di                             (gt_drp0_di                    ),
  .drp0_we                             (gt_drp0_we                    ),
  .drp0_en                             (gt_drp0_en                    ),
  .drp0_rst                            (gt_drp0_rst                   ),

  .drp0_do                             (gt_drp0_do                    ),
  .drp0_rdy                            (gt_drp0_rdy                   ),

  .drp1_addr                           (gt_drp1_addr                  ),
  .drp1_di                             (gt_drp1_di                    ),
  .drp1_we                             (gt_drp1_we                    ),
  .drp1_en                             (gt_drp1_en                    ),
  .drp1_rst                            (gt_drp1_rst                   ),

  .drp1_do                             (gt_drp1_do                    ),
  .drp1_rdy                            (gt_drp1_rdy                   ),

  .drp2_addr                           (gt_drp2_addr                  ),
  .drp2_di                             (gt_drp2_di                    ),
  .drp2_we                             (gt_drp2_we                    ),
  .drp2_en                             (gt_drp2_en                    ),
  .drp2_rst                            (gt_drp2_rst                   ),

  .drp2_do                             (gt_drp2_do                    ),
  .drp2_rdy                            (gt_drp2_rdy                   ),

  .drp3_addr                           (gt_drp3_addr                  ),
  .drp3_di                             (gt_drp3_di                    ),
  .drp3_we                             (gt_drp3_we                    ),
  .drp3_en                             (gt_drp3_en                    ),
  .drp3_rst                            (gt_drp3_rst                   ),

  .drp3_do                             (gt_drp3_do                    ),
  .drp3_rdy                            (gt_drp3_rdy                   ),

  .drp4_addr                           (gt_drp4_addr                  ),
  .drp4_di                             (gt_drp4_di                    ),
  .drp4_we                             (gt_drp4_we                    ),
  .drp4_en                             (gt_drp4_en                    ),
  .drp4_rst                            (gt_drp4_rst                   ),

  .drp4_do                             (gt_drp4_do                    ),
  .drp4_rdy                            (gt_drp4_rdy                   ),

  .drp5_addr                           (gt_drp5_addr                  ),
  .drp5_di                             (gt_drp5_di                    ),
  .drp5_we                             (gt_drp5_we                    ),
  .drp5_en                             (gt_drp5_en                    ),
  .drp5_rst                            (gt_drp5_rst                   ),

  .drp5_do                             (gt_drp5_do                    ),
  .drp5_rdy                            (gt_drp5_rdy                   ),

  .drp6_addr                           (gt_drp6_addr                  ),
  .drp6_di                             (gt_drp6_di                    ),
  .drp6_we                             (gt_drp6_we                    ),
  .drp6_en                             (gt_drp6_en                    ),
  .drp6_rst                            (gt_drp6_rst                   ),

  .drp6_do                             (gt_drp6_do                    ),
  .drp6_rdy                            (gt_drp6_rdy                   ),

  .drp7_addr                           (gt_drp7_addr                  ),
  .drp7_di                             (gt_drp7_di                    ),
  .drp7_we                             (gt_drp7_we                    ),
  .drp7_en                             (gt_drp7_en                    ),
  .drp7_rst                            (gt_drp7_rst                   ),

  .drp7_do                             (gt_drp7_do                    ),
  .drp7_rdy                            (gt_drp7_rdy                   ),

  .gt_interface_sel                    (gt_interface_sel              ),

  .slv_wdata                           (slv_wdata                     ),
  .slv_addr                            (slv_addr                      ),
  .slv_rden                            (gt_slv_rden                   ),
  .slv_wren                            (gt_slv_wren                   ),

  .slv_wr_done                         (gt_slv_wr_done                ),
  .slv_rd_done                         (gt_slv_rd_done                ),
  .slv_rdata                           (gt_slv_rdata                  ),

  .s_drp_clk                           (s_drp_clk                     ),
  .s_drp_reset                         (s_drp_reset                   ),
                                                                                
  .s_axi_aclk                          (s_axi_aclk                    ),
  .s_axi_aresetn                       (s_axi_aresetn                 )

);

//-----------------------------------------------------------------------------
// jesd204_phy_0_commonDbgCtrl register bank, with replicated IO and internal select
//-----------------------------------------------------------------------------
jesd204_phy_0_commonDbgCtrl #(
   .C_S_AXI_ADDR_WIDTH           (BANK_DECODE_HIGH_LOW)
) jesd204_phy_0_commonDbgCtrl_i (

  .cmm_interface_sel                   (cmm_interface_sel             ),

  .qpll0_pd_0                          (qpll0_pd_0                    ),
  .qpll1_pd_0                          (qpll1_pd_0                    ),

  .qpll0_pd_1                          (qpll0_pd_1                    ),
  .qpll1_pd_1                          (qpll1_pd_1                    ),

  .slv_addr                            (slv_addr                      ),
  .slv_wdata                           (slv_wdata                     ),
  .slv_rden                            (cmn_dbg_slv_rden              ),
  .slv_wren                            (cmn_dbg_slv_wren              ),

  .slv_wr_done                         (cmn_dbg_slv_wr_done           ),
  .slv_rd_done                         (cmn_dbg_slv_rd_done           ),
  .slv_rdata                           (cmn_dbg_slv_rdata             ),

  .s_axi_aclk                          (s_axi_aclk                    ),
  .s_axi_aresetn                       (s_axi_aresetn                 )

);
//-----------------------------------------------------------------------------
// jesd204_phy_0_transDbgCtrl_async register bank, with replicated IO and internal select
//-----------------------------------------------------------------------------
jesd204_phy_0_transDbgCtrl_async #(
   .C_S_AXI_ADDR_WIDTH           (BANK_DECODE_HIGH_LOW)
) jesd204_phy_0_transDbgCtrl_async_i (

  .gt_interface_sel                    (gt_interface_sel              ),

  .rx_pd_0                             (rx_pd_0                       ),
  .cpll_pd_0                           (cpll_pd_0                     ),
  .txpllclksel                         (txpllclksel                   ),
  .rxpllclksel                         (rxpllclksel                   ),
  .txpostcursor_0                      (txpostcursor_0                ),
  .txprecursor_0                       (txprecursor_0                 ),
  .loopback_0                          (loopback_0                    ),
  .tx_sys_reset_axi                    (tx_sys_reset_axi              ),
  .rx_sys_reset_axi                    (rx_sys_reset_axi              ),
  .cpll_cal_per                        (cpll_cal_per                  ),
  .cpll_cal_tol                        (cpll_cal_tol                  ),

  .rx_pd_1                             (rx_pd_1                       ),
  .cpll_pd_1                           (cpll_pd_1                     ),
  .txpostcursor_1                      (txpostcursor_1                ),
  .txprecursor_1                       (txprecursor_1                 ),
  .loopback_1                          (loopback_1                    ),

  .rx_pd_2                             (rx_pd_2                       ),
  .cpll_pd_2                           (cpll_pd_2                     ),
  .txpostcursor_2                      (txpostcursor_2                ),
  .txprecursor_2                       (txprecursor_2                 ),
  .loopback_2                          (loopback_2                    ),

  .rx_pd_3                             (rx_pd_3                       ),
  .cpll_pd_3                           (cpll_pd_3                     ),
  .txpostcursor_3                      (txpostcursor_3                ),
  .txprecursor_3                       (txprecursor_3                 ),
  .loopback_3                          (loopback_3                    ),

  .rx_pd_4                             (rx_pd_4                       ),
  .cpll_pd_4                           (cpll_pd_4                     ),
  .txpostcursor_4                      (txpostcursor_4                ),
  .txprecursor_4                       (txprecursor_4                 ),
  .loopback_4                          (loopback_4                    ),

  .rx_pd_5                             (rx_pd_5                       ),
  .cpll_pd_5                           (cpll_pd_5                     ),
  .txpostcursor_5                      (txpostcursor_5                ),
  .txprecursor_5                       (txprecursor_5                 ),
  .loopback_5                          (loopback_5                    ),

  .rx_pd_6                             (rx_pd_6                       ),
  .cpll_pd_6                           (cpll_pd_6                     ),
  .txpostcursor_6                      (txpostcursor_6                ),
  .txprecursor_6                       (txprecursor_6                 ),
  .loopback_6                          (loopback_6                    ),

  .rx_pd_7                             (rx_pd_7                       ),
  .cpll_pd_7                           (cpll_pd_7                     ),
  .txpostcursor_7                      (txpostcursor_7                ),
  .txprecursor_7                       (txprecursor_7                 ),
  .loopback_7                          (loopback_7                    ),

  .slv_addr                            (slv_addr                      ),
  .slv_wdata                           (slv_wdata                     ),
  .slv_rden                            (chan_async_slv_rden           ),
  .slv_wren                            (chan_async_slv_wren           ),

  .slv_wr_done                         (chan_async_slv_wr_done        ),
  .slv_rd_done                         (chan_async_slv_rd_done        ),
  .slv_rdata                           (chan_async_slv_rdata          ),

  .s_axi_aclk                          (s_axi_aclk                    ),
  .s_axi_aresetn                       (s_axi_aresetn                 )

);
//-----------------------------------------------------------------------------
// jesd204_phy_0_transDbgCtrl_tx register bank, with replicated IO and internal select
//-----------------------------------------------------------------------------
jesd204_phy_0_transDbgCtrl_tx #(
   .C_S_AXI_ADDR_WIDTH           (BANK_DECODE_HIGH_LOW)
) jesd204_phy_0_transDbgCtrl_tx_i (

  .gt_interface_sel                    (gt_interface_sel              ),

  .tx_pd_0                             (tx_pd_0                       ),
  .txdiffctrl_0                        (txdiffctrl_0                  ),
  .txinihibit_0                        (txinihibit_0                  ),
  .txpolarity_0                        (txpolarity_0                  ),

  .tx_pd_1                             (tx_pd_1                       ),
  .txdiffctrl_1                        (txdiffctrl_1                  ),
  .txinihibit_1                        (txinihibit_1                  ),
  .txpolarity_1                        (txpolarity_1                  ),

  .tx_pd_2                             (tx_pd_2                       ),
  .txdiffctrl_2                        (txdiffctrl_2                  ),
  .txinihibit_2                        (txinihibit_2                  ),
  .txpolarity_2                        (txpolarity_2                  ),

  .tx_pd_3                             (tx_pd_3                       ),
  .txdiffctrl_3                        (txdiffctrl_3                  ),
  .txinihibit_3                        (txinihibit_3                  ),
  .txpolarity_3                        (txpolarity_3                  ),

  .tx_pd_4                             (tx_pd_4                       ),
  .txdiffctrl_4                        (txdiffctrl_4                  ),
  .txinihibit_4                        (txinihibit_4                  ),
  .txpolarity_4                        (txpolarity_4                  ),

  .tx_pd_5                             (tx_pd_5                       ),
  .txdiffctrl_5                        (txdiffctrl_5                  ),
  .txinihibit_5                        (txinihibit_5                  ),
  .txpolarity_5                        (txpolarity_5                  ),

  .tx_pd_6                             (tx_pd_6                       ),
  .txdiffctrl_6                        (txdiffctrl_6                  ),
  .txinihibit_6                        (txinihibit_6                  ),
  .txpolarity_6                        (txpolarity_6                  ),

  .tx_pd_7                             (tx_pd_7                       ),
  .txdiffctrl_7                        (txdiffctrl_7                  ),
  .txinihibit_7                        (txinihibit_7                  ),
  .txpolarity_7                        (txpolarity_7                  ),

  .slv_addr                            (slv_addr                      ),
  .slv_wdata                           (slv_wdata                     ),
  .slv_rden                            (chan_tx_slv_rden              ),
  .slv_wren                            (chan_tx_slv_wren              ),

  .slv_wr_done                         (chan_tx_slv_wr_done           ),
  .slv_rd_done                         (chan_tx_slv_rd_done           ),
  .slv_rdata                           (chan_tx_slv_rdata             ),

  .clk2_clk                            (tx_core_clk                   ),
  .clk2_reset                          (tx_core_reset                 ),

  .s_axi_aclk                          (s_axi_aclk                    ),
  .s_axi_aresetn                       (s_axi_aresetn                 )

);
//-----------------------------------------------------------------------------
// jesd204_phy_0_transDbgCtrl_rx register bank, with replicated IO and internal select
//-----------------------------------------------------------------------------
jesd204_phy_0_transDbgCtrl_rx #(
   .C_S_AXI_ADDR_WIDTH           (BANK_DECODE_HIGH_LOW)
) jesd204_phy_0_transDbgCtrl_rx_i (

  .gt_interface_sel                    (gt_interface_sel              ),

  .rxpolarity_0                        (rxpolarity_0                  ),
  .rxlpmen                             (rxlpmen                       ),
  .rxdfelpmreset                       (rxdfelpmreset                 ),
  .rxdfetap2hold                       (rxdfetap2hold                 ),
  .rxdfetap3hold                       (rxdfetap3hold                 ),
  .rxdfetap4hold                       (rxdfetap4hold                 ),
  .rxdfetap5hold                       (rxdfetap5hold                 ),
  .rxdfetap6hold                       (rxdfetap6hold                 ),
  .rxdfetap7hold                       (rxdfetap7hold                 ),
  .rxdfetap8hold                       (rxdfetap8hold                 ),
  .rxdfetap9hold                       (rxdfetap9hold                 ),
  .rxdfetap10hold                      (rxdfetap10hold                ),
  .rxdfetap11hold                      (rxdfetap11hold                ),
  .rxdfetap12hold                      (rxdfetap12hold                ),
  .rxdfetap13hold                      (rxdfetap13hold                ),
  .rxdfetap14hold                      (rxdfetap14hold                ),
  .rxdfetap15hold                      (rxdfetap15hold                ),
  .rxoshold                            (rxoshold                      ),
  .rxdfeagchold                        (rxdfeagchold                  ),
  .rxdfelfhold                         (rxdfelfhold                   ),
  .rxdfeuthold                         (rxdfeuthold                   ),
  .rxdfevphold                         (rxdfevphold                   ),

  .rxpolarity_1                        (rxpolarity_1                  ),

  .rxpolarity_2                        (rxpolarity_2                  ),

  .rxpolarity_3                        (rxpolarity_3                  ),

  .rxpolarity_4                        (rxpolarity_4                  ),

  .rxpolarity_5                        (rxpolarity_5                  ),

  .rxpolarity_6                        (rxpolarity_6                  ),

  .rxpolarity_7                        (rxpolarity_7                  ),

  .slv_addr                            (slv_addr                      ),
  .slv_wdata                           (slv_wdata                     ),
  .slv_rden                            (chan_rx_slv_rden              ),
  .slv_wren                            (chan_rx_slv_wren              ),

  .slv_wr_done                         (chan_rx_slv_wr_done           ),
  .slv_rd_done                         (chan_rx_slv_rd_done           ),
  .slv_rdata                           (chan_rx_slv_rdata             ),

  .clk2_clk                            (rx_core_clk                   ),
  .clk2_reset                          (rx_core_reset                 ),

  .s_axi_aclk                          (s_axi_aclk                    ),
  .s_axi_aresetn                       (s_axi_aresetn                 )

);

endmodule

