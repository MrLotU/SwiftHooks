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
    
    func boot(on elg: EventLoopGroup) throws { }
    
    var closures: [TestEvent: [EventClosure]] = [:]
    
    func shutdown() { }
    
    var hooks: SwiftHooks?
    
    static let id: HookID = .test
    
    let translator: EventTranslator.Type = Translator.self
    
    class Translator: EventTranslator {
        static func translate<E>(_ event: E) -> GlobalEvent? where E : EventType {
            guard let event = event as? TestEvent else { return nil }
            switch event {
            case ._messageCreate: return ._messageCreate
            default: return nil
            }
        }
        
        static func decodeConcreteType<T>(for event: GlobalEvent, with data: Data, as t: T.Type) -> T? {
            switch event {
            case ._messageCreate: return TestMessage(data) as? T
            }
        }
    }
    
    init(_ options: _Options, hooks: SwiftHooks?) {
        self.hooks = hooks
    }
    
    func listen<T, I>(for event: T, handler: @escaping EventHandler<I>) where T : _Event, I == T.ContentType {
        guard let event = event as? _TestEvent<TestEvent, I> else { return }
        var closures = self.closures[event, default: []]
        closures.append { (data) in
            guard let object = I.init(data) else {
                SwiftHooks.logger.debug("Unable to extract \(I.self) from data.")
                return
            }
            try handler(object)
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

struct _TestEvent<E: EventType, ContentType: PayloadType>: _Event {
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
    public var id: IDable { return "" }
    public var mention: String { return "" }
    
    init() { }
}

struct TestMessage: Messageable {
    public var channel: Channelable { _channel }
    public var _channel: TestChannel
    public var content: String
    public var author: Userable { _author }
    public var _author: TestUser
    
    public init?(_ data: Data) {
        self._author = TestUser()
        self._channel = TestChannel()
        self.content = "!ping"
    }
    
    public func reply(_ content: String) { }
    public func edit(_ content: String) { }
    public func delete() { }
}
