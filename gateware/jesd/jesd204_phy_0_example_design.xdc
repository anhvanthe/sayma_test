#----------------------------------------------------------------------
# Title      : Example top level constraints for JESD204 PHY
# Project    : jesd204_phy_v3_4_0
#----------------------------------------------------------------------
# File       : jesd204_phy_0_example_design.xdc
# Author     : Xilinx
#----------------------------------------------------------------------
# Description: Xilinx Constraint file for the example design for
#              JESD204 phy core
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

#------------------------------------------
# TIMING CONSTRAINTS
#------------------------------------------
# Set Transceiver Reference Clock to 125 MHz
create_clock -period 8.000 -name jesd204_phy_0_refclk [get_ports refclk_common_p]
# Set Tx Core Clock to 125.00MHz
create_clock -period 8.000 -name jesd204_phy_0_tx_coreclk [get_ports core_clk_tx_p]

# Set Rx Core Clock to 125.00MHz
create_clock -period 8.000 -name jesd204_phy_0_rx_coreclk [get_ports core_clk_rx_p]

# Set DRP Clock to 100.0 MHz
create_clock -period 10.000 -name jesd204_phy_0_drpclk [get_ports drpclk_in]

# Set AXI Clock to 100.0 MHz
create_clock -period 10.000 -name jesd204_phy_0_axiclk [get_ports s_axi_aclk]


#set_false_path -to [get_cells -hier -filter {name =~ sequencer_i/sync_*xresetdone_*xclk_i/data_sync_reg0 && IS_SEQUENTIAL}]

## These are pesudo LED's that are used to sequence the testbench. 
#set_false_path -to [get_pins -hier -filter {name =~ *sync_*_led_drpclk_i/data_sync_reg0/D}]


############### DRP MAILBOX AXI -> DRP  ######################################################################################################################
# When the common is in the example design, these constrains must be set in the example design as the common is still in the design, just outside the IP core
# Use the following commands to help you add/modify constraints.
# report_timing -from *_axiclk -to *_drpclk -unique_pins -setup -path_type summary -max_paths 1000
# set_msg_config -id {Constraints 18-401} -verbose -limit 100000
# foreach {myStr} [get_pins -hier -regexp -filter {name =~ {.*GTHE3_CHANNEL_PRIM_INST/.*(?:DRPADDR\[|DRPDI\[|DRPWE|DRPEN).*}}] {puts "$myStr"}
##############################################################################################################################################################

