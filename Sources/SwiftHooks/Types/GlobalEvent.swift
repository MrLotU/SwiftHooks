import protocol NIO.EventLoop

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

public struct _GlobalEvent<ContentType>: _GEvent {
    public typealias E = GlobalEvent
    public typealias D = GlobalDispatch
    public let event: E

    public init(_ e: E, _ t: ContentType.Type) {
        self.event = e
    }
}

public struct GlobalDispatch: EventDispatch {
    public init?(_ h: _Hook) {
        return nil
    }
    
    public init(_ eventLoop: EventLoop) { self.eventLoop = eventLoop }
    
    public let eventLoop: EventLoop
}

public enum GlobalEvent: EventType {
    case _messageCreate
    
    public static let messageCreate = _GlobalEvent(GlobalEvent._messageCreate, Messageable.self)
}

extension Dictionary {
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
