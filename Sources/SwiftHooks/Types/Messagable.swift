public protocol Messageable {
    var channel: Channelable { get }
    var content: String { get }
    var author: Userable { get }
    
    func reply(_ content: String)
    func edit(_ content: String)
    func delete()
}
