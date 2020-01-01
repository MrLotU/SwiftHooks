import struct Foundation.Data

public typealias EventHandler<I> = (I) throws -> Void

public protocol EventType: Hashable {}

public protocol PayloadType: Decodable {
    static func create(from data: Data) -> Self?
}

public extension PayloadType {
    static func create(from data: Data) -> Self? {
        guard let g = try? SwiftHooks.decoder.decode(Self.self, from: data) else { return nil }
        return g
    }
}

public protocol _Event: Hashable {
    associatedtype ContentType: PayloadType
    associatedtype E: EventType
    var event: E { get }
    init(_ e: E, _ t: ContentType.Type)
}

extension _Event {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.event == rhs.event &&
            type(of: type(of: lhs).E.self) == type(of: type(of: rhs).E.self) &&
            type(of: type(of: lhs).ContentType.self) == type(of: type(of: rhs).ContentType.self)
    }
}

public protocol _GEvent: Hashable {
    associatedtype ContentType
    associatedtype E: EventType
    var event: E { get }
    init(_ e: E, _ t: ContentType.Type)
}

extension _GEvent {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.event == rhs.event &&
            type(of: type(of: lhs).E.self) == type(of: type(of: rhs).E.self) &&
            type(of: type(of: lhs).ContentType.self) == type(of: type(of: rhs).ContentType.self)
    }
}

public struct _GlobalEvent<E: EventType, ContentType>: _GEvent {
    public let event: E

    public init(_ e: E, _ t: ContentType.Type) {
        self.event = e
    }
}

public enum GlobalEvent: EventType {
    case _messageCreate
    
    public static let messageCreate = _GlobalEvent(GlobalEvent._messageCreate, Messageable.self)
}

public extension Dictionary {
    subscript <E>(_ t: E) -> Value? where E: _Event, Key == E.E {
        get {
            return self[t.event]
        }
        set {
            self[t.event] = newValue
        }
    }
    
    subscript <E>(_ t: E, default d: Value) -> Value where E: _Event, Key == E.E {
        get {
            return self[t.event] ?? d
        }
    }
    
    subscript <E>(_ t: E) -> Value? where E: _GEvent, Key == E.E {
        get {
            return self[t.event]
        }
        set {
            self[t.event] = newValue
        }
    }
    
    subscript <E>(_ t: E, default d: Value) -> Value where E: _GEvent, Key == E.E {
        get {
            return self[t.event] ?? d
        }
    }
}
