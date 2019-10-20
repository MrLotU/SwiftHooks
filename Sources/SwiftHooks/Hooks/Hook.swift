import Foundation

public struct HookID: Hashable {
    public let identifier: String
    public init(identifier: String) {
        self.identifier = identifier
    }
}

public protocol Hook {
    func boot() throws
    func shutDown() throws
    
    var hooks: SwiftHooks? { get set }
    static var id: HookID { get }
    var translator: EventTranslator.Type { get }
    
    init<O>(_ options: O, hooks: SwiftHooks?) where O: HookOptions, O.H == Self
    
    func listen<T, I>(for event: T, handler: @escaping EventHandler<I>) where T: _Event, T.ContentType == I
    func dispatchEvent<E>(_ event: E, with payload: Payload, raw: Data) where E: EventType
}

public extension Hook {
    func listen<T, I>(for event: T, only: HookID..., handler: @escaping EventHandler<I>) where T: _Event, T.ContentType == I {
        self.listen(for: event, excluding: [], only: only, handler: handler)
    }

    func listen<T, I>(for event: T, excluding: HookID..., handler: @escaping EventHandler<I>) where T: _Event, T.ContentType == I {
        self.listen(for: event, excluding: excluding, only: [], handler: handler)
    }

    func listen<T, I>(for event: T, excluding: [HookID], only: [HookID], handler: @escaping EventHandler<I>) where T: _Event, T.ContentType == I {
        guard !excluding.contains(type(of: self).id), (only.isEmpty || only.contains(type(of: self).id)) else { return }
        self.listen(for: event, handler: handler)
    }
}

public protocol HookOptions {
    associatedtype H: Hook
}

public extension SwiftHooks {
    func hook<H, O>(_ hook: H.Type, _ options: O) throws where O: HookOptions, O.H == H {
        let hook = hook.init(options, hooks: self)
        try hook.boot()
        self.hooks.append(hook)
    }
}
