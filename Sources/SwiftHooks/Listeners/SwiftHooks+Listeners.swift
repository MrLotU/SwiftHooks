import Foundation

extension SwiftHooks {
    func listen<T, I>(for event: T, _ handler: @escaping EventHandler<I>) where T: _Event, T.ContentType == I {
        if let event = event as? _GlobalEvent<GlobalEvent, I> {
            self.gListen(for: event, handler)
        }
        self.hooks.forEach { $0.listen(for: event, handler: handler) }
    }
    
    func gListen<T, I>(for event: T, _ handler: @escaping EventHandler<I>) where T: _GEvent, T.ContentType == I {
        guard let event = event as? _GlobalEvent<GlobalEvent, I> else { self.logger.error("`SwiftHooks.gListen(for:_:)` called with a non `_GlobalEvent<GlobalEvent, I>` type. This should never happen."); return }
        var closures = self.globalListeners[event, default: []]
        closures.append { (data, hook) in
            guard let object = hook.translator.decodeConcreteType(for: event.event, with: data, as: I.self) else {
                self.logger.debug("Unable to extract \(I.self) from data.")
                return
            }
            try handler(object)
        }
        self.globalListeners[event] = closures
    }
}
