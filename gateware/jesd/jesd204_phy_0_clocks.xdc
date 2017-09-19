#----------------------------------------------------------------------
# Title      : External Clock Constraints for JESD204
# Project    : jesd204_phy_v3_4_0
#----------------------------------------------------------------------
# File       : jesd204_phy_0_clocks.xdc
# Author     : Xilinx
#----------------------------------------------------------------------
# Description: Xilinx Constraint file for JESD204 PHY core
#---------------------------------------------------------------------
# (c) Copyright 2004-2013 Xilinx, Inc. All rights reserved.

# Set Rx Core Clock
set rx_coreclk [get_clocks -of_objects [get_ports rx_core_clk]]
# Set Tx Core Clock
set tx_coreclk [get_clocks -of_objects [get_ports tx_core_clk]]


set_case_analysis 1 [get_pins -hier -filter {name =~ *jesd204_phy_0_gt_i/inst/gen_gtwizard_gt*_top.jesd204_phy_0_gt_gtwizard_gt*_inst/gen_gtwizard_gt*.gen_channel_container*.gen_enabled_channel.gt*_channel_wrapper_inst/channel_inst/gt*_channel_gen.gen_gt*_channel_inst*.GT*_CHANNEL_PRIM_INST/TXPLLCLKSEL[0]}]
set_case_analysis 1 [get_pins -hier -filter {name =~ *jesd204_phy_0_gt_i/inst/gen_gtwizard_gt*_top.jesd204_phy_0_gt_gtwizard_gt*_inst/gen_gtwizard_gt*.gen_channel_container*.gen_enabled_channel.gt*_channel_wrapper_inst/channel_inst/gt*_channel_gen.gen_gt*_channel_inst*.GT*_CHANNEL_PRIM_INST/TXPLLCLKSEL[1]}]
set_case_analysis 0 [get_pins -hier -filter {name =~ *jesd204_phy_0_gt_i/inst/gen_gtwizard_gt*_top.jesd204_phy_0_gt_gtwizard_gt*_inst/gen_gtwizard_gt*.gen_channel_container*.gen_enabled_channel.gt*_channel_wrapper_inst/channel_inst/gt*_channel_gen.gen_gt*_channel_inst*.GT*_CHANNEL_PRIM_INST/TXSYSCLKSEL[0]}]
set_case_analysis 1 [get_pins -hier -filter {name =~ *jesd204_phy_0_gt_i/inst/gen_gtwizard_gt*_top.jesd204_phy_0_gt_gtwizard_gt*_inst/gen_gtwizard_gt*.gen_channel_container*.gen_enabled_channel.gt*_channel_wrapper_inst/channel_inst/gt*_channel_gen.gen_gt*_channel_inst*.GT*_CHANNEL_PRIM_INST/TXSYSCLKSEL[1]}]

set_case_analysis 1 [get_pins -hier -filter {name =~ *jesd204_phy_0_gt_i/inst/gen_gtwizard_gt*_top.jesd204_phy_0_gt_gtwizard_gt*_inst/gen_gtwizard_gt*.gen_channel_container*.gen_enabled_channel.gt*_channel_wrapper_inst/channel_inst/gt*_channel_gen.gen_gt*_channel_inst*.GT*_CHANNEL_PRIM_INST/RXPLLCLKSEL[0]}]
set_case_analysis 1 [get_pins -hier -filter {name =~ *jesd204_phy_0_gt_i/inst/gen_gtwizard_gt*_top.jesd204_phy_0_gt_gtwizard_gt*_inst/gen_gtwizard_gt*.gen_channel_container*.gen_enabled_channel.gt*_channel_wrapper_inst/channel_inst/gt*_channel_gen.gen_gt*_channel_inst*.GT*_CHANNEL_PRIM_INST/RXPLLCLKSEL[1]}]
set_case_analysis 0 [get_pins -hier -filter {name =~ *jesd204_phy_0_gt_i/inst/gen_gtwizard_gt*_top.jesd204_phy_0_gt_gtwizard_gt*_inst/gen_gtwizard_gt*.gen_channel_container*.gen_enabled_channel.gt*_channel_wrapper_inst/channel_inst/gt*_channel_gen.gen_gt*_channel_inst*.GT*_CHANNEL_PRIM_INST/RXSYSCLKSEL[0]}]
set_case_analysis 1 [get_pins -hier -filter {name =~ *jesd204_phy_0_gt_i/inst/gen_gtwizard_gt*_top.jesd204_phy_0_gt_gtwizard_gt*_inst/gen_gtwizard_gt*.gen_channel_container*.gen_enabled_channel.gt*_channel_wrapper_inst/channel_inst/gt*_channel_gen.gen_gt*_channel_inst*.GT*_CHANNEL_PRIM_INST/RXSYSCLKSEL[1]}]

# Set DRP Clock
set drpclk [get_clocks -of_objects [get_ports drpclk]]

# Set AXI Clock
set axiclk [get_clocks -of_objects [get_ports s_axi_aclk]]

# ULTRASCALE GT False paths - COMMON
# ULTRASCALE GT False paths - CHANNEL
set_false_path -from [get_cells -hier -filter {name =~ *drp*Mailbox_i/drp_write_data_reg* && IS_SEQUENTIAL}]       -to [get_clocks -of_objects [get_ports drpclk]]
set_false_path -from [get_cells -hier -filter {name =~ *drp*Mailbox_i/drp_int_addr_reg* && IS_SEQUENTIAL}]         -to [get_clocks -of_objects [get_ports drpclk]]
set_false_path -from [get_cells -hier -filter {name =~ *drp*Mailbox_i/drp_if_select_reg* && IS_SEQUENTIAL}]        -to [get_clocks -of_objects [get_ports drpclk]]
set_false_path -from [get_cells -hier -filter {name =~ *drp*Mailbox_i/access_type_reg* && IS_SEQUENTIAL}]          -to [get_clocks -of_objects [get_ports drpclk]]
set_false_path -from [get_cells -hier -filter {name =~ *drp*Mailbox_i/drp_int_addr_reg* && IS_SEQUENTIAL}]         -to [get_clocks -of_objects [get_ports drpclk]]

set_false_path -from [get_cells -hier -filter {name =~ *_transDbgCtrl_async_i/txpllclksel_reg* && IS_SEQUENTIAL}]  -to [get_clocks -of_objects [get_ports drpclk]]
set_false_path -from [get_cells -hier -filter {name =~ *_transDbgCtrl_async_i/rxpllclksel_reg* && IS_SEQUENTIAL}]  -to [get_clocks -of_objects [get_ports drpclk]]

