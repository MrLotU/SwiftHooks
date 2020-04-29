import NIO

public protocol Channelable: PayloadType {
    var mention: String { get }
    @discardableResult
    func send(_ msg: String) -> EventLoopFuture<Messageable>
}
