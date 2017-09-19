//----------------------------------------------------------------------------
// Title : Example Design Top Level
// Project : JESD204_phy
//----------------------------------------------------------------------------
// File : jesd204_phy_0_example_design.v
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
module jesd204_phy_0_example_design #(
  parameter             pLanes = 2,
  parameter             pTxLaneByteWidth = 4,
  parameter             pRxLaneByteWidth = 4
  ) (
  //-----------------------------------------------------------------------------
  // AXI Lite IO
  //-----------------------------------------------------------------------------
  input                 s_axi_aclk,
  input                 s_axi_aresetn,
  input   [11:0]        s_axi_awaddr,
  input                 s_axi_awvalid,
  output                s_axi_awready,
  input   [31:0]        s_axi_wdata,
  input                 s_axi_wvalid,
  output                s_axi_wready,
  output  [1:0]         s_axi_bresp,
  output                s_axi_bvalid,
  input                 s_axi_bready,
  input   [11:0]        s_axi_araddr,
  input                 s_axi_arvalid,
  output                s_axi_arready,
  output  [31:0]        s_axi_rdata,
  output  [1:0]         s_axi_rresp,
  output                s_axi_rvalid,
  input                 s_axi_rready,
  input                 core_clk_tx_p,           // TX Clock
  input                 core_clk_tx_n,           //

  input                 core_clk_rx_p,           // RX Clock
  input                 core_clk_rx_n,           //

  input                 drpclk_in,
  input                 refclk_common_p,
  input                 refclk_common_n,
  input                 reset,                   // resets RX/TX reset SM
  output                gpio_led_testPassed,     //
  output                gpio_led_error,          //
  output                gpio_led_txResetDone,    //
  output                gpio_led_rxResetDone,    //

  // These signals are used for measurements so on coreclk domains
  output                data_gen_all_one,
  output                data_check_all_one,
  output         [1:0]  sel_out,

  output  [pLanes-1:0]  txp,                     //
  output  [pLanes-1:0]  txn,                     //
  input   [pLanes-1:0]  rxp,                     //
  input   [pLanes-1:0]  rxn                      //
  );

// -----------------------------------------------------------------------------
// Local parameters
// -----------------------------------------------------------------------------
localparam pTxLaneWidth = pTxLaneByteWidth * 8;
localparam pRxLaneWidth = pRxLaneByteWidth * 8;

// -----------------------------------------------------------------------------
// Wire for the data interface between the JESD204 PHY and generation/test blocks
// -----------------------------------------------------------------------------
wire  [3:0] gt0_txcharisk;      // Lane 0
wire [31:0] gt0_txdata;         // 

wire  [3:0] gt0_rxdisperr;      // Lane 0
wire  [3:0] gt0_rxcharisk;      // 
wire  [3:0] gt0_rxnotintable;   // 
wire [31:0] gt0_rxdata;         // 

wire  [3:0] gt1_txcharisk;      // Lane 1
wire [31:0] gt1_txdata;         // 

wire  [3:0] gt1_rxdisperr;      // Lane 1
wire  [3:0] gt1_rxcharisk;      // 
wire  [3:0] gt1_rxnotintable;   // 
wire [31:0] gt1_rxdata;         // 

// -----------------------------------------------------------------------------
// Common block wiring
// -----------------------------------------------------------------------------
wire                  common0_qpll0_refclk_out;
wire                  common0_qpll0_lock_out;
wire                  common0_qpll0_clk_out;
reg         gpio_led_0pllLocked_qpll0;
wire                  common0_qpll1_refclk_out;
wire                  common0_qpll1_lock_out;
wire                  common0_qpll1_clk_out;
reg                   gpio_led_0pllLocked_qpll1;

// -----------------------------------------------------------------------------
// internal signals
// -----------------------------------------------------------------------------
wire                  drpclk;
wire                  tx_coreclk;
wire                  data_check_error;
wire                  tx_reset_done;
wire                  rx_coreclk;
wire                  rx_reset_done;
wire            [3:0] data_generate_enable;

