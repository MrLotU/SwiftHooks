import Foundation

extension SwiftHooks {
    func listen<T, I>(for event: T, _ handler: @escaping EventHandler<I>) where T: _Event, T.ContentType == I {
        if let event = event as? _GlobalEvent<GlobalEvent, I> {
            self.gListen(for: event, handler)
        }
        self.hooks.forEach { $0.listen(for: event, handler: handler) }
    }
    
    func gListen<I>(for event: _GlobalEvent<GlobalEvent, I>, _ handler: @escaping EventHandler<I>) {
        var closures = self.globalListeners[event, default: []]
        closures.append { (payload, data) in
            guard let object = payload.getData(I.self, from: data) else {
                self.logger.debug("Unable to extract \(I.self) from data.")
                return
            }
            try handler(object)
        }
        self.globalListeners[event] = closures
    }
}
