#!/usr/bin/env python3
import sys
sys.path.append("gateware") # FIXME

from migen import *
from migen.genlib.resetsync import AsyncResetSynchronizer

from litex.soc.interconnect.csr import *

from litex.build.generic_platform import *
from litex.build.xilinx import XilinxPlatform

from litex.soc.integration.soc_core import *
from litex.soc.integration.soc_sdram import *
from litex.soc.integration.builder import *
from litex.soc.cores.uart import UARTWishboneBridge
from litex.soc.interconnect import stream
from litex.soc.cores.cordic import Cordic
from litex.soc.interconnect import wishbone

from litedram.modules import MT41J256M16
from litedram.phy import kusddrphy
from litedram.frontend.bist import LiteDRAMBISTGenerator
from litedram.frontend.bist import LiteDRAMBISTChecker

from litejesd204b.common import *
from litejesd204b.phy.gth import GTHQuadPLL as JESD204BGTHQuadPLL
from litejesd204b.phy.gth import GTHChannelPLL as JESD204BGTHChannelPLL
from litejesd204b.phy import LiteJESD204BPhyTX
from litejesd204b.core import LiteJESD204BCoreTX
from litejesd204b.core import LiteJESD204BCoreTXControl

from drtio.gth_ultrascale import *

from liteiclink.serwb.genphy import SERWBPHY
from liteiclink.serwb.core import SERWBCore

from litescope import LiteScopeAnalyzer


