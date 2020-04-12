extension SwiftHooks {
    public func register<P: Plugin>(_ plugin: P) {
        self.plugins.append(plugin)
        self.commands.append(contentsOf: plugin.commands.executables())
        plugin.listeners.register(to: self)
    }
}

extension _Hook {
    public func register<P: Plugin>(_ plugin: P) {
        plugin.listeners.register(to: self)
    }
}
