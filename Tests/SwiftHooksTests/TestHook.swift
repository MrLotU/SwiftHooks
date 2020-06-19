import Foundation
import NIO
import NIOConcurrencyHelpers
import SwiftHooks

extension HookID {
    static var test: HookID {
        return .init(identifier: "test")
    }
}

final class TestHook: Hook {
    var user: Userable? { nil }
        
    struct _Options: HookOptions { }
    typealias Options = _Options
    
    var closures: [TestEvent: [EventClosure]] = [:]
    let lock = Lock()
    
    func shutdown() { }
    
    var hooks: SwiftHooks?
    
    static let id: HookID = .test
    
    init(_ options: _Options, _ elg: EventLoopGroup) {
        self.eventLoopGroup = elg
    }

    func boot(hooks: SwiftHooks?) throws {
        self.hooks = hooks
    }

    var eventLoopGroup: EventLoopGroup

    func translate<E>(_ event: E) -> GlobalEvent? where E : EventType {
        guard let event = event as? TestEvent else { return nil }
        switch event {
        case ._messageCreate: return ._messageCreate
        default: return nil
        }
    }

    func decodeConcreteType<T>(for event: GlobalEvent, with data: Data, as t: T.Type, on eventLoop: EventLoop) -> T? {
        switch event {
        case ._messageCreate: return TestMessage.create(from: data, on: self, on: eventLoop) as? T
        }
    }
    
    func listen<T, I, D>(for event: T, handler: @escaping EventHandler<D, I>) where T : _Event, I == T.ContentType, T.D == D {
        guard let event = event as? _TestEvent<I> else { return }
        var closures = self.closures[event, default: []]
        closures.append { (data, el) in
            guard let object = I.create(from: data, on: self, on: el) else {
                SwiftHooks.logger.debug("Unable to extract \(I.self) from data.")
                return el.makeFailedFuture(SwiftHooksError.GenericTypeCreationFailure("\(I.self)"))
            }
            guard let d = D.init(self, eventLoop: el) else {
                SwiftHooks.logger.debug("Unable to wrap \(I.self) in \(D.self) dispatch.")
                return el.makeFailedFuture(SwiftHooksError.DispatchCreationError)
            }
            return handler(d, object)
        }
        self.closures[event] = closures
    }
    
    func dispatchEvent<E>(_ event: E, with raw: Data, on eventLoop: EventLoop) -> EventLoopFuture<Void> where E : EventType {
        func unwrapAndFuture(_ x: Void = ()) -> EventLoopFuture<Void> {
            if let hooks = self.hooks {
                return hooks.dispatchEvent(event, with: raw, from: self, on: eventLoop)
            } else {
                return eventLoop.makeSucceededFuture(())
            }
        }
        guard let event = event as? TestEvent else { return unwrapAndFuture() }
        let futures = self.lock.withLock { () -> [EventLoopFuture<Void>] in
            let handlers = self.closures[event] ?? []
            return handlers.map({ (handler) in
                return handler(raw, eventLoop)
            })
        }
        return EventLoopFuture.andAllSucceed(futures, on: eventLoop).flatMap(unwrapAndFuture)
    }
}

struct TestDispatch: EventDispatch {
    var eventLoop: EventLoop
    
    init?(_ h: _Hook, eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
}

struct _TestEvent<ContentType: PayloadType>: _Event {
    typealias E = TestEvent
    typealias D = TestDispatch
    public let event: E
    public init(_ e: E, _ t: ContentType.Type) {
        self.event = e
    }
}

enum TestEvent: String, EventType {
    case _test = "TEST"
    case _messageCreate = "MESSAGE_CREATE"

    public static let test = _TestEvent(TestEvent._test, Test.self)
    public static let messageCreate = _TestEvent(TestEvent._messageCreate, TestMessage.self)
}

struct Test: PayloadType {
    var test: String { "test" }
}

struct TestChannel: Channelable {
    public func send(_ msg: String) -> EventLoopFuture<Messageable> { fatalError() }
    public var mention: String { return "" }
    
    init() { }
}

struct TestUser: Userable {
    var mention: String { "" }
    
    var identifier: String? { nil }
}

struct TestMessage: Messageable {
    var gChannel: Channelable { fatalError() }
    
    var gAuthor: Userable { fatalError() }
    
    public var channel: Channelable { _channel }
    public var _channel: TestChannel
    public var content: String
    public var author: Userable { _author }
    public var _author: TestUser
    
    static func create(from data: Data, on _: _Hook, on _: EventLoop) -> TestMessage? {
        return TestMessage(data)
    }
    
    public init?(_ data: Data) {
        self._author = TestUser()
        self._channel = TestChannel()
        self.content = "!ping"
    }
    
    public func reply(_ content: String) -> EventLoopFuture<Messageable> { fatalError() }
    public func edit(_ content: String) -> EventLoopFuture<Messageable> { fatalError() }
    public func delete() -> EventLoopFuture<Void> { fatalError() }
}
