/// EventListeners used in `Plugin`s.
public protocol EventListeners {
    /// Used to register listener closures to main `SwiftHooks` class.
    func register(to h: SwiftHooks)
    /// Used to register listener closures to a specific `_Hook`.
    func register(to h: _Hook)
}

/// Group multiple `EventListeners` together.
public struct Listeners: EventListeners {
    let listeners: EventListeners
    
    /// Create new `Listeners`
    ///
    /// - parameters:
    ///     - listeners: `EventListeners` in this group.
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

/// NOOP provider for `EventListeners`.
public struct NoListeners: EventListeners {
    public func register(to h: SwiftHooks) { }
    public func register(to h: _Hook) { }
}

/// Listener used to listen to specific hook events.
///
///     Listener(Discord.messageCreate) { ... }
///     Listener(MyHook.myCustomEvent) { ... }
///
public struct Listener<T, I, D>: EventListeners where T: _Event, T.ContentType == I, T.D == D {
    let event: T
    let closure: EventHandler<D, I>
    
    /// Create new `Listener`.
    ///
    /// - parameters:
    ///     - event: Event to listen for.
    ///     - closure: Closure to invoke when receiving event `T`.
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

/// Listener used to listen to global events.
///
///     Listener(Global.messageCreate) { ... }
///
public struct GlobalListener<T, I>: EventListeners where T: _GEvent, T.ContentType == I {
    let event: T
    let closure: EventHandler<GlobalDispatch, I>
    
    /// Create new `GlobalListener`.
    ///
    /// - parameters:
    ///     - event: GlobalEvent to listen for.
    ///     - closure: Closure to invoke when receiving event `T`.
    public init(_ event: T, _ closure: @escaping EventHandler<GlobalDispatch, I>) {
        self.event = event
        self.closure = closure
    }
    
    public func register(to h: SwiftHooks) {
        h.gListen(for: event, closure)
    }
    
    public func register(to h: _Hook) { }
}
