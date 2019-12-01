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
    
    init<O>(_ options: O, hooks: SwiftHooks?) where O == Options
}

public protocol _Hook {
    func boot(on elg: EventLoopGroup) throws
    func shutdown()
    
    var hooks: SwiftHooks? { get set }
    static var id: HookID { get }
    var translator: EventTranslator.Type { get }
        
    func listen<T, I>(for event: T, handler: @escaping EventHandler<I>) where T: _Event, T.ContentType == I
    func dispatchEvent<E>(_ event: E, with raw: Data) where E: EventType
}

public protocol HookOptions { }

public extension SwiftHooks {
    func hook<H, O>(_ hook: H.Type, _ options: O) throws where H: Hook, H.Options == O {
        let hook = hook.init(options, hooks: self)
        self.hooks.append(hook)
    }
}
