//-----------------------------------------------------------------------------
// Title      : phyAxiConfig
// Project    : NA
//-----------------------------------------------------------------------------
// File       : phyAxiConfig.v
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

module jesd204_phy_0_phyAxiConfig #(
   parameter integer                   C_S_AXI_ADDR_WIDTH   = 11
   )
(
   input                                  s_axi_aclk,
   input                                  s_axi_aresetn,
   
   // 
   output reg                             timeout_enable = 1,
   output reg  [11:0]                     timeout_value = 128,
   output reg  [7:0]                      cmm_interface_sel = 0,
   output reg  [7:0]                      gt_interface_sel = 0,
   input                                  tx_reset_not_done,
   input                                  rx_reset_not_done,
   input                                  cpll_not_locked,
   input                                  qpll0_not_locked,
   input                                  qpll1_not_locked,

 
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
   wire        [7:0]                      major_revision;
   wire        [7:0]                      minor_revision;
   wire        [7:0]                      version_revision;
   wire        [7:0]                      fpga_type;
   wire        [7:0]                      speedgrade;
   wire        [7:0]                      package;
   wire        [7:0]                      gt_type;
   wire        [30:0]                     num_common_drp;
   wire        [30:0]                     num_transceiver_drp;
   wire        [30:0]                     num_transceiver_dbg;
   wire        [3:0]                      gt_rx_master_chan;
   wire        [3:0]                      gt_tx_master_chan;
   wire                                   rx_is_64;
   wire                                   tx_is_64;
   wire        [31:0]                     rxlinerate;
   wire        [31:0]                     rxrefclk;
   wire        [31:0]                     rxxmult;
   wire        [31:0]                     rxpll;
   wire        [31:0]                     txlinerate;
   wire        [31:0]                     txrefclk;
   wire        [31:0]                     txxmult;
   wire        [31:0]                     txpll;
   wire                                   sw_capable;
   wire        [31:0]                     ins_loss;
   wire        [1:0]                      equalisation;
   wire        [31:0]                     min_line_rate;
   wire        [31:0]                     max_line_rate;
   wire        [31:0]                     drp_clk_rate;
   wire        [31:0]                     gen_uuid;
   wire        [31:0]                     gen_version;
   wire        [31:0]                     gen_date;
   wire        [31:0]                     gen_time;

  //----------------------------------------------------------------------------
  // constant wire asisgnments, ease readability instead of coding into the
  // register read statement
  //----------------------------------------------------------------------------
  assign  major_revision                 = 8'd3;
  assign  minor_revision                 = 8'd4;
  assign  version_revision               = 8'd0;
  assign  fpga_type                      = 8'd1;
  assign  speedgrade                     = 8'd20;
  assign  package                        = 8'd3;
  assign  gt_type                        = 8'd5;
  assign  num_common_drp                 = 31'd2;
  assign  num_transceiver_drp            = 31'd8;
  assign  num_transceiver_dbg            = 31'd8;
  assign  gt_rx_master_chan              = 4'd0;
  assign  gt_tx_master_chan              = 4'd0;
  assign  rx_is_64                       = 1'd0;
  assign  tx_is_64                       = 1'd0;
  assign  rxlinerate                     = 32'd5000000;
  assign  rxrefclk                       = 32'd125000;
  assign  rxxmult                        = 32'd40000;
  assign  rxpll                          = 32'd3;
  assign  txlinerate                     = 32'd5000000;
  assign  txrefclk                       = 32'd125000;
  assign  txxmult                        = 32'd40000;
  assign  txpll                          = 32'd3;
  assign  sw_capable                     = 1'd0;
  assign  ins_loss                       = 32'd12000;
  assign  equalisation                   = 2'd0;
  assign  min_line_rate                  = 32'd5000;
  assign  max_line_rate                  = 32'd5000;
  assign  drp_clk_rate                   = 32'd100000;
  assign  gen_uuid                       = 32'd1617409;
  assign  gen_version                    = 32'd0;
  assign  gen_date                       = 32'd20170919;
  assign  gen_time                       = 32'd162438;

  //----------------------------------------------------------------------------
  // Register write logic
  //----------------------------------------------------------------------------
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
        // set RW register defaults
        timeout_enable                 <= 1'd1;
        timeout_value                  <= 12'd128;
        cmm_interface_sel              <= 8'd0;
        gt_interface_sel               <= 8'd0;

      end 
      else begin    
         // on a write we write to the appropiate register 
         if (slv_wren) begin
            case (slv_addr)
            'h5     : begin // @ address = 0x14
                      timeout_enable                 <= slv_wdata[0];
                      end
            'h7     : begin // @ address = 0x1C
                      timeout_value                  <= slv_wdata[11:0];
                      end
            'h8     : begin // @ address = 0x20
                      cmm_interface_sel              <= slv_wdata[7:0];
                      end
            'h9     : begin // @ address = 0x24
                      gt_interface_sel               <= slv_wdata[7:0];
                      end

            endcase
         end   
      end
   end
   
   //---------------------------------------------------------------------------
   // Register read logic, non registered, 
   //---------------------------------------------------------------------------
   always @(*)
     begin
     slv_rdata = 'd0; // Zero all data
     case (slv_addr)
     'h0     : begin // @ address = 0
               slv_rdata[31:24]     = major_revision;
               slv_rdata[23:16]     = minor_revision;
               slv_rdata[15:8]      = version_revision;
               end
     'h1     : begin // @ address = 4
               slv_rdata[31:24]     = fpga_type;
               slv_rdata[23:16]     = speedgrade;
               slv_rdata[15:8]      = package;
               slv_rdata[7:0]       = gt_type;
               end
     'h2     : begin // @ address = 8
               slv_rdata[30:0]      = num_common_drp;
               end
     'h3     : begin // @ address = 0xC
               slv_rdata[30:0]      = num_transceiver_drp;
               end
     'h4     : begin // @ address = 0x10
               slv_rdata[30:0]      = num_transceiver_dbg;
               end
     'h5     : begin // @ address = 0x14
               slv_rdata[0]         = timeout_enable;
               end
     'h7     : begin // @ address = 0x1C
               slv_rdata[11:0]      = timeout_value;
               end
     'h8     : begin // @ address = 0x20
               slv_rdata[7:0]       = cmm_interface_sel;
               end
     'h9     : begin // @ address = 0x24
               slv_rdata[7:0]       = gt_interface_sel;
               end
     'hc     : begin // @ address = 0x30
               slv_rdata[3:0]       = gt_rx_master_chan;
               end
     'hd     : begin // @ address = 0x34
               slv_rdata[3:0]       = gt_tx_master_chan;
               end
     'he     : begin // @ address = 0x38
               slv_rdata[0]         = rx_is_64;
               end
     'hf     : begin // @ address = 0x3C
               slv_rdata[0]         = tx_is_64;
               end
     'h20    : begin // @ address = 0x80
               slv_rdata[4]         = tx_reset_not_done;
               slv_rdata[3]         = rx_reset_not_done;
               slv_rdata[2]         = cpll_not_locked;
               slv_rdata[1]         = qpll0_not_locked;
               slv_rdata[0]         = qpll1_not_locked;
               end
     'h24    : begin // @ address = 0x90
               slv_rdata[31:0]      = rxlinerate;
               end
     'h26    : begin // @ address = 0x98
               slv_rdata[31:0]      = rxrefclk;
               end
     'h27    : begin // @ address = 0x9C
               slv_rdata[31:0]      = rxxmult;
               end
     'h28    : begin // @ address = 0xA0
               slv_rdata[31:0]      = rxpll;
               end
     'h2c    : begin // @ address = 0xB0
               slv_rdata[31:0]      = txlinerate;
               end
     'h2e    : begin // @ address = 0xB8
               slv_rdata[31:0]      = txrefclk;
               end
     'h2f    : begin // @ address = 0xBC
               slv_rdata[31:0]      = txxmult;
               end
     'h30    : begin // @ address = 0xC0
               slv_rdata[31:0]      = txpll;
               end
     'h34    : begin // @ address = 0xD0
               slv_rdata[0]         = sw_capable;
               end
     'h35    : begin // @ address = 0xD4
               slv_rdata[31:0]      = ins_loss;
               end
     'h36    : begin // @ address = 0xD8
               slv_rdata[1:0]       = equalisation;
               end
     'h38    : begin // @ address = 0xE0
               slv_rdata[31:0]      = min_line_rate;
               end
     'h39    : begin // @ address = 0xE4
               slv_rdata[31:0]      = max_line_rate;
               end
     'h3a    : begin // @ address = 0xE8
               slv_rdata[31:0]      = drp_clk_rate;
               end
     'h3c    : begin // @ address = 0xF0
               slv_rdata[31:0]      = gen_uuid;
               end
     'h3d    : begin // @ address = 0xF4
               slv_rdata[31:0]      = gen_version;
               end
     'h3e    : begin // @ address = 0xF8
               slv_rdata[31:0]      = gen_date;
               end
     'h3f    : begin // @ address = 0xFC
               slv_rdata[31:0]      = gen_time;
               end

     default   : slv_rdata = 'd0;
     endcase
     end
   
   //---------------------------------------------------------------------------
   // read/write done logic.
   // For the basic register bank these are fed directly back in as the reg
   // delay is known and fixed.
   //---------------------------------------------------------------------------
   always @(*)
     begin
     slv_rd_done = slv_rden;
     slv_wr_done = slv_wren;
     end

endmodule
