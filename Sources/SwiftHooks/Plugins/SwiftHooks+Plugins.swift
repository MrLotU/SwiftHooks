extension SwiftHooks {
    public func register(_ plugin: Plugin) {
        self.plugins.append(plugin)
        self.commands.append(contentsOf: plugin.commands)
        plugin.registerListeners(to: self)
    }
}
