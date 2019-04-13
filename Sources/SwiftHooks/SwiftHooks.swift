public final class SwiftHooks {
    public var hooks: [Hook]
    
    public func hook(_ hook: Hook) throws {
        self.hooks.append(hook)
        try hook.connect()
    }
    
    init() {
        self.hooks = []
    }
}
