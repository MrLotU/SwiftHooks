import Foundation

extension HookID {
    static var discord: HookID {
        return .init(identifier: "discord")
    }
}

public final class DiscordHook: Hook {
    public init<O>(_ options: O, hooks: SwiftHooks?) where DiscordHook == O.H, O : HookOptions {
        guard let options = options as? DiscordHookOptions else {
            fatalError("DiscordHook must always be initialized with `DiscordHookOptions`")
        }
        
        self.token = options.token
        self.hooks = hooks
        self.discordListeners = [:]
    }
    
    public func boot() throws { SwiftHooks.logger.info("Connecting \(self.self)") }
    public func shutDown() throws { SwiftHooks.logger.info("Shutting down \(self.self)") }
    public static let id: HookID = .discord
    public var translator: EventTranslator.Type {
        return DiscordEventTranslator.self
    }

    var token: String
    
    public internal(set) var discordListeners: [DiscordEvent: [EventClosure]]
    
    public weak var hooks: SwiftHooks?
    
    public func listen<T, I>(for event: T, handler: @escaping EventHandler<I>) where T : _Event, I == T.ContentType {
        guard let event = event as? _DiscordEvent<DiscordEvent, I> else { return }
        var closures = self.discordListeners[event, default: []]
        closures.append { (event, data) in
            guard let object = event.getData(I.self, from: data) else {
                SwiftHooks.logger.debug("Unable to extract \(I.self) from data.")
                return
            }
            try handler(object)
        }
        self.discordListeners[event] = closures
    }
    
    public func dispatchEvent<E>(_ event: E, with payload: Payload, raw: Data) where E: EventType {
        defer {
            self.hooks?.dispatchEvent(event, with: payload, raw: raw)
        }
        guard let event = event as? DiscordEvent else { return }
        let handlers = self.discordListeners[event]
        handlers?.forEach({ (handler) in
            do {
                try handler(payload, raw)
            } catch {
                SwiftHooks.logger.error("\(error.localizedDescription)")
            }
        })
    }
}

class DiscordEventTranslator: EventTranslator {
    static func translate<E>(_ event: E) -> GlobalEvent? where E : EventType {
        guard let e = event as? DiscordEvent else { return nil }
        switch e {
        case ._messageCreate: return ._messageCreate
        default: return nil
        }
    }
    
//    static func decodableTypeForEvent<E, T>(_ event: E) -> T.Type? where E : EventType, T: Decodable {
//        guard let e = event as? DiscordEvent else { return nil }
//        switch e {
//        case ._messageCreate: return DiscordMessage.self
//        case ._guildCreate: return Guild.self
//        }
//    }
}

public struct DiscordHookOptions: HookOptions {
    public typealias H = DiscordHook
    
    var token: String
    
    public init(token: String) {
        self.token = token
    }
}

public struct _DiscordEvent<E: EventType, ContentType>: _Event {
    public let event: E
    public init(_ e: E, _ t: ContentType.Type) {
        self.event = e
    }
}

public struct Guild: Codable {
    public let name: String
    
    public init(_ name: String) {
        self.name = name
    }
}

public struct DiscordChannel: Channelable {
    public func send(_ msg: String) { }
    public var mention: String { return "" }
    public func asBaseChannel() -> BaseChannel {
        return BaseChannel(mention: self.mention)
    }
}

public struct DiscordUser: Userable {
    public var id: IDable { return "" }
    public var mention: String { return "" }
    
    public func asBaseUser() -> BaseUser {
        return BaseUser(id: self.id, mention: self.mention)
    }
}

public struct DiscordMessage: Messageable {
    public static var concreteType: Decodable.Type = DiscordMessage.self
    public var channel: DiscordChannel
    public var content: String
    public var author: DiscordUser
    
    public func reply(_ content: String) { }
    public func edit(_ content: String) { }
    public func delete() { }
    
    public func asBaseMessage() -> BaseMessage {
        return BaseMessage(channel: self.channel.asBaseChannel(), content: self.content, author: self.author.asBaseUser())
    }
}

public enum DiscordEvent: String, EventType {
    case _guildCreate = "GUILD_CREATE"
    case _messageCreate = "MESSAGE_CREATE"

    public static let guildCreate = _DiscordEvent(DiscordEvent._guildCreate, Guild.self)
    public static let messageCreate = _DiscordEvent(DiscordEvent._messageCreate, DiscordMessage.self)
}
