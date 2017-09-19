//-----------------------------------------------------------------------------
// Title      : transDbgCtrl_tx
// Project    : NA
//-----------------------------------------------------------------------------
// File       : transDbgCtrl_tx.v
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

module jesd204_phy_0_transDbgCtrl_tx #(
   parameter integer                   C_S_AXI_ADDR_WIDTH   = 11
   )
(
   input                                  s_axi_aclk,
   input                                  s_axi_aresetn,

   input                                  clk2_clk,
   input                                  clk2_reset,
   
   // IO for bank 0 
   input       [7:0]                      gt_interface_sel,
   output reg  [1:0]                      tx_pd_0 = 0,
   output reg  [3:0]                      txdiffctrl_0 = 12,
   output reg                             txinihibit_0 = 0,
   output reg                             txpolarity_0 = 0,

   // IO for bank 1 
   output reg  [1:0]                      tx_pd_1 = 0,
   output reg  [3:0]                      txdiffctrl_1 = 12,
   output reg                             txinihibit_1 = 0,
   output reg                             txpolarity_1 = 0,

 
   // basic register interface
   input                                  slv_rden,
   input                                  slv_wren,
   input       [31:0]                     slv_wdata,
   input       [C_S_AXI_ADDR_WIDTH-1:2]   slv_addr,
   
   output reg                             slv_rd_done,
   output reg                             slv_wr_done,
   output reg  [31:0]                     slv_rdata
 
);

  localparam C_INT_ADDRWIDTH = C_S_AXI_ADDR_WIDTH - 2;

  //----------------------------------------------------------------------------
  // Internal reg/wire declarations
  //----------------------------------------------------------------------------

  reg         slv_rden_r;            // Registered incoming read 
  wire        slv_rden_pls;          // Internally generated pulse
  reg         slv_access_valid_hold; // Flag indicates access in progress in axi domain
  wire        slv_wren_clear;        // Clears the held access valid signal
  reg         slv_access_is_read;    // High is access is a read
  reg  [31:0] slv_wdata_r_internal;  // Register the write data
  wire        slv_wren_clk2;         // Pulse on clk2 when rising edge of valid seen
  wire        slv_wren_done_pulse;   // Pulse on falling edge of clk1_ready
  wire        do_write_clk2;         // Use for debug

  //----------------------------------------------------------------------------
  // Create a held wr or rd signal. This is used to flag an access in progress
  // accross the clock domain.  This is reset when the signal has passed back
  // from the clk2 domain into the axi domain
  //----------------------------------------------------------------------------
  always @( posedge s_axi_aclk ) begin
    if ( ~s_axi_aresetn ) begin
      slv_access_valid_hold <= 'd0;
      slv_wdata_r_internal <= 'd0;
      end
    else begin
      if(slv_wren | slv_rden_pls) begin
        slv_access_valid_hold <= 'd1;
        // register the data locally for cross clock domain crossing
        slv_wdata_r_internal <= slv_wdata;
        end
      else begin
        if(slv_wren_clear) begin
          slv_access_valid_hold <= 'd0;
          end
        // Hold data
        slv_wdata_r_internal <= slv_wdata_r_internal;
        end
      end
    end

  //---------------------------------------------------------------------------
  // register the incoming read strobe, this will stay high, so we create a 
  // pulse to use. to generate the request across the clock domain.
  //---------------------------------------------------------------------------
  always @( posedge s_axi_aclk ) begin
    if ( ~s_axi_aresetn ) begin
      slv_rden_r <= 'd0; // Zero all data
      end
    else begin
      slv_rden_r <= slv_rden;
      end
    end
    
  assign slv_rden_pls = (!slv_rden_r) & slv_rden;

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  // Clk2 clock domain handshake
  // 
  // This logic pass's the Clk2 access request across the clock domain.
  // On the DRP side, a pulse is generated to initialte the Clk2 access. When
  // The RDY pulse is received, a ready signal is passed back across the clock
  // boundary to the AXI clock domain. This causes the valid request to be
  // removed, and when seen on the DRP domain, the ready is lowered.
  // When the ready falling edge is seen in the AXI domain the AXI transaction
  // is finally completed.
  // Although this logic is slow, it minimises the logic required.
  // It also ensures if the Clk2 rate is very slow compared to the AXI rate
  // transactions will fully complete before another can be requested, though
  // in the case the user should probally set wait_for_drp low and poll for
  // the Clk2 completion
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  jesd204_phy_0_phyCoreCtrlInterface_hshk_pls_gen clk2clk_handshake_pulse_gen_i(
   .clk1             (s_axi_aclk              ),
   .clk1_rst         (s_axi_aresetn           ),
   
   .clk1_valid       (slv_access_valid_hold   ), // Access in clk1 requested flag, pass to clk2
   .clk1_ready       (slv_wren_clear          ), // Access is complete in clk2, lower request in clk1
   .clk1_ready_pulse (slv_wren_done_pulse     ), // Pulsed on falling edge of clk1_ready, access complete in clk1 & clk2
   
   .clk2             (clk2_clk                ),
   .clk2_rst         (clk2_reset              ),
 
   .clk2_valid       ( ),
   .clk2_valid_pulse (slv_wren_clk2           ),
   .clk2_ready_pulse (slv_wren_clk2           )
    
  );
  
  // Gate the write strobe with the access type. In this case only the read enable
  // is high while we wait for the result
  assign do_write_clk2 = slv_wren_clk2 & (! slv_rden_r);

  //----------------------------------------------------------------------------
  // Register write logic
  //----------------------------------------------------------------------------
   always @( posedge clk2_clk )
   begin
      if (~clk2_reset) begin
        // set RW register defaults

        tx_pd_0                        <= 2'd0;
        txdiffctrl_0                   <= 4'd12;
        txinihibit_0                   <= 1'd0;
        txpolarity_0                   <= 1'd0;

        tx_pd_1                        <= 2'd0;
        txdiffctrl_1                   <= 4'd12;
        txinihibit_1                   <= 1'd0;
        txpolarity_1                   <= 1'd0;

 
      end 
      else begin    
         // on a write we write to the appropriate register
         // Not that slv_rden_r comes from the AXI clock domain, but will be stable
         // when the pulse arrives to register the data.
         if (slv_wren_clk2 & (~slv_rden_r)) begin
            case ({gt_interface_sel,slv_addr[6:2]})
            // WRITE assignments for signal block 0
            'h1     : begin // @ address = 0x04
                      tx_pd_0                        <= slv_wdata_r_internal[1:0];
                      end
            'h2     : begin // @ address = 0x08
                      txdiffctrl_0                   <= slv_wdata_r_internal[3:0];
                      end
            'h3     : begin // @ address = 0x0C
                      txinihibit_0                   <= slv_wdata_r_internal[0];
                      end
            'h4     : begin // @ address = 0x10
                      txpolarity_0                   <= slv_wdata_r_internal[0];
                      end

            // WRITE assignments for signal block 1
            'h21    : begin // @ address = 0x04
                      tx_pd_1                        <= slv_wdata_r_internal[1:0];
                      end
            'h22    : begin // @ address = 0x08
                      txdiffctrl_1                   <= slv_wdata_r_internal[3:0];
                      end
            'h23    : begin // @ address = 0x0C
                      txinihibit_1                   <= slv_wdata_r_internal[0];
                      end
            'h24    : begin // @ address = 0x10
                      txpolarity_1                   <= slv_wdata_r_internal[0];
                      end


            endcase
         end   
      end
   end
   
  //----------------------------------------------------------------------------
  // Register read logic
  // All signal come from clk 2, however by design these should be RW signals,
  // originating in this block. Therefore we know these signals will be steady
  // on a read.
  //---------------------------------------------------------------------------
  always @( posedge s_axi_aclk ) begin
    if ( ~s_axi_aresetn ) begin
      end
    else begin
      slv_rdata <= 'd0; // Zero all data bits, individual bits may be modified in the case below
      case ({gt_interface_sel,slv_addr[6:2]})
      // READ assignments for signal block 0
     'h0     : begin // @ address = 0x00
               slv_rdata[7:0]       <= 'd0; // gt_interface_sel is an external select
               end
     'h1     : begin // @ address = 0x04
               slv_rdata[1:0]       <= tx_pd_0;
               end
     'h2     : begin // @ address = 0x08
               slv_rdata[3:0]       <= txdiffctrl_0;
               end
     'h3     : begin // @ address = 0x0C
               slv_rdata[0]         <= txinihibit_0;
               end
     'h4     : begin // @ address = 0x10
               slv_rdata[0]         <= txpolarity_0;
               end

      // READ assignments for signal block 1
     'h20    : begin // @ address = 0x00
               slv_rdata[7:0]       <= 'd0; // gt_interface_sel is an external select
               end
     'h21    : begin // @ address = 0x04
               slv_rdata[1:0]       <= tx_pd_1;
               end
     'h22    : begin // @ address = 0x08
               slv_rdata[3:0]       <= txdiffctrl_1;
               end
     'h23    : begin // @ address = 0x0C
               slv_rdata[0]         <= txinihibit_1;
               end
     'h24    : begin // @ address = 0x10
               slv_rdata[0]         <= txpolarity_1;
               end

      default: slv_rdata            <= 'd0;
      endcase
      end
    end
   
   //---------------------------------------------------------------------------
   // read/write done logic.
   // Completed with the retruning pulse from the clk2 domain
   //---------------------------------------------------------------------------
   always @(*)
     begin
     slv_rd_done = slv_wren_done_pulse & (  slv_rden_r) ;
     slv_wr_done = slv_wren_done_pulse & (! slv_rden_r);
     end

endmodule