_io = [
    # clock
    ("clk50", 0, Pins("AF9"), IOStandard("LVCMOS18")),

    # leds
    ("user_led", 0, Pins("AG9"), IOStandard("LVCMOS18")),
    ("user_led", 1, Pins("AJ10"), IOStandard("LVCMOS18")),
    ("user_led", 2, Pins("AJ13"), IOStandard("LVCMOS18")),
    ("user_led", 3, Pins("AE13"), IOStandard("LVCMOS18")),

    # ios
    ("user_io", 0, Pins("AG11"), IOStandard("LVCMOS18")),
    ("user_io", 1, Pins("AH11"), IOStandard("LVCMOS18")),
    ("user_io", 2, Pins("AJ11"), IOStandard("LVCMOS18")),
    ("user_io", 3, Pins("AG12"), IOStandard("LVCMOS18")),
    ("user_io", 4, Pins("AH12"), IOStandard("LVCMOS18")),
    ("user_io", 5, Pins("AD11"), IOStandard("LVCMOS18")),
    ("user_io", 6, Pins("AE11"), IOStandard("LVCMOS18")),
    ("user_io", 7, Pins("AE12"), IOStandard("LVCMOS18")),

    # serial
    ("serial", 0,
        Subsignal("tx", Pins("AK8")),
        Subsignal("rx", Pins("AL8")),
        IOStandard("LVCMOS18")
    ),
    ("serial", 1,
        Subsignal("tx", Pins("M27")),
        Subsignal("rx", Pins("L27")),
        IOStandard("LVCMOS18")
    ),

    ("usr_uart_p", 1, Pins("H27"), IOStandard("LVCMOS18")),
    ("usr_uart_n", 1, Pins("G27"), IOStandard("LVCMOS18")),

    # sdram
    ("ddram_64", 0,
        Subsignal("a", Pins(
            "AE17 AL17 AG16 AG17 AD16 AH14 AD15 AK15",
            "AF14 AF15 AL18 AL15 AE18 AJ15 AG14"),
            IOStandard("SSTL15_DCI")),
        Subsignal("ba", Pins("AF17 AD19 AD18"), IOStandard("SSTL15_DCI")),
        Subsignal("ras_n", Pins("AH19"), IOStandard("SSTL15_DCI")),
        Subsignal("cas_n", Pins("AK18"), IOStandard("SSTL15_DCI")),
        Subsignal("we_n", Pins("AG19"), IOStandard("SSTL15_DCI")),
        Subsignal("cs_n", Pins("AF18"), IOStandard("SSTL15_DCI")),
        Subsignal("dm", Pins("AD21 AE25 AJ21 AM21 AH26 AN26 AJ29 AL32"),
            IOStandard("SSTL15_DCI"),
            Misc("DATA_RATE=DDR")),
        Subsignal("dq", Pins(
            "AE23 AG20 AF22 AF20 AE22 AD20 AG22 AE20",
            "AJ24 AG24 AJ23 AF23 AH23 AF24 AH22 AG25",
            "AL22 AL25 AM20 AK23 AK22 AL24 AL20 AL23",
            "AM24 AN23 AN24 AP23 AP25 AN22 AP24 AM22",
            "AH28 AK26 AK28 AM27 AJ28 AH27 AK27 AM26",
            "AL30 AP29 AM30 AN28 AL29 AP28 AM29 AN27",
            "AH31 AH32 AJ34 AK31 AJ31 AJ30 AH34 AK32",
            "AN33 AP33 AM34 AP31 AM32 AN31 AL34 AN32"),
            IOStandard("SSTL15_DCI"),
            Misc("ODT=RTT_40"),
            Misc("DATA_RATE=DDR")),
        Subsignal("dqs_p", Pins("AG21 AH24 AJ20 AP20 AL27 AN29 AH33 AN34"),
            IOStandard("DIFF_SSTL15_DCI"),
            Misc("ODT=RTT_40"),
            Misc("DATA_RATE=DDR")),
        Subsignal("dqs_n", Pins("AH21 AJ25 AK20 AP21 AL28 AP30 AJ33 AP34"),
            IOStandard("DIFF_SSTL15_DCI"),
            Misc("ODT=RTT_40"),
            Misc("DATA_RATE=DDR")),
        Subsignal("clk_p", Pins("AE16"), IOStandard("DIFF_SSTL15_DCI"), Misc("DATA_RATE=DDR")),
        Subsignal("clk_n", Pins("AE15"), IOStandard("DIFF_SSTL15_DCI"), Misc("DATA_RATE=DDR")),
        Subsignal("cke", Pins("AL19"), IOStandard("SSTL15_DCI")),
        Subsignal("odt", Pins("AJ18"), IOStandard("SSTL15_DCI")),
        Subsignal("reset_n", Pins("AJ14"), IOStandard("SSTL15")),
        Misc("SLEW=FAST"),
        Misc("OUTPUT_IMPEDANCE=RDRV_40_40")
    ),

    ("ddram_32", 1,
        Subsignal("a", Pins(
            "E15 D15 J16 K18 H16 K17 K16 J15",
            "K15 D14 D18 G15 L18 G14 L15"),
            IOStandard("SSTL15_DCI")),
        Subsignal("ba", Pins("L19 H17 G16"), IOStandard("SSTL15_DCI")),
        Subsignal("ras_n", Pins("E18"), IOStandard("SSTL15_DCI")),
        Subsignal("cas_n", Pins("E16"), IOStandard("SSTL15_DCI")),
        Subsignal("we_n", Pins("D16"), IOStandard("SSTL15_DCI")),
        Subsignal("cs_n", Pins("G19"), IOStandard("SSTL15_DCI")),
        Subsignal("dm", Pins("F27 E26 D23 G24"),
            IOStandard("SSTL15_DCI"),
            Misc("DATA_RATE=DDR")),
        Subsignal("dq", Pins(
            "C28 B27 A27 C27 D28 E28 A28 D29",
            "D25 C26 E25 B25 C24 A25 D24 B26",
            "B20 D21 B22 E23 E22 D20 B21 A20",
            "F23 H21 F24 G21 F22 E21 G22 E20"),
            IOStandard("SSTL15_DCI"),
            Misc("DATA_RATE=DDR")),
        Subsignal("dqs_p", Pins("B29 B24 C21 G20"),
            IOStandard("DIFF_SSTL15_DCI"),
            Misc("ODT=RTT_40"),
            Misc("DATA_RATE=DDR")),
        Subsignal("dqs_n", Pins("A29 A24 C22 F20"),
            IOStandard("DIFF_SSTL15_DCI"),
            Misc("ODT=RTT_40"),
            Misc("DATA_RATE=DDR")),
        Subsignal("clk_p", Pins("J19"), IOStandard("DIFF_SSTL15_DCI"), Misc("DATA_RATE=DDR")),
        Subsignal("clk_n", Pins("J18"), IOStandard("DIFF_SSTL15_DCI"), Misc("DATA_RATE=DDR")),
        Subsignal("cke", Pins("H18"), IOStandard("SSTL15_DCI")),
        Subsignal("odt", Pins("F19"), IOStandard("SSTL15_DCI")),
        Subsignal("reset_n", Pins("F14"), IOStandard("SSTL15")),
        Misc("SLEW=FAST"),
        Misc("OUTPUT_IMPEDANCE=RDRV_40_40")
    ),

    # dac
    ("dac_refclk", 0,
        Subsignal("p", Pins("V6")),
        Subsignal("n", Pins("V5")),
    ),

    ("dac_sysref", 0,
        Subsignal("p", Pins("B10")),
        Subsignal("n", Pins("A10")),
        IOStandard("LVDS")
    ),
    ("dac_sync", 0,
        Subsignal("p", Pins("L8")),
        Subsignal("n", Pins("K8")),
        IOStandard("LVDS")
    ),
    ("dac_jesd", 0,
	    Subsignal("txp", Pins("R4 U4 W4 AA4 AC4 AE4 AG4 AH6")),
        Subsignal("txn", Pins("R3 U3 W3 AA3 AC3 AE3 AG3 AH5"))
    ),

    ("dac_sysref", 1,
        Subsignal("p", Pins("B10")),
        Subsignal("n", Pins("A10")),
        IOStandard("LVDS")
    ),
    ("dac_sync", 1,
        Subsignal("p", Pins("J9")),
        Subsignal("n", Pins("H9")),
        IOStandard("LVDS")
    ),
    ("dac_jesd", 1,
        Subsignal("txp", Pins("B6 C4 D6 F6 G4 J4 L4 N4")),
        Subsignal("txn", Pins("B5 C3 D5 F5 G3 J3 L3 N3"))
    ),


    # drtio
    ("drtio_refclk", 0,
        Subsignal("p", Pins("P6")),
        Subsignal("n", Pins("P5")),
    ),

    ("drtio_tx", 0,
        Subsignal("p", Pins("AN4")),
        Subsignal("n", Pins("AN3"))
    ),
    ("drtio_rx", 0,
        Subsignal("p", Pins("AP2")),
        Subsignal("n", Pins("AP1"))
    ),
    ("drtio_tx_disable_n", 0, Pins("AP11"), IOStandard("LVCMOS18")),

    ("drtio_tx", 1,
        Subsignal("p", Pins("AM6")),
        Subsignal("n", Pins("AM5"))
    ),
    ("drtio_rx", 1,
        Subsignal("p", Pins("AM2")),
        Subsignal("n", Pins("AM1"))
    ),
    ("drtio_tx_disable_n", 1, Pins("AM12"), IOStandard("LVCMOS18")),

    # rtm
    ("rtm_refclk125", 0,
        Subsignal("p", Pins("V6")),
        Subsignal("n", Pins("V5")),
    ),
    ("rtm_refclk156p25", 0,
        Subsignal("p", Pins("P6")),
        Subsignal("n", Pins("P5")),
    ),

    # serwb
    ("serwb", 0,
        Subsignal("clk_p", Pins("J8")), # rtm_fpga_usr_io_p
        Subsignal("clk_n", Pins("H8")), # rtm_fpga_usr_io_n
        Subsignal("tx_p", Pins("A13")), # rtm_fpga_lvds1_p
        Subsignal("tx_n", Pins("A12")), # rtm_fpga_lvds1_n
        Subsignal("rx_p", Pins("C12")), # rtm_fpga_lvds2_p
        Subsignal("rx_n", Pins("B12")), # rtm_fpga_lvds2_n
        IOStandard("LVDS")
    ),
]

