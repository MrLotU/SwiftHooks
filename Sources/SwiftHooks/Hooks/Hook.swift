import NIO
import Foundation

public struct HookID: Hashable {
    public let identifier: String
    public init(identifier: String) {
        self.identifier = identifier
    }
}

// Just an extra wrapper for fancy initialization that's all type safe. `_Hook` exists so we can put them in an array.

public protocol Hook: _Hook {
    associatedtype Options: HookOptions
    
    init<O>(_ options: O, _ elg: EventLoopGroup) where O == Options
}

public protocol _Hook {
    func boot(hooks: SwiftHooks?) throws
    func shutdown()
    
    var hooks: SwiftHooks? { get }
    var eventLoopGroup: EventLoopGroup { get }
    static var id: HookID { get }
        
    func listen<T, I, D>(for event: T, handler: @escaping EventHandler<D, I>) where T: _Event, T.ContentType == I, T.D == D
    func dispatchEvent<E>(_ event: E, with raw: Data) where E: EventType
    
    func translate<E>(_ event: E) -> GlobalEvent? where E: EventType
    func decodeConcreteType<T>(for event: GlobalEvent, with data: Data, as t: T.Type) -> T?
}

public extension _Hook {
    func boot() throws {
        try self.boot(hooks: nil)
    }
}

public protocol HookOptions { }

public extension SwiftHooks {
    func hook<H, O>(_ hook: H.Type, _ options: O) throws where H: Hook, H.Options == O {
        let hook = hook.init(options, self.eventLoopGroup)
        self.hooks.append(hook)
    }
}
