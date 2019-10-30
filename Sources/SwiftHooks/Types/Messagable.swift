public protocol Messageable: Codable, SwiftHooksPayloadType {
    func asBaseMessage() -> BaseMessage
}


public struct BaseMessage {
    public var channel: BaseChannel
    public var content: String
    public var author: BaseUser
    
    public init(channel: BaseChannel, content: String, author: BaseUser) {
        self.channel = channel
        self.content = content
        self.author = author
    }
    
    public func reply(_ content: String) {
        
    }
    
    public func edit(_ content: String) {
        
    }
    
    public func delete() {
        
    }
}
