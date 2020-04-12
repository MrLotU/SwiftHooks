public protocol EventListeners {
    func register(to h: SwiftHooks)
    func register(to h: _Hook)
}

public struct Listeners: EventListeners {
    let listeners: EventListeners
    
    public init(@ListenerBuilder listeners: () -> EventListeners) {
        self.listeners = listeners()
    }
    
    public func register(to h: SwiftHooks) {
        self.listeners.register(to: h)
    }
    
    public func register(to h: _Hook) {
        self.listeners.register(to: h)
    }
}

public struct NoListeners: EventListeners {
    public func register(to h: SwiftHooks) { }
    public func register(to h: _Hook) { }
}

public struct Listener<T, I, D>: EventListeners where T: _Event, T.ContentType == I, T.D == D {
    let event: T
    let closure: EventHandler<D, I>
    
    public init(_ event: T, _ closure: @escaping EventHandler<D, I>) {
        self.event = event
        self.closure = closure
    }
    
    public func register(to h: SwiftHooks) {
        h.listen(for: event, closure)
    }
    
    public func register(to h: _Hook) {
        h.listen(for: event, handler: closure)
    }
}

public struct GlobalListener<T, I>: EventListeners where T: _GEvent, T.ContentType == I {
    let event: T
    let closure: EventHandler<GlobalDispatch, I>
    
    public init(_ event: T, _ closure: @escaping EventHandler<GlobalDispatch, I>) {
        self.event = event
        self.closure = closure
    }
    
    public func register(to h: SwiftHooks) {
        h.gListen(for: event, closure)
    }
    
    public func register(to h: _Hook) { }
}
