from migen import *
from migen.genlib.resetsync import AsyncResetSynchronizer
from migen.genlib.cdc import MultiReg, PulseSynchronizer, Gearbox
from migen.genlib.misc import BitSlip

from misoc.cores.code_8b10b import Encoder, Decoder

from amc_rtm_link.phy import PhaseDetector


class KUSSerdesPLL(Module):
    def __init__(self, refclk_freq, linerate, vco_div=1):
        assert refclk_freq == 125e6
        assert linerate == 1.25e9

        self.lock = Signal()
        self.refclk = Signal()
        self.serdes_clk = Signal()
        self.serdes_20x_clk = Signal()
        self.serdes_5x_clk = Signal()

        # # #

        #----------------------
        # refclk:        125MHz
        # vco:          1250MHz
        #----------------------
        # serdes:      31.25MHz
        # serdes_20x:    625MHz
        # serdes_5x:  156.25MHz
        #----------------------
        self.linerate = linerate

        pll_locked = Signal()
        pll_fb = Signal()
        pll_serdes_clk = Signal()
        pll_serdes_20x_clk = Signal()
        pll_serdes_5x_clk = Signal()
        self.specials += [
            Instance("PLLE2_BASE",
                p_STARTUP_WAIT="FALSE", o_LOCKED=pll_locked,

                # VCO @ 1.25GHz / vco_div
                p_REF_JITTER1=0.01, p_CLKIN1_PERIOD=8.0,
                p_CLKFBOUT_MULT=10, p_DIVCLK_DIVIDE=vco_div,
                i_CLKIN1=self.refclk, i_CLKFBIN=pll_fb,
                o_CLKFBOUT=pll_fb,

                # 31.25MHz: serdes
                p_CLKOUT0_DIVIDE=40//vco_div, p_CLKOUT0_PHASE=0.0,
                o_CLKOUT0=pll_serdes_clk,

                # 625MHz: serdes_20x
                p_CLKOUT1_DIVIDE=2//vco_div, p_CLKOUT1_PHASE=0.0,
                o_CLKOUT1=pll_serdes_20x_clk,

                # 156.25MHz: serdes_5x
                p_CLKOUT2_DIVIDE=8//vco_div, p_CLKOUT2_PHASE=0.0,
                o_CLKOUT2=pll_serdes_5x_clk
            ),
            Instance("BUFG", i_I=pll_serdes_clk, o_O=self.serdes_clk),
            Instance("BUFG", i_I=pll_serdes_20x_clk, o_O=self.serdes_20x_clk),
            Instance("BUFG", i_I=pll_serdes_5x_clk, o_O=self.serdes_5x_clk)
        ]
        self.specials += MultiReg(pll_locked, self.lock)


