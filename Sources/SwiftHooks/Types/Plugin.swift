public protocol BasePlugin: class {
    var hooks: SwiftHooks { get }
    
    func boot() throws
}

public protocol Plugin: BasePlugin {
    init(_ hooks: SwiftHooks)
}
