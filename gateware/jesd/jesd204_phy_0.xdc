#----------------------------------------------------------------------
# Title      : Constraints for JESD204 PHY
# Project    : jesd204_phy_v3_4_0
#----------------------------------------------------------------------
# File       : jesd204_phy_0_block.xdc
# Author     : Xilinx
#----------------------------------------------------------------------
# Description: Xilinx Constraint file for JESD204 PHY core
#---------------------------------------------------------------------
# (c) Copyright 2004-2014 Xilinx, Inc. All rights reserved.
#
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
#
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
#
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
#
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.
#

##############################################################################################################################################################
# False paths to the DRP clock syncronisers that resync the incoming RX/TX resets. This also covers the path from the AXI domain if used.
##############################################################################################################################################################
#set_false_path -to [get_cells -hier -regexp -filter {name =~ {.*jesd204_phy_0.*sync_[rt]x_reset_(?:data|all)\/data_sync_reg.*} && IS_SEQUENTIAL}]

##############################################################################################################################################################
# TIMING CONSTRAINTS
##############################################################################################################################################################
set_false_path -from [get_cells -hier -filter {name =~ *jesd204_phy_block_i/gtwiz_reset_block_i/gtwiz_reset_*x_done_int_reg* && IS_SEQUENTIAL}]
set_false_path -to [get_cells -hier -filter {name =~ *jesd204_phy_block_i/gtwiz_reset_block_i/bit_synchronizer_gtwiz_reset_userclk_*x_active_inst/i_in_meta_reg* && IS_SEQUENTIAL}]
set_false_path -to [get_cells -hier -filter {name =~ *gtwiz_userclk_*x_active_meta_reg*}]
set_false_path -to [get_cells -hier -filter {name =~ *gtwiz_userclk_*x_active_sync_reg*}]
############### DRP MAILBOX DRP -> AXI  ######################################################################################################################
# report_timing -from *_drpclk -to *_axiclk -unique_pins -setup -path_type summary -max_paths 1000
##############################################################################################################################################################
# This signal is registered and held in the DRP clock domain. It is protected by a handshake across the DRP->AXI
set_false_path -from [get_cells -hier -filter {name =~ *drp*Mailbox_i/drp_read_data_reg* && IS_SEQUENTIAL}]              -to [get_cells -hier -filter {name =~ *axi_register_if_i/axi_rdata_reg* && IS_SEQUENTIAL}]

# this is the path to the read register on the DRP domain. Again access type is stable when required
set_false_path -from [get_cells -hier -filter {name =~ *drp*Mailbox_i/access_type_reg* && IS_SEQUENTIAL}]                -to [get_cells -hier -filter {name =~ *drp*Mailbox_i/drp_read_data_reg* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *drp*Mailbox_i/drp_if_select_reg* && IS_SEQUENTIAL}]              -to [get_cells -hier -filter {name =~ *drp*Mailbox_i/drp_read_data_reg* && IS_SEQUENTIAL}]

# This is the path into the the ready synchronizer. The drp_if_select_reg is stable and used to select the correct DRP RDY signal
set_false_path -from [get_cells -hier -filter {name =~ *drp*Mailbox_i/drp_if_select_reg* && IS_SEQUENTIAL}]              -to [get_cells -hier -filter {name =~ *drp*Mailbox_i/*clk2_ready_reg* && IS_SEQUENTIAL}]


##############################################################################################################################################################
# AXI internal paths
##############################################################################################################################################################

## Transceiver selector path
set gtSelStart   [get_cells -hier -filter {name =~ *phyAxiConfig_i/gt_interface_sel_reg* && IS_SEQUENTIAL}]

############### TX DEBUG CTRL
# report_timing -from *_tx_coreclk -to *_axiclk     -unique_pins -setup -path_type summary -max_paths 1000
# report_timing -from *_axiclk     -to *_tx_coreclk -unique_pins -setup -path_type summary -max_paths 1000
##############################################################################################################################################################
## DRP domain endpoints in TX register bank
set transTxDrpSide [get_cells -hier -regexp -filter {name =~ {.*_transDbgCtrl_tx_i\/(?:txdiffctrl|txin.*hibit|txpolarity|tx_pd).*} && IS_SEQUENTIAL}]

############################# Register signals
set_false_path -from $gtSelStart -to $transTxDrpSide

# AXI register write data, held for xfer to DRP domain registers
set_false_path -from [get_cells -hier -filter {name =~ *_transDbgCtrl_tx_i/slv_wdata_r_internal* && IS_SEQUENTIAL}] -to $transTxDrpSide
# AXI side read strobe
set_false_path -from [get_cells -hier -filter {name =~ *_transDbgCtrl_tx_i/slv_rden_r_reg*       && IS_SEQUENTIAL}] -to $transTxDrpSide
# address selection
set_false_path -from [get_cells -hier -filter {name =~ *axi_register_if_i/slv_addr_reg*          && IS_SEQUENTIAL}] -to $transTxDrpSide

# ank register signals to AXI read register
set_false_path -from $transTxDrpSide -to [get_cells -hier -filter {name =~ *_transDbgCtrl_tx_i/slv_rdata_reg* && IS_SEQUENTIAL}]

############### RX DEBUG CTRL
# report_timing -from *_rx_coreclk -to *_axiclk     -unique_pins -setup -path_type summary -max_paths 1000
# report_timing -from *_axiclk     -to *_rx_coreclk -unique_pins -setup -path_type summary -max_paths 1000
##############################################################################################################################################################
## DRP domain endpoints in RX register bank
set transRxDrpSide [get_cells -hier -regexp -filter {name =~ {.*_transDbgCtrl_rx_i\/(?:rxpolarity|rxlpmen|rxdfelpmreset|rxoshold|rxdfe.*hold).*} && IS_SEQUENTIAL}]

############################# Register signals
set_false_path -from $gtSelStart -to $transRxDrpSide

# AXI register write data, held for xfer to DRP domain registers
set_false_path -from [get_cells -hier -filter {name =~ *_transDbgCtrl_rx_i/slv_wdata_r_internal* && IS_SEQUENTIAL}] -to $transRxDrpSide
# AXI side read strobe
set_false_path -from [get_cells -hier -filter {name =~ *_transDbgCtrl_rx_i/slv_rden_r_reg*       && IS_SEQUENTIAL}] -to $transRxDrpSide
# address selection
set_false_path -from [get_cells -hier -filter {name =~ *axi_register_if_i/slv_addr_reg*          && IS_SEQUENTIAL}] -to $transRxDrpSide

# bank register signals to AXI read register
set_false_path -from $transRxDrpSide -to [get_cells -hier -filter {name =~ *_transDbgCtrl_rx_i/slv_rdata_reg* && IS_SEQUENTIAL}]

set_false_path -from [get_cells -hier -filter {name =~ *_transDbgCtrl_async_i/cpll_cal_per_reg* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *_transDbgCtrl_async_i/cpll_cal_tol_reg* && IS_SEQUENTIAL}]



