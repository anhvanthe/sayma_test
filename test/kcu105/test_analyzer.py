#!/usr/bin/env python3

from litex.soc.tools.remote import RemoteClient

from litescope.software.driver.analyzer import LiteScopeAnalyzerDriver

wb = RemoteClient()
wb.open()

# # #

analyzer = LiteScopeAnalyzerDriver(wb.regs, "analyzer", debug=True)
analyzer.configure_trigger(cond={})
analyzer.configure_subsampler(64)
analyzer.run(offset=16, length=64)
analyzer.wait_done()
analyzer.upload()
analyzer.save("dump.vcd")
analyzer.save("dump.sr")

# # #

wb.close()
