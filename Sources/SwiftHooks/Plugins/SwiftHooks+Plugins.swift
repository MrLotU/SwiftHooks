extension SwiftHooks {
    /// Register a plugin to the SwiftHooks system.
    ///
    ///     swiftHooks.register(MyPlugin())
    ///
    /// This will add all commands & listeners in the plugin to all registered hooks.
    ///
    /// - parameters:
    ///     - plugin: Plugin to register
    public func register<P: Plugin>(_ plugin: P) throws {
        self.plugins.append(plugin)
        let executables = plugin.commands.executables()
        try executables.validate()
        self.commands.append(contentsOf: executables)
        plugin.listeners.register(to: self)
    }
}

extension _Hook {
    /// Register a plugin to a single hook.
    ///
    ///     myHook.register(MyPlugin())
    ///
    /// This will add all listeners in the plugin to this hook.
    ///
    /// - parameters:
    ///     - plugin: Plugin to register
    public func register<P: Plugin>(_ plugin: P) {
        plugin.listeners.register(to: self)
    }
}
