public protocol Plugin { }

extension Plugin {
    var commands: [Command] {
        return Mirror(reflecting: self)
            .children
            .compactMap { child in
                if let value = child.value as? Command {
                    return value
                }
                return nil
            }
    }
    
    func registerListeners(to h: _Hook) {
        listeners.forEach { listener in
                listener.register(to: h)
        }
    }
    
    func registerListeners(to h: SwiftHooks) {
        listeners.forEach { listener in
                listener.register(to: h)
        }
    }
    
    var listeners: [_Listener] {
        return Mirror(reflecting: self)
            .children
            .compactMap { $0.value as? _Listener }
    }
}
