//-----------------------------------------------------------------------------
// Title      : phyCoreCtrlInterface_hshk_pls_gen
// Project    : NA
//-----------------------------------------------------------------------------
// File       : phyCoreCtrlInterface_hshk_pls_gen.v
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

//-----------------------------------------------------------------------------
// Pulse handshake
//-----------------------------------------------------------------------------
module jesd204_phy_0_phyCoreCtrlInterface_hshk_pls_gen (
  input       clk1,
  input       clk1_rst,
  
  input       clk1_valid,
  output      clk1_ready,
  output reg  clk1_ready_pulse,
 
  input       clk2,
  input       clk2_rst,
  
  output      clk2_valid,
  output reg  clk2_valid_pulse,
  input       clk2_ready_pulse
   
 );
 
//-----------------------------------------------------------------------------
// internal registers
//-----------------------------------------------------------------------------
reg clk2_valid_sync_r;
reg clk1_ready_sync_r;
reg clk2_ready;
       
//-----------------------------------------------------------------------------
// sync the valid signal. This should be held high by the clk1 domain until
// ready is seen back in the clk1 domain, when the transaction is complete
//-----------------------------------------------------------------------------
jesd204_phy_0_phyCoreCtrlInterface_sync axi_2_drp_valid_i (
  .clk      (clk2),
  .data_in  (clk1_valid),
  .data_out (clk2_valid) 
);
  
//-----------------------------------------------------------------------------
// Generate a vali pulse in clk2 domain when a rising edge is seen on valid
// When the returning ready pulse is seen the ready flag is raised and then
// passed to the clk1 domain. This signal is cleared when the valid signal
// goes low. It is the responsability of the clk 1 domain to clear this signal
//-----------------------------------------------------------------------------
always @(posedge clk2) begin
  if (~clk2_rst) begin
    clk2_valid_sync_r <= 1'd0;
    clk2_ready        <= 1'd0;
    clk2_valid_pulse  <= 1'd0;
    end
  else begin
    // register the sync output to create an pulse
    clk2_valid_sync_r <= clk2_valid;
    
    // create a pulse on a rising edge across the clock domain
    clk2_valid_pulse <= (~clk2_valid_sync_r) & clk2_valid;
    
    // Generate the ready signal, based on the incoming pulse
    if (clk2_ready_pulse) begin
      clk2_ready <= 1'd1;
      end
    else begin
      if(~clk2_valid) begin
        clk2_ready <= 1'd0;
        end
      end
    end
  end
 
//-----------------------------------------------------------------------------
// pass the ready signal between the two clock domains
//-----------------------------------------------------------------------------
jesd204_phy_0_phyCoreCtrlInterface_sync drp_2_axi_in_progress_i (
  .clk      (clk1),
  .data_in  (clk2_ready),
  .data_out (clk1_ready) 
);
 
//-----------------------------------------------------------------------------
// Generate a pulse on the falling edge of ready. 
//-----------------------------------------------------------------------------
always @(posedge clk1) begin
  if (~clk1_rst) begin
    clk1_ready_pulse  <= 1'd0;
    clk1_ready_sync_r <= 1'd0;
    end
  else begin
    // register the sync output to create an pulse
    clk1_ready_sync_r <= clk1_ready;
    
    // create a pulse on a FALLING edge across the clock domain
    // This is going to be really slow, but for a slow clk2, we need to ensure
    // we dont start another access before its done!
    clk1_ready_pulse <= (~clk1_ready) & (clk1_ready_sync_r);
    end
  end
 
endmodule

