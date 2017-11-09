#!/usr/bin/env python3
import sys
sys.path.append("gateware") # FIXME

from litex.gen import *
from litex.soc.interconnect.csr import *
from litex.gen.genlib.resetsync import AsyncResetSynchronizer

from litex.build.generic_platform import *
from litex.build.xilinx import XilinxPlatform

from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.uart import UARTWishboneBridge
from litex.soc.cores.spi import SPIMaster
from litex.soc.cores.gpio import GPIOOut
from litex.soc.interconnect import stream
from litex.soc.interconnect import wishbone

from liteiclink.serwb.phy import SERWBPLL, SERWBPHY
from liteiclink.serwb.core import SERWBCore

from litescope import LiteScopeAnalyzer


_io = [
    # clock
    ("clk50", 0, Pins("E15"), IOStandard("LVCMOS25")),

    # serial
    ("serial", 0,
        Subsignal("tx", Pins("C16")),
        Subsignal("rx", Pins("B17")),
        IOStandard("LVCMOS25")
    ),

    # hmc (830 and 7043)
    ("hmc_spi", 0,
        Subsignal("clk", Pins("A17")),
        Subsignal("mosi", Pins("B16")),
        Subsignal("miso", Pins("D9")),
        IOStandard("LVCMOS25")
    ),
    ("hmc830_spi_cs", 0, Pins("C8"), IOStandard("LVCMOS25")),
    ("hmc7043_spi_cs", 0, Pins("D16"), IOStandard("LVCMOS25")),
    ("hmc7043_reset", 0, Pins("E17"), IOStandard("LVCMOS25")),

    # clock mux
    ("clk_src_ext_sel", 0, Pins("P15"), IOStandard("LVCMOS25")),
    ("ref_clk_src_sel", 0, Pins("J14"), IOStandard("LVCMOS25")),
    ("dac_clk_src_sel", 0, Pins("P16"), IOStandard("LVCMOS25")),

    # dac
    ("dac_rst_n", 0, Pins("U15"), IOStandard("LVCMOS25")),

    # dac 0
    ("dac0_spi", 0,
        Subsignal("clk", Pins("T13")),
        Subsignal("cs_n", Pins("U14")),
        Subsignal("mosi", Pins("V17")),
        Subsignal("miso", Pins("R13")),
        IOStandard("LVCMOS25")
    ),
    ("dac0_txen", 0, Pins("V16 U16"), IOStandard("LVCMOS25")),

    # dac 1
    ("dac1_spi", 0,
        Subsignal("clk", Pins("J15")),
        Subsignal("cs_n", Pins("K18")),
        Subsignal("mosi", Pins("J18")),
        Subsignal("miso", Pins("J16")),
        IOStandard("LVCMOS25")
    ),
    ("dac1_txen", 0, Pins("L17 L14"), IOStandard("LVCMOS25")),

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

    ("mezz_io", 0, Pins("P1 M4 N4 N3 N2 P4 P3 R2 R1 R3 T2 U2 U1 V3 V2 T4"), IOStandard("LVCMOS25")),
    ("mezz_io", 1, Pins("T3 U4 V4 P6 P5 U6 U5 R5 T5 R7 T7 U7 V6 V8 V7 R6"), IOStandard("LVCMOS25")),
    ("mezz_io", 2, Pins("D11 C12 B12 A12 A13 A14 C14 B15 B14 A15 D13 C13 E13 D14 D15 E16"), IOStandard("LVCMOS25")),
    ("mezz_io", 3, Pins("K5 J5 J4 K2 K1 K3 L2 L4 L3 L5 M5 M2 M1 M6 N6 N1"), IOStandard("LVCMOS25")),
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


def _build_version(with_time=True):
    import datetime
    import time
    if with_time:
        return datetime.datetime.fromtimestamp(
                time.time()).strftime("%Y-%m-%d %H:%M:%S")
    else:
        return datetime.datetime.fromtimestamp(
                time.time()).strftime("%Y-%m-%d")


class JESDTestSoC(SoCCore):
    csr_map = {
        "hmc_spi":          20,
        "hmc_spi_sel":      21,
        "dac_reset":        22,
        "clk_src_ext_sel":  23,
        "ref_clk_src_sel":  24,
        "dac_clk_src_sel":  25,
        "dac0_spi":         26,
        "dac1_spi":         27,
        "mezz0_io":         28,
        "mezz1_io":         29,
        "mezz2_io":         30,
        "mezz3_io":         31,
        "analyzer":         40,
    }
    csr_map.update(SoCCore.csr_map)

    def __init__(self, platform):
        clk_freq = int(125e6)
        SoCCore.__init__(self, platform, clk_freq,
            cpu_type=None,
            csr_data_width=32, csr_address_width=15,
            with_uart=False,
            ident="Sayma RTM JESD Test Design " + _build_version(),
            with_timer=False
        )
        self.submodules.crg = _CRG(platform)

        # uart <--> wishbone
        self.add_cpu_or_bridge(UARTWishboneBridge(platform.request("serial"),
                                                  clk_freq, baudrate=115200))
        self.add_wb_master(self.cpu_or_bridge.wishbone)

        # clock muxes
        self.submodules.clk_src_ext_sel = GPIOOut(platform.request("clk_src_ext_sel"))
        self.submodules.ref_clk_src_sel = GPIOOut(platform.request("ref_clk_src_sel"))
        self.submodules.dac_clk_src_sel = GPIOOut(platform.request("dac_clk_src_sel"))

        # hmc spi
        hmc_spi_pads = platform.request("hmc_spi")
        self.submodules.hmc_spi = SPIMaster(hmc_spi_pads)
        hmc830_spi_cs = platform.request("hmc830_spi_cs")
        hmc7043_spi_cs = platform.request("hmc7043_spi_cs")
        hmc_spi_sel = Signal()
        self.submodules.hmc_spi_sel = GPIOOut(hmc_spi_sel)
        self.comb += [
            If(hmc_spi_sel,
                hmc830_spi_cs.eq(0),
                hmc7043_spi_cs.eq(self.hmc_spi.core.cs_n)
            ).Else(
                hmc830_spi_cs.eq(~self.hmc_spi.core.cs_n),
                hmc7043_spi_cs.eq(1)
            ),
            platform.request("hmc7043_reset").eq(0)
        ]

        # dac_rst_n
        self.submodules.dac_reset = GPIOOut(platform.request("dac_rst_n"))

        # dac0 spi
        dac0_spi_pads = platform.request("dac0_spi")
        self.submodules.dac0_spi = SPIMaster(dac0_spi_pads)

        # dac0 control
        self.comb += platform.request("dac0_txen").eq(0b11)

        # dac1 spi
        dac1_spi_pads = platform.request("dac1_spi")
        self.submodules.dac1_spi = SPIMaster(dac1_spi_pads)

        # dac1 control
        self.comb += platform.request("dac1_txen").eq(0b11)

        # mezz control
        self.submodules.mezz0_io = GPIOOut(platform.request("mezz_io", 0))
        self.submodules.mezz1_io = GPIOOut(platform.request("mezz_io", 1))
        self.submodules.mezz2_io = GPIOOut(platform.request("mezz_io", 2))
        self.submodules.mezz3_io = GPIOOut(platform.request("mezz_io", 3))

        # analyzer
        hmc_spi_group = [
            hmc_spi_pads.clk,
            hmc_spi_pads.mosi,
            hmc_spi_pads.miso,
            hmc830_spi_cs,
            hmc7043_spi_cs
        ]
        dac0_spi_group = [
            dac0_spi_pads.clk,
            dac0_spi_pads.mosi,
            dac0_spi_pads.miso,
            dac0_spi_pads.cs_n
        ]
        dac1_spi_group = [
            dac1_spi_pads.clk,
            dac1_spi_pads.mosi,
            dac1_spi_pads.miso,
            dac1_spi_pads.cs_n
        ]
        analyzer_signals = {
            0 : hmc_spi_group,
            1 : dac0_spi_group,
            2 : dac1_spi_group
        }

        self.submodules.analyzer = LiteScopeAnalyzer(analyzer_signals, 8192)

    def do_exit(self, vns):
        if hasattr(self, "analyzer"):
            self.analyzer.export_csv(vns, "test/sayma_rtm/analyzer.csv")



class SERWBTestSoC(SoCCore):
    csr_map = {
        "serwb_phy": 20,
        "analyzer":  30
    }
    csr_map.update(SoCCore.csr_map)

    mem_map = {
        "serwb": 0x30000000,
    }
    mem_map.update(SoCCore.mem_map)

    def __init__(self, platform, with_analyzer=False):
        clk_freq = int(125e6)
        SoCCore.__init__(self, platform, clk_freq,
            cpu_type=None,
            csr_data_width=32,
            with_uart=False,
            ident="Sayma RTM / AMC <--> RTM SERWB Link Test Design " + _build_version(),
            with_timer=False
        )
        self.submodules.crg = _CRG(platform)

        # uart <--> wishbone
        self.add_cpu_or_bridge(UARTWishboneBridge(platform.request("serial"),
                                                  clk_freq, baudrate=115200))
        self.add_wb_master(self.cpu_or_bridge.wishbone)

        self.crg.cd_sys.clk.attr.add("keep")
        platform.add_period_constraint(self.crg.cd_sys.clk, 8.0)

        # amc rtm link
        serwb_pll = SERWBPLL(125e6, 1.25e9, vco_div=1)
        self.submodules += serwb_pll

        serwb_phy = SERWBPHY(platform.device, serwb_pll, platform.request("serwb"), mode="slave")
        self.submodules.serwb_phy = serwb_phy
        self.comb += self.crg.reset.eq(serwb_phy.init.reset)

        serwb_phy.serdes.cd_serwb_serdes.clk.attr.add("keep")
        serwb_phy.serdes.cd_serwb_serdes_20x.clk.attr.add("keep")
        serwb_phy.serdes.cd_serwb_serdes_5x.clk.attr.add("keep")
        platform.add_period_constraint(serwb_phy.serdes.cd_serwb_serdes.clk, 1e9/31.25e6),
        platform.add_period_constraint(serwb_phy.serdes.cd_serwb_serdes_20x.clk, 1e9/625e6),
        platform.add_period_constraint(serwb_phy.serdes.cd_serwb_serdes_5x.clk, 1e9/156.25e6)
        self.platform.add_false_path_constraints(
            self.crg.cd_sys.clk,
            serwb_phy.serdes.cd_serwb_serdes.clk,
            serwb_phy.serdes.cd_serwb_serdes_5x.clk,
            serwb_phy.serdes.cd_serwb_serdes_20x.clk)

        # wishbone master
        serwb_core = SERWBCore(serwb_phy, clk_freq, mode="master")
        self.submodules += serwb_core
        self.add_wb_master(serwb_core.etherbone.wishbone.bus)

        # wishbone test memory
        self.submodules.serwb_sram = wishbone.SRAM(8192, init=[i for i in range(8192//4)])
        self.register_mem("serwb_sram", self.mem_map["serwb"], self.serwb_sram.bus, 8192)

        # analyzer
        if with_analyzer:
            wishbone_access = Signal()
            self.comb += wishbone_access.eq((serwb_phy.serdes.decoders[0].d == 0xa5) |
                                            (serwb_phy.serdes.decoders[1].d == 0x5a))
            init_group = [
                wishbone_access,
                serwb_phy.init.ready,
                serwb_phy.init.error,
                serwb_phy.init.delay_min,
                serwb_phy.init.delay_max,
                serwb_phy.init.delay,
                serwb_phy.init.bitslip
            ]
            serdes_group = [
                wishbone_access,
                serwb_phy.serdes.encoder.k[0],
                serwb_phy.serdes.encoder.d[0],
                serwb_phy.serdes.encoder.k[1],
                serwb_phy.serdes.encoder.d[1],
                serwb_phy.serdes.encoder.k[2],
                serwb_phy.serdes.encoder.d[2],
                serwb_phy.serdes.encoder.k[3],
                serwb_phy.serdes.encoder.d[3],

                serwb_phy.serdes.decoders[0].d,
                serwb_phy.serdes.decoders[0].k,
                serwb_phy.serdes.decoders[1].d,
                serwb_phy.serdes.decoders[1].k,
                serwb_phy.serdes.decoders[2].d,
                serwb_phy.serdes.decoders[2].k,
                serwb_phy.serdes.decoders[3].d,
                serwb_phy.serdes.decoders[3].k,
            ]
            etherbone_source_group = [
                wishbone_access,
                serwb_core.etherbone.wishbone.source
            ]
            etherbone_sink_group = [
                wishbone_access,
                serwb_core.etherbone.wishbone.sink
            ]
            wishbone_group = [
                wishbone_access,
                serwb_core.etherbone.wishbone.bus
            ]
            analyzer_signals = {
                0 : init_group,
                1 : serdes_group,
                2 : etherbone_source_group,
                3 : etherbone_sink_group,
                4 : wishbone_group
            }
            self.submodules.analyzer = LiteScopeAnalyzer(analyzer_signals, 128, cd="sys")

    def do_exit(self, vns):
        if hasattr(self, "analyzer"):
            self.analyzer.export_csv(vns, "test/sayma_rtm/analyzer.csv")


def main():
    platform = Platform()
    compile_gateware = True
    if len(sys.argv) < 2:
        print("missing target (jesd or serwb)")
        exit()
    if sys.argv[1] == "jesd":
        soc = JESDTestSoC(platform)
    elif sys.argv[1] == "serwb":
        soc = SERWBTestSoC(platform)
    builder = Builder(soc, output_dir="build_sayma_rtm", csr_csv="test/sayma_rtm/csr.csv",
        compile_gateware=compile_gateware)
    vns = builder.build()
    soc.do_exit(vns)


if __name__ == "__main__":
    main()
