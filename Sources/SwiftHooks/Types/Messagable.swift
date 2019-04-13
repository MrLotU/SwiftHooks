public protocol Messageable {
    var channel: Channelable { get }
    var content: String { get }
    
    func reply(_ msg: Messageable)
}
