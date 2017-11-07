#!/usr/bin/env python3
import sys

from litex.gen import *
from litex.boards.platforms import kcu105

from litex.gen.genlib.io import CRG

from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.uart import UARTWishboneBridge


class ClkGenSoC(SoCCore):
    def __init__(self, platform):
        clk_freq = int(125e9)
        SoCCore.__init__(self, platform, clk_freq,
            cpu_type=None,
            csr_data_width=32,
            with_uart=False,
            ident="KCU105 1.2GHz Clock Generator",
            with_timer=False
        )
        self.submodules.crg = CRG(platform.request("clk125"))
        self.add_cpu_or_bridge(UARTWishboneBridge(platform.request("serial"),
                                                  clk_freq, baudrate=115200))
        self.add_wb_master(self.cpu_or_bridge.wishbone)

        clk300 = platform.request("clk300")
        clk300_se = Signal()
        self.specials += Instance("IBUFDS", i_I=clk300.p, i_IB=clk300.n, o_O=clk300_se)

        pll_locked = Signal()
        pll_fb = Signal()
        pll_out1 = Signal()
        pll_out2 = Signal()
        self.specials += [
            Instance("PLLE2_BASE",
                     p_STARTUP_WAIT="FALSE", o_LOCKED=pll_locked,

                     # VCO @ 1.2GHz
                     p_REF_JITTER1=0.01, p_CLKIN1_PERIOD=3.33,
                     p_CLKFBOUT_MULT=4, p_DIVCLK_DIVIDE=1,
                     i_CLKIN1=clk300_se, i_CLKFBIN=pll_fb, o_CLKFBOUT=pll_fb,

                     # 1.2GHz
                     p_CLKOUT1_DIVIDE=1, p_CLKOUT1_PHASE=0.0,
                     o_CLKOUT1=pll_out1,

                     # 100MHz
                     p_CLKOUT2_DIVIDE=12, p_CLKOUT2_PHASE=0.0,
                     o_CLKOUT2=pll_out2,
            )
        ]

        user_sma_clock_pads = platform.request("user_sma_clock")
        self.specials += [
            Instance("OBUFDS",
                i_I=pll_out1,
                o_O=user_sma_clock_pads.p,
                o_OB=user_sma_clock_pads.n
            )
        ]

        user_sma_gpio_p = platform.request("user_sma_gpio_p")
        self.comb += user_sma_gpio_p.eq(pll_out2)

def main():
    soc = ClkGenSoC(kcu105.Platform())
    builder = Builder(soc, output_dir="build_clkgen")
    builder.build()


if __name__ == "__main__":
    main()
