import NIO
import Foundation

extension HookID {
    static var discord: HookID {
        return .init(identifier: "discord")
    }
}

public final class DiscordHook: Hook {
    public typealias Options = DiscordHookOptions
    
    public init(_ options: DiscordHookOptions, hooks: SwiftHooks?) {
        self.token = options.token
        self.hooks = hooks
        self.discordListeners = [:]
    }
    public func boot(on elg: EventLoopGroup) throws {
        SwiftHooks.logger.info("Booting \(self.self)")
        let event = DiscordEvent._guildCreate
        let mEvent = DiscordEvent._messageCreate

        self.dispatchEvent(event, with: Data())
        self.dispatchEvent(mEvent, with: Data())
        
        elg.next().scheduleTask(in: .seconds(5)) {
            self.dispatchEvent(mEvent, with: Data())
        }
    }
    public func shutdown() { SwiftHooks.logger.info("Shutting down \(self.self)") }
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
        closures.append { (data) in
            guard let object = I.init(data) else {
                SwiftHooks.logger.debug("Unable to extract \(I.self) from data.")
                return
            }
            try handler(object)
        }
        self.discordListeners[event] = closures
    }
    
    public func dispatchEvent<E>(_ event: E, with raw: Data) where E: EventType {
        defer {
            self.hooks?.dispatchEvent(event, with: raw, from: self)
        }
        guard let event = event as? DiscordEvent else { return }
        let handlers = self.discordListeners[event]
        handlers?.forEach({ (handler) in
            do {
                try handler(raw)
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
    
    static func decodeConcreteType<T>(for event: GlobalEvent, with data: Data, as t: T.Type) -> T? {
        switch event {
        case ._messageCreate: return DiscordMessage(data) as? T
        }
    }
}

public struct DiscordHookOptions: HookOptions {
    public typealias H = DiscordHook
    
    var token: String
    
    public init(token: String) {
        self.token = token
    }
}

public struct _DiscordEvent<E: EventType, ContentType: PayloadType>: _Event {
    public let event: E
    public init(_ e: E, _ t: ContentType.Type) {
        self.event = e
    }
}

public struct Guild: Codable, PayloadType {
    public let name: String
    
    public init?(_ data: Data) {
        self.name = "abc"
    }
    
    public init(_ name: String) {
        self.name = name
    }
}

public struct DiscordChannel: Channelable {
    public func send(_ msg: String) { }
    public var mention: String { return "" }
    
    init() { }
}

public struct DiscordUser: Userable {
    public var id: IDable { return "" }
    public var mention: String { return "" }
    
    init() { }
}

public struct DiscordMessage: Messageable {
    public var channel: Channelable { _channel }
    public var _channel: DiscordChannel
    public var content: String
    public var author: Userable { _author }
    public var _author: DiscordUser
    
    public init?(_ data: Data) {
        self._author = DiscordUser()
        self._channel = DiscordChannel()
        self.content = "!ping"
    }
    
    public func reply(_ content: String) { }
    public func edit(_ content: String) { }
    public func delete() { }
}

public enum DiscordEvent: String, EventType {
    case _guildCreate = "GUILD_CREATE"
    case _messageCreate = "MESSAGE_CREATE"

    public static let guildCreate = _DiscordEvent(DiscordEvent._guildCreate, Guild.self)
    public static let messageCreate = _DiscordEvent(DiscordEvent._messageCreate, DiscordMessage.self)
}