class Platform(XilinxPlatform):
    default_clk_name = "clk50"
    default_clk_period = 20.0

    def __init__(self):
        XilinxPlatform.__init__(self, "xcku040-ffva1156-1-c", _io,
            toolchain="vivado")


class _CRG(Module):
    def __init__(self, platform):
        self.clock_domains.cd_sys0p2x = ClockDomain()
        self.clock_domains.cd_sys = ClockDomain()
        self.clock_domains.cd_sys4x = ClockDomain(reset_less=True)
        self.clock_domains.cd_clk200 = ClockDomain()
        self.clock_domains.cd_ic = ClockDomain()

        clk50 = platform.request("clk50")
        clk50_buffered = Signal()
        pll_locked = Signal()
        pll_fb = Signal()
        pll_sys4x = Signal()
        pll_clk200 = Signal()
        self.specials += [
            Instance("BUFG", i_I=clk50, o_O=clk50_buffered),
            Instance("PLLE2_BASE", name="crg_main_mmcm",
                attr={("LOC", "MMCME3_ADV_X1Y0")},
                p_STARTUP_WAIT="FALSE", o_LOCKED=pll_locked,

                # VCO @ 1GHz
                p_REF_JITTER1=0.01, p_CLKIN1_PERIOD=20.0,
                p_CLKFBOUT_MULT=20, p_DIVCLK_DIVIDE=1,
                i_CLKIN1=clk50_buffered, i_CLKFBIN=pll_fb, o_CLKFBOUT=pll_fb,

                # 500MHz
                p_CLKOUT0_DIVIDE=2, p_CLKOUT0_PHASE=0.0, o_CLKOUT0=pll_sys4x,

                # 200MHz
                p_CLKOUT1_DIVIDE=5, p_CLKOUT1_PHASE=0.0, o_CLKOUT1=pll_clk200,
            ),
            Instance("BUFGCE_DIV", name="main_bufgce_div",
                attr={("LOC", "BUFGCE_DIV_X1Y0")},
                p_BUFGCE_DIVIDE=4,
                i_CE=1, i_I=pll_sys4x, o_O=self.cd_sys.clk),
            Instance("BUFGCE", name="main_bufgce",
                attr={("LOC", "BUFGCE_X1Y14")},
                i_CE=1, i_I=pll_sys4x, o_O=self.cd_sys4x.clk),
            Instance("BUFG", i_I=pll_clk200, o_O=self.cd_clk200.clk),
            AsyncResetSynchronizer(self.cd_clk200, ~pll_locked),
        ]

        # https://www.xilinx.com/support/answers/67885.html
        platform.add_platform_command(
            "set_property CLOCK_DELAY_GROUP ULTRASCALE_IS_AWFUL [get_nets -of [get_pins main_bufgce_div/O]]")
        platform.add_platform_command(
            "set_property CLOCK_DELAY_GROUP ULTRASCALE_IS_AWFUL [get_nets -of [get_pins main_bufgce/O]]")
        platform.add_platform_command(
            "set_property USER_CLOCK_ROOT X2Y2 [get_nets -of [get_pins main_bufgce_div/O]]")
        platform.add_platform_command(
            "set_property USER_CLOCK_ROOT X2Y2 [get_nets -of [get_pins main_bufgce/O]]")

        ic_reset_counter = Signal(max=64, reset=63)
        ic_reset = Signal(reset=1)
        self.sync.clk200 += \
            If(ic_reset_counter != 0,
                ic_reset_counter.eq(ic_reset_counter - 1)
            ).Else(
                ic_reset.eq(0)
            )
        ic_rdy = Signal()
        ic_rdy_counter = Signal(max=64, reset=63)
        self.cd_sys.rst.reset = 1
        self.comb += self.cd_ic.clk.eq(self.cd_sys.clk)
        self.sync.ic += [
            If(ic_rdy,
                If(ic_rdy_counter != 0,
                    ic_rdy_counter.eq(ic_rdy_counter - 1)
                ).Else(
                    self.cd_sys.rst.eq(0)
                )
            )
        ]
        self.specials += [
            Instance("IDELAYCTRL", p_SIM_DEVICE="ULTRASCALE",
                     i_REFCLK=ClockSignal("clk200"), i_RST=ic_reset,
                     o_RDY=ic_rdy),
            AsyncResetSynchronizer(self.cd_ic, ic_reset)
        ]


