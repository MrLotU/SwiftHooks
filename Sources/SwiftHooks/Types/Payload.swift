import struct Foundation.Data

public typealias EventClosure = (Data) throws -> Void

//public protocol Payload {
//    var data: Data { get }
//}

extension SwiftHooks {
    public func dispatchEvent<E>(_ event: E, with raw: Data) where E: EventType {
        guard let event = event as? GlobalEvent else { return }
//        self.handleInternals(event, with: payload, raw: raw)
        
        let handlers = self.globalListeners[event]
        handlers?.forEach({ (handler) in
            do {
                try handler(raw)
            } catch {
                self.logger.error("\(error.localizedDescription)")
            }
        })
    }
    
//    private func handleInternals(_ event: GlobalEvent, with payload: Payload) {
//        if event == ._messageCreate, let m = payload.getData(Messageable.self, from: raw) {
//            self.handleMessage(m)
//        }
//    }
}
