public protocol Messageable: PayloadType {
    var gChannel: Channelable { get }
    var content: String { get }
    var gAuthor: Userable { get }
        
    func reply(_ content: String)
    func edit(_ content: String)
    func delete()
}
