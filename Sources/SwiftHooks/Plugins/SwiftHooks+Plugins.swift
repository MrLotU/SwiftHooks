extension SwiftHooks {
    public func register(_ plugin: Plugin) throws {
//        try plugin.boot()
        
        Mirror(reflecting: plugin)
            .children
            .forEach{ child in
                if let value = child.value as? CCommand {
                    self.commands.append(value.command)
                }
            }
        
        self.plugins.append(plugin)
    }
    
//    public func register(_ plugin: Plugin.Type) throws {
//        try self.register(plugin.init(self))
//    }
}
