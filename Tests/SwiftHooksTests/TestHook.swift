import Foundation
import NIO
import SwiftHooks

extension HookID {
    static var test: HookID {
        return .init(identifier: "test")
    }
}

final class TestHook: Hook {
    struct _Options: HookOptions { }
    typealias Options = _Options
    
    var closures: [TestEvent: [EventClosure]] = [:]
    
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

    func decodeConcreteType<T>(for event: GlobalEvent, with data: Data, as t: T.Type) -> T? {
        switch event {
        case ._messageCreate: return TestMessage.create(from: data, on: self) as? T
        }
    }
    
    func listen<T, I, D>(for event: T, handler: @escaping EventHandler<D, I>) where T : _Event, I == T.ContentType, T.D == D {
        guard let event = event as? _TestEvent<I> else { return }
        var closures = self.closures[event, default: []]
        closures.append { (data) in
            guard let object = I.create(from: data, on: self) else {
                SwiftHooks.logger.debug("Unable to extract \(I.self) from data.")
                return
            }
            guard let d = D.init(self) else {
                SwiftHooks.logger.debug("Unable to wrap \(I.self) in \(D.self) dispatch.")
                return
            }
            try handler(d, object)
        }
        self.closures[event] = closures
    }
    
    func dispatchEvent<E>(_ event: E, with raw: Data) where E : EventType {
        defer {
            self.hooks?.dispatchEvent(event, with: raw, from: self)
        }
        guard let event = event as? TestEvent else { return }
        let handlers = self.closures[event]
        handlers?.forEach({ (handler) in
            do {
                try handler(raw)
            } catch {
                SwiftHooks.logger.error("\(error.localizedDescription)")
            }
        })
    }
}

struct TestDispatch: EventDispatch {
    var eventLoop: EventLoop
    
    init?(_ h: _Hook) {
        guard let h = h as? TestHook else { return nil }
        self.eventLoop = h.eventLoopGroup.next()
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
    public func send(_ msg: String) { }
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
    
    static func create(from data: Data, on _: _Hook) -> TestMessage? {
        return TestMessage(data)
    }
    
    public init?(_ data: Data) {
        self._author = TestUser()
        self._channel = TestChannel()
        self.content = "!ping"
    }
    
    public func reply(_ content: String) { }
    public func edit(_ content: String) { }
    public func delete() { }
}
