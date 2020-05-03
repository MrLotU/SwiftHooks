import NIO
import Foundation

/// Used to identify hooks.
public struct HookID: Hashable {
    public let identifier: String
    public init(identifier: String) {
        self.identifier = identifier
    }
}

// Just an extra wrapper for fancy initialization that's all type safe. `_Hook` exists so we can put them in an array.

///  A Hook within `SwiftHooks` is a backend implementation emitting events. For example Discord, Slack or GitHub
public protocol Hook: _Hook {
    associatedtype Options: HookOptions
    
    /// Create a new instance of `Hook` using it's `Options`.
    init<O>(_ options: O, _ elg: EventLoopGroup) where O == Options
}

/// Base hook type. Non-generic to be stored in arrays. See `Hook` for generic version.
public protocol _Hook {
    /// Boot hook.
    ///
    /// This should set up a connection to the Hook's backend.
    ///
    /// - parameters:
    ///     - hooks: `SwiftHooks` instance. Will be nil when used standalone.
    func boot(hooks: SwiftHooks?) throws
    
    /// Shut down hook.
    ///
    /// This should gracefully close the connection to the Hook's backend.
    func shutdown()
    
    /// Refference to the main `SwiftHooks` class.
    var hooks: SwiftHooks? { get }
    /// EventLoopGroup this hook is running on. If not used standalone, this will be shared with the main `SwiftHooks` class.
    var eventLoopGroup: EventLoopGroup { get }
    /// Identifier of the hook. See `HookID`
    static var id: HookID { get }
        
    /// Register a new `Listener` to this hook.
    ///
    /// - parameters:
    ///     - event: Event to listen for
    ///     - handler: Closure to call when receiving event `T`
    func listen<T, I, D>(for event: T, handler: @escaping EventHandler<D, I>) where T: _Event, T.ContentType == I, T.D == D
    
    /// Dispatch an event.
    ///
    /// This function should invoke all listeners listening for `E`, and signal the event to the main `SwiftHooks` class.
    func dispatchEvent<E>(_ event: E, with raw: Data) where E: EventType
    
    /// Used for global events.
    ///
    /// Translates a generic, hook specific, event into a `GlobalEvent` instance.
    func translate<E>(_ event: E) -> GlobalEvent? where E: EventType
    
    /// Used for global events.
    ///
    /// Gets a concrete type for a global event, type-erased to a protocol.
    func decodeConcreteType<T>(for event: GlobalEvent, with data: Data, as t: T.Type) -> T?
}

public extension _Hook {
    /// Identifier of the hook. See `HookID`
    var id: HookID {
        type(of: self).id
    }
    
    /// Standalone boot this hook.
    ///
    /// For when you don't need the main `SwiftHooks` class.
    func boot() throws {
        try self.boot(hooks: nil)
    }
}

public protocol HookOptions { }

public extension SwiftHooks {
    /// Add a `Hook` to the `SwiftHooks` class.
    ///
    ///     try swiftHooks.hook(MyHook.self, MyHookOptions(...))
    ///
    /// - parameters:
    ///     - hook: Hook type to connect.
    ///     - options: Options required to initialize the hook.
    func hook<H, O>(_ hook: H.Type, _ options: O) throws where H: Hook, H.Options == O {
        let hook = hook.init(options, self.eventLoopGroup)
        self.hooks.append(hook)
    }
}
