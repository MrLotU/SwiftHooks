public protocol Channelable: PayloadType {
    var mention: String { get }
    func send(_ msg: String)
}