wire                  rxencommaalign;   
wire                  data_check_enable;
wire                  rxreset;          
wire                  txreset;          
wire                  txoutclk;         
wire                  rxoutclk;         
wire                  gt_powergood;

// ----------------------------------------------------------------------------
// Create registered outputs of all our status LED signals.
// Resync these to drpclk to prevent ant timing violations in the design
// ----------------------------------------------------------------------------
  jesd204_phy_0_example_design_sync_block sync_txresetdone_led_drpclk_i  (
    .clk             (drpclk              ),
    .data_in         (tx_reset_done       ),
    .data_out        (gpio_led_txResetDone)
  );
  jesd204_phy_0_example_design_sync_block sync_rxresetdone_led_drpclk_i  (
    .clk             (drpclk              ),
    .data_in         (rx_reset_done       ),
    .data_out        (gpio_led_rxResetDone)
  );
  jesd204_phy_0_example_design_sync_block sync_error_led_drpclk_i  (
    .clk             (drpclk              ),
    .data_in         (data_check_error    ),
    .data_out        (gpio_led_error      )
  );
  jesd204_phy_0_example_design_sync_block sync_testpassed_led_drpclk_i  (
    .clk             (drpclk              ),
    .data_in         (~data_check_error   ),
    .data_out        (gpio_led_testPassed )
  );

// -----------------------------------------------------------------------------
// If used break out the QPLL lock signals
// -----------------------------------------------------------------------------
always @(posedge common0_qpll0_refclk_out)
    begin
    gpio_led_0pllLocked_qpll0 <= common0_qpll0_lock_out;
    end


