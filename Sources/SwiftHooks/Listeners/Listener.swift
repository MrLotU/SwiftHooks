protocol _Listener {
    func register(to h: SwiftHooks)
    func register(to h: _Hook)
}

@propertyWrapper
public final class GlobalListener<T, I>: _Listener where T: _GEvent, T.ContentType == I {
    let event: T
    
    public var wrappedValue: EventHandler<I>
    
    public init(wrappedValue: @escaping EventHandler<I>, _ event: T) {
        self.event = event
        self.wrappedValue = wrappedValue
    }
    
    public init(_ event: T) {
        self.event = event
        self.wrappedValue = { _ in }
    }
    
    func register(to h: SwiftHooks) {
        h.gListen(for: event, wrappedValue)
    }
    
    func register(to h: _Hook) { }
}

@propertyWrapper
public final class Listener<T, I>: _Listener where T: _Event, T.ContentType == I {
    let event: T
    
    public var wrappedValue: EventHandler<I>
    
    public init(wrappedValue: @escaping EventHandler<I>, _ event: T) {
        self.event = event
        self.wrappedValue = wrappedValue
    }
    
    public init(_ event: T) {
        self.event = event
        self.wrappedValue = { _ in }
    }
    
    func register(to h: SwiftHooks) {
        h.listen(for: event, wrappedValue)
    }
    
    func register(to h: _Hook) {
        h.listen(for: event, handler: wrappedValue)
    }
}
