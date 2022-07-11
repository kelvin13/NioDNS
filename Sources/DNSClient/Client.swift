import NIO

public final class DNSClient: Resolver {
    let dnsDecoder: DNSDecoder
    let channel: Channel
    let primaryAddress: SocketAddress
    var loop: EventLoop {
        return channel.eventLoop
    }
    // Each query has an ID to keep track of which response belongs to which query
    var messageID: UInt16 = 0
    
    internal init(channel: Channel, address: SocketAddress, decoder: DNSDecoder) {
        self.channel = channel
        self.primaryAddress = address
        self.dnsDecoder = decoder
    }
    
    public init(channel: Channel, dnsServerAddress: SocketAddress, context: DNSClientContext) {
        self.channel = channel
        self.primaryAddress = dnsServerAddress
        self.dnsDecoder = context.decoder
    }

    deinit {
        _ = self.close()
    }
    
    public func close() -> EventLoopFuture<Void> {
        self.channel.close(mode: .all)
    }
}

public struct DNSClientContext {
    internal let decoder: DNSDecoder
    
    public init(eventLoopGroup: EventLoopGroup) {
        self.decoder = DNSDecoder(group: eventLoopGroup)
    }
}

struct SentQuery {
    let message: Message
    let promise: EventLoopPromise<Message>
}