class SDRAMTestSoC(SoCSDRAM):
    csr_map = {
        "ddrphy":    20,
        "generator": 21,
        "checker":   22,
        "analyzer":  30
    }
    csr_map.update(SoCSDRAM.csr_map)

    mem_map = {
        "firmware_ram": 0x20000000,
    }
    mem_map.update(SoCSDRAM.mem_map)

    def __init__(self, platform, ddram="ddram_32", with_cpu=False):
        clk_freq = int(125e6)
        SoCSDRAM.__init__(self, platform, clk_freq,
            cpu_type="lm32" if with_cpu else None,
            integrated_rom_size=0x8000 if with_cpu else 0,
            integrated_sram_size=0x8000 if with_cpu else 0,
            csr_data_width=8 if with_cpu else 32,
            l2_size=128,
            with_uart=with_cpu, uart_stub=False,
            ident="Sayma AMC SDRAM Test Design ", ident_version=True,
            with_timer=with_cpu
        )
        self.submodules.crg = _CRG(platform)
        if not with_cpu:
            self.add_cpu_or_bridge(UARTWishboneBridge(platform.request("serial"),
                                                      clk_freq, baudrate=115200))
            self.add_wb_master(self.cpu_or_bridge.wishbone)

        # firmware
        firmware_ram_size = 0x10000
        self.submodules.firmware_ram = wishbone.SRAM(firmware_ram_size)
        self.register_mem("firmware_ram", self.mem_map["firmware_ram"], self.firmware_ram.bus, firmware_ram_size)

        # sdram
        self.submodules.ddrphy = kusddrphy.KUSDDRPHY(platform.request(ddram))
        self.add_constant("DDRPHY_WLEVEL", None)
        self.add_constant("KUSDDRPHY", None)
        sdram_module = MT41J256M16(self.clk_freq, "1:4")
        self.register_sdram(self.ddrphy,
                            sdram_module.geom_settings,
                            sdram_module.timing_settings)

        # sdram bist
        generator_user_port = self.sdram.crossbar.get_port(mode="write")
        self.submodules.generator = LiteDRAMBISTGenerator(
            generator_user_port, random=True)
        checker_user_port = self.sdram.crossbar.get_port(mode="read")
        self.submodules.checker = LiteDRAMBISTChecker(
            checker_user_port, random=True)

        # leds
        led_counter = Signal(32)
        self.sync += led_counter.eq(led_counter + 1)
        self.comb += [
            platform.request("user_led", 0).eq(led_counter[26]),
            platform.request("user_led", 1).eq(led_counter[27]),
            platform.request("user_led", 2).eq(led_counter[28]),
            platform.request("user_led", 3).eq(led_counter[29])
        ]

        # analyzer
        if not with_cpu:
            dfi_phase_groups = []
            for i in range(4):
                dfi_phase_group = [
                    self.ddrphy.dfi.phases[i].address,
                    self.ddrphy.dfi.phases[i].bank,
                    self.ddrphy.dfi.phases[i].ras_n,
                    self.ddrphy.dfi.phases[i].cas_n,
                    self.ddrphy.dfi.phases[i].we_n,
                    self.ddrphy.dfi.phases[i].cs_n,
                    self.ddrphy.dfi.phases[i].cke,
                    self.ddrphy.dfi.phases[i].odt,
                    self.ddrphy.dfi.phases[i].reset_n,
                    self.ddrphy.dfi.phases[i].wrdata_en,
                    self.ddrphy.dfi.phases[i].wrdata_mask,
                    self.ddrphy.dfi.phases[i].wrdata,
                    self.ddrphy.dfi.phases[i].rddata,
                    self.ddrphy.dfi.phases[i].rddata_valid
                ]
                dfi_phase_groups.append(dfi_phase_group)
            analyzer_signals = {
                0 : dfi_phase_groups[0],
                1 : dfi_phase_groups[1],
                2 : dfi_phase_groups[2],
                3 : dfi_phase_groups[3]
            }
            if not with_cpu:
                self.submodules.analyzer = LiteScopeAnalyzer(analyzer_signals, 64)

    def do_exit(self, vns):
        if hasattr(self, "analyzer"):
            self.analyzer.export_csv(vns, "test/sayma_amc/analyzer.csv")


