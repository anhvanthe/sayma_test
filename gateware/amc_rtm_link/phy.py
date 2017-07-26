from litex.gen import *
from litex.gen.genlib.cdc import MultiReg, PulseSynchronizer
from litex.gen.genlib.misc import WaitTimer

from litex.soc.interconnect.csr import *


class PhaseDetector(Module, AutoCSR):
    def __init__(self, nbits=8):
        self.mdata = Signal(8)
        self.sdata = Signal(8)

        self.reset = CSR()
        self.status = CSRStatus(2)

        # # #

        # ideal sampling (middle of the eye):
        #  _____       _____       _____
        # |     |_____|     |_____|     |_____|   data
        #    +     +     +     +     +     +      master sampling
        #       -     -     -     -     -     -   slave sampling (90°/bit period)
        # Since taps are fixed length delays, this ideal case is not possible
        # and we will fall in the 2 following possible cases:
        #
        # 1) too late sampling (idelay needs to be decremented):
        #  _____       _____       _____
        # |     |_____|     |_____|     |_____|   data
        #     +     +     +     +     +     +     master sampling
        #        -     -     -     -     -     -  slave sampling (90°/bit period)
        # on mdata transition, mdata != sdata
        #
        #
        # 2) too early sampling (idelay needs to be incremented):
        #  _____       _____       _____
        # |     |_____|     |_____|     |_____|   data
        #   +     +     +     +     +     +       master sampling
        #      -     -     -     -     -     -    slave sampling (90°/bit period)
        # on mdata transition, mdata == sdata

        transition = Signal()
        inc = Signal()
        dec = Signal()

        # find transition
        mdata_d = Signal(8)
        self.sync.serdes_5x += mdata_d.eq(self.mdata)
        self.comb += transition.eq(mdata_d != self.mdata)


        # find what to do
        self.comb += [
            inc.eq(transition & (self.mdata == self.sdata)),
            dec.eq(transition & (self.mdata != self.sdata))
        ]

        # error accumulator
        lateness = Signal(nbits, reset=2**(nbits - 1))
        too_late = Signal()
        too_early = Signal()
        reset_lateness = Signal()
        self.comb += [
            too_late.eq(lateness == (2**nbits - 1)),
            too_early.eq(lateness == 0)
        ]
        self.sync.serdes_5x += [
            If(reset_lateness,
                lateness.eq(2**(nbits - 1))
            ).Elif(~too_late & ~too_early,
                If(inc, lateness.eq(lateness - 1)),
                If(dec, lateness.eq(lateness + 1))
            )
        ]

        # control / status cdc
        self.specials += MultiReg(Cat(too_late, too_early), self.status.status)
        self.submodules.do_reset_lateness = PulseSynchronizer("sys", "serdes_5x")
        self.comb += [
            reset_lateness.eq(self.do_reset_lateness.o),
            self.do_reset_lateness.i.eq(self.reset.re)
        ]


# serdes master <--> slave synchronization:
# 1) master sends idle pattern (zeroes) to reset slave.
# 2) master sends K28.5 commas to allow slave to synchronize, slave sends idle pattern.
# 3) slave sends K28.5 commas to allow master to synchronize, master sends K28.5 commas.
# 4) master stops sending K28.5 commas.
# 5) slave stops sending K25.5 commas.
# 6) link is ready.

