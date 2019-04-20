public protocol Hook {
    func boot() throws
    func shutDown() throws
    
    var hooks: SwiftHooks? { get set }
    
    init<O>(_ options: O, hooks: SwiftHooks?) where O: HookOptions, O.H == Self
    
    func listen<T, I>(for event: T, _ handler: @escaping EventHandler<I>) where T: MType, T.ContentType == I
}

public protocol HookOptions {
    associatedtype H: Hook
}

public extension SwiftHooks {
    func hook<H, O>(_ hook: H.Type, _ options: O) throws where O: HookOptions, O.H == H {
        let hook = hook.init(options, hooks: self)
        self.hooks.append(hook)
        try hook.boot()
    }
}