// ----------------------------------------------------------------------------
// design test harness
// ----------------------------------------------------------------------------
jesd204_phy_0_example_design_sequencer sequencer_i (
  .core_clk_tx                         (tx_coreclk                    ),
  .core_clk_rx                         (rx_coreclk                    ),
  .reset                               (reset                         ),

  .rxencommaalign                      (rxencommaalign                ),
  .bypass_fake_ila                     (1'd1                          ),
  .data_check_enable                   (data_check_enable             ),
  .rx_reset_done                       (rx_reset_done                 ),
  .rxreset                             (rxreset                       ),

  .data_generate_enable                (data_generate_enable          ),
  .tx_reset_done                       (tx_reset_done                 ),
  .txreset                             (txreset                       )
  );
// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
jesd204_phy_0_example_design_clks_in clks_in_i (
  .core_clk_tx_p                       (core_clk_tx_p                 ),
  .core_clk_tx_n                       (core_clk_tx_n                 ),
  .tx_coreclk                          (tx_coreclk                    ),

  .core_clk_rx_p                       (core_clk_rx_p                 ),
  .core_clk_rx_n                       (core_clk_rx_n                 ),
  .rx_coreclk                          (rx_coreclk                    ),

  .drpclk_in                           (drpclk_in                     ),
  .refclk_common_p                     (refclk_common_p               ),
  .refclk_common_n                     (refclk_common_n               ),
  .refclk_common_out                   (qpll0_refclk                  ),
  .drpclk                              (drpclk                        )
  );
// ----------------------------------------------------------------------------
// JESD204 PHY instance
// ----------------------------------------------------------------------------
jesd204_phy_0 jesd204_phy_0_support_block_i(
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
  .drpclk                              (drpclk                        ),
  .tx_sys_reset                        (reset                         ),
  .rx_sys_reset                        (reset                         ),
  .tx_reset_gt                         (reset                         ),
  .rx_reset_gt                         (reset                         ),
  .rxp_in                              (rxp                           ),
  .rxn_in                              (rxn                           ),
  .txp_out                             (txp                           ),
  .txn_out                             (txn                           ),

  .tx_core_clk                         (tx_coreclk                    ),

  .rx_core_clk                         (rx_coreclk                    ),

  .gt_powergood                        (gt_powergood                  ),


  // PRBS mode
  .gt_prbssel                          (4'd0                          ),
  .rxencommaalign                      (rxencommaalign                ),

  .gt0_txdata                          (gt0_txdata                    ),
  .gt0_txcharisk                       (gt0_txcharisk                 ),

  .gt1_txdata                          (gt1_txdata                    ),
  .gt1_txcharisk                       (gt1_txcharisk                 ),

  .txoutclk                            (txoutclk                      ),
  .rxoutclk                            (rxoutclk                      ),

  .tx_reset_done                       (tx_reset_done                 ),

  .gt0_rxdata                          (gt0_rxdata                    ),
  .gt0_rxcharisk                       (gt0_rxcharisk                 ),
  .gt0_rxdisperr                       (gt0_rxdisperr                 ),
  .gt0_rxnotintable                    (gt0_rxnotintable              ),
  .gt1_rxdata                          (gt1_rxdata                    ),
  .gt1_rxcharisk                       (gt1_rxcharisk                 ),
  .gt1_rxdisperr                       (gt1_rxdisperr                 ),
  .gt1_rxnotintable                    (gt1_rxnotintable              ),
  .cpll_refclk                         (qpll0_refclk                  ),
  .qpll0_refclk                        (qpll0_refclk                  ),
  .qpll1_refclk                        (qpll0_refclk                  ),
  .common0_qpll0_lock_out              (common0_qpll0_lock_out        ),
  .common0_qpll0_refclk_out            (common0_qpll0_refclk_out      ),
  .common0_qpll0_clk_out               (common0_qpll0_clk_out         ),
  .common0_qpll1_lock_out              (common0_qpll1_lock_out        ),
  .common0_qpll1_refclk_out            (common0_qpll1_refclk_out      ),
  .common0_qpll1_clk_out               (common0_qpll1_clk_out         ),
  .rx_reset_done                       (rx_reset_done                 )
);

// ----------------------------------------------------------------------------
// Data generator
// ----------------------------------------------------------------------------
jesd204_phy_0_example_design_data_generator #( 
  .pLaneByteWidth(pTxLaneByteWidth) 
  ) data_generator_i (
  .reset                               (txreset                       ),
  .tx_coreclk                          (tx_coreclk                    ),
  .data_gen_all_one                    (data_gen_all_one              ),

  .gt0_txdata                          (gt0_txdata                    ),
  .gt0_txcharisk                       (gt0_txcharisk                 ),

  .gt1_txdata                          (gt1_txdata                    ),
  .gt1_txcharisk                       (gt1_txcharisk                 ),

  .data_generate_enable                (data_generate_enable          )
);
// ----------------------------------------------------------------------------
// Data self checker
// ----------------------------------------------------------------------------
jesd204_phy_0_example_design_data_checker #( 
  .pLaneByteWidth(pRxLaneByteWidth) 
  ) data_checker_i (
  .reset                               (rxreset                       ),
  .rx_coreclk                          (rx_coreclk                    ),
  .data_check_all_one                  (data_check_all_one            ),
  .sel_out                             (sel_out                       ),

  .gt0_rxdata                          (gt0_rxdata                    ),
  .gt0_rxcharisk                       (gt0_rxcharisk                 ),
  .gt0_rxdisperr                       (gt0_rxdisperr                 ),
  .gt0_rxnotintable                    (gt0_rxnotintable              ),

  .gt1_rxdata                          (gt1_rxdata                    ),
  .gt1_rxcharisk                       (gt1_rxcharisk                 ),
  .gt1_rxdisperr                       (gt1_rxdisperr                 ),
  .gt1_rxnotintable                    (gt1_rxnotintable              ),

  .data_check_enable                   (data_check_enable             ),
  .data_check_error                    (data_check_error              )
);
endmodule
