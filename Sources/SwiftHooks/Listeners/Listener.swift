protocol IListener {
    func register(to h: SwiftHooks)
}

@propertyWrapper
public final class Listener<T, I>: IListener where T: _Event, T.ContentType == I {
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
}
