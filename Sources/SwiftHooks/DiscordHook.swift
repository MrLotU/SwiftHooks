public final class DiscordHook: Hook {
    public init<O>(_ options: O, hooks: SwiftHooks?) where DiscordHook == O.H, O : HookOptions {
        guard let options = options as? DiscordHookOptions else {
            fatalError("DiscordHook must always be initialized with `DiscordHookOptions`")
        }
        
        self.token = options.token
    }
    
    public func connect() throws { print("Connecting \(self.self)") }
    public func shutDown() throws { print("Shutting down \(self.self)") }
    
    var token: String
    
    public weak var hooks: SwiftHooks?
}

public struct DiscordHookOptions: HookOptions {
    public typealias H = DiscordHook
    
    var token: String
    
    public init(token: String) {
        self.token = token
    }
}

public struct DiscordMType<ContentType, E: EventType>: MType {
    public let event: E
    public init(_ e: E, _ t: ContentType.Type) {
        self.event = e
    }
}

public struct Guild {
    public let name: String
}

public enum DiscordEvent: EventType {
    case _guildCreate
    
    public static let guildCreate = DiscordMType(DiscordEvent._guildCreate, Guild.self)
}