class SerdesMasterInit(Module):
    def __init__(self, serdes, taps):
        self.reset = Signal()
        self.error = Signal()
        self.ready = Signal()

        # # #

        self.delay = delay = Signal(max=taps)
        self.delay_min = delay_min = Signal(max=taps)
        self.delay_min_found = delay_min_found = Signal()
        self.delay_max = delay_max = Signal(max=taps)
        self.delay_max_found = delay_max_found = Signal()
        self.bitslip = bitslip = Signal(max=40)

        timer = WaitTimer(1024)
        self.submodules += timer

        self.submodules.fsm = fsm = ResetInserter()(FSM(reset_state="IDLE"))
        self.comb += self.fsm.reset.eq(self.reset)

        fsm.act("IDLE",
            NextValue(delay, 0),
            NextValue(delay_min, 0),
            NextValue(delay_min_found, 0),
            NextValue(delay_max, 0),
            NextValue(delay_max_found, 0),
            serdes.rx_delay_rst.eq(1),
            NextValue(bitslip, 0),
            NextState("RESET_SLAVE"),
            serdes.tx_idle.eq(1)
        )
        fsm.act("RESET_SLAVE",
            timer.wait.eq(1),
            If(timer.done,
                timer.wait.eq(0),
                NextState("SEND_PATTERN")
            ),
            serdes.tx_idle.eq(1)
        )
        fsm.act("SEND_PATTERN",
            If(~serdes.rx_idle,
                NextState("WAIT_STABLE")
            ),
            serdes.tx_comma.eq(1)
        )
        fsm.act("WAIT_STABLE",
            timer.wait.eq(1),
            If(timer.done,
                timer.wait.eq(0),
                NextState("CHECK_PATTERN")
            ),
            serdes.tx_comma.eq(1)
        )
        fsm.act("CHECK_PATTERN",
            If(~delay_min_found,
                If(serdes.rx_comma,
                    timer.wait.eq(1),
                    If(timer.done,
                        NextValue(delay_min, delay),
                        NextValue(delay_min_found, 1)
                    )
                ).Else(
                    NextState("INC_DELAY_BITSLIP")
                ),
            ).Else(
                If(~serdes.rx_comma,
                    NextValue(delay_max, delay),
                    NextValue(delay_max_found, 1),
                    NextState("RESET_SAMPLING_WINDOW")
                ).Else(
                    NextState("INC_DELAY_BITSLIP")
                )
            ),
            serdes.tx_comma.eq(1)
        )
        self.comb += serdes.rx_bitslip_value.eq(bitslip)
        fsm.act("INC_DELAY_BITSLIP",
            NextState("WAIT_STABLE"),
            If(delay == (taps - 1),
                If(delay_min_found,
                    NextState("ERROR")
                ),
                If(bitslip == (40 - 1),
                    NextValue(bitslip, 0)
                ).Else(    
                    NextValue(bitslip, bitslip + 1)
                ),
                NextValue(delay, 0),
                serdes.rx_delay_rst.eq(1)
            ).Else(
                NextValue(delay, delay + 1),
                serdes.rx_delay_inc.eq(1),
                serdes.rx_delay_ce.eq(1)
            ),
            serdes.tx_comma.eq(1)
        )
        fsm.act("RESET_SAMPLING_WINDOW",
            NextValue(delay, 0),
            serdes.rx_delay_rst.eq(1),
            NextState("WAIT_SAMPLING_WINDOW"),
            serdes.tx_comma.eq(1)
        )
        fsm.act("CONFIGURE_SAMPLING_WINDOW",
            If(delay == (delay_min + (delay_max - delay_min)[1:]),
                NextState("READY")
            ).Else(
                NextValue(delay, delay + 1),
                serdes.rx_delay_inc.eq(1),
                serdes.rx_delay_ce.eq(1),
                NextState("WAIT_SAMPLING_WINDOW")
            ),
            serdes.tx_comma.eq(1)
        )
        fsm.act("WAIT_SAMPLING_WINDOW",
            timer.wait.eq(1),
            If(timer.done,
                timer.wait.eq(0),
                NextState("CONFIGURE_SAMPLING_WINDOW")
            ),
            serdes.tx_comma.eq(1)
        )
        fsm.act("READY",
            self.ready.eq(1)
        )
        fsm.act("ERROR",
            self.error.eq(1)
        )