def get_phy_pads(jesd_pads, n):
    class PHYPads:
        def __init__(self, txp, txn):
            self.txp = txp
            self.txn = txn
    return PHYPads(jesd_pads.txp[n], jesd_pads.txn[n])


class Cosine(Module, AutoCSR):
    def __init__(self, width=16):
        self._amplitude = CSRStorage(width)
        self._frequency = CSRStorage(2*width)

        self.submodules.cordic = cordic = Cordic(
                width=width, widthz=2*width, guard=None, eval_mode="pipelined")

        z = Signal(2*width)
        self.sync += z.eq(z + self._frequency.storage)

        self.comb += [
                cordic.xi.eq(self._amplitude.storage),
                cordic.yi.eq(0),
                cordic.zi.eq(z)
        ]
        self.o = cordic.xo


class JESDTestSoC(SoCCore):
    csr_map = {
        "cosine":       20,
        "dac0_control": 21,
        "dac0_core":    22,
        "dac1_control": 23,
        "dac1_core":    24,
        "analyzer":     30
    }
    csr_map.update(SoCCore.csr_map)

    def __init__(self, platform):
        clk_freq = int(125e6)
        SoCCore.__init__(self, platform, clk_freq,
            cpu_type=None,
            csr_data_width=32,
            with_uart=False,
            ident="Sayma AMC JESD Test Design ", ident_version=True,
            with_timer=False
        )
        self.submodules.crg = _CRG(platform)

        # uart <--> wishbone
        self.add_cpu_or_bridge(UARTWishboneBridge(platform.request("serial"),
                                                  clk_freq, baudrate=115200))
        self.add_wb_master(self.cpu_or_bridge.wishbone)

        self.crg.cd_sys.clk.attr.add("keep")
        platform.add_period_constraint(self.crg.cd_sys.clk, 8.0)

        # amc <--> rtm usr_uart / aux_uart redirection
        aux_uart_pads = platform.request("serial", 1)
        self.comb += [
            aux_uart_pads.tx.eq(platform.request("usr_uart_p")),
            platform.request("usr_uart_n").eq(aux_uart_pads.rx)
        ]

        # jesd
        ps = JESD204BPhysicalSettings(l=8, m=4, n=16, np=16)
        ts = JESD204BTransportSettings(f=2, s=2, k=16, cs=0)
        settings = JESD204BSettings(ps, ts, did=0x5a, bid=0x5)
        linerate = 6e9
        refclk_freq = 150e6

        self.clock_domains.cd_jesd = ClockDomain()
        refclk_pads = platform.request("dac_refclk")

        self.refclk = Signal()
        refclk_to_bufg_gt = Signal()
        self.specials += [
            Instance("IBUFDS_GTE3", i_CEB=0,
                     p_REFCLK_HROW_CK_SEL=0b00,
                     i_I=refclk_pads.p, i_IB=refclk_pads.n,
                     o_O=self.refclk, o_ODIV2=refclk_to_bufg_gt),
            Instance("BUFG_GT", i_I=refclk_to_bufg_gt, o_O=self.cd_jesd.clk)
        ]
        platform.add_period_constraint(self.cd_jesd.clk, 1e9/refclk_freq)

        self.submodules.cosine = cosine = ClockDomainsRenamer("jesd")(Cosine(16))

        for dac in range(2):
            jesd_pads = platform.request("dac_jesd", dac)
            phys = []
            for i in range(len(jesd_pads.txp)):
                cpll = JESD204BGTHChannelPLL(self.refclk, refclk_freq, linerate)
                self.submodules += cpll
                print(cpll)

                phy = LiteJESD204BPhyTX(
                    cpll, get_phy_pads(jesd_pads, i), self.clk_freq,
                    transceiver="gth")
                platform.add_period_constraint(phy.transmitter.cd_tx.clk, 40*1e9/linerate)
                platform.add_false_path_constraints(
                    self.crg.cd_sys.clk,
                    self.cd_jesd.clk,
                    phy.transmitter.cd_tx.clk)
                phys.append(phy)
            to_jesd = ClockDomainsRenamer("jesd")
            core = to_jesd(LiteJESD204BCoreTX(phys, settings, converter_data_width=64))
            control = to_jesd(LiteJESD204BCoreTXControl(core))
            setattr(self.submodules, "dac"+str(dac)+"_core", core)
            setattr(self.submodules, "dac"+str(dac)+"_control", control)
            core.register_jsync(platform.request("dac_sync", dac))
            core.register_jref(platform.request("dac_sysref", dac) if dac == 0 else self.dac0_core.jref)
            self.comb += [
                core.sink.converter0.eq(Cat(cosine.o, cosine.o, cosine.o, cosine.o)),
                core.sink.converter1.eq(Cat(cosine.o, cosine.o, cosine.o, cosine.o)),
                core.sink.converter2.eq(Cat(cosine.o, cosine.o, cosine.o, cosine.o)),
                core.sink.converter3.eq(Cat(cosine.o, cosine.o, cosine.o, cosine.o))
            ]

        jesd_dac0_phy0_counter = Signal(32)
        self.sync.dac0_core_phy0_tx += jesd_dac0_phy0_counter.eq(jesd_dac0_phy0_counter + 1)
        self.comb += platform.request("user_led", 0).eq(jesd_dac0_phy0_counter[26])
        self.comb += platform.request("user_led", 1).eq(self.dac0_core.jsync)

        jesd_dac1_phy0_counter = Signal(32)
        self.sync.dac1_core_phy0_tx += jesd_dac1_phy0_counter.eq(jesd_dac1_phy0_counter + 1)
        self.comb += platform.request("user_led", 2).eq(jesd_dac1_phy0_counter[26])
        self.comb += platform.request("user_led", 3).eq(self.dac1_core.jsync)

    def do_exit(self, vns):
        pass


