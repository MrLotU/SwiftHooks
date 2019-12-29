extension SwiftHooks {
    public func register(_ plugin: Plugin) {
        self.plugins.append(plugin)
        self.commands.append(contentsOf: plugin.commands)
        plugin.registerListeners(to: self)
    }
}

extension _Hook {
    public func register(_ plugin: Plugin) {
        plugin.registerListeners(to: self)
    }
}
