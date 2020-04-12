@_functionBuilder public struct ListenerBuilder {
    public static func buildBlock<T>(_ listener: T) -> T where T: EventListeners {
        return listener
    }
    
    public static func buildBlock<L0, L1>(_ l0: L0, _ l1: L1) -> ListenerTuple<(L0, L1)> where L0: EventListeners, L1: EventListeners {
        return .init(tuple: (l0, l1))
    }
    
    public static func buildBlock<L0, L1, L2>(_ l0: L0, _ l1: L1, _ l2: L2) -> ListenerTuple<(L0, L1, L2)> where L0: EventListeners, L1: EventListeners, L2: EventListeners {
        return .init(tuple: (l0, l1, l2))
    }
    
    public static func buildBlock<L0, L1, L2, L3>(_ l0: L0, _ l1: L1, _ l2: L2, _ l3: L3) -> ListenerTuple<(L0, L1, L2, L3)> where L0: EventListeners, L1: EventListeners, L2: EventListeners, L3: EventListeners {
        return .init(tuple: (l0, l1, l2, l3))
    }
    
    public static func buildBlock<L0, L1, L2, L3, L4>(_ l0: L0, _ l1: L1, _ l2: L2, _ l3: L3, _ l4: L4) -> ListenerTuple<(L0, L1, L2, L3, L4)> where L0: EventListeners, L1: EventListeners, L2: EventListeners, L3: EventListeners, L4: EventListeners {
        return .init(tuple: (l0, l1, l2, l3, l4))
    }
    
    public static func buildBlock<L0, L1, L2, L3, L4, L5>(_ l0: L0, _ l1: L1, _ l2: L2, _ l3: L3, _ l4: L4, _ l5: L5) -> ListenerTuple<(L0, L1, L2, L3, L4, L5)> where L0: EventListeners, L1: EventListeners, L2: EventListeners, L3: EventListeners, L4: EventListeners, L5: EventListeners {
        return .init(tuple: (l0, l1, l2, l3, l4, l5))
    }
    
    public static func buildBlock<L0, L1, L2, L3, L4, L5, L6>(_ l0: L0, _ l1: L1, _ l2: L2, _ l3: L3, _ l4: L4, _ l5: L5, _ l6: L6) -> ListenerTuple<(L0, L1, L2, L3, L4, L5, L6)> where L0: EventListeners, L1: EventListeners, L2: EventListeners, L3: EventListeners, L4: EventListeners, L5: EventListeners, L6: EventListeners {
        return .init(tuple: (l0, l1, l2, l3, l4, l5, l6))
    }
    
    public static func buildBlock<L0, L1, L2, L3, L4, L5, L6, L7>(_ l0: L0, _ l1: L1, _ l2: L2, _ l3: L3, _ l4: L4, _ l5: L5, _ l6: L6, _ l7: L7) -> ListenerTuple<(L0, L1, L2, L3, L4, L5, L6, L7)> where L0: EventListeners, L1: EventListeners, L2: EventListeners, L3: EventListeners, L4: EventListeners, L5: EventListeners, L6: EventListeners, L7: EventListeners {
        return .init(tuple: (l0, l1, l2, l3, l4, l5, l6, l7))
    }
    
    public static func buildBlock<L0, L1, L2, L3, L4, L5, L6, L7, L8>(_ l0: L0, _ l1: L1, _ l2: L2, _ l3: L3, _ l4: L4, _ l5: L5, _ l6: L6, _ l7: L7, _ l8: L8) -> ListenerTuple<(L0, L1, L2, L3, L4, L5, L6, L7, L8)> where L0: EventListeners, L1: EventListeners, L2: EventListeners, L3: EventListeners, L4: EventListeners, L5: EventListeners, L6: EventListeners, L7: EventListeners, L8: EventListeners {
        return .init(tuple: (l0, l1, l2, l3, l4, l5, l6, l7, l8))
    }
    
    public static func buildBlock<L0, L1, L2, L3, L4, L5, L6, L7, L8, L9>(_ l0: L0, _ l1: L1, _ l2: L2, _ l3: L3, _ l4: L4, _ l5: L5, _ l6: L6, _ l7: L7, _ l8: L8, _ l9: L9) -> ListenerTuple<(L0, L1, L2, L3, L4, L5, L6, L7, L8, L9)> where L0: EventListeners, L1: EventListeners, L2: EventListeners, L3: EventListeners, L4: EventListeners, L5: EventListeners, L6: EventListeners, L7: EventListeners, L8: EventListeners, L9: EventListeners {
        return .init(tuple: (l0, l1, l2, l3, l4, l5, l6, l7, l8, l9))
    }
}

public struct ListenerTuple<T>: EventListeners {
    public func register(to h: SwiftHooks) {
        self.listeners().forEach { $0.register(to: h) }
    }
    
    public func register(to h: _Hook) {
        self.listeners().forEach { $0.register(to: h) }
    }
    
    func listeners() -> [EventListeners] {
        if let (l0, l1) = tuple as? (EventListeners, EventListeners) {
            return [l0, l1]
        } else if let (l0, l1, l2) = tuple as? (EventListeners, EventListeners, EventListeners) {
            return [l0, l1, l2]
        } else if let (l0, l1, l2, l3) = tuple as? (EventListeners, EventListeners, EventListeners, EventListeners) {
            return [l0, l1, l2, l3]
        } else if let (l0, l1, l2, l3, l4) = tuple as? (EventListeners, EventListeners, EventListeners, EventListeners, EventListeners) {
            return [l0, l1, l2, l3, l4]
        } else if let (l0, l1, l2, l3, l4, l5) = tuple as? (EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners) {
           return [l0, l1, l2, l3, l4, l5]
        } else if let (l0, l1, l2, l3, l4, l5, l6) = tuple as? (EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners) {
           return [l0, l1, l2, l3, l4, l5, l6]
        } else if let (l0, l1, l2, l3, l4, l5, l6, l7) = tuple as? (EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners) {
           return [l0, l1, l2, l3, l4, l5, l6, l7]
        } else if let (l0, l1, l2, l3, l4, l5, l6, l7, l8) = tuple as? (EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners) {
           return [l0, l1, l2, l3, l4, l5, l6, l7, l8]
        } else if let (l0, l1, l2, l3, l4, l5, l6, l7, l8, l9) = tuple as? (EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners, EventListeners) {
           return [l0, l1, l2, l3, l4, l5, l6, l7, l8, l9]
        }
        return []
    }
    
    public func group(_ group: String) -> ListenerTuple<T> {
        return self
    }
    
    let tuple: T
}