class DRTIOTestSoC(SoCCore):
    csr_map = {
        "drtio_phy": 20
    }
    csr_map.update(SoCCore.csr_map)

    def __init__(self, platform, pll="cpll", dw=20):
        clk_freq = int(125e6)
        SoCCore.__init__(self, platform, clk_freq,
            cpu_type=None,
            csr_data_width=32,
            with_uart=False,
            ident="Sayma AMC DRTIO Test Design ", ident_version=True,
            with_timer=False
        )
        self.submodules.crg = _CRG(platform)
        self.add_cpu_or_bridge(UARTWishboneBridge(platform.request("serial"),
                                                  clk_freq, baudrate=115200))
        self.add_wb_master(self.cpu_or_bridge.wishbone)

        self.crg.cd_sys.clk.attr.add("keep")
        platform.add_period_constraint(self.crg.cd_sys.clk, 8.0)

        # amc <--> rtm usr_uart / aux_uart redirection
        aux_uart_pads = platform.request("serial", 1)
        self.comb += [
            aux_uart_pads.tx.eq(platform.request("usr_uart_p")),
            platform.request("usr_uart_n").eq(aux_uart_pads.rx)
        ]

        refclk = Signal()
        refclk_pads = platform.request("drtio_refclk")
        self.specials += [
            Instance("IBUFDS_GTE3",
                i_CEB=0,
                i_I=refclk_pads.p,
                i_IB=refclk_pads.n,
                o_O=refclk)
        ]

        if pll == "cpll":
            plls = [GTHChannelPLL(refclk, 150e6, 3e9) for i in range(2)]
            self.submodules += iter(plls)
            print(plls)
        elif pll == "qpll":
            qpll = GTHQuadPLL(refclk, 150e6, 3e9)
            plls = [qpll for i in range(2)]
            self.submodules += qpll
            print(qpll)

        self.submodules.drtio_phy = drtio_phy = GTH(
            plls,
            [platform.request("drtio_tx", i) for i in range(2)],
            [platform.request("drtio_rx", i) for i in range(2)],
            clk_freq,
            20)
        self.comb += platform.request("drtio_tx_disable_n", 0).eq(0b1)
        self.comb += platform.request("drtio_tx_disable_n", 1).eq(0b1)

        counter = Signal(32)
        self.sync.rtio += counter.eq(counter + 1)

        for i, channel in enumerate(drtio_phy.channels):
            self.comb += [
                channel.encoder.k[0].eq(1),
                channel.encoder.d[0].eq((5 << 5) | 28),
                channel.encoder.k[1].eq(0)
            ]
            self.comb += channel.encoder.d[1].eq(counter[26:])
            for j in range(2):
                self.comb += platform.request("user_led", 2*i + j).eq(channel.decoders[1].d[j])

        for gth in drtio_phy.gths:
            gth.cd_rtio_tx.clk.attr.add("keep")
            gth.cd_rtio_rx.clk.attr.add("keep")
            platform.add_period_constraint(gth.cd_rtio_tx.clk, 1e9/gth.rtio_clk_freq)
            platform.add_period_constraint(gth.cd_rtio_rx.clk, 1e9/gth.rtio_clk_freq)
            self.platform.add_false_path_constraints(
                self.crg.cd_sys.clk,
                gth.cd_rtio_tx.clk,
                gth.cd_rtio_rx.clk)

    def do_exit(self, vns):
        pass


