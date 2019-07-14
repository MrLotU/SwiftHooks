extension SwiftHooks {
    public func register(_ plugin: BasePlugin) throws {
        try plugin.boot()
        self.plugins.append(plugin)
    }
    
    public func register(_ plugin: Plugin.Type) throws {
        try self.register(plugin.init(self))
    }
}
