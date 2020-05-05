import NIO

/// A generic channel used in `GlobalEvent`s.
public protocol Channelable: PayloadType {
    /// Mentions the channel. For example `#channelId`
    var mention: String { get }
    
    /// Sends a message to the channel.
    ///
    ///     let channel: Channelable = ...
    ///     channel.send("Hi! I'm a bot")
    ///
    /// - parameters:
    ///     - msg: Message content to send.
    /// - returns: The created message.
    @discardableResult
    func send(_ msg: String) -> EventLoopFuture<Messageable>
}
