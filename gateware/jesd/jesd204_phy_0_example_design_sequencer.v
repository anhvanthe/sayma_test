//----------------------------------------------------------------------------
// Title : Example Design Top Level
// Project : JESD204_phy
//----------------------------------------------------------------------------
// File : jesd204_phy_0_example_design_sequencer.v
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
module jesd204_phy_0_example_design_sequencer #(
  parameter   pLanes = 2 
) (

  input             core_clk_tx,
  input             core_clk_rx,

  input             tx_reset_done,
  input             rx_reset_done,

  input             reset,
  input             bypass_fake_ila,

  output reg        rxreset,
  output reg        data_check_enable,
  output            rxencommaalign,

  output reg        txreset,
  output reg  [3:0] data_generate_enable

  );

// ----------------------------------------------------------------------------
// parameters
// ----------------------------------------------------------------------------

localparam pRESET_CNT_W        = 'd6;
localparam pSEQ_CNT_W          = 'd6;

localparam pSM_SEQ_IDLE        = 'd0;  // Idle state, control in reset state
localparam pSM_SEQ_STAGING     = 'd1;  // pre reset initialisation step
localparam pSM_SEQ_INI_RESET   = 'd2;  // startup reset
localparam pSM_SEQ_DONEWAIT    = 'd3;  // Wait for reset done
localparam pSM_SEQ_COMMASYNC   = 'd4;  // Send comma's
localparam pSM_SEQ_FAKEILA0    = 'd5;  // Send an ILA type sequence
localparam pSM_SEQ_FAKEILA1    = 'd6;  // Send an ILA type sequence
localparam pSM_SEQ_FAKEILA2    = 'd7;  // Send an ILA type sequence
localparam pSM_SEQ_FAKEILA3    = 'd8;  // Send an ILA type sequence
localparam pSM_SEQ_FREERUN     = 'd15; // run run run !

// ----------------------------------------------------------------------------
// state machine & reset variables
// ----------------------------------------------------------------------------
reg                    [3:0] sm_seq_tx = 0;
reg                    [3:0] sm_seq_rx = 0;
reg     [pRESET_CNT_W - 1:0] tx_resetCounter = 0;
reg     [pRESET_CNT_W - 1:0] rx_resetCounter = 0;

// ----------------------------------------------------------------------------
// reset resync registers, create an and'ed done signal for each domain
// ----------------------------------------------------------------------------
wire                         txResyncTxReset;
wire                         txResyncRxReset;
wire                         txClk_rx_tx_reset_done;

wire                         rxResyncTxReset;
wire                         rxResyncRxReset;
wire                         rxClk_rx_tx_reset_done;

// Fake ILA sequence counter, note this only contains the K symbols, not the
// link configuration data
reg         [pSEQ_CNT_W-1:0] tx_seq_count = 0;
wire                         tx_seq_count_at_max;
wire                         tx_seq_count_at_min;
wire                         tx_is_ila;

