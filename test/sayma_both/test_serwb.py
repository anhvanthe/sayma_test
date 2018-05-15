#!/usr/bin/env python3

import sys
import time

from litex.soc.tools.remote import RemoteClient

from litescope.software.driver.analyzer import LiteScopeAnalyzerDriver

wb_amc = RemoteClient(port=1234, csr_csv="../sayma_amc/csr.csv", debug=False)
wb_rtm = RemoteClient(port=1235, csr_csv="../sayma_rtm/csr.csv", debug=False)
wb_amc.open()
wb_rtm.open()

# # #

def seed_to_data(seed, random=True):
    if random:
        return (1664525*seed + 1013904223) & 0xffffffff
    else:
        return seed

def write_pattern(length):
    for i in range(length):
        wb_amc.write(wb_amc.mems.serwb.base + 4*i, seed_to_data(i))

def check_pattern(length, debug=False):
    errors = 0
    for i in range(length):
        error = 0
        read_data = wb_amc.read(wb_amc.mems.serwb.base + 4*i)
        if read_data != seed_to_data(i):
            error = 1
            if debug:
                print("{}: 0x{:08x}, 0x{:08x}   KO".format(i, read_data, seed_to_data(i)))
        else:
            if debug:
                print("{}: 0x{:08x}, 0x{:08x} OK".format(i, read_data, seed_to_data(i)))
        errors += error
    return errors

if len(sys.argv) < 2:
    print("missing test (init, prbs, scrambling, wishbone, analyzer)")
    wb.close()
    exit()

if sys.argv[1] == "init":
    wb_amc.regs.serwb_phy_control_reset.write(1)
    timeout = 100
    print("SERWB init", end="")
    while (wb_amc.regs.serwb_phy_control_ready.read() == 0 and
           wb_amc.regs.serwb_phy_control_error.read() == 0 and
           timeout > 0):
        time.sleep(0.1)
        print(".", end="")
        sys.stdout.flush()
        timeout -= 1
    print("")
    print("AMC configuration")
    print("-----------------")
    if hasattr(wb_amc.regs, "serwb_phy_control_delay_min_founds"):
    	print("delay_min_found: {:d}".format(wb_amc.regs.serwb_phy_control_delay_min_found.read()))
    	print("delay_min: {:d}".format(wb_amc.regs.serwb_phy_control_delay_min.read()))
    	print("delay_max_found: {:d}".format(wb_amc.regs.serwb_phy_control_delay_max_found.read()))
    	print("delay_max: {:d}".format(wb_amc.regs.serwb_phy_control_delay_max.read()))    
    	print("delay: {:d}".format(wb_amc.regs.serwb_phy_control_delay.read()))
    print("bitslip: {:d}".format(wb_amc.regs.serwb_phy_control_bitslip.read()))
    print("ready: {:d}".format(wb_amc.regs.serwb_phy_control_ready.read()))
    print("error: {:d}".format(wb_amc.regs.serwb_phy_control_error.read()))
    print("")
    print("RTM configuration")
    print("-----------------")
    if hasattr(wb_rtm.regs, "serwb_phy_control_delay_min_found"):
    	print("delay_min_found: {:d}".format(wb_rtm.regs.serwb_phy_control_delay_min_found.read()))
    	print("delay_min: {:d}".format(wb_rtm.regs.serwb_phy_control_delay_min.read()))
    	print("delay_max_found: {:d}".format(wb_rtm.regs.serwb_phy_control_delay_max_found.read()))
    	print("delay_max: {:d}".format(wb_rtm.regs.serwb_phy_control_delay_max.read()))    
    	print("delay: {:d}".format(wb_rtm.regs.serwb_phy_control_delay.read()))
    print("bitslip: {:d}".format(wb_rtm.regs.serwb_phy_control_bitslip.read()))
    print("ready: {:d}".format(wb_rtm.regs.serwb_phy_control_ready.read()))
    print("error: {:d}".format(wb_rtm.regs.serwb_phy_control_error.read()))

elif sys.argv[1] == "prbs":
    print("PRBS Slave to Master test:")
    wb_amc.regs.serwb_phy_control_prbs_cycles.write(int(1e6))
    wb_amc.regs.serwb_phy_control_prbs_start.write(1)
    #check_pattern(1, debug=False) # error injecton
    time.sleep(1)
    print("errors : %d" %wb_amc.regs.serwb_phy_control_prbs_errors.read())

    print("PRBS Master to Slave test:")
    wb_rtm.regs.serwb_phy_control_prbs_cycles.write(int(1e6))
    wb_rtm.regs.serwb_phy_control_prbs_start.write(1)
    #check_pattern(1, debug=False) # error injecton
    time.sleep(1)
    print("errors : %d" %wb_rtm.regs.serwb_phy_control_prbs_errors.read())

elif sys.argv[1] == "scrambling":
    if wb_amc.regs.serwb_phy_control_scrambling_enable.read():
        print("Disabling scrambling")
        wb_rtm.regs.serwb_phy_control_scrambling_enable.write(0)
        wb_amc.regs.serwb_phy_control_scrambling_enable.write(0)
    else:
        print("Enabling scrambling")
        wb_rtm.regs.serwb_phy_control_scrambling_enable.write(1)
        wb_amc.regs.serwb_phy_control_scrambling_enable.write(1)

elif sys.argv[1] == "wishbone":
    write_pattern(128)
    errors = check_pattern(128, debug=True)
    print("errors: {:d}".format(errors))
elif sys.argv[1] == "dump":
    for i in range(32):
        print("{:08x}".format(wb_amc.read(wb_amc.mems.serwb.base + 4*i)))
elif sys.argv[1] == "analyzer_rtm":
    analyzer = LiteScopeAnalyzerDriver(wb_rtm.regs, "analyzer", config_csv="../sayma_rtm/analyzer.csv", debug=True)
    analyzer.configure_trigger(cond={"soc_activity" : 1})
    analyzer.run(offset=32, length=128)

    time.sleep(1)
    #wb_amc.regs.serwb_test_do_write.write(1)
    wb_amc.regs.serwb_test_do_read.write(1)

    analyzer.wait_done()
    analyzer.upload()
    analyzer.save("dump.vcd")
else:
    raise ValueError

# # #

wb_amc.close()
wb_rtm.close()
