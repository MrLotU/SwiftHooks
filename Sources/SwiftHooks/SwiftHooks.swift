import Logging

public final class SwiftHooks {
    public var hooks: [Hook]
    
    public internal(set) var globalListeners: [GlobalEvent: [EventClosure]]
    public internal(set) var commands: [Command]
    public internal(set) var plugins: [Plugin]
    
    public init() {
        self.hooks = []
        self.globalListeners = [:]
        self.commands = []
        self.plugins = []
    }

    public func hook(_ hook: Hook) throws {
        try hook.boot()
        self.hooks.append(hook)
    }
}

extension SwiftHooks {
    public static let logger = Logger(label: "SwiftHooks.Global")
    
    public var logger: Logger {
        return type(of: self).logger
    }
}
