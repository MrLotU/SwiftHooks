extension SwiftHooks {
    public func register<P: Plugin>(_ plugin: P) throws {
        self.plugins.append(plugin)
        let executables = plugin.commands.executables()
        try executables.validate()
        self.commands.append(contentsOf: executables)
        plugin.listeners.register(to: self)
    }
}

extension _Hook {
    public func register<P: Plugin>(_ plugin: P) {
        plugin.listeners.register(to: self)
    }
}
