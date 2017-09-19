//-----------------------------------------------------------------------------
// Title      : drpCommonMailbox
// Project    : NA
//-----------------------------------------------------------------------------
// File       : drpCommonMailbox.v
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

module jesd204_phy_0_drpCommonMailbox #(
   parameter integer                   C_S_AXI_ADDR_WIDTH    = 11,
   parameter integer                   C_S_DRP_ADDR_WIDTH    = 9,
   parameter integer                   C_S_DRP_TIMEOUT_WIDTH = 9
   ) (
   input                                  s_axi_aclk,
   input                                  s_axi_aresetn,
   
   input                                  s_drp_clk,
   input                                  s_drp_reset,

   input       [7:0]                      cmm_interface_sel,
    
   // DRP interface 0
   output      [C_S_DRP_ADDR_WIDTH-1:0]   drp0_addr,
   output      [15:0]                     drp0_di,
   output                                 drp0_we,
   output                                 drp0_en,
   output                                 drp0_rst,
                                             
   input       [15:0]                     drp0_do,
   input                                  drp0_rdy,

   // basic register interface
   input                                  slv_rden,
   input                                  slv_wren,
   input       [31:0]                     slv_wdata,
   input       [C_S_AXI_ADDR_WIDTH-1:2]   slv_addr,
   
   output                                 slv_rd_done,
   output                                 slv_wr_done,
   output reg  [31:0]                     slv_rdata
 
);

  //----------------------------------------------------------------------------
  // Parameters
  //----------------------------------------------------------------------------
  localparam ADDR_STUFF_ZERO   = 32 - C_S_DRP_ADDR_WIDTH;
  localparam C_S_NUM_DRP_WIDTH = 1;
  
  //----------------------------------------------------------------------------
  // Address map for control logic
  //----------------------------------------------------------------------------
  localparam DRP_IF_SEL        = 0;
  localparam DRP_ADDRESS       = 1;
  localparam DRP_WR_DATA       = 2;
  localparam DRP_RW_DATA       = 3;
  localparam DRP_RESET         = 4;
  localparam DRP_STATUS        = 5;
  localparam DRP_TO_LENGTH     = 6;
  localparam DRP_NO_WAIT       = 7;
  
  //----------------------------------------------------------------------------
  // internal signals
  //----------------------------------------------------------------------------
  reg                               do_write_axi;
  reg                               do_read_axi;
                                    
  wire                              do_write_drp;
  wire                              do_read_drp;
                                  
  reg                               selected_rdy_drp;
  wire                              selected_rdy_axi;
                                    
  // Status flags                   
  reg                               access_type;            // read=0, write=1, clears on complete
  reg                               timeout_flag;           // sticky timeout flag, cleared on new access
  reg                               drp_access_in_progress; // indicates DRP is waiting for a rdy response
  reg                               drp_access_valid;       // DRP access is valid
                                                                        
  reg   [C_S_NUM_DRP_WIDTH-1:0]     drp_if_select;
  reg   [C_S_DRP_ADDR_WIDTH-1:0]    drp_int_addr;
  reg   [15:0]                      drp_write_data;
  reg   [15:0]                      drp_read_data;
  reg                               drp_reset;
  
  reg   [C_S_DRP_TIMEOUT_WIDTH-1:0] timeout_length;
  reg   [C_S_DRP_TIMEOUT_WIDTH-1:0] timeout_counter;
  reg                               wr_req_reg;
  reg                               rd_req_reg;
  reg                               wait_for_drp;

  wire                              clk1_ready_pulse;
  wire                              clk2_valid_pulse;
     
  //----------------------------------------------------------------------------
  // Register write logic
  //----------------------------------------------------------------------------
  always @( posedge s_axi_aclk )
  begin
     if (~s_axi_aresetn) begin
       // set RW register defaults
       drp_if_select           <= 'd0;
       drp_int_addr            <= 'd0;
       drp_write_data          <= 'd0;
       drp_reset               <= 'd0;
       timeout_length          <= 'd0;
       wait_for_drp            <= 'd1;
       
       // Control defaults
       access_type             <= 'd0; 
       timeout_flag            <= 'd0;
       drp_access_in_progress  <= 'd0;
       wr_req_reg              <= 'd0;
       rd_req_reg              <= 'd0;
       drp_access_valid        <= 'd0;
     end 
     else begin
     
        // Keep a copy of this event, we ned to use this to complete a non-drp register 
        // access, the decision can only be made when drp_access_in_progress is valid
        wr_req_reg <= slv_wren;
        rd_req_reg <= slv_rden;
     
        // In the case we use an external selector, we keep it regestered internlly
        // to ensure there are no fanout issues
        drp_if_select <= cmm_interface_sel[C_S_NUM_DRP_WIDTH-1:0];
           
        // Mailbox write interface
        if (slv_wren) begin
           case (slv_addr)
           DRP_ADDRESS   : begin
                           drp_int_addr <= slv_wdata[C_S_DRP_ADDR_WIDTH-1:0];
                           
                           if (slv_wdata[30] ^ slv_wdata[31]) begin
                             // Only update on an actual access initiation
                             access_type    <= slv_wdata[31];
                             timeout_flag   <= 1'd0;
                             drp_access_valid       <= slv_wdata[30] ^ slv_wdata[31];
                             drp_access_in_progress <= slv_wdata[30] ^ slv_wdata[31];
                           end
                           
                           end
           DRP_WR_DATA   : drp_write_data <= slv_wdata[15:0];
           DRP_RESET     : drp_reset      <= slv_wdata[0];
           DRP_TO_LENGTH : timeout_length <= slv_wdata[C_S_DRP_TIMEOUT_WIDTH-1:0];
           DRP_NO_WAIT   : wait_for_drp   <= slv_wdata[0];
           
           endcase
        end
        else begin
          do_write_axi  <= 1'd0;
          do_read_axi   <= 1'd0;
          drp_reset     <= 1'd0;
          
          // DRP COMPLETE logic
          // When the transaction is complete, assuming it was a DRP transaction
          // clear the access in progress, 
          if( clk1_ready_pulse | timeout_flag ) begin
            drp_access_in_progress <= 1'd0;
            
            // We want this to be sticky if there was an error to make life easy for the 
            // firmware
            if(~timeout_flag) begin
              access_type <= 1'd0;
            end
          end

          if( selected_rdy_axi | timeout_flag ) begin
            drp_access_valid <= 1'd0;
          end

        end
     end
  end
   
  //----------------------------------------------------------------------------
  // Register read logic, 
  //---------------------------------------------------------------------------
  always @(*)
    begin
    case (slv_addr)
    DRP_IF_SEL    : slv_rdata = {{C_S_NUM_DRP_WIDTH{1'd0}}, drp_if_select};
    DRP_ADDRESS   : slv_rdata = {{ADDR_STUFF_ZERO{1'd0}}, drp_int_addr};
    DRP_WR_DATA   : slv_rdata = {{16{1'd0}}, drp_write_data};
    DRP_RW_DATA   : slv_rdata = {{16{1'd0}}, drp_read_data};
    DRP_RESET     : slv_rdata = {{31{1'd0}}, drp_reset};
    DRP_STATUS    : slv_rdata = {{29{1'd0}}, access_type, timeout_flag, drp_access_in_progress};
    DRP_TO_LENGTH : slv_rdata = timeout_length;
    DRP_NO_WAIT   : slv_rdata = wait_for_drp;
    default       : slv_rdata = 'd0;
    endcase
    end
          
  //---------------------------------------------------------------------------
  // read done logic
  //---------------------------------------------------------------------------
  assign slv_rd_done = drp_access_in_progress & wait_for_drp ? clk1_ready_pulse : rd_req_reg;
  assign slv_wr_done = drp_access_in_progress & wait_for_drp ? clk1_ready_pulse : wr_req_reg;
  
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  // DRP clock domain handshake
  // 
  // This logic pass's the DRP access request across the clock domain.
  // On the DRP side, a pulse is generated to initialte the DRP access. When
  // The RDY pulse is received, a ready signal is passed back across the clock
  // boundary to the AXI clock domain. This causes the valid request to be
  // removed, and when seen on the DRP domain, the ready is lowered.
  // When the ready falling edge is seen in the AXI domain the AXI transaction
  // is finally completed.
  // Although this logic is slow, it minimises the logic required.
  // It also ensures if the DRP rate is very slow compared to the AXI rate
  // transactions will fully complete before another can be requested, though
  // in the case the user should probally set wait_for_drp low and poll for
  // the DRP completion
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  jesd204_phy_0_phyCoreCtrlInterface_hshk_pls_gen clk2clk_handshake_pulse_gen_i(
   .clk1             (s_axi_aclk              ),
   .clk1_rst         (s_axi_aresetn       ),
   
   .clk1_valid       (drp_access_valid        ), // Access in clk1 requested flag, pass to clk2
   .clk1_ready       (selected_rdy_axi        ), // Access is complete in clk2, lower request in clk1
   .clk1_ready_pulse (clk1_ready_pulse        ), // Pulsed on falling edge of clk1_ready, access complete in clk1 & clk2
   
   .clk2             (s_drp_clk               ),
   .clk2_rst         (s_drp_reset             ),
 
   .clk2_valid       ( ),
   .clk2_valid_pulse (clk2_valid_pulse        ),
   .clk2_ready_pulse (selected_rdy_drp        )
    
  );
 
  // Note that access_type comes direct from an AXI register, 
  // but by design will be stable when the clk2_valid_pulse is generated
  assign do_write_drp = clk2_valid_pulse & (access_type);
  assign do_read_drp  = clk2_valid_pulse & (~access_type);
  
  //----------------------------------------------------------------------------
  // Register read logic on the DRP domain on the rdy pulse
  //---------------------------------------------------------------------------
  always @( posedge s_drp_clk )
    begin
      if (~s_drp_reset) begin
        drp_read_data <= 'd0;
      end
      else begin
        if(selected_rdy_drp & (access_type==0)) begin
          case (drp_if_select)
          'd0   : drp_read_data <= drp0_do;
          default : drp_read_data <= drp0_do; // tie default to one of the if
          endcase
        end
      end
    end
  
  // mux the ready signal from the selected DRP interface
  always @(*)
    begin
    case (drp_if_select)
    'd0       : selected_rdy_drp = drp0_rdy;
    default   : selected_rdy_drp = 1'd0; // tie default to one of the if
    endcase
    end
     
  //---------------------------------------------------------------------------
  // DRP interface 0
  // Note drp_int_addr, drp_write_data, drp_if_select, drp_reset all exist
  // in the AXI domain and must have appropiate constrains for systhesis.
  // This implementation minimised the number of flops required, as this data
  // is static when used for the actual DRP access.
  //---------------------------------------------------------------------------
  assign drp0_addr = drp_int_addr;
  assign drp0_di   = drp_write_data; 
  assign drp0_we   = do_write_drp  & (drp_if_select==0); 
  assign drp0_en   = (do_read_drp | do_write_drp) & (drp_if_select==0); 
  assign drp0_rst  = drp_reset & (drp_if_select==0);
  

endmodule

