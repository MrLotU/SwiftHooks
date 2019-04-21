import Foundation

public typealias EventClosure = (Payload, Data) throws -> Void

public protocol Payload {
    func getData<T>(_ type: T.Type, from: Data) -> T?
}

extension SwiftHooks {
    public func dispatchEvent<E>(_ event: E, with payload: Payload, raw: Data) where E: EventType {
        guard let event = event as? GlobalEvent else { return }
        let handlers = self.globalListeners[event]
        handlers?.forEach({ (handler) in
            do {
                try handler(payload, raw)
            } catch {
                self.logger.error("\(error.localizedDescription)")
            }
        })
    }
}
