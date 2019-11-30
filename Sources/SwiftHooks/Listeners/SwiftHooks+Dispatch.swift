import struct Foundation.Data

public typealias EventClosure = (Data) throws -> Void
public typealias GlobalEventClosure = (Data, Hook) throws -> Void

extension SwiftHooks {
    public func dispatchEvent<E>(_ event: E, with raw: Data, from h: Hook) where E: EventType {
        guard let event = h.translator.translate(event) else { return }
        self.handleInternals(event, with: raw, from: h)
        
        let handlers = self.globalListeners[event]
        handlers?.forEach({ (handler) in
            do {
                try handler(raw, h)
            } catch {
                self.logger.error("\(error.localizedDescription)")
            }
        })
    }
    
    private func handleInternals(_ event: GlobalEvent, with raw: Data, from h: Hook) {
        if event == ._messageCreate, let m = h.translator.decodeConcreteType(for: event, with: raw, as: Messageable.self) {
            self.handleMessage(m)
        }
    }
}
