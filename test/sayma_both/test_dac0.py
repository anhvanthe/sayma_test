#!/usr/bin/env python3

from litex.soc.tools.remote import RemoteClient

from litejesd204b.common import *

from libbase.ad9154 import *

wb_amc = RemoteClient(port=1234, csr_csv="../sayma_amc/csr.csv", debug=False)
wb_rtm = RemoteClient(port=1235, csr_csv="../sayma_rtm/csr.csv", debug=False)
wb_amc.open()
wb_rtm.open()

# # #

# jesd settings
ps = JESD204BPhysicalSettings(l=8, m=4, n=16, np=16)
ts = JESD204BTransportSettings(f=2, s=2, k=16, cs=0)
jesd_settings = JESD204BSettings(ps, ts, did=0x5a, bid=0x5)

# reset dacs
wb_rtm.regs.dac_reset_out.write(0)
wb_rtm.regs.dac_reset_out.write(1)

time.sleep(1)

# configure dac0
dac0 = AD9154(wb_rtm.regs, 0)
dac0.reset()
print("dac0 configuration")
print("dac0 present: {:s}".format(str(dac0.check_presence())))
dac0.startup(jesd_settings, linerate=10e9)
# show dac0 status
dac0.print_status()

# release/reset jesd core
wb_amc.regs.dac0_control_prbs_config.write(0)
wb_amc.regs.dac0_control_enable.write(0)
time.sleep(1)
wb_amc.regs.dac0_control_enable.write(1)

time.sleep(1)

# show dac0 status
dac0.print_status()

# # #

wb_amc.close()
wb_rtm.close()
