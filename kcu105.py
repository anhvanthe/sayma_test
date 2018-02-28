#!/usr/bin/env python3
import sys
import sys
sys.path.append("gateware") # FIXME

from migen import *
from migen.genlib.io import CRG

from litex.build.generic_platform import *
from litex.boards.platforms import kcu105

from litex.soc.interconnect.csr import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.uart import UARTWishboneBridge

from drtio.gth_ultrascale import GTH



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
        "analyzer" : 20,
        "drtio_phy": 21
    }
    csr_map.update(SoCCore.csr_map)

    def __init__(self, platform, nlanes=2):
        clk_freq = int(1e9/platform.default_clk_period)
        SoCCore.__init__(self, platform, clk_freq,
            cpu_type=None,
            csr_data_width=32,
            with_uart=False,
            ident="KCU105 DRTIO Test Design ",
            ident_version=True,
            with_timer=False
        )
        self.submodules.crg = CRG(platform.request(platform.default_clk_name),
                                  platform.request("cpu_reset"))
        self.add_cpu_or_bridge(UARTWishboneBridge(platform.request("serial"),
                                                  clk_freq, baudrate=115200))
        self.add_wb_master(self.cpu_or_bridge.wishbone)

        self.crg.cd_sys.clk.attr.add("keep")
        platform.add_period_constraint(self.crg.cd_sys.clk, 8.0)

        # 150Mhz clock -> user_sma --> user_sma_mgt_refclk
        clk300 = platform.request("clk300")
        self.clock_domains.cd_clk300 = ClockDomain()
        self.specials += Instance("IBUFDS", i_I=clk300.p, i_IB=clk300.n, o_O=self.cd_clk300.clk)
        user_sma_clock_pads = platform.request("user_sma_clock")
        user_sma_clock = Signal()
        self.sync.clk300 += user_sma_clock.eq(~user_sma_clock)
        self.specials += [
            Instance("OBUFDS",
                i_I=user_sma_clock,
                o_O=user_sma_clock_pads.p,
                o_OB=user_sma_clock_pads.n)
        ]

        rtio_clk_freq = 150e6

        self.submodules.drtio_phy = drtio_phy = GTH(
            clock_pads=platform.request("user_sma_mgt_refclk"),
            data_pads= [platform.request("sfp", i) for i in range(nlanes)],
            sys_clk_freq=clk_freq,
            rtio_clk_freq=150e6)
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
            platform.add_period_constraint(gth.cd_rtio_tx.clk, 1e9/rtio_clk_freq)
            platform.add_period_constraint(gth.cd_rtio_rx.clk, 1e9/rtio_clk_freq)
            self.platform.add_false_path_constraints(
                self.crg.cd_sys.clk,
                gth.cd_rtio_tx.clk,
                gth.cd_rtio_rx.clk)

def main():
    platform = kcu105.Platform()
    if len(sys.argv) < 2:
        print("missing target (base or drtio)")
        exit()
    if sys.argv[1] == "base":
        soc = BaseSoC(platform)
    elif sys.argv[1] == "drtio":
        soc = DRTIOTestSoC(platform)
    builder = Builder(soc, output_dir="build_kcu105", csr_csv="test/kcu105/csr.csv")
    vns = builder.build()


if __name__ == "__main__":
    main()
