#!/usr/bin/env python3
import sys
import sys
sys.path.append("gateware") # FIXME

from litex.gen import *
from litex.soc.interconnect.csr import *
from litex.build.generic_platform import *
from litex.boards.platforms import kcu105

from litex.gen.genlib.io import CRG

from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.uart import UARTWishboneBridge

from drtio.gth_ultrascale import GTHChannelPLL, GTHQuadPLL, GTH

from litescope import LiteScopeAnalyzer


class BaseSoC(SoCCore):
    def __init__(self, platform):
        clk_freq = int(1e9/platform.default_clk_period)
        SoCCore.__init__(self, platform, clk_freq,
            cpu_type=None,
            csr_data_width=32,
            with_uart=False,
            ident="Transceiver Test Design",
            with_timer=False
        )
        self.submodules.crg = CRG(platform.request(platform.default_clk_name))
        self.add_cpu_or_bridge(UARTWishboneBridge(platform.request("serial"),
                                                  clk_freq, baudrate=115200))
        self.add_wb_master(self.cpu_or_bridge.wishbone)

        self.crg.cd_sys.clk.attr.add("keep")
        platform.add_period_constraint(self.crg.cd_sys.clk, 8.0)


class DRTIOTestSoC(SoCCore):
    csr_map = {
        "drtio_phy": 20
    }
    csr_map.update(SoCCore.csr_map)

    def __init__(self, platform, pll="cpll", dw=20):
        clk_freq = int(1e9/platform.default_clk_period)
        SoCCore.__init__(self, platform, clk_freq,
            cpu_type=None,
            csr_data_width=32,
            with_uart=False,
            ident="KCU105 DRTIO Test Design ",
            ident_version=True,
            with_timer=False
        )
        self.submodules.crg = CRG(platform.request(platform.default_clk_name))
        self.add_cpu_or_bridge(UARTWishboneBridge(platform.request("serial"),
                                                  clk_freq, baudrate=115200))
        self.add_wb_master(self.cpu_or_bridge.wishbone)

        self.crg.cd_sys.clk.attr.add("keep")
        platform.add_period_constraint(self.crg.cd_sys.clk, 8.0)

		# 300Mhz clock -> user_sma --> user_sma_mgt_refclk
        clk300 = platform.request("clk300")
        clk300_se = Signal()
        self.specials += Instance("IBUFDS", i_I=clk300.p, i_IB=clk300.n, o_O=clk300_se)
        user_sma_clock_pads = platform.request("user_sma_clock")
        user_sma_clock = Signal()
        self.specials += [
            Instance("ODDRE1",
                i_D1=0, i_D2=1, i_SR=0,
                i_C=clk300_se,
                o_Q=user_sma_clock),
            Instance("OBUFDS",
                i_I=user_sma_clock,
                o_O=user_sma_clock_pads.p,
                o_OB=user_sma_clock_pads.n)
        ]

        refclk = Signal()
        refclk_pads = platform.request("user_sma_mgt_refclk")
        self.specials += [
            Instance("IBUFDS_GTE3",
                i_CEB=0,
                i_I=refclk_pads.p,
                i_IB=refclk_pads.n,
                o_O=refclk)
        ]

        if pll == "cpll":
            plls = [GTHChannelPLL(refclk, 300e6, 3e9) for i in range(2)]
            self.submodules += iter(plls)
            print(plls)
        elif pll == "qpll":
            qpll = GTHQuadPLL(refclk, 300e6, 3e9)
            plls = [qpll for i in range(2)]
            self.submodules += qpll
            print(qpll)

        self.submodules.drtio_phy = drtio_phy = GTH(
            plls,
            [platform.request("sfp_tx", i) for i in range(2)],
            [platform.request("sfp_rx", i) for i in range(2)],
            clk_freq,
            20)
        self.comb += platform.request("sfp_tx_disable_n", 0).eq(0b1)
        self.comb += platform.request("sfp_tx_disable_n", 1).eq(0b1)

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


def main():
    platform = kcu105.Platform()
    if len(sys.argv) < 2:
        print("missing target (base or drtio)")
        exit()
    if sys.argv[1] == "base":
        soc = BaseSoC(platform)
    elif sys.argv[1] == "drtio":
        soc = DRTIOTestSoC(platform)
    builder = Builder(soc, output_dir="build_kcu105")
    builder.build()


if __name__ == "__main__":
    main()
