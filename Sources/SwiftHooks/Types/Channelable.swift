public protocol Channelable: Codable {    
    func asBaseChannel() -> BaseChannel
}

public struct BaseChannel {
    var mention: String
    
    public init(mention: String) {
        self.mention = mention
    }
    
    func send(_ msg: String) {
        
    }
}
