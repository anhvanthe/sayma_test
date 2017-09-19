//-----------------------------------------------------------------------------
// Title      : transDbgCtrl_async
// Project    : NA
//-----------------------------------------------------------------------------
// File       : transDbgCtrl_async.v
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

module jesd204_phy_0_transDbgCtrl_async #(
   parameter integer                   C_S_AXI_ADDR_WIDTH   = 11
   )
(
   input                                  s_axi_aclk,
   input                                  s_axi_aresetn,
   
   // IO for bank 0 
   input       [7:0]                      gt_interface_sel,
   output reg  [1:0]                      rx_pd_0 = 0,
   output reg                             cpll_pd_0 = 1,
   output reg  [1:0]                      txpllclksel = 3,
   output reg  [1:0]                      rxpllclksel = 3,
   output reg  [4:0]                      txpostcursor_0 = 0,
   output reg  [4:0]                      txprecursor_0 = 0,
   output reg  [2:0]                      loopback_0 = 0,
   output reg                             tx_sys_reset_axi = 0,
   output reg                             rx_sys_reset_axi = 0,
   output reg  [17:0]                     cpll_cal_per = 0,
   output reg  [17:0]                     cpll_cal_tol = 0,

   // IO for bank 1 
   output reg  [1:0]                      rx_pd_1 = 0,
   output reg                             cpll_pd_1 = 1,
   output reg  [4:0]                      txpostcursor_1 = 0,
   output reg  [4:0]                      txprecursor_1 = 0,
   output reg  [2:0]                      loopback_1 = 0,

   // IO for bank 2 
   output reg  [1:0]                      rx_pd_2 = 0,
   output reg                             cpll_pd_2 = 1,
   output reg  [4:0]                      txpostcursor_2 = 0,
   output reg  [4:0]                      txprecursor_2 = 0,
   output reg  [2:0]                      loopback_2 = 0,

   // IO for bank 3 
   output reg  [1:0]                      rx_pd_3 = 0,
   output reg                             cpll_pd_3 = 1,
   output reg  [4:0]                      txpostcursor_3 = 0,
   output reg  [4:0]                      txprecursor_3 = 0,
   output reg  [2:0]                      loopback_3 = 0,

   // IO for bank 4 
   output reg  [1:0]                      rx_pd_4 = 0,
   output reg                             cpll_pd_4 = 1,
   output reg  [4:0]                      txpostcursor_4 = 0,
   output reg  [4:0]                      txprecursor_4 = 0,
   output reg  [2:0]                      loopback_4 = 0,

   // IO for bank 5 
   output reg  [1:0]                      rx_pd_5 = 0,
   output reg                             cpll_pd_5 = 1,
   output reg  [4:0]                      txpostcursor_5 = 0,
   output reg  [4:0]                      txprecursor_5 = 0,
   output reg  [2:0]                      loopback_5 = 0,

   // IO for bank 6 
   output reg  [1:0]                      rx_pd_6 = 0,
   output reg                             cpll_pd_6 = 1,
   output reg  [4:0]                      txpostcursor_6 = 0,
   output reg  [4:0]                      txprecursor_6 = 0,
   output reg  [2:0]                      loopback_6 = 0,

   // IO for bank 7 
   output reg  [1:0]                      rx_pd_7 = 0,
   output reg                             cpll_pd_7 = 1,
   output reg  [4:0]                      txpostcursor_7 = 0,
   output reg  [4:0]                      txprecursor_7 = 0,
   output reg  [2:0]                      loopback_7 = 0,

 
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
  // Register write logic
  //----------------------------------------------------------------------------
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
        // set RW register defaults

        rx_pd_0                        <= 2'd0;
        cpll_pd_0                      <= 1'd1;
        txpllclksel                    <= 2'd3;
        rxpllclksel                    <= 2'd3;
        txpostcursor_0                 <= 5'd0;
        txprecursor_0                  <= 5'd0;
        loopback_0                     <= 3'd0;
        tx_sys_reset_axi               <= 1'd0;
        rx_sys_reset_axi               <= 1'd0;
        cpll_cal_per                   <= 18'd0;
        cpll_cal_tol                   <= 18'd0;

        rx_pd_1                        <= 2'd0;
        cpll_pd_1                      <= 1'd1;
        txpostcursor_1                 <= 5'd0;
        txprecursor_1                  <= 5'd0;
        loopback_1                     <= 3'd0;

        rx_pd_2                        <= 2'd0;
        cpll_pd_2                      <= 1'd1;
        txpostcursor_2                 <= 5'd0;
        txprecursor_2                  <= 5'd0;
        loopback_2                     <= 3'd0;

        rx_pd_3                        <= 2'd0;
        cpll_pd_3                      <= 1'd1;
        txpostcursor_3                 <= 5'd0;
        txprecursor_3                  <= 5'd0;
        loopback_3                     <= 3'd0;

        rx_pd_4                        <= 2'd0;
        cpll_pd_4                      <= 1'd1;
        txpostcursor_4                 <= 5'd0;
        txprecursor_4                  <= 5'd0;
        loopback_4                     <= 3'd0;

        rx_pd_5                        <= 2'd0;
        cpll_pd_5                      <= 1'd1;
        txpostcursor_5                 <= 5'd0;
        txprecursor_5                  <= 5'd0;
        loopback_5                     <= 3'd0;

        rx_pd_6                        <= 2'd0;
        cpll_pd_6                      <= 1'd1;
        txpostcursor_6                 <= 5'd0;
        txprecursor_6                  <= 5'd0;
        loopback_6                     <= 3'd0;

        rx_pd_7                        <= 2'd0;
        cpll_pd_7                      <= 1'd1;
        txpostcursor_7                 <= 5'd0;
        txprecursor_7                  <= 5'd0;
        loopback_7                     <= 3'd0;

 
      end 
      else begin    
         // on a write we write to the appropriate register 
         if (slv_wren) begin
            case ({gt_interface_sel,slv_addr[6:2]})
            // WRITE assignments for signal block 0
            'h1     : begin // @ address = 0x04
                      rx_pd_0                        <= slv_wdata[1:0];
                      end
            'h2     : begin // @ address = 0x08
                      cpll_pd_0                      <= slv_wdata[0];
                      end
            'h3     : begin // @ address = 0x0C
                      txpllclksel                    <= slv_wdata[1:0];
                      end
            'h4     : begin // @ address = 0x10
                      rxpllclksel                    <= slv_wdata[1:0];
                      end
            'h5     : begin // @ address = 0x14
                      txpostcursor_0                 <= slv_wdata[4:0];
                      end
            'h6     : begin // @ address = 0x18
                      txprecursor_0                  <= slv_wdata[4:0];
                      end
            'h7     : begin // @ address = 0x1C
                      loopback_0                     <= slv_wdata[2:0];
                      end
            'h8     : begin // @ address = 0x20
                      tx_sys_reset_axi               <= slv_wdata[0];
                      end
            'h9     : begin // @ address = 0x24
                      rx_sys_reset_axi               <= slv_wdata[0];
                      end
            'hc     : begin // @ address = 0x30
                      cpll_cal_per                   <= slv_wdata[17:0];
                      end
            'hd     : begin // @ address = 0x34
                      cpll_cal_tol                   <= slv_wdata[17:0];
                      end

            // WRITE assignments for signal block 1
            'h21    : begin // @ address = 0x04
                      rx_pd_1                        <= slv_wdata[1:0];
                      end
            'h22    : begin // @ address = 0x08
                      cpll_pd_1                      <= slv_wdata[0];
                      end
            'h23    : begin // @ address = 0x0C
                      txpllclksel                    <= slv_wdata[1:0];
                      end
            'h24    : begin // @ address = 0x10
                      rxpllclksel                    <= slv_wdata[1:0];
                      end
            'h25    : begin // @ address = 0x14
                      txpostcursor_1                 <= slv_wdata[4:0];
                      end
            'h26    : begin // @ address = 0x18
                      txprecursor_1                  <= slv_wdata[4:0];
                      end
            'h27    : begin // @ address = 0x1C
                      loopback_1                     <= slv_wdata[2:0];
                      end
            'h28    : begin // @ address = 0x20
                      tx_sys_reset_axi               <= slv_wdata[0];
                      end
            'h29    : begin // @ address = 0x24
                      rx_sys_reset_axi               <= slv_wdata[0];
                      end
            'h2c    : begin // @ address = 0x30
                      cpll_cal_per                   <= slv_wdata[17:0];
                      end
            'h2d    : begin // @ address = 0x34
                      cpll_cal_tol                   <= slv_wdata[17:0];
                      end

            // WRITE assignments for signal block 2
            'h41    : begin // @ address = 0x04
                      rx_pd_2                        <= slv_wdata[1:0];
                      end
            'h42    : begin // @ address = 0x08
                      cpll_pd_2                      <= slv_wdata[0];
                      end
            'h43    : begin // @ address = 0x0C
                      txpllclksel                    <= slv_wdata[1:0];
                      end
            'h44    : begin // @ address = 0x10
                      rxpllclksel                    <= slv_wdata[1:0];
                      end
            'h45    : begin // @ address = 0x14
                      txpostcursor_2                 <= slv_wdata[4:0];
                      end
            'h46    : begin // @ address = 0x18
                      txprecursor_2                  <= slv_wdata[4:0];
                      end
            'h47    : begin // @ address = 0x1C
                      loopback_2                     <= slv_wdata[2:0];
                      end
            'h48    : begin // @ address = 0x20
                      tx_sys_reset_axi               <= slv_wdata[0];
                      end
            'h49    : begin // @ address = 0x24
                      rx_sys_reset_axi               <= slv_wdata[0];
                      end
            'h4c    : begin // @ address = 0x30
                      cpll_cal_per                   <= slv_wdata[17:0];
                      end
            'h4d    : begin // @ address = 0x34
                      cpll_cal_tol                   <= slv_wdata[17:0];
                      end

            // WRITE assignments for signal block 3
            'h61    : begin // @ address = 0x04
                      rx_pd_3                        <= slv_wdata[1:0];
                      end
            'h62    : begin // @ address = 0x08
                      cpll_pd_3                      <= slv_wdata[0];
                      end
            'h63    : begin // @ address = 0x0C
                      txpllclksel                    <= slv_wdata[1:0];
                      end
            'h64    : begin // @ address = 0x10
                      rxpllclksel                    <= slv_wdata[1:0];
                      end
            'h65    : begin // @ address = 0x14
                      txpostcursor_3                 <= slv_wdata[4:0];
                      end
            'h66    : begin // @ address = 0x18
                      txprecursor_3                  <= slv_wdata[4:0];
                      end
            'h67    : begin // @ address = 0x1C
                      loopback_3                     <= slv_wdata[2:0];
                      end
            'h68    : begin // @ address = 0x20
                      tx_sys_reset_axi               <= slv_wdata[0];
                      end
            'h69    : begin // @ address = 0x24
                      rx_sys_reset_axi               <= slv_wdata[0];
                      end
            'h6c    : begin // @ address = 0x30
                      cpll_cal_per                   <= slv_wdata[17:0];
                      end
            'h6d    : begin // @ address = 0x34
                      cpll_cal_tol                   <= slv_wdata[17:0];
                      end

            // WRITE assignments for signal block 4
            'h81    : begin // @ address = 0x04
                      rx_pd_4                        <= slv_wdata[1:0];
                      end
            'h82    : begin // @ address = 0x08
                      cpll_pd_4                      <= slv_wdata[0];
                      end
            'h83    : begin // @ address = 0x0C
                      txpllclksel                    <= slv_wdata[1:0];
                      end
            'h84    : begin // @ address = 0x10
                      rxpllclksel                    <= slv_wdata[1:0];
                      end
            'h85    : begin // @ address = 0x14
                      txpostcursor_4                 <= slv_wdata[4:0];
                      end
            'h86    : begin // @ address = 0x18
                      txprecursor_4                  <= slv_wdata[4:0];
                      end
            'h87    : begin // @ address = 0x1C
                      loopback_4                     <= slv_wdata[2:0];
                      end
            'h88    : begin // @ address = 0x20
                      tx_sys_reset_axi               <= slv_wdata[0];
                      end
            'h89    : begin // @ address = 0x24
                      rx_sys_reset_axi               <= slv_wdata[0];
                      end
            'h8c    : begin // @ address = 0x30
                      cpll_cal_per                   <= slv_wdata[17:0];
                      end
            'h8d    : begin // @ address = 0x34
                      cpll_cal_tol                   <= slv_wdata[17:0];
                      end

            // WRITE assignments for signal block 5
            'ha1    : begin // @ address = 0x04
                      rx_pd_5                        <= slv_wdata[1:0];
                      end
            'ha2    : begin // @ address = 0x08
                      cpll_pd_5                      <= slv_wdata[0];
                      end
            'ha3    : begin // @ address = 0x0C
                      txpllclksel                    <= slv_wdata[1:0];
                      end
            'ha4    : begin // @ address = 0x10
                      rxpllclksel                    <= slv_wdata[1:0];
                      end
            'ha5    : begin // @ address = 0x14
                      txpostcursor_5                 <= slv_wdata[4:0];
                      end
            'ha6    : begin // @ address = 0x18
                      txprecursor_5                  <= slv_wdata[4:0];
                      end
            'ha7    : begin // @ address = 0x1C
                      loopback_5                     <= slv_wdata[2:0];
                      end
            'ha8    : begin // @ address = 0x20
                      tx_sys_reset_axi               <= slv_wdata[0];
                      end
            'ha9    : begin // @ address = 0x24
                      rx_sys_reset_axi               <= slv_wdata[0];
                      end
            'hac    : begin // @ address = 0x30
                      cpll_cal_per                   <= slv_wdata[17:0];
                      end
            'had    : begin // @ address = 0x34
                      cpll_cal_tol                   <= slv_wdata[17:0];
                      end

            // WRITE assignments for signal block 6
            'hc1    : begin // @ address = 0x04
                      rx_pd_6                        <= slv_wdata[1:0];
                      end
            'hc2    : begin // @ address = 0x08
                      cpll_pd_6                      <= slv_wdata[0];
                      end
            'hc3    : begin // @ address = 0x0C
                      txpllclksel                    <= slv_wdata[1:0];
                      end
            'hc4    : begin // @ address = 0x10
                      rxpllclksel                    <= slv_wdata[1:0];
                      end
            'hc5    : begin // @ address = 0x14
                      txpostcursor_6                 <= slv_wdata[4:0];
                      end
            'hc6    : begin // @ address = 0x18
                      txprecursor_6                  <= slv_wdata[4:0];
                      end
            'hc7    : begin // @ address = 0x1C
                      loopback_6                     <= slv_wdata[2:0];
                      end
            'hc8    : begin // @ address = 0x20
                      tx_sys_reset_axi               <= slv_wdata[0];
                      end
            'hc9    : begin // @ address = 0x24
                      rx_sys_reset_axi               <= slv_wdata[0];
                      end
            'hcc    : begin // @ address = 0x30
                      cpll_cal_per                   <= slv_wdata[17:0];
                      end
            'hcd    : begin // @ address = 0x34
                      cpll_cal_tol                   <= slv_wdata[17:0];
                      end

            // WRITE assignments for signal block 7
            'he1    : begin // @ address = 0x04
                      rx_pd_7                        <= slv_wdata[1:0];
                      end
            'he2    : begin // @ address = 0x08
                      cpll_pd_7                      <= slv_wdata[0];
                      end
            'he3    : begin // @ address = 0x0C
                      txpllclksel                    <= slv_wdata[1:0];
                      end
            'he4    : begin // @ address = 0x10
                      rxpllclksel                    <= slv_wdata[1:0];
                      end
            'he5    : begin // @ address = 0x14
                      txpostcursor_7                 <= slv_wdata[4:0];
                      end
            'he6    : begin // @ address = 0x18
                      txprecursor_7                  <= slv_wdata[4:0];
                      end
            'he7    : begin // @ address = 0x1C
                      loopback_7                     <= slv_wdata[2:0];
                      end
            'he8    : begin // @ address = 0x20
                      tx_sys_reset_axi               <= slv_wdata[0];
                      end
            'he9    : begin // @ address = 0x24
                      rx_sys_reset_axi               <= slv_wdata[0];
                      end
            'hec    : begin // @ address = 0x30
                      cpll_cal_per                   <= slv_wdata[17:0];
                      end
            'hed    : begin // @ address = 0x34
                      cpll_cal_tol                   <= slv_wdata[17:0];
                      end

            endcase
         end   
      end
   end
   
  //----------------------------------------------------------------------------
   // Register read logic, non registered, 
   //---------------------------------------------------------------------------
   always @(*)
     begin
     slv_rdata = 'd0; // Zero all data bits, individual bits may be modified in the case below
     case ({gt_interface_sel,slv_addr[6:2]})
     // READ assignments for signal block 0
     'h0     : begin // @ address = 0x00
               slv_rdata[7:0]       = 'd0; // gt_interface_sel is an external select
               end
     'h1     : begin // @ address = 0x04
               slv_rdata[1:0]       = rx_pd_0;
               end
     'h2     : begin // @ address = 0x08
               slv_rdata[0]         = cpll_pd_0;
               end
     'h3     : begin // @ address = 0x0C
               slv_rdata[1:0]       = txpllclksel;
               end
     'h4     : begin // @ address = 0x10
               slv_rdata[1:0]       = rxpllclksel;
               end
     'h5     : begin // @ address = 0x14
               slv_rdata[4:0]       = txpostcursor_0;
               end
     'h6     : begin // @ address = 0x18
               slv_rdata[4:0]       = txprecursor_0;
               end
     'h7     : begin // @ address = 0x1C
               slv_rdata[2:0]       = loopback_0;
               end
     'h8     : begin // @ address = 0x20
               slv_rdata[0]         = tx_sys_reset_axi;
               end
     'h9     : begin // @ address = 0x24
               slv_rdata[0]         = rx_sys_reset_axi;
               end
     'hc     : begin // @ address = 0x30
               slv_rdata[17:0]      = cpll_cal_per;
               end
     'hd     : begin // @ address = 0x34
               slv_rdata[17:0]      = cpll_cal_tol;
               end

     // READ assignments for signal block 1
     'h20    : begin // @ address = 0x00
               slv_rdata[7:0]       = 'd0; // gt_interface_sel is an external select
               end
     'h21    : begin // @ address = 0x04
               slv_rdata[1:0]       = rx_pd_1;
               end
     'h22    : begin // @ address = 0x08
               slv_rdata[0]         = cpll_pd_1;
               end
     'h23    : begin // @ address = 0x0C
               slv_rdata[1:0]       = txpllclksel;
               end
     'h24    : begin // @ address = 0x10
               slv_rdata[1:0]       = rxpllclksel;
               end
     'h25    : begin // @ address = 0x14
               slv_rdata[4:0]       = txpostcursor_1;
               end
     'h26    : begin // @ address = 0x18
               slv_rdata[4:0]       = txprecursor_1;
               end
     'h27    : begin // @ address = 0x1C
               slv_rdata[2:0]       = loopback_1;
               end
     'h28    : begin // @ address = 0x20
               slv_rdata[0]         = tx_sys_reset_axi;
               end
     'h29    : begin // @ address = 0x24
               slv_rdata[0]         = rx_sys_reset_axi;
               end
     'h2c    : begin // @ address = 0x30
               slv_rdata[17:0]      = cpll_cal_per;
               end
     'h2d    : begin // @ address = 0x34
               slv_rdata[17:0]      = cpll_cal_tol;
               end

     // READ assignments for signal block 2
     'h40    : begin // @ address = 0x00
               slv_rdata[7:0]       = 'd0; // gt_interface_sel is an external select
               end
     'h41    : begin // @ address = 0x04
               slv_rdata[1:0]       = rx_pd_2;
               end
     'h42    : begin // @ address = 0x08
               slv_rdata[0]         = cpll_pd_2;
               end
     'h43    : begin // @ address = 0x0C
               slv_rdata[1:0]       = txpllclksel;
               end
     'h44    : begin // @ address = 0x10
               slv_rdata[1:0]       = rxpllclksel;
               end
     'h45    : begin // @ address = 0x14
               slv_rdata[4:0]       = txpostcursor_2;
               end
     'h46    : begin // @ address = 0x18
               slv_rdata[4:0]       = txprecursor_2;
               end
     'h47    : begin // @ address = 0x1C
               slv_rdata[2:0]       = loopback_2;
               end
     'h48    : begin // @ address = 0x20
               slv_rdata[0]         = tx_sys_reset_axi;
               end
     'h49    : begin // @ address = 0x24
               slv_rdata[0]         = rx_sys_reset_axi;
               end
     'h4c    : begin // @ address = 0x30
               slv_rdata[17:0]      = cpll_cal_per;
               end
     'h4d    : begin // @ address = 0x34
               slv_rdata[17:0]      = cpll_cal_tol;
               end

     // READ assignments for signal block 3
     'h60    : begin // @ address = 0x00
               slv_rdata[7:0]       = 'd0; // gt_interface_sel is an external select
               end
     'h61    : begin // @ address = 0x04
               slv_rdata[1:0]       = rx_pd_3;
               end
     'h62    : begin // @ address = 0x08
               slv_rdata[0]         = cpll_pd_3;
               end
     'h63    : begin // @ address = 0x0C
               slv_rdata[1:0]       = txpllclksel;
               end
     'h64    : begin // @ address = 0x10
               slv_rdata[1:0]       = rxpllclksel;
               end
     'h65    : begin // @ address = 0x14
               slv_rdata[4:0]       = txpostcursor_3;
               end
     'h66    : begin // @ address = 0x18
               slv_rdata[4:0]       = txprecursor_3;
               end
     'h67    : begin // @ address = 0x1C
               slv_rdata[2:0]       = loopback_3;
               end
     'h68    : begin // @ address = 0x20
               slv_rdata[0]         = tx_sys_reset_axi;
               end
     'h69    : begin // @ address = 0x24
               slv_rdata[0]         = rx_sys_reset_axi;
               end
     'h6c    : begin // @ address = 0x30
               slv_rdata[17:0]      = cpll_cal_per;
               end
     'h6d    : begin // @ address = 0x34
               slv_rdata[17:0]      = cpll_cal_tol;
               end

     // READ assignments for signal block 4
     'h80    : begin // @ address = 0x00
               slv_rdata[7:0]       = 'd0; // gt_interface_sel is an external select
               end
     'h81    : begin // @ address = 0x04
               slv_rdata[1:0]       = rx_pd_4;
               end
     'h82    : begin // @ address = 0x08
               slv_rdata[0]         = cpll_pd_4;
               end
     'h83    : begin // @ address = 0x0C
               slv_rdata[1:0]       = txpllclksel;
               end
     'h84    : begin // @ address = 0x10
               slv_rdata[1:0]       = rxpllclksel;
               end
     'h85    : begin // @ address = 0x14
               slv_rdata[4:0]       = txpostcursor_4;
               end
     'h86    : begin // @ address = 0x18
               slv_rdata[4:0]       = txprecursor_4;
               end
     'h87    : begin // @ address = 0x1C
               slv_rdata[2:0]       = loopback_4;
               end
     'h88    : begin // @ address = 0x20
               slv_rdata[0]         = tx_sys_reset_axi;
               end
     'h89    : begin // @ address = 0x24
               slv_rdata[0]         = rx_sys_reset_axi;
               end
     'h8c    : begin // @ address = 0x30
               slv_rdata[17:0]      = cpll_cal_per;
               end
     'h8d    : begin // @ address = 0x34
               slv_rdata[17:0]      = cpll_cal_tol;
               end

     // READ assignments for signal block 5
     'ha0    : begin // @ address = 0x00
               slv_rdata[7:0]       = 'd0; // gt_interface_sel is an external select
               end
     'ha1    : begin // @ address = 0x04
               slv_rdata[1:0]       = rx_pd_5;
               end
     'ha2    : begin // @ address = 0x08
               slv_rdata[0]         = cpll_pd_5;
               end
     'ha3    : begin // @ address = 0x0C
               slv_rdata[1:0]       = txpllclksel;
               end
     'ha4    : begin // @ address = 0x10
               slv_rdata[1:0]       = rxpllclksel;
               end
     'ha5    : begin // @ address = 0x14
               slv_rdata[4:0]       = txpostcursor_5;
               end
     'ha6    : begin // @ address = 0x18
               slv_rdata[4:0]       = txprecursor_5;
               end
     'ha7    : begin // @ address = 0x1C
               slv_rdata[2:0]       = loopback_5;
               end
     'ha8    : begin // @ address = 0x20
               slv_rdata[0]         = tx_sys_reset_axi;
               end
     'ha9    : begin // @ address = 0x24
               slv_rdata[0]         = rx_sys_reset_axi;
               end
     'hac    : begin // @ address = 0x30
               slv_rdata[17:0]      = cpll_cal_per;
               end
     'had    : begin // @ address = 0x34
               slv_rdata[17:0]      = cpll_cal_tol;
               end

     // READ assignments for signal block 6
     'hc0    : begin // @ address = 0x00
               slv_rdata[7:0]       = 'd0; // gt_interface_sel is an external select
               end
     'hc1    : begin // @ address = 0x04
               slv_rdata[1:0]       = rx_pd_6;
               end
     'hc2    : begin // @ address = 0x08
               slv_rdata[0]         = cpll_pd_6;
               end
     'hc3    : begin // @ address = 0x0C
               slv_rdata[1:0]       = txpllclksel;
               end
     'hc4    : begin // @ address = 0x10
               slv_rdata[1:0]       = rxpllclksel;
               end
     'hc5    : begin // @ address = 0x14
               slv_rdata[4:0]       = txpostcursor_6;
               end
     'hc6    : begin // @ address = 0x18
               slv_rdata[4:0]       = txprecursor_6;
               end
     'hc7    : begin // @ address = 0x1C
               slv_rdata[2:0]       = loopback_6;
               end
     'hc8    : begin // @ address = 0x20
               slv_rdata[0]         = tx_sys_reset_axi;
               end
     'hc9    : begin // @ address = 0x24
               slv_rdata[0]         = rx_sys_reset_axi;
               end
     'hcc    : begin // @ address = 0x30
               slv_rdata[17:0]      = cpll_cal_per;
               end
     'hcd    : begin // @ address = 0x34
               slv_rdata[17:0]      = cpll_cal_tol;
               end

     // READ assignments for signal block 7
     'he0    : begin // @ address = 0x00
               slv_rdata[7:0]       = 'd0; // gt_interface_sel is an external select
               end
     'he1    : begin // @ address = 0x04
               slv_rdata[1:0]       = rx_pd_7;
               end
     'he2    : begin // @ address = 0x08
               slv_rdata[0]         = cpll_pd_7;
               end
     'he3    : begin // @ address = 0x0C
               slv_rdata[1:0]       = txpllclksel;
               end
     'he4    : begin // @ address = 0x10
               slv_rdata[1:0]       = rxpllclksel;
               end
     'he5    : begin // @ address = 0x14
               slv_rdata[4:0]       = txpostcursor_7;
               end
     'he6    : begin // @ address = 0x18
               slv_rdata[4:0]       = txprecursor_7;
               end
     'he7    : begin // @ address = 0x1C
               slv_rdata[2:0]       = loopback_7;
               end
     'he8    : begin // @ address = 0x20
               slv_rdata[0]         = tx_sys_reset_axi;
               end
     'he9    : begin // @ address = 0x24
               slv_rdata[0]         = rx_sys_reset_axi;
               end
     'hec    : begin // @ address = 0x30
               slv_rdata[17:0]      = cpll_cal_per;
               end
     'hed    : begin // @ address = 0x34
               slv_rdata[17:0]      = cpll_cal_tol;
               end

     default : slv_rdata            = 'd0;
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