class SERWBTest(Module, AutoCSR):
    def __init__(self, bus):
        self.do_write = CSR()
        self.do_read = CSR()

        # # #

        self.submodules.fsm = fsm = FSM(reset_state="IDLE")
        fsm.act("IDLE",
            If(self.do_write.re,
                NextState("WRITE")
            ).Elif(self.do_read.re,
                NextState("READ")
            )
        )
        fsm.act("WRITE",
            bus.stb.eq(1),
            bus.cyc.eq(1),
            bus.we.eq(1),
            bus.adr.eq(0x12345678),
            bus.dat_w.eq(0xdeadbeef),
            If(bus.ack,
                NextState("IDLE")
            )
        )
        fsm.act("READ",
            bus.stb.eq(1),
            bus.cyc.eq(1),
            bus.adr.eq(0x89abcdef),
            If(bus.ack,
                NextState("IDLE")
            )
        )


class SERWBTestSoC(SoCCore):
    csr_map = {
        "serwb_phy":   20,
        "serwb_test":  21,
        "analyzer":    30
    }
    csr_map.update(SoCCore.csr_map)

    mem_map = {
        "serwb": 0x30000000,
    }
    mem_map.update(SoCCore.mem_map)

    def __init__(self, platform, with_serwb_test=False):
        clk_freq = int(125e6)
        SoCCore.__init__(self, platform, clk_freq,
            cpu_type=None,
            csr_data_width=32,
            with_uart=False,
            ident="Sayma AMC / AMC <--> RTM SERWB Link Test Design ", ident_version=True,
            with_timer=False
        )
        self.submodules.crg = _CRG(platform)

        # uart <--> wishbone
        self.add_cpu_or_bridge(UARTWishboneBridge(platform.request("serial"),
                                                  clk_freq, baudrate=115200))
        self.add_wb_master(self.cpu_or_bridge.wishbone)

        # amc <--> rtm usr_uart / aux_uart redirection
        aux_uart_pads = platform.request("serial", 1)
        self.comb += [
            aux_uart_pads.tx.eq(platform.request("usr_uart_p")),
            platform.request("usr_uart_n").eq(aux_uart_pads.rx)
        ]

        # amc rtm link
        serwb_phy = SERWBPHY(platform.device, platform.request("serwb"), mode="master")
        self.submodules.serwb_phy = serwb_phy

        # wishbone slave
        serwb_core = SERWBCore(serwb_phy, clk_freq, mode="slave")
        self.submodules += serwb_core
        if with_serwb_test:
            # serwb test
            self.submodules.serwb_test = SERWBTest(serwb_core.etherbone.wishbone.bus)
        else:
            self.register_mem("serwb", self.mem_map["serwb"], serwb_core.etherbone.wishbone.bus, 8192)


