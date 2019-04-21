import Foundation

public typealias EventClosure = (Payload, Data) throws -> Void

public protocol Payload {
    func getData<T>(_ type: T.Type, from: Data) -> T?
}

extension SwiftHooks {
    public func dispatchEvent<E>(_ event: E, with payload: Payload, raw: Data) where E: EventType {
        guard let event = event as? GlobalEvent else { return }
        self.handleInternals(event, with: payload, raw: raw)
        
        let handlers = self.globalListeners[event]
        handlers?.forEach({ (handler) in
            do {
                try handler(payload, raw)
            } catch {
                self.logger.error("\(error.localizedDescription)")
            }
        })
    }
    
    private func handleInternals(_ event: GlobalEvent, with payload: Payload, raw: Data) {
        if event == ._messageCreate, let m = payload.getData(Messageable.self, from: raw) {
            self.handleMessage(m)
        }

    }
}
