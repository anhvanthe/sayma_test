from migen import *

class ChannelInterface:
    def __init__(self, encoder, decoders):
        self.rx_ready = Signal()
        self.encoder = encoder
        self.decoders = decoders


class TransceiverInterface:
    def __init__(self, channel_interfaces):
        self.channels = channel_interfaces
