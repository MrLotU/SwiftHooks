extension SwiftHooks {
    public func listen<T, I>(for event: T, _ handler: @escaping EventHandler<I>) where T: MType, T.ContentType == I {
        if let event = event as? GlobalMType<I, GlobalEvent> {
            self.gListen(for: event, handler)
        }
        self.hooks.forEach { $0.listen(for: event, handler) }
    }
    
    func gListen<I>(for event: GlobalMType<I, GlobalEvent>, _ handler: @escaping EventHandler<I>) {
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
