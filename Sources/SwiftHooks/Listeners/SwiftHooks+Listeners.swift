import Foundation

extension SwiftHooks {
    func listen<T, I, D>(for event: T, _ handler: @escaping EventHandler<D, I>) where T: _Event, T.ContentType == I, T.D == D {
        if let event = event as? _GlobalEvent<I>, let h = handler as? EventHandler<GlobalDispatch, I> {
            self.gListen(for: event, h)
        }
        self.hooks.forEach { $0.listen(for: event, handler: handler) }
    }
    
    func gListen<T, I>(for event: T, _ handler: @escaping EventHandler<GlobalDispatch, I>) where T: _GEvent, T.ContentType == I {
        guard let event = event as? _GlobalEvent<I> else { self.logger.error("`SwiftHooks.gListen(for:_:)` called with a non `_GlobalEvent<GlobalEvent, I>` type. This should never happen."); return }
        var closures = self.globalListeners[event, default: []]
        closures.append { (data, hook, el) in
            guard let object = hook.decodeConcreteType(for: event.event, with: data, as: I.self, on: el) else {
                self.logger.debug("Unable to extract \(I.self) from data.")
                return el.makeFailedFuture(SwiftHooksError.ConcreteTypeCreationFailure("\(I.self)"))
            }
            
            return handler(.init(el), object)
        }
        self.globalListeners[event] = closures
    }
}


public enum SwiftHooksError: Error {
    case ConcreteTypeCreationFailure(String)
    case DispatchCreationError
    case GenericTypeCreationFailure(String)
}
