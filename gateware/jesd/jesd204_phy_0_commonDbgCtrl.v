//-----------------------------------------------------------------------------
// Title      : commonDbgCtrl
// Project    : NA
//-----------------------------------------------------------------------------
// File       : commonDbgCtrl.v
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

module jesd204_phy_0_commonDbgCtrl #(
   parameter integer                   C_S_AXI_ADDR_WIDTH   = 11
   )
(
   input                                  s_axi_aclk,
   input                                  s_axi_aresetn,
   
   // IO for bank 0 
   input       [7:0]                      cmm_interface_sel,
   output reg                             qpll0_pd_0 = 0,
   output reg                             qpll1_pd_0 = 1,

 
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

        qpll0_pd_0                     <= 1'd0;
        qpll1_pd_0                     <= 1'd1;

 
      end 
      else begin    
         // on a write we write to the appropriate register 
         if (slv_wren) begin
            case ({cmm_interface_sel,slv_addr[6:2]})
            // WRITE assignments for signal block 0
            'h1     : begin // @ address = 0x04
                      qpll0_pd_0                     <= slv_wdata[0];
                      end
            'h2     : begin // @ address = 0x08
                      qpll1_pd_0                     <= slv_wdata[0];
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
     case ({cmm_interface_sel,slv_addr[6:2]})
     // READ assignments for signal block 0
     'h0     : begin // @ address = 0x00
               slv_rdata[7:0]       = 'd0; // cmm_interface_sel is an external select
               end
     'h1     : begin // @ address = 0x04
               slv_rdata[0]         = qpll0_pd_0;
               end
     'h2     : begin // @ address = 0x08
               slv_rdata[0]         = qpll1_pd_0;
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
