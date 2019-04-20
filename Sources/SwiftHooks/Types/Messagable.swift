public protocol Messageable {
    var channel: Channelable { get }
    var content: String { get }
    
    func reply(_ content: String)
    func edit(_ content: String)
    func delete()
}
