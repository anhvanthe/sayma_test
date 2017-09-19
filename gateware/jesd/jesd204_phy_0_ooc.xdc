# This constraints file contains default clock frequencies to be used during out-of-context flows such as
# OOC Synthesis and Hierarchical Designs. For best results the frequencies should be modified
# to match the target frequencies.
# This constraints file is not used in normal top-down synthesis (the default flow of Vivado)

#######################################################################
# Clock frequencies for OOC flow - maximum supported                  #
#######################################################################

# Set DRP Clock to 100.0MHz
create_clock -period 10.000 [get_ports drpclk]

# Set AXI Clock to 100.0MHz
create_clock -period 10.000 [get_ports s_axi_aclk]

# Set tx_coreclk to 125.00MHz
create_clock -period 8.000 [get_ports tx_core_clk]
# Set rx_coreclk to 125.00MHz
create_clock -period 8.000 [get_ports rx_core_clk]
# Set QPLL0 Reference Clock to 125MHz
create_clock -period 8.000  [get_ports qpll0_refclk]