class KUSSerdes(Module):
    def __init__(self, pll, pads, mode="master"):
        self.tx_data = Signal(32)
        self.rx_data = Signal(32)

        self.tx_idle = Signal()
        self.tx_comma = Signal()
        self.rx_idle = Signal()
        self.rx_comma = Signal()

        self.rx_bitslip_value = Signal(6)
        self.rx_delay_rst = Signal()
        self.rx_delay_inc = Signal()
        self.rx_delay_ce = Signal()
        self.rx_delay_en_vtc = Signal()

        # # #

        self.submodules.encoder = ClockDomainsRenamer("serdes")(
            Encoder(4, True))
        self.decoders = [ClockDomainsRenamer("serdes")(
            Decoder(True)) for _ in range(4)]
        self.submodules += self.decoders

        # clocking
        # master mode:
        # - linerate/10 pll refclk provided by user
        # - linerate/10 slave refclk generated on clk_pads
        # slave mode:
        # - linerate/10 pll refclk provided by clk_pads
        self.clock_domains.cd_serdes = ClockDomain()
        self.clock_domains.cd_serdes_5x = ClockDomain()
        self.clock_domains.cd_serdes_20x = ClockDomain(reset_less=True)
        self.comb += [
            self.cd_serdes.clk.eq(pll.serdes_clk),
            self.cd_serdes_5x.clk.eq(pll.serdes_5x_clk),
            self.cd_serdes_20x.clk.eq(pll.serdes_20x_clk)
        ]
        self.specials += AsyncResetSynchronizer(self.cd_serdes, ~pll.lock)
        self.comb += self.cd_serdes_5x.rst.eq(self.cd_serdes.rst)

        # control/status cdc
        tx_idle = Signal()
        tx_comma = Signal()
        rx_idle = Signal()
        rx_comma = Signal()
        rx_bitslip_value = Signal(6)
        rx_delay_rst = Signal()
        rx_delay_inc = Signal()
        rx_delay_en_vtc = Signal()
        rx_delay_ce = Signal()
        self.specials += [
            MultiReg(self.tx_idle, tx_idle, "serdes"),
            MultiReg(self.tx_comma, tx_comma, "serdes"),
            MultiReg(rx_idle, self.rx_idle, "sys"),
            MultiReg(rx_comma, self.rx_comma, "sys"),
            MultiReg(self.rx_bitslip_value, rx_bitslip_value, "serdes"),
            MultiReg(self.rx_delay_inc, rx_delay_inc, "serdes_5x"),
            MultiReg(self.rx_delay_en_vtc, rx_delay_en_vtc, "serdes_5x")
        ]
        self.submodules.do_rx_delay_rst = PulseSynchronizer("sys", "serdes_5x")
        self.comb += [
            rx_delay_rst.eq(self.do_rx_delay_rst.o),
            self.do_rx_delay_rst.i.eq(self.rx_delay_rst)
        ]
        self.submodules.do_rx_delay_ce = PulseSynchronizer("sys", "serdes_5x")
        self.comb += [
            rx_delay_ce.eq(self.do_rx_delay_ce.o),
            self.do_rx_delay_ce.i.eq(self.rx_delay_ce)
        ]

        # tx clock (linerate/10)
        if mode == "master":
            self.submodules.tx_clk_gearbox = Gearbox(40, "serdes", 8, "serdes_5x")
            self.comb += self.tx_clk_gearbox.i.eq((0b1111100000 << 30) |
                                                  (0b1111100000 << 20) |
                                                  (0b1111100000 << 10) |
                                                  (0b1111100000 <<  0))
            clk_o = Signal()
            self.specials += [
                Instance("OSERDESE3",
                    p_DATA_WIDTH=8, p_INIT=0,
                    p_IS_CLK_INVERTED=0, p_IS_CLKDIV_INVERTED=0, p_IS_RST_INVERTED=0,

                    o_OQ=clk_o,
                    i_RST=ResetSignal("serdes"),
                    i_CLK=ClockSignal("serdes_20x"), i_CLKDIV=ClockSignal("serdes_5x"),
                    i_D=self.tx_clk_gearbox.o
                ),
                Instance("OBUFDS",
                    i_I=clk_o,
                    o_O=pads.clk_p,
                    o_OB=pads.clk_n
                )
            ]

        # tx data
        self.submodules.tx_gearbox = Gearbox(40, "serdes", 8, "serdes_5x")
        self.comb += [
            If(tx_comma,
                self.encoder.k[0].eq(1),
                self.encoder.d[0].eq(0xbc)
            ).Else(
                self.encoder.d[0].eq(self.tx_data[0:8]),
                self.encoder.d[1].eq(self.tx_data[8:16]),
                self.encoder.d[2].eq(self.tx_data[16:24]),
                self.encoder.d[3].eq(self.tx_data[24:32])
            )
        ]
        self.sync.serdes += \
            If(tx_idle,
                self.tx_gearbox.i.eq(0)
            ).Else(
                self.tx_gearbox.i.eq(Cat(*[self.encoder.output[i] for i in range(4)]))
            )

        serdes_o = Signal()
        self.specials += [
            Instance("OSERDESE3",
                p_DATA_WIDTH=8, p_INIT=0,
                p_IS_CLK_INVERTED=0, p_IS_CLKDIV_INVERTED=0, p_IS_RST_INVERTED=0,

                o_OQ=serdes_o,
                i_RST=ResetSignal("serdes"),
                i_CLK=ClockSignal("serdes_20x"), i_CLKDIV=ClockSignal("serdes_5x"),
                i_D=self.tx_gearbox.o
            ),
            Instance("OBUFDS",
                i_I=serdes_o,
                o_O=pads.tx_p,
                o_OB=pads.tx_n
            )
        ]

        # rx clock
        use_bufr = True
        if mode == "slave":
            clk_i = Signal()
            clk_i_bufg = Signal()
            self.specials += [
                Instance("IBUFDS",
                    i_I=pads.clk_p,
                    i_IB=pads.clk_n,
                    o_O=clk_i
                )
            ]
            if use_bufr:
                clk_i_bufr = Signal()
                self.specials += [
                    Instance("BUFR", i_I=clk_i, o_O=clk_i_bufr),
                    Instance("BUFG", i_I=clk_i_bufr, o_O=clk_i_bufg)
                ]
            else:
                self.specials += Instance("BUFG", i_I=clk_i, o_O=clk_i_bufg)
            self.comb += pll.refclk.eq(clk_i_bufg)

        # rx data
        self.submodules.rx_gearbox = Gearbox(8, "serdes_5x", 40, "serdes")
        self.submodules.rx_bitslip = ClockDomainsRenamer("serdes")(BitSlip(40))

        self.submodules.phase_detector = ClockDomainsRenamer("serdes_5x")(PhaseDetector())

        # use 2 serdes for phase detection: 1 master / 1 slave
        serdes_m_i_nodelay = Signal()
        serdes_s_i_nodelay = Signal()
        self.specials += [
            Instance("IBUFDS_DIFF_OUT",
                i_I=pads.rx_p,
                i_IB=pads.rx_n,
                o_O=serdes_m_i_nodelay,
                o_OB=serdes_s_i_nodelay
            )
        ]

        serdes_m_i_delayed = Signal()
        serdes_m_q = Signal(8)
        self.specials += [
            Instance("IDELAYE3",
                p_CASCADE="NONE", p_UPDATE_MODE="ASYNC", p_REFCLK_FREQUENCY=200.0,
                p_IS_CLK_INVERTED=0, p_IS_RST_INVERTED=0,
                # Note: can't use TIME mode since not reloading DELAY_VALUE on rst...
                p_DELAY_FORMAT="COUNT", p_DELAY_SRC="IDATAIN",
                p_DELAY_TYPE="VARIABLE", p_DELAY_VALUE=50, # 1/4 bit period (ambient temp)

                i_CLK=ClockSignal("serdes_5x"),
                i_RST=rx_delay_rst, i_LOAD=0,
                i_INC=rx_delay_inc, i_EN_VTC=rx_delay_en_vtc,
                i_CE=rx_delay_ce,

                i_IDATAIN=serdes_m_i_nodelay, o_DATAOUT=serdes_m_i_delayed
            ),
            Instance("ISERDESE3",
                p_DATA_WIDTH=8,

                i_D=serdes_m_i_delayed,
                i_RST=ResetSignal("serdes"),
                i_FIFO_RD_CLK=0, i_FIFO_RD_EN=0,
                i_CLK=ClockSignal("serdes_20x"), i_CLK_B=~ClockSignal("serdes_20x"),
                i_CLKDIV=ClockSignal("serdes_5x"),
                o_Q=serdes_m_q
            )
        ]
        self.comb += self.phase_detector.mdata.eq(serdes_m_q)

        serdes_s_i_delayed = Signal()
        serdes_s_q = Signal(8)
        self.specials += [
            Instance("IDELAYE3",
                p_CASCADE="NONE", p_UPDATE_MODE="ASYNC", p_REFCLK_FREQUENCY=200.0,
                p_IS_CLK_INVERTED=0, p_IS_RST_INVERTED=0,
                # Note: can't use TIME mode since not reloading DELAY_VALUE on rst...
                p_DELAY_FORMAT="COUNT", p_DELAY_SRC="IDATAIN",
                p_DELAY_TYPE="VARIABLE", p_DELAY_VALUE=100, # 1/2 bit period (ambient temp)

                i_CLK=ClockSignal("serdes_5x"),
                i_RST=rx_delay_rst, i_LOAD=0,
                i_INC=rx_delay_inc, i_EN_VTC=rx_delay_en_vtc,
                i_CE=rx_delay_ce,

                i_IDATAIN=serdes_s_i_nodelay, o_DATAOUT=serdes_s_i_delayed
            ),
            Instance("ISERDESE3",
                p_DATA_WIDTH=8,

                i_D=serdes_s_i_delayed,
                i_RST=ResetSignal("serdes"),
                i_FIFO_RD_CLK=0, i_FIFO_RD_EN=0,
                i_CLK=ClockSignal("serdes_20x"), i_CLK_B=~ClockSignal("serdes_20x"),
                i_CLKDIV=ClockSignal("serdes_5x"),
                o_Q=serdes_s_q
            )
        ]
        self.comb += self.phase_detector.sdata.eq(~serdes_s_q)

        self.comb += [
            self.rx_gearbox.i.eq(serdes_m_q),
            self.rx_bitslip.value.eq(rx_bitslip_value),
            self.rx_bitslip.i.eq(self.rx_gearbox.o),
            self.decoders[0].input.eq(self.rx_bitslip.o[0:10]),
            self.decoders[1].input.eq(self.rx_bitslip.o[10:20]),
            self.decoders[2].input.eq(self.rx_bitslip.o[20:30]),
            self.decoders[3].input.eq(self.rx_bitslip.o[30:40]),
            self.rx_data.eq(Cat(*[self.decoders[i].d for i in range(4)])),
            rx_idle.eq(self.rx_bitslip.o == 0),
            rx_comma.eq(((self.decoders[0].d == 0xbc) & (self.decoders[0].k == 1)) &
                        ((self.decoders[1].d == 0x00) & (self.decoders[1].k == 0)) &
                        ((self.decoders[2].d == 0x00) & (self.decoders[2].k == 0)) &
                        ((self.decoders[3].d == 0x00) & (self.decoders[3].k == 0)))

        ]
