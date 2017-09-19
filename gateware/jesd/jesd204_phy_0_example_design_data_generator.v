//----------------------------------------------------------------------------
// Project : JESD204_phy
//----------------------------------------------------------------------------
// File : jesd204_phy_0_example_design_data_generator.v
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

module jesd204_phy_0_example_design_data_generator #(
  parameter  pLaneByteWidth = 4,
  parameter  pLaneWidth     = (pLaneByteWidth * 8)
) (

  output  [pLaneWidth-1:0] gt0_txdata,    
  output             [3:0] gt0_txcharisk,
  output  [pLaneWidth-1:0] gt1_txdata,    
  output             [3:0] gt1_txcharisk,
  output reg               data_gen_all_one,
  
  input                    reset,
  input                    tx_coreclk,
  input              [3:0] data_generate_enable
  
  );

//----------------------------------------------------------------------------
// Declaration
//----------------------------------------------------------------------------
wire [1:0] data_gen_all_one_b;

//----------------------------------------------------------------------------
// register data all one
//----------------------------------------------------------------------------
always @(posedge tx_coreclk) begin
   if(reset) begin
      data_gen_all_one <= 1'd0;
   end else begin
      data_gen_all_one <= data_gen_all_one_b[0];
   end
end  
  
// -----------------------------------------------------------------------------
// Lane 0 the data generator
// -----------------------------------------------------------------------------
jesd204_phy_0_example_design_generate_unit #( 
  .pLaneByteWidth (pLaneByteWidth) 
  ) i_data_gen_0(

  .gt_txdata              (gt0_txdata      ),
  .gt_txcharisk           (gt0_txcharisk   ),
  .data_gen_all_one       (data_gen_all_one_b[0]),

  .reset                  (reset                 ),
  .tx_coreclk             (tx_coreclk            ),
  .data_generate_enable   (data_generate_enable  )
  
  );

// -----------------------------------------------------------------------------
// Lane 1 the data generator
// -----------------------------------------------------------------------------
jesd204_phy_0_example_design_generate_unit #( 
  .pLaneByteWidth (pLaneByteWidth) 
  ) i_data_gen_1(

  .gt_txdata              (gt1_txdata      ),
  .gt_txcharisk           (gt1_txcharisk   ),
  .data_gen_all_one       (data_gen_all_one_b[1]),

  .reset                  (reset                 ),
  .tx_coreclk             (tx_coreclk            ),
  .data_generate_enable   (data_generate_enable  )
  
  );


endmodule


