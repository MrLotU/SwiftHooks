public final class SwiftHooks {
    public var hooks: [Hook]
    
    public internal(set) var globalListeners: [GlobalEvent: [EventClosure]]
    
    public init() {
        self.hooks = []
        self.globalListeners = [:]
    }

    public func hook(_ hook: Hook) throws {
        self.hooks.append(hook)
        try hook.connect()
    }
    
    public func listen<T, I>(for event: T, _ handler: @escaping (I) -> ()) where T: MType, T.ContentType == I {
        if let event = event as? GlobalMType<I, GlobalEvent> {
            self.gListen(for: event, handler)
        }
    }
    
    func gListen<I>(for event: GlobalMType<I, GlobalEvent>, _ handler: @escaping EventHandler<I>) {
        var closures = self.globalListeners[event, default: []]
        closures.append { (event, data) in
            guard let object = event.getData(I.self, from: data) else {
                // TODO: Log
                return
            }
            try handler(object)
        }
        self.globalListeners[event] = closures
    }
}
