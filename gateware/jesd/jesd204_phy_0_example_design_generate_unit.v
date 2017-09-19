//----------------------------------------------------------------------------
// Title : Example Design Top Level
// Project : JESD204_phy
//----------------------------------------------------------------------------
// File : jesd204_phy_0_example_design_generate_unit.v
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

module jesd204_phy_0_example_design_generate_unit #(
  parameter  pLaneByteWidth = 4,
  parameter  pLaneWidth     = (pLaneByteWidth * 8)
) (

  output reg     [pLaneWidth-1:0] gt_txdata,    
  output reg [pLaneByteWidth-1:0] gt_txcharisk,
  output reg                      data_gen_all_one,
  //output reg [1:0]  sel_out=0,

  input                           reset,
  input                           tx_coreclk,
  input                     [3:0] data_generate_enable
  
  );
  
  localparam pK_is_r = 8'h1C;                  // K28_0
  localparam pK_is_a = 8'h7C;                  // K28_3
  localparam pK_is_q = 8'h9C;                  // K28_4
  localparam pK_is_k = 8'hBC;                  // K28_5
  localparam pSymbol = 1'h1;                   // Symbol
  localparam pData   = 1'h0;                   // Data
  
  localparam pSeqCntWidth  = 8;                // Simple data generator
  
// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------
reg [pSeqCntWidth-1:0] sequence_counter;

// -----------------------------------------------------------------------------
// register data going out of block
// -----------------------------------------------------------------------------
always @(posedge tx_coreclk)
  begin
  if(reset)
    begin
    gt_txcharisk <= {pLaneByteWidth{pSymbol}};
    gt_txdata    <= {pLaneByteWidth{pK_is_k}};
    end
  else
    begin
    case(data_generate_enable)
        
    4'h0 : begin
           gt_txcharisk <= {pLaneByteWidth{pSymbol}};
           gt_txdata    <= {pLaneByteWidth{pK_is_k}};
           end
    4'h1 : begin
           gt_txcharisk <= {pLaneByteWidth{pSymbol}};
           gt_txdata    <= {pLaneByteWidth{pK_is_k}};
           end
    4'h2 : begin
           gt_txcharisk <= {pLaneByteWidth{1'd0}};
           //gt_txdata    <= {pLaneByteWidth{{pLaneByteWidth{1'd0}},sequence_counter}};
           gt_txdata    <= {pLaneByteWidth{sequence_counter}};
           end
    4'h6 : begin
           gt_txcharisk <= {{pLaneByteWidth - 1{pData}},pSymbol};
           gt_txdata    <= {{pLaneByteWidth - 1{8'd0}},pK_is_r};
           end
    4'hA : begin
           gt_txcharisk <= {pSymbol,{pLaneByteWidth - 1{pData}}};
           gt_txdata    <= {pK_is_a,{pLaneByteWidth - 1{8'd0}}};
           end
    default : begin
           gt_txcharisk <= gt_txcharisk;
           gt_txdata    <= gt_txdata;
           end
    endcase
    end
  end  

// -----------------------------------------------------------------------------
// flag when data all one
// -----------------------------------------------------------------------------
always @(posedge tx_coreclk)begin
   data_gen_all_one <= (&gt_txdata);
end

// -----------------------------------------------------------------------------
// Used to Generate a rolling data sequence
// -----------------------------------------------------------------------------
always @(posedge tx_coreclk) begin
   if(reset) begin
     sequence_counter <= 'd0;
   end else begin
      if(data_generate_enable[1] == 1) begin
         sequence_counter <= sequence_counter + 'd1;
      end
   end
end

endmodule
