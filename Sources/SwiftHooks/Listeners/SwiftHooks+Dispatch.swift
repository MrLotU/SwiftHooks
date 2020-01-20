import struct Foundation.Data
import class Metrics.Counter

public typealias EventClosure = (Data) throws -> Void
public typealias GlobalEventClosure = (Data, _Hook) throws -> Void

extension SwiftHooks {
    public func dispatchEvent<E>(_ e: E, with raw: Data, from h: _Hook) where E: EventType {
        guard let event = h.translate(e) else { return }
        Counter(label: "global_events_dispatched", dimensions: [("hook", type(of: h).id.identifier), ("event", "\(event)")]).increment()
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
    
    private func handleInternals(_ event: GlobalEvent, with raw: Data, from h: _Hook) {
        if event == ._messageCreate, let m = h.decodeConcreteType(for: event, with: raw, as: Messageable.self) {
            self.handleMessage(m)
        }
    }
}
