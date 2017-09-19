//----------------------------------------------------------------------------
// Title : Example Design Top Level
// Project : JESD204_phy
//----------------------------------------------------------------------------
// File : jesd204_phy_0_example_design_data_checker.v
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

module jesd204_phy_0_example_design_data_checker #(
  parameter  pLaneByteWidth = 4,
  parameter  pLaneWidth     = (pLaneByteWidth * 8)
) (

  input   wire [31:0] gt0_rxdata,           // input wire [31 : 0] gt0_rxdata
  input   wire  [3:0] gt0_rxcharisk,        // input wire  [3 : 0] gt0_rxcharisk
  input   wire  [3:0] gt0_rxdisperr,        // input wire  [3 : 0] gt0_rxdisperr
  input   wire  [3:0] gt0_rxnotintable,     // input wire  [3 : 0] gt0_rxnotintable
  input   wire [31:0] gt1_rxdata,           // input wire [31 : 0] gt1_rxdata
  input   wire  [3:0] gt1_rxcharisk,        // input wire  [3 : 0] gt1_rxcharisk
  input   wire  [3:0] gt1_rxdisperr,        // input wire  [3 : 0] gt1_rxdisperr
  input   wire  [3:0] gt1_rxnotintable,     // input wire  [3 : 0] gt1_rxnotintable

  input               reset,
  input               rx_coreclk,
  
  input               data_check_enable,
  output       [1:0]  sel_out,
  output  reg         data_check_all_one,
  output  reg         data_check_error
  
  );

wire [1:0] data_check_error_lane;
wire [1:0] data_check_all_one_b;
wire [1:0] sel_out_gt0;
wire [1:0] sel_out_gt1;

//----------------------------------------------------------------------------
// Or error signals together from each checker unit
//----------------------------------------------------------------------------
always @(posedge rx_coreclk) begin
   if(reset) begin
      data_check_error   <= 1'd0;
      data_check_all_one <= 1'd0;
   end else begin
      data_check_error   <= |data_check_error_lane;
      data_check_all_one <= data_check_all_one_b[0];
   end
end  

assign sel_out = sel_out_gt0;

//----------------------------------------------------------------------------
// Test units per lane
//----------------------------------------------------------------------------
jesd204_phy_0_example_design_checker_unit #(
  .pLaneByteWidth(pLaneByteWidth)
) i_data_check_0(

  .gt_rxdata              (gt0_rxdata       ),
  .gt_rxcharisk           (gt0_rxcharisk    ),
  .gt_rxdisperr           (gt0_rxdisperr    ),
  .gt_rxnotintable        (gt0_rxnotintable ),

  .reset                  (reset                          ),
  .rx_coreclk             (rx_coreclk                     ),
  .sel_out                (sel_out_gt0              ),
  .data_check_error       (data_check_error_lane[0]  ),
  .data_check_all_one     (data_check_all_one_b[0]   ),
  .data_check_enable      (data_check_enable              )
  
  );

jesd204_phy_0_example_design_checker_unit #(
  .pLaneByteWidth(pLaneByteWidth)
) i_data_check_1(

  .gt_rxdata              (gt1_rxdata       ),
  .gt_rxcharisk           (gt1_rxcharisk    ),
  .gt_rxdisperr           (gt1_rxdisperr    ),
  .gt_rxnotintable        (gt1_rxnotintable ),

  .reset                  (reset                          ),
  .rx_coreclk             (rx_coreclk                     ),
  .sel_out                (sel_out_gt1              ),
  .data_check_error       (data_check_error_lane[1]  ),
  .data_check_all_one     (data_check_all_one_b[1]   ),
  .data_check_enable      (data_check_enable              )
  
  );

endmodule


