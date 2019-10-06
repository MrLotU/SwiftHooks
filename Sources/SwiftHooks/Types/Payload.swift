import Foundation

public typealias EventClosure = (Payload, Data) throws -> Void

public protocol Payload {
//    associatedtype Body
    func getData<T>(_ type: T.Type, from: Data) -> T?
}

extension SwiftHooks {
    public func dispatchEvent(_ event: GlobalEvent, with payload: Payload, raw: Data) {
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
