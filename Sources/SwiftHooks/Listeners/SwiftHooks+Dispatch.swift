import NIO
import struct Foundation.Data
import class Metrics.Counter

public typealias EventClosure = (Data, EventLoop) -> EventLoopFuture<Void>
public typealias GlobalEventClosure = (Data, _Hook, EventLoop) -> EventLoopFuture<Void>

extension SwiftHooks {
    /// Dispatch an event from a `_Hook` into the central `SwiftHooks` system.
    ///
    /// - parameters:
    ///     - e: Event to dispatch
    ///     - raw: Raw bytes containing the event.
    ///     - h: Hook this event originated from.
    public func dispatchEvent<E>(_ e: E, with raw: Data, from h: _Hook, on eventLoop: EventLoop) -> EventLoopFuture<Void> where E: EventType {
        guard let event = h.translate(e) else { return eventLoop.makeSucceededFuture(()) }
        Counter(label: "global_events_dispatched", dimensions: [("hook", type(of: h).id.identifier), ("event", "\(event)")]).increment()
        self.handleInternals(event, with: raw, from: h, on: eventLoop)
        
        let futures = self.lock.withLock { () -> [EventLoopFuture<Void>] in
            let handlers = self.globalListeners[event] ?? []
            return handlers.map({ (handler) in
                handler(raw, h, eventLoop)
            })
        }
        return EventLoopFuture.andAllSucceed(futures, on: eventLoop)
    }
    
    private func handleInternals(_ event: GlobalEvent, with raw: Data, from h: _Hook, on eventLoop: EventLoop) {
        if event == ._messageCreate, let m = h.decodeConcreteType(for: event, with: raw, as: Messageable.self, on: eventLoop) {
            self.handleMessage(m, from: h, on: eventLoop)
        }
    }
}
