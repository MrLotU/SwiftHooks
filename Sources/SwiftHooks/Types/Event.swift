import struct Foundation.Data
import protocol NIO.EventLoop

public typealias EventHandler<D: EventDispatch, I> = (D, I) throws -> Void

public protocol EventDispatch {
    var eventLoop: EventLoop { get }
    
    init?(_ h: _Hook)
}

public protocol EventType: Hashable {}

public protocol PayloadType: Decodable {
    static func create(from data: Data, on h: _Hook) -> Self?
}

public extension PayloadType {
    static func create(from data: Data, on _: _Hook) -> Self? {
        do {
            return try SwiftHooks.decoder.decode(Self.self, from: data)
        } catch {
            SwiftHooks.logger.debug("Decoding error: \(error), \(error.localizedDescription)")
            return nil
        }
    }
}

public protocol _Event: Hashable {
    associatedtype ContentType: PayloadType
    associatedtype E: EventType
    associatedtype D: EventDispatch
    var event: E { get }
}

extension _Event {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.event == rhs.event &&
            type(of: type(of: lhs).E.self) == type(of: type(of: rhs).E.self) &&
            type(of: type(of: lhs).ContentType.self) == type(of: type(of: rhs).ContentType.self)
    }
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
}