class FullTestSoC(SoCSDRAM):
    csr_map = {
        "ddrphy":    20,
        "serwb_phy": 21,
        "analyzer":  30
    }
    csr_map.update(SoCSDRAM.csr_map)

    mem_map = {
        "firmware_ram": 0x20000000,
        "serwb":        0x30000000
    }
    mem_map.update(SoCSDRAM.mem_map)

    def __init__(self, platform):
        clk_freq = int(125e6)
        SoCSDRAM.__init__(self, platform, clk_freq,
            cpu_type="lm32",
            integrated_rom_size=0x8000,
            integrated_sram_size=0x8000,
            csr_data_width=8,
            l2_size=128,
            with_uart=True,
            ident="Sayma Full Test Design ", ident_version=True,
            with_timer=True
        )
        self.submodules.crg = _CRG(platform)

        self.crg.cd_sys.clk.attr.add("keep")

        # amc <--> rtm usr_uart / aux_uart redirection
        aux_uart_pads = platform.request("serial", 1)
        self.comb += [
            aux_uart_pads.tx.eq(platform.request("usr_uart_p")),
            platform.request("usr_uart_n").eq(aux_uart_pads.rx)
        ]

        # firmware
        firmware_ram_size = 0x10000
        self.submodules.firmware_ram = wishbone.SRAM(firmware_ram_size)
        self.register_mem("firmware_ram", self.mem_map["firmware_ram"], self.firmware_ram.bus, firmware_ram_size)

        # sdram
        self.submodules.ddrphy = kusddrphy.KUSDDRPHY(platform.request("ddram_64"))
        self.add_constant("DDRPHY_WLEVEL", None)
        self.add_constant("KUSDDRPHY", None)
        sdram_module = MT41J256M16(self.clk_freq, "1:4")
        self.register_sdram(self.ddrphy,
                            sdram_module.geom_settings,
                            sdram_module.timing_settings)

        # amc rtm link
        serwb_phy = SERWBPHY(platform.device, platform.request("serwb"), mode="master")
        self.submodules.serwb_phy = serwb_phy

        # wishbone slave
        serwb_core = SERWBCore(serwb_phy, clk_freq, mode="slave", with_scrambling=False)
        self.submodules += serwb_core
        self.register_mem("serwb", self.mem_map["serwb"], serwb_core.etherbone.wishbone.bus, 8192)

        # leds
        led_counter = Signal(32)
        self.sync += led_counter.eq(led_counter + 1)
        self.comb += [
            platform.request("user_led", 0).eq(led_counter[26]),
            platform.request("user_led", 1).eq(led_counter[27]),
            platform.request("user_led", 2).eq(led_counter[28]),
            platform.request("user_led", 3).eq(led_counter[29])
        ]


def main():
    platform = Platform()
    compile_gateware = True
    if len(sys.argv) < 2:
        print("missing target (ddram or jesd or drtio or serwb)")
        exit()
    if sys.argv[1] == "ddram":
        dw = "64"
        with_cpu = True
        if len(sys.argv) > 2:
            dw = sys.argv[2]
        if len(sys.argv) > 3:
            with_cpu = bool(sys.argv[3])
            #compile_gateware = False
        soc = SDRAMTestSoC(platform, "ddram_" + dw, with_cpu)
    elif sys.argv[1] == "jesd":
        soc = JESDTestSoC(platform)
    elif sys.argv[1] == "drtio":
        soc = DRTIOTestSoC(platform)
    elif sys.argv[1] == "serwb":
        soc = SERWBTestSoC(platform)
    elif sys.argv[1] == "full":
         soc = FullTestSoC(platform)
    builder = Builder(soc, output_dir="build_sayma_amc", csr_csv="test/sayma_amc/csr.csv",
        compile_gateware=compile_gateware)
    vns = builder.build()
    soc.do_exit(vns)


if __name__ == "__main__":
    main()
