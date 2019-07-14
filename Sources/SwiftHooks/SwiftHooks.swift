import Logging

public final class SwiftHooks {
    public var hooks: [Hook]
    
    public internal(set) var globalListeners: [GlobalEvent: [EventClosure]]
    public internal(set) var commands: [Command]
    public internal(set) var plugins: [BasePlugin]
    
    public init() {
        self.hooks = []
        self.globalListeners = [:]
        self.commands = []
        self.plugins = []
    }

    public func hook(_ hook: Hook) throws {
        self.hooks.append(hook)
        try hook.boot()
    }
}

extension SwiftHooks {
    public static let logger = Logger(label: "SwiftHooks.Global")
    
    public var logger: Logger {
        return type(of: self).logger
    }
}
