import Foundation
import NIO
import Logging

/// Main SwiftHooks class. Acts as global controller.
///
///     let swiftHooks = SwiftHooks()
///
/// Hooks and Plugins are both connected to the main SwiftHooks class.
public final class SwiftHooks {
    /// EventLoopGroup this application runs on.
    public let eventLoopGroup: EventLoopGroup
    /// Wether or not `SwiftHooks` did shutdown.
    public private(set) var didShutdown: Bool
    private var isBooted: Bool
    private var running: EventLoopPromise<Void>?
    /// Config used for this `SwiftHooks` instance.
    public let config: SwiftHooksConfig
    
    /// Registered `_Hook`s.
    public internal(set) var hooks: [_Hook]
    /// Registered `GlobalListener`s.
    public internal(set) var globalListeners: [GlobalEvent: [GlobalEventClosure]]
    /// Registered `ExecutableCommand`s
    public internal(set) var commands: [_ExecutableCommand]
    /// Registered `Plugin`s.
    public internal(set) var plugins: [_Plugin]
    
    /// Global `JSONDecoder`
    public static let decoder = JSONDecoder()
    /// Global `JSONEncoder`
    public static let encoder = JSONEncoder()
    
    /// Create a new `SwiftHooks` instance
    ///
    /// - parameters:
    ///     - eventLoopGroup: EventLoopGroup to run SwiftHooks on. If not passed in a new one will be created.
    ///     - config: Configuration to use. Defaults to `SwiftHooksConfig.default`
    public init(eventLoopGroup: EventLoopGroup? = nil, config: SwiftHooksConfig = .default) {
        if let elg = eventLoopGroup {
            self.eventLoopGroup = elg
        } else {
            self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        }
        self.didShutdown = false
        self.isBooted = false
        
        self.hooks = []
        self.globalListeners = [:]
        self.commands = []
        self.plugins = []
        self.config = config
    }
    
    /// Run the SwiftHooks process. Will boot all connected `Hook`s and block forever.
    public func run() throws {
        defer { self.shutdown() }
        if running == nil {
            running = eventLoopGroup.next().makePromise(of: Void.self)
        }
        
        do {
            try self.boot()
            try running?.futureResult.wait()
        } catch {
            logger.error("Block error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func boot() throws {
        guard !self.isBooted else { return }
        logger.info("Booting SwiftHooks")
        self.isBooted = true
        try self.hooks.forEach { try $0.boot(hooks: self) }
    }
    
    func shutdown() {
        assert(!self.didShutdown, "SwiftHooks already shut down")
        self.hooks.forEach { $0.shutdown() }
        self.didShutdown = true
        self.logger.trace("Shutdown complete.")
    }

    /// Connect a new `_Hook` to the SwiftHooks system.
    ///
    /// - parameters:
    ///     - hook: Instance of `_Hook` or `Hook`
    public func hook(_ hook: _Hook) throws {
        self.hooks.append(hook)
    }
    
    deinit {
        self.logger.trace("SwiftHooks deinitialized. Goodbye")
        if !self.didShutdown {
            assertionFailure("SwiftHooks.shutdown() was not called before SwiftHooks deinitialized")
        }
    }
}

extension SwiftHooks {
    /// Global SwiftHooks logger
    public static var logger: Logger {
        var l = Logger(label: "SwiftHooks.Global")
        l.logLevel = .trace
        return l
    }
    
    /// Global SwiftHooks logger
    public var logger: Logger {
        return type(of: self).logger
    }
}
