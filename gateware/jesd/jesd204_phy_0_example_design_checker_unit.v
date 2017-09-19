//----------------------------------------------------------------------------
// Title : Example Design Top Level
// Project : JESD204_phy
//----------------------------------------------------------------------------
// File : jesd204_phy_0_example_design_checker_unit.v
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

module jesd204_phy_0_example_design_checker_unit  #(
  parameter  pLaneByteWidth = 4,
  parameter  pLaneWidth     = (pLaneByteWidth * 8)
) (

  input   [31:0] gt_rxdata,           // input wire [31:0] gt_rxdata
  input    [3:0] gt_rxcharisk,        // input wire  [3:0] gt_rxcharisk
  input    [3:0] gt_rxdisperr,        // input wire  [3:0] gt_rxdisperr
  input    [3:0] gt_rxnotintable,     // input wire  [3:0] gt_rxnotintable
  
  input          reset,
  input          rx_coreclk,
  input          data_check_enable,
  output reg [1:0]  sel_out=0,
  output reg     data_check_all_one,
  output reg     data_check_error
  
  );
  
//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
localparam pSM_ERROR_IDLE        = 0;
localparam pSM_ERROR_GOTCOMMAEND = 1;
localparam pSM_ERROR_WAIT        = 2;
localparam pSM_ERROR_CHECK       = 3;
localparam pSM_ERROR_SEEN        = 4;

//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
wire [63:0] two_samples_data;
wire [7:0]  two_samples_cisk;
wire        commas;
reg         commas_r;

reg  [7:0]  expected_value=0;
reg  [2:0]  error_valid_sm=0;

reg [31:0]  gt_rxdata_r;
reg  [3:0]  gt_rxcharisk_r;
reg  [7:0]  char_is_k;

reg [31:0]  data_out=0;
reg  [3:0]  char_out=0;

wire        comma_end;
wire        incoming_good;
reg         incoming_good_r;

// Register these decisions to break a critical path in locking the output
// select of the 8 byte data path.
reg  [7:0]  char_is_k_r;
reg         comma_end_r;

//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
assign two_samples_data = {gt_rxdata, gt_rxdata_r};
assign two_samples_cisk = {gt_rxcharisk, gt_rxcharisk_r};

assign incoming_good    = (~(|gt_rxdisperr)) & (~(|gt_rxnotintable));
assign commas           = (&char_is_k);
assign comma_end        = commas_r & (!commas) & incoming_good_r & incoming_good;

always @(*) begin
   char_is_k[0] = (two_samples_data[7 : 0] == 8'hbc) & (two_samples_cisk[0]);
   char_is_k[1] = (two_samples_data[15: 8] == 8'hbc) & (two_samples_cisk[1]);
   char_is_k[2] = (two_samples_data[23:16] == 8'hbc) & (two_samples_cisk[2]);
   char_is_k[3] = (two_samples_data[31:24] == 8'hbc) & (two_samples_cisk[3]);
   char_is_k[4] = (two_samples_data[39:32] == 8'hbc) & (two_samples_cisk[4]);
   char_is_k[5] = (two_samples_data[47:40] == 8'hbc) & (two_samples_cisk[5]);
   char_is_k[6] = (two_samples_data[55:48] == 8'hbc) & (two_samples_cisk[6]);
   char_is_k[7] = (two_samples_data[63:56] == 8'hbc) & (two_samples_cisk[7]);   
   end

always @(posedge rx_coreclk) begin
  comma_end_r <= comma_end;
  char_is_k_r <= char_is_k;
end

// We can afford to delay this decision by one cycle, if we also select delay
// the select value. This is a critical path due to the decision
// being made on the data coming from the GT, which is then used to select the
// output value.
always @(posedge rx_coreclk)
  if(comma_end_r)
     case(char_is_k_r[7:4])
     4'b0111:sel_out<=3;
     4'b0011:sel_out<=2;
     4'b0001:sel_out<=1;
     4'b0000:sel_out<=0;
     default:sel_out<=sel_out;
     endcase

always @(posedge rx_coreclk)
   case(sel_out)
   3:begin
     data_out <= two_samples_data[55: 24];
     char_out <= two_samples_cisk[6 : 3 ];
     end
   2:begin
     data_out <= two_samples_data[47: 16];
     char_out <= two_samples_cisk[5 : 2 ];
     end
   1:begin
     data_out <= two_samples_data[39: 8 ];
     char_out <= two_samples_cisk[4 : 1 ];
     end
   0:begin
     data_out <= two_samples_data[31: 0 ];
     char_out <= two_samples_cisk[3 : 0 ];
     end
   endcase

always @(posedge rx_coreclk)
  begin
  gt_rxdata_r        <= gt_rxdata;
  gt_rxcharisk_r     <= gt_rxcharisk;
  commas_r           <= commas;
  data_check_error   <= error_valid_sm == pSM_ERROR_SEEN;
  incoming_good_r    <= incoming_good;
  data_check_all_one <= &data_out;
  end

always @(posedge rx_coreclk)
    begin
    if(reset | (!data_check_enable))
       expected_value   <= 0;
    else
      if(error_valid_sm == pSM_ERROR_CHECK)
         expected_value <= expected_value + 1;
      else
         expected_value <= data_out[7:0] + 1;
    end
    
always @(posedge rx_coreclk)
    begin
    if(reset | (!data_check_enable))
       error_valid_sm   <= pSM_ERROR_IDLE;
    else
       // State machine control
       case(error_valid_sm)
       pSM_ERROR_IDLE        : begin
          if(comma_end_r)
             error_valid_sm <= pSM_ERROR_GOTCOMMAEND;
       end
       pSM_ERROR_GOTCOMMAEND : error_valid_sm <= pSM_ERROR_WAIT;
       pSM_ERROR_WAIT        : error_valid_sm <= pSM_ERROR_CHECK;
       pSM_ERROR_CHECK       : begin
                               if({4{expected_value}} != data_out)
                                  error_valid_sm <= pSM_ERROR_SEEN;
                               end
       default               : error_valid_sm <= error_valid_sm;
       endcase
    end

endmodule


