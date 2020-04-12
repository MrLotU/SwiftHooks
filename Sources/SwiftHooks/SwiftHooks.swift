import Foundation
import NIO
import Logging

public final class SwiftHooks {
    public let eventLoopGroup: EventLoopGroup
    public private(set) var didShutdown: Bool
    private var isBooted: Bool
    private var running: EventLoopPromise<Void>?
    
    public var hooks: [_Hook]
    public internal(set) var globalListeners: [GlobalEvent: [GlobalEventClosure]]
    public internal(set) var commands: [_ExecutableCommand]
    public internal(set) var plugins: [_Plugin]
    
    public static let decoder = JSONDecoder()
    public static let encoder = JSONEncoder()
    
    public init(eventLoopGroup: EventLoopGroup? = nil) {
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
    }
    
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
    public static var logger: Logger {
        var l = Logger(label: "SwiftHooks.Global")
        l.logLevel = .trace
        return l
    }
    
    public var logger: Logger {
        return type(of: self).logger
    }
}
