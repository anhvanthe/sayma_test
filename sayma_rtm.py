#!/usr/bin/env python3
import sys
sys.path.append("gateware") # FIXME

from migen import *
from migen.genlib.resetsync import AsyncResetSynchronizer

from migen.build.generic_platform import *
from migen.build.xilinx import XilinxPlatform

from misoc.integration.soc_core import *
from misoc.integration.builder import *
from misoc.interconnect.csr import *
from misoc.interconnect import stream
from misoc.interconnect import wishbone


from serwb.phy import SERWBPLL, SERWBPHY
from serwb.core import SERWBCore


_io = [
    # clock
    ("clk50", 0, Pins("E15"), IOStandard("LVCMOS25")),

    # serial
    ("serial", 0,
        Subsignal("tx", Pins("C16")),
        Subsignal("rx", Pins("B17")),
        IOStandard("LVCMOS25")
    ),

    # serwb
    ("serwb", 0,
        Subsignal("clk_p", Pins("R18")), # rtm_fpga_usr_io_p
        Subsignal("clk_n", Pins("T18")), # rtm_fpga_usr_io_n
        Subsignal("tx_p", Pins("T17")), # rtm_fpga_lvds2_p
        Subsignal("tx_n", Pins("U17")), # rtm_fpga_lvds2_n
        Subsignal("rx_p", Pins("R16")), # rtm_fpga_lvds1_p
        Subsignal("rx_n", Pins("R17")), # rtm_fpga_lvds1_n
        IOStandard("LVDS_25")
    ),
]


class Platform(XilinxPlatform):
    default_clk_name = "clk50"
    default_clk_period = 20.0

    def __init__(self):
        XilinxPlatform.__init__(self, "xc7a15t-csg325-1", _io,
            toolchain="vivado")


class _CRG(Module):
    def __init__(self, platform):
        self.clock_domains.cd_sys = ClockDomain()
        self.clock_domains.cd_clk200 = ClockDomain()

        clk50 = platform.request("clk50")
        self.reset = Signal()

        pll_locked = Signal()
        pll_fb = Signal()
        pll_sys = Signal()
        pll_clk200 = Signal()
        self.specials += [
            Instance("PLLE2_BASE",
                     p_STARTUP_WAIT="FALSE", o_LOCKED=pll_locked,

                     # VCO @ 1GHz
                     p_REF_JITTER1=0.01, p_CLKIN1_PERIOD=20.0,
                     p_CLKFBOUT_MULT=20, p_DIVCLK_DIVIDE=1,
                     i_CLKIN1=clk50, i_CLKFBIN=pll_fb, o_CLKFBOUT=pll_fb,

                     # 125MHz
                     p_CLKOUT0_DIVIDE=8, p_CLKOUT0_PHASE=0.0, o_CLKOUT0=pll_sys,

                     # 200MHz
                     p_CLKOUT3_DIVIDE=5, p_CLKOUT3_PHASE=0.0, o_CLKOUT3=pll_clk200
            ),
            Instance("BUFG", i_I=pll_sys, o_O=self.cd_sys.clk),
            Instance("BUFG", i_I=pll_clk200, o_O=self.cd_clk200.clk),
            AsyncResetSynchronizer(self.cd_sys, ~pll_locked | self.reset),
            AsyncResetSynchronizer(self.cd_clk200, ~pll_locked | self.reset)
        ]

        reset_counter = Signal(4, reset=15)
        ic_reset = Signal(reset=1)
        self.sync.clk200 += \
            If(reset_counter != 0,
                reset_counter.eq(reset_counter - 1)
            ).Else(
                ic_reset.eq(0)
            )
        self.specials += Instance("IDELAYCTRL", i_REFCLK=ClockSignal("clk200"), i_RST=ic_reset)


class SERWBTestSoC(SoCCore):
    mem_map = {
        "serwb": 0x20000000,  # (default shadow @0xa0000000)
    }
    mem_map.update(SoCCore.mem_map)

    def __init__(self, platform):
        clk_freq = int(125e6)
        SoCCore.__init__(self, platform, clk_freq,
            integrated_rom_size=0x8000,
            integrated_sram_size=0x8000,
            ident="Sayma RTM / AMC <--> RTM Link Test Design"
        )
        self.csr_devices += ["serwb_control"]

        self.submodules.crg = _CRG(platform)
        self.crg.cd_sys.clk.attr.add("keep")
        platform.add_period_constraint(self.crg.cd_sys.clk, 8.0)

        # amc rtm link
        serwb_pll = SERWBPLL(125e6, 1.25e9, vco_div=1)
        self.submodules += serwb_pll

        serwb_phy = SERWBPHY(platform.device, serwb_pll, platform.request("serwb"), mode="slave")
        self.submodules.serwb_phy = serwb_phy
        self.comb += self.crg.reset.eq(serwb_phy.init.reset)

        serwb_phy.serdes.cd_serdes.clk.attr.add("keep")
        serwb_phy.serdes.cd_serdes_20x.clk.attr.add("keep")
        serwb_phy.serdes.cd_serdes_5x.clk.attr.add("keep")
        platform.add_period_constraint(serwb_phy.serdes.cd_serdes.clk, 32.0),
        platform.add_period_constraint(serwb_phy.serdes.cd_serdes_20x.clk, 1.6),
        platform.add_period_constraint(serwb_phy.serdes.cd_serdes_5x.clk, 6.4)
        self.platform.add_false_path_constraints(
            self.crg.cd_sys.clk,
            serwb_phy.serdes.cd_serdes.clk,
            serwb_phy.serdes.cd_serdes_5x.clk)


        # wishbone master
        serwb_core = SERWBCore(serwb_phy, clk_freq, mode="master")
        self.submodules += serwb_core
        self.add_wb_master(serwb_core.etherbone.wishbone.bus)

        # wishbone test memory
        self.submodules.serwb_sram = wishbone.SRAM(8192, init=[i for i in range(8192//4)])
        self.register_mem("serwb_sram", self.mem_map["serwb"], 8192, self.serwb_sram.bus)


def main():
    platform = Platform()
    if len(sys.argv) < 2:
        print("missing target (serwb)")
        exit()
    if sys.argv[1] == "serwb":
        soc = SERWBTestSoC(platform)
    builder = Builder(soc, output_dir="build_sayma_rtm")
    vns = builder.build()


if __name__ == "__main__":
    main()