class SerdesSlaveInit(Module, AutoCSR):
    def __init__(self, serdes, taps):
        self.reset = Signal()
        self.ready = Signal()
        self.error = Signal()

        # # #

        self.delay = delay = Signal(max=taps)
        self.delay_min = delay_min = Signal(max=taps)
        self.delay_min_found = delay_min_found = Signal()
        self.delay_max = delay_max = Signal(max=taps)
        self.delay_max_found = delay_max_found = Signal()
        self.bitslip = bitslip = Signal(max=40)

        timer = WaitTimer(1024)
        self.submodules += timer

        self.comb += self.reset.eq(serdes.rx_idle)

        self.submodules.fsm = fsm = ResetInserter()(FSM(reset_state="IDLE"))
        fsm.act("IDLE",
            NextValue(delay, 0),
            NextValue(delay_min, 0),
            NextValue(delay_min_found, 0),
            NextValue(delay_max, 0),
            NextValue(delay_max_found, 0),
            serdes.rx_delay_rst.eq(1),
            NextValue(bitslip, 0),
            NextState("WAIT_STABLE"),
            serdes.tx_idle.eq(1)
        )
        fsm.act("WAIT_STABLE",
            timer.wait.eq(1),
            If(timer.done,
                timer.wait.eq(0),
                NextState("CHECK_PATTERN")
            ),
            serdes.tx_idle.eq(1)
        )
        fsm.act("CHECK_PATTERN",
            If(~delay_min_found,
                If(serdes.rx_comma,
                    timer.wait.eq(1),
                    If(timer.done,
                        timer.wait.eq(0),
                        NextValue(delay_min, delay),
                        NextValue(delay_min_found, 1)
                    )
                ).Else(
                    NextState("INC_DELAY_BITSLIP")
                ),
            ).Else(
                If(~serdes.rx_comma,
                    NextValue(delay_max, delay),
                    NextValue(delay_max_found, 1),
                    NextState("RESET_SAMPLING_WINDOW")
                ).Else(
                    NextState("INC_DELAY_BITSLIP")
                )
            ),
            serdes.tx_idle.eq(1)
        )
        self.comb += serdes.rx_bitslip_value.eq(bitslip)
        fsm.act("INC_DELAY_BITSLIP",
            NextState("WAIT_STABLE"),
            If(delay == (taps - 1),
                If(delay_min_found,
                    NextState("ERROR")
                ),
                If(bitslip == (40 - 1),
                    NextValue(bitslip, 0)
                ).Else(    
                    NextValue(bitslip, bitslip + 1)
                ),
                NextValue(delay, 0),
                serdes.rx_delay_rst.eq(1)
            ).Else(
                NextValue(delay, delay + 1),
                serdes.rx_delay_inc.eq(1),
                serdes.rx_delay_ce.eq(1)
            ),
            serdes.tx_idle.eq(1)
        )
        fsm.act("RESET_SAMPLING_WINDOW",
            NextValue(delay, 0),
            serdes.rx_delay_rst.eq(1),
            NextState("WAIT_SAMPLING_WINDOW")
        )
        fsm.act("CONFIGURE_SAMPLING_WINDOW",
            If(delay == (delay_min + (delay_max - delay_min)[1:]),
                NextState("SEND_PATTERN")
            ).Else(
                NextValue(delay, delay + 1),
                serdes.rx_delay_inc.eq(1),
                serdes.rx_delay_ce.eq(1),
                NextState("WAIT_SAMPLING_WINDOW")
            )
        )
        fsm.act("WAIT_SAMPLING_WINDOW",
            timer.wait.eq(1),
            If(timer.done,
                timer.wait.eq(0),
                NextState("CONFIGURE_SAMPLING_WINDOW")
            )
        )
        fsm.act("SEND_PATTERN",
            timer.wait.eq(1),
            If(timer.done,
                If(~serdes.rx_comma,
                    NextState("READY")
                )
            ),
            serdes.tx_comma.eq(1)
        )
        fsm.act("READY",
            self.ready.eq(1)
        )
        fsm.act("ERROR",
            self.error.eq(1)
        )


class SerdesControl(Module, AutoCSR):
    def __init__(self, init, mode="master"):
        if mode == "master":
            self.reset = CSR()
        self.ready = CSRStatus()
        self.error = CSRStatus()

        self.delay = CSRStatus(9)
        self.delay_min_found = CSRStatus()
        self.delay_min = CSRStatus(9)
        self.delay_max_found = CSRStatus()
        self.delay_max = CSRStatus(9)
        self.bitslip = CSRStatus(6)

        # # #

        if mode == "master":
            self.comb += init.reset.eq(self.reset.re)
        self.comb += [
            self.ready.status.eq(init.ready),
            self.error.status.eq(init.error),
            self.delay.status.eq(init.delay),
            self.delay_min_found.status.eq(init.delay_min_found),
            self.delay_min.status.eq(init.delay_min),
            self.delay_max_found.status.eq(init.delay_max_found),
            self.delay_max.status.eq(init.delay_max),
            self.bitslip.status.eq(init.bitslip)
        ]
