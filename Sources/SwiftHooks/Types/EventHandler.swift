public typealias EventHandler<I> = (I) throws -> Void

public protocol EventType: Hashable {}

public protocol MType: Hashable {
    associatedtype ContentType
    associatedtype E: EventType
    var event: E { get }
    init(_ e: E, _ t: ContentType.Type)
}

extension MType {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.event == rhs.event &&
            type(of: type(of: lhs).E.self) == type(of: type(of: rhs).E.self) &&
            type(of: type(of: lhs).ContentType.self) == type(of: type(of: rhs).ContentType.self)
    }
}

public enum Event {
    public static var messageCreate: GlobalMType<Messageable, GlobalEvent> {
        return GlobalEvent.messageCreate
    }
}

public struct GlobalMType<ContentType, E: EventType>: MType {
    public let event: E

    public init(_ e: E, _ t: ContentType.Type) {
        self.event = e
    }
}

public enum GlobalEvent: EventType {
    case _messageCreate
    
    public static let messageCreate = GlobalMType(GlobalEvent._messageCreate, Messageable.self)
}

public extension Dictionary {
    subscript <E>(_ t: E) -> Value? where E: MType, Key == E.E {
        get {
            return self[t.event]
        }
        set {
            self[t.event] = newValue
        }
    }
    
    subscript <E>(_ t: E, default d: Value) -> Value where E: MType, Key == E.E {
        get {
            return self[t.event] ?? d
        }
    }
}