// ----------------------------------------------------------------------------
// TX CLOCK DOMAIN
// ----------------------------------------------------------------------------
// TX sequencer & control
// Mainly we snd comma's K28.5 sync symbols. We sent a fake ILS type sequence
// to allow the RX bench to align, then we go back to K28.5 symbols
// ----------------------------------------------------------------------------
always @(posedge core_clk_tx)
    begin
    if(reset)
       begin
       data_generate_enable <= 1'd0;
       txreset              <= 1'd0;
       tx_resetCounter      <= 0;
       end
    else
       begin

       // reset counter control code.
       if(sm_seq_tx == pSM_SEQ_STAGING)
          // Use staging state to load th decaying counter
          tx_resetCounter <= {pRESET_CNT_W{1'd1}}; // Set to max value
       else
          if(tx_resetCounter != 'd0)
             // decay to zero
             tx_resetCounter <= tx_resetCounter - 1'd1;
          else
             tx_resetCounter <= 'd0;

        txreset <= (tx_resetCounter != 'd0);

        if((sm_seq_tx == pSM_SEQ_FREERUN))
           data_generate_enable <= 'd2;
        else        
	   if((sm_seq_tx == pSM_SEQ_FREERUN) | (sm_seq_tx == pSM_SEQ_COMMASYNC))
              data_generate_enable <= {3'd0,txClk_rx_tx_reset_done};
           else
             if(tx_is_ila)
           	data_generate_enable <= {tx_seq_count_at_max, tx_seq_count_at_min,txClk_rx_tx_reset_done,1'd0};
             else
           	data_generate_enable <= 4'd0;
       end
    end

// Next state logic
always @(posedge core_clk_tx)
    begin
    if(reset)
       sm_seq_tx   <=pSM_SEQ_IDLE;
    else
       // State machine control
       case(sm_seq_tx)
       pSM_SEQ_IDLE      : sm_seq_tx <= pSM_SEQ_STAGING;
       pSM_SEQ_STAGING   : sm_seq_tx <= pSM_SEQ_INI_RESET;
       pSM_SEQ_INI_RESET : begin
                           if(tx_resetCounter == 'd0)
                              sm_seq_tx <= pSM_SEQ_DONEWAIT;
                           end
       pSM_SEQ_DONEWAIT : begin
                           if(txClk_rx_tx_reset_done == 1'd1)
                              sm_seq_tx <= pSM_SEQ_COMMASYNC;
                           end
       pSM_SEQ_COMMASYNC : begin
                           if(tx_seq_count_at_max)
                              if(bypass_fake_ila)
                                 sm_seq_tx <= pSM_SEQ_FREERUN;
                              else
                                 sm_seq_tx <= pSM_SEQ_FAKEILA0;
                           end
       pSM_SEQ_FAKEILA0 : begin
                           if(tx_seq_count_at_max)
                              sm_seq_tx <= pSM_SEQ_FAKEILA1;
                           end
       pSM_SEQ_FAKEILA1 : begin
                           if(tx_seq_count_at_max)
                              sm_seq_tx <= pSM_SEQ_FAKEILA2;
                           end
       pSM_SEQ_FAKEILA2 : begin
                           if(tx_seq_count_at_max)
                              sm_seq_tx <= pSM_SEQ_FAKEILA3;
                           end
       pSM_SEQ_FAKEILA3 : begin
                           if(tx_seq_count_at_max)
                              sm_seq_tx <= pSM_SEQ_FREERUN;
                           end
       pSM_SEQ_FREERUN   : sm_seq_tx <= pSM_SEQ_FREERUN;
       default           : sm_seq_tx <= sm_seq_tx;
       endcase
    end

// Counter to measure ILA & COMMA sequence lengths.
always @(posedge core_clk_tx)
    begin
    if(reset)
       begin
       tx_seq_count <= 0;
       end
    else
       begin

       // reset counter control code.
       if((sm_seq_tx == pSM_SEQ_COMMASYNC) | (tx_is_ila))
          // Count in these states
          tx_seq_count <= tx_seq_count + 'd1; // Set to max value
       else
          tx_seq_count <= 'd0;

       end
    end

// decode state & count control
assign tx_seq_count_at_max = tx_seq_count == {pSEQ_CNT_W{1'd1}};
assign tx_seq_count_at_min = tx_seq_count == {pSEQ_CNT_W{1'd0}};
assign tx_is_ila = (sm_seq_tx == pSM_SEQ_FAKEILA0) |
                   (sm_seq_tx == pSM_SEQ_FAKEILA1) |
                   (sm_seq_tx == pSM_SEQ_FAKEILA2) |
                   (sm_seq_tx == pSM_SEQ_FAKEILA3) ;

// ----------------------------------------------------------------------------
// RX CLOCK DOMAIN
// ----------------------------------------------------------------------------
// RX sequencer!
// ----------------------------------------------------------------------------
always @(posedge core_clk_rx)
    begin
    if(reset)
       begin
       data_check_enable <= 1'd0;
       rxreset           <= 1'd0;
       rx_resetCounter   <= 0;
       end
    else
       begin
       rxreset        <= (rx_resetCounter != 'd0);

       // reset counter control code.
       if(sm_seq_rx == pSM_SEQ_STAGING)
          // Use staging state to load th decaying counter
          rx_resetCounter <= {pRESET_CNT_W{1'd1}}; // Set to max value
       else
          if(rx_resetCounter != 'd0)
             // decay to zero
             rx_resetCounter <= rx_resetCounter - 1'd1;
          else
             rx_resetCounter <= 'd0;
        
        if(sm_seq_rx == pSM_SEQ_FREERUN)
           data_check_enable <= rxClk_rx_tx_reset_done;
        else
           data_check_enable <= 1'd0;

       end
    end

always @(posedge core_clk_rx)
    begin
    if(reset)
       sm_seq_rx   <=pSM_SEQ_IDLE;
    else
       // State machine control
       case(sm_seq_rx)
       pSM_SEQ_IDLE      : sm_seq_rx <= pSM_SEQ_STAGING;
       pSM_SEQ_STAGING   : sm_seq_rx <= pSM_SEQ_INI_RESET;
       pSM_SEQ_INI_RESET : begin
                           if(rx_resetCounter == 'd0)
                              sm_seq_rx <= pSM_SEQ_FREERUN;
                           end
       default           : sm_seq_rx <= sm_seq_rx;
       endcase
    end

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Sync the reset done signals across clock domains. Only when both cores
// are reset do we want the checkers to operate (at least in loopback mode)
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
  jesd204_phy_0_example_design_sync_block sync_txresetdone_txclk_i
  (
    .clk             (core_clk_tx    ),
    .data_in         (tx_reset_done  ),
    .data_out        (txResyncTxReset)
  );

  jesd204_phy_0_example_design_sync_block sync_rxresetdone_txclk_i
  (
    .clk             (core_clk_tx    ),
    .data_in         (rx_reset_done  ),
    .data_out        (txResyncRxReset)
  );

  assign txClk_rx_tx_reset_done = txResyncTxReset & txResyncRxReset;

  jesd204_phy_0_example_design_sync_block sync_rxresetdone_rxclk_i
  (
    .clk             (core_clk_rx    ),
    .data_in         (rx_reset_done  ),
    .data_out        (rxResyncRxReset)
  );

  jesd204_phy_0_example_design_sync_block sync_txresetdone_rxclk_i
  (
    .clk             (core_clk_rx    ),
    .data_in         (tx_reset_done  ),
    .data_out        (rxResyncTxReset)
  );

  assign rxClk_rx_tx_reset_done = rxResyncTxReset & rxResyncRxReset;

  assign rxencommaalign         = !rxClk_rx_tx_reset_done;

endmodule


